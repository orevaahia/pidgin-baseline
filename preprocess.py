import time
import sys
import csv

from os import cpu_count
from functools import partial
from multiprocessing import Pool

from fuzzywuzzy import process
import numpy as np
import pandas as pd


if __name__ == "__main__":

    #get paths
    en_path = sys.argv[1]
    pcm_path = sys.argv[2]

    # Read the test data to filter from train and dev splits.
    en_test_sents = set()
    filter_test_sents = en_path+"/test.en-any.en"
    j = 0
    with open(filter_test_sents) as f:
        for line in f:
            en_test_sents.add(line.strip())
            j += 1
    print('Loaded {} global test sentences to filter from the training/dev data.'.format(j))

    # TMX file to dataframe
    en_file = en_path+'/jw300.en'
    pcm_file = pcm_path+'/jw300.pcm'

    en = []
    pcm = []
    skip_lines = []  # Collect the line numbers of the source portion to skip the same lines for the target portion.
    with open(en_file) as f:
        for i, line in enumerate(f):
            # Skip sentences that are contained in the test set.
            if line.strip() not in en_test_sents:
                en.append(line.strip())
            else:
                skip_lines.append(i)             
    with open(pcm_file) as f:
        for j, line in enumerate(f):
            # Only add to corpus if corresponding source was not skipped.
            if j not in skip_lines:
                pcm.append(line.strip())
        
    print('Loaded data and skipped {}/{} lines since contained in test set.'.format(len(skip_lines), i))
    
    #create a dataframe of data
    df = pd.DataFrame(zip(en, pcm), columns=['en_sentence', 'pcm_sentence'])

    # drop duplicate translations
    df_pp = df.drop_duplicates()

    # drop conflicting translations in same language
    df_pp.drop_duplicates(subset='en_sentence', inplace=True)
    df_pp.drop_duplicates(subset='pcm_sentence', inplace=True)

    # Shuffle the data to remove bias in dev set selection.
    df_pp = df_pp.sample(frac=1, random_state=42).reset_index(drop=True)

    # reset the index of the training set after previous filtering
    df_pp.reset_index(drop=False, inplace=True)

    # Remove samples from the training data set if they "almost overlap" with the samples in the test set.
    def fuzzfilter(sample, candidates, pad):
        candidates = [x for x in candidates if len(x) <= len(sample)+pad and len(x) >= len(sample)-pad] 
        if len(candidates) > 0:
            return process.extractOne(sample, candidates)[1]
        else:
            return np.nan

    start_time = time.time()

    #run with multiprocessing
    with Pool(cpu_count()-1) as pool:
        scores = pool.map(partial(fuzzfilter, candidates=list(en_test_sents), pad=5), df_pp['en_sentence'])
    hours, rem = divmod(time.time() - start_time, 3600)
    minutes, seconds = divmod(rem, 60)
    print("done in {}h:{}min:{}seconds".format(hours, minutes, seconds))

    # Filter out "almost overlapping samples"
    df_pp = df_pp.assign(scores=scores)
    df_pp = df_pp[df_pp['scores'] < 95]

    # Do the split between dev/train and create parallel corpora
    dev_size = 1000

    #convert to lower case
    df_pp["en_sentence"] = df_pp["en_sentence"].str.lower()
    df_pp["pcm_sentence"] = df_pp["pcm_sentence"].str.lower()

    #get dev set and drop from train
    dev = df_pp.tail(dev_size) 
    stripped = df_pp.drop(df_pp.tail(dev_size).index) 

    print("saving preprocessed {} train sentences and {} dev sentences...".format(len(stripped), len(dev)))

    #save train file
    with open(en_path+"/train.en", "w") as src_file, open(pcm_path+"/train.pcm", "w") as trg_file:
        for index, row in stripped.iterrows():
            src_file.write(row["en_sentence"]+"\n")
            trg_file.write(row["pcm_sentence"]+"\n")
    
    #save dev file
    with open(en_path+"/dev.en", "w") as src_file, open(pcm_path+"/dev.pcm", "w") as trg_file:
        for index, row in dev.iterrows():
            src_file.write(row["en_sentence"]+"\n")
            trg_file.write(row["pcm_sentence"]+"\n")
        

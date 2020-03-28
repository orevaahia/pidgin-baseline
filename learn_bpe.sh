

#specify paths
BASELINE_PATH=$PWD
DATA_PATH=$BASELINE_PATH/data
TOOLS_PATH=$BASELINE_PATH/tools
JOEY_PATH=$TOOLS_PATH/joeynmt
EN_PATH=$DATA_PATH/en
PCM_PATH=$DATA_PATH/pcm
JOEY_DATA_PATH=$JOEY_PATH/en-pcm-data

mkdir -p $JOEY_DATA_PATH


#Learn BPE
echo "Learning BPE codes..."
subword-nmt learn-joint-bpe-and-vocab --input $EN_PATH/train.en $PCM_PATH/train.pcm -s 4000 -o $DATA_PATH/bpe.codes.4000 --write-vocabulary $EN_PATH/vocab.en $PCM_PATH/vocab.pcm
echo "Done!"

#Apply BPE splits to the train, development and test data.
echo "Applying BPE codes to data..."
subword-nmt apply-bpe -c $DATA_PATH/bpe.codes.4000 --vocabulary $EN_PATH/vocab.en < $EN_PATH/train.en > $EN_PATH/train.bpe.en
subword-nmt apply-bpe -c $DATA_PATH/bpe.codes.4000 --vocabulary $PCM_PATH/vocab.pcm < $PCM_PATH/train.pcm > $PCM_PATH/train.bpe.pcm

subword-nmt apply-bpe -c $DATA_PATH/bpe.codes.4000 --vocabulary $EN_PATH/vocab.en < $EN_PATH/dev.en > $EN_PATH/dev.bpe.en
subword-nmt apply-bpe -c $DATA_PATH/bpe.codes.4000 --vocabulary $PCM_PATH/vocab.pcm < $PCM_PATH/dev.pcm > $PCM_PATH/dev.bpe.pcm

subword-nmt apply-bpe -c $DATA_PATH/bpe.codes.4000 --vocabulary $EN_PATH/vocab.en < $EN_PATH/test.en > $EN_PATH/test.bpe.en
subword-nmt apply-bpe -c $DATA_PATH/bpe.codes.4000 --vocabulary $PCM_PATH/vocab.pcm < $PCM_PATH/test.pcm > $PCM_PATH/test.bpe.pcm
echo "Done!"

#create a data path in joeynmt
echo "Copying all data to training data path"

#copy bpe codes to joey data path
cp $EN_PATH/train.* $JOEY_DATA_PATH
cp $EN_PATH/test.* $JOEY_DATA_PATH
cp $EN_PATH/dev.* $JOEY_DATA_PATH
cp $EN_PATH/vocab.* $JOEY_DATA_PATH

cp $PCM_PATH/train.* $JOEY_DATA_PATH
cp $PCM_PATH/test.* $JOEY_DATA_PATH
cp $PCM_PATH/dev.* $JOEY_DATA_PATH
cp $PCM_PATH/vocab.* $JOEY_DATA_PATH

cp $DATA_PATH/bpe.codes.4000 $JOEY_DATA_PATH

echo "Combining learned vocabulary into..."
# create combined vocab using joeynmt's build_vocab
chmod +x $JOEY_PATH/scripts/build_vocab.py
$JOEY_PATH/scripts/build_vocab.py $JOEY_DATA_PATH/train.bpe.en $JOEY_DATA_PATH/train.bpe.pcm --output_path $JOEY_DATA_PATH/vocab.txt

echo "Done!"

#list out files in joey data path
echo "Below are the files in the joey data path"
ls $JOEY_DATA_PATH


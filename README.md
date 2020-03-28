# PidginBaseline : Towards Supervised and Unsupervised Neural Machine Translation Baselines for Nigerian Pidgin 

This repository contains the code for the paper titled - Towards Supervised and Unsupervised Neural Machine Translation Baselines for Nigerian Pidgin - and presented at the International Learning on Language Representations (ICLR) 2020 workshop on African NLP, April 2020, Addis Ababa, Ethiopia.

Link to paper - 

## Running the Code:

```
git clone https://github.com/orevaoghene/pidgin-baseline
cd pidigin-baseline
pip install -r requirements.txt
./get_data.sh
```

The above commands will:

1. Clone the repository
2. Change your present working directory to the cloned repository
3. Install all requirements
3. Download and preprocess the train, test and dev sets. 

Now that you have the data, you can now specify your required training configuration in the config.yaml file. For more information about the configurations, please refer to the [Joeynmt configuration documentation](https://joeynmt.readthedocs.io/en/latest/tutorial.html#configuration) The configuration files used in our experiments are available in the
[experiments folder](./experiments). 

If you would be training with byte pair encodings, you would need to run the learn_bpe shell script before training, as this will learn the byte pair encodings needed. 
```
./learn_bpe.sh
```

Once you have specified the necessary configurations and learned byte pair encodings (if need be), you can start training by running the train_model shell script. 
```
./train_model.sh
```

You will be required to specify an experiment name after you run the train_model shell script.


## Unsupervised Baselines

To run the unsupervised baselines, follow the instructions in the [PidginUNMT repository.](https://github.com/keleog/PidginUNMT) 

## Results

### Bleu Scores

**English to Pidgin Translation**:
- Unsupervised Model (word-level) - 5.18
- Supervised Model (word-level) - 17.73
- Supervised Model (BPE) - **24.29**

**Pidgin to English Translation**:
- Unsupervised Model (word-level) - 7.93
- Supervised Model (word-level) - **24.67**
- Supervised Model (BPE) - 13.00

### Model Translations
Please refer to the [experiments folder](./experiments) to see the result translations by the different models. 

## Acknowledgments

Special thanks to the Masakhane group - [website](masakhane.io) and [github](https://github.com/masakhane-io) for literally catalysing this work. 






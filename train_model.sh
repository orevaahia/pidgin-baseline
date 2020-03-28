#receive experiment name from user
echo "Please enter experiment name"
read experiment_name

#specify paths
BASELINE_PATH=$PWD
DATA_PATH=$BASELINE_PATH/data
TOOLS_PATH=$BASELINE_PATH/tools
EN_PATH=$DATA_PATH/en
PCM_PATH=$DATA_PATH/pcm
JOEY_PATH=$TOOLS_PATH/joeynmt
JOEY_DATA_PATH=$JOEY_PATH/en-pcm-data
JOEY_MODELS_PATH=$JOEY_PATH/models
RESULTS_PATH=$BASELINE_PATH/results
EXPERIMENT_PATH=$RESULTS_PATH/$experiment_name 

#create paths
mkdir -p $RESULTS_PATH
mkdir -p $EXPERIMENT_PATH

#copy config file to joeynmt path and start training
cp config.yaml $JOEY_PATH/configs/config.yaml
cd $JOEY_PATH
python -m joeynmt train configs/config.yaml

#copy trained model files to experiment path
cd $JOEY_MODELS_PATH
cp -p -r "`ls -tr | tail -1`" $EXPERIMENT_PATH
echo "Experiments results saved in $EXPERIMENT_PATH"

#test model
echo "Testing Model..."
cd $JOEY_PATH
python -m joeynmt test configs/config.yaml
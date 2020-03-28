
echo "Welcome!"

#specify paths
BASELINE_PATH=$PWD
DATA_PATH=$BASELINE_PATH/data
TOOLS_PATH=$BASELINE_PATH/tools
EN_PATH=$DATA_PATH/en
PCM_PATH=$DATA_PATH/pcm

#create paths
mkdir -p $DATA_PATH
mkdir -p $TOOLS_PATH
mkdir -p $EN_PATH
mkdir -p $PCM_PATH


echo "downloading parallel data from opus..."

#download data from opus
cd $DATA_PATH
opus_read -d JW300 -s en -t pcm -wm moses -w jw300.en jw300.pcm -q
gunzip JW300_latest_xml_en-pcm.xml.gz

#move downloaded data to corresponding language paths
mv $DATA_PATH/jw300.en $EN_PATH/jw300.en
mv $DATA_PATH/jw300.pcm $PCM_PATH/jw300.pcm

echo "done downloading parallel data from opus!"

#download english test data
echo "downloading english test data..."
cd $EN_PATH
curl https://raw.githubusercontent.com/juliakreutzer/masakhane/master/jw300_utils/test/test.en-any.en --output $EN_PATH/test.en-any.en --silent
curl https://raw.githubusercontent.com/juliakreutzer/masakhane/master/jw300_utils/test/test.en-pcm.en --output $EN_PATH/test.en --silent
echo "done downloading english test data!"

#download pidgin test data
echo "downloading pidgin test data..."
cd $PCM_PATH
curl https://raw.githubusercontent.com/juliakreutzer/masakhane/master/jw300_utils/test/test.en-pcm.pcm --output $PCM_PATH/test.pcm --silent
echo "done downloading pidgin data!"

#preprocess the downloaded data
echo "preprocessing downloaded data..."
chmod +x $BASELINE_PATH/preprocess.py
python $BASELINE_PATH/preprocess.py $EN_PATH $PCM_PATH
echo "done processing downloaded data!"

#clone joeynmt for translation
echo "Setting up JoeyNMT"
cd $TOOLS_PATH
git clone https://github.com/joeynmt/joeynmt.git
cd joeynmt
pip install .






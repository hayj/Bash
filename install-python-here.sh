PYTHON_VERSION=3.6.6 # 3.6.6, 3.7.0, 3.5.4
sudo apt-get -y install python3-tk tk
sudo apt-get -y install tk8.6-dev
sudo apt-get -y install libssl-dev
sudo apt-get -y install pew
sudo apt-get -y install zlib1g-dev
sudo apt-get -y install make build-essential libssl-dev zlib1g-dev libbz2-dev libsqlite3-dev
INSTALL_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TMP_DIR=$INSTALL_DIR/tmp
rm -rf $TMP_DIR
rm -rf $INSTALL_DIR/python-$PYTHON_VERSION
mkdir $TMP_DIR
cd $TMP_DIR
wget https://www.python.org/ftp/python/$PYTHON_VERSION/Python-$PYTHON_VERSION.tgz
tar zxfv Python-$PYTHON_VERSION.tgz
find $TMP_DIR -type d | xargs chmod 0755
cd Python-$PYTHON_VERSION
mkdir $INSTALL_DIR/python-$PYTHON_VERSION
./configure --prefix=$INSTALL_DIR/python-$PYTHON_VERSION # --with-libs='bzip'
make && make install
rm -rf $TMP_DIR

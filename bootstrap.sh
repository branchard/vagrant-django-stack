#!/usr/bin/env bash

# TODOLIST:- spelling check
# - Test conf and install
# - Test Python versions compatibility
# - Test Django versions compatibility
# - Correct 'dpkg-preconfigure: unable to re-open stdin: No such file or directory' err msg
# - Correct '[Warning] Using unique option prefix key_buffer instead of key_buffer_size is deprecated and will be removed in a future release. Please use the full name instead.' wrn msg

echo 'bootstrap.sh is run !'
# CONFIGURATION
PROJECT_NAME=$1
MYSQL_PASSWORD=$2
PYTHON_VERSION=$3
DJANGO_VERSION=$4
VIRTUALENV_NAME='venv'
HOME_DIR='/home/vagrant/'
PROJECT_DIR="/vagrant/"
ROOT_DIR="$PROJECT_DIR/$5/"
echo "CONFIGURATION: PROJECT_NAME=$PROJECT_NAME, MYSQL_PASSWORD=$MYSQL_PASSWORD, PYTHON_VERSION=$PYTHON_VERSION, DJANGO_VERSION=$DJANGO_VERSION, VIRTUALENV_NAME=$VIRTUALENV_NAME, HOME_DIR=$HOME_DIR, ROOT_DIR=$ROOT_DIR"

rm -f $HOME_DIR/postinstall.sh # remove useless stuff
echo "$HOME_DIR/postinstall.sh was removed"

echo 'APT deposit will be updated'
apt-get -y update
echo 'Done.'

echo 'Some essential packages will be installed'
apt-get -y install bc git-core build-essential
echo 'Done.'

# MySQL
echo 'MySQL will be installed and configured'
debconf-set-selections <<< "mysql-server-5.5 mysql-server/root_password password $MYSQL_PASSWORD"
debconf-set-selections <<< "mysql-server-5.5 mysql-server/root_password_again password $MYSQL_PASSWORD"
apt-get -y install mysql-server
apt-get -y install mysql-client
echo 'Done.'

# Python env
echo "A Python$PYTHON_VERSION will be initialized with a virtualenv"
apt-get -y install python python$PYTHON_VERSION python-pip

pip install virtualenv
pip install virtualenvwrapper

echo '' >> $HOME_DIR.bashrc
echo '# CUSTOM' >> $HOME_DIR.bashrc
echo "export WORKON_HOME=~/.virtualenvs" >> $HOME_DIR.bashrc
echo 'mkdir -p $WORKON_HOME' >> $HOME_DIR.bashrc
echo "export PROJECT_HOME=$PROJECT_DIR" >> $HOME_DIR.bashrc
echo "source /usr/local/bin/virtualenvwrapper.sh" >> $HOME_DIR.bashrc
echo "workon $VIRTUALENV_NAME" >> $HOME_DIR.bashrc
echo "echo 'virtualenv acivated'" >> $HOME_DIR.bashrc
#echo 'cd $PROJECT_HOME' >> $HOME_DIR.bashrc

export WORKON_HOME=$HOME_DIR/.virtualenvs
mkdir -p $WORKON_HOME
export PROJECT_HOME="$PROJECT_DIR"
source /usr/local/bin/virtualenvwrapper.sh

echo 'done.'

echo 'Virtualenv activation ...'
mkvirtualenv --python=/usr/bin/python$PYTHON_VERSION $VIRTUALENV_NAME
echo 'Virtualenv activating now'
echo 'We are now in the virtualenv !'

echo "Django $DJANGO_VERSION will be installed"
pip install django==$DJANGO_VERSION
echo 'Done.'

# Gunicorn
echo 'Gunicorn will be installed and run'
pip install gunicorn
touch $HOME_DIR/gunicorn_run.sh
sed 's/^M$//' $ROOT_DIR/gunicorn_run.sh > $HOME_DIR/gunicorn_run.sh # convert dos line ending file to unix ending file
chmod a+x $HOME_DIR/gunicorn_run.sh
$HOME_DIR/gunicorn_run.sh&
echo 'Done.'

# Nginx
echo 'Nginx will be installed, configured and run'
apt-get -y install nginx
rm -f /etc/nginx/sites-enabled/default
rm -f /etc/nginx/sites-available/default
cp $ROOT_DIR/nginx_config /etc/nginx/sites-available/
mv /etc/nginx/sites-available/nginx_config /etc/nginx/sites-available/$PROJECT_NAME
sed -i -e "s/example.com/$PROJECT_NAME/g" /etc/nginx/sites-available/$PROJECT_NAME
ln -s /etc/nginx/sites-available/$PROJECT_NAME /etc/nginx/sites-enabled/$PROJECT_NAME
service nginx restart
echo 'Done.'

# Clean
echo 'APT cleanup'
apt-get -y clean
echo 'Done.'

# Tests
echo 'Testing if corectly installed and configured ...'
# TODO
echo 'Done.'

echo 'Boostrap done !'
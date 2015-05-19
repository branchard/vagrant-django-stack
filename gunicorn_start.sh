#!/bin/bash
# Params: APP_NAME

if [ "$#" -ne 1 ];
  then
    echo "Illegal number of parameters"
    echo "Usage:"
    echo "gunicorn_start APP_NAME"
    exit 128
fi

ROOT_DIR="/vagrant/"                              # Path of the root dir
NAME=$1                                           # Name of the application
DJANGODIR=$ROOT_DIR/projects/$NAME                # Django project directory
USER=root                                         # the user to run as
GROUP=root                                        # the group to run as
NUM_WORKERS=$((2 * nproc + 1))                    # how many worker processes should Gunicorn spawn
DJANGO_SETTINGS_MODULE=$NAME.settings             # which settings file should Django use
DJANGO_WSGI_MODULE=$NAME.wsgi                     # WSGI module name

if [ ! -f $DJANGODIR/manage.py ];
  then
  echo "Cannot find project $NAME"
  exit 128
fi

echo "Starting $NAME as `whoami`"

# Activate the virtual environment
export WORKON_HOME=$ROOT_DIR/projects/virtualenvs/
source /usr/local/bin/virtualenvwrapper.sh
workon $NAME
export DJANGO_SETTINGS_MODULE=$DJANGO_SETTINGS_MODULE
export PYTHONPATH=$DJANGODIR:$PYTHONPATH

# Start your Django Unicorn
# Programs meant to be run under supervisor should not daemonize themselves (do not use --daemon)
exec $ROOT_DIR/projects/virtualenvs/$NAME/bin/gunicorn ${DJANGO_WSGI_MODULE}:application \
  --name $NAME \
  --workers $NUM_WORKERS \
  --user=$USER --group=$GROUP \
  --log-level=debug \
  --log-file=-

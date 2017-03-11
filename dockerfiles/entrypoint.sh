#!/bin/bash
set -eo pipefail
shopt -s dotglob

# The last stable version of Sage at now
SAGE_VERSION="8.5.1"

# Github release
SAGE_LINK="https://github.com/roots/sage/archive/$SAGE_VERSION.tar.gz"

# Path to save
SAGE_PATH="sage/sage.tar.gz"

# cURL will fail when destination folder doesn't exist
if [[ ! -d $(dirname $HOME/$SAGE_PATH) ]]; then
	echo "NOTICE: Creating directory $(dirname $HOME/$SAGE_PATH)"
	mkdir -p $(dirname $HOME/$SAGE_PATH)
fi

echo "INFO: Sage is downloading from $SAGE_LINK"

if [[ $(curl -fSL -o $HOME/$SAGE_PATH $SAGE_LINK) ]]; then
	echo "ERROR: Can't start downloading. Abort!!!"
	exit 1
fi

echo "INFO: Sage downloaded with success and saved as $HOME/$SAGE_PATH"

# Extract Sage...
if [[ -n $(tar -xzf $HOME/$SAGE_PATH -C $(dirname $HOME/$SAGE_PATH)) ]]; then
	echo "ERROR: Can't extract $HOME/$SAGE_PATH to $(dirname $HOME/$SAGE_PATH)"
	echo "Abort!!!"
	exit 1
fi

if [[ -n $(mv -f $(dirname $HOME/$SAGE_PATH)/sage-$SAGE_VERSION/* $(dirname $HOME/$SAGE_PATH)) ]]; then
	echo "ERROR: The error was happen when moving files from $(dirname $HOME/$SAGE_PATH)/sage-$SAGE_VERSION) to $(dirname $HOME/$SAGE_PATH)"
	echo "Abort!!!"
	exit 1
fi

echo "INFO: The Sage's files moved from $(dirname $HOME/$SAGE_PATH)/sage-$SAGE_VERSION/ to $(dirname $HOME/$SAGE_PATH) with success"

if [[ -n $(rm -d $(dirname $HOME/$SAGE_PATH)/sage-$SAGE_VERSION) ]]; then
	echo "NOTICE: The directory $(dirname $HOME/$SAGE_PATH)/sage-$SAGE_VERSION isn't empty"
fi

# Move to destination directory with Sage archive
cd $(dirname $HOME/$SAGE_PATH)

if [[ -z "$(which node)" ]]; then
	echo "ERROR: Node isn't install on the server"
	echo "Abort!!!"
	exit 1
fi

echo "INFO: Node version: $(node -v)"

if [[ -z "$(which npm)" ]]; then
	echo "ERROR: NPM isn't install on the server"
	echo "Abort!!!"
	exit 1
fi

echo "INFO: NPM version: $(npm -v)"

# Install node modules
npm install

# if directory node_modules doesn't exist then modules didn't install
# I am not find the best way that it, but I don't know another way
if [[ ! -d "$(dirname $HOME/$SAGE_PATH)/node_modules" ]]; then
	echo "ERROR: The modules of Node didn't install, because folder $(dirname $HOME/$SAGE_PATH)/node_modules is missing"
	echo "Abort!!!"
	exit 1
fi

# Install bower dependencies
if [[ -n "$(which bower)" ]]; then
	# Install Twitter Bootstrap & JQuery by default
	bower install

	if [[ ! -d "$(dirname $HOME/$SAGE_PATH)/bower_components" ]]; then
		echo "WARNING: Bower dependencies wasn't installed, because folder $(dirname $HOME/$SAGE_PATH)/bower_components is missing"
	else
		echo "INFO: Bower dependencies was installed"
	fi
fi

# Create theme files for first time
if [[ -n "$(which gulp)" ]]; then
	# Generate sturnup files using default gulp task by Sage
	gulp

	if [[ ! -d "$(dirname $HOME/$SAGE_PATH)/dist" ]]; then
		echo "WARNING: Gulp could not create the startup files"
	else
		echo "INFO: Gulp successfully created all the startup files"
	fi
fi

# Hurrah!!!
echo "FINISH: Sage was successfully deployed in $(dirname $HOME/$SAGE_PATH)"

# Setup CMD ["gulp", "watch"] in Dockerfiles
eval exec "$@"

#!/bin/bash
#
# Script:  WordPress Plugin Boilerplate Setup Script
# Author:  José Luis Cruz (https://github.com/joseluis)
# Version: 20151019
#
# Description:
#
# The purpose of this script is to automatically go through the necessary steps
# to set up the WordPress-Plugin-Boilerplate for the first time, as shown in:
# https://github.com/DevinVinson/WordPress-Plugin-Boilerplate/wiki/Setting-up-the-boilerplate-in-UNIX
#

NEWNAME_ORIG="${@}"
SCRIPTNAME=`basename "$0"`


# Make some verifications and ask for confirmation
# ##

# Check needed parameters
if [ "${NEWNAME_ORIG}" == '' ]; then
	echo "Error: You need to specify the slug you want to use for your plugin"
	exit
fi

# TODO: Check naming compliance
# https://codex.wordpress.org/File_Header#File_Header_Specification


# Check needed software
command -v curl >/dev/null 2>&1 || {
	# TODO: check for wget
	echo "Error: You need curl installed to be able to download the boilerplate"
	exit
}
command -v iconv >/dev/null 2>&1 || {
	# TODO: check for the absence of special characters
	echo "Error: You need iconv installed"
	exit
}

# Empty folder
if [ "$(ls -a -I . -I .. -I ${SCRIPTNAME} | tr -d '\n')" ]; then
	echo -e  "\nWarning: Current folder is not empty."
	read -p "It is safer to run this script from an empty folder. Continue? (y/n) " yn

	if [ "${yn}" != "y" ]; then
		echo "Aborted"
		exit
	fi
fi


# Prepare the different name variations for different substitutions
# ##

DEFAULTNAME='plugin-name'
DEFAULTNAME_UND=$(echo "$DEFAULTNAME" | tr '-' '_')
DEFAULTNAME_CAMEL_UND=$(echo "$DEFAULTNAME" | sed -r 's/([a-z]+)-([a-z])([a-z]+)/\1\U_\2\L\3/')
DEFAULTNAME_UPPERCAMEL_UND="$(tr '[:lower:]' '[:upper:]' <<< ${DEFAULTNAME_CAMEL_UND:0:1})${DEFAULTNAME_CAMEL_UND:1}"
DEFAULTNAME_UPPERCAMEL_SPA=$(echo "${DEFAULTNAME_UPPERCAMEL_UND}" | tr '_' ' ' )

NEWNAME=$(echo ${NEWNAME_ORIG} | iconv -t ascii//translit | tr '[:upper:]' '[:lower:]' | tr ' ' '-' )
NEWNAME_UND=$(echo "$NEWNAME" | tr '-' '_')
NEWNAME_CAMEL_UND=$(echo "$NEWNAME_UND" | sed -r 's/(_)([a-z])/\1\U\2\L/g')
NEWNAME_UPPERCAMEL_UND="$(tr '[:lower:]' '[:upper:]' <<< ${NEWNAME_CAMEL_UND:0:1})${NEWNAME_CAMEL_UND:1}"


# Last confirmation before the process begins
##

echo -e "\nThe following replacements will be performed on the boilerplate:\n"

echo -e "\tReplace \"${DEFAULTNAME}\" for \"${NEWNAME}\" in filenames and the plugin folder name"
echo -e "\tReplace \"${DEFAULTNAME_UND}\" for \"${NEWNAME_UND}\" in variables and functions" 
echo -e "\tReplace \"${DEFAULTNAME_UPPERCAMEL_UND}\" for \"${NEWNAME_UPPERCAMEL_UND}\" in classes" 
echo -e "\tReplace \"${DEFAULTNAME_UPPERCAMEL_SPA}\" for \"${NEWNAME_ORIG}\" at the 1st line of README.txt" 

echo; read -p "Do you want to proceed? (y/n) " yn
if [ "${yn}" != "y" ]; then
	echo "Aborted"
	exit
fi


# Download the boilerplate
##
DEFAULTDIRNAME="WordPress-Plugin-Boilerplate-master"
echo "Downloading the boilerplate . . ."
wget https://github.com/DevinVinson/WordPress-Plugin-Boilerplate/archive/master.zip -O master.zip
unzip master.zip
mv ${DEFAULTDIRNAME}/${DEFAULTNAME} ${NEWNAME}
rm -rf master.zip ${DEFAULTDIRNAME}
echo "Done!"

cd ${NEWNAME}


# Rename the Files
##
echo "Renaming files . . . "
find . -name "*${DEFAULTNAME}*" | while read FILE ; do
	echo "Renaming \"${FILE}\" . . ."
	newfile=$(echo "${FILE}" | sed -e "s/${DEFAULTNAME}/${NEWNAME}/");
	mv "${FILE}" "${newfile}";
done 
echo "Done !"


# Replace the Strings (functions, methods, etc)
##
echo -n "Renaming variables, functions, classes . . . "
find . -type f -print0 | xargs -0 sed -i "s/${DEFAULTNAME}/${NEWNAME}/g"
find . -type f -print0 | xargs -0 sed -i "s/${DEFAULTNAME_UND}/${NEWNAME_UND}/g"
find . -type f -print0 | xargs -0 sed -i "s/${DEFAULTNAME_UPPERCAMEL_UND}/${NEWNAME_UPPERCAMEL_UND}/g"
sed -i "1s/.*/=== ${NEWNAME_ORIG} ===/" README.txt

echo "Done !"


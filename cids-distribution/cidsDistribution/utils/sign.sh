#!/bin/bash

if [[ -z $1 || -z $2 || -z $3 ]] ; then
    echo -e "\e[31mERROR\e[39m: Usage: $0 {KEYSTORE} {STOREPASS} {JARFILE} {TSA}"
    exit 1
fi

KEYSTORE=$1
STOREPASS=$2
TSA=$3
JARFILE=$4


umask 0000

jarsigner_output=$(jarsigner -strict -verify -keystore $KEYSTORE -storepass $STOREPASS $JARFILE cismet)
if [[ $? -eq 0 && $jarsigner_output != *"jar is unsigned."* && $jarsigner_output != *"no manifest."* ]]; then
    echo -e "\e[32mINFO\e[39m: \e[1m$JARFILE\e[0m is already signed with cismet certificate"
else
    rm -f MANIFEST.TXT 2>> /dev/null
    printf "Permissions: all-permissions\n" > MANIFEST.TXT
    printf "Codebase: *\n" >> MANIFEST.TXT
    printf "\n" >> MANIFEST.TXT

    if [[ $jarsigner_output == *"no manifest."* ]]; then
        echo -e "\e[33mWARNING\e[39m: \e[1m$JARFILE\e[0m does not contain a MANIFEST, updating JAR"
    fi

    if [[ $jarsigner_output == *"jar is unsigned."* ]]; then
        echo -e "\e[33mNOTICE\e[39m: signing unsigned \e[1m$JARFILE\e[0m with cismet certificate"
    else
        echo -e "\e[33mNOTICE\e[39m: signing signed \e[1m$JARFILE\e[0m with cismet certificate"
        zip -q -d $JARFILE META-INF/\*.SF META-INF/\*.RSA META-INF/\*.DSA 2>> /dev/null >> /dev/null
    fi
    
    # update all jars and set permission and codebase attribute
    # ignore warnings about duplicate attributes
    jar -ufm $JARFILE MANIFEST.TXT 2> /dev/null
    
    if [[ -z $TSA ]] ; then
        jarsigner -keystore $KEYSTORE -storepass $STOREPASS $JARFILE cismet
    else
        jarsigner -tsa $TSA -keystore $KEYSTORE -storepass $STOREPASS $JARFILE cismet
    fi

    rm -f MANIFEST.TXT 2>> /dev/null
fi
#!/bin/bash

if [ "$1" = "learn" ] ; then
    java -cp "/skyfire/src/antlr/antlr-4.7-complete.jar:/skyfire/lib/mysql-connector-java-5.1.46-bin.jar:/skyfire/src/:." learning.XMLPCSGLearner
elif  [ "$1" = "generate" ] ; then
    java -cp "/skyfire/src/antlr/antlr-4.7-complete.jar:/skyfire/lib/mysql-connector-java-5.1.46-bin.jar:/skyfire/src/:." generation.XMLGenerator
else
    echo "Command '$1' not known. Chose either 'learn' or 'generate'"
fi
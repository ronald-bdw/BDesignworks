#!/bin/sh

PROJECT_NAME = "BDesignworks"
PATH = "$PWD/$PROJECT_NAME/CoreData"

mogenerator --swift --model "$PATH/$PROJECT_NAME.xcdatamodeld" --machine-dir "$PATH/Private/" --human-dir "$PATH"

sleep 3
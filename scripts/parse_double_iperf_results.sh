#!/bin/bash


cat $1 | grep -A 1 Server  | grep -v Server  | rev | cut -d ' ' -f3  | rev | cut -d '/' -f 1 | grep -v '-' >> $2

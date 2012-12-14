#!/bin/bash
#The intent of this script is to update all of the
#tutorial branches with updates from blankslate.

for i in {1..9}
do
git checkout tutorial$i
git merge blankslate -m 'Updating ME.framework'
done







#!/bin/bash

# Loop over a list
for COLOR in red green blue; do
	echo "Color: $COLOR"
done

# Loop over files in current directory
echo "---"
for FILE in ./*.sh; do
	echo "Script found: $FILE"
done

# While loop with counter
echo "---"
COUNT=1
while [ $COUNT -le 5 ]; do
    echo "Count: $COUNT"
    COUNT=$((COUNT + 1))
done








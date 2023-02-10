#! /bin/bash
ENUM_DIR=$(find .. -type d | grep "png-" | sed "s/..\/png-//g")
for SIZE in $ENUM_DIR 
	do
		echo 'Конвертация: '$SIZE
		./convert-all-files-one-size.sh $SIZE
	done

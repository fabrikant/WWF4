#! /bin/bash
ENUM_DIR=$(find .. -type d | grep "png-" | sed "s/..\/png-//g")
for SIZE in $ENUM_DIR 
	do
		echo 'Конвертация: '$SIZE
		./convert-one-file-one-size.sh $SIZE $1
	done

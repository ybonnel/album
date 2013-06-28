#!/bin/sh

SOURCE_REP=$1

DEST_REP=$2

if [ "x$SOURCE_REP" = "x" -o "x$DEST_REP" = "x" ]
then
	echo "Bad arguments"
	exit 60
fi

cp -R $SOURCE_REP $DEST_REP.new

LONGUEUR_REP=`echo "$DEST_REP.new" | wc -c`

echo "[" > $DEST_REP.new/album.json

FIRST_LINE=1

ls -1 $DEST_REP.new | grep -v json | while read a
do 
	if [ $FIRST_LINE = 1 ]
	then
		FIRST_LINE=0
	else
		echo "," >> $DEST_REP.new/album.json
	fi
	echo "{ \"name\":\"$a\"," >> $DEST_REP.new/album.json

	FIRST_PHOTO=1

	ls -1 "$DEST_REP.new/$a" | grep -v mini | while read photo
	do
		if [ $FIRST_PHOTO = 1 ]
		then
			FIRST_PHOTO=0
			DATE_PRISE=`exif -t 0x9003 "$DEST_REP.new/$a/$photo" | grep Value | cut -d" " -f4 | sed "s/:/\//g"`
			echo "\"date\":\"${DATE_PRISE}\",\"photos\":[" >> $DEST_REP.new/album.json
		else
			echo "," >> $DEST_REP.new/album.json
		fi


		echo "{\"name\":\"$photo\",\"lien\":\"$a/$photo\",\"mini\":\"$a/mini_$photo\"}" >> $DEST_REP.new/album.json
		if [ -f "$DEST_REP/$a/mini_$photo" ]
		then
			cp "$DEST_REP/$a/mini_$photo" "$DEST_REP.new/$a/mini_$photo"
		else
			echo "convert \"$DEST_REP.new/$a/$photo\" -resize 3% \"$DEST_REP.new/$a/mini_$photo\""
			convert "$DEST_REP.new/$a/$photo" -resize 3% "$DEST_REP.new/$a/mini_$photo"
		fi
	done

	find "$DEST_REP.new/$a" -type f  -printf "\"%h/%f\"\n" | grep -v mini | xargs zip -0 "$DEST_REP.new/$a.zip"

	echo "]}" >> $DEST_REP.new/album.json
done

echo "]" >> $DEST_REP.new/album.json

rm -rf $DEST_REP.old
mv $DEST_REP $DEST_REP.old
mv $DEST_REP.new $DEST_REP

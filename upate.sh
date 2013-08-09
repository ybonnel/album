#!/bin/sh

SOURCE_REP=$1

DEST_REP=$2

echo "Debut de mise a jour"
date

if [ "x$SOURCE_REP" = "x" -o "x$DEST_REP" = "x" ]; then
	echo "Bad arguments"
	exit 60
fi

rm -rf $DEST_REP.new > /dev/null 2>&1

cp -R $SOURCE_REP $DEST_REP.new

LONGUEUR_REP=`echo "$DEST_REP.new" | wc -c`

echo "[" > $DEST_REP.new/album.json

FIRST_LINE=1

CURRENT_OS=`uname`

ls -1 $DEST_REP.new | grep -v json | while read a
do 
	if [ $FIRST_LINE = 1 ]; then
		FIRST_LINE=0
	else
		echo "," >> $DEST_REP.new/album.json
	fi
	echo "{ \"name\":\"$a\"," >> $DEST_REP.new/album.json

	FIRST_PHOTO=1

	mkdir "$DEST_REP.new/$a/mini"
	mkdir "$DEST_REP.new/$a/moy"

	ls -1 "$DEST_REP.new/$a" | grep -v mini | grep -v moy | while read photo
	do
		if [ $FIRST_PHOTO = 1 ]; then
			FIRST_PHOTO=0
			if [ "${CURRENT_OS}" = "Darwin" ]; then
				DATE_PRISE=`exiftool -exif:DateTimeOriginal "$DEST_REP.new/$a/$photo" | cut -c 35-44 | sed "s/:/\//g"`
			else
				DATE_PRISE=`exif -t 0x9003 "$DEST_REP.new/$a/$photo" | grep Value | cut -d" " -f4 | sed "s/:/\//g"`
			fi
			echo "\"date\":\"${DATE_PRISE}\",\"photos\":[" >> $DEST_REP.new/album.json
		else
			echo "," >> $DEST_REP.new/album.json
		fi


		if [ "${CURRENT_OS}" = "Darwin" ]; then
			DATE_PRISE=`exiftool -exif:DateTimeOriginal "$DEST_REP.new/$a/$photo" | cut -c 35-44 | sed "s/:/\//g"`
		else
			DATE_PRISE=`exif -t 0x9003 "$DEST_REP.new/$a/$photo" | grep Value | cut -d" " -f4 | sed "s/:/\//g"`
		fi


		echo "{\"name\":\"$photo\",\"date\":\"${DATE_PRISE}\",\"lien\":\"$a/$photo\",\"mini\":\"$a/mini/$photo\",\"moy\":\"$a/moy/$photo\"}" >> $DEST_REP.new/album.json
		if [ "${CURRENT_OS}" = "Darwin" ]; then
			sips --resampleHeight 100 "$DEST_REP.new/$a/$photo" -s formatOptions normal --out "$DEST_REP.new/$a/mini/$photo"
			sips --resampleHeight 500 "$DEST_REP.new/$a/$photo" -s formatOptions normal --out "$DEST_REP.new/$a/moy/$photo"
		fi
	done

	mogrify -define jpeg:size=200x200 -path "$DEST_REP.new/$a/mini" -thumbnail x100 "$DEST_REP.new/$a/$photo/*.JPG"
	mogrify -define jpeg:size=1000x1000 -path "$DEST_REP.new/$a/moy" -thumbnail x500 "$DEST_REP.new/$a/$photo/*.JPG"


	if [ "${CURRENT_OS}" = "Darwin" ]; then
		find "$DEST_REP.new/$a" -type f | grep -v mini | grep -v moy | awk '{print "\""$0"\""}' | xargs zip -0 "$DEST_REP.new/$a.zip"
	else
		find "$DEST_REP.new/$a" -type f  -printf "\"%h/%f\"\n" | grep -v mini | grep -v moy | xargs zip -0 "$DEST_REP.new/$a.zip"
	fi


	echo "]}" >> $DEST_REP.new/album.json
done

echo "]" >> $DEST_REP.new/album.json

rm -rf $DEST_REP.old
mv $DEST_REP $DEST_REP.old
mv $DEST_REP.new $DEST_REP


date
echo "Fin de mise a jour"

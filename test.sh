cd ~/tei/Documentation/

FILES=(tcw20 tcw22 tcw24 tcw27 tcw29 testing_and_building)

#for FILE in "${FILES}"
for FILE in tcw20 tcw22 tcw24 tcw27 tcw29 testing_and_building
do
  if [ ! -f TCW/_po/ja/"$FILE".po ]
  then
    echo Skipped: No "$FILE".po
    continue
  fi

  if [ ! -f TCW/_mo/ja/"$FILE".mo ]
  then
    echo "msgfmt TCW/_po/ja/${FILE}.po -o TCW/_mo/ja/${FILE}.mo"
    echo Created: "$FILE".mo

    echo "itstool -m TCW/_mo/ja/${FILE}.mo TCW/${FILE}.xml -o TCW/ja/${FILE}.xml"
    echo Created: ja/"$FILE".xml
  elif [ TCW/_po/ja/"$FILE".po -nt TCW/_mo/ja/"$FILE".mo ]
  then
    echo "msgfmt TCW/_po/ja/${FILE}.po -o TCW/_mo/ja/${FILE}.mo"
    echo Updated: "$FILE".mo

    echo "itstool -m TCW/_mo/ja/${FILE}.mo TCW/${FILE}.xml -o TCW/ja/${FILE}.xml"
    echo Updated: ja/"$FILE".xml
  fi
done


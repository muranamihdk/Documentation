cd ~/tei/Documentation/

echo "git checkout localize_ja"
git checkout localize_ja
echo

if [ $(curl \
 -s \
 -H "Authorization: Token 4uQDi24YSNEYgpxkkTvwdk7z9gZYupXiUvcxyccT" \
 http://www3420ue.sakura.ne.jp:8080/api/projects/tcw/repository/ \
| jq -r '.needs_commit') = false ]
then
  echo "No changes to commit"
  #exit 0
fi

if [ $(curl \
 -s \
 -d operation=commit \
 -H "Authorization: Token 4uQDi24YSNEYgpxkkTvwdk7z9gZYupXiUvcxyccT" \
 http://www3420ue.sakura.ne.jp:8080/api/components/tcw/tcw20/repository/ \
| jq -r '.result') = false ]
then
  echo "Commit Failure."
  exit 1
else
  echo "Commit Success."
fi

echo

echo "git pull origin localize_ja"
git pull origin localize_ja
echo

for FILE in tcw20 tcw22 tcw24 tcw27 tcw29 testing_and_building
do
  if [ ! -f TCW/_po/ja/"$FILE".po ]
  then
    echo Skipped: No "$FILE".po
    continue
  fi

  if [ ! -f TCW/_mo/ja/"$FILE".mo ]
  then
    #echo "msgfmt TCW/_po/ja/${FILE}.po -o TCW/_mo/ja/${FILE}.mo"
    msgfmt TCW/_po/ja/"${FILE}".po -o TCW/_mo/ja/"${FILE}".mo
    echo Created: "$FILE".mo

    #echo "itstool -m TCW/_mo/ja/${FILE}.mo TCW/${FILE}.xml -o TCW/ja/${FILE}.xml"
    itstool -m TCW/_mo/ja/"${FILE}".mo TCW/"${FILE}".xml -o TCW/ja/"${FILE}".xml
    echo Created: ja/"$FILE".xml
  elif [ TCW/_po/ja/"$FILE".po -nt TCW/_mo/ja/"$FILE".mo ]
  then
    #echo "msgfmt TCW/_po/ja/${FILE}.po -o TCW/_mo/ja/${FILE}.mo"
    msgfmt TCW/_po/ja/"${FILE}".po -o TCW/_mo/ja/"${FILE}".mo
    echo Updated: "$FILE".mo

    #echo "itstool -m TCW/_mo/ja/${FILE}.mo TCW/${FILE}.xml -o TCW/ja/${FILE}.xml"
    itstool -m TCW/_mo/ja/"${FILE}".mo TCW/"${FILE}".xml -o TCW/ja/"${FILE}".xml
    echo Updated: ja/"$FILE".xml
  fi
done

echo
git add .
git commit -m "update translations"
echo
echo "git push origin localize_ja"
git push origin localize_ja


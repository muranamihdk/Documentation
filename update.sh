cd `dirname $0`

echo "git checkout localize_ja"
git checkout localize_ja
echo

if [ $(curl \
 -s \
 -H "Authorization: Token 4uQDi24YSNEYgpxkkTvwdk7z9gZYupXiUvcxyccT" \
 http://www3420ue.sakura.ne.jp:8080/api/projects/tcw/repository/ \
| jq -r '.needs_commit') = true ]
then
  echo "Changes to commit exists at Weblate. Commit before local update."
  exit 1
fi

echo "git fetch teic"
git fetch teic
echo
echo "git diff origin/master teic/master --name-only"
git diff origin/master teic/master --name-only
echo
if [ $(git diff origin/master teic/master --name-only | wc -l) -eq 0 ]
then
  echo "No changes to merge."
  #exit 0
else
  # Sync with upstream
  git checkout master
  #git merge teic/master -m "Merge branch 'master' of https://github.com/TEIC/Documentation into master"
  echo "git pull teic master:master"
  git pull teic master:master
  echo
  echo "git push origin master:master"
  git push origin master:master
  git checkout -
  
  echo
  echo "git merge master"
  git merge master -m "Merge branch 'master' into localize_ja"
  echo
  echo "git push origin localize_ja"

  git push origin localize_ja
  # pull at Weblate
  if [ $(curl \
   -s \
   -d operation=pull \
   -H "Authorization: Token 4uQDi24YSNEYgpxkkTvwdk7z9gZYupXiUvcxyccT" \
   http://www3420ue.sakura.ne.jp:8080/api/components/tcw/tcw20/repository/ \
  | jq -r '.result') = false ]
  then
    echo "Pull at Weblate Failure."
    exit 1
  else
    echo "Pull at Weblate Success."
    echo
  fi
  echo
fi


for FILE in tcw20 tcw22 tcw24 tcw27 tcw29 testing_and_building
do
  if [ ! -f TCW/_pot/"$FILE".pot ]
  then
    itstool -o TCW/_pot/"$FILE".pot TCW/"$FILE".xml
    echo Created: "$FILE".pot
  fi

  if [ ! -f TCW/_po/ja/"$FILE".po ]
  then
    cp TCW/_pot/"$FILE".pot TCW/_po/ja/"$FILE".po
    echo Created: "$FILE".po
  fi

  if [ TCW/"$FILE".xml -nt TCW/_po/ja/"$FILE".po ]
  then
    itstool -o TCW/_pot/"$FILE".pot TCW/"$FILE".xml
    msgmerge -U TCW/_po/ja/"$FILE".po TCW/_pot/"$FILE".pot
    echo Updated: "$FILE".po
  fi
done

echo "git diff origin/localize_ja --name-only"
git diff origin/localize_ja --name-only
if [ $(git diff origin/localize_ja --name-only | wc -l) -ne 0 ]
then
  echo
  git add .
  git commit -m "update po files"
  echo
  echo "git push origin localize_ja"
  git push origin localize_ja

  # pull at Weblate
  if [ $(curl \
   -s \
   -d operation=pull \
   -H "Authorization: Token 4uQDi24YSNEYgpxkkTvwdk7z9gZYupXiUvcxyccT" \
   http://www3420ue.sakura.ne.jp:8080/api/components/tcw/tcw20/repository/ \
  | jq -r '.result') = false ]
  then
    echo "Pull at Weblate Failure."
    exit 1
  else
    echo "Pull at Weblate Success."
    echo
  fi
fi


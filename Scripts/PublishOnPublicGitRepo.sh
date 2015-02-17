PUBLIC_REPO="https://github.com/payleven/InApp-SDK-iOS.git"
PUBLIC_REPO_DIR="temp_private"

# Delete any existing temporary folders
rm -rf $PUBLIC_REPO_DIR

#Clone public repo
git clone $PUBLIC_REPO $PUBLIC_REPO_DIR || exit 1

#Move to the public dir repo
cd $PUBLIC_REPO_DIR

#Remove everything
rm -rf *

#Copy distribution sample files
cd ..
cp -R "PaylevenInAppSDKExample" $PUBLIC_REPO_DIR

#Commit public distribution files
cd $PUBLIC_REPO_DIR
if [ -n "$(git status --porcelain)" ]; then
    git add .
    git add -u
    git commit -m "Sample updated on $(date +%m-%d-%y)"
	git push origin --all
else
  echo "There is nothing to commit. Skip commiting sample sources";
fi


#Delete temp folders
#cd .. rm -rf $PUBLIC_REPO_DIR

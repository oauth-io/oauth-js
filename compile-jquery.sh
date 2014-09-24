#! /bin/sh
# In the jquery sources folder, you have to:
#
# git clone git@github.com:jquery/jquery.git
# git checkout 2.1.1
# npm install
#
# Make sure to have grunt-cli installed with
# npm install -g grunt-cli

OAUTHJS_PATH=`pwd`
JQUERY_PATH="../jquery"

cd $JQUERY_PATH
grunt custom:-attributes,-attributes/attr,-attributes/classes,-attributes/prop,-attributes/support,-attributes/val,-attributes,-css/addGetHookIf,-css/curCSS,-css/defaultDisplay,-css/hiddenVisibleSelectors,-css/support,-css/swap,-css/var,-css/var/cssExpand,-css/var/getStyles,-css/var/isHidden,-css/var/rmargin,-css/var/rnumnonpx,-css,-data/var/data_user,-deprecated,-dimensions,-effects,-effects/animatedSelector,-effects/Tween,-event/alias,-event/support,-intro,-manipulation/_evalUrl,-manipulation/support,-manipulation/var,-manipulation/var/rcheckableType,-manipulation,-offset,-outro,-queue,-queue/delay,-selector-native,-selector-sizzle,-sizzle,-sizzle/dist,-sizzle/dist/sizzle,-sizzle/test,-traversing,-traversing/findFilter,-traversing/var,-traversing/var/rneedsContext,-wrap,-exports,-exports/global,-exports/amd
cat ./dist/jquery.js | head -n $((`cat ./dist/jquery.js | wc -l`-2)) > ./dist/jquery-lite.js
LASTLINES=`cat ./dist/jquery.js | tail -n 1`
echo 'return jQuery;' >> ./dist/jquery-lite.js
echo $LASTLINES >> ./dist/jquery-lite.js

cd $OAUTHJS_PATH
cp $JQUERY_PATH/dist/jquery-lite.js ./js/tools/jquery-lite.js && echo "copied jquery to oauth-js"
grunt && echo "compiled oauth-js"

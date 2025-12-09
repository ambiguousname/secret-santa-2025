cp {BuddyServer.dll,LICENSES.md} Mac/
cp {BuddyServer.dll,LICENSES.md} Windows/

cd Windows
zip -r HollowBuddyWindows.zip *

cd ../Mac
zip -r HollowBuddyMac.zip *
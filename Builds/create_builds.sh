cp {BuddyServer.dll,LICENSES.md,README.md} Mac/
cp {BuddyServer.dll,LICENSES.md,README.md} Windows/

cd Windows
zip -r HollowBuddyWindows.zip *

cd ../Mac
zip -r HollowBuddyMac.zip *
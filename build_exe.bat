"c:\Program Files\7-Zip\7z.exe" a -xr@exclude.list temp.zip *
move temp.zip ../Build/temp.love
cd ../Build
del pac.exe
copy/b love.exe+temp.love trump.exe
del temp.love
move trump.exe ../"Trumpcade"
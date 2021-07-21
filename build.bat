@echo off

echo /============ PREPARE =============
echo /

if exist .\amxmodx\plugins rd /S /q .\amxmodx\plugins
mkdir .\amxmodx\plugins
cd .\amxmodx\plugins

echo /
echo /
echo /============ COMPILE =============
echo /

for /R ..\scripting\ %%F in (*.sma) do (
    echo / /
    echo / / Compile %%~nF:
    echo / /
    amxx190 %%F
)

echo /
echo /
echo /============ BUILD =============
echo /

cd ..\..
mkdir .\.build\VipM-VipTest\amxmodx\scripting\

xcopy .\amxmodx\ .\.build\VipM-VipTest\amxmodx\ /s /e /y
copy .\README.md .\.build\

if exist .\VipM-VipTest.zip del .\VipM-VipTest.zip
cd .\.build
zip -r .\..\VipM-VipTest.zip .
cd ..
rmdir .\.build /s /q

echo /
echo /
echo /============ END =============
echo /

set /p q=
@echo off
pushd "C:\Program Files (x86)\gpsbabel
set arg=%1
:doshift
if "%2"=="" goto endsub
set arg=%arg% %2%
shift  
goto doshift
:endsub
Set arg=%arg:"=%
echo arg=%arg%
gpsbabel.exe %arg%
set arg=
:end
popd
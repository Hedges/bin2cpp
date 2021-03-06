@echo off
REM build test.cpp with files generated by bin2cpp

set BIN2CPP=%~dp0..\build-msvc\bin\bin2cpp.exe
if not exist %BIN2CPP% exit /b 1

:configure_v140
echo Configuring VC++ 2015...
if not exist "%VS140COMNTOOLS%..\..\VC\vcvarsall.bat" exit /b 1
call "%VS140COMNTOOLS%..\..\VC\vcvarsall.bat" x86_amd64 || exit /b 1

:generate_cpp
mkdir input || goto:test_failed
mkdir output || goto:test_failed

REM see test.cpp for details of what is expected
copy golden_master.bin input\  || goto:test_failed
%BIN2CPP% -ns myNamespace -o generated -d output input || goto:test_failed
if not exist output\generated.h goto:test_failed
if not exist output\generated.cpp goto:test_failed

:build_src
echo.
echo Building test.cpp...
set BUILDDIR=%~dp0build-dir
mkdir %BUILDDIR% || exit /b 1
pushd %BUILDDIR%
cl /nologo /DEBUG /EHsc /W4 %~dp0\test.cpp %~dp0\output\generated.cpp -I%~dp0\output || exit /b 1
cl /nologo /DEBUG /EHsc /W4 %~dp0\example.cpp %~dp0\output\generated.cpp -I%~dp0\output || exit /b 1
popd

:run_test
if not exist %BUILDDIR%\test.exe exit /b 1
echo.
%BUILDDIR%\test.exe || exit /b 1

:clean
del /q %BUILDDIR%\*
rd /q %BUILDDIR%
del /q input\*
rd /q input
del /q output\*
rd /q output

echo Success!
exit /b 0

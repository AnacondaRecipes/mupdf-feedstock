@echo on

set PKG_CONFIG_PATH="%LIBRARY_LIB%\pkgconfig"
set PYTHONPATH="%PREFIX%\Lib\site-packages"
set BUILD_DIR=build-release-x64

copy %RECIPE_DIR%\CMakeLists.txt .
if errorlevel 1 exit 1

make generate
if errorlevel 1 exit 1

@REM Configure using the CMakeFiles
cmake -B %BUILD_DIR% -G Ninja -S %SRC_DIR% ^
      -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
      -DCMAKE_PREFIX_PATH:PATH="%LIBRARY_PREFIX%" ^
      -DCMAKE_BUILD_TYPE:STRING=Release
if errorlevel 1 exit 1

@REM Build!
cmake --build %BUILD_DIR% --config Release
if errorlevel 1 exit 1

@REM Produce C++ bindings, as it is done via python script rather then build system
%CONDA_PYTHON_EXE% scripts\mupdfwrap.py -d %BUILD_DIR% -b all -o windows
if errorlevel 1 exit 1

@REM Install!
cmake --install %BUILD_DIR% --config Release
if errorlevel 1 exit 1


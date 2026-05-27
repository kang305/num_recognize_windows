@echo off
REM ============================================
REM  Windows Build Script
REM  Usage: build_windows.bat [libtorch_path] [qt_path]
REM  Example: build_windows.bat "C:\libtorch" "C:\Qt\6.5.0\msvc2019_64"
REM ============================================

setlocal enabledelayedexpansion

REM --- Detect LibTorch path ---
if not "%~1"=="" (
    set LIBTORCH_PATH=%~1
) else if exist "C:\libtorch" (
    set LIBTORCH_PATH=C:\libtorch
) else if exist "D:\libtorch" (
    set LIBTORCH_PATH=D:\libtorch
) else (
    echo [ERROR] LibTorch not found. Please specify path:
    echo   build_windows.bat "C:\libtorch" "C:\Qt\6.5.0\msvc2019_64"
    echo.
    echo Download LibTorch from: https://pytorch.org/
    echo Choose: Release, Windows, LibTorch, C++/Java, CPU-only
    echo Extract to C:\libtorch
    exit /b 1
)

REM --- Detect Qt path ---
if not "%~2"=="" (
    set QT_PATH=%~2
) else if exist "C:\Qt" (
    for /f "delims=" %%d in ('dir /b /ad /o-n "C:\Qt" 2^>nul') do (
        for /f "delims=" %%t in ('dir /b /ad /o-n "C:\Qt\%%d" 2^>nul') do (
            if exist "C:\Qt\%%d\%%t\msvc2019_64" (
                set QT_PATH=C:\Qt\%%d\%%t\msvc2019_64
                goto :qt_found
            )
        )
    )
    :qt_found
)

if "%QT_PATH%"=="" (
    echo [WARNING] Qt not auto-detected. Add Qt bin to your PATH, or specify:
    echo   build_windows.bat "C:\libtorch" "C:\Qt\6.5.0\msvc2019_64"
)

REM --- Build ---
echo ============================================
echo  LibTorch: %LIBTORCH_PATH%
echo  Qt:       %QT_PATH%
echo ============================================

if exist build rmdir /s /q build
mkdir build
cd build

set CMAKE_ARGS=-DCMAKE_PREFIX_PATH="%LIBTORCH_PATH%"
if not "%QT_PATH%"=="" (
    set CMAKE_ARGS=%CMAKE_ARGS% -DCMAKE_PREFIX_PATH="%LIBTORCH_PATH%;%QT_PATH%"
)

cmake .. %CMAKE_ARGS%
if %errorlevel% neq 0 exit /b %errorlevel%

cmake --build . --config Release
if %errorlevel% neq 0 exit /b %errorlevel%

REM --- Copy model file to output ---
copy /Y "..\mnist_cnn.pt" "Release\mnist_cnn.pt" >nul 2>&1

echo.
echo ============================================
echo  Build successful!
echo  Run: build\Release\num_recognize.exe
echo ============================================

cd ..
endlocal

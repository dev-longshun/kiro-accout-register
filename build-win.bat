@echo off
echo Cleaning...
if exist dist rmdir /s /q dist
if exist out rmdir /s /q out

echo Building...
call npm run build
if errorlevel 1 (
    echo Build failed!
    pause
    exit /b 1
)

echo Packaging...
call npx electron-builder --win --x64
if errorlevel 1 (
    echo Packaging failed!
    pause
    exit /b 1
)

echo Done!
pause

@echo off
setlocal EnableExtensions EnableDelayedExpansion

set "EXIT_CODE=0"

cd /d "%~dp0"
if errorlevel 1 (
  echo 错误: 无法进入脚本所在目录。
  set "EXIT_CODE=1"
  goto :pause_and_exit
)

echo === Kiro Auto Register 启动器 (Windows) ===
echo 项目目录: %CD%
echo.

where node >nul 2>nul
if errorlevel 1 (
  echo 错误: 未检测到 node，请先安装 Node.js 22+
  set "EXIT_CODE=1"
  goto :pause_and_exit
)

where npm >nul 2>nul
if errorlevel 1 (
  echo 错误: 未检测到 npm，请先安装 npm 10+
  set "EXIT_CODE=1"
  goto :pause_and_exit
)

for /f "delims=" %%i in ('node -v 2^>nul') do set "NODE_VERSION=%%i"
for /f "delims=" %%i in ('npm -v 2^>nul') do set "NPM_VERSION=%%i"
echo Node 版本: !NODE_VERSION!
echo npm 版本:  !NPM_VERSION!
echo.

rem 默认使用国内镜像，可通过 USE_CN_MIRROR=0 关闭
if not "%USE_CN_MIRROR%"=="0" (
  if "%NPM_REGISTRY_URL%"=="" set "NPM_REGISTRY_URL=https://registry.npmmirror.com"
  if "%ELECTRON_MIRROR_URL%"=="" set "ELECTRON_MIRROR_URL=https://npmmirror.com/mirrors/electron/"
  if "%PLAYWRIGHT_MIRROR_URL%"=="" set "PLAYWRIGHT_MIRROR_URL=https://npmmirror.com/mirrors/playwright/"

  set "npm_config_registry=!NPM_REGISTRY_URL!"
  set "ELECTRON_MIRROR=!ELECTRON_MIRROR_URL!"
  set "PLAYWRIGHT_DOWNLOAD_HOST=!PLAYWRIGHT_MIRROR_URL!"

  echo 已启用国内镜像:
  echo   npm registry:         !npm_config_registry!
  echo   electron mirror:      !ELECTRON_MIRROR!
  echo   playwright download:  !PLAYWRIGHT_DOWNLOAD_HOST!
  echo.
)

if not exist "node_modules" (
  echo 未检测到 node_modules，正在安装项目依赖...
  call npm install
  if errorlevel 1 (
    echo 标准安装失败，正在尝试兼容模式: npm install --legacy-peer-deps
    call npm install --legacy-peer-deps
    if errorlevel 1 (
      echo 依赖安装失败，请检查网络或 npm 配置后重试。
      set "EXIT_CODE=1"
      goto :pause_and_exit
    )
  )
  echo 依赖安装完成。
) else (
  echo 已检测到 node_modules，跳过依赖安装。
)

echo.
echo 检查 Playwright Chromium...
node -e "const fs=require('fs');try{const {chromium}=require('playwright');process.exit(fs.existsSync(chromium.executablePath())?0:1)}catch(e){process.exit(1)}" >nul 2>nul
if errorlevel 1 (
  echo 未检测到 Chromium，正在安装...
  call npm run install-browser
  if errorlevel 1 (
    echo Chromium 安装失败，请检查网络后重试。
    set "EXIT_CODE=1"
    goto :pause_and_exit
  )
  echo Chromium 安装完成。
) else (
  echo 已检测到 Chromium，跳过安装。
)

echo.
echo 正在启动服务...
echo 命令: npm run dev
echo 按 Ctrl+C 停止服务
echo ----------------------------------------
call npm run dev
set "EXIT_CODE=%ERRORLEVEL%"

if not "%EXIT_CODE%"=="0" (
  echo.
  echo 服务异常退出，退出码: %EXIT_CODE%
) else (
  echo.
  echo 服务已停止。
)

goto :pause_and_exit

:pause_and_exit
echo.
if "%NO_PAUSE%"=="1" exit /b %EXIT_CODE%
echo 脚本结束，退出码: %EXIT_CODE%
pause
exit /b %EXIT_CODE%

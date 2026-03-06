#!/bin/bash

pause_and_exit() {
  local code="${1:-0}"
  echo ""
  if [ "${NO_PAUSE:-0}" = "1" ]; then
    exit "$code"
  fi
  echo "脚本结束，退出码: $code"
  read -r -p "按回车关闭窗口..." _
  exit "$code"
}

if ! cd "$(dirname "$0")"; then
  echo "错误: 无法进入脚本所在目录。"
  pause_and_exit 1
fi

echo "=== Kiro Auto Register 启动器 ==="
echo "项目目录: $(pwd)"
echo ""

if ! command -v node >/dev/null 2>&1; then
  echo "错误: 未检测到 node，请先安装 Node.js 22+"
  pause_and_exit 1
fi

if ! command -v npm >/dev/null 2>&1; then
  echo "错误: 未检测到 npm，请先安装 npm 10+"
  pause_and_exit 1
fi

echo "Node 版本: $(node -v)"
echo "npm 版本:  $(npm -v)"
echo ""

# 默认使用国内镜像，可通过 USE_CN_MIRROR=0 关闭
if [ "${USE_CN_MIRROR:-1}" = "1" ]; then
  NPM_REGISTRY_URL="${NPM_REGISTRY_URL:-https://registry.npmmirror.com}"
  ELECTRON_MIRROR_URL="${ELECTRON_MIRROR_URL:-https://npmmirror.com/mirrors/electron/}"
  PLAYWRIGHT_MIRROR_URL="${PLAYWRIGHT_MIRROR_URL:-https://npmmirror.com/mirrors/playwright/}"

  export npm_config_registry="$NPM_REGISTRY_URL"
  export ELECTRON_MIRROR="$ELECTRON_MIRROR_URL"
  export PLAYWRIGHT_DOWNLOAD_HOST="$PLAYWRIGHT_MIRROR_URL"

  echo "已启用国内镜像:"
  echo "  npm registry:         $npm_config_registry"
  echo "  electron mirror:      $ELECTRON_MIRROR"
  echo "  playwright download:  $PLAYWRIGHT_DOWNLOAD_HOST"
  echo ""
fi

if [ ! -d "node_modules" ]; then
  echo "未检测到 node_modules，正在安装项目依赖..."
  npm install
  if [ $? -ne 0 ]; then
    echo "标准安装失败，正在尝试兼容模式: npm install --legacy-peer-deps"
    npm install --legacy-peer-deps
    if [ $? -ne 0 ]; then
      echo "依赖安装失败，请检查网络或 npm 配置后重试。"
      pause_and_exit 1
    fi
  fi
  echo "依赖安装完成。"
else
  echo "已检测到 node_modules，跳过依赖安装。"
fi

echo ""
echo "检查 Playwright Chromium..."
if node -e "const fs=require('fs'); try{const {chromium}=require('playwright'); process.exit(fs.existsSync(chromium.executablePath())?0:1)}catch(e){process.exit(1)}"; then
  echo "已检测到 Chromium，跳过安装。"
else
  echo "未检测到 Chromium，正在安装..."
  npm run install-browser
  if [ $? -ne 0 ]; then
    echo "Chromium 安装失败，请检查网络后重试。"
    pause_and_exit 1
  fi
  echo "Chromium 安装完成。"
fi

echo ""
echo "正在启动服务..."
echo "命令: npm run dev"
echo "按 Ctrl+C 停止服务"
echo "----------------------------------------"

npm run dev
exit_code=$?

if [ "$exit_code" -ne 0 ]; then
  echo ""
  echo "服务异常退出，退出码: $exit_code"
else
  echo ""
  echo "服务已停止。"
fi

pause_and_exit "$exit_code"

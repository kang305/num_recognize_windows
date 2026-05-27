# ============================================================
#  手写数字识别系统 - Windows 一键环境配置脚本
#  使用方法: 右键 → "使用 PowerShell 运行"，或在终端中:
#    powershell -ExecutionPolicy Bypass -File setup_windows.ps1
# ============================================================

$ErrorActionPreference = "Stop"
$LIBTORCH_URL = "https://download.pytorch.org/libtorch/cpu/libtorch-win-shared-with-deps-2.5.1%2Bcpu.zip"
$QT_VERSION = "6.5.0"
$LIBTORCH_DIR = "C:\libtorch"

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  手写数字识别系统 - 环境自动配置" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "本脚本将安装以下组件:" -ForegroundColor Yellow
Write-Host "  1. Visual Studio 2022 Build Tools (MSVC 编译器)"
Write-Host "  2. CMake (构建工具)"
Write-Host "  3. Qt $QT_VERSION (GUI 框架)"
Write-Host "  4. LibTorch (深度学习推理库)"
Write-Host "  5. Git (版本管理，可选)"
Write-Host ""
Write-Host "预计耗时: 15-40 分钟（取决于网速）" -ForegroundColor Yellow
Write-Host ""

$answer = Read-Host "是否继续? (y/n)"
if ($answer -ne "y" -and $answer -ne "Y") {
    Write-Host "已取消" -ForegroundColor Red
    exit
}

# ----------------------------------------------------------
# Step 1: Visual Studio 2022 Build Tools
# ----------------------------------------------------------
Write-Host ""
Write-Host "[1/5] 安装 Visual Studio 2022 Build Tools..." -ForegroundColor Green
$vsInstalled = winget list --id Microsoft.VisualStudio.2022.BuildTools --exact 2>$null
if ($vsInstalled -match "BuildTools") {
    Write-Host "  已安装，跳过" -ForegroundColor Gray
} else {
    winget install Microsoft.VisualStudio.2022.BuildTools `
        --override "--wait --passive --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended" `
        --accept-source-agreements --accept-package-agreements
    Write-Host "  Visual Studio Build Tools 安装完成！" -ForegroundColor Green
    Write-Host "  请重启电脑后再继续运行本脚本。" -ForegroundColor Yellow
    $answer = Read-Host "  是否现在重启? (y/n)"
    if ($answer -eq "y" -or $answer -eq "Y") {
        Restart-Computer
    } else {
        Write-Host "  请手动重启后重新运行本脚本。" -ForegroundColor Yellow
        exit
    }
}

# ----------------------------------------------------------
# Step 2: CMake
# ----------------------------------------------------------
Write-Host ""
Write-Host "[2/5] 安装 CMake..." -ForegroundColor Green
$cmakeInstalled = winget list --id Kitware.CMake --exact 2>$null
if ($cmakeInstalled -match "CMake") {
    Write-Host "  已安装，跳过" -ForegroundColor Gray
} else {
    winget install Kitware.CMake --accept-source-agreements --accept-package-agreements
    Write-Host "  CMake 安装完成！" -ForegroundColor Green
}

# Refresh PATH
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# ----------------------------------------------------------
# Step 3: Qt 6 via aqtinstall
# ----------------------------------------------------------
Write-Host ""
Write-Host "[3/5] 安装 Qt $QT_VERSION..." -ForegroundColor Green

$qtDir = "C:\Qt\$QT_VERSION\msvc2019_64"
if (Test-Path $qtDir) {
    Write-Host "  已安装 ($qtDir)，跳过" -ForegroundColor Gray
} else {
    # Install aqtinstall via pip
    Write-Host "  安装 aqtinstall (命令行 Qt 安装工具)..." -ForegroundColor Gray
    pip install aqtinstall 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  需要先安装 Python。正在通过 winget 安装..." -ForegroundColor Yellow
        winget install Python.Python.3.12 --accept-source-agreements --accept-package-agreements
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
        pip install aqtinstall
    }

    Write-Host "  下载 Qt $QT_VERSION (MSVC 2019 64-bit)，约 2GB..." -ForegroundColor Gray
    aqt install-qt windows desktop $QT_VERSION win64_msvc2019_64 --outputdir C:\Qt

    if (Test-Path $qtDir) {
        Write-Host "  Qt 安装完成！" -ForegroundColor Green
    } else {
        Write-Host "  Qt 安装失败，请手动安装。下载地址: https://www.qt.io/download-open-source" -ForegroundColor Red
    }
}

# ----------------------------------------------------------
# Step 4: LibTorch
# ----------------------------------------------------------
Write-Host ""
Write-Host "[4/5] 下载 LibTorch..." -ForegroundColor Green

if (Test-Path "$LIBTORCH_DIR\include\torch\torch.h") {
    Write-Host "  已安装，跳过" -ForegroundColor Gray
} else {
    $zipPath = "$env:TEMP\libtorch.zip"
    Write-Host "  下载中 (约 2GB)..." -ForegroundColor Gray
    Invoke-WebRequest -Uri $LIBTORCH_URL -OutFile $zipPath
    Write-Host "  解压到 $LIBTORCH_DIR ..." -ForegroundColor Gray
    Expand-Archive -Path $zipPath -DestinationPath "C:\" -Force
    Remove-Item $zipPath
    Write-Host "  LibTorch 安装完成！" -ForegroundColor Green
}

# ----------------------------------------------------------
# Step 5: Git (optional)
# ----------------------------------------------------------
Write-Host ""
Write-Host "[5/5] 安装 Git (可选)..." -ForegroundColor Green
$gitInstalled = winget list --id Git.Git --exact 2>$null
if ($gitInstalled -match "Git") {
    Write-Host "  已安装，跳过" -ForegroundColor Gray
} else {
    winget install Git.Git --accept-source-agreements --accept-package-agreements
    Write-Host "  Git 安装完成！" -ForegroundColor Green
}

# ----------------------------------------------------------
# Done
# ----------------------------------------------------------
Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  环境配置完成！" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "已安装的组件:"
Write-Host "  MSVC 编译器 : Visual Studio 2022 Build Tools"
Write-Host "  CMake        : $(cmake --version | Select-Object -First 1)"
Write-Host "  Qt           : $qtDir"
Write-Host "  LibTorch     : $LIBTORCH_DIR"
Write-Host ""

Write-Host "接下来请执行以下命令编译项目:" -ForegroundColor Yellow
Write-Host ""
Write-Host "  cd <项目目录>" -ForegroundColor White
Write-Host "  mkdir build; cd build" -ForegroundColor White
Write-Host "  cmake .. -DCMAKE_PREFIX_PATH=`"$LIBTORCH_DIR;$qtDir`"" -ForegroundColor White
Write-Host "  cmake --build . --config Release" -ForegroundColor White
Write-Host "  copy ..\mnist_cnn.pt Release\" -ForegroundColor White
Write-Host "  .\Release\num_recognize.exe" -ForegroundColor White
Write-Host ""
Write-Host "或者直接用 build_windows.bat 一键编译:" -ForegroundColor Yellow
Write-Host "  .\build_windows.bat `"$LIBTORCH_DIR`" `"$qtDir`"" -ForegroundColor White

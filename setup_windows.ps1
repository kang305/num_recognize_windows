# ============================================================
#  手写数字识别系统 - Windows 一键环境配置脚本
#  适用于: 完全空白的新 Windows 10/11 电脑
#
#  使用方法:
#    方法1: 右键 setup_windows.ps1 → "使用 PowerShell 运行"
#    方法2: 在终端中执行:
#      powershell -ExecutionPolicy Bypass -File setup_windows.ps1
#
#  如果中途提示重启，重启后再次运行本脚本即可（已装的会自动跳过）。
# ============================================================

$ErrorActionPreference = "Continue"
$LIBTORCH_URL = "https://download.pytorch.org/libtorch/cpu/libtorch-win-shared-with-deps-2.5.1%2Bcpu.zip"
$QT_VERSION = "6.5.0"
$LIBTORCH_DIR = "C:\libtorch"
$QT_DIR = "C:\Qt\$QT_VERSION\msvc2019_64"

# Refresh PATH helper
function Refresh-Path {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}

# Check if a winget package is installed
function Test-WingetInstalled($packageId) {
    $result = winget list --id $packageId --exact 2>$null
    return ($result -match $packageId)
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  手写数字识别系统 - 环境自动配置" -ForegroundColor Cyan
Write-Host "  (适用于完全空白的新电脑)" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "本脚本将从零开始安装:" -ForegroundColor Yellow
Write-Host "  1. Python 3.12        (脚本运行 & 模型训练)"
Write-Host "  2. Git                 (代码管理，可选)"
Write-Host "  3. Visual Studio 2022 Build Tools (MSVC 编译器)"
Write-Host "  4. CMake               (C++ 构建工具)"
Write-Host "  5. Qt $QT_VERSION           (GUI 框架)"
Write-Host "  6. LibTorch 2.5.1      (深度学习推理库)"
Write-Host ""
Write-Host "预计耗时: 15-40 分钟（取决于网速）" -ForegroundColor Yellow
Write-Host "如果中途需要重启，重启后重新运行本脚本即可。" -ForegroundColor Yellow
Write-Host "已安装的组件会自动跳过，不会重复安装。" -ForegroundColor Yellow
Write-Host ""

$answer = Read-Host "是否继续? (y/n)"
if ($answer -ne "y" -and $answer -ne "Y") {
    Write-Host "已取消" -ForegroundColor Red
    exit
}

$needRestart = $false

# ============================================================
# Step 1: Python 3.12 (最先安装，后续 pip/aqtinstall 需要)
# ============================================================
Write-Host ""
Write-Host "[1/6] 安装 Python 3.12..." -ForegroundColor Green

if (Test-WingetInstalled "Python.Python.3.12") {
    Write-Host "  已安装，跳过" -ForegroundColor Gray
} else {
    winget install Python.Python.3.12 --accept-source-agreements --accept-package-agreements
    Refresh-Path
    Write-Host "  Python 安装完成！" -ForegroundColor Green
}

# ============================================================
# Step 2: Git
# ============================================================
Write-Host ""
Write-Host "[2/6] 安装 Git..." -ForegroundColor Green

if (Test-WingetInstalled "Git.Git") {
    Write-Host "  已安装，跳过" -ForegroundColor Gray
} else {
    winget install Git.Git --accept-source-agreements --accept-package-agreements
    Refresh-Path
    Write-Host "  Git 安装完成！" -ForegroundColor Green
}

# ============================================================
# Step 3: Visual Studio 2022 Build Tools (MSVC)
# ============================================================
Write-Host ""
Write-Host "[3/6] 安装 Visual Studio 2022 Build Tools (MSVC 编译器)..." -ForegroundColor Green

if (Test-WingetInstalled "Microsoft.VisualStudio.2022.BuildTools") {
    Write-Host "  已安装，跳过" -ForegroundColor Gray
} else {
    Write-Host "  下载约 2-3GB，请耐心等待..." -ForegroundColor Gray
    winget install Microsoft.VisualStudio.2022.BuildTools `
        --override "--wait --passive --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended" `
        --accept-source-agreements --accept-package-agreements

    if ($LASTEXITCODE -ne 0) {
        Write-Host "  VS Build Tools 安装可能未完成，请检查网络后重试" -ForegroundColor Red
        exit 1
    }
    Write-Host "  VS Build Tools 安装完成！" -ForegroundColor Green
    $needRestart = $true
}

# ============================================================
# Step 4: CMake
# ============================================================
Write-Host ""
Write-Host "[4/6] 安装 CMake..." -ForegroundColor Green

if (Test-WingetInstalled "Kitware.CMake") {
    Write-Host "  已安装，跳过" -ForegroundColor Gray
} else {
    winget install Kitware.CMake --accept-source-agreements --accept-package-agreements
    Refresh-Path
    Write-Host "  CMake 安装完成！" -ForegroundColor Green
}

# ============================================================
# Step 5: Qt 6 (via aqtinstall)
# ============================================================
Write-Host ""
Write-Host "[5/6] 安装 Qt $QT_VERSION..." -ForegroundColor Green

if (Test-Path $QT_DIR) {
    Write-Host "  已安装 ($QT_DIR)，跳过" -ForegroundColor Gray
} else {
    Refresh-Path

    # Install aqtinstall
    Write-Host "  安装 aqtinstall (Qt 命令行安装工具)..." -ForegroundColor Gray
    python -m pip install aqtinstall 2>$null
    if ($LASTEXITCODE -ne 0) {
        # Try pip directly (may need to be in PATH)
        pip install aqtinstall
        if ($LASTEXITCODE -ne 0) {
            Write-Host "  aqtinstall 安装失败。请确认 Python 已正确安装。" -ForegroundColor Red
            Write-Host "  手动安装: pip install aqtinstall" -ForegroundColor Yellow
            exit 1
        }
    }

    Write-Host "  下载 Qt $QT_VERSION (MSVC 2019 64-bit)，约 2GB，请耐心等待..." -ForegroundColor Gray
    aqt install-qt windows desktop $QT_VERSION win64_msvc2019_64 --outputdir C:\Qt

    if (Test-Path $QT_DIR) {
        Write-Host "  Qt 安装完成！" -ForegroundColor Green
    } else {
        Write-Host "  Qt 安装失败。" -ForegroundColor Red
        Write-Host "  手动下载 Qt: https://www.qt.io/download-open-source" -ForegroundColor Yellow
        Write-Host "  选择 MSVC 2019 64-bit 组件，安装到 C:\Qt" -ForegroundColor Yellow
    }
}

# ============================================================
# Step 6: LibTorch
# ============================================================
Write-Host ""
Write-Host "[6/6] 下载 LibTorch 2.5.1..." -ForegroundColor Green

if (Test-Path "$LIBTORCH_DIR\include\torch\torch.h") {
    Write-Host "  已安装，跳过" -ForegroundColor Gray
} else {
    $zipPath = "$env:TEMP\libtorch.zip"
    Write-Host "  下载中 (约 2GB)，请耐心等待..." -ForegroundColor Gray

    try {
        Invoke-WebRequest -Uri $LIBTORCH_URL -OutFile $zipPath -ErrorAction Stop
    } catch {
        Write-Host "  下载失败，请检查网络连接" -ForegroundColor Red
        Write-Host "  手动下载: https://pytorch.org/ → LibTorch → Windows → CPU → cxx11 ABI" -ForegroundColor Yellow
        Write-Host "  解压到: C:\libtorch" -ForegroundColor Yellow
        exit 1
    }

    Write-Host "  解压到 $LIBTORCH_DIR ..." -ForegroundColor Gray
    Expand-Archive -Path $zipPath -DestinationPath "C:\" -Force
    Remove-Item $zipPath
    Write-Host "  LibTorch 安装完成！" -ForegroundColor Green
}

# ============================================================
# Done
# ============================================================
Refresh-Path

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  环境配置完成！" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "已安装的组件:"
Write-Host "  Python       : $(python --version 2>$null)"
Write-Host "  CMake        : $(cmake --version 2>$null | Select-Object -First 1)"
Write-Host "  Qt           : $QT_DIR"
Write-Host "  LibTorch     : $LIBTORCH_DIR"
Write-Host ""

if ($needRestart) {
    Write-Host "============================================" -ForegroundColor Yellow
    Write-Host "  VS Build Tools 安装后需要重启电脑！" -ForegroundColor Yellow
    Write-Host "  重启后直接跳到编译步骤即可，不用再运行本脚本。" -ForegroundColor Yellow
    Write-Host "============================================" -ForegroundColor Yellow
    Write-Host ""
    $answer = Read-Host "是否现在重启? (y/n)"
    if ($answer -eq "y" -or $answer -eq "Y") {
        Restart-Computer
    } else {
        Write-Host "请手动重启后再继续。" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  编译 & 运行" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "打开 PowerShell 或命令提示符，进入项目目录，执行:" -ForegroundColor White
Write-Host ""

$batchCmd = ".\build_windows.bat `"$LIBTORCH_DIR`" `"$QT_DIR`""
Write-Host "  $batchCmd" -ForegroundColor Green

Write-Host ""
Write-Host "编译完成后运行:" -ForegroundColor White
Write-Host "  .\build\Release\num_recognize.exe" -ForegroundColor Green
Write-Host ""

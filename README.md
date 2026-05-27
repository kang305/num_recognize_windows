# 手写数字识别系统（Windows 版）

基于 **PyTorch (LibTorch)** 和 **Qt** 搭建的深度学习手写数字识别系统。

在画布上用鼠标写一个数字，CNN 模型会实时识别出来。

---

## 选择安装方式

| 方式 | 适合人群 | 预计耗时 |
|------|---------|---------|
| **[方式零：一键脚本（最快）](#方式零一键脚本推荐)** | 不想手动操作、喜欢命令行 | 约 15 分钟 |
| **[方式 A：CLion](#方式-aclion)** | 想要 IDE 图形界面、学生 | 约 30 分钟 |
| **[方式 B：Visual Studio + 命令行](#方式-bvisual-studio--命令行)** | 熟悉 VS，或没有 CLion 授权 | 约 45 分钟 |

三种方式结果一样，选一种即可。

---

# 方式零：一键脚本（推荐）

项目自带 `setup_windows.ps1`，在终端里跑一次就能装好全部环境。

> **适用系统：** Windows 10/11（自带 winget）

---

### 步骤 01：下载项目并运行脚本

1. 点击页面顶部绿色 **"Code"** 按钮 → **"Download ZIP"**，解压到任意文件夹
2. 在项目文件夹中，右键 `setup_windows.ps1` → **"使用 PowerShell 运行"**
3. 输入 `y` 确认，等待完成
4. 如果中途提示重启电脑，重启后重新运行脚本

脚本会自动安装：
- Visual Studio 2022 Build Tools（MSVC 编译器）
- CMake（构建工具）
- Qt 6.5.0（GUI 框架）
- LibTorch 2.5.1（推理库）
- Git（版本管理）

---

### 步骤 02：编译运行

环境装好后，在项目目录下打开终端：

```powershell
.\build_windows.bat "C:\libtorch" "C:\Qt\6.5.0\msvc2019_64"
cd build\Release
.\num_recognize.exe
```

---

### 手动逐条安装（不用脚本）

如果你只想装其中某几个组件，下面是每条对应的终端命令：

```powershell
# 1. MSVC 编译器
winget install Microsoft.VisualStudio.2022.BuildTools --override "--wait --passive --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended"

# 2. CMake
winget install Kitware.CMake

# 3. Qt 6.5.0 (需要先装 Python)
winget install Python.Python.3.12
pip install aqtinstall
aqt install-qt windows desktop 6.5.0 win64_msvc2019_64 --outputdir C:\Qt

# 4. LibTorch (下载并解压)
Invoke-WebRequest -Uri "https://download.pytorch.org/libtorch/cpu/libtorch-win-shared-with-deps-2.5.1%2Bcpu.zip" -OutFile "$env:TEMP\libtorch.zip"
Expand-Archive -Path "$env:TEMP\libtorch.zip" -DestinationPath "C:\" -Force
```

---

# 方式 A：CLion

CLion 自带 CMake 和 MinGW 编译器，不需要装 Visual Studio。

---

### 步骤 A1：安装 CLion

1. 打开：https://www.jetbrains.com/clion/download/
2. 下载 Windows 安装包并运行
3. 安装时勾选 **"Add to PATH"** 和 **"Associate .cpp files"**
4. 没有授权的话，点击 **"Start Free Trial"**（免费试用 30 天）
5. 在校学生可以申请免费教育授权：https://www.jetbrains.com/community/education/

---

### 步骤 A2：安装 Qt 6

1. 打开：https://www.qt.io/download-open-source
2. 往下滑，点击 **"Download the Qt Online Installer"**
3. 运行安装器，注册/登录 Qt 账号（免费）
4. 在组件选择界面：
   - 展开 **"Qt"** → 展开最新版本（如 6.5.0）
   - 勾选 **"MSVC 2019 64-bit"**
   - 其他组件可以全部取消勾选以节省空间
5. 点击安装（默认路径：`C:\Qt\`）

---

### 步骤 A3：下载 LibTorch

1. 打开：https://pytorch.org/
2. 依次选择：**Stable** → **Windows** → **LibTorch** → **C++ / Java** → **CPU**
3. 点击 **"Download here (cxx11 ABI)"** 下载 zip 包
4. 将 zip 解压到 `C:\libtorch`（解压后应包含 `include`、`lib`、`bin` 等文件夹）

---

### 步骤 A4：用 CLion 打开项目

1. 点击本页面顶部的绿色 **"Code"** 按钮 → **"Download ZIP"**
2. 解压到任意文件夹（比如桌面）
3. 启动 CLion，点击 **"Open"**，选择项目文件夹
4. CLion 会自动检测到 `CMakeLists.txt`，弹出提示 **"Load CMake project?"** → 点击 **"Load"**

---

### 步骤 A5：配置 CMake

告诉 CLion Qt 和 LibTorch 在哪里：

1. CLion 菜单：**File → Settings → Build, Execution, Deployment → CMake**
2. 在 **"CMake options"** 输入框中粘贴：
   ```
   -DCMAKE_PREFIX_PATH=C:\libtorch;C:\Qt\6.5.0\msvc2019_64
   ```
   如果 Qt 版本不同，修改对应路径即可。

3. 点击 **"Apply"** → **"OK"**
4. CLion 会自动重新运行 CMake，等待底部状态栏显示 **"CMake generation finished"**

---

### 步骤 A6：编译运行

1. 点击工具栏的 **锤子图标**（或按 `Ctrl+F9`）编译
2. 编译完成后，点击绿色的 **▶ 运行按钮**（或按 `Shift+F10`）
3. 程序窗口打开 — **用鼠标在画布上写一个数字（0-9）**，点击"识别"按钮查看结果！

> **提示：** 如果运行时提示找不到 Qt DLL，将 `C:\Qt\6.5.0\msvc2019_64\bin` 添加到系统 PATH 环境变量，然后重启 CLion。

---

# 方式 B：Visual Studio + 命令行

---

### 步骤 B1：安装 Visual Studio 2022

1. 打开：https://visualstudio.microsoft.com/zh-hans/downloads/
2. 找到 **"Visual Studio 2022"** → 点击 **"Community"**（免费）
3. 在安装器中勾选 **"使用 C++ 的桌面开发"**
4. 点击安装（约 10-20 分钟），完成后 **重启电脑**

---

### 步骤 B2：安装 Qt 6

同方式 A 的步骤 A2。注意勾选 **"MSVC 2019 64-bit"**。

---

### 步骤 B3：下载 LibTorch

同方式 A 的步骤 A3。解压到 `C:\libtorch`。

---

### 步骤 B4：下载本项目

1. 点击页面顶部绿色 **"Code"** 按钮 → **"Download ZIP"**
2. 解压到桌面或任意文件夹

---

### 步骤 B5：编译项目

1. 从开始菜单打开 **"Developer Command Prompt for VS 2022"**
2. 进入项目文件夹：
   ```
   cd C:\Users\<你的用户名>\Desktop\num_recognize_windows
   ```
3. 运行构建脚本（根据实际版本调整 Qt 路径）：
   ```
   build_windows.bat "C:\libtorch" "C:\Qt\6.5.0\msvc2019_64"
   ```
4. 看到 **"Build successful!"** 即编译完成

---

### 步骤 B6：运行程序

1. 进入输出目录：
   ```
   cd build\Release
   ```
2. 双击 `num_recognize.exe`，或在命令行运行：
   ```
   num_recognize.exe
   ```
3. 程序窗口打开 — 用鼠标画数字，点击"识别"！

---

## 项目结构

```
num_recognize_windows/
├── main.cpp              # Qt 程序入口
├── mainwindow.h/cpp      # 主窗口界面 + 识别逻辑
├── canvaswidget.h/cpp    # 手写画布控件
├── recognizer.h/cpp       # CNN 模型推理（LibTorch）
├── train_model.py         # 训练模型的 Python 脚本
├── mnist_cnn.pt          # 已训练好的 TorchScript 模型
├── CMakeLists.txt         # CMake 构建配置
├── build_windows.bat     # Windows 命令行一键构建脚本
├── setup_windows.ps1     # Windows 环境一键配置脚本
└── .gitignore
```

## 自己训练模型（可选）

项目中已包含训练好的模型 `mnist_cnn.pt`。如果你想重新训练：

1. 安装 Python 3.8 及以上版本
2. 安装依赖：
   ```
   pip install torch torchvision
   ```
3. 运行训练脚本：
   ```
   python train_model.py
   ```
4. 脚本会自动下载 MNIST 数据集，训练 7 轮，生成新的 `mnist_cnn.pt`
5. 将新的 `.pt` 文件覆盖项目根目录下的旧文件即可

## 说明

- **模型准确率**：在 MNIST 测试集上约 98-99%
- **输入**：28×28 灰度图（画布自动缩放）
- **网络结构**：Conv2d → ReLU → Conv2d → ReLU → MaxPool → FC → FC
- TorchScript 模型跨平台，同一个 `.pt` 文件在 Windows、Mac、Linux 上通用

---

## 常见问题

| 问题 | 解决方法 |
|------|---------|
| CMake 找不到 Qt | 确认 Qt 安装时勾选了 MSVC 2019 64-bit（或 MinGW 64-bit），可以用 Qt Maintenance Tool 补装 |
| CMake 找不到 Torch | 确认 LibTorch 已解压到 `C:\libtorch`，且包含 `include`、`lib`、`bin` 文件夹 |
| 程序启动后闪退 | 把 `mnist_cnn.pt` 复制到 exe 所在的同一文件夹 |
| 提示 `no Qt platform plugin was initialized` | 将 `C:\Qt\6.x.x\msvc2019_64\bin` 添加到系统 PATH，或把 `platforms/qwindows.dll` 复制到 exe 旁边 |
| 提示 `MSVCP140.dll 找不到` | 安装 VC++ 运行库：https://aka.ms/vs/17/release/vc_redist.x64.exe |
| CLion：CMake 生成失败 | 检查 Settings → CMake 中的 `CMAKE_PREFIX_PATH`，确保两段路径在磁盘上真实存在 |
| CLion：运行按钮灰色不可点 | 等待底部状态栏 CMake 加载完成，如果卡住，点 **File → Reload CMake Project** |

# Handwritten Digit Recognition System (Windows)

A deep learning-based handwritten digit recognition system built with **PyTorch (LibTorch)** and **Qt**, running on Windows.

Draw a digit on the canvas, and the CNN model will recognize it in real time.

---

## Choose Your Setup Path

| Path | Suitable For | Estimated Time |
|------|-------------|----------------|
| **[Path A: CLion](#path-a-clion-recommended)** | Most users, beginners, students | ~30 minutes |
| **[Path B: Visual Studio + Command Line](#path-b-visual-studio--command-line)** | Users familiar with VS, or no CLion license | ~45 minutes |

Both paths produce the same result. Pick one.

---

# Path A: CLion (Recommended)

CLion bundles CMake and the MinGW compiler — no need to install Visual Studio.

---

### Step A1: Install CLion

1. Go to: https://www.jetbrains.com/clion/download/
2. Download the Windows installer and run it
3. During installation, check **"Add to PATH"** and **"Associate .cpp files"**
4. If you don't have a license, click **"Start Free Trial"** (30 days) — students can apply for a free educational license at https://www.jetbrains.com/community/education/

---

### Step A2: Install Qt 6

1. Go to: https://www.qt.io/download-open-source
2. Scroll down and click **"Download the Qt Online Installer"**
3. Run the installer, sign up / log in (free)
4. In the component selection screen:
   - Under **"Qt"**, expand the latest version (e.g., 6.5.0)
   - Check **"MSVC 2019 64-bit"**  (CLion can use MSVC toolchain)
   - Or if you prefer MinGW: check **"MinGW 64-bit"**
5. Install (default path: `C:\Qt\`)

---

### Step A3: Download LibTorch

1. Go to: https://pytorch.org/
2. Under "PyTorch Build": **Stable**
3. Under "Your OS": **Windows**
4. Under "Package": **LibTorch**
5. Under "Compute Platform": **CPU**
6. Click **"Download here (cxx11 ABI)"**
7. Extract the zip to `C:\libtorch` (so you have `C:\libtorch\include`, `C:\libtorch\lib`, etc.)

---

### Step A4: Open Project in CLion

1. Click the green **"Code"** button on this page → **"Download ZIP"**
2. Extract to a folder of your choice (e.g., Desktop)
3. Launch CLion, click **"Open"**, select the project folder
4. CLion will detect `CMakeLists.txt` — a notification appears: **"Load CMake project?"** → click **"Load"**

---

### Step A5: Configure CMake in CLion

CLion needs to know where Qt and LibTorch are. Set the `CMAKE_PREFIX_PATH`:

1. In CLion, go to **File → Settings → Build, Execution, Deployment → CMake**
2. In the **"CMake options"** field, paste:
   ```
   -DCMAKE_PREFIX_PATH=C:\libtorch;C:\Qt\6.5.0\msvc2019_64
   ```
   Adjust the Qt path if your version is different.

3. Click **"Apply"** → **"OK"**
4. CLion will automatically re-run CMake — wait for **"CMake generation finished"** in the bottom status bar

---

### Step A6: Build & Run

1. Click the green **▶ hammer icon** (or press `Ctrl+F9`) to build
2. After build completes, click the green **▶ Run button** (or press `Shift+F10`)
3. The app window opens — **draw a digit (0-9) with your mouse**, click "识别 (Recognize)" to see the prediction!

> **Note:** On first run, if the exe can't find Qt DLLs, add `C:\Qt\6.5.0\msvc2019_64\bin` to your system PATH, then restart CLion.

---

# Path B: Visual Studio + Command Line

---

### Step B1: Install Visual Studio 2022 (C++ Compiler)

1. Go to: https://visualstudio.microsoft.com/downloads/
2. Scroll to **"Visual Studio 2022"** → click **"Community"** (free)
3. In the installer, check **"Desktop development with C++"**
4. Click **"Install"** (~10-20 minutes), then **restart your computer**

---

### Step B2: Install Qt 6

Same as Path A Step A2. Make sure to check **"MSVC 2019 64-bit"**.

---

### Step B3: Download LibTorch

Same as Path A Step A3. Extract to `C:\libtorch`.

---

### Step B4: Download This Project

1. Click the green **"Code"** button at the top → **"Download ZIP"**
2. Extract to your Desktop or any folder

---

### Step B5: Build the Project

1. Open **"Developer Command Prompt for VS 2022"** from the Start Menu
2. Navigate to the project folder:
   ```
   cd C:\Users\<YourName>\Desktop\num_recognize_windows
   ```
3. Run the build script:
   ```
   build_windows.bat "C:\libtorch" "C:\Qt\6.5.0\msvc2019_64"
   ```
   Adjust the Qt version and MSVC path as needed.

4. When you see **"Build successful!"**, compilation is done.

---

### Step B6: Run the App

1. Navigate to the output:
   ```
   cd build\Release
   ```
2. Double-click `num_recognize.exe`, or run:
   ```
   num_recognize.exe
   ```
3. The app window opens — draw a digit, click "识别 (Recognize)"!

---

## Project Structure

```
num_recognize_windows/
├── main.cpp              # Qt application entry point
├── mainwindow.h/cpp      # Main window UI + recognition logic
├── canvaswidget.h/cpp    # Drawing canvas widget
├── recognizer.h/cpp       # CNN model inference (LibTorch)
├── train_model.py         # Python script to train the CNN model
├── mnist_cnn.pt          # Pre-trained TorchScript model (28x28 grayscale → 0-9)
├── CMakeLists.txt         # CMake build configuration
├── build_windows.bat     # Windows command-line build script
└── .gitignore
```

## Training Your Own Model (Optional)

The project includes a pre-trained model (`mnist_cnn.pt`). To retrain:

1. Install Python 3.8+
2. Install dependencies:
   ```
   pip install torch torchvision
   ```
3. Run:
   ```
   python train_model.py
   ```
4. This downloads the MNIST dataset, trains for 7 epochs, and generates `mnist_cnn.pt`
5. Copy the new `.pt` file to the project root to replace the existing one

## Notes

- **Model accuracy**: ~98-99% on MNIST test set
- **Input**: 28x28 grayscale image (auto-resized from canvas)
- **Model**: Simple CNN (Conv2d → ReLU → Conv2d → ReLU → MaxPool → FC → FC)
- TorchScript model is cross-platform — the same `.pt` file works on Windows, Mac, and Linux

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| CMake can't find Qt | Make sure MSVC 2019 64-bit (or MinGW 64-bit) is checked in Qt installer. Re-run Qt Maintenance Tool to add it. |
| CMake can't find Torch | Verify LibTorch is extracted to `C:\libtorch` and contains `include/`, `lib/`, `bin/` folders. |
| `num_recognize.exe` crashes on start | Make sure `mnist_cnn.pt` is in the same folder as the exe. |
| `no Qt platform plugin was initialized` | Add `C:\Qt\6.x.x\msvc2019_64\bin` to your PATH, or copy `platforms/qwindows.dll` next to the exe. |
| `MSVCP140.dll not found` | Install Visual C++ Redistributable from: https://aka.ms/vs/17/release/vc_redist.x64.exe |
| CLion: CMake generation failed | Double-check the `CMAKE_PREFIX_PATH` in Settings → CMake — both paths must exist on disk. |
| CLion: Run button grayed out | Wait for CMake to finish loading (check the bottom status bar). If stuck, click **File → Reload CMake Project**. |

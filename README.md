# Handwritten Digit Recognition System (Windows)

A deep learning-based handwritten digit recognition system built with **PyTorch (LibTorch)** and **Qt**, running on Windows.

Draw a digit on the canvas, and the CNN model will recognize it in real time.

---

## Step-by-Step Setup Guide (Fresh Windows Machine)

This guide assumes you have **nothing** installed. Follow each step in order.

---

### Step 1: Install Visual Studio 2022 (C++ Compiler)

Qt and LibTorch require a C++ compiler. We'll install Visual Studio.

1. Open your browser and go to: https://visualstudio.microsoft.com/downloads/
2. Scroll down to **"Visual Studio 2022"** → click **"Community"** (free)
3. Run the downloaded installer
4. In the installer, check **"Desktop development with C++"**
5. Click **"Install"** (takes ~10-20 minutes)
6. After installation, **restart your computer**

---

### Step 2: Install Qt 6

Qt provides the GUI framework.

1. Open your browser and go to: https://www.qt.io/download-open-source
2. Scroll down and click **"Download the Qt Online Installer"**
3. Run the downloaded installer
4. During installation:
   - Sign up / log in with a Qt account (free)
   - Choose **"Qt 6.x.x"** (latest stable version, e.g., 6.5.0)
   - Expand the version and check **"MSVC 2019 64-bit"**
   - Uncheck all other components to save space
5. Install (takes ~5-10 minutes, about 2-3 GB)
6. Default install path: `C:\Qt\`

---

### Step 3: Download LibTorch (PyTorch C++ Library)

LibTorch is the C++ version of PyTorch, used to load and run the neural network model.

1. Open your browser and go to: https://pytorch.org/
2. On the homepage, click **"Install"** in the top menu
3. Under "PyTorch Build", select: **Stable**
4. Under "Your OS", select: **Windows**
5. Under "Package", select: **LibTorch**
6. Under "Language", select: **C++ / Java**
7. Under "Compute Platform", select: **CPU** (no GPU needed)
8. A download link will appear — click **"Download here (cxx11 ABI)"**
9. Find the downloaded zip file (e.g., `libtorch-win-shared-with-deps-2.x.x+cpu.zip`)
10. Extract it to `C:\libtorch` (the final path should be `C:\libtorch\include`, `C:\libtorch\lib`, etc.)

---

### Step 4: Download This Project

1. Click the green **"Code"** button at the top of this page → **"Download ZIP"**
2. Extract the zip to `C:\Users\<YourName>\Desktop\num_recognize_windows`

---

### Step 5: Build the Project

1. Open **"Developer Command Prompt for VS 2022"** from the Start Menu
2. Navigate to the project folder:
   ```
   cd C:\Users\<YourName>\Desktop\num_recognize_windows
   ```
3. Run the build script (adjust Qt version if needed):
   ```
   build_windows.bat "C:\libtorch" "C:\Qt\6.5.0\msvc2019_64"
   ```
   If Qt installed to a different version path, change `6.5.0` and `msvc2019_64` accordingly.

4. Wait for compilation (~2-5 minutes)
5. If successful, you'll see: `Build successful!`

---

### Step 6: Run the App

1. Navigate to the build output:
   ```
   cd build\Release
   ```
2. Double-click `num_recognize.exe` in File Explorer, or run:
   ```
   num_recognize.exe
   ```
3. The app window opens — **draw a digit (0-9) with your mouse** on the canvas, click "识别 (Recognize)" to see the prediction!

---

## Project Structure

```
num_recognize_windows/
├── main.cpp              # Qt application entry point
├── mainwindow.h/cpp      # Main window UI + recognition logic
├── canvaswidget.h/cpp    # Drawing canvas widget
├── recognizer.h/cpp       # CNN model inference (LibTorch)
├── train_model.py         # Python script to train the CNN model
├── mnist_cnn.pt          # Pre-trained TorchScript model (88x28 grayscale → 0-9)
├── CMakeLists.txt         # CMake build configuration
├── build_windows.bat     # One-click Windows build script
└── .gitignore
```

## Training Your Own Model (Optional)

The project includes a pre-trained model (`mnist_cnn.pt`). To retrain:

1. Install Python 3.8+
2. Install dependencies:
   ```
   pip install torch torchvision
   ```
3. Run the training script:
   ```
   python train_model.py
   ```
4. This will download the MNIST dataset, train for 7 epochs, and save a new `mnist_cnn.pt`
5. Copy the new `mnist_cnn.pt` to the project root to replace the existing one

## Notes

- **Model accuracy**: ~98-99% on MNIST test set
- **Input**: 28x28 grayscale image (auto-resized from canvas)
- **Model**: Simple CNN (Conv2d → ReLU → Conv2d → ReLU → MaxPool → FC → FC)
- TorchScript model is cross-platform — the same `.pt` file works on Windows, Mac, and Linux

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| CMake can't find Qt | Make sure MSVC 2019 64-bit is checked in Qt installer. Re-run Qt Maintenance Tool to add it. |
| CMake can't find Torch | Verify LibTorch is extracted to `C:\libtorch` and the path contains `include/`, `lib/`, `bin/` folders. |
| `num_recognize.exe` crashes on start | Copy `mnist_cnn.pt` from the project root to `build\Release\` next to the exe. |
| `no Qt platform plugin was initialized` | Add `C:\Qt\6.x.x\msvc2019_64\bin` to your system PATH, or copy `platforms/qwindows.dll` next to the exe. |
| Build fails with linker errors | Make sure LibTorch and Qt are both 64-bit. Open "x64 Native Tools Command Prompt for VS 2022" specifically (not x86). |

#include "mainwindow.h"
#include <QMessageBox>
#include <QGroupBox>
#include <QFont>
#include <QDir>
#include <QFile>
#include <QCoreApplication>
#include <algorithm>

MainWindow::MainWindow(QWidget* parent)
    : QMainWindow(parent)
    , canvas_(nullptr)
    , recognizer_(nullptr)
{
    setWindowTitle("手写数字识别系统 - Handwritten Digit Recognition");
    setMinimumSize(500, 600);

    setupUI();
    loadModel();
}

MainWindow::~MainWindow() {
    delete recognizer_;
}

void MainWindow::setupUI() {
    QWidget* centralWidget = new QWidget(this);
    setCentralWidget(centralWidget);
    QVBoxLayout* mainLayout = new QVBoxLayout(centralWidget);

    // Title
    QLabel* titleLabel = new QLabel("基于深度学习的手写数字识别系统");
    titleLabel->setAlignment(Qt::AlignCenter);
    QFont titleFont;
    titleFont.setPointSize(16);
    titleFont.setBold(true);
    titleLabel->setFont(titleFont);
    mainLayout->addWidget(titleLabel);

    // Canvas
    QGroupBox* canvasGroup = new QGroupBox("手写输入区域 (用鼠标绘制数字)");
    QVBoxLayout* canvasLayout = new QVBoxLayout(canvasGroup);
    canvasLayout->setAlignment(Qt::AlignCenter);
    canvas_ = new CanvasWidget(this);
    canvasLayout->addWidget(canvas_);
    mainLayout->addWidget(canvasGroup);

    // Buttons
    QHBoxLayout* buttonLayout = new QHBoxLayout();
    recognizeBtn_ = new QPushButton("识别 (Recognize)");
    clearBtn_ = new QPushButton("清除 (Clear)");
    recognizeBtn_->setMinimumHeight(40);
    clearBtn_->setMinimumHeight(40);
    buttonLayout->addWidget(recognizeBtn_);
    buttonLayout->addWidget(clearBtn_);
    mainLayout->addLayout(buttonLayout);

    connect(recognizeBtn_, &QPushButton::clicked, this, &MainWindow::onRecognize);
    connect(clearBtn_, &QPushButton::clicked, this, &MainWindow::onClear);

    // Result
    QGroupBox* resultGroup = new QGroupBox("识别结果");
    QVBoxLayout* resultLayout = new QVBoxLayout(resultGroup);

    resultLabel_ = new QLabel("请在画布中手写数字，然后点击\"识别\"");
    resultLabel_->setAlignment(Qt::AlignCenter);
    QFont resultFont;
    resultFont.setPointSize(14);
    resultLabel_->setFont(resultFont);
    resultLayout->addWidget(resultLabel_);

    // Probability bars
    for (int i = 0; i < 10; ++i) {
        QHBoxLayout* barLayout = new QHBoxLayout();
        QLabel* digitLabel = new QLabel(QString::number(i));
        digitLabel->setFixedWidth(20);
        digitLabel->setAlignment(Qt::AlignRight | Qt::AlignVCenter);

        QProgressBar* bar = new QProgressBar();
        bar->setRange(0, 100);
        bar->setValue(0);
        bar->setTextVisible(false);
        bar->setMaximumHeight(18);

        QLabel* pctLabel = new QLabel("0%");
        pctLabel->setFixedWidth(40);

        barLayout->addWidget(digitLabel);
        barLayout->addWidget(bar);
        barLayout->addWidget(pctLabel);

        probBars_.push_back(bar);
        probLabels_.push_back(pctLabel);
        resultLayout->addLayout(barLayout);
    }

    mainLayout->addWidget(resultGroup);
}

void MainWindow::loadModel() {
    recognizer_ = new Recognizer();

    // Try multiple paths
    QStringList paths = {
        "mnist_cnn.pt",
        QCoreApplication::applicationDirPath() + "/mnist_cnn.pt",
        QCoreApplication::applicationDirPath() + "/../mnist_cnn.pt",
        QDir::currentPath() + "/mnist_cnn.pt"
    };

    bool loaded = false;
    for (const auto& path : paths) {
        if (QFile::exists(path)) {
            loaded = recognizer_->loadModel(path.toStdString());
            if (loaded) break;
        }
    }

    if (!loaded) {
        resultLabel_->setText("模型文件 mnist_cnn.pt 未找到！请先运行 train_model.py 训练模型。");
    }
}

void MainWindow::onRecognize() {
    if (!recognizer_ || !recognizer_->isLoaded()) {
        resultLabel_->setText("模型未加载，无法识别。请先训练模型。");
        return;
    }

    // Get normalized 28x28 pixel data
    auto pixels = canvas_->getNormalizedPixels(28, 28);

    // MNIST normalization: (x - 0.1307) / 0.3081
    for (auto& p : pixels) {
        p = (p - 0.1307f) / 0.3081f;
    }

    // Run prediction
    std::vector<float> probabilities;
    int predicted = recognizer_->predict(pixels, 28, 28, &probabilities);

    if (predicted < 0) {
        resultLabel_->setText("识别失败");
        return;
    }

    // Update result display
    resultLabel_->setText(QString("识别结果: %1").arg(predicted));

    // Update probability bars
    for (int i = 0; i < 10 && i < (int)probabilities.size(); ++i) {
        int pct = static_cast<int>(probabilities[i] * 100);
        probBars_[i]->setValue(pct);
        probLabels_[i]->setText(QString::number(pct) + "%");

        // Highlight the predicted digit
        if (i == predicted) {
            probBars_[i]->setStyleSheet(
                "QProgressBar::chunk { background-color: #4CAF50; }");
        } else {
            probBars_[i]->setStyleSheet(
                "QProgressBar::chunk { background-color: #2196F3; }");
        }
    }
}

void MainWindow::onClear() {
    canvas_->clear();
    resultLabel_->setText("已清除，请重新绘制数字");
    for (int i = 0; i < 10; ++i) {
        probBars_[i]->setValue(0);
        probLabels_[i]->setText("0%");
        probBars_[i]->setStyleSheet(
            "QProgressBar::chunk { background-color: #2196F3; }");
    }
}

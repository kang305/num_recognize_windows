#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <QPushButton>
#include <QLabel>
#include <QVBoxLayout>
#include <QHBoxLayout>
#include <QProgressBar>
#include <vector>

#include "canvaswidget.h"
#include "recognizer.h"

class MainWindow : public QMainWindow {
    Q_OBJECT

public:
    explicit MainWindow(QWidget* parent = nullptr);
    ~MainWindow();

private slots:
    void onRecognize();
    void onClear();

private:
    void setupUI();
    void loadModel();

    CanvasWidget* canvas_;
    Recognizer* recognizer_;

    QPushButton* recognizeBtn_;
    QPushButton* clearBtn_;
    QLabel* resultLabel_;
    std::vector<QProgressBar*> probBars_;
    std::vector<QLabel*> probLabels_;
};

#endif // MAINWINDOW_H

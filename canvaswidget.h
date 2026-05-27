#ifndef CANVASWIDGET_H
#define CANVASWIDGET_H

#include <QWidget>
#include <QImage>
#include <QPoint>
#include <QPainter>

class CanvasWidget : public QWidget {
    Q_OBJECT

public:
    explicit CanvasWidget(QWidget* parent = nullptr);

    void clear();
    QImage getImage() const;
    std::vector<float> getNormalizedPixels(int targetWidth, int targetHeight) const;

protected:
    void paintEvent(QPaintEvent* event) override;
    void mousePressEvent(QMouseEvent* event) override;
    void mouseMoveEvent(QMouseEvent* event) override;
    void mouseReleaseEvent(QMouseEvent* event) override;

private:
    void drawLineTo(const QPoint& endPoint);
    void resizeImage(const QSize& newSize);

    QImage image_;
    QPoint lastPoint_;
    bool drawing_ = false;
    static const int DEFAULT_SIZE = 280;
    static const int PEN_WIDTH = 18;
};

#endif // CANVASWIDGET_H
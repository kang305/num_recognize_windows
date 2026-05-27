#include "canvaswidget.h"
#include <QMouseEvent>
#include <QPainter>
#include <cmath>

CanvasWidget::CanvasWidget(QWidget* parent)
    : QWidget(parent)
{
    setMinimumSize(DEFAULT_SIZE, DEFAULT_SIZE);
    setMaximumSize(DEFAULT_SIZE, DEFAULT_SIZE);
    setMouseTracking(true);

    QImage img(DEFAULT_SIZE, DEFAULT_SIZE, QImage::Format_Grayscale8);
    img.fill(Qt::white);
    image_ = img;
}

void CanvasWidget::clear() {
    image_.fill(Qt::white);
    update();
}

QImage CanvasWidget::getImage() const {
    return image_;
}

std::vector<float> CanvasWidget::getNormalizedPixels(int targetWidth, int targetHeight) const {
    QImage scaled = image_.scaled(targetWidth, targetHeight, Qt::IgnoreAspectRatio, Qt::SmoothTransformation);

    std::vector<float> pixels;
    pixels.reserve(targetWidth * targetHeight);

    for (int y = 0; y < targetHeight; ++y) {
        for (int x = 0; x < targetWidth; ++x) {
            // Convert 0-255 grayscale to [0, 1] normalized, inverted (white bg=0, black ink=1)
            float value = 1.0f - (qGray(scaled.pixel(x, y)) / 255.0f);
            pixels.push_back(value);
        }
    }

    return pixels;
}

void CanvasWidget::paintEvent(QPaintEvent*) {
    QPainter painter(this);
    QRect rect(0, 0, width(), height());
    painter.drawImage(rect, image_);

    // Draw border
    painter.setPen(QPen(Qt::black, 2));
    painter.drawRect(rect.adjusted(1, 1, -1, -1));
}

void CanvasWidget::mousePressEvent(QMouseEvent* event) {
    if (event->button() == Qt::LeftButton) {
        drawing_ = true;
        lastPoint_ = event->pos();
        drawLineTo(event->pos());
    }
}

void CanvasWidget::mouseMoveEvent(QMouseEvent* event) {
    if (drawing_) {
        drawLineTo(event->pos());
    }
}

void CanvasWidget::mouseReleaseEvent(QMouseEvent* event) {
    if (event->button() == Qt::LeftButton) {
        drawing_ = false;
        drawLineTo(event->pos());
    }
}

void CanvasWidget::drawLineTo(const QPoint& endPoint) {
    QPainter painter(&image_);
    painter.setRenderHint(QPainter::Antialiasing);
    painter.setPen(QPen(Qt::black, PEN_WIDTH, Qt::SolidLine, Qt::RoundCap, Qt::RoundJoin));
    painter.drawLine(lastPoint_, endPoint);
    lastPoint_ = endPoint;
    update();
}

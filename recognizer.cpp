#include "recognizer.h"
#include <iostream>

Recognizer::Recognizer() {}

Recognizer::~Recognizer() {}

bool Recognizer::loadModel(const std::string& modelPath) {
    try {
        model_ = torch::jit::load(modelPath);
        model_.eval();
        loaded_ = true;
        std::cout << "Model loaded successfully from: " << modelPath << std::endl;
        return true;
    } catch (const c10::Error& e) {
        std::cerr << "Error loading model: " << e.what() << std::endl;
        loaded_ = false;
        return false;
    }
}

bool Recognizer::isLoaded() const {
    return loaded_;
}

int Recognizer::predict(const std::vector<float>& imageData, int width, int height,
                        std::vector<float>* outProbabilities) {
    if (!loaded_) {
        std::cerr << "Model not loaded!" << std::endl;
        return -1;
    }

    // Create tensor from image data: [1, 1, height, width]
    auto options = torch::TensorOptions().dtype(torch::kFloat32);
    torch::Tensor input = torch::from_blob(
        const_cast<float*>(imageData.data()),
        {1, 1, height, width},
        options
    ).clone();

    // Run inference
    torch::NoGradGuard no_grad;
    std::vector<torch::jit::IValue> inputs;
    inputs.push_back(input);
    auto output = model_.forward(inputs).toTensor();

    // Model outputs log_softmax, convert to probabilities with exp
    auto probs = torch::exp(output);
    auto maxResult = probs.max(1);
    int predicted = std::get<1>(maxResult).item<int>();

    if (outProbabilities) {
        outProbabilities->resize(10);
        auto squeezed = probs.squeeze();
        auto probAccessor = squeezed.accessor<float, 1>();
        for (int i = 0; i < 10; ++i) {
            (*outProbabilities)[i] = probAccessor[i];
        }
    }

    return predicted;
}

#ifndef RECOGNIZER_H
#define RECOGNIZER_H

// Qt's 'slots' keyword macro conflicts with LibTorch's Object::slots() method.
// Temporarily undefine it before including torch headers.
#ifdef slots
#pragma push_macro("slots")
#undef slots
#define SLOTS_WAS_DEFINED
#endif

#include <torch/torch.h>
#include <torch/script.h>

#ifdef SLOTS_WAS_DEFINED
#pragma pop_macro("slots")
#undef SLOTS_WAS_DEFINED
#endif

#include <vector>
#include <string>

class Recognizer {
public:
    Recognizer();
    ~Recognizer();

    bool loadModel(const std::string& modelPath);
    bool isLoaded() const;

    int predict(const std::vector<float>& imageData, int width, int height,
                std::vector<float>* outProbabilities = nullptr);

private:
    torch::jit::script::Module model_;
    bool loaded_ = false;
};

#endif // RECOGNIZER_H
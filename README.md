# mask-detection
AI mask detection model at google colab

### Mask Detection Project Summary

#### **Motivation**
The project is driven by the need to enforce mask-wearing regulations in public spaces due to COVID-19. The aim is to develop an AI model for Hanyang Corporations that can identify whether a person is wearing a mask using smart kiosks.

#### **Surrounding Conditions**
There is an abundance of non-masked face datasets, but not enough masked face datasets for training a deep network. To address this, realistic masked faces need to be generated and used for training.

#### **Goal**
The project’s objective is to develop a deep learning model capable of binary classification to determine if a person in an image is wearing a mask. The model will be implemented and tested in Google Colab.

#### **Important Information**
- **Code Requirements:** Include tensorboard visualizations for the training process.

#### **How to Proceed**
1. **Data Preparation:** Download aligned and cropped face images. Use MaskTheFace tool to create augmented face images with masks.
2. **Model Architecture:** Use a Resnet-50 architecture from the PyTorch model zoo for the binary classification task.
3. **Training:** Train the model with the provided dataset using BCELossWithLogitsLoss. Recommended settings include 50 epochs, a batch size of 64, and a learning rate of 0.01.
4. **Testing:** Evaluate the model with personal or celebrity photos.

#### **Synthetic Data Generation **
Generate masked face images for the "wearing_mask" directory in both training and validation sets using the MaskTheFace tool.

#### **Data Augmentation **
Apply random augmentations such as flips and scaling. Crop the images to 112x112 pixels using PyTorch's dataloader and transformation tools.

#### **Model **
Implement a binary classifier using the Resnet-50 architecture. Set the output to binary values representing masked (1) and non-masked (0) faces.

#### **Training Process**
- **Optimizer:** Any choice of optimizer.
- **Loss Function:** BCEWithLogitsLoss.
- **Epochs:** 50
- **Batch Size:** 64
- **Learning Rate:** 0.01
- **Model Saving:** Save the trained model using PyTorch's model saving tutorial.

#### **Visualization **
- Track training and validation loss and accuracy using WandB.
- Plot the ROC curve and AUC for each epoch to evaluate the model's performance.

#### **Important Criteria**
- **Synthetic Data Generation**  applying different types and colors of masks.
- **Data Augmentation** designing the dataloader and performing augmentations.
- **Model Implementation** correctly importing and utilizing the Resnet-50 model.
- **Training** training performance over a minimum of 20 epochs.
- **Visualization** plotting metrics like loss, accuracy, ROC curve, and AUC.
- **Qualitative Evaluation** testing with custom images.
- **Discussions** ablation studies and discussing model limitations.
- **Evaluation on Test Set** 

#### **Report Included **
- Diagram and description of the Resnet-50 architecture.
- Sample augmented images using MaskTheFace.
- Training and validation plots (accuracy, loss, ROC curve, AUC).
- Discussions on ablation studies, model limitations, and qualitative evaluation results.


#### **Miscellaneous Points**
- Follow examples from the provided MNIST classification notebook.
- Understand how to load images into PyTorch tensors and handle data between CPU and GPU.

This summary encapsulates the project's outline and provides a roadmap for developing the mask detection AI model.

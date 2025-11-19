from flask import Flask, render_template, request
import tensorflow as tf
from tensorflow.keras.preprocessing import image
import numpy as np
import os

app = Flask(__name__, static_folder="static")

# Ensure static folder exists
os.makedirs("static", exist_ok=True)

MODEL_PATH = "Model/skin_disease_model.h5"
model = tf.keras.models.load_model(MODEL_PATH)

print("MODEL OUTPUT SHAPE:", model.output_shape)

class_labels = [
    "Acne and Rosacea Photos",
    "Actinic Keratosis Basal Cell Carcinoma and other Malignant Lesions",
    "Atopic Dermatitis Photos",
    "Cellulitis Impetigo and other Bacterial Infections",
    "Eczema Photos",
    "Exanthems and Drug Eruptions",
    "Herpes HPV and other STDs Photos",
    "Light Diseases and Disorders of Pigmentation",
    "Lupus and other Connective Tissue diseases",
    "Melanoma Skin Cancer Nevi and Moles",
    "Poison Ivy Photos and other Contact Dermatitis",
    "Psoriasis pictures Lichen Planus and related diseases",
    "Seborrheic Keratoses and other Benign Tumors",
    "Systemic Disease",
    "Tinea Ringworm Candidiasis and other Fungal Infections",
    "Urticaria Hives",
    "Vascular Tumors",
    "Vasculitis Photos",
    "Warts Molluscum and other Viral Infections"
]

def predict_image(img_path):
    img = image.load_img(img_path, target_size=(224, 224))
    img = image.img_to_array(img)
    img = np.expand_dims(img, axis=0) / 255.0

    predictions = model.predict(img)
    class_index = np.argmax(predictions)
    confidence = np.max(predictions) * 100

    return class_labels[class_index], confidence

@app.route("/")
def home():
    return render_template("index.html")

@app.route("/predict", methods=["POST"])
def predict():
    if "file" not in request.files:
        return "No file uploaded"

    file = request.files["file"]

    file_path = os.path.join("static", file.filename)
    file.save(file_path)

    label, confidence = predict_image(file_path)

    return render_template("result.html",
                           image_path=file_path,
                           prediction=label,
                           confidence=round(confidence, 2))

if __name__ == "__main__":
    app.run(debug=True)


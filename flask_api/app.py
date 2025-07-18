from flask import Flask, request, jsonify
from flask_cors import CORS
import cv2
import numpy as np
import mediapipe as mp
import pickle
import tempfile
import os

# Load model
model_dict = pickle.load(open('model.p', 'rb'))
model = model_dict['model']

# Labels
labels_dict = {
    0: 'A', 1: 'B', 2: 'C', 3: 'D', 4: 'E', 5: 'F', 6: 'G', 7: 'H', 8: 'I',
    9: 'J', 10: 'K', 11: 'L', 12: 'M', 13: 'N', 14: 'O', 15: 'P', 16: 'Q', 17: 'R',
    18: 'S', 19: 'T', 20: 'U', 21: 'V', 22: 'W', 23: 'X', 24: 'Y', 25: 'Z', 26: '0',
    27: '1', 28: '2', 29: '3', 30: '4', 31: '5', 32: '6', 33: '7', 34: '8', 35: '9'
}

# MediaPipe setup
mp_hands = mp.solutions.hands
hands = mp_hands.Hands(static_image_mode=True, max_num_hands=1)
mp_drawing = mp.solutions.drawing_utils

# Flask app setup
app = Flask(__name__)
CORS(app)

@app.route('/predict', methods=['POST'])
def predict():
    if 'image' not in request.files:
        return jsonify({'error': 'No image file provided'}), 400

    file = request.files['image']
    
    # Save image temporarily
    with tempfile.NamedTemporaryFile(delete=False, suffix=".jpg") as temp_file:
        file.save(temp_file.name)
        temp_path = temp_file.name

    # Load image using OpenCV
    image = cv2.imread(temp_path)
    os.remove(temp_path)  # clean up

    if image is None:
        return jsonify({'error': 'Invalid image'}), 400

    # Convert to RGB
    image_rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
    results = hands.process(image_rgb)

    if not results.multi_hand_landmarks:
        return jsonify({'error': 'No hands detected'}), 400

    # Extract landmarks
    hand_landmarks = results.multi_hand_landmarks[0]
    x_ = []
    y_ = []
    data_aux = []

    for landmark in hand_landmarks.landmark:
        x_.append(landmark.x)
        y_.append(landmark.y)

    if not x_ or not y_:
        return jsonify({'error': 'Invalid landmark data'}), 400

    x_min = min(x_)
    y_min = min(y_)

    for landmark in hand_landmarks.landmark:
        data_aux.append(landmark.x - x_min)
        data_aux.append(landmark.y - y_min)

    if len(data_aux) != 42:
        return jsonify({'error': f'Expected 42 features, got {len(data_aux)}'}), 400

    try:
        prediction = model.predict([np.asarray(data_aux)])
        predicted_label = labels_dict[int(prediction[0])]
        return jsonify({'prediction': predicted_label})
    except Exception as e:
        return jsonify({'error': f'Prediction failed: {str(e)}'}), 500

if __name__ == '__main__':
    app.run(debug=True)

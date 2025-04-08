import face_recognition
import cv2
import numpy as np
import RPi.GPIO as GPIO
import time
import random
import os

ti = time.time()

# GPIO setup
LED = 4
KEY = 5
SERVO_PIN = 2

GPIO.setmode(GPIO.BCM)
GPIO.setup(LED, GPIO.OUT)
GPIO.setup(KEY, GPIO.IN)
GPIO.setup(SERVO_PIN, GPIO.OUT)

# PWM 객체 생성 및 시작
servo = GPIO.PWM(SERVO_PIN, 50)
servo.start(0)

# 서보 모터 제어에 사용되는 상수 정의
SERVO_MAX_DUTY = 12
SERVO_MIN_DUTY = 3

# 서보 모터 제어 함수 정의
def servo_control(degree, delay):
    if degree > 90:
        degree = 90

    # 각도에 따른 듀티 비 계산
    duty = SERVO_MIN_DUTY + (degree * (SERVO_MAX_DUTY - SERVO_MIN_DUTY) / 90.0)
    print("Degree: {} to {}(Duty)".format(degree, duty))
    
    # 듀티 비 설정 및 대기
    servo.ChangeDutyCycle(duty)
    time.sleep(delay)

# 사진 인코딩 및 학습
known_faces = []
names = []

image_dir = "/home/SIUUU/.venv/door_lock/jeonsang"
for file_name in os.listdir(image_dir):
    if file_name.endswith((".jpg", ".jpeg", ".png")):
        image_path = os.path.join(image_dir, file_name)
        image = face_recognition.load_image_file(image_path)
        
        # 얼굴 인코딩 시 다양한 jitter 적용
        face_encodings = face_recognition.face_encodings(image, num_jitters=10)
        
        for encoding in face_encodings:
            known_faces.append(encoding)
            names.append(os.path.splitext(file_name)[0])

tf = time.time()
print(tf - ti)
print("press button")

recognition_threshold = 2  # seconds

# 비디오 처리 함수
def process_video(video_path):
    frame_number = 0
    frame_skip = 6
    recognition_start_time = None

    # Open the input movie file
    input_movie = cv2.VideoCapture(video_path)
    length = int(input_movie.get(cv2.CAP_PROP_FRAME_COUNT))

    recognized = False
    initial_time = time.time()

    while input_movie.isOpened():
        # Skip frames
        if frame_number % frame_skip != 0:
            frame_number += 1
            input_movie.grab()  # just grab the frame and skip processing
            continue

        # Grab a single frame of video
        ret, frame = input_movie.read()
        frame_number += 1

        # Quit when the input video file ends
        if not ret:
            break

        # Resize frame for faster face recognition processing
        small_frame = cv2.resize(frame, (0, 0), fx = 0.2, fy = 0.2)
        rgb_small_frame = np.ascontiguousarray(small_frame[:, :, ::-1])

        # Find all the faces and face encodings in the current frame of video
        face_locations = face_recognition.face_locations(rgb_small_frame, model = 'hog')
        face_encodings = face_recognition.face_encodings(rgb_small_frame, face_locations)

        face_names = []
        face_probabilities = []
        for face_encoding in face_encodings:
            matches = face_recognition.compare_faces(known_faces, face_encoding, tolerance=0.5)
            face_distances = face_recognition.face_distance(known_faces, face_encoding)
            best_match_index = np.argmin(face_distances)
            name = None
            probability = 0.0

            if matches[best_match_index]:
                name = names[best_match_index]
                probability = (1 - face_distances[best_match_index]) * 100

            face_names.append(name)
            face_probabilities.append(probability)
            if name:
                recognized = True

        # Label the results
        for (top, right, bottom, left), name, probability in zip(face_locations, face_names, face_probabilities):
            if name:
                # Scale back up face locations since the frame we detected in was scaled to 1/2 size
                top *= 5
                right *= 5
                bottom *= 5
                left *= 5

                # Draw a box around the face
                cv2.rectangle(frame, (left, top), (right, bottom), (0, 0, 255), 2)

                # Draw a label with a name below the face
                cv2.rectangle(frame, (left, bottom - 25), (right, bottom), (0, 0, 255), cv2.FILLED)
                font = cv2.FONT_HERSH
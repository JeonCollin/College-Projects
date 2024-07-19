import face_recognition
import cv2
import numpy as np

# Open the input movie file
input_movie = cv2.VideoCapture("hamilton_clip.mp4")
length = int(input_movie.get(cv2.CAP_PROP_FRAME_COUNT))

# Create an output movie file (make sure resolution/frame rate matches input video!)
fourcc = cv2.VideoWriter_fourcc(*'H264')
output_movie = cv2.VideoWriter('output.mp4', fourcc, 29.97, (640, 360))

# Load some sample pictures and learn how to recognize them.
lmm_image = face_recognition.load_image_file("lin-manuel-miranda.png")
lmm_face_encoding = face_recognition.face_encodings(lmm_image)[0]

al_image = face_recognition.load_image_file("alex-lacamoire.png")
al_face_encoding = face_recognition.face_encodings(al_image)[0]

known_faces = [
    lmm_face_encoding,
    al_face_encoding
]

# Initialize some variables
frame_number = 0
frame_skip = 10
names = ["Lin-Manuel Miranda", "Alex Lacamoire"]

while True:
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
    small_frame = cv2.resize(frame, (0, 0), fx=0.5, fy=0.5)
    rgb_small_frame = np.ascontiguousarray(small_frame[:, :, ::-1])

    # Find all the faces and face encodings in the current frame of video
    face_locations = face_recognition.face_locations(rgb_small_frame)
    face_encodings = face_recognition.face_encodings(rgb_small_frame, face_locations)

    face_names = []
    for face_encoding in face_encodings:
        matches = face_recognition.compare_faces(known_faces, face_encoding, tolerance=0.50)
        name = None

        for i, match in enumerate(matches):
            if match:
                name = names[i]
                break

        face_names.append(name)

    # Label the results
    for (top, right, bottom, left), name in zip(face_locations, face_names):
        if not name:
            continue

        # Scale back up face locations since the frame we detected in was scaled to 1/2 size
        top *= 2
        right *= 2
        bottom *= 2
        left *= 2

        # Draw a box around the face
        cv2.rectangle(frame, (left, top), (right, bottom), (0, 0, 255), 2)

        # Draw a label with a name below the face
        cv2.rectangle(frame, (left, bottom - 25), (right, bottom), (0, 0, 255), cv2.FILLED)
        font = cv2.FONT_HERSHEY_DUPLEX
        cv2.putText(frame, name, (left + 6, bottom - 6), font, 0.5, (255, 255, 255), 1)

    # Show the frame on the screen
    cv2.imshow('Video', frame)

    # Write the resulting image to the output video file
    print(f"Writing frame {frame_number} / {length}")
    output_movie.write(frame)

    # Exit the video display window when 'q' is pressed
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

# All done!
input_movie.release()
output_movie.release()
cv2.destroyAllWindows()

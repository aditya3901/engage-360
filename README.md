<!-- PROJECT LOGO -->
<div align=center>
    <img width=200 src="https://github.com/aditya3901/engage-360/blob/master/assets/images/appicon.png" alt="Logo" width="200" height="200">
    <h1>Engage 360</h1>
    <a href="https://madewithlove.org.in" target="_blank">Made with <span style="color: #e74c3c">&hearts;</span> in India</a>
</div>

## About The Project

Engage 360 aims to resolve the problems faced by people in the online mode of education and examination! Engage 360 provides solution to the problems such as <b>Proxy User, Proxy Attendance and Cheating during Online Examinations</b>.

## Core Features

* <b>Face Recognition Based Authentication System</b>
* <b>Automated Attendance System during Video Call Meetings</b>&nbsp;&nbsp;⭐
* <b>Online Exam Proctoring | Cheating Detection System</b>&nbsp;&nbsp;⭐&nbsp;⭐

|![](https://github.com/aditya3901/aditya3901/blob/main/Engage-360/pic_1.png)|![](https://github.com/aditya3901/aditya3901/blob/main/Engage-360/pic_2.png)|![](https://github.com/aditya3901/aditya3901/blob/main/Engage-360/pic_3.png)|
|-|-|-|

## Built With

Here's a curated list of all the major technologies that have been used to build Engage 360: 

* <b>[Flutter](https://flutter.dev/)</b> : For building the UI of the app
* <b>[Dart](https://dart.dev/)</b> : For building the backend of the app
* <b>[Azure Face Api](https://azure.microsoft.com/en-in/services/cognitive-services/face/)</b> : For Detecting and Verifying Face of the User
* <b>[Firebase ML Vision SDK](https://developers.google.com/ml-kit/vision/face-detection)</b> : For Detecting Face in real-time from Camera Stream
* <b>[Agora WebRTC](https://www.agora.io/en/)</b> : For implementing the Video Calling Feature
* <b>[Firebase Database](https://firebase.google.com/docs/database)</b> : For Storing User's Data and other app events

## Instructions for Project Setup
* Clone the repo to your local system
* After opening the project, first thing to do is **to get the packages**. Type the following in the terminal :
    - **flutter pub get**
* Now open your **android** emulator or connect your **android** device.
* To run the code, go to the terminal and type : 
    - **flutter run --no-sound-null-safety**
    - Firebase ML SDK doesn't support sound null safety. 

## Features of Engage 360
### ‣ Face Recognition Based Authentication System 
For Authentication, the **Azure Face Api** was used and for painting the box around the face in real-time, the **Firebase ML Vision SDK** was used.

* **Signup** : 
    * The user first needs to click an image of his face. The image is then sent to **Face Detection Api** which returns us a **faceId** which is later used to verify the user. 
    * After that the user needs to enter his **name** & **phone number** and all these datas are then stored in the **database** & the user is signed in. 

* **Login** : 
    * The user first needs to enter his phone number using which we **query the database** to see if the user already exist or not. 
    * If user exist, then he needs to click an image of his face & now this image is sent to the **Face Detection Api** to get a faceId. 
    * Then this faceId and the faceId from the database is sent to **Face Verification Api**. If the face matches, the user is logged in. 

|![](https://github.com/aditya3901/aditya3901/blob/main/Engage-360/pic_4.png)|![](https://github.com/aditya3901/aditya3901/blob/main/Engage-360/pic_5.png)|![](https://github.com/aditya3901/aditya3901/blob/main/Engage-360/pic_6.png)|![](https://github.com/aditya3901/aditya3901/blob/main/Engage-360/pic_7.png)|
|-|-|-|-|
<br>

### ‣ Automated Attendance System during Video Call Meetings &nbsp;⭐
For Video Calling, the **Agora WebRTC** Engine was used which provides integrated **Face Detection Callback** to monitor face during video call. For storing data, the **Firebase Database** was used. There are two ways to join a meeting and each way has its own separate roles: 

* **Host** : The Host needs to create a new Room and share the Room-Id with the attendees.
* **Attendee** : The Attendee joins the room using the room-id from the host. 
* During the entire duration of the meet, the **face of the attendee gets monitored**.
    * At any point of the meet, if the **face of the attendee is not detected**, he is given a warning and his **violation counter is increased by +1**.
* If the violation counter reaches 3, he'll be **removed from the room** and marked as **absent**.
* When the host leaves, everyone else is removed from the room and all those who were in the meet till then will be marked as **present**. 

|![](https://github.com/aditya3901/aditya3901/blob/main/Engage-360/pic_8.png)|![](https://github.com/aditya3901/aditya3901/blob/main/Engage-360/pic_9.png)|![](https://github.com/aditya3901/aditya3901/blob/main/Engage-360/pic_10.png)|![](https://github.com/aditya3901/aditya3901/blob/main/Engage-360/pic_11.png)|
|-|-|-|-|
<br>

### ‣ Online Exam Proctoring | Cheating Detection System &nbsp;&nbsp;⭐&nbsp;⭐
The main idea behind this was that during online interviews/exams, the video, audio and screen of the candidate is already shared over the video calling platforms like G-meet or MS-Teams. But the proctor has to manually check the candidate's face to see whether he's cheating.

Here Engage 360 comes into play. During the entire duration of the test, the face of the candidate is monitored through the app. Here's more details about it: 

* Before entering the test, the candidate has to **verify his face** by clicking an image. This prevents proxy test attempts.
* Once started, the face of the candidate is constantly monitored.
* At any time during the test, if the **face is not detected**, the candidate will be **immediately disqualified**. 

Since the video, audio and screen of the candidate is already shared over the video calling platforms, there's only **3 places around him** from where he can cheat. Either by looking down at his phone/notes or by looking left or right.

* If the candidate **tries to look down**, he'll be shown a warning and his violation counter will be increased.
* If the candidate **rotates his head left or right frequently**, he'll be shown a warning and his violation counter will be increased.
* If the violation counter reaches 3, the candidate will be **disqualified**.

|![](https://github.com/aditya3901/aditya3901/blob/main/Engage-360/pic_12.png)|![](https://github.com/aditya3901/aditya3901/blob/main/Engage-360/pic_13.png)|![](https://github.com/aditya3901/aditya3901/blob/main/Engage-360/pic_14.png)|![](https://github.com/aditya3901/aditya3901/blob/main/Engage-360/pic_15.png)|
|-|-|-|-|
<br>

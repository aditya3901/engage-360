<!-- PROJECT LOGO -->
<div align=center>
    <img width=200 src="https://github.com/aditya3901/engage-360/blob/master/assets/images/appicon.png" alt="Logo" width="200" height="200">
    <h1>Engage 360</h1>
    <a href="https://madewithlove.org.in" target="_blank">Made with <span style="color: #e74c3c">&hearts;</span> in India</a>
</div>

## About The Project

Engage 360 is your one-stop solution for everything related to Video Meetings & Online Exam Monitoring! Engage 360 provides services such as <b>Face Recognition Based Authentication System, Automated Attendance System during Live Video Call Meetings, Online Exam Proctoring System</b> and much more.


## Built With

Here's a curated list of all the major technologies that have been used to build Engage 360: 

* <b>[Flutter](https://flutter.dev/)</b> : For building the UI of the app
* <b>[Dart](https://dart.dev/)</b> : For building the backend of the app
* <b>[Azure Face Api](https://azure.microsoft.com/en-in/services/cognitive-services/face/)</b> : For Detecting and Verifying Face of the User
* <b>[Firebase ML Vision](https://developers.google.com/ml-kit/vision/face-detection)</b> : For Detecting Face in real-time from Camera Stream
* <b>[Agora WebRTC](https://www.agora.io/en/)</b> : For implementing the Video Calling Feature
* <b>[Firebase Database](https://firebase.google.com/docs/database)</b> : For Storing User's Data and other app events

## Features of Engage 360
### # Face Recognition Based Authentication System

* **Signup** : The user first needs to click an image of his face. The image is then sent to **Face Detection Api** to detect face from the image and return us a faceId which is later used for verifying the user. After that the user needs to enter his name and phone number and all these datas are then stored in the database and the user is signed in. 

* **Login** : The user first needs to enter his phone number using which we query the database to see if the user already exist or not. If user exist, then the user needs to click an image of his face and now his image is again sent to the **Face Detection Api** to get a faceId and then this faceId and the faceId from the database is sent to **Face Verification Api** to verify the user. If the face matches, the user is logged in. 

|![](https://github.com/aditya3901/aditya3901/blob/main/Engage1.png)|![](https://github.com/aditya3901/aditya3901/blob/main/Engage3.png)|![](https://github.com/aditya3901/aditya3901/blob/main/Engage2.png)|![](https://github.com/aditya3901/aditya3901/blob/main/Engage4.png)|
|-|-|-|-|

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

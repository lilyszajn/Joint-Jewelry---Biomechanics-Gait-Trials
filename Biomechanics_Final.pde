import processing.net.*;
import SimpleOpenNI.*;  //middleware to execute skeleton tracking
SimpleOpenNI kinect;
import java.lang.Runtime;
import processing.video.*; //to run the intro video

int[] userMap;
PImage backgroundImage; //background image

PVector prevRightHandLocation;
PVector prevLeftHandLocation;
PVector prevRightKneeLocation;
PVector prevLeftKneeLocation;
PVector prevRightHipLocation;
PVector prevLeftHipLocation;
PVector prevRightFootLocation;
PVector prevLeftFootLocation;
PVector prevRightShoulderLocation;
PVector prevLeftShoulderLocation;


PVector rightHandLocation2D;
PVector leftHandLocation2D;
PVector rightKneeLocation2D;
PVector leftKneeLocation2D;
PVector rightHipLocation2D;
PVector leftHipLocation2D;
PVector rightFootLocation2D;
PVector leftFootLocation2D;
PVector rightShoulderLocation2D;
PVector leftShoulderLocation2D;

//PVector shoulderAvg; 
//PVector feetAvg;
//PVector kneeAvg;


int r = 255;
int g = 255;
int b = 255;

float finalScore = 0;

float testTime = 10000;
float timeLeft = 0;
float startTime = 0;

//no calibration
boolean autoCalib=true;

ArrayList<Float> rightKneeToFoot = new ArrayList();
ArrayList<Float> rightHipToKnee = new ArrayList();
ArrayList<Float> leftHipToKnee = new ArrayList();
ArrayList<Float> leftKneeToFoot = new ArrayList();
ArrayList kneeList = new ArrayList();
Date d = new Date(); //for saving the csv file

void setup() { 

  //load the background image
  //background(255);
  scale(2);
  kinect = new SimpleOpenNI(this); //create kinect object
  kinect.enableDepth(); //enable the depth image
  kinect.enableRGB(); //display color video feed of user rather than depth image
  kinect.enableUser(SimpleOpenNI.SKEL_PROFILE_ALL);
  kinect.alternativeViewPointDepthToImage(); //turn on depth color alignment


  size(640, 480); 

  //initialize joint location objects as vectors
  prevRightHandLocation = new PVector(0, 0, 0);
  prevLeftHandLocation = new PVector(0, 0, 0);
  prevRightKneeLocation = new PVector(0, 0, 0);
  prevLeftKneeLocation = new PVector(0, 0, 0);
  prevRightHipLocation = new PVector(0, 0, 0);
  prevLeftHipLocation = new PVector(0, 0, 0);
  prevRightFootLocation = new PVector(0, 0, 0);
  prevLeftFootLocation = new PVector(0, 0, 0);
  prevRightShoulderLocation = new PVector(0, 0, 0);
  prevLeftShoulderLocation = new PVector(0, 0, 0);
}


void draw() { 
  //set up the kinect part
  //scale(2);
  PImage rgbImage = kinect.rgbImage();
  //image(rgbImage, 0, 0,1280,960);
  //load the background image
  background(255);
  kinect.update(); 
  //image(depthImage, 0, 0);

  //image(kinect.depthImage(), 0, 0);

  IntVector userList = new IntVector(); 
  kinect.getUsers(userList);

  if (userList.size() > 0) { 
    int userId = userList.get(0);

    if (kinect.isTrackingSkeleton(userId)) { 
      //display the user's image
      //prepare the color pixels

      image(rgbImage, 0, 0, width, height);

      /* millis() start after calibration has happened
       if (startTime == 0) {
       startTime = millis();
       //startTime = millis();
       println("START TIME" + startTime);
       }*/

      drawSkeleton(userId);


      // make a vector to store the right knee
      PVector rightKneeLocation = new PVector();
      // put the position of the left hand into that vector
      float confidence = kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_KNEE, rightKneeLocation); 
      // make a vector to store the left knee
      PVector leftKneeLocation = new PVector();
      // put the position of the left knee into that vector
      kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, leftKneeLocation); 
      //make a vector to store the left hip
      PVector leftHipLocation = new PVector();
      // put the position of the left hip into that vector
      kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_HIP, leftHipLocation); 
      //right hip vector
      PVector rightHipLocation = new PVector();
      // put the position of the right hip into that vector
      kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_HIP, rightHipLocation); 
      //vector for feet locations
      PVector leftFootLocation = new PVector();
      // put the position of the lef`t hip into that vector
      kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_FOOT, leftFootLocation); 
      //right hip vector
      PVector rightFootLocation = new PVector();
      // put the position of the right hip into that vector
      kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_FOOT, rightFootLocation); 

      rightKneeToFoot.add(rightFootLocation.dist(rightKneeLocation)); //averages the knee to foot distance
      leftKneeToFoot.add(leftFootLocation.dist(leftKneeLocation));
      rightHipToKnee.add(rightHipLocation.dist(rightKneeLocation)); //distance of shoulders to feet if position should be 0 in ideal scenario
      leftHipToKnee.add(leftHipLocation.dist(leftKneeLocation));

      String[] myString = new String[rightKneeToFoot.size()];
      for (int i = 0; i < rightKneeToFoot.size(); i++) {
        float currentRightKnee= rightKneeToFoot.get(i);
        float currentRightHip = rightHipToKnee.get(i);
        float currentLeftKnee = leftKneeToFoot.get(i);
        float currentLeftHip = leftHipToKnee.get(i);
        myString[i] = abs(currentRightKnee) + "," + abs(currentRightHip) + "," + abs(currentLeftKnee) + "," + abs(currentLeftHip);
      }
      println(d.toString());
      saveStrings("Test" + d + ".csv", myString); //save all answers into a text file

      /*//figure out the distance between the current location and previous location of the knees
       float currentScore = (rightKneeLocation2D.dist(prevRightKneeLocation) + leftKneeLocation2D.dist(prevLeftKneeLocation));
       
       fill(255, 50, 70);
       text("Knee Distance: " + currentScore, 10, 10);*/
    }

    prevRightKneeLocation = rightKneeLocation2D;
    prevLeftKneeLocation = leftKneeLocation2D;
    prevRightHipLocation = rightHipLocation2D;
    prevLeftHipLocation = leftHipLocation2D;
    prevRightFootLocation = rightFootLocation2D;
    prevLeftFootLocation = leftFootLocation2D;
    prevRightShoulderLocation = rightShoulderLocation2D;
    prevLeftShoulderLocation = leftShoulderLocation2D;
  }
}

float angleOf(PVector one, PVector two, PVector axis) {
  PVector limb = PVector.sub(two, one);
  return degrees(PVector.angleBetween(limb, axis));
}


void drawSkeleton(int userId) { 
  stroke(0); 
  strokeWeight(2);
  /*kinect.drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK); 
   kinect.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_LEFT_SHOULDER); 
   kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW); 
   kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND); 
   kinect.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_RIGHT_SHOULDER); 
   kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW); 
   kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND); 
   kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_TORSO); 
   kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_TORSO); 
   kinect.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_LEFT_HIP); 
   kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HIP, SimpleOpenNI.SKEL_LEFT_KNEE);
   kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_KNEE, SimpleOpenNI.SKEL_LEFT_FOOT); 
   kinect.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_RIGHT_HIP); 
   kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_RIGHT_KNEE); 
   kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, SimpleOpenNI.SKEL_RIGHT_FOOT); 
   kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_LEFT_HIP);
   
   noStroke();*/

  fill(r, 0, 0); 
  drawJoint(userId, SimpleOpenNI.SKEL_HEAD); 
  drawJoint(userId, SimpleOpenNI.SKEL_NECK); 
  drawJoint(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER); 
  drawJoint(userId, SimpleOpenNI.SKEL_LEFT_ELBOW); 
  drawJoint(userId, SimpleOpenNI.SKEL_NECK); 
  drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER); 
  drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW); 
  drawJoint(userId, SimpleOpenNI.SKEL_TORSO); 
  drawJoint(userId, SimpleOpenNI.SKEL_LEFT_HIP); 
  drawJoint(userId, SimpleOpenNI.SKEL_LEFT_KNEE); 
  drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_HIP); 
  drawJoint(userId, SimpleOpenNI.SKEL_LEFT_FOOT); 
  drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_KNEE); 
  drawJoint(userId, SimpleOpenNI.SKEL_LEFT_HIP); 
  drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_FOOT); 
  drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_HAND); 
  drawJoint(userId, SimpleOpenNI.SKEL_LEFT_HAND);
}

void drawJoint(int userId, int jointID) { 
  PVector joint = new PVector(); 
  float confidence = kinect.getJointPositionSkeleton(userId, jointID, joint); 
  if (confidence < 1) {
    return;
  } 
  PVector convertedJoint = new PVector(); 
  kinect.convertRealWorldToProjective(joint, convertedJoint); 
  ellipse(convertedJoint.x, convertedJoint.y, 20, 20);
}

// user-tracking callbacks!
void onNewUser(int userId)
{
  println("onNewUser - userId: " + userId);
  println("  start pose detection");

  if (autoCalib)
    kinect.requestCalibrationSkeleton(userId, true);
  else    
    kinect.startPoseDetection("Psi", userId);
}

void onLostUser(int userId)
{
  println("onLostUser - userId: " + userId);
}


void onEndCalibration(int userId, boolean successful) {
  if (successful) { 
    println("  User calibrated !!!");
    kinect.startTrackingSkeleton(userId);
  } 
  else { 
    println("  Failed to calibrate user !!!");
    kinect.startPoseDetection("Psi", userId);
  }
}
void onStartPose(String pose, int userId) { 
  println("Started pose for user"); 
  kinect.stopPoseDetection(userId); 
  kinect.requestCalibrationSkeleton(userId, true);
}


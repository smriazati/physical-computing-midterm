import netP5.*;
import oscP5.*;

OscP5 oscP5;
//NetAddress myRemoteLocation;


//MISC

int screenWidth = 1000;
int strokeweight = 2;

int delayTime = 50;
int timer = millis();
int last = 0;
int startscreentime;

PFont f;

boolean startTheDrawing = false;
boolean pauseTheDrawing = false;

PImage startImg1;
PImage startImg2;

// COLOR
color redValue = 0;
color greenValue = 0;
color blueValue = 0;

boolean redState = false;
boolean greenState = false; 
boolean blueState = false;

String redIsOn = "RY";
String greenIsOn = "GY";
String blueIsOn = "BY";

String redIsOnMessage = "";
String greenIsOnMessage = "";
String blueIsOnMessage = "";


// ACCEL
float xValue;
float yValue;
float zValue;

float posX;
float posY;

FloatList positionsX;
FloatList positionsY;

int listlengthX;
int listlengthY;

float currentX = screenWidth/2;
float currentY = screenWidth/2;

float prevX;
float prevY;

    
void setup() {
  size(1000, 1000);
  oscP5 = new OscP5(this,1234);

  textAlign(CENTER);

  background(0);
  stroke(redValue,greenValue,blueValue);
  strokeWeight(strokeweight);
  f = createFont("Arial",16,true); // Arial, 16 point, anti-aliasing on
  startImg1 = loadImage("start1.jpg");
  startImg2 = loadImage("start2.jpg");


  // create the list
  positionsX = new FloatList();
  positionsY = new FloatList();
  
  //myRemoteLocation = new NetAddress("192.168.0.3",8001);

}


void draw() {
  
  timer = millis();
  
  
  if (startTheDrawing == false) {
    startScreen();
    startscreentime = millis();
  } 
  
 
  if (keyPressed) {
    if (key == 'k' || key == 'K') {
      background(0);
      pauseTheDrawing = false;
      timer = 0;
      last = millis() - startscreentime;
    } 
  } 
  if (startTheDrawing && !pauseTheDrawing) {

    lineDrawer();
    colorPicker();
      
    if (keyPressed) {
      if (key == 's' || key == 'S') {
        endScreen();
        pauseTheDrawing = true;
      }
    } 
  } 
}

void lineDrawer() {
    posX = map(xValue,-300,300,0,screenWidth);
    posY = map(yValue,-300,300,0,screenWidth);
  
  // if you're using accel values
  //posX = map(xValue,-1,1,0,screenWidth);
  //posY = map(yValue,-1,1,0,screenWidth);
  
  if (posX >= 0) {
    prevX = currentX;
    positionsX.append(posX);
    listlengthX = positionsX.size();
    currentX = positionsX.get(listlengthX-1);
  }
  if (posY >= 0) {
    prevY = currentY;
    positionsY.append(posY);
    listlengthY = positionsY.size();
    currentY = positionsY.get(listlengthY-1);
  }

  // now DRAW THE LINE
  line(currentX, currentY, prevX, prevY);
  //println("currentX: " + currentX +", currentY: " + currentY + ", prevX: " + prevX +", prevY: " + prevY);  
}

void colorPicker() {
  boolean isRedOn = redIsOnMessage.equals(redIsOn);
  boolean isGreenOn = greenIsOnMessage.equals(greenIsOn);
  boolean isBlueOn = blueIsOnMessage.equals(blueIsOn);

  if (isRedOn) {
    delay(delayTime);
    redValue = 255;  
  } 
  if (isRedOn == false) {
    delay(delayTime);
    redValue = 0;  
  }  

  if (isBlueOn) {
    delay(delayTime);
    blueValue = 255;  
  } 
  if (isBlueOn == false) {
    delay(delayTime);
    blueValue = 0;  
  }  

  if (isGreenOn) {
    delay(delayTime);
    greenValue = 255;  
  } 
  if (isGreenOn == false) {
    delay(delayTime);
    greenValue = 0;  
  }  


  //update stroke values
  stroke(redValue,greenValue,blueValue);

  // show feedback, current color as a circle
  fill(redValue, greenValue,blueValue);
  ellipse(40,40,40,40);
}

void startScreen() {
    background(255);
    fill(0);
    textFont(f,36);
    
    String start1 = "Welcome to RGB!";
    String start2 = "Press the buttons on the controller to change the pen color.";
    String start2b = "Try turning on multiple buttons at once to create a more interesting palette.";
    String start3 = "Press the S key on the keyboard to save your drawing and clear the screen.";
    String start4 = "Press the L key to start drawing";
    
    text(start1,screenWidth/2,screenWidth-900);
    
    textFont(f,24);
    text(start2,screenWidth/2,screenWidth-750);
    image(startImg1,(screenWidth-startImg1.width)/2,screenWidth-735);
    text(start2b,screenWidth/2,screenWidth-540);
    image(startImg2,(screenWidth-startImg2.width)/2,screenWidth-515);
    text(start3,screenWidth/2,screenWidth-300);

    textFont(f,36);
    text(start4,screenWidth/2,screenWidth-100);
    
    if(keyPressed) {
      if ( key == 'l' || key == 'L') {
          startTheDrawing = true;
          println("start the drawing");
          background(0);
          pauseTheDrawing = false;
       
      }
    }
}

void endScreen() {

    fill(0,0,0,95);
    rect(0,0,screenWidth,screenWidth);
    
    fill(0);
    stroke(0);
    ellipse(40,40,50,50);
  
    stroke(255);
    line(250,25, 250, 650);
    line(250,650,750,650);
    line(750,650,750,25);
    line(750,25,250,25);
    
   // add this string to screen
  
    String end1 = "You have been drawing for ";
    float currentTime = (timer-last-startscreentime)/1000; 
    String end2 = "seconds";
  
    String end3 = "You have received ";
    float currentBytesReceived = currentTime*.2;
    String end4 = "bytes of data.";

    String end5 = "You have created ";
    float currentBytesCreated = currentTime*3.7;
    String end6 = "bytes of data.";
    
    //String endCTA1 = "What happens next?";
    //String endCTA2 = "";
    
    String end7 = "Press the K key to draw again.";
    
    textFont(f,36);
    fill(255);

    text(end1,screenWidth/2,100);
    fill(255,230,0);
    text(currentTime,screenWidth/2,150);
    fill(255);
    text(end2,screenWidth/2,200);

    text(end3,screenWidth/2,300);
    fill(0,255,230);
    text("~ "+currentBytesReceived,screenWidth/2,350);
    fill(255);
    text(end4,screenWidth/2,400);
    
    text(end5,screenWidth/2,500);
    fill(230,0,255);
    text("~ "+currentBytesCreated,screenWidth/2,550);
    fill(255);
    text(end6,screenWidth/2,600);
    
    // save the image before instructions appear
    println("image saved!");
    saveFrame("line-######.png");
    
    textFont(f,24);
    text(end7,screenWidth/2,screenWidth-100);

}


/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {
  if(theOscMessage.checkAddrPattern("/photon")==true){
    

    redIsOnMessage = theOscMessage.get(0).stringValue();
    greenIsOnMessage = theOscMessage.get(1).stringValue();
    blueIsOnMessage = theOscMessage.get(2).stringValue();
    //println("OSC colors-- red: "+redIsOnMessage+"  green:  " + greenIsOnMessage+"  blue:  " + blueIsOnMessage);    

    xValue = theOscMessage.get(3).floatValue();    
    yValue = theOscMessage.get(5).floatValue();    
    zValue = theOscMessage.get(4).floatValue();
    println("OSC accel values-- x:  " + xValue+"  y: "+yValue+"  z:  " + zValue);    
  
    return;
  }
}

  
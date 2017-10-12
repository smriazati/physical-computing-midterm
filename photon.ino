// This #include statement was automatically added by the Particle IDE.
#include <SparkFunMMA8452Q.h>

// This #include statement was automatically added by the Particle IDE.
#include <simple-OSC.h>

// // Important to avoid green light (bc of while loops i think)
// SYSTEM_THREAD(ENABLED);

// initialize LED & btn pins
int blueLed = D5; 
int greenLed = D6;
int redLed = D7;
int blueBtn = D2;
int greenBtn = D3;
int redBtn = D4;

// create variables for button toggles
int blueStatus = false;
int greenStatus = false;
int redStatus = false;

String blueMessage;
String greenMessage;
String redMessage;

int delayTime = 50;


// particle messaging
String robMessage;

// The below works if the MMA8452Q's address select pin (SA0) is high.
// If SA0 is low (if the jumper on the back of the SparkFun MMA8452Q breakout
// board is closed), initialize it like this:
// MMA8452Q accel(MMA8452Q_ADD_SA0_); 
MMA8452Q accel; // Default constructor, SA0 pin is HIGH

// OSC set up
UDP udp;

// 192.168.0.3
IPAddress outIp(192, 168, 0, 3);//your computer IP

// campus 10.196.30.97
// 10.193.0.144
//IPAddress outIp(10,193,0,144);

unsigned int outPort = 1234; //computer incoming port
unsigned int inPort = 8001;

void setup() {
    Serial.begin(115200); // faster data rate
    udp.begin(inPort);//necessary even for sending only.
    Serial.println("");
    Serial.println("WiFi connected");
    IPAddress ip = WiFi.localIP();

    // Full-scale range can be: SCALE_2G, SCALE_4G, or SCALE_8G (2, 4, or 8g)
    // ODR can be: ODR_800, ODR_400, ODR_200, ODR_100, ODR_50, ODR_12, ODR_6 or ODR_1
    accel.begin(SCALE_8G, ODR_800); 

    pinMode(blueLed, OUTPUT); 
    pinMode(greenLed, OUTPUT);
    pinMode(redLed, OUTPUT); 
  
    pinMode(blueBtn, INPUT_PULLUP); 
    pinMode(greenBtn, INPUT_PULLUP);
    pinMode(redBtn, INPUT_PULLUP); 
 
    Particle.subscribe("rob-sarah-physcomp-midterm-42", listeningToPartner);
    
}



void loop() { 


    // message to photon channel
    
    


    // buttons
    
    // BLUE 
    // toggle btn status with btn press, and toggle LED value
    if (digitalRead(blueBtn) == true) { 
        blueStatus = !blueStatus; 
        digitalWrite(blueLed, blueStatus); 
        Particle.publish("rob-sarah-physcomp-midterm-42", "blue");
    } 
    while(digitalRead(blueBtn) == true); 
    delay(delayTime);

    // Green 
    // toggle btn status with btn press, and toggle LED value
    if (digitalRead(greenBtn) == true) { 
        greenStatus = !greenStatus; 
        digitalWrite(greenLed, greenStatus); 
        Particle.publish("rob-sarah-physcomp-midterm-42", "green");
    } 
    while(digitalRead(greenBtn) == true); 
    delay(delayTime);

    // RED 
    // toggle btn status with btn press, and toggle LED value
    if (digitalRead(redBtn) == true) { 
        redStatus = !redStatus; 
        digitalWrite(redLed, redStatus); 
        Particle.publish("rob-sarah-physcomp-midterm-42", "red");
    } 
    while(digitalRead(redBtn) == true); 
    delay(delayTime); 


    // OSC MESSAGE KEY
    // 6 STRINGS (RY/RN, GY/GN, BY/BN, X, Y, Z)

    if (blueStatus) {
        blueMessage = "BY";
    } else {
        blueMessage = "BN";
    }    

    if (greenStatus) {
        greenMessage = "GY";
    } else {
        greenMessage = "GN";
    } 

    if (redStatus) {
        redMessage = "RY";
    } else {
        redMessage = "RN";
    } 

    OSCMessage outMessage("/photon");

	// add color data to the message
    outMessage.addString(redMessage);
    outMessage.addString(greenMessage);
    outMessage.addString(blueMessage);
 
	// add accel data to the message, has to be in conditional
    if (accel.available())
    {
		// To update acceleration values from the accelerometer, call accel.read();
        accel.read();
		
		// After reading, six class variables are updated: x, y, z, cx, cy, and cz.
		// Those are the raw, 12-bit values (x, y, and z) and the calculated
		// acceleration's in units of g (cx, cy, and cz).
        outMessage.addFloat(accel.cx);
        outMessage.addFloat(accel.cy);
        outMessage.addFloat(accel.z);
    }
    
    
    // finish the message
    outMessage.send(udp,outIp,outPort);


}





void listeningToPartner(const char *event, const char *data) {
    robMessage = data;
    
    if (robMessage == "button pressed") {
        Particle.publish("rob-sarah-physcomp-midterm-42","I see the button press");
        
        redStatus = false;
        blueStatus = false;
        greenStatus = false;
    }
}




# Midterm IoT Project

Name: Sarah Riazati

Date: Thursday, October 12

## Project: RGB Game

<img src="images/drawing1.png" width="300px">

### A drawing game...
**How to play:** RGB is a simple drawing game with a physical controller. The player can activate the red, green and blue buttons to adjust the color of the digital pen. The player moves the game controller in all directions to draw a line. Pressing any key on the keyboard saves the drawing and clears the screen.

#### ...with a twist? 

Players might be surprised when they look at the saved drawing, because an additional stamp of text information will overlay on top of their artwork. The overlay contains a message about how much data the game play created, and how that translates to kilowatt hours of electricity. 

	* You have been drawing for ___ seconds.
	* You have received approximately ____ bytes of data. 
	* You have created approximately ____ bytes of data. 

#### Why? 
RGB is a somewhat pointless game. You can't win, and it's nearly impossible to use the game to draw a realistic or intentional drawing. The experience of playing RGB may be enticing because of the unexpected interactivity of the DIY physical controller. Eventually, most players will grow bored of the novelty. Only after the gameplay is over will the player realize the true point of the game: even the most mindless digital activities require real, physical resources that come from the planet we all live on together.

#### Also... 

My Photon is listening for a message from my partner Rob's Photon. When my Photon hears the message "button pressed" in the "rob-sarah-physcomp-midterm-42" event, all of the buttons in the drawing game are automatically turned off. A button press on Rob's game sends data through his Photon to Blynk. To counteract this extra data, my Photon goes dark. 

## Technical details

### The Circuit

Start with a particle photon redboard wired like this:

<img src="images/fritzing_diagram.jpg" width="600px">

The photon is collecting sensor from the accelerometer and the three push buttons. It is sending sensor data back out to the three LEDs. Together, this creates two systems: one for color picking and one for location sensing system. 

The color picker works based off of three buttons on the breadboard, set to control the red, green and blue values of the drawing line. We also have LEDs on the breadboard to serve as feedback for which color is "on".

### The Photon Code

#### The color picker 
In the photon code loop function, we read the signal from each button. If the button is pressed, we change the color's status (set to *false* by default) to the opposite. For example, when the green button is pressed, we do this toggle:

	        greenStatus = !greenStatus; 

And if the greenStatus = true, the corresponding LED turns on.

	        digitalWrite(greenLed, greenStatus); 

Most importantly, the photon code adds info to the OSC message depending on the color status. 

    		if (greenStatus) {
        		greenMessage = "GY";
    		} else {
        		greenMessage = "GN";
    		} 	

The Processing sketch is listening for each of the messages, waiting to adjust the stroke color value accordingly. But more on that later...


#### The accelerometer 

The accelerometer works based on the SparkFunMMA8452Q library. At the beginning of the code, we create an accelerometer object:
	
	MMA8452Q accel
	
In the set up function, we use the begin method and pass in parameters so it sends lots of data quickly, so we can draw a better line. 

    accel.begin(SCALE_8G, ODR_800); 


In the loop function, we read the accel data and write the float values of x, y and z into the OSC message.

    if (accel.available())
    {
        accel.read();
		
        outMessage.addFloat(accel.x);
        outMessage.addFloat(accel.y);
        outMessage.addFloat(accel.z);
    }

Now  we have constructed an OSC message with three strings (R,G,B) and three floats (x,y,z). We're ready to dive into Processing, where we'll take this info and make a drawing.

<a href="photon.ino">View the full photon code here.</a>



### The Processing Sketch


In Processing, we can grab the OSC message from the Photon and use the message's values to determine the stroke RGB color values, and the x and y positions to draw the line. 

We parse the OSC message and assign its messages into relevant variables, i.e. redIsOnMessage, xValue, etc.

	void oscEvent(OscMessage theOscMessage) {
    	if(theOscMessage.checkAddrPattern("/photon")==true){
  
    		redIsOnMessage = theOscMessage.get(0).stringValue();
    		greenIsOnMessage = theOscMessage.get(1).stringValue();
    		blueIsOnMessage = theOscMessage.get(2).stringValue();

    		xValue = theOscMessage.get(3).floatValue();    
    		yValue = theOscMessage.get(4).floatValue();    
    		zValue = theOscMessage.get(5).floatValue();
  
    		return;
  		}
	}


#### The Color Picker

In the draw loop, we use boolean values and conditional statements to check which buttons are on. For example, to check if we are receiving a message of "RY" (red is on) vs. "RN" (red is off):

	  String redIsOn = "RY"
      boolean isRedOn = redIsOnMessage.equals(redIsOn);
      
      if (isRedOn) {
        delay(delayTime);
        redValue = 255;  
     } 
      if (isRedOn == false) {
        delay(delayTime);
        redValue = 0;  
      }  
      
Then, we can use the updated redValue to change the stroke color and draw a circle of that color, for feedback:

  	stroke(redValue,greenValue,blueValue);

  	fill(redValue, greenValue,blueValue);
	ellipse(40,40,40,40);

      
#### The line

To draw the line, we take the float info now stored from OSC into xValue and yValue, and we use these messages to create a Floatlist to draw the line. *In future versions we could use z to do something too, or even cx, cy and cz (acceleration)*.

First, declare all the variables:
	
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

In the setup loop, create the Floatlists:

    positionsX = new FloatList();
    positionsY = new FloatList();

In the draw loop, map the floats from the OSC message to bigger floats that better match the screen size. Append each new mapped position to the Float list, and measure the length of the list. Because we're using a list, we can always determine the ultimate and penultimate values in the float list, and we can use each of those as the *currentX*, *currentY*, *prevX* and *prevY* values that we need to draw a continuous line. 
  
    posX = map(xValue,-200,200,0,screenWidth);
    posY = map(yValue,-200,200,0,screenWidth);
    
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


<a href="rgbgame/rgbgame.pde">View the full Processing code here.</a>


#### How does the game calculate my data? 

I used a timer to review the network usage of my Processing sketch using Activity Monitor. I estimated that the Processing sketch receives roughly .2 KB of data / second via the OSC message from the Photon. So, there 6KB of data are transferred if a player plays for 30 seconds. 

What about the "data created" calculation? I used the timer info and the final image's file size of a group of 15 different images, and calculated an average game play time of 26.5 seconds, creating a file size average of 98.1 KB. 
	
	98.1 KB / 26.5 seconds = 3.7 KB / second

In the current version, since the drawings are saved locally on the laptop's hard drive,  the created data technically never "touches" the cloud. In a future version, the footprinted drawings would be automatically posted on a public social channel. 


#### Why not tell me more?   

The internet requires a massive infrastructure, and the full physical impact of the resources it requires to operate would be difficult to measure. For this reason, the final footprint succinctly points out that data was created and received, and the unexpected appearance of the footprint is sufficient surprise to trigger a memorable experience for the player. In a future version of the game, these metrics could even affect the success or function of the drawing game. 
 

## Conceptual background

>Is multi-tabbed browsing the IT equivalent of leaving the refrigerator door open?

It's easy to forget that the electrical impact of internet browing spans far beyond the impact of charging a smartphone. In fact, the entire infrastructure of the internet relies on electronics, which rely on electricity. 

Let's follow an example, paraphrased from <a href="http://aceee.org/files/proceedings/2012/data/papers/0193-000409.pdf">The Megawatts behind Your Megabytes</a> 

>An example transmission activity might begin on a desktop computer when an end user requests to download a song. That request gets converted into **packets** that are sent to their wireless router and then through a **fiber optic line** to a local **internet service provider (ISP)**, a Tier 3 **Point of Presence (POP)**. Once the ISP processes the packet, it sends it along, up to a **Tier 2 POP** through a fiber optic cable with more bandwidth. The packet with the request might then be passed up to a **Tier 1 POP** and shuttled across the country before hopping back down to a lower tier POP to find the **data center** where the song is stored... All of the sends and receives at the carrier nodes are brokered by **routers, switches, or hubs**; each humming with the electronics of their own processers and overhead loads such as cooling, power conditioning, and lighting.  Additionally, when fiber optic, copper-wire, or wireless communication links must span long distances, the signal degrades and must be regenerated periodically by **repeaters**, each of which adds to the energy footprint of the activities. Once the signal finally arrives at the data source, the download begins, sending the song in packets back to the original requester by way of the same process in reverse.
 
This same white paper projects that the average energy draw of worldwide internet is 141 billion kilowatt hours. Of that total, 38% of that load is on end user devices and 48% is from network data centers & servers. These projected numbers are from 2011, and have assuredly increased in the past 6 years.

In 2016, a report from the DOE's Lawrence Berkeley National Laboratory estimates that the US-based data centers used about 70 billion kilowatt hours. That's just the data centers in the United States alone! 

So, the internet takes up a lot of power to run. But how much data are we actually moving around as we browse, stream and download?  

A 2016 report from 
<a href="https://www.cisco.com/c/en/us/solutions/collateral/service-provider/visual-networking-index-vni/complete-white-paper-c11-481360.html?referring_site=RE&pos=1&page=https://www.cisco.com/c/en/us/solutions/collateral/service-provider/visual-networking-index-vni/mobile-white-paper-c11-520862.html#_Toc484813985">Cisco</a> reported the total consumer internet traffic to be 58,630 petbytes a month, or 703.56 exabytes a year. (1 petabyte is equal to 1 million gigabytes. 1000 petabytes equals 1 exabyte.) This number steadily increases year to to year. <a href="https://www.nytimes.com/2016/07/01/business/media/nielsen-survey-media-viewing.html">According to Nielsen</a>, the average American adult spends 10 hours 39 minutes a day consuming digital media in 2016, up one hour from 2015. 

 
### What about all the web browsing *you* did to make this project? 
 
I reviewed my browsing history and estimated the number of sites I visited to research my project. Using the time stamps, I was also able to estimate the amount of time spent researching so far. Until Monday 10/9 at 5PM, I spent nearly 9 hours online for this project, visiting **nearly 600 websites**. My conservative estimate for browsing habits is that I visited just over 1 site / minute, on average. <a href="http://www.httparchive.org/interesting.php?a=All&l=Sep%2015%202017">According to the HTTP Archive</a>, the average size of a website is 3.376 MB.

	3376 kb * 600 sites = 2025600 kb total 

That's just over 2GB in data downloaded for this project, and it's is a conservative estimate. It does not account for data *sent* from my computer to other servers, and it doesn't account for the weight of streaming video tutorials (thanks <a href="https://www.youtube.com/user/shiffman">Coding Train!</a>). That's a lot of data!
 

## Form & Enclosure 

<img src="images/rgbinplay.jpg" width="600px" />

RGB Game lives inside a recycled cardboard boxed. In this prototype, the electronics are visible and it's possible to remove/replace the Photon & breadboard without destroying the enclosure. 

<img src="images/enc-1.jpg" width="600px" />
<img src="images/enc-2.jpg" width="600px" />
<img src="images/enc-3.jpg" width="600px" />
<img src="images/enc-4.jpg" width="600px" />
<img src="images/enc-5.jpg" width="600px" />

### What's next? 

In a future version of this project, I would ditch the breadboard and embed the buttons and LEDs directly in the enclosure. I would add an additional button for starting / saving / resetting the game, to replace the need for keyboard presses. I might even add in a speaker, so the game could play a varying tone based on information from the accelerometer! 

<img src="images/future1.jpg" width="300px"/>

Here are some other things I would continue to improve: 

* Automatically post each final, overlaid drawing from Processing to a Flickr account
* The caption of the Flickr image would include further information about energy sources, based on the geo-location of the post
* The caption could also include information,s
* Create more experimental games and interactive experiences that coudl combine into a collection exploring the materials behind the cloud



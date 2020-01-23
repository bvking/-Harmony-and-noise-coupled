import peasy.*;
PeasyCam cam;

import sync.*;

// change these for screen size
float fov = 45;  // degrees
float w = 1000;
float h = 800;
 
// don't change these
float cameraZ, zNear, zFar;
float w2 = w / 2;
float h2 = h / 2;

PNetwork net;
float side;
float displacement;
float NaturalF;
float coupling;

float noiseScale= 1;

void setup() { 
  //perspective setting
  size(1000, 800, P3D);
  
 /*  to manage later reflection on sphere
  colorMode(RGB, 1);
//  fill(0.4);
 */
 
  cam = new PeasyCam(this, 1000);
  cameraZ = (h / 2.0) / tan(radians(fov) / 2.0);
  zNear = cameraZ / 10.0;
  zFar = cameraZ * 10.0;
  println("CamZ: " + cameraZ);
  rectMode(CENTER);
  //
  
  int networkSize = 12; // To modulate sound of 12 note (one octave) Later!!!
  float coupling = 1;// How modulate this?
  float noiseLevel = 0 ; // Usefull only with case Q?
  net = new PNetwork(this, networkSize, coupling, noiseLevel);
  side = height*0.15*1/networkSize;
  displacement = width/2;
  
  frameRate(100);
}

void draw() {
  
     // float coupling = mouseY/(height/10); 
  
    //******movement of each oscillator will change by moduling noiseDetail with the trackpad
 
     // to modulate the noise in Q and q case
     noiseDetail(4, mouseY/(height*1/1.2));//mouseX/(width/20), mouseY/(height*1/1.2)
  
  background(0);
  translate(width/2, height/2);
 
  /* to manage later the direction of the light
   lightSpecular(1, 1, 1);
  directionalLight(0.8, 0.8, 0.8, 0, 0, -1);
  float s = mouseX / float(width);
  specular(s, s, s);
  */
 
  // Draw  spheres corresponding to the phase of each oscillator
 
  stroke(75, 190, 70);
  for (int i = 0; i < net.networkSize; i++) {
    pushMatrix();
    float x = displacement*cos(net.phase[i]);
    float y = displacement*sin(net.phase[i]);

  translate(-w2, -h2, -1000); // Set the perspective 3D with two fingers on the trackpad
 
  fill (0);
  sphere(side*3); // this sphere serves as a reference
  sphereDetail( 4*5);

    // Draw sphere 
  fill(25*(5-i),  25*i, (i+5)*25 ); 
  noStroke();  // 
  translate (x*-1,y*-1, 200+(50*5*i));  
  sphere(side*3);
  
    // Draw axe of each sphere
   rotate(net.phase[i]);
   stroke(120);
   line(0, 0, displacement*1, 0 );
   noStroke(); 
  
   
 
   // I can't see the line ot the order paramater
   /*
   fill (12);
   stroke (255);
   
  rotate(-net.averagePhase); // draw a line pointing to the average phase of the network
  line(0, 0, displacement*net.orderParameter, 0);
  sphere(side*5);
    */
    popMatrix();
  }
   // Draw a line pointing to the axe of rotation of sphere 
  
    for (int i = 0; i < net.networkSize; i++) {
    pushMatrix();
 /*   
   rotate(net.phase[i]);
   stroke(120); 
   line(0, 0, displacement*1, 0 );
   rotate(-net.averagePhase); // draw a line pointing to the average phase of the network
   color (12);
   stroke (255);
  line(0, 0, displacement*net.orderParameter, 0);
  */
   popMatrix();
   
   // LATER 
 
  
  }
 
  net.step();
}

void keyPressed() {
 //***********************  ADDING "LIVE" in the hole movement
   if (key == 'Q') {println ("Noise in Phases");
    background (0);
       for (int i = 0; i < net.networkSize; i++) {
           net.phase[i] = TWO_PI *   noise(i*0.1); 
    print ("phase "); print (i);  print (" ");
    print (net.phase[i]); print (" ");
    print ("frequency "); print (i); print (" ");
    println (net.naturalFrequency[i]);
     }
  } 
  if (key == 'q') {println ("Noise in Frequencies");
  background (0); 
       for (int i = 0; i < net.networkSize; i++) {
           net.naturalFrequency[i] = TWO_PI *   noise(i*0.1); //p0.01 to begin slower
    print ("phase "); print (i);  print (" ");
    print (net.phase[i]); print (" ");
    print ("frequency "); print (i); print (" ");
    println (net.naturalFrequency[i]);    
     }
} 
   //************* modulate the parameters of the middle sphere
 if (key == 'e') { 
    net.phase[net.networkSize-net.networkSize/2] +=0.1;
     for (int i = 0; i < net.networkSize; i++) {   
    print ("phase "); print (i);  print (" ");
    print (net.phase[i]); print (" ");
    print ("frequency "); print (i); print (" ");
    println (net.naturalFrequency[i]);
  } 
  }    
  if (key == 'd') {    
     net.phase[net.networkSize-net.networkSize/2] -=0.1;
      for (int i = 0; i < net.networkSize; i++) {  
    print ("phase "); print (i);  print (" ");
    print (net.phase[i]); print (" ");
    print ("frequency "); print (i); print (" ");
    println (net.naturalFrequency[i]);
  }
  }  
   else if (key == 'r') {
    net.naturalFrequency[net.networkSize-net.networkSize/2] +=0.1; 
      for (int i = 0; i < net.networkSize; i++) {
    print ("phase "); print (i);  print (" ");
    print (net.phase[i]); print (" ");
    print ("frequency "); print (i); print (" ");
    println (net.naturalFrequency[i]);
}
}
     else if (key == 'f') {     
     net.naturalFrequency[net.networkSize-net.networkSize/2] -=0.1;   
      for (int i = 0; i < net.networkSize; i++) {   
    print ("phase "); print (i);  print (" ");
    print (net.phase[i]); print (" ");
    print ("frequency "); print (i); print (" ");
    println (net.naturalFrequency[i]);
}

//*********************************      make 2 cases to shift the frequencies one by one

//*********************************      Shift FREQUENCIE 0 to 1, 1 to 2... and 11 to 0. And shift again the new 0 into 1
//*********************************      the same case as above in the other way -->     shift FREQUENCIE 0 to 11, 1 to 0... and 11 to 10. And shift again         
}
 if (key == 'i') { //  Shift frequencies one by one. 
 
   for (int i = 0; i < net.networkSize; i++) {
     
    if( i+1 < net.networkSize) {
 
  net.naturalFrequency[i]= net.naturalFrequency[i+1];
  
    /* or something else but it doesn't work
    net.naturalFrequency[11]= net.naturalFrequency[0];
    net.naturalFrequency[10]= net.naturalFrequency[11];
    net.naturalFrequency[9]= net.naturalFrequency[10];
    net.naturalFrequency[8]= net.naturalFrequency[9];
    net.naturalFrequency[7]= net.naturalFrequency[8];
    net.naturalFrequency[6]= net.naturalFrequency[7];
    net.naturalFrequency[5]= net.naturalFrequency[6];
    net.naturalFrequency[4]= net.naturalFrequency[5];
    net.naturalFrequency[3]= net.naturalFrequency[4];
    net.naturalFrequency[2]= net.naturalFrequency[3];
    net.naturalFrequency[1]= net.naturalFrequency[2];
    net.naturalFrequency[0]= net.naturalFrequency[1];
    */  
    print ("phase "); print (i);  print (" ");
    print (net.phase[i]); print (" ");
    print ("frequency "); print (i); print (" ");
    println (net.naturalFrequency[i]);    
    }
    
    else {
  //    net.naturalFrequency[0]= net.naturalFrequency[net.networkSize];    
     }     
}
}      
      ///****************************** MODULATE SPEED of ALL FREQUENCIE MORE OR LESS FASTLY
      /// ****************************  How could i modulate the couple?
      
    else if (key == 'y') {
    
     println("y= Increase last frequencies + 0.05*i ");
     
  float coupling = mouseY/80;  // Why it doesn't change the coupling
         for (int i = 0; i < net.networkSize; i++) {   
       net.naturalFrequency[i] = net.naturalFrequency[i]+(0.05*i);
       println (coupling);        
    print ("phase "); print (i);  print (" ");
    print (net.phase[i]); print (" ");
    print ("frequency "); print (i); print (" ");
    println (net.naturalFrequency[i]);
     }       
}    
       else if (key == 'h') { println(" Decrease last frequencies - 0.05*i"); 
     for (int i = 0; i < net.networkSize; i++) { 
       net.naturalFrequency[i] = net.naturalFrequency[i]-(0.05*i);            
    print ("phase "); print (i);  print (" ");
    print (net.phase[i]); print (" ");
    print ("frequency "); print (i); print (" ");
    println (net.naturalFrequency[i]);   
     }
}     
   if (key == 'w') {  println(" Increase with 0.1 ");    
   for (int i = 0; i < net.networkSize; i++) { 
  net.naturalFrequency[i]= net.naturalFrequency[i]+(i*0.1);     
    print ("phase "); print (i);  print (" ");
    print (net.phase[i]); print (" ");
    print ("frequency "); print (i); print (" ");
    println (net.naturalFrequency[i]);
     }    
}     
   if (key == 'v') {  println(" Decrease with 0.1 "); //   
   for (int i = 0; i < net.networkSize; i++) {  
   net.naturalFrequency[i]= net.naturalFrequency[i]-(i*0.1); ;    
    print ("phase "); print (i);  print (" ");
    print (net.phase[i]); print (" ");
    print ("frequency "); print (i); print (" ");
    println (net.naturalFrequency[i]);
     }  
}  
   if (keyCode == UP) { println( "Increase with 0.01 "); // Incremente together without changing phases   
   for (int i = 0; i < net.networkSize; i++) { 
   net.naturalFrequency[i] = net.naturalFrequency[i]+0.01*i;  
    print ("phase "); print (i);  print (" ");
    print (net.phase[i]); print (" ");
    print ("frequency "); print (i); print (" ");
    println (net.naturalFrequency[i]);
     }
}  
   if (keyCode == DOWN) { println(" Decrease all last frequencies proportionnaly to i  "); // Incremente together without changing phases  
   for (int i = 0; i < net.networkSize; i++) {
       net.naturalFrequency[i] = net.naturalFrequency[i]-0.01*i;
    print ("phase "); print (i);  print (" ");
    print (net.phase[i]); print (" ");
    print ("frequency "); print (i); print (" ");
    println (net.naturalFrequency[i]);  
     }
} 
  //************************** CHANGE THE WAY OF ROTATION
   else if (key == 'o') { println("  Opposite frequencies without changing phases  "); 
   for (int i = 0; i < net.networkSize; i++) {
     net.naturalFrequency[i] = -1* net.naturalFrequency[i];     
    print ("phase "); print (i);  print (" ");
    print (net.phase[i]); print (" ");
    print ("frequency "); print (i); print (" ");
    println (net.naturalFrequency[i]);  
     }
  }  
  //************************** SET HARMONIC MOVEMENT  
    else if (key == 'c') {  print(" Harmonic Frequencies in ClockWiseWay ");
   for (int i = 0; i < net.networkSize; i++) {
     net.naturalFrequency[i]=  i*-0.1;    
    print ("phase "); print (i);  print (" ");
    print (net.phase[i]); print (" ");
    print ("frequency "); print (i); print (" ");
    println (net.naturalFrequency[i]);
     }     
}    
     else if (key == 'C') {  println("  Set frequency positively in harmonic way. "); //
   for (int i = 0; i < net.networkSize; i++) {
     net.naturalFrequency[i]= i*0.1;   
    print ("phase "); print (i);  print (" ");
    print (net.phase[i]); print (" ");
    print ("frequency "); print (i); print (" ");
    println (net.naturalFrequency[i]);
     } 
} 
     else if (key == '0') { println(" Set Frequencies to 0 ");
     
       for (int i = 0; i < net.networkSize; i++) {   
       net.naturalFrequency[i]=0;  
    print ("phase "); print (i);  print (" ");
    print (net.phase[i]); print (" ");
    print ("frequency "); print (i); print (" ");
    println (net.naturalFrequency[i]); 
     }
} 
    else if (key == '1') { println(" Set Frequencies to 1+ harmonic distance ");
       for (int i = 0; i < net.networkSize; i++) {  
       net.naturalFrequency[i]=1+i*0.1;  
    print ("phase "); print (i);  print (" ");
    print (net.phase[i]); print (" ");
    print ("frequency "); print (i); print (" ");
    println (net.naturalFrequency[i]);   
     }
} 
    else if (key == '2') { println(" Set Frequencies to 2+ harmonic distance "); 
       for (int i = 0; i < net.networkSize; i++) {  
       net.naturalFrequency[i]=2+i*0.1;  
    print ("phase "); print (i);  print (" ");
    print (net.phase[i]); print (" ");
    print ("frequency "); print (i); print (" ");
    println (net.naturalFrequency[i]);   
     }
} 
    else if (key == '3')  {  println(" Set Frequencies to 3 + harmonic distance ");  
       for (int i = 0; i < net.networkSize; i++) {  
       net.naturalFrequency[i]=3+i*0.1;  
    print ("phase "); print (i);  print (" ");
    print (net.phase[i]); print (" ");
    print ("frequency "); print (i); print (" ");
    println (net.naturalFrequency[i]);  
     }
} 
    else if (key == '4') {  println(" Set Frequencies to 4 + harmonic distance "); 
       for (int i = 0; i < net.networkSize; i++) { 
       net.naturalFrequency[i]=4+i*0.1;   
    print ("phase "); print (i);  print (" ");
    print (net.phase[i]); print (" ");
    print ("frequency "); print (i); print (" ");
    println (net.naturalFrequency[i]);   
     }
} 
  //***************************** PLAY with phase to CHANGE PATTERN
   if (key == 'Z') { println ("Start positions / last offset phases");    
      for (int i = 0; i < net.networkSize; i++) {
    net.phase[i] =    2*i*1/net.networkSize*PI;
    print ("phase "); print (i);  print (" ");
    print (net.phase[i]); print (" ");
    print ("frequency "); print (i); print (" ");
    println (net.naturalFrequency[i]);
  }
} // COOOOOLLLL
 if (key == 'z') { println ("Start + Incremente positions / last offset phases");    
      for (int i = 0; i < net.networkSize; i++) {
    net.phase[i] +=    2*i*1/net.networkSize*PI;
    print ("phase "); print (i);  print (" ");
    print (net.phase[i]); print (" ");
    print ("frequency "); print (i); print (" ");
    println (net.naturalFrequency[i]);
  }
} 
   if (key == 'A') { println ("Incremente positions / last offset phases");    
      for (int i = 0; i < net.networkSize; i++) {
    net.phase[i] +=   net.phase[i]+ i*1/net.networkSize*PI;
    print ("phase "); print (i);  print (" ");
    print (net.phase[i]); print (" ");
    print ("frequency "); print (i); print (" ");
    println (net.naturalFrequency[i]);
  }
} 
   if (key == 'a') { println ("Decremente positions / last offset phases");  
      for (int i = 0; i < net.networkSize; i++) {    
    net.phase[i] = net.phase[i]-i*-1.0/net.networkSize*PI;    
    print ("phase "); print (i);  print (" ");
    print (net.phase[i]); print (" ");
    print ("frequency "); print (i); print (" ");
    println (net.naturalFrequency[i]);
  }
}  
   else if (key == 'T') {println(" Increase space of phases with the former gap between phase ");     
     for (int i = 0; i < net.networkSize; i++) {
             net.phase[i] += 1*net.phase[i]; // switch T / A --> it's awesome stuff          
    print ("phase "); print (i);  print (" ");
    print (net.phase[i]); print (" ");
    print ("frequency "); print (i); print (" ");
    println (net.naturalFrequency[i]);
     }   
} 
     else if (key == 't') {println(" Go to the opposite phase");
     for (int i = 0; i < net.networkSize; i++) { 
              net.phase[i] -= 1*net.phase[i]; // switch t/a --> it's awesome stuff         
    print ("phase "); print (i);  print (" ");
    print (net.phase[i]); print (" ");
    print ("frequency "); print (i); print (" ");
    println (net.naturalFrequency[i]);   
     }    
}  
   else if (key == 'G') {println(" Increase the gap between phases ");
   for (int i = 0; i < net.networkSize; i++) {
             net.phase[i] +=i*0.01;
    print ("phase "); print (i);  print (" ");
    print (net.phase[i]); print (" ");
    print ("frequency "); print (i); print (" ");
    println (net.naturalFrequency[i]);   
     }
} 
  else if (key == 'g') { println(" Decrease the gap between phases ");  
       for (int i = 0; i < net.networkSize; i++) {
               net.phase[i] -=i*0.01;
    print ("phase "); print (i);  print (" ");
    print (net.phase[i]); print (" ");
    print ("frequency "); print (i); print (" ");
    println (net.naturalFrequency[i]);
     }
} 
//****************** To use when frequencies are set at 0
  else if (key == 'P') { println("INCREASE phases with 0.5   "); //
   for (int i = 0; i < net.networkSize; i++) {
                  net.phase[i] += 0.5*net.phase[i];  //   
    print ("phase "); print (i);  print (" ");
    print (net.phase[i]); print (" ");
    print ("frequency "); print (i); print (" ");
    println (net.naturalFrequency[i]);   
     } 
}    
   else if (key == 'p') {println("DECREASE phases with 0.5   "); //
   for (int i = 0; i < net.networkSize; i++) {  
             net.phase[i] -=0.5* net.phase[i]; //
    print ("phase "); print (i);  print (" ");
    print (net.phase[i]); print (" ");
    print ("frequency "); print (i); print (" ");
    println (net.naturalFrequency[i]);   
     } 
  }   
// ****************** ALIGNEMENT of PHASES
else if (key == '9') { println(" Set Phases to 0 ");
       for (int i = 0; i < net.networkSize; i++) {
             net.phase[i]=0;
    print ("phase "); print (i);  print (" ");
    print (net.phase[i]); print (" ");
    print ("frequency "); print (i); print (" ");
    println (net.naturalFrequency[i]);
     }
} 
else if (key == '8') { println(" Add 180° to all oscillator ");
       for (int i = 0; i < net.networkSize; i++) {
             net.phase[i]=PI;   
    print ("phase "); print (i);  print (" ");
    print (net.phase[i]); print (" ");
    print ("frequency "); print (i); print (" ");
    println (net.naturalFrequency[i]);
     }
} 
// MAKE A SORT OF FOLLOW MODE
} 

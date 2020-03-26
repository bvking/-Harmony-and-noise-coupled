//MANAGE SOUND

import ddf.minim.*;
import ddf.minim.ugens.*;

// MANAGE NETWORK of OSCILLATOR

import java.util.Arrays;
import sync.*;
// MANAGE ARDUINO
import processing.serial.*;
Serial arduinoport;

// variable of the setting of oscillator network
PNetwork net;
float side;
float displacement;
float NaturalF;
float coupling;
float noiseScale= 1;
float radius;
int[] rev;

//int networkSize=4;
// MANAGE data TO SEND POSITION or SPEED to ARDUINO
float speed0, speed1, speed2, speed3, speed4;
int VirtualPosition, VirtualPosition1;
float[] pos;

// MANAGE SOUND
Minim       minim;

AudioOutput out0;
AudioOutput out1;
AudioOutput out2;
AudioOutput out3;

//MoogFilter  moog[];
MoogFilter  moog0;
MoogFilter  moog1;
MoogFilter  moog2;
MoogFilter  moog3;


//MANAGE VARIABLE TO MODULATE SOUND
int freqMax= 12000;
float phaz, freq;
float rez;
float[] phazi;
float[] speedi;
float[] freqi;
float[] resonancei;
int []j; // to reduce the number or revolution even or odd  

// MANAGE PERSPECTIVE
import peasy.*;
PeasyCam cam;


// change these for screen size
float fov = 45;  // degrees
float w = 1000;
float h = 800;
 
// don't change these
float cameraZ, zNear, zFar;
float w2 = w / 2;
float h2 = h / 2;


void setup() {
   //perspective setting
  size(1000, 800, P3D);
  
  //********to send value to Arduino
  String[] ports = Serial.list();
 // printArray(ports);
   printArray(Serial.list());
 // arduinoport = new Serial(this,ports[14],115200);
  
  int networkSize = 5;
  float noiseLevel = 0 ; // Usefull only with case Q?
  rev = new int[networkSize];
  j= new int[networkSize]; // reduce rev even or odd with 0 or 1 /
  float coupling = 0.5;
  net = new PNetwork(this, networkSize, coupling, noiseLevel);
  side = height*0.15*1/networkSize;
  displacement = width/2;
  
  minim   = new Minim(this);
  out0     = minim.getLineOut(); 
  out1     = minim.getLineOut();
  out2     = minim.getLineOut();
  out3     = minim.getLineOut();
  
  
  // construct a law pass MoogFilter with a 
  // cutoff frequency of 1200 Hz and a resonance of 0.5
  /*
  moog0 = new MoogFilter( 50*0.5, 0.5 ); 
  moog1 = new MoogFilter( 50*1, 0.5 );
  moog2 = new MoogFilter( 50*2, 0.5 );
  moog3 = new MoogFilter( 50*3, 0.5 );
 */
 
  moog0 = new MoogFilter( 50*10, 0.5 ); 
  moog1 = new MoogFilter( 50*20, 0.5 );
  moog2 = new MoogFilter( 50*30, 0.5 );
  moog3 = new MoogFilter( 50*40, 0.5 );
  
  // we will filter a white noise source,
  // which will allow us to hear the result of filtering
  Noise noize = new Noise( 0.5f );  

  // send the noise through the filter
  
  noize.patch( moog0 ).patch( out0 );
  noize.patch( moog1 ).patch( out1 );
  noize.patch( moog2 ).patch( out2 );
  noize.patch( moog3 ).patch( out3 );
  
  phazi=  new float[networkSize];
  speedi= new float[networkSize];
  freqi=  new float[networkSize];
  resonancei= new float[networkSize];
 

  
  
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
  frameRate(60);   
}

void draw() {
  
  countRevs();
  println(frameCount + ": " + Arrays.toString(rev));
    coupling = mouseX/80;
    net.setCoupling(coupling);
 //   println(coupling); 
    
    
  // MODULATE the noise in Q and q case
     noiseDetail(4, mouseY/(height*1/1.2));//mouseX/(width/20), mouseY/(height*1/1.2)
  
  background(220);
  
   // Calculate the overall order (cohesion) in the network
  PVector order = net.getOrderVector();
  float orderParameter = net.getOrderParameter();
  stroke(100);
  fill(100);
  String ordometer = String.format("Order: %.2f", orderParameter);
  text(ordometer, 10, 20);
 //  net.setCoupling(coupling);
  String couplingFormat = String.format("Coupling: %.2f", coupling);
  text(coupling, 200, 20);
  
  translate(width/2, height/2);
 
  /* to manage later the direction of the light
   lightSpecular(1, 1, 1);
  directionalLight(0.8, 0.8, 0.8, 0, 0, -1);
  float s = mouseX / float(width);
  specular(s, s, s);
  */
 
  // Draw  spheres corresponding to the phase of each oscillator
 
  stroke(75, 190, 70);
  for (int i = 0; i < net.size(); i++) {

    pushMatrix();
    float x = displacement*cos(net.phase[i]);
    float y = displacement*sin(net.phase[i]);
    
 // ***************************************DATA TO MANAGE SOUND
     j[i]= rev[i]%2; // if j==0 the number of revolution is pair, j==1 -->impair, j==-1--> impair and negative
     
     print ("j "); print(i); print (j[i]);
       
     if (net.naturalFrequency[i] < 0) {
    freqi[i] = constrain( map( net.naturalFrequency[i], 0, -5, 200, 16000 ), 200, 12000 );
      }

     else  {
    freqi[i]=  constrain( map( net.naturalFrequency[i], 0, 5, 200, 16000 ), 200, 12000 );                
      }
      
//**************** IF MOTOR TURN IN Clock Way and number of revolution is >0
    // revoltion pair
       if (net.phase[i] > 0 && j[i]==0)  { 
       phazi[i]= constrain (map( net.phase[i], 0, 2*PI, 200, 16000), 200, freqMax);  
       println ("nombre pair");
     }
     // revoltion impair
        if (net.phase[i] > 0 && j[i]==1 )  {   
        phazi[i]= constrain (map( net.phase[i], 0, 2*PI, 16000, 200), 200, freqMax);
        println ("nombre impair");
     }
    // IF MOTOR TURN IN CClock Way  and number of revolution is >0 
      if  (net.phase[i] < 0 && j[i]==0 ) {   
      phazi[i]= constrain (map( net.phase[i], 0, -2*PI, 200, 16000), 200, freqMax); 
       println ("nombre pair back");
     } 
      if (net.phase[i] < 0 && j[i]==1) {   
      phazi[i]= constrain (map( net.phase[i], 0, -2*PI, 16000, 200), 200, freqMax);
      println ("nombre impair back");
     }   
    // IF MOTOR TURN IN CClock Way   and number of revolution is <0 
    // revoltion impair
       if (net.phase[i] < 0 && j[i]==-1)  { 
       phazi[i]= constrain (map( net.phase[i], 0, -2*PI, 16000, 200), 200, freqMax);
       println ("nombre impair negative CCW");
     }
     // revoltion pair
        if (net.phase[i] < 0 && (j[i]==0 && rev[i]<0))  { 
        phazi[i]= constrain (map( net.phase[i], 0, -2*PI, 200, 16000), 200, freqMax);  
        println ("nombre pair negative CCW");
     }
    //*******************************$ // IF MOTOR TURN IN Clock Way   and number of revolution is <0 
        if (net.phase[i] > 0 && j[i]==-1)  { 
        phazi[i]= constrain (map( net.phase[i], 0, 2*PI, 200, 16000), 200, freqMax); 
          println ("nombre impair negative CW");
     }
        if (net.phase[i] > 0 && (j[i]==0 && rev[i]<0))  { 
          phazi[i]= constrain (map( net.phase[i], 0, 2*PI, 16000, 200), 200, freqMax); 
          println ("nombre pair negative CW");
      }
               
        speedi[i]= map ((net.velocity[i]*100), -500, 500, 0, 1);
        
        resonancei[i]= speedi[i];
        
  //      print ("resonance "); print (i); print (" "); print (resonancei[i]);
  //      println ("");
   
  
    /*  
       moog0.frequency.setLastValue( freqi[0]  );
       moog1.frequency.setLastValue( freqi[1]  );
       moog2.frequency.setLastValue( freqi[2]  );
       moog3.frequency.setLastValue( freqi[3]  );
       
    */  
       moog0.frequency.setLastValue( phazi[0]  );
       moog1.frequency.setLastValue( phazi[1]  );
       moog2.frequency.setLastValue( phazi[2]  );
       moog3.frequency.setLastValue( phazi[3]  );
 
    //   rez= constrain( map( orderParameter, 0, 1, -1, 1), -1, 1 );       
       moog0.resonance.setLastValue( resonancei[0]); //rez
       moog1.resonance.setLastValue( resonancei[1]); //rez
       moog2.resonance.setLastValue( resonancei[2]); //rez
       moog3.resonance.setLastValue( resonancei[3]); //rez
       
        print ("phazi "); print (i);  print (" "); println ( phazi[i]); 
   //    
 // ************** PRINT DATA TO SEE COHERENCE BETWEEN MOVEMENT AND SOUND
 /*
    print ("phase "); print (i);  print (" "); print (net.phase[i]); print (" ");
    print ("phazi "); print (i);  print (" "); println ( phazi[i]); 
       
    print ("frequency "); print (i); print (" ");print (net.naturalFrequency[i]);  print (" ");
    print ("freqi "); print (i); print (" "); println (freqi[i]); 
    
    print ("velocityi "); print (i);  print (" "); print ( net.velocity[i]); print (" ");  
    print ("speedi "); print (i);  print (" "); println ( speedi[i]);
     
    print ("rez "); print (i); print (" "); println (rez );
  */ 
  translate(-w2, -h2, -1000); // Set the perspective 3D with two fingers on the trackpad
  line (250,250, 250, 250);  // line showing how ball will behang by the motor's axe.
 
   //line (0,0,0,0,0, 11*250+200+250); //axe helping the 3D representation. axe qui relie les pendules
  fill (0);
  sphere(side*3); // this sphere serves as a reference
  sphereDetail( 4*5);
  
    // Draw sphere 
  fill(25*(net.size()-i),  11*(net.size()-i), i+net.size()*11 ); 
  noStroke();  // 
  translate (x*1,y*1, 200+(50*5*i));  //*-1 go in clockwise, *1 go in CCW
  sphere(side*3);
      
    // Draw axe of each sphere
   rotate(net.phase[i]);
   stroke(120);
   line(0, 0, displacement*-1, 0 ); // * opposite / translate
   noStroke();
   
   popMatrix();
  }
  
  
  //********* AESTHETIC PROPOSITION to HAVE the same movement at the OPPOSITE SIDE
  
  /*
   noiseDetail(4, mouseY/(height*1/1.2));//mouseX/(width/20), mouseY/(height*1/1.2)
  
//  background(0);
  translate(-(width/2), -(height/2), -1000);
  
    stroke(75, 190, 70);
  for (int i = 0; i < net.size(); i++) {
    pushMatrix();
    float x = displacement*cos(net.phase[i]);
    float y = displacement*sin(net.phase[i]);

   /*
   rotate(net.phase[i]);
   stroke(120); 
   line(0, 0, displacement*1, 0 );
   rotate(-net.averagePhase); // draw a line pointing to the average phase of the network
   color (12);
   stroke (255);
  line(0, 0, displacement*net.orderParameter, 0);
  */
  
  /*
     // Draw sphere 
  fill(25*(net.size()-i),  11*(net.size()-i), (i+net.size())*11 ); 
  noStroke();  // 
  translate (x*-1,y*-1, 200+(50*5*i));  //*-1 go in clockwise, *1 go in CCW
  sphere(side*3);
  
    
    // Draw axe of each sphere
   rotate(net.phase[i]);
   stroke(120);
   line(0, 0, displacement*1, 0 ); // * opposite / translate
   noStroke();
     
   popMatrix();
  }  
  */
  
  net.step();  
//  arduinoPos ();
}

void countRevs() {
  for (int i = 0; i < net.size(); i++) {
//    if (net.oldPhase[i] < HALF_PI && net.phase[i] > 1.5 * PI) {
        if (net.oldPhase[i] < -1.5 * PI && net.phase[i] > -HALF_PI) {
      rev[i]--;
    } else if (net.oldPhase[i] > 1.5 * PI && net.phase[i] < HALF_PI) {
      rev[i]++;
    }
  }
}

void printSummary(int i) {
  print("phase "); print(i); print(" ");
  print(net.phase[i]); print(" ");
  print("frequency "); print(i); print(" ");
  println(net.naturalFrequency[i]);
}

void keyPressed() {//**** faire position de base à l'arret avec ecrart equidistant qui s'incrementent entre G et le chiffre
 
  if ( key == '5' ) moog0.type = MoogFilter.Type.LP;
  if ( key == '6' ) moog1.type = MoogFilter.Type.HP;
  if ( key == '7' ) moog2.type = MoogFilter.Type.BP;
  
  
  //********** SET POSITION of STEPPER MOTOR
 if (keyCode == LEFT) { //println( "Increase with 0.01 "); // Incremente together without changing phases   
   for (int i = 0; i < net.size(); i++) {
     
     
 
     printSummary(i);
     }
}  
   if (keyCode == RIGHT) {// println(" Decrease all last frequencies proportionnaly to i  "); // Incremente together without changing phases  
   for (int i = 0; i < net.size(); i++) {
  
     printSummary(i);
     }
}  

 // SET POSITION
 if (keyCode == TAB) { println(" GO to NEXT POSITION "); // 
   for (int i = 0; i < net.size(); i++) {
   // net.phase[i] += net.phase[i]+2*PI/net.size();// (incremente ecrat des dernieres phases --> si nul elles n'evoluent pas
    net.phase[i] = net.phase[i]+2*PI/net.size(); // (faire un nouvel ecart à corrélé selon l'ecart precedent )
   //    net.phase[i] += 2*i*PI/net.size(); // positionne avec un ecart qui s'increment et se supperposent les uns sur les autres
    print ("phase "); print (i);  print (" ");
    print (net.phase[i]); print (" ");
    print ("frequency "); print (i); print (" ");
    println (net.naturalFrequency[i]);  
     }
}

  if (key == 'u') { println(" GO to NEXT POSITION "); //   TAB -
   for (int i = 0; i < net.size(); i++) {
   // net.phase[i] += net.phase[i]+2*PI/net.size();// (incremente ecrat des dernieres phases --> si nul elles n'evoluent pas
    net.phase[i] = net.phase[i]-2*PI/net.size(); // (faire un nouvel ecart à corrélé selon l'ecart precedent )
   //    net.phase[i] += 2*i*PI/net.size(); // positionne avec un ecart qui s'increment et se supperposent les uns sur les autres
    print ("phase "); print (i);  print (" ");
    print (net.phase[i]); print (" ");
    print ("frequency "); print (i); print (" ");
    println (net.naturalFrequency[i]);  
     }
}
// SET POSITION
 if (keyCode == CONTROL) { println(" SHIFT POSITION "); // Faire control -
   for (int i = 0; i < net.size(); i++) {
    net.phase[i] += net.phase[i]+2*PI/net.size();// (incremente ecrat des dernieres phases --> si nul elles n'evoluent pas
  //  net.phase[i] = net.phase[i]+2*PI/net.size(); // (faire un nouvel ecart à corrélé selon l'ecart precedent )
   //    net.phase[i] += 2*i*PI/net.size(); // positionne avec un ecart qui s'increment et se supperposent les uns sur les autres
    print ("phase "); print (i);  print (" ");
    print (net.phase[i]); print (" ");
    print ("frequency "); print (i); print (" ");
    println (net.naturalFrequency[i]);  
     }
}
if (key == 'j') { println(" SHIFT POSITION "); //  control -
   for (int i = 0; i < net.size(); i++) {
 //   net.phase[i] -= net.phase[i]-2*PI/net.size();// (les alignent betement)
       net.phase[i] = -2*i*PI/net.size();// (les alignent betement)
  //  net.phase[i] = net.phase[i]+2*PI/net.size(); // (faire un nouvel ecart à corrélé selon l'ecart precedent )
   //    net.phase[i] += 2*i*PI/net.size(); // positionne avec un ecart qui s'increment et se supperposent les uns sur les autres
    print ("phase "); print (i);  print (" ");
    print (net.phase[i]); print (" ");
    print ("frequency "); print (i); print (" ");
    println (net.naturalFrequency[i]);  
     }
}
 
 
 //***********************  ADDING "LIVE" in the hole movement
   if (key == 'Q') {println ("Noise in Phases");
    background (0);
       for (int i = 0; i < net.size(); i++) {
         //  net.phase[i] = TWO_PI *   noise(i*0.1); 
            net.phase[i] =  net.phase[i]  +  noise(i*0.1); // Add noise in former 
           
    print ("phase "); print (i);  print (" ");
    print (net.phase[i]); print (" ");
    print ("frequency "); print (i); print (" ");
    println (net.naturalFrequency[i]);
     }
  } 
  if (key == 'q') {println ("Noise in Frequencies");
  background (0); 
       for (int i = 0; i < net.size(); i++) {
           net.naturalFrequency[i] = TWO_PI *   noise(i*0.1); //0.01 to begin slower
    print ("phase "); print (i);  print (" ");
    print (net.phase[i]); print (" ");
    print ("frequency "); print (i); print (" ");
    println (net.naturalFrequency[i]);    
     }
} 

if (key == 'S') {println ("Add noise in last Frequencies. Vary it with mouse y");
  background (255); 
       for (int i = 0; i < net.size(); i++) {
      //     net.naturalFrequency[i] = TWO_PI *   noise(i*0.1); //0.01 to begin slower
       net.naturalFrequency[i] =    net.naturalFrequency[i] +  noise(i*0.1); // pas mal
    //     net.naturalFrequency[i] =   net.naturalFrequency[i] * noise(i*0.5); // trop aleatoire
    print ("phase "); print (i);  print (" ");
    print (net.phase[i]); print (" ");
    print ("frequency "); print (i); print (" ");
    println (net.naturalFrequency[i]);    
     }
} 




   //************* To modulate the parameters of the middle sphere
 if (key == 'e') { 
    net.phase[net.size()-net.size()/2] +=0.1;
     for (int i = 0; i < net.size(); i++) {   
    print ("phase "); print (i);  print (" ");
    print (net.phase[i]); print (" ");
    print ("frequency "); print (i); print (" ");
    println (net.naturalFrequency[i]);
  } 
  }    
  if (key == 'd') {    
     net.phase[net.size()-net.size()/2] -=0.1;
      for (int i = 0; i < net.size(); i++) {  
    print ("phase "); print (i);  print (" ");
    print (net.phase[i]); print (" ");
    print ("frequency "); print (i); print (" ");
    println (net.naturalFrequency[i]);
  }
  }  
   else if (key == 'r') {
    net.naturalFrequency[net.size()-net.size()/2] +=0.1; 
      for (int i = 0; i < net.size(); i++) {
    printSummary(i);
}
}
     else if (key == 'f') {     
     net.naturalFrequency[net.size()-net.size()/2] -=0.1;   
      for (int i = 0; i < net.size(); i++) {   
    printSummary(i);
}

if (key == 'b') { println (" SET FREQUENCIES POSITIVELY & NEGATIVELY ");
  println (" SET FREQUENCIES POSITIVELY & NEGATIVELY ");
  println (" SET FREQUENCIES POSITIVELY & NEGATIVELY ");
  println (" SET FREQUENCIES POSITIVELY & NEGATIVELY ");
  println (" SET FREQUENCIES POSITIVELY & NEGATIVELY ");
  println (" SET FREQUENCIES POSITIVELY & NEGATIVELY ");
  //   net.naturalFrequency[5]= 2;
    net.naturalFrequency[4]= 2;
    net.naturalFrequency[3]= 1;
    net.naturalFrequency[2]= 0;
    net.naturalFrequency[1]= -1;
    net.naturalFrequency[0]= -2;
    
for (int i = 0; i < net.size(); i++) {
      printSummary(i);  
    }
  } 

//*********************************      To make 2 cases A, B to shift the frequencies one by one

//********************************* case A: Shift FREQUENCIE 0 to 1, 1 to 2... and 11 to 0. And shift again the new 0 into 1
//********************************* case B: The same case as above in the other way -->  shift FREQUENCIE 0 to 11, 1 to 0... and 11 to 10. And shift again         
}

if (key == 'i') { println (" Shift frequencies one by one 0 to 1. ");
    net.shiftFrequencies(1);
for (int i = 0; i < net.size(); i++) {
      printSummary(i);  
    }
  } 
    
  
 if (key == 'u') { println (" Shift frequencies one by one 1 to 0 ");
    net.shiftFrequencies(-1);
for (int i = 0; i < net.size(); i++) {  
      printSummary(i);  
    }
  }  
 
if (key == 'j') { println (" Shift phase one by one 0 to 1. ");
    net.shiftPhases(1);
for (int i = 0; i < net.size(); i++) {
      printSummary(i);  
    }
  }   
  
  
  
///****************************** MODULATE SPEED of ALL FREQUENCIE MORE OR LESS FASTLY
/// ****************************  How could i modulate the couple?
 
/*    

  }    

/*
 if (key == 'i') { //  Shift frequencies one by one. 
 
   for (int i = 0; i < net.size(); i++) {
     
    if (i+1 < net.size()) {
 
  net.naturalFrequency[i]= net.naturalFrequency[i+1];
  
    //* or something else but it doesn't work
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
     
    printSummary(i);
    }
    
    else {
  //    net.naturalFrequency[0]= net.naturalFrequency[net.size()];    
     }     
}

}      
      ///****************************** MODULATE SPEED of ALL FREQUENCIE MORE OR LESS FASTLY
      /// ****************************  How could i modulate the couple?
*/     
  else if (key == 'y') { println("y= Increase last frequencies + 0.05*i ");
     
      float coupling = mouseY/80;  // Why it doesn't change the coupling
      for (int i = 0; i < net.size(); i++) {   
      net.naturalFrequency[i] = net.naturalFrequency[i]+(0.05*i);
      print ("coupling : "); println (coupling);        
      printSummary(i);
     }       
} 

   else if (key == 'h') { println(" Decrease last frequencies - 0.05*i"); 
     for (int i = 0; i < net.size(); i++) { 
       net.naturalFrequency[i] = net.naturalFrequency[i]-(0.05*i);            
       printSummary(i);
     }
}     
   if (key == 'w') {  println(" Increase with 0.1 ");    
   for (int i = 0; i < net.size(); i++) { 
    net.naturalFrequency[i]= net.naturalFrequency[i]+(i*0.1);     
    printSummary(i);
     }    
}     
   if (key == 'v') {  println(" Decrease with 0.1 "); //   
   for (int i = 0; i < net.size(); i++) {  
     net.naturalFrequency[i]= net.naturalFrequency[i]-(i*0.1); ;    
     printSummary(i);
     }  
}  
   if (keyCode == UP) { //println( "Increase with 0.01 "); // Incremente together without changing phases   
   for (int i = 0; i < net.size(); i++) { 
  // net.naturalFrequency[i] = net.naturalFrequency[i]+0.01*i;  
     net.naturalFrequency[i] = net.naturalFrequency[i]+0.1;  
     printSummary(i);
     }
}  
   if (keyCode == DOWN) {// println(" Decrease all last frequencies proportionnaly to i  "); // Incremente together without changing phases  
   for (int i = 0; i < net.size(); i++) {
  //     net.naturalFrequency[i] = net.naturalFrequency[i]-0.01*i;
     net.naturalFrequency[i] = net.naturalFrequency[i]-0.1;
     printSummary(i);
     }
} 
  //************************** CHANGE THE WAY OF ROTATION
   else if (key == 'o') {// println("  Opposite frequencies without changing phases  "); 
   for (int i = 0; i < net.size(); i++) {
     net.naturalFrequency[i] = -1* net.naturalFrequency[i];   
     printSummary(i);
     }
  }  
  //************************** SET HARMONIC MOVEMENT  
    else if (key == 'c') {  println("c =  Harmonic Frequencies in ClockWiseWay ");
   for (int i = 0; i < net.size(); i++) {
     net.naturalFrequency[i]=  i*-0.1;    
     printSummary(i);
     }     
}    
     else if (key == 'C') {  println(" C = Reset frequency positively in harmonic way. "); //
   for (int i = 0; i < net.size(); i++) {
     net.naturalFrequency[i]= i*0.1;   
     printSummary(i);
     } 
} 
     else if (key == '0') { println("Set Frequencies to 0 ");
     
       for (int i = 0; i < net.size(); i++) {   
       net.naturalFrequency[i]=1;  
   printSummary(i);
     }
} 
    else if (key == '1') { println("Set Frequencies to 1+ harmonic distance ");
       for (int i = 0; i < net.size(); i++) {
         
    float coupling = mouseY/(height/10); // No effect
    print ("coupling :"); println (coupling);
     
       net.naturalFrequency[i]=1-i*0.05;  
     printSummary(i);  
     }
} 
    else if (key == '2') { println(" Set Frequencies to 2+ harmonic distance "); 
       for (int i = 0; i < net.size(); i++) {  
       net.naturalFrequency[i]=1-i*0.1;  
    printSummary(i);  
     }
} 
    else if (key == '3')  {  println(" Set Frequencies to 3 + harmonic distance ");  
       for (int i = 0; i < net.size(); i++) {  
       net.naturalFrequency[i]=1-i*0.15;  
    printSummary(i); 
     }
} 
    else if (key == '4') {  println(" Set Frequencies to 4 + harmonic distance "); 
       for (int i = 0; i < net.size(); i++) { 
       net.naturalFrequency[i]=1-i*0.20;   
    printSummary(i);
     }
} 
  //***************************** PLAY with phase to CHANGE PATTERN
   if (key == 'Z') { println ("Start with the same offset between  phases");    
      for (int i = 0; i < net.size(); i++) {
    net.phase[i] =    2*i*1/net.size()*PI;
    printSummary(i);
  }
} // COOOOOLLLL
 if (key == 'z') { println ("Incremente Same offset between  phases");    
      for (int i = 0; i < net.size(); i++) {
    net.phase[i] +=    2*i*1/net.size()*PI;
     printSummary(i);
  }
} 
   if (key == 'A') { println ("Incremente positions / last offset phases");    
      for (int i = 0; i < net.size(); i++) {
    net.phase[i] +=   net.phase[i]+ i*1/net.size()*PI;
     printSummary(i);
  }
} 
   if (key == 'a') { println ("Decremente positions / last offset phases");  
      for (int i = 0; i < net.size(); i++) {    
    net.phase[i] = net.phase[i]-i*-1.0/net.size()*PI;    
    printSummary(i);
  }
}  
   else if (key == 'T') {println(" Increase space of phases with the former gap between phase ");     
     for (int i = 0; i < net.size(); i++) {
             net.phase[i] += 1*net.phase[i]; // switch T / A --> it's awesome stuff          
     printSummary(i);
     }   
} 
     else if (key == 't') {println(" Go to the opposite phase");
     for (int i = 0; i < net.size(); i++) { 
              net.phase[i] -= 1*net.phase[i]; // switch t/a --> it's awesome stuff         
   printSummary(i);  
     }    
}  
   else if (key == 'G') {println(" Increase the gap between phases ");
   for (int i = 0; i < net.size(); i++) {
             net.phase[i] +=i*0.01;
     printSummary(i);   
     }
} 
  else if (key == 'g') { println(" Decrease the gap between phases ");  
       for (int i = 0; i < net.size(); i++) {
               net.phase[i] -=i*0.01;
     printSummary(i);
     }
} 
//****************** To use when frequencies are set at 0
  else if (key == 'P') { println("INCREASE phases with 0.5   "); //
   for (int i = 0; i < net.size(); i++) {
                  net.phase[i] += 0.5*net.phase[i];  //   
    printSummary(i);  
     } 
}    
   else if (key == 'p') {println("DECREASE phases with 0.5   "); //
   for (int i = 0; i < net.size(); i++) {  
             net.phase[i] -=0.5* net.phase[i]; //
     printSummary(i);  
     } 
  }   
// ****************** ALIGNEMENT of PHASES --- thus, phases alignement depend of coupling.
else if (key == '9') { println(" Set Phases to 0 "); // 
       for (int i = 0; i < net.size(); i++) {
             net.phase[i]=0;
    printSummary(i);
     }
} 
else if (key == '8') { println(" Add 180° to all oscillator ");
       for (int i = 0; i < net.size(); i++) {
             net.phase[i]=PI;   
     printSummary(i);
     }
} 
// MAKE A SORT OF FOLLOW MODE
} 

void arduinoPos (){
    for (int i = 0; i < net.size(); i++) {
  //*******************************   ASSIGN MOTOR WITH SPEED (former solution but to much expensive for now, maybe latter)

  //     String speed= (nf (int (net.velocity[i]*100), 0, 2)+"*"); // keep only 2 digit after the coma. Transform in into *100 
      
   //    String speed= (int (net.velocity[4]*100))+"*"+ (int (net.velocity[3]*100))+"*"+ (int (net.velocity[2]*100))+"*"+ (int (net.velocity[1]*100))+"*"+ (int (net.velocity[0]*100))+"*";
       
   //    String speed= (int (net.velocity[4]*100))+"*"+ (int (net.velocity[3]*100))+"*"+ (int (net.velocity[2]*100))+"*"+ (int (net.velocity[1]*100))+"*"+ (int (-314))+"*";
       
  //     String speed= (int (-314))+"*"+ (int (net.velocity[3]*100))+"*"+ (int (net.velocity[2]*100))+"*"+ (int (net.velocity[1]*100))+"*"+ (int (314))+"*";// velocity4 = w0 
  
         String speed= (int (-314))+"*"+ (int (10))+"*"+ (int (-11))+"*"+ (int (12))+"*"+ (int (314))+"*";// velocity4 = w0 
       
       print (" speedMeasureLess: "); print (i); print (speed); // speed without measure
       
       arduinoport.write(speed);
       println ("");
   //*******************************  ASSIGN MOTOR WITH POSITION
   
   // RESOUDRE L'ERREUR   // ASSIGN MOTOR WITH POSITION IN A SIMPLER MANNER  ( WITH A AN ARRAY) 
    //   pos[i]= map ((net.phase[i]), 0, TWO_PI, 0, 2048);
 
      float pos0 = map ((net.phase[0]), 0, TWO_PI, 0, 2048); // Put the position at the good scale for a step motor with 2048 step.
      float pos1 = map ((net.phase[1]), 0, TWO_PI, 0, 2048); // Put the position at the good scale for a step motor with 2048 step.
      
      int Pos0= int (pos0);
      int Pos1= int (pos1);
    // CHANGE DATA TO HAVE THEM ON A CIRCLE BETWEEN 0 and 2048
  if ( Pos0 <2049 )  {    
             VirtualPosition = Pos0;
   }
  if ( Pos0 < 0)  {   
             VirtualPosition = 2048+ Pos0;
   }
  if ( Pos1 <2049 )  {      
             VirtualPosition1 = Pos1;
   }
  if ( Pos1 < 0)  {  
             VirtualPosition1 = 2048+ Pos1; 
   }  
  //  //Specify int DATA values, in order Arduino understand it's int DATA.
      // And split them with "*" 
  
  //   String pos = (10)+"*"+(10) +"*"+(10)+"*"+(int (VirtualPosition1))+"*"+(int (VirtualPosition)) +"*"; 
     
  //  print ("  pos   ");println (pos); arduinoport.write(pos); // Send data to Arduino.
  }  
}    

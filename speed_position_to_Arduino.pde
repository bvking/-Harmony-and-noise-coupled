//MANAGE SOUND

import ddf.minim.*;
import ddf.minim.ugens.*;

// MANAGE ARDUINO
import processing.serial.*;
Serial arduinoport;

// MANAGE data TO SEND to ARDUINO
float speed0, speed1, speed2, speed3, speed4;
int VirtualPosition, VirtualPosition1;
float[] pos;

// MANAGE SOUND
Minim       minim;
AudioOutput out;
AudioOutput out1;
AudioOutput out2;
MoogFilter  moog;
MoogFilter  moog1;
MoogFilter  moog2;

//MANAGE VARIABLE TO MODULATE SOUND
float phaz, freq;
float rez;

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

// MAANGE MOVEMENT
import sync.*;

PNetwork net;
float side;
float displacement;
float NaturalF;
float coupling;

float noiseScale= 1;

void setup() { 
  //perspective setting
  size(1000, 800, P3D);
  
  //********to send value to Arduino
  String[] ports = Serial.list();
  printArray(ports);
 // arduinoport = new Serial(this,ports[6],115200);
 
  //***************
  
 
  
  // initialize the minim and out objects
  
  minim   = new Minim(this);
  out     = minim.getLineOut();
  
  // construct a law pass MoogFilter with a 
  // cutoff frequency of 1200 Hz and a resonance of 0.5
  moog    = new MoogFilter( 1200, 0.5 );
  moog1 =  new MoogFilter( 1200*4, 0.5 );
  moog2 = new MoogFilter( 1200*8, 0.5 );
  
  // we will filter a white noise source,
  // which will allow us to hear the result of filtering
  Noise noize = new Noise( 0.5f );  

  // send the noise through the filter
  noize.patch( moog ).patch( out );
  noize.patch( moog1 ).patch( out );
  
  // Minim       minim;



  
  
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
  
  frameRate(20);
}

void draw() {

    float coupling = mouseY/(height/10); // No effect
    print ("coupling :"); println (coupling);
    
    //******movement of each oscillator will change by moduling noiseDetail with the trackpad
     // to modulate the noise in Q and q case
     noiseDetail(4, mouseY/(height*1/1.2));//mouseX/(width/20), mouseY/(height*1/1.2)
  
  background(220);
  
   // Calculate the overall order (cohesion) in the network
  PVector order = net.getOrderVector();
  float orderParameter = net.getOrderParameter();
  stroke(100);
  fill(100);
  String ordometer = String.format("Order: %.2f", orderParameter);
  text(ordometer, 10, 20);
  
  translate(width/2, height/2);
 
  /* to manage later the direction of the light
   lightSpecular(1, 1, 1);
  directionalLight(0.8, 0.8, 0.8, 0, 0, -1);
  float s = mouseX / float(width);
  specular(s, s, s);
  */
 
  // Draw  spheres corresponding to the phase of each oscillator
 
  stroke(75, 190, 70);
  for (int i = 0; i < net.size; i++) {
    pushMatrix();
    float x = displacement*cos(net.phase[i]);
    float y = displacement*sin(net.phase[i]);
    
 // ***************************************DATA TO MANAGE SOUND
      
    if  (net.naturalFrequency[i] < 0) {
      
          freq = constrain( map( net.naturalFrequency[i], 0, -5, 200, 12000 ), 200, 12000 );
        
         }
         
         else  {
         
         freq = constrain( map( net.naturalFrequency[i], 0, 5, 200, 12000 ), 200, 12000 );
         
          }
         
         
     if  (net.phase[i] < 0) {
      
         phaz = constrain( map( net.phase[i], 0, -2*PI, 200, 12000 ), 200, 12000 );
        
         }
         
         else  {
           
         phaz = constrain( map( net.phase[i], 0, 2*PI, 200, 12000 ), 200, 12000 );
           
         }  
         
        
    float  freq = constrain( map( net.naturalFrequency[i], 0, 5, 200, 12000 ), 200, 16000 );/// adjust frequency between 200 and 16000  
    moog.frequency.setLastValue( freq  ); // modulate the cutoff or the moog filter with frequency
    moog1.frequency.setLastValue( phaz  ); // modulate the cutoff or the moog filter with phase
 
    rez= constrain( map( orderParameter, 0, 1, 0, 1), 1, 0 );      
    moog.resonance.setLastValue( rez); //rez
   //    
 // ************** PRINT DATA TO SEE COHERENCE BETWEEN MOVEMENT AND SOUND
 /*
    print ("phase "); print (i);  print (" ");
    print (net.phase[i]); print (" ");
     print ("phaz "); print (i);  print (" "); println (phaz );
     
    print ("frequency "); print (i); print (" ");
    print (net.naturalFrequency[i]);  print (" ");
    print ("freq "); print (i); print (" "); println (freq );   
    print ("rez"); print (i); print (" "); println (rez );
  
 */
 
  translate(-w2, -h2, -1000); // Set the perspective 3D with two fingers on the trackpad
  

  
   line (250,250, 250, 250);  // line showing how ball will behang by the motor's axe.
  

  
 // line (0,0,0,0,0, 11*250+200+250); //axe helping the 3D representation. axe qui relie les pendules
 
 
  fill (0);
  sphere(side*3); // this sphere serves as a reference
  sphereDetail( 4*5);
  
 

    // Draw sphere 
  fill(25*(net.size-i),  11*(net.size-i), (i+net.size)*11 ); 
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
  for (int i = 0; i < net.size; i++) {
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
  fill(25*(net.size-i),  11*(net.size-i), (i+net.size)*11 ); 
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
  
  
  
   for (int i = 0; i < net.size; i++) {
    
     
  // SORT of SOLUTION when DATAS of velocity bug
  
  if ( net.velocity[i] < -120 )   {
    
     println(  "ERRRRRRRRRRRRRRORRRRRRRRRRRRRRRRRR" );
     println(  "ERRRRRRRRRRRRRRORRRRRRRRRRRRRRRRRR" );
     println(  "ERRRRRRRRRRRRRRORRRRRRRRRRRRRRRRRR" );
     println(  "ERRRRRRRRRRRRRRORRRRRRRRRRRRRRRRRR" );
     println(  "ERRRRRRRRRRRRRRORRRRRRRRRRRRRRRRRR" );
    
    net.velocity[i]= net.velocity[i]*-0.01;
    
     }
     
   if ( net.velocity[i] > 120 )   {
    
    net.velocity[i]= net.velocity[i]*-0.01;
    
    println(  "ERRRRRRRRRRRRRRORRRRRRRRRRRRRRRRRR" );
    println(  "ERRRRRRRRRRRRRRORRRRRRRRRRRRRRRRRR" );
    println(  "ERRRRRRRRRRRRRRORRRRRRRRRRRRRRRRRR" );
    println(  "ERRRRRRRRRRRRRRORRRRRRRRRRRRRRRRRR" );
    println(  "ERRRRRRRRRRRRRRORRRRRRRRRRRRRRRRRR" );
    
     }
     
   else { 
     
    net.velocity[i]=net.velocity[i];
    
    }
    
  //******************************* ASSIGN MOTOR WITH SPEED (former solution but to much expensive for now, maybe latter)

       String speed= (nf (net.velocity[i], 0, 2)+"*"); // keep only 2 digit after the coma
   
   //    print (" speedMeasureLess: "); print (speed); // speed without measure
 
 
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
  
  
     String pos = (10)+"*"+(10) +"*"+(10)+"*"+(int (VirtualPosition1))+"*"+(int (VirtualPosition)) +"*"; 
     
    print ("  pos   ");println (pos);
 
 //arduinoport.write(pos); // Send data to Arduino.
  
  }    
}   

void keyPressed() {//**** faire position de base à l'arret avec ecrart equidistant qui s'incrementent entre G et le chiffre
  if ( key == '5' ) moog.type = MoogFilter.Type.LP;
  if ( key == '6' ) moog.type = MoogFilter.Type.HP;
  if ( key == '7' ) moog.type = MoogFilter.Type.BP;

 // SET POSITION
 if (keyCode == TAB) { println(" GO to NEXT POSITION "); // 
   for (int i = 0; i < net.size; i++) {
   // net.phase[i] += net.phase[i]+2*PI/net.size;// (incremente ecrat des dernieres phases --> si nul elles n'evoluent pas
    net.phase[i] = net.phase[i]+2*PI/net.size; // (faire un nouvel ecart à corrélé selon l'ecart precedent )
   //    net.phase[i] += 2*i*PI/net.size; // positionne avec un ecart qui s'increment et se supperposent les uns sur les autres
    print ("phase "); print (i);  print (" ");
    print (net.phase[i]); print (" ");
    print ("frequency "); print (i); print (" ");
    println (net.naturalFrequency[i]);  
     }
}

  if (key == 'u') { println(" GO to NEXT POSITION "); //   TAB -
   for (int i = 0; i < net.size; i++) {
   // net.phase[i] += net.phase[i]+2*PI/net.size;// (incremente ecrat des dernieres phases --> si nul elles n'evoluent pas
    net.phase[i] = net.phase[i]-2*PI/net.size; // (faire un nouvel ecart à corrélé selon l'ecart precedent )
   //    net.phase[i] += 2*i*PI/net.size; // positionne avec un ecart qui s'increment et se supperposent les uns sur les autres
    print ("phase "); print (i);  print (" ");
    print (net.phase[i]); print (" ");
    print ("frequency "); print (i); print (" ");
    println (net.naturalFrequency[i]);  
     }
}
// SET POSITION
 if (keyCode == CONTROL) { println(" SHIFT POSITION "); // Faire control -
   for (int i = 0; i < net.size; i++) {
    net.phase[i] += net.phase[i]+2*PI/net.size;// (incremente ecrat des dernieres phases --> si nul elles n'evoluent pas
  //  net.phase[i] = net.phase[i]+2*PI/net.size; // (faire un nouvel ecart à corrélé selon l'ecart precedent )
   //    net.phase[i] += 2*i*PI/net.size; // positionne avec un ecart qui s'increment et se supperposent les uns sur les autres
    print ("phase "); print (i);  print (" ");
    print (net.phase[i]); print (" ");
    print ("frequency "); print (i); print (" ");
    println (net.naturalFrequency[i]);  
     }
}
if (key == 'j') { println(" SHIFT POSITION "); //  control -
   for (int i = 0; i < net.size; i++) {
 //   net.phase[i] -= net.phase[i]-2*PI/net.size;// (les alignent betement)
       net.phase[i] = -2*i*PI/net.size;// (les alignent betement)
  //  net.phase[i] = net.phase[i]+2*PI/net.size; // (faire un nouvel ecart à corrélé selon l'ecart precedent )
   //    net.phase[i] += 2*i*PI/net.size; // positionne avec un ecart qui s'increment et se supperposent les uns sur les autres
    print ("phase "); print (i);  print (" ");
    print (net.phase[i]); print (" ");
    print ("frequency "); print (i); print (" ");
    println (net.naturalFrequency[i]);  
     }
}
 
 
 //***********************  ADDING "LIVE" in the hole movement
   if (key == 'Q') {println ("Noise in Phases");
    background (0);
       for (int i = 0; i < net.size; i++) {
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
       for (int i = 0; i < net.size; i++) {
           net.naturalFrequency[i] = TWO_PI *   noise(i*0.1); //0.01 to begin slower
    print ("phase "); print (i);  print (" ");
    print (net.phase[i]); print (" ");
    print ("frequency "); print (i); print (" ");
    println (net.naturalFrequency[i]);    
     }
} 

if (key == 'S') {println ("Add noise in last Frequencies. Vary it with mouse y");
  background (255); 
       for (int i = 0; i < net.size; i++) {
      //     net.naturalFrequency[i] = TWO_PI *   noise(i*0.1); //p0.01 to begin slower
       net.naturalFrequency[i] =    net.naturalFrequency[i] +  noise(i*0.1); // pas mal
    //     net.naturalFrequency[i] =   net.naturalFrequency[i] * noise(i*0.5); // trop aleatoire
    print ("phase "); print (i);  print (" ");
    print (net.phase[i]); print (" ");
    print ("frequency "); print (i); print (" ");
    println (net.naturalFrequency[i]);    
     }
} 




   //************* modulate the parameters of the middle sphere
 if (key == 'e') { 
    net.phase[net.size-net.size/2] +=0.1;
     for (int i = 0; i < net.size; i++) {   
    print ("phase "); print (i);  print (" ");
    print (net.phase[i]); print (" ");
    print ("frequency "); print (i); print (" ");
    println (net.naturalFrequency[i]);
  } 
  }    
  if (key == 'd') {    
     net.phase[net.size-net.size/2] -=0.1;
      for (int i = 0; i < net.size; i++) {  
    print ("phase "); print (i);  print (" ");
    print (net.phase[i]); print (" ");
    print ("frequency "); print (i); print (" ");
    println (net.naturalFrequency[i]);
  }
  }  
   else if (key == 'r') {
    net.naturalFrequency[net.size-net.size/2] +=0.1; 
      for (int i = 0; i < net.size; i++) {
    print ("phase "); print (i);  print (" ");
    print (net.phase[i]); print (" ");
    print ("frequency "); print (i); print (" ");
    println (net.naturalFrequency[i]);
}
}
     else if (key == 'f') {     
     net.naturalFrequency[net.size-net.size/2] -=0.1;   
      for (int i = 0; i < net.size; i++) {   
    print ("phase "); print (i);  print (" ");
    print (net.phase[i]); print (" ");
    print ("frequency "); print (i); print (" ");
    println (net.naturalFrequency[i]);
}

//*********************************      make 2 cases A, B to shift the frequencies one by one

//********************************* case A: Shift FREQUENCIE 0 to 1, 1 to 2... and 11 to 0. And shift again the new 0 into 1
//********************************* case B: The same case as above in the other way -->  shift FREQUENCIE 0 to 11, 1 to 0... and 11 to 10. And shift again         
}
 if (key == 'i') { //  Shift frequencies one by one. 
 
   for (int i = 0; i < net.size; i++) {
     
    if (i+1 < net.size) {
 
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
  //    net.naturalFrequency[0]= net.naturalFrequency[net.size];    
     }     
}
}      
      ///****************************** MODULATE SPEED of ALL FREQUENCIE MORE OR LESS FASTLY
      /// ****************************  How could i modulate the couple?
      
    else if (key == 'y') {
    
     println("y= Increase last frequencies + 0.05*i ");
     
  float coupling = mouseY/80;  // Why it doesn't change the coupling
         for (int i = 0; i < net.size; i++) {   
       net.naturalFrequency[i] = net.naturalFrequency[i]+(0.05*i);
       println (coupling);        
    print ("phase "); print (i);  print (" ");
    print (net.phase[i]); print (" ");
    print ("frequency "); print (i); print (" ");
    println (net.naturalFrequency[i]);
     }       
}    
       else if (key == 'h') { println(" Decrease last frequencies - 0.05*i"); 
     for (int i = 0; i < net.size; i++) { 
       net.naturalFrequency[i] = net.naturalFrequency[i]-(0.05*i);            
    print ("phase "); print (i);  print (" ");
    print (net.phase[i]); print (" ");
    print ("frequency "); print (i); print (" ");
    println (net.naturalFrequency[i]);   
     }
}     
   if (key == 'w') {  println(" Increase with 0.1 ");    
   for (int i = 0; i < net.size; i++) { 
  net.naturalFrequency[i]= net.naturalFrequency[i]+(i*0.1);     
    print ("phase "); print (i);  print (" ");
    print (net.phase[i]); print (" ");
    print ("frequency "); print (i); print (" ");
    println (net.naturalFrequency[i]);
     }    
}     
   if (key == 'v') {  println(" Decrease with 0.1 "); //   
   for (int i = 0; i < net.size; i++) {  
   net.naturalFrequency[i]= net.naturalFrequency[i]-(i*0.1); ;    
    print ("phase "); print (i);  print (" ");
    print (net.phase[i]); print (" ");
    print ("frequency "); print (i); print (" ");
    println (net.naturalFrequency[i]);
     }  
}  
   if (keyCode == UP) { //println( "Increase with 0.01 "); // Incremente together without changing phases   
   for (int i = 0; i < net.size; i++) { 
  // net.naturalFrequency[i] = net.naturalFrequency[i]+0.01*i;  
     net.naturalFrequency[i] = net.naturalFrequency[i]+0.1;  
    /*
    print ("phase "); print (i);  print (" ");
    print (net.phase[i]); print (" ");
    print ("frequency "); print (i); print (" ");
    println (net.naturalFrequency[i]);
    */
     }
}  
   if (keyCode == DOWN) {// println(" Decrease all last frequencies proportionnaly to i  "); // Incremente together without changing phases  
   for (int i = 0; i < net.size; i++) {
  //     net.naturalFrequency[i] = net.naturalFrequency[i]-0.01*i;
   net.naturalFrequency[i] = net.naturalFrequency[i]-0.1;
   /*
    print ("phase "); print (i);  print (" ");
    print (net.phase[i]); print (" ");
    print ("frequency "); print (i); print (" ");
    println (net.naturalFrequency[i]);
    */
     }
} 
  //************************** CHANGE THE WAY OF ROTATION
   else if (key == 'o') {// println("  Opposite frequencies without changing phases  "); 
   for (int i = 0; i < net.size; i++) {
     net.naturalFrequency[i] = -1* net.naturalFrequency[i];   
     /*
    print ("phase "); print (i);  print (" ");
    print (net.phase[i]); print (" ");
    print ("frequency "); print (i); print (" ");
    println (net.naturalFrequency[i]);  
    */
     }
  }  
  //************************** SET HARMONIC MOVEMENT  
    else if (key == 'c') {  println("c =  Harmonic Frequencies in ClockWiseWay ");
   for (int i = 0; i < net.size; i++) {
     net.naturalFrequency[i]=  i*-0.1;    
    print ("phase "); print (i);  print (" ");
    print (net.phase[i]); print (" ");
    print ("frequency "); print (i); print (" ");
    println (net.naturalFrequency[i]);
     }     
}    
     else if (key == 'C') {  println(" C = Reset frequency positively in harmonic way. "); //
   for (int i = 0; i < net.size; i++) {
     net.naturalFrequency[i]= i*0.1;   
    print ("phase "); print (i);  print (" ");
    print (net.phase[i]); print (" ");
    print ("frequency "); print (i); print (" ");
    println (net.naturalFrequency[i]);
     } 
} 
     else if (key == '0') { println("Set Frequencies to 0 ");
     
       for (int i = 0; i < net.size; i++) {   
       net.naturalFrequency[i]=1;  
    print ("phase "); print (i);  print (" ");
    print (net.phase[i]); print (" ");
    print ("frequency "); print (i); print (" ");
    println (net.naturalFrequency[i]); 
     }
} 
    else if (key == '1') { println("Set Frequencies to 1+ harmonic distance ");
       for (int i = 0; i < net.size; i++) {
         
    float coupling = mouseY/(height/10); // No effect
    print ("coupling :"); println (coupling);
     
       net.naturalFrequency[i]=1-i*0.05;  
    print ("phase "); print (i);  print (" ");
    print (net.phase[i]); print (" ");
    print ("frequency "); print (i); print (" ");
    println (net.naturalFrequency[i]);   
     }
} 
    else if (key == '2') { println(" Set Frequencies to 2+ harmonic distance "); 
       for (int i = 0; i < net.size; i++) {  
       net.naturalFrequency[i]=1-i*0.1;  
    print ("phase "); print (i);  print (" ");
    print (net.phase[i]); print (" ");
    print ("frequency "); print (i); print (" ");
    println (net.naturalFrequency[i]);   
     }
} 
    else if (key == '3')  {  println(" Set Frequencies to 3 + harmonic distance ");  
       for (int i = 0; i < net.size; i++) {  
       net.naturalFrequency[i]=1-i*0.15;  
    print ("phase "); print (i);  print (" ");
    print (net.phase[i]); print (" ");
    print ("frequency "); print (i); print (" ");
    println (net.naturalFrequency[i]);  
     }
} 
    else if (key == '4') {  println(" Set Frequencies to 4 + harmonic distance "); 
       for (int i = 0; i < net.size; i++) { 
       net.naturalFrequency[i]=1-i*0.20;   
    print ("phase "); print (i);  print (" ");
    print (net.phase[i]); print (" ");
    print ("frequency "); print (i); print (" ");
    println (net.naturalFrequency[i]);   
     }
} 
  //***************************** PLAY with phase to CHANGE PATTERN
   if (key == 'Z') { println ("Start with the same offset between  phases");    
      for (int i = 0; i < net.size; i++) {
    net.phase[i] =    2*i*1/net.size*PI;
    print ("phase "); print (i);  print (" ");
    print (net.phase[i]); print (" ");
    print ("frequency "); print (i); print (" ");
    println (net.naturalFrequency[i]);
  }
} // COOOOOLLLL
 if (key == 'z') { println ("Incremente Same offset between  phases");    
      for (int i = 0; i < net.size; i++) {
    net.phase[i] +=    2*i*1/net.size*PI;
    print ("phase "); print (i);  print (" ");
    print (net.phase[i]); print (" ");
    print ("frequency "); print (i); print (" ");
    println (net.naturalFrequency[i]);
  }
} 
   if (key == 'A') { println ("Incremente positions / last offset phases");    
      for (int i = 0; i < net.size; i++) {
    net.phase[i] +=   net.phase[i]+ i*1/net.size*PI;
    print ("phase "); print (i);  print (" ");
    print (net.phase[i]); print (" ");
    print ("frequency "); print (i); print (" ");
    println (net.naturalFrequency[i]);
  }
} 
   if (key == 'a') { println ("Decremente positions / last offset phases");  
      for (int i = 0; i < net.size; i++) {    
    net.phase[i] = net.phase[i]-i*-1.0/net.size*PI;    
    print ("phase "); print (i);  print (" ");
    print (net.phase[i]); print (" ");
    print ("frequency "); print (i); print (" ");
    println (net.naturalFrequency[i]);
  }
}  
   else if (key == 'T') {println(" Increase space of phases with the former gap between phase ");     
     for (int i = 0; i < net.size; i++) {
             net.phase[i] += 1*net.phase[i]; // switch T / A --> it's awesome stuff          
    print ("phase "); print (i);  print (" ");
    print (net.phase[i]); print (" ");
    print ("frequency "); print (i); print (" ");
    println (net.naturalFrequency[i]);
     }   
} 
     else if (key == 't') {println(" Go to the opposite phase");
     for (int i = 0; i < net.size; i++) { 
              net.phase[i] -= 1*net.phase[i]; // switch t/a --> it's awesome stuff         
    print ("phase "); print (i);  print (" ");
    print (net.phase[i]); print (" ");
    print ("frequency "); print (i); print (" ");
    println (net.naturalFrequency[i]);   
     }    
}  
   else if (key == 'G') {println(" Increase the gap between phases ");
   for (int i = 0; i < net.size; i++) {
             net.phase[i] +=i*0.01;
    print ("phase "); print (i);  print (" ");
    print (net.phase[i]); print (" ");
    print ("frequency "); print (i); print (" ");
    println (net.naturalFrequency[i]);   
     }
} 
  else if (key == 'g') { println(" Decrease the gap between phases ");  
       for (int i = 0; i < net.size; i++) {
               net.phase[i] -=i*0.01;
    print ("phase "); print (i);  print (" ");
    print (net.phase[i]); print (" ");
    print ("frequency "); print (i); print (" ");
    println (net.naturalFrequency[i]);
     }
} 
//****************** To use when frequencies are set at 0
  else if (key == 'P') { println("INCREASE phases with 0.5   "); //
   for (int i = 0; i < net.size; i++) {
                  net.phase[i] += 0.5*net.phase[i];  //   
    print ("phase "); print (i);  print (" ");
    print (net.phase[i]); print (" ");
    print ("frequency "); print (i); print (" ");
    println (net.naturalFrequency[i]);   
     } 
}    
   else if (key == 'p') {println("DECREASE phases with 0.5   "); //
   for (int i = 0; i < net.size; i++) {  
             net.phase[i] -=0.5* net.phase[i]; //
    print ("phase "); print (i);  print (" ");
    print (net.phase[i]); print (" ");
    print ("frequency "); print (i); print (" ");
    println (net.naturalFrequency[i]);   
     } 
  }   
// ****************** ALIGNEMENT of PHASES --- thus, phases alignement depend of coupling.
else if (key == '9') { println(" Set Phases to 0 "); // 
       for (int i = 0; i < net.size; i++) {
             net.phase[i]=0;
    print ("phase "); print (i);  print (" ");
    print (net.phase[i]); print (" ");
    print ("frequency "); print (i); print (" ");
    println (net.naturalFrequency[i]);
     }
} 
else if (key == '8') { println(" Add 180° to all oscillator ");
       for (int i = 0; i < net.size; i++) {
             net.phase[i]=PI;   
    print ("phase "); print (i);  print (" ");
    print (net.phase[i]); print (" ");
    print ("frequency "); print (i); print (" ");
    println (net.naturalFrequency[i]);
     }
} 
// MAKE A SORT OF FOLLOW MODE

} 

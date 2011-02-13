class Sidewalk {
  
  // how many strings to make
  int strings = 10;
  // start and end x position
  int xp0 = 50;
  int xp1 = width-50;
  // array of lengths
  float[] arrLen = new float[strings];
  // length range
  float len0 = 50; float len1 = height-20;
  // timer variables
  float t0 = millis();
  float t1 = t0;  
  // timer - minimum seconds of time between reconfiguring
  float tChange = 3.0;
  // has user plucked a thread since last reconfiguration?
  boolean hasPlayed = false;
  
  // -----------------------------------------------------
  // Constructor
  // -----------------------------------------------------
  Sidewalk () {
    float len;
    float xp = xp0;
    float dx = (xp1-xp0)/(strings-2);
    float yp = yAxis;
    
    // create threads
    for (int i = 0; i < strings; i++) {
      // set lengths randomly
      len = lerp(len0, len1, random(1));
      // draw vertical lines along
      addThread(xp, yp-len/2, xp, yp+len/2);
      xp += dx;
    }
  }
  
  // Update function
  void upd() {
    // how much time elapsed since last reconfigure
    t1 = millis();
    float elap = (t1-t0)/1000;
    // only reconfigure while not currently engaged
    if ((elap > tChange) && !isEngaged && !isMouseDown && hasPlayed) {
      reconfigure();
    }
  }  

  // User played
  void userPlayed() {
    // stoer the last time the user plucked
    t0 = millis();
    if (!hasPlayed) hasPlayed = true;
  }
  
  // Move strings to 
  void reconfigure() {
    hasPlayed = false;
    float len;
    for (int i = 0; i < strings; i++) {
      len = lerp(len0, len1, random(1));
      arrThreads[i].resizeTo(len);
    }
  }  
}


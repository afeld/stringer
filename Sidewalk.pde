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
  
  // Move strings to 
  void reconfigure() {
    float len;
    for (int i = 0; i < strings; i++) {
      len = lerp(len0, len1, random(1));
      arrThreads[i].resizeTo(len);
    }
  }  
}


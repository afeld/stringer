class Sidewalk {
  
  // how many strings to make
  int strings = 10;
  // start and end x position
  int xp0 = 30;
  int xp1 = 50;
  
  // -----------------------------------------------------
  // Constructor
  // -----------------------------------------------------
  Sidewalk () {
    float len;
    float xp = xp0;
    float yp = height/2;
    // create threads
    for (int i = 0; i < strings; i++) {
      len = 25 + random(height-50);
      addThread(xp, yp-len/2, xp, yp+len/2);
      xp += 50;
    }
  }  
}


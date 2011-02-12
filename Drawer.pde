class Drawer {
  
  // start point, end point
  float xp0, yp0, xp1, yp1;
  
  // -----------------------------------------------------
  // Constructor
  // -----------------------------------------------------
  Drawer (float xp0P, float yp0P) {
    // store the start point
    xp0 = xp0P; yp0 = yp0P;
  }
  
  // update my line
  void upd() {
    xp1 = getUserX(); yp1 = getUserY();
    redraw();
  }
  
  // redraw my line
  void redraw() {
    line(xp0, yp0, xp1, yp1);
  }  

  // done with current drawing 
  void done() {
    // create the thread
    addThread(xp0, yp0, xp1, yp1);
  }
}

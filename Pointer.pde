class Pointer {
  float stillThreshold = 2.0;
  
  PVector location = new PVector(0,0);
  PVector prevLocation = new PVector(0,0);
  int stillCount = 0;
  
  void updateLocation(PVector loc){
   this.updateLocation((int)loc.x, (int)loc.y); 
  }
  
  void updateLocation(int x, int y){
    prevLocation.x = location.x;
    prevLocation.y = location.y;
    
    location.x = x;
    location.y = y;
    
    if (isStationary()){
      stillCount += 1;
    } else {
      stillCount = 0;
    }
  };
  
  boolean isStationary(){
    float d = dist(prevLocation.x, prevLocation.y, location.x, location.y);
    return (d < stillThreshold);
  }
  
  boolean atOrigin(){
    return (location.x == 0 && location.y == 0);
  }
}


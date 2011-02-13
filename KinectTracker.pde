class KinectTracker {

  // Size of kinect image
  int kw = 640;
  int kh = 480;
  // Set default threshhold
  int threshold = 970;
  // lerp easing - from 0 to 1, how quickly dot eases to position
  float lerpEase = 0.2;
  // Raw location
  PVector loc;
  // Interpolated location
  PVector lerpedLoc;
  // Depth data
  int[] depth;
  // We'll use a lookup table so that we don't have to repeat the math over and over
  float[] depthLookUp = new float[2048];  
  // Display image
  PImage display;

  // --------------------------------
  // Contstructor
  // --------------------------------
  KinectTracker() {
    
    kinect.start();
    kinect.enableDepth(true);
    // We could skip processing the grayscale image for efficiency
    // but this example is just demonstrating everything
    kinect.processDepthImage(true);
    // create image for display
    display = createImage(kw,kh,PConstants.RGB);
    // location
    loc = new PVector(0,0);
    lerpedLoc = new PVector(0,0);    
    // Lookup table for all possible depth values (0 - 2047)
    for (int i = 0; i < depthLookUp.length; i++) {
      depthLookUp[i] = rawDepthToMeters(i);
    }    
  }

  // Track image
  void track() {

    // Get the raw depth as array of integers
    depth = kinect.getRawDepth();
    // Being overly cautious here
    if (depth == null) return;
    float sumX = 0;
    float sumY = 0;
    float count = 0;
    // go through image
    for(int x = 0; x < kw; x++) {
      for(int y = 0; y < kh; y++) {
        // Mirroring the image
        int offset = kw-x-1+y*kw;
        // Grabbing the raw depth
        int rawDepth = depth[offset];
        // Testing against threshold
        if (rawDepth < threshold) {
          sumX += x;
          sumY += y;
          count++;
        }
      }
    }
    // As long as we found something
    if (count != 0) {
      loc = new PVector(sumX/count,sumY/count);
      // engage
      if (!isEngaged) engage();
    } else {
      // didn't get anything above threshhold, user is not in
      if (isEngaged) disengage();
    }

    // Interpolating the location, doing it arbitrarily for now
    lerpedLoc.x = PApplet.lerp(lerpedLoc.x, loc.x, lerpEase);
    lerpedLoc.y = PApplet.lerp(lerpedLoc.y, loc.y, lerpEase);
  }

  PVector getLerpedPos() {
    return lerpedLoc;
  }

  PVector getPos() {
    return loc;
  }

  void display() {
    // ratio for darkening - 0 to 1
    float rDarken = 0.0;
    //
    PImage img = kinect.getDepthImage();
    // Being overly cautious here
    if (depth == null || img == null) return;
    // Going to rewrite the depth image to show which pixels are in threshold
    // A lot of this is redundant, but this is just for demonstration purposes
    display.loadPixels();
    float rat;
    // go through image
    for(int x = 0; x < kw; x++) {
      for(int y = 0; y < kh; y++) {
        // mirroring image
        int offset = kw-x-1+y*kw;
        // Raw depth
        int rawDepth = depth[offset];
        //PVector v = depthToWorld(x,y,rawDepth);

        int pix = x+y*display.width;
        //
        if (rawDepth < threshold) {
          // set color for the ones in threshhold
          rat = 1-(float)rawDepth/threshold;
          // set the grey value proportional to the depth
          // display.pixels[pix] = color(rat*255);
          display.pixels[pix] = color(50+rat*120);
        } 
        else {
          // couldn't get this to work:
          // float fixDepth =  depthLookUp[rawDepth];
          // display.pixels[pix] = color(round(fixDepth*255));
          
          // this will draw the actual data from the grayscape depth image
          display.pixels[pix] = color(round(red(img.pixels[offset])*rDarken));
        }
      }
    }
    display.updatePixels();

    // Draw the image
    image(display,0,0);
  }

  void quit() {
    kinect.quit();
  }

  int getThreshold() {
    return threshold;
  }

  void setThreshold(int t) {
    threshold =  t;
  }
  
  // These functions come from: http://graphics.stanford.edu/~mdfisher/Kinect.html
  float rawDepthToMeters(int depthValue) {
    if (depthValue < 2047) {
      return (float)(1.0 / ((double)(depthValue) * -0.0030711016 + 3.3309495161));
    }
    return 0.0f;
  }
  
  // Convert depth to world
  PVector depthToWorld(int x, int y, int depthValue) {
  
    final double fx_d = 1.0 / 5.9421434211923247e+02;
    final double fy_d = 1.0 / 5.9104053696870778e+02;
    final double cx_d = 3.3930780975300314e+02;
    final double cy_d = 2.4273913761751615e+02;
  
    PVector result = new PVector();
    double depth =  depthLookUp[depthValue];//rawDepthToMeters(depthValue);
    result.x = (float)((x - cx_d) * depth * fx_d);
    result.y = (float)((y - cy_d) * depth * fy_d);
    result.z = (float)(depth);
    return result;
  }
  
}


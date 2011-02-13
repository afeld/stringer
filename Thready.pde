class Thready {
  
  // current position and original position
  float xp0, yp0, ypt0;
  float xp1, yp1, ypt1;
  // store distance
  float dx, dy;
  // array of current start/end points
  PVector pt0, pt1;
  // store original position
  PVector pto0, pto1;
    
  // my permanent midpoint
  float xMid, yMid;		
  // the position of my swinging pendulum point (midpoint)
  float xc, yc;
  // my grabbed point by user
  float xg, yg, xgi, ygi;
  float xg1, yg1, xg0, yg0;
  // drawing point
  float xd, yd;
  // ratio for curvature. Make this around 0.5 or higher
  float rBezier = 0.2;
  // distance we can pull perpendicularly from middle pt of string (as ratio length)
  // (amplitude of wave)
  float rDistMax = 0.15;
  // minimum distance to force string to move, when you brush it
  float rDistMin = 0.01;
  // max amplitude of wave when oscillating (as ratio of length)
  float rAmpMax = 0.072;
  // minimum distance to move (px), amplitude, so if you brush it it always shows movement
  float ampPxMin = 5;
  // maximum pixel distance to move, amplitude
  float ampPxMax = 33;
  // pan range (-1 to 1) - range is -1 to 1, but make it slight because 
  // it will shift already playing sounds
  float pan0 = -0.4; float pan1 = 0.4;
  // frequency of oscillation - this is the increment per frame for t value.
  // higher gives higher frequency
  float freq0 = 0.5; // frequency for long strings
  float freq1 = 2.5; // frequency for short strings
  float freq;
  
  // amplitude dampening - how quickly it dampens to nothing - ratio 0 to 1
  float ampDamp0 = 0.95;
  float ampDamp1 = 0.87;
  float ampDamp;
  // length where we cap it highest/lowest pitch (px)
  // our longest thread is 658, shortest is 19
  float len0 = 30; float len1 = 480;
  // temporary distance variables
  float distMax; float distPerp;
  // how close do we have to be to instantly grab a thread - perpendicular distance (px)
  float distInstantPerp = 6;  
  
  // stores ratio from 0 to 1 where user has grabbed along the string
  float rGrab, rHalf;
  // my main angle
  float ang; float angOrig;
  // my perpendicular angle
  float angPerp;
  // total length of this thread (when unstretched)
  float len; float lenOrig;
  // how much are we stretched, as a ratio from 0 (straight line) to 1 (max elastic)
  float rStretch = 0;
  // easing resize ratio
  float resizeEase = 0.08;
  
 
  // temporary variables
  float dx0, dy0, dx1, dy1, dist0, dist1;
  float dxBez0, dyBez0, dxBez1, dyBez1;
  
  // my index number within the route sequence
  int ind;
  // stroke
  int str0 = 1; int str1 = 4; int str;
  // hex value
  float hex;
  
  // frame counter
  int ctGrab = 0;
  // oscillation increment
  float t = 0;
  // current amplitude
  float amp, ampMax;
  // current stretch strength as ratio
  float rStrength;
  
  // my pitch index (0, 1, 2...) - and as ratio
  int pitchInd; float rPitch;
  // reference to my audio sample
  AudioSample au;
  // lowest and highest volume for notes triggered by user
  float vol0 = 0.3; float vol1 = 0.6;
  // gain range triggered by user (db change)
  float gain0 = -10; float gain1 = -1;
  // is update on
  boolean isUpdOn = false;
  // oscillation direction (-1 or 1)
  int oscDir;
  
  // currently grabbed
  boolean isGrabbed = false;
  // currently oscillating
  boolean isOsc = false;
  // was just dropped
  boolean isFirstOsc = false;
  // not drawn yet
  boolean isVisible = false; 
  //
  boolean isFirstRun = true;
  // is resizing
  boolean isResizing = false;
  
  // -----------------------------------------------------
  // Constructor
  // -----------------------------------------------------
  Thready (float xp0P, float yp0P, float xp1P, float yp1P, int indP) {
    // store position
    xp0 = xp0P; yp0 = yp0P; 
    xp1 = xp1P; yp1 = yp1P;
    // store as point object
    pt0 = new PVector(xp0, yp0);
    pt1 = new PVector(xp1, yp1);
    // store original position that doesn't move
    pto0 = new PVector(xp0, yp0);
    pto1 = new PVector(xp1, yp1);
    // store my index number
    ind = indP;
    // update position once now
    updPos();
  }

  // -----------------------------------------------------
  // Update functions
  // ----------------------------------------------------- 
  // general update
  void upd() {
    // update position - don't need to trigger unless it's moving
    if (isResizing) updPos();
    // is thread currently grabbed
    if (isGrabbed) {
      updGrab();
    // is thread currently oscillating
    } else if (isOsc) {
      updOsc();
    }
    // redraw
    redraw();
  }
  
  // update position
  void updPos() {
    if (isResizing) {
      yp0 += (ypt0-yp0)*resizeEase;
      yp1 += (ypt1-yp1)*resizeEase;
      // are we there?
      if (abs(ypt0-yp0) < 1) {
        // snap there
        yp0 = ypt0; yp1 = ypt1;
        resizeDone();
      }
    }
    // store values in my point object
    pt0.x = xp0; pt0.y = yp0;
    pt1.x = xp1; pt1.y = yp1;
    // distances
    dx = xp1-xp0;
    dy = yp1-yp0;
    // store midpoint
    xMid = xp0 + dx*0.5;
    yMid = yp0 + dy*0.5;
    // store angle
    ang = atan2(dy, dx);
    // perpendicular angle
    angPerp = PI/2 - ang;
    // set new length
    len = dist(xp0, yp0, xp1, yp1);
    // *** store sin and cos of angle here to not recalculate all the time!
    
    // set my pitch
    if (len > len1) { rPitch = 0; }
    else if (len < len0) { rPitch = 1; }
    else { rPitch = 1-norm(len, len0, len1); }
    // initially set pendulum to midpoint
    xc = xMid; yc = yMid;
    // set my pitch index (0, 1, 2, 3...)
    pitchInd = floor(rPitch*(notes-0.0001));
    // don't run this if we're mid-resize
    if (!isResizing) {
      // need to initialize for that sample?
      if (arrSamples[pitchInd] == null) {
        // load that sample
        String pre = pitchInd < 10 ? "0" : "";
        // store it
        au = arrSamples[pitchInd] = minim.loadSample("cello_" + pre + pitchInd + ".mp3", 1024);
      } else {
        // my audio object
        au = arrSamples[pitchInd];
      }
    }
    // store max distance we can pull from middle of string perpendicularly
    distMax = rDistMax*len;
    //
    if (distMax > ampPxMax) {
      distMax = ampPxMax;
    } else if (distMax < ampPxMin) {
      distMax = ampPxMin;
    }
    // set my oscillation frequency
    freq = lerp(freq0, freq1, rPitch);
    ampDamp = lerp(ampDamp0, ampDamp1, rPitch);
    // set my maximum amplitude
    ampMax = rAmpMax*len;
    if (ampMax < ampPxMin) {
      ampMax = ampPxMin;
    } else if (ampMax > ampPxMax) {
      ampMax = ampPxMax;
    }
    // first time running?
    if (isFirstRun) {
      // store these values because they will change
      lenOrig = len; angOrig = ang;
      // add to route
      // this.route.addToLength(this.len);
      isFirstRun = false;
    } 
  }
  
  // updOsc
  void updOsc() {
	
    // ease it back to the zero line first
    if (isFirstOsc) {
      float ease = 0.8;
      float dxg = xg1 - xg;
      float dyg = yg1 - yg;
      //
      xg += dxg*ease;
      yg += dyg*ease;
      // have we arrived?
      if ((abs(dxg) < 2) && (abs(dyg) < 2)) {
        // initialize
        t = 0; oscDir = 1;
        isFirstOsc = false;
        // which direction it has been going in
        float sx0 = sign(dxg);
        float sx1 = sign(sin(ang));
        // reverse the initial oscillation direction if needed
        if (sx0 != sx1) { this.oscDir *= -1; }
      }
    } else {
      
      // increment counter
      t += freq*oscDir;
      // make c oscillate between 0 and 1 with sin 
      float c = sin(t);
      // dampen the amplitude
      amp *= ampDamp;
      //
      xc = xMid + c*sin(ang)*amp;
      yc = yMid - c*cos(ang)*amp;
      // if amplitude is below mimum, cut it
      if (amp < 0.5) {
        amp = 0; 
        isOsc = false;
      }
    }
  }
  
  // update while grabbed
  void updGrab() {
    float xu = getUserX(); float yu = getUserY();
    // get current mouse position
    xu = getUserX(); yu = getUserY();
    // how far away is it from the line
    float dxu = xu-xp0; float dyu = yu-yp0;
    // angle
    float ang0 = atan2(dyu,dxu); float ang1 = ang-ang0;
    // direct distance 
    //float hyp = Math.sqrt(dxu*dxu + dyu*dyu);
    float hyp = dist(xu, yu, xp0, yp0);
    // perpendicular distance
    distPerp = hyp*sin(ang1);
    // distance parallel along the line
    float distPara = hyp*cos(ang1);
    // how far as a ratio from 0 to 1 are we on the line
    rGrab = lim(distPara/len, 0, 1);
    // normalize it to increase to 1 at the halfway point
    if (rGrab <= 0.5) { rHalf = rGrab/0.5; } else { rHalf = 1-(rGrab-0.5)/0.5; }
    // what distance can we pull the string at this point?
    float distMaxAllow = distMax*rHalf;
    // set the current stretch strength
    rStrength = lim(abs(distPerp)/distMax, 0, 1);

    // has the user's point pulled too far?
    if (abs(distPerp) > distMaxAllow) {
      drop();
    } else {
      // that grabbed point is ok, allow it
      xg = xu; yg = yu;
    }
    //
    ctGrab++;
  }

  // -----------------------------------------------------
  // Redraw function
  // -----------------------------------------------------    
  // redraw
  void redraw() {
    
    // grabbed mode (or on the first osc after being dropped)
    if (isGrabbed || isFirstOsc) {
      xd = xg; yd = yg;
    // oscillating freely mode
    } else {
      xd = xc; yd = yc;
    }
    dx0 = xd-xp0; dy0 = yd-yp0;
    dx1 = xp1-xd; dy1 = yp1-yd;
    // distance
    dist0 = dist(xp0, yp0, xd, yd);
    dist1 = dist(xd, yd, xp1, yp1);
    // move to the center pendulum point
    dxBez0 = rBezier*dist0*cos(ang);
    dyBez0 = rBezier*dist0*sin(ang);		
    // move to the center pendulum point
    dxBez1 = rBezier*dist1*cos(ang);
    dyBez1 = rBezier*dist1*sin(ang);			
    // draw bezier - point, control, control, point
    bezier(xp0, yp0, xd-dxBez0, yd-dyBez0, xd-dxBez0, yd-dyBez0, xd, yd);
    bezier(xd, yd, xd+dxBez1, yd+dyBez1, xd+dxBez1, yd+dyBez1, xp1, yp1);
  }
  
  // -----------------------------------------------------
  // Pluck and grab functions
  // -----------------------------------------------------  
  // brush over this string in one frame
  void pluck(float xp, float yp, boolean byUser) {
    float xu = getUserX(); float yu = getUserY();
    // store as initial position
    xgi = xg = xp; ygi = yg = yp;
    // if it was triggered by a train
    if (byUser) {
      // user's current mouse position
      xu = getUserX(); yu = getUserY();
      // get average speed from main class
      float spd = getSpdAvg();
    }
    // how far away is it from the line
    float dxu = xu-xp0; float dyu = yu-yp0;			
    // use our current xg and yg, that's where the user intersected the string
    float dxg = xgi-xp0; float dyg = ygi-yp0;
    // hypotenuse distance
    float hyp = dist(xp0, yp0, xgi, ygi);
    // as ratio 0 to 1
    rGrab = lim(hyp/len, 0, 1);
    // normalize it to increase to 1 at the halfway point
    if (rGrab <= 0.5) { rHalf = rGrab/0.5; } else { rHalf = 1-(rGrab-0.5)/0.5; }					
    //
    float distMaxAllow = distMax*rHalf;
    // how far do we want it to pull? Base on user's speed
    distPerp = (1-spd)*distMaxAllow;
    // set new strength
    rStrength = lim(abs(distPerp)/distMax, 0, 1);
    // less than minimum? (always vibrate string a little bit)
    if (distPerp < ampPxMin) distPerp = ampPxMin;
    // set it
    xg = xgi + distPerp*cos(angPerp);
    yg = ygi + distPerp*sin(angPerp);	
	
    // reset me to the center point
    xc = xMid; yc = yMid;
    // already oscillating?
    if (isOsc) {
      // already oscillating - boost the oscillation strength just a bit
      rStrength = lim((rStrength*0.5) + (amp/ampMax), 0, 1);
      // set new amplitude
      amp = rStrength*ampMax;				
      // not oscillating - start oscillating now
    } else {
      // store current amplitude based on strength
      amp = rStrength*ampMax;
      // start oscillating
      startOsc();
    }
    // calculate gain
    float gain = lerp(gain0, gain1, rStrength);
    // set pan based on x position - from -1 to 1
    float pan = lerp(pan0, pan1, lim(xu/width, 0, 1));
    //
    playNote(gain, pan);
  }
  
  // grab this string and hold it
  void grab(float xp, float yp, boolean byUser) {
    grabbed++;
    // store as initial position
    xgi = xg = xp; ygi = yg = yp;
    // start counter			
    ctGrab = 0;
    isGrabbed = true;
    // update once now
    updGrab();	
  }

  // drop this thread
  void drop() {
    grabbed--;
    //
    isGrabbed = false;
    // reset me
    xc = xMid; yc = yMid;
    // store current amplitude based on strength
    amp = rStrength*ampMax;
    // calculate gain
    float gain = lerp(gain0, gain1, rStrength);
    // set pan based on x position - from -1 to 1
    float pan = lerp(pan0, pan1, lim(getUserX()/width, 0, 1));
    // play note
    playNote(gain, pan);
    // start oscillation
    this.startOsc();	
  } 

  // -----------------------------------------------------
  // Other functions
  // -----------------------------------------------------
  void playNote(float gain, float pan) {
    // set volume and pan
    if (au.hasControl(Controller.GAIN)) { au.setGain(gain); }
    if (au.hasControl(Controller.PAN)) { au.setPan(pan); }
    // tell sidewalk we played a note
    sidewalk.userPlayed();
    // trigger the sample
    au.trigger();    
  }
  
  void startOsc() {
    // where does the grabbed point want to return to
    xg1 = xp0 + rGrab*dx;
    yg1 = yp0 + rGrab*dy;			
    // store start position
    xg0 = xg; yg0 = yg;			
    // counter
    t = 0;
    // we are on our first cycle of oscillation
    isFirstOsc = isOsc = true;		  
  }
  
  void resizeTo(float l) {
    isResizing = true;
    // store target position
    ypt0 = yAxis-l/2;
    ypt1 = yAxis+l/2;
  }
  
  void resizeDone() {
    isResizing = false;
    // update position one last time
    updPos();  
  }
}


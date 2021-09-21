use <nz/nz.scad>;

$fn = 72;

slop = 0.15;
slack = 0.25;
fudge = 0.01;
fudge2 = 0.02;

lineW = 0.6;

seat = lineW*4;  // thickness of material under bolt heads

m = 4;
mMargin = 4.8;   // thickness of material around bolt heads
mAdjHeadR = m_adjusted_button_head_width(m, slack=slack*2, $fn=$fn) / 2;
mOuterR = mAdjHeadR + mMargin;
mInset = 4;
// mSlot = 10;


rod = [10, 10];
bump = lineW;
bumpR = rod[1]/2 + 1;
plateGap = rod[0] + slop*2 + bump*2;
plateW = mInset + seat - bump;
width = plateGap + plateW*2;
fillet = plateW/2;

// lampBump = bump+1;
// lampGap = 12.5 + slop*2 + lampBump*2;
lampGap = 15 + slack*2;
// 12.5 + slop*2 + lampBump*2 = lampGap;
// lampBump*2 = lampGap - 12.5 - slop*2;
// lampBump = (lampGap - 12.5 - slop*2)/2;
lampBump = (lampGap - (12.5 + slop*2))/2;

echo(lampGap);

knobR = 4.025;
adjKnobR = circumgoncircumradius(r=knobR+slack*2);  // should slack be really be doubled?
knobOuterR = adjKnobR + mMargin;
knobInset = 3.0;

studR = 4.15;
adjStudR = circumgoncircumradius(r=studR+slack*2);  // should slack be really be doubled?
studOuterR = adjStudR + mMargin;
studInset = plateW + bump - 3.0;

hookR = 4;
adjHookR = circumgoncircumradius(r=hookR+slack*2);  // should slack be really be doubled?
hookOuterR = adjHookR + mMargin;
hookInset = plateW + bump - lineW*2;

springInset = hookInset - bump - 1.2;
springA = 72;

stemR = 6.65;  // 6.5;
stemL = 32;


shoulderW   = 40;  // was ~38.5
shoulderA   = 65;  // was ~40°

elbowUpperW = 40;  // was ~38.5
elbowUpperA = 55;  // was ~65°
elbowForeW  = 40;  // was ~38.5
elbowForeA  = 55;  // was ~65°
elbowL      = 65;  // was ~49.5

wristW      = 40;  // was ~31.5
wristL      = 32;  // was ~26.0


shoulder   = [  shoulderW*cos(shoulderA)  ,   shoulderW*sin(shoulderA)  ];

elbowUpper = [elbowUpperW*cos(elbowUpperA), elbowUpperW*sin(elbowUpperA)];
elbowFore  = [ elbowForeW*cos(elbowForeA) ,  elbowForeW*sin(elbowForeA) ];

wristBase  = norm([wristW/2, wristL]);
wristFore  = [square(wristW)/(2*wristBase),   wristL*wristW/wristBase   ];


shoulderSpring = [shoulderW*cos(shoulderA), 45];
elbowSpring = [0, 5];


wristA = atan2(max(studOuterR, knobOuterR)-mOuterR, wristBase);


rodClearance    =  8.5;
wireClearance   = 10.5;
lampClearance   = 17.5;


mBraceFront = 2.5;
mBraceBack  = 3;
mBraceFrontOffset = 1.8125 + 0.15;
mBraceBackOffset  = 1.8125;
mBraceFrontInset = 15;
mBraceBackInset  =  3;


// module teardrop(r) rotate([0,90,0]) extrude(width, center=true) rotate(-90) teardrop(r=r, a=60, truncate=r);

module teardrop_fillet(r) rotate([0,90,0]) extrude(width-fillet*2, center=true) rotate(-90) teardrop(r=r-fillet, a=50, truncate=r);

module hollow(clearance) rotate([0,90,0]) rod(plateGap, r=clearance+slop, center=true);

module bolt() rotate([0,90,0]) translate([0, 0, width/2-mInset]) rotate(90)
  m_bolt(m, shank=width, button=mInset+fudge, nut=[width-mInset*2, width], slack=slack*2);

module knobBolt() rotate([0,-90,0]) {
  translate([0, 0, width/2+fudge]) m_bolt(m, shank=width+fudge2, slack=slack*2);
  translate([0, 0, width/2+fudge]) rod(-mInset-fudge, r=circumgoncircumradius(d=6.7));
  // translate([0, 0, width/2-mInset]) m_bolt(m, button=mInset+fudge, slack=0);
  translate([0, 0, -width/2-fudge]) rod(knobInset+fudge, r=adjKnobR);
}

module studBolt() {
  rotate([0,90,0]) translate([0, 0, width/2+fudge]) {
    m_bolt(m, shank=width/2+fudge, slack=slack*2);
    rod(-knobInset-fudge, r=adjKnobR);
  }
  rotate([0,-90,0]) translate([0, 0, width/2+fudge]) {
    rotate(45) box([m+slop*2, m+slop*2, -width/2-fudge], [0,0,1]);
    rod(-studInset-(lampBump-bump)+(lampGap-plateGap)/2-fudge, r=adjStudR);
  }
}

module hingeHook() {
  // rotate([0,90,0]) translate([0, 0, -width/2-fudge]) rod(width+fudge2, r=adjHookR);
  rotate([0,90,0]) translate([0, 0, width/2+fudge]) m_bolt(m, shank=width+fudge2, slack=slack*2);
  flipX() translate([width/2-hookInset, 0, 0]) rotate([0,90,0]) rod(hookInset+fudge, r=adjHookR);
  flipX()
    rotate([atan2(-elbowFore[1], elbowFore[0])])
      flipY()
        translate([width/2, 0, 0])
          rotate([180, 270, 180])
            hull_rotate_extrude(springA, segments=1)
              tull([0, adjHookR*2-springInset*2, 0], center=true)
                tull([100, 0, 0])
                  spindle(0, r=springInset, $fn=16);
}

module freeHook() {
  // translate([width/2+fudge, 0, 0]) rotate([0, 90, 0]) rotate(atan2(shoulderSpring[0], shoulderSpring[1]-shoulder[1]))
  //   m_bolt(m, shank=width+fudge2, height=-mSlot, slack=slack*2);
  // flipX() translate([-plateGap/2-mInset, 0, 0]) rotate([0,90,0]) m_bolt(m, shank=width, button=mInset+fudge, slack=slack*2);
  flipX() translate([bump-plateGap/2, 0, 0]) rotate([0,90,0]) rotate(90) m_bolt(m, shank=width, nut=[-fudge-bump, mInset], slack=slack*2);
}

module hinge(clearance) {
  hollow(clearance);
  bolt();
}

module bump(r, gap=plateGap, bump=bump) {
  flipX() translate([gap/2, 0, 0]) rotate([0, -90, 0]) rotate_extrude(convexity=1) polygon(
  [ [    0,   bump]
  , [bumpR,   bump]
  , [    r,      0]
  , [bumpR, -fudge]
  , [    0, -fudge]
  ] );
}

module shoulder() {
  difference() {
    union() {
      difference() {
        union() {
          // body
          translate([0, mOuterR, mOuterR]) minkowski() {
            hull() {
              teardrop_fillet(mOuterR);
              translate([0, 0, shoulder[0]]) teardrop_fillet(mOuterR);
              translate([0, shoulder[1], 0]) teardrop_fillet(mOuterR);
              translate([0, shoulderSpring[1], shoulderSpring[0]]) teardrop_fillet(mOuterR);
            }
            sphere(r=circumgoncircumradius(fillet), $fn=$fn/2);
          }
          // stem
          translate([0, mOuterR, stemR*sqrt(2)/2]) rotate([-90])
            extrude(-mOuterR-slack*2-stemL) teardrop(r=stemR, truncate=stemR*sqrt(2)/2);
        }
        box([100, 100, -fillet-fudge], [0,1,1]);
        // rod cut
        translate([0, mOuterR+shoulder[1]/2, mOuterR+shoulder[0]/2]) rotate([-atan2(shoulder[0], shoulder[1])])
          translate([0, 0, -rod[1]/2-slop]) box([plateGap, 100, 100], [0,0,1]);  // TODO: calculate actual bounds
        // hollows
        translate([0, mOuterR, mOuterR]) {
          translate([0, 0, shoulder[0]]) hollow(rodClearance);
          translate([0, shoulder[1], 0]) hollow(wireClearance);
        }
      }
      // bumps
      translate([0, mOuterR, mOuterR]) {
        translate([0, 0, shoulder[0]]) bump(mOuterR);
        translate([0, shoulder[1], 0]) bump(mOuterR);
      }
    }
    // bolts
    translate([0, mOuterR, mOuterR]) {
      translate([0, 0, shoulder[0]]) bolt();
      translate([0, shoulder[1], 0]) knobBolt();
      translate([0, shoulderSpring[1], shoulderSpring[0]]) freeHook();
    }
    // support screws
    translate([0, -slack*2-stemL+mBraceFrontInset, (stemR+stemR*sqrt(2)/2)/2+mBraceFrontOffset]) rotate([90])
      m_bolt(mBraceFront, depth=100, socket=mBraceFrontInset+fudge);  // TODO: calculate actual depth
    translate([0, -slack*2-stemL+mBraceBackInset, (stemR+stemR*sqrt(2)/2)/2-mBraceBackOffset]) rotate([90])
      m_bolt(mBraceBack, depth=100, socket=mBraceBackInset+fudge);  // TODO: calculate actual depth
  }
}

module elbow() {
  difference() {
    union() {
      difference() {
        // body
        translate([0, 0, hookOuterR]) minkowski() {
          hull() {
            flipY() translate([0, elbowL/2, 0]) teardrop_fillet(hookOuterR);
            translate([0, elbowUpper[0]-elbowL/2, elbowUpper[1]]) teardrop_fillet(mOuterR);
            translate([0, elbowL/2-elbowFore[0], elbowFore[1]]) teardrop_fillet(mOuterR);
          }
          sphere(r=circumgoncircumradius(fillet), $fn=$fn/2);
        }
        box([100, 100, -fillet-fudge], [0,0,1]);
        translate([0, 0, hookOuterR]) {
          // rod cuts
          translate([0, elbowUpper[0]/2-elbowL/2, elbowUpper[1]/2]) rotate([atan2(elbowUpper[1], elbowUpper[0])])
            translate([0, 0, -rod[1]/2-slop]) box([plateGap, 100, 100], [0,0,1]);  // TODO: calculate actual bounds
          translate([0, elbowL/2-elbowFore[0]/2, elbowFore[1]/2]) rotate([atan2(-elbowFore[1], elbowFore[0])])
            translate([0, 0, -rod[1]/2-slop]) box([plateGap, 100, 100], [0,0,1]);  // TODO: calculate actual bounds
          difference() {
            intersection() {
              translate([0, elbowUpper[0]/2-elbowL/2+lineW*10, elbowUpper[1]/2]) rotate([atan2(elbowUpper[1], elbowUpper[0])])
                translate([0, 0, -rod[1]/2-slop]) box([plateGap, 100, -100], [0,0,1]);  // TODO: calculate actual bounds
              translate([0, elbowL/2-elbowFore[0]/2-lineW*10, elbowFore[1]/2]) rotate([atan2(-elbowFore[1], elbowFore[0])])
                translate([0, 0, -rod[1]/2-slop]) box([plateGap, 100, -100], [0,0,1]);  // TODO: calculate actual bounds
            }
            flipY() translate([0, elbowL/2, 0]) hollow(wireClearance+lineW*4);
            translate([0, elbowUpper[0]-elbowL/2, elbowUpper[1]]) hollow(rodClearance+lineW*4);
            translate([0, elbowL/2-elbowFore[0], elbowFore[1]]) hollow(rodClearance+lineW*4);
          }
        }
        // hollows
        translate([0, 0, hookOuterR]) {
          flipY() translate([0, elbowL/2, 0]) hollow(wireClearance);
          translate([0, elbowUpper[0]-elbowL/2, elbowUpper[1]]) hollow(rodClearance);
          translate([0, elbowL/2-elbowFore[0], elbowFore[1]]) hollow(rodClearance);
        }
      }
      // bumps
      translate([0, 0, hookOuterR]) {
        flipY() translate([0, elbowL/2, 0]) bump(hookOuterR);
        translate([0, elbowUpper[0]-elbowL/2, elbowUpper[1]]) bump(mOuterR);
        translate([0, elbowL/2-elbowFore[0], elbowFore[1]]) bump(mOuterR);
      }
    }
    // bolts
    translate([0, 0, hookOuterR]) {
      translate([0, elbowSpring[0], elbowSpring[1]]) freeHook();
      translate([0, elbowL/2, 0]) bolt();  // hingeHook();
      translate([0, -elbowL/2, 0]) bolt();
      translate([0, elbowUpper[0]-elbowL/2, elbowUpper[1]]) bolt();
      translate([0, elbowL/2-elbowFore[0], elbowFore[1]]) bolt();
    }
  }
}

module wrist()
  rotate_about([0, -wristBase/2, mOuterR], [wristA]) {
    difference() {
      union() {
        difference() {
          // body
          translate([0, 0, mOuterR]) minkowski() {
            hull() {
              translate([0, -wristBase/2, 0]) rotate([-wristA]) teardrop_fillet(mOuterR);
              translate([0, wristBase/2, 0]) rotate([-wristA]) teardrop_fillet(max(studOuterR, knobOuterR));
              translate([0, wristFore[0]-wristBase/2, wristFore[1]]) rotate([-wristA]) teardrop_fillet(mOuterR);
            }
            rotate([-wristA]) sphere(r=circumgoncircumradius(fillet), $fn=$fn/2);
          }
          rotate_about([0, -wristBase/2, mOuterR], [-wristA]) box([100, 100, -fillet*2-fudge], [0,0,1]);
          // rod cuts
          translate([0, wristFore[0]/2-wristBase/2, mOuterR+wristFore[1]/2]) rotate([atan2(wristFore[1], wristFore[0])])
            translate([0, 0, -rod[1]/2-slop]) box([plateGap, 100, 100], [0,0,1]);  // TODO: calculate actual bounds
          translate([0, wristBase/2, mOuterR]) rotate([atan2(wristFore[1], wristFore[0])])
            translate([0, 0, lampClearance+slop]) box([lampGap, 100, -100], [0,0,1]);  // TODO: calculate actual bounds
          // hollows
          translate([0, 0, mOuterR]) {
            translate([0, -wristBase/2, 0]) rotate([-wristA]) hollow(rodClearance);
            translate([0, wristFore[0]-wristBase/2, wristFore[1]]) rotate([-wristA]) hollow(wireClearance);
          }
        }
        // bumps
        translate([0, 0, mOuterR]) {
          translate([0, -wristBase/2, 0]) rotate([-wristA]) bump(mOuterR);
          translate([0, wristBase/2, 0]) rotate([-wristA]) bump(max(studOuterR, knobOuterR), gap=lampGap, bump=lampBump);
          translate([0, wristFore[0]-wristBase/2, wristFore[1]]) rotate([-wristA]) bump(mOuterR);
        }
      }
      // bolts
      translate([0, 0, mOuterR]) {
        translate([0, wristBase/2, 0]) rotate([-wristA]) rotate(180) studBolt();
        translate([0, -wristBase/2, 0]) rotate([-wristA]) rotate(180) bolt();
        translate([0, wristFore[0]-wristBase/2, wristFore[1]]) rotate([-wristA]) rotate(180) bolt();
      }
    }
  }

// translate([0, 100, 0])
//   rotate([90])
//     shoulder();
// // rotate([180])
//   elbow();
// translate([0, -100, 0])
//   wrist();

// render()
// shoulder();
elbow();
// wrist();

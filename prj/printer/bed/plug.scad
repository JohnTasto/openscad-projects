use <nz/nz.scad>;

$fn = 60;

slop = 0.2;
margin = 5;
fillet = margin+3.5/2;

gauge = 2;
lipH = 13.4;

// #define DEFAULT_AXIS_STEPS_PER_UNIT    { 402.70, 400.90, 1600, 398.01, 388.35 }  // 1/64 microstepping
// actual measured values:
holeW = 152.75;   // printed at 153
holeSD = 29.00;   // printed at 28.75   // 29 fits snuggly
holeLD = 181.5;   // printed at 180.75  // 181 fits snuggly, 181.5 is too long

module large(test=false) {
  base = test ? 0.5 : lipH;
  height = base + gauge;
  difference() {
    union() {
      box([holeW-slop, holeLD-3.5-slop, height], [0,0,1]);
      box([holeW-3.5-slop, holeLD-slop, height], [0,0,1]);
      box([holeW+2*margin, holeLD+2*margin-2*fillet, base], [0,0,1]);
      box([holeW+2*margin-2*fillet, holeLD+2*margin, base], [0,0,1]);
      flip() flip([0,1,0]) translate([holeW/2+margin-fillet, holeLD/2+margin-fillet, 0])
        cylinder(base, r=fillet);
    }
    if (test) translate([0,0,0.5]) box([holeW-10, holeLD-10, height+2], [0,0,1]);
    flip() flip([0,1,0]) translate([holeW/2-slop/2-3.5/2, holeLD/2-slop/2-3.5/2, height])
      m_bolt(3, shank=height+1, nut=test?undef:[height-3, height+1]);
  }
}

flangeW = 152;
flangeY = 19;  // from edge
flangeR = 20;

screwW = 81 - 3.5;
screwY = 11.75 - 3.5/2;  // from edge

wiresXL = -17.75 - 7.5/2;
wiresXR = 36.5 + 7.5/2;
wiresXC = wiresXL/2 + wiresXR/2;
wiresW = wiresXR - wiresXL;

leadscrewY = 15.75;  // from edge
leadscrewR = 11;

module small(test=false) {
  base = test ? 0.5 : lipH;
  height = base + gauge;
  difference() {
    union() {
      // lip
      box([holeW-slop, holeSD-3.5-slop, height], [0,0,1]);
      box([holeW-3.5-slop, holeSD-slop, height], [0,0,1]);
      flip() translate([holeW/2-slop/2-3.5/2, holeSD/2-slop/2-3.5/2, 0])
        cylinder(height, d=3.5);
      // base
      box([holeW+2*margin, holeSD+2*margin-2*fillet, base], [0,0,1]);
      box([holeW+2*margin-2*fillet, holeSD+2*margin, base], [0,0,1]);
      flip() flip([0,1,0]) translate([holeW/2+margin-fillet, holeSD/2+margin-fillet, 0])
        cylinder(base, r=fillet);
      // screws
      flip() translate([screwW/2, holeSD/2+screwY, 0]) {
        cylinder(base, r=fillet);
        box([2*fillet, screwY+1, base], [0,-1,1]);
      }
    }
    if (test) translate([0,0,0.5]) box([holeW-10, holeSD-10, height+2], [0,0,1]);
    // screws
    flip() translate([holeW/2-slop/2-3.5/2, slop/2+3.5/2-holeSD/2, height])
      m_bolt(3, shank=height+1, nut=test?undef:[height-3, height+1]);
    flip() translate([screwW/2, holeSD/2+screwY, base])
      m_bolt(3, shank=base+1, nut=test?undef:[base-3, base+1]);
    // flanges
    flip() translate([flangeW/2, holeSD/2+flangeY, -1])
      cylinder(height+2, r=flangeR+1);
    // wires
    translate([wiresXC, -holeSD/2, -1]) {
      flip() translate([wiresW/2-fillet, 0, 0]) cylinder(height+2, r=fillet);
      box([wiresW, fillet+1, height+2], [0,-1,1]);
      box([wiresW-2*fillet, 2*fillet, height+2], [0,0,1]);
    }
    // leadscrew
    translate([0, holeSD/2+leadscrewY, -2]) cylinder(height+2, r=leadscrewR+1);
  }
}

rotate(90) large(test=false);
// rotate(90) small(test=false);

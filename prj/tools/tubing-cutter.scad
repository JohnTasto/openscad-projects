use <nz/nz.scad>


// Wall Line Count - 3
// Fill Gaps Between Walls - Nowhere
// Initial Bottom Layers - as manny as necessary to support internal structure
// Infill Density - 0%
// Combing Mode - All
// Max Comb Extra Distance - 20mm
// Avoid Printed Parts While Traveling - No
// Regular Fan Speed - 0
// Support Density - 50% (ends up being 100% for the Tab Anti Warping plugin)


fn = 60;

fudge  = 0.01;
fudge2 = 0.02;

slop = 0.14;

lineW = 0.4;
layerH0 = 0.32;
layerHN = 0.2;

// walls
cutWall = lineW*6;
jigWall = lineW*2;
base    = 1;

// tubing
tubeMaxL = 30;
tubeMinL = 24;
tubeD    = 3;

// bolt
mD     =  3;
mH     = 12;
mHeadH =  3;

// blade
bladeD  =  0.25;
bladeW  = 50;
bladeH  = 12;
bladeOL =  0.25;

supportL = 10;


// calculations

tubeR = circumgoncircumradius(d=tubeD+slop*2, $fn=fn);
mHeadR = m_adjusted_socket_head_width(mD, $fn=fn)/2;

jigH = round_absolute_height_layer(base*2 + mHeadR*2       , layerHN, layerH0);
cutB = floor_absolute_height_layer(jigH/2 - tubeR - bladeOL, layerHN, layerH0);
cutH = floor_absolute_height_layer(cutB + bladeH           , layerHN, layerH0);

cutL = cutWall*2 + slop*2 + bladeD;
jigL = tubeMaxL + mH + mHeadH - cutL/2;
preL = supportL + cutL/2;

jigW = jigH + jigWall*2 - layerHN;
cutW = cutWall*2 + slop*2 + bladeW;

jigFillet = jigW/2 - mHeadR;

mouthR = lineW*2+slop;
mouthH = mouthR*4;

tubeRangeL = tubeMaxL - tubeMinL;

threadL = mH - tubeRangeL;

echo(str("Thread length: ", threadL, "mm"));


module mouth() polygon(
  [ [-fudge  ,         fudge     ]
  , [ mouthR ,         fudge     ]
  , [ mouthR ,        -layerHN/2 ]
  , [ 0      , -mouthH-layerHN/2 ]
  , [-fudge  , -mouthH-layerHN/2 ]
  ]);

difference() {
  union() {
    // cut body
    extrude(cutH, convexity=2) rect([cutW, cutL], [0,0], r=cutWall+slop, $fn=fn);
    difference() {
      // jig body
      extrude(jigH, convexity=2) translate([0, preL/2-jigL/2]) rect([jigW, preL+cutL+jigL], [0,0], r=jigFillet, $fn=fn);
      // window
      translate([0, 0, jigH/2]) intersection() {
        translate([0, preL+cutL/2-jigWall, 0]) flipZ() rotate([90]) extrude(tubeMaxL+preL+cutL/2-jigWall, convexity=2) polygon(
          [ [        fudge ,        fudge ]
          , [ jigH/2+fudge , jigH/2+fudge ]
          , [-jigH/2-fudge , jigH/2+fudge ]
          , [       -fudge ,        fudge ]
          ]);
        extrude(jigH+fudge2, center=true) translate([0, (preL-jigL+mHeadH+mH-jigWall)/2])
          rect([jigW-jigWall*2, preL+cutL+jigL-mHeadH-mH-jigWall], [0,0], r=jigFillet-jigWall, $fn=fn);
      }
    }
    // braces
    flipX() flipY() translate([jigW/2, cutL/2, jigH]) rotate([90, 0, 90]) extrude(-jigWall) polygon(
      [ [     -fudge     , cutH-jigH-layerHN/2 ]
      , [      0         , cutH-jigH-layerHN/2 ]
      , [ preL-jigFillet ,           0         ]
      , [ preL-jigFillet ,          -fudge     ]
      , [     -fudge     ,          -fudge     ]
      ]);
  }
  // blade hole
  translate([0, 0, cutB]) extrude(cutH-cutB+fudge) rect([bladeW+slop*2, bladeD+slop*2], [0,0], r=slop, $fn=fn);
  flipX() translate([bladeW/2, 0, cutH]) rotate([90, 0,  0]) extrude(bladeD, center=true) mouth();
  flipY() translate([0, bladeD/2, cutH]) rotate([90, 0, 90]) extrude(bladeW, center=true) mouth();
  flipX() flipY() translate([bladeW/2, bladeD/2, cutH]) revolve($fn=fn) mouth();
  // tubing hole
  translate([0, preL+cutL/2+fudge, jigH/2]) rotate([90]) rod(preL+cutL/2+tubeMaxL+fudge, r=tubeR, $fn=fn);
  // bolt hole
  translate([0, -cutL/2-jigL+mHeadH+tubeRangeL, jigH/2]) rotate([90]) m_bolt(mD, depth=threadL, socket=mHeadH+tubeRangeL+fudge, $fn=fn);
}

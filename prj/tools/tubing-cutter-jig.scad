use <nz/nz.scad>

// TODO: pull out common expressions

fn = 60;

fudge  = 0.01;
fudge2 = 0.02;

slop = 0.15;

lineW = 0.4;
wall = lineW*6;

// cutter
base = 1.75;
mountW = 22.6;
mountD = 10.3;
mountH =  6.5;
bladeD =  0.5;
bladeH = 10.5;

extraTop = 0.2;

mountCornerMaxD = 2;
mountCornerMinW = 1.3;

// tubing
tubeMaxL = 30;
tubeMinL = 24;
tubeD    = 3;

// bolt
mD     =  3;
mH     = 12;
mHeadH =  3;

r = circumgoncircumradius(d=tubeD+slop*2, $fn=fn);

l = wall + slop + mountD/2 + tubeMaxL + mH + mHeadH;
w = wall*2 + slop*2 + mountW;
h = base*2 + r*2;

tubeRangeL = tubeMaxL - tubeMinL;

threadL = mH - tubeRangeL;

echo(str("Thread length: ", threadL, "mm"));

difference() {
  union() {
    extrude(h+extraTop, convexity=2) difference() {
      union() {
        // mount body
        translate([0, l/2-wall-slop-mountD/2]) {
          rect([w-wall*2, mountD+slop*2+wall*2], [0,0]);
          rect([w, mountD+slop*2], [0,0]);
          flipX() flipY() translate([w/2-wall, mountD/2+slop]) circle(wall, $fn=fn);
        }
        // rail body
        union() {
          rect([h+extraTop*2+wall*2, l-wall*2], [0,0]);
          rect([h+extraTop*2, l], [0,0]);
          flipX() translate([h/2+extraTop, wall-l/2]) circle(wall, $fn=fn);
        }
      }
      // mount hole
      translate([0, l/2-wall]) rect([mountW+slop*2, -mountD-slop*2], [0,1]);
    }
    // tubing guide
    extrude(h/2+extraTop-r*sqrt(2)/2) translate([0, l/2-wall-slop-mountD/2-bladeD/2]) rect([r*2*sqrt(2)/2+lineW*4, bladeD/2-mountD/2-slop-fudge], [0,1]);
    // mount corners
    extrude(h+extraTop-mountH) translate([0, l/2-wall-slop-mountD/2]) flipX() flipY() translate([mountW/2+slop, mountD/2+slop]) polygon(
      [ [  fudge                                  ,  fudge           ]
      , [  fudge                                  , -mountCornerMaxD ]
      , [ -mountCornerMinW-slop*2                 , -mountCornerMaxD ]
      , [ -mountCornerMinW-slop*2-mountCornerMaxD ,  fudge           ]
      ]);
  }
  // tubing hole
  translate([0, l/2+fudge, h/2+extraTop]) rotate([90]) rod(fudge+wall+slop+mountD/2+tubeMaxL, r=r, $fn=fn);
  // bolt hole
  translate([0, -l/2+mHeadH+tubeRangeL, h/2+extraTop]) rotate([90]) m_bolt(mD, depth=threadL, socket=mHeadH+tubeRangeL+fudge, $fn=fn);
  // window
  translate([0, l/2-wall*2-slop*2-mountD, h/2+extraTop]) rotate([90]) extrude(tubeMaxL-wall-slop-mountD/2, convexity=2) {
    polygon(
      [ [     fudge,     fudge]
      , [ h/2+fudge, h/2+fudge]
      , [-h/2-fudge, h/2+fudge]
      , [    -fudge,     fudge]
      ]);
    polygon(
      [ [     fudge,              -fudge]
      , [ h/2+fudge, -h/2-extraTop-fudge]
      , [-h/2-fudge, -h/2-extraTop-fudge]
      , [    -fudge,              -fudge]
      ]);
  }
}

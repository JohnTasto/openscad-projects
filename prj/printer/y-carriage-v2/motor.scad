use <nz/nz.scad>;
use <base.scad>;
use <../x-carriage/base.scad>;
use <../belt/gear12.scad>;


show_original = false;
show_new = true;

/* [Components] */
show_rail = true;
show_gear = true;
show_wall = false;

/* [X Carriage] */
show_x_carriage = true;
home_x_carriage = false;
transparent_x_carriage = true;


/* [Hidden] */

fn = 12;

aluCarriageOffset = 1.0;   // was 1.0 last print
slide = 3;                 // was 2.5 last print
mZ = 0;
mY = 6 + aluCarriageOffset;
mX = -1;                   // was -1.5 last print
mH = 31;    // holes
mD = 42.5;  // width & height
mL = 34.5;  // length
mBumpD = 23;
mBumpL = 2.25;
shaftD = 10;
shaftL = 2.4;
pulleyD = 16;
pulleyL = max(14.5, 28.5-shaftL-mBumpL-mY, 21-shaftL-mBumpL);
// shaftL = 20 +- 1
// pulleyL = 14
mPlate = 10;
heatsinkClearance = 0.5;
mPlug = 14;


module y_carriage_motor(color) {
  color(color) render(convexity=2*clampTeeth())
    difference() {
      union() {
        rotate([0,0,180]) y_carriage();
        translate([mX, mY, mZ]) {
          // motor plate
          box([mH+slide, mPlate, mD], [0,1,0]);
          box([mD+slide, mPlate, mH], [0,1,0]);
          flip() flip([0,0,1])
            translate([mH/2+slide/2, 0, mH/2]) rotate([-90,0,0]) cylinder(mPlate, d=mD-mH);
          // long motor screw (might need overlapping a bit)
          translate([ycW()/2-mX, 0, mD/2]) box([mH/2+slide/2-ycW()/2+mX, ycL()/2-mY, mD-mH], [1,1,-1]);
          translate([mH/2+slide/2, 0, mH/2]) rotate([-90,0,0]) cylinder(ycL()/2-mY, d=mD-mH);
        }
      }

      // cable hole
      translate([0, xRodWall()-ycL()/2, keel()])
        box([ycW()+2, xRodD(), max(mPlug, mZ+mD/2-keel())], [0,1,1]);

      // motor hole
      translate([0, mY, mZ]) box([ycW()+2, mL, mD], [0,-1,0]);

      translate([mX, mY, mZ]) {
        // motor bump hole
        translate([slide/2, -1, 0]) {
          rotate([-90,0,0]) cylinder(mBumpL+1, d=mBumpD);
          box([slide+mD/2+1, mBumpL+1, mBumpD], [-1,1,0]);
        }

        // motor shaft hole
        translate([slide/2, mBumpL-1, 0]) {
          rotate([-90,0,0]) cylinder(shaftL+2, d=shaftD);
          box([slide+mD/2+1, shaftL+2, shaftD], [-1,1,0]);
        }

        // pulley hole
        translate([slide/2, mBumpL+shaftL, 0]) {
          rotate([-90,0,0]) cylinder(pulleyL, d=pulleyD);
          box([slide+mD/2+1, pulleyL, pulleyD], [-1,1,0]);
        }

        // clearance for heatsinks
        translate([0, 0, -mD/2]) rotate([45,0,0]) box([mD+slide+2, 2, 5], [0,0,0]);

        // long motor screw hole
        translate([0, 26, 0])
          translate([mH/2-slide/2, 0,  mH/2]) rotate([-90,0,0]) m_bolt(3, shank=40, washer=50, width=slide);
        // short motor screw holes
        translate([0, 4, 0]) {
          translate([slide/2-mH/2, 0,  mH/2]) rotate([-90,180,0]) m_bolt(3, shank=10, washer=mPlate-3.995, width=slide);
          translate([mH/2-slide/2, 0,  -mH/2]) rotate([-90,0,0]) m_bolt(3, shank=10, washer=mPlate-3.995, width=slide);
          translate([slide/2-mH/2, 0,  -mH/2]) rotate([-90,180,0]) m_bolt(3, shank=10, washer=mPlate-3.995, width=slide);
        }

        // carriage motor back screws
        back = mD/2 + slide/2;
        translate([back-3, mPlate/2, 0])
          flip([0,0,1]) translate([0, 0, mH/2-6.5]) rotate([0,90,0])
            m_bolt(3, depth=18, shank=back-3-ycW()/2, button=50);
      }
    }
}

module front_block() translate([-100,-100,-100]) cube([100, 200, 200]);
module back_block() translate([0.000001,-100,-100]) cube([100, 200, 200]);

module y_carriage_motor_front() {
  intersection() {
    y_carriage_motor();
    front_block();
  }
}

module y_carriage_motor_back() {
  intersection() {
    y_carriage_motor();
    back_block();
  }
}

if (show_original) color([.25,.25,.25,.5]) {
  translate([ycW()/2, 0, 16.625]) rotate([0,-90,0]) import("ref/y-carriage-primary-lm8uu.stl");
  translate([ycW()/2, -5.5, 4.95325]) rotate([0,90,0]) import("ref/y-carriage-primary-back.stl");
}

if (show_new) color([.5,.5,.5,.75])
  y_carriage_motor($fn=fn);

if (show_rail) rotate([0,0,180])
  y_rail($fn=fn);

if (show_gear) translate([mX, mY+13, mZ]) rotate(-90)
  gear12(color=[.75, .75, .75, .75], $fn=fn);

if (show_wall) color([.75,.75,.75,.25]) translate([yRodSide(), -100, -100])
  cube([6, 200, 200]);

if (show_x_carriage) translate([home_x_carriage ? mX-85/2-mD/2-slide/2 : -100, 0, 0])
  x_carriage(
    color=[.75, .75, .75, transparent_x_carriage ? .25 : 1],
    block=[.75, .75, .75, transparent_x_carriage ? .25 : 1],
    bltouch=[.75, .75, .75, .75],
    feederTabs=[.75, .75, .75, .25]
  );

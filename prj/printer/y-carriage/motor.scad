use <nz/nz.scad>;
use <base.scad>;

fn = 12;

show_original = false;
show_new = true;
show_rail = true;
show_wall = false;

if (show_original) {
  color([.25,.25,.25,.5]) {
    translate([0, 0, 16.625]) rotate([0,-90,0]) import("ref/y-carriage-primary-lm8uu.stl");
    translate([0, -5.5, 4.95325]) rotate([0,90,0]) import("ref/y-carriage-primary-back.stl");
  }
}

aluCarriageOffset = 1.0;
slide = 2.5;
mZ = 0;
mY = 6 + aluCarriageOffset;
mX = -11;
mH = 31;    // holes
mD = 42.5;  // width/height
mL = 34.5;  // length
mBumpD = 23;
mBumpL = 2.25;
shaftD = 10;
shaftL = 2.4;
pulleyD = 16;
pulleyL = max(14.5, 28.5-shaftL-mBumpL-mY, 21-shaftL-mBumpL);
// shaft 20 +- 1
// pulley is 14
mPlate = 10;
heatsinkClearance = 0.5;

module y_carriage_motor() {
  difference() {
    union() {
      rotate([0,0,180]) y_carriage_base();
      // translate([mX-mD/2-slide/2, mY, mZ-mD/2]) cube([mD+slide, mPlate, mD]);
      translate([mX, mY, mZ]) box([mH+slide, mPlate, mD], [0,1,0]);
      translate([mX, mY, mZ]) box([mD+slide, mPlate, mH], [0,1,0]);
      translate([mX+mH/2+slide/2, mY, mZ+mH/2]) rotate([-90,0,0]) cylinder(mPlate, d=mD-mH);
      translate([mX+mH/2+slide/2, mY, mZ-mH/2]) rotate([-90,0,0]) cylinder(mPlate, d=mD-mH);
      translate([mX-mH/2-slide/2, mY, mZ+mH/2]) rotate([-90,0,0]) cylinder(mPlate, d=mD-mH);
      translate([mX-mH/2-slide/2, mY, mZ-mH/2]) rotate([-90,0,0]) cylinder(mPlate, d=mD-mH);
    }
    translate([-20, -39, 6.5]) cube([21, 8, max(14, 36+mZ-mD/2)]);
    translate([-20, mY-mL, mZ-mD/2]) cube([21, mL, mD]);
    translate([mX+slide/2, mY-1, mZ]) rotate([-90,0,0]) cylinder(mBumpL+1, d=mBumpD);
    translate([mX-slide/2-mD/2-1, mY-1, mZ-mBumpD/2]) cube([slide+mD/2+1, mBumpL+1, mBumpD]);
    translate([mX+slide/2, mY+mBumpL-1, mZ]) rotate([-90,0,0]) cylinder(shaftL+2, d=shaftD);
    translate([mX-slide/2-mD/2-1, mY+mBumpL-1, mZ-shaftD/2]) cube([slide+mD/2+1, shaftL+2, shaftD]);
    translate([mX+slide/2, mY+mBumpL+shaftL, mZ]) rotate([-90,0,0]) cylinder(pulleyL, d=pulleyD);
    translate([mX-slide/2-mD/2-1, mY+mBumpL+shaftL, mZ-pulleyD/2]) cube([slide+mD/2+1, pulleyL, pulleyD]);
    translate([mX, mY+4, mZ]) {
      translate([ mH/2-slide/2, 0,  mH/2]) rotate([-90,  0,0]) m_bolt(3, shank=10, washer=mPlate-3.995, width=slide);
      translate([ mH/2-slide/2, 0, -mH/2]) rotate([-90,  0,0]) m_bolt(3, shank=10, washer=mPlate-3.995, width=slide);
      translate([-mH/2+slide/2, 0,  mH/2]) rotate([-90,180,0]) m_bolt(3, shank=10, washer=mPlate-3.995, width=slide);
      translate([-mH/2+slide/2, 0, -mH/2]) rotate([-90,180,0]) m_bolt(3, shank=10, washer=mPlate-3.995, width=slide);
    }
    translate([0, mY+mPlate/2, mZ]) {
      translate([8, 0, mH/2-6.5]) rotate([0,90,0]) m_bolt(3, depth=18, shank=8, button=50);  // clearance for
      translate([8, 0, 6.5-mH/2]) rotate([0,90,0]) m_bolt(3, depth=18, shank=8, button=50);  //   16mm screw
    }
    // clearance for heatsinks
    translate([mX, mY, mZ-mD/2]) rotate([45,0,0]) cube([mD+slide+2, 2, 5], center=true);
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

if (show_new) color([.5,.5,.5,1]) y_carriage_motor($fn=fn);

module y_rail_motor() {
  rotate([0,0,180]) y_rail();
}

if (show_rail) color([.75,.75,.75,.25]) y_rail_motor($fn=fn);

if (show_wall) color([.75,.75,.75,.25]) translate([22.5-9.5, -100, -100]) cube([6, 200, 200]);

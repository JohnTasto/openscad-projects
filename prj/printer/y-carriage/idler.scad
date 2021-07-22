use <nz/nz.scad>;
use <base.scad>;

fn = 12;

show_original = false;
show_new = true;
show_rail = true;

if (show_original) {
  color([.25,.25,.25,.5])
    translate([0, 0, 24]) rotate([0,90,0]) import("ref/y-carriage-seconday-lm8uu.stl");
}

reverse = false;
aluCarriageOffset = 1.0;  // somehow the motor pulley is still about 1mm behind the idler
iZ = 0;
axleD = 8.25;
axleL = 27;
idlerD = 16;
idlerL = 21.5;
mid = 13.25+aluCarriageOffset+(reverse?5:0);

module y_carriage_idler() {
  difference() {
    y_carriage_base();
    translate([-1,  mid-idlerL/2, iZ-idlerD/2]) cube([21, idlerL, idlerD]);
    translate([7.5, mid-axleL/2, iZ]) rotate([-90,0,0]) cylinder(axleL, d=axleD);
    translate([-1,  mid-axleL/2, iZ-axleD/2]) cube([8.5, axleL, axleD]);
  }
}

if (show_new) color([.5,.5,.5,1]) y_carriage_idler($fn=fn);

module y_rail_idler() {
  y_rail();
}

if (show_rail) color([.75,.75,.75,.25]) y_rail_idler($fn=fn);

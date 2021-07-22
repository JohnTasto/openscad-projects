use <nz/nz.scad>;

fn = 36;


gearL = 14.15;
thinL = 1.05;
teethL = 7;
thickL = 6.1;
gearD = 13;
teethD = 9.5;
shaftD = 5;


assert(epsilon_equals(gearL, thinL+teethL+thickL));

module gear12(color)
  color(color) render(convexity=2)
    difference() {
      union() {
        translate([gearL/2, 0, 0]) rotate([0,-90,0]) cylinder(thinL, d=gearD);
        translate([gearL/2, 0, 0]) rotate([0,-90,0]) cylinder(gearL, d=teethD, $fn=12);
        translate([-gearL/2, 0, 0]) rotate([0,90,0]) cylinder(thickL, d=gearD);
      }
      translate([gearL/2+1, 0, 0]) rotate([0,-90,0]) cylinder(gearL+2, d=shaftD);
    }

gear12($fn=fn);

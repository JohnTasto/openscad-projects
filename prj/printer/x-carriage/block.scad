use <nz/nz.scad>;

$fs = 1;

w = 87;
d = 16;
h = 12.75;

m3_shank = 3.5;
m3_thread = 2.5;

module block(color, bltouch=false, feederTabs=false) {
  translate([0, -d/2, 0]) {

    if (bltouch) color(bltouch) render(convexity=7)
      translate([-38, -5-1.5, 8.5]) {
        translate([0, 0, 3.75]) rotate([0,180,0]) import("ref/bltouch-bracket-v3.stl");
        translate([-15.5, 0, 6.25]) rotate(90) import("ref/bl-touch.stl");
      }

    color(color) render(convexity=8)
      difference() {
        box([w, d, h], [0,1,1]);

        // heat break
        flip() translate([16.5, 6.5, -1]) cylinder(h+2, d=6);
        flip() translate([16.5, -1, h/2 /*guess*/]) rotate([-90,0,0]) cylinder(d/2, d=m3_thread);

        // top plate
        translate([0, 3.5, -1]) cylinder(h+2, d=m3_thread);
        translate([0, 13.5, -1]) cylinder(h+2, d=m3_thread);

        // mount
        flip() translate([37, 8.5, -1]) cylinder(6.5+1, d=m3_thread);

        // motors/fans
        flip() translate([7, -1, 8.5]) rotate([-90,0,0]) cylinder(d+2, d=m3_shank);
        flip() translate([38, -1, 8.5]) rotate([-90,0,0]) cylinder(d+2, d=m3_shank);
      }

    if (feederTabs) color(feederTabs) render(convexity=2)
      flip() translate([w/2, 1, 44]) box([10.5, 10, 7], [1,1,-1]);
  }
}

block(bltouch=true, feederTabs=true);

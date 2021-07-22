use <nz/nz.scad>
use <standoff.scad>

$fn = 36;

// Pi Cam 2.1 25x24, m2 screws 21x12.5


union() {
  translate([0, 24-12.5/2-(25-21)/2, 0]) flipX() flipY() translate([21/2, 12.5/2, 0]) standoff(2-.1, 1.6, 7);
  minkowski() {
    box([25, 24, 1], [0,1,1]);
    cylinder(0.5, d=6);
  }
}

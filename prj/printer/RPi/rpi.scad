use <nz/nz.scad>
use <standoff.scad>

$fn = 36;


// RPi 56x85, m2.5 screws 49x58
// Buck converter 21x43, m3 screws 2.5 from long edge, 6.5 from short edge


module rpi() translate([0, 85-58/2-(56-49)/2, 0]) flipX() flipY() translate([49/2, 58/2, 0]) standoff(2-.1, 1.6, 8.5);
// box([56, 85, 1], [0,1,1]);

module buck() {
  translate([2.5-21/2, 6.5, 0]) standoff(3-.1, 1.6, 8.5);
  translate([21/2-2.5, 43-6.5, 0]) standoff(3-.1, 1.6, 8.5);
}
// box([21, 43, 1], [0,1,1]);

union() {
  translate([56/2, 0, 0]) rpi();
  translate([-21/2-21, 0, 0]) buck();
  minkowski() {
    translate([56, 0, 0]) box([2*21+56, 85, 1], [-1, 1, 1]);
    cylinder(0.5, d=6);
  }
}

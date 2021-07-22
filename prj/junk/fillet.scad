use <nz/nz.scad>

difference() {
  union() {
    box([20, 20, 10], [0,0,-1]);
    rotate([0,30,0]) translate([0, 0, -5]) rotate([30,0,0]) box([10, 5, 12], [0,0,1]);
  }
  rotate([0,-30,0]) translate([0, 0, -5]) rotate([150,0,0]) box([10, 5, 12], [0,0,-1]);
}

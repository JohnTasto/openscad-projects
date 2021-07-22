use <nz/nz.scad>;
use <base.scad>;


$fn = 60;

length = 100;
snap = 0.5;
lineW = 0.4;


difference() {
  cylinder(length, d=adjYRodD()+8*lineW+0.01);
  translate([0,0,-1]) {
    cylinder(length+2, d=adjYRodD());
    box([adjYRodD()-snap, adjYRodD(), length+2], [0,-1,1]);
  }
}

use <nz/nz.scad>;
use <base.scad>;


$fn = 60;


translate([0, 0, ycW()/2])
  difference() {
    rotate([-90]) extrude(adjLbL()+lbOWall()*2, center=true) teardrop(d=ycW(), truncate=ycW()/2);
    box([ycW()+2, adjLbL()+lbOWall()*2+2, ycW()/2+1], [0,0,1]);
    rotate([-90]) {
      cylinder(ycL()+2, d=adjYRodD()+yRodClearance()*2, center=true);
      cylinder(adjLbL(), d=adjLbD(), center=true);
    }
  }

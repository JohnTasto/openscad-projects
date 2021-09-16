use <nz/nz.scad>;
use <gt2.scad>;

fn = 60;


d = 9;
fillet = 1;
teeth = 6;
length = 2*teeth - 1;

module tensioner(hex=false) {
  render(convexity=6) translate([0,0,3.5]) rotate([90,90,0])
  difference() {
    minkowski() {
      union() {
        rotate([90,0,0]) cylinder
          ( length-2*fillet
          , d=hex?circumgoncircumdiameter(d=d-2*fillet, segments=6):d-2*fillet
          , center=true
          , $fn=hex?6:$fn
          );
        box([d/2+1-fillet, length-2*fillet, d-2*fillet], [1,0,0]);
      }
      sphere(fillet);
    }
    flip([0,1,0]) translate([hex?-1.25:-1, length/2, 0]) rotate([-90,hex?0:90,0])
      m_bolt(2, shank=length, nut=[0, 2.5]);
    translate([d/2-1, 0, 1.5]) rotate([-90,0,90]) gt2([length+4, d, 0.9], [0,0,1], [1, 1]);
  }
}

translate([0,0,d/2]) rotate([-90,0,0]) tensioner(hex=true, $fn=fn);

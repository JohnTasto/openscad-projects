use <nz/nz.scad>;

fn = 60;


slop = 0.55;  // 0.2 too small
slack = 1.0;
probeD = 2;
probeH = 3.5;
wall = 1.2;
coverage = 6;


module tip() {
  render(convexity=1) difference() {
    translate([0, 0, 36.75]) import("ref/bl-touch.stl");
    translate([0, 0, 12]) box([100, 100, 100], [0,0,1]);
    box([100, 100, 100], [0,0,-1]);
  }
}

module condom()
  render(convexity=3) difference() {
    translate([0, 0, wall+slop/2]) render(convexity=1) minkowski() {
      difference() {
        tip();
        translate([0, 0, probeH+coverage-2*wall-slop]) box([100, 100, 100], [0,0,1]);
      }
      sphere(circumgoncircumradius(wall+slop/2));
    }
    translate([0, 0, probeH]) render(convexity=1) minkowski() {
      tip();
      sphere(circumgoncircumradius(slop/2));
    }
    translate([0, 0, -1])
      cylinder(probeH+2, d=probeD+slack);
  }


//color([1.0, 0.5, 0.5, 0.5]) cylinder(probeH, d=probeD, $fn=fn);
//color([1.0, 0.5, 0.5, 0.5]) translate([0,0,probeH]) difference() {
//  tip();
//  translate([0, 0, coverage]) box([100, 100, 100], [0,0,1]);
//}
color([0.25 ,0.25, 0.25, 0.5]) condom($fn=fn);

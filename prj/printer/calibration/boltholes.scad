use <nz/nz.scad>;


module diameters(d, under, over, step, space, h=1)
  for (i = [-under : over])
    translate([i*(d+space), 0, 0])
      cylinder(h, d=(d+i*step));

module sides(d, dunder, dover, dstep, space, nstart, nend, nstep=1, h=1)
  for (i = [0 : (nend-nstart)/nstep])
    translate([0, i*(d+space), 0])
      diameters(d, dunder, dover, dstep, space, h, $fn=(nstart+i*nstep));

module circumdiameters(d, under, over, step, space, h=1)
  for (i = [-under : over])
    translate([i*(d+space), 0, 0])
      cylinder(h, d=circumgoncircumdiameter(d=d+i*step));

module circumsides(d, dunder, dover, dstep, space, nstart, nend, nstep=1, h=1)
  for (i = [0 : (nend-nstart)/nstep])
    translate([0, i*(d+space), 0])
      circumdiameters(d, dunder, dover, dstep, space, h, $fn=(nstart+i*nstep));

module holes()
  difference() {
    translate([-45,0,0]) cube([90, 55, 5]);
    translate([-25,15,-1]) {
      sides(3, 3, 3, .1, 2, 8, 36, 4, h=7);
      translate([50,0,0]) circumsides(3, 3, 3, .1, 2, 8, 36, 4, h=7);
    }
  }

union() {
  holes();
  translate([0,5,0]) rotate([90,0,0]) holes();
  translate([-2.5,2.5,0]) rotate([90,0,90]) holes();
}

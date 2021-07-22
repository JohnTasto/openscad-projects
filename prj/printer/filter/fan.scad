use <nz/nz.scad>;

fn = 36;


// measurements:

// fanN = 92;
// fanR = 46.3;  // 92.6;
// fanD = 25.25;
// fanScrew = 83;
// fanScrewR = 2.125;

fanN = 80;
fanR = 40.3;  // 92.6;
fanD = 25.25;
fanScrew = 72;
fanScrewR = 2.125;


// options:

slop = 0.3;
slack = 0.5;
lineW = 0.4;

fillet = 4*lineW;


module fan() {
  translate([0, 0, fanR/2])
    difference() {
      union() {
        box([2*fanR, fanD, 2*fanR-4*fanScrewR], [0,0,0]);
        box([2*fanR-4*fanScrewR, fanD, 2*fanR], [0,0,0]);
        flipX() flipZ() translate([fanR-2*fanScrewR, 0, fanR-2*fanScrewR])
          rotate([90,0,0]) cylinder(fanD, r=2*fanScrewR, center=true);
      }
      flipX() flipZ() translate([fanScrew/2, 0, fanScrew/2])
        rotate([90,0,0]) cylinder(fanD+1, r=fanScrewR, center=true, $fn=4*ceil($fn/8));
      rotate([90,0,0]) cylinder(fanD+1, r=fanR-2.4, center=true, $fn=2*$fn);
    }
}


fan($fn=fn);

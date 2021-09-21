use <nz/nz.scad>


$fn = 60;


m = 3;
grip = 0.1;

lineW = 0.4;
wall = 6*lineW + 0.01;

length = 20;


thread = m_adjusted_thread_width(m, grip=grip);
r = wall+thread/2;


translate([0, 0, r])
  difference() {
    union() {
      translate([-r, 0, 0]) rotate([-90, 0, -90]) extrude(length) teardrop(r=r, truncate=r);
      translate([0, -r, 0]) rotate([-90, 0, 0]) extrude(length) teardrop(r=r, truncate=r);
      translate([0, 0, -r]) cylinder(length, r=r);
    }
    translate([-r-1, 0, 0]) rotate([-90, 0, -90]) cylinder(length+2, d=thread);
    translate([0, -r-1, 0]) rotate([-90, 0, 0]) cylinder(length+2, d=thread);
    translate([0, 0, -r-1]) cylinder(length+2, d=thread);
  }

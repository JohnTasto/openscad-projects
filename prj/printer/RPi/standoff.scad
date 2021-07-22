use <nz/nz.scad>


module standoff(thread, wall, height) {
  difference() {
    cylinder(height, d=thread+2*wall);
    translate([0,0,-1]) cylinder(height+2, d=thread);
  }
}

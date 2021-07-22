// copyright aeropic 2017, neurozero 2021

use <nz/nz.scad>


// order of the Sierpinski pyramid
order = 5;    // [0,1,2,3,4,5,6,7]

// edge length of smallest octahedron
edge = 5.0;   // [2:50]

// line width in slicer
lineW = 0.6;  // [0.2:0.1:1.0]


/* [Hidden] */

gap    = 0.03;
fudge  = 0.001;
fudge2 = 0.002;

r = edge*sqrt(2)/2;
size = pow(2, order)*edge;
overlap = lineW+gap*2;


difference() {
  sierpinski(order-1);
  box([size, size, -overlap*sqrt(2)/2-fudge], [0,0,1]);
}


module sierpinski(ord) {
  n = pow(2, ord);  // octahedra per quadrant
  offset = n*overlap/2;
  quarter = n*edge/2;
  if (n<1) rotate(45) cylinder(r1=r, r2=0, h=r, $fn=4);
  else {
    difference() {
      union () {
        translate([+quarter-offset, +quarter-offset, 0]) sierpinski(ord-1);
        translate([-quarter+offset, -quarter+offset, 0]) sierpinski(ord-1);
        translate([-quarter+offset, +quarter-offset, 0]) sierpinski(ord-1);
        translate([+quarter-offset, -quarter+offset, 0]) sierpinski(ord-1);
      }
      translate([0, 0, -fudge]) {
        box([n*edge*2, gap, (overlap+gap)*sqrt(2)/2+fudge2], [0,0,1]);
        box([gap, n*edge*2, (overlap+gap)*sqrt(2)/2+fudge2], [0,0,1]);
      }
    }
    translate([0, 0, (quarter-offset)*sqrt(2)]) {
      rotate([180,0,0]) sierpinski(ord-1);
      rotate([  0,0,0]) sierpinski(ord-1);
    }
    box([overlap*2, overlap*2, overlap*sqrt(2)], [0,0,0]);
  }
}

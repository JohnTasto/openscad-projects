// Similar to example here:
//   https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Transformations#offset

use <nz/nz.scad>;

$fn=24;


p = [[0,0], [10,0], [10,10], [5,5], [0,10]];


// base
translate([0, 0]) polygon(p);


// round concavities and shrink
translate([15, 10]) offset(-1) polygon(p);

// round convexities and preserve polygon dimensions
translate([30, 10]) offset(1) offset(-1) polygon(p);

translate([45, 10]) offset(1) offset(1) offset(-1) polygon(p);

// round all vertices and preserve polygon dimensions - higher resolution on convexities
translate([60, 10]) offset(-1) offset(1) offset(1) offset(-1) polygon(p);

// same as previous
//translate([-75, 0]) offset(-1) offset(2) offset(-1) polygon(p);


// round convexities and enlarge
translate([15, -10]) offset(1) polygon(p);

// round concavities and preserve polygon dimensions
translate([30, -10]) offset(-1) offset(1) polygon(p);

translate([45, -10]) offset(-1) offset(-1) offset(1) polygon(p);

// round all vertices and preserve polygon dimensions - higher resolution on concavities
translate([60, -10]) offset(1) offset(-1) offset(-1) offset(1) polygon(p);

// same as previous
//translate([75, 0]) offset(1) offset(-2) offset(1) polygon(p);

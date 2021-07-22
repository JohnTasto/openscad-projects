use <nz/nz.scad>;


box([5, 10, 3], [1,1,1]);
translate([20,0,0]) box([5, 10, 3], [-1,1,1]);
translate([0,0,3]) box([20, 20, 1.5], [1,1,1]);

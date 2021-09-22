use <nz/nz.scad>

line_width = 0.4;          // [0.2:0.05:1.6]
layer_height = 0.2;        // [0.1:0.05:0.8]
first_layer_height = 0.3;  // [0.1:0.05:0.8]
layers = 12;               // [2:1:25]
letter_layers = 8;         // [0:1:24]

steps = 6;                 // [1:1:20]
start = 1.6;               // [0.4:0.1:3.2]

perimeters = 6;            // [2:1:20]

height = first_layer_height + (layers-1)*layer_height;
floor = height - letter_layers*layer_height;

// f(x) = a(x - x_v)^2 + f(x_v)
//
// x_v = steps
// f(x_v) = 50 - perimeters*line_width
// f(x) = a(x - steps)^2 + 50 - perimeters*line_width
//
// passes through (0, 0)
// 0 = a(0 - steps)^2 + 50 - perimeters*line_width
// -a*steps^2 = 50 - perimeters*line_width
// a = (perimeters*line_width - 50) / steps^2
//
// f(x) = ((perimeters*line_width - 50) / steps^2)*(x - steps)^2 + 50 - perimeters*line_width
function pinwheel(i) = ((perimeters*line_width - 50) / (steps*steps))*(i-steps)*(i-steps) + 50 - perimeters*line_width;

difference() {
  union() {
    difference() {
      box([100, 100, height], [0,0,1]);
      translate([0, 0, -1]) box([100-2*perimeters*line_width, 100-2*perimeters*line_width, height+2], [0,0,1]);
    }
    difference() {
      ring(8) for (i=[1:steps]) {
        translate([pinwheel(i), 0, 0]) box([pinwheel(i)-pinwheel(i-1), start+2*line_width*(i-1), height], [-1,1,1]);
        translate([pinwheel(i), start+2*line_width*i, 0]) rotate(-45) box([2*line_width*sqrt(2), 2*line_width*sqrt(2), height], [1,-1,1]);
      }
      ring(4) translate([50, 0, -1]) box([75, 250, height+2], [1, 0, 1]);
    }
    ring(4) union () {
      translate([50, 50, 0]) rotate(45) box([10, 10, height], [-1,0,1]);
      difference() {
        rotate(45) translate([50-perimeters*line_width, 0, 0]) box([25, 50, height], [1,0,1]);
        translate([50, 0, -1]) box([50, 100, height+2], [1,1,1]);
        translate([0, 50, -1]) box([100, 50, height+2], [1,1,1]);
      }
    }
  }
  rotate( 135) translate([0, 52.5-3*line_width, floor]) scale([1.5, 1, 1]) linear_extrude(height-floor+layer_height) text("A", halign="center");
  rotate(  45) translate([0, 52.5-3*line_width, floor]) scale([1.5, 1, 1]) linear_extrude(height-floor+layer_height) text("B", halign="center");
  rotate( -45) translate([0, 52.5-3*line_width, floor]) scale([1.5, 1, 1]) linear_extrude(height-floor+layer_height) text("C", halign="center");
  rotate(-135) translate([0, 52.5-3*line_width, floor]) scale([1.5, 1, 1]) linear_extrude(height-floor+layer_height) text("D", halign="center");
}

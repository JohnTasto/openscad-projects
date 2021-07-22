use <nz/nz.scad>

line_width = 0.4;          // [0.2:0.05:1.6]
layer_height = 0.2;        // [0.1:0.05:0.8]
first_layer_height = 0.3;  // [0.1:0.05:0.8]
layers = 12;               // [2:1:25]
letter_layers = 8;         // [0:1:24]

steps = 10;                // [3:1:20]
perimeters = 6;            // [2:1:20]

height = first_layer_height + (layers-1)*layer_height;
floor = height - letter_layers*layer_height;
wall = perimeters*line_width;

step = 100/steps;

module slot(x, y) {
  difference() {
    box([x, y, height]);
    translate([0,0,-1]) box([x-wall, y-wall, height+2]);
  }
}

difference() {
  union() {
    for (i=[0:steps-1]) {
      translate([i*step,0,0]) slot(step, 100-i*step);
      translate([0,i*step,0]) slot(100-i*step, step);
    }

    box([wall, 100, height]);
    box([100, wall, height]);

    translate([100-step, 0, 0]) box([step+wall, step, height], [-1,1,1]);
    translate([0, 100-step, 0]) box([step, step+wall, height], [1,-1,1]);
  }
  translate([100-1.5*step-wall/2, 0.5*step, floor])
    rotate(-90)
      flip()
        translate([(step-2*wall)/25, (wall-step)/85, 0])
          scale([(step-2*wall)/9.675, (step-wall)/9.54, 1])
            linear_extrude(height-floor+layer_height)
              text("X", halign="center", valign="center");
  translate([0.5*step, 100-1.5*step-wall/2, floor])
    flip()
      translate([(step-2*wall)/25, (wall-step)/85, 0])
        scale([(step-2*wall)/9.675, (step-wall)/9.54, 1])
          linear_extrude(height-floor+layer_height)
            text("Y", halign="center", valign="center");
}

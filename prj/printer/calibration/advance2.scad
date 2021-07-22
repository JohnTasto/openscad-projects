use <nz/nz.scad>

layer_height = 0.3;
first_layer_height = 0.45;

steps = 50;
layers_per_step = 5;
unit_mark_depth = 1*layer_height;
minor_mark_depth = -1.5*layer_height;
major_mark_depth = -2*layer_height;
minor_mark_steps = 5;
major_mark_steps = 10;
mark_angle = 45;

size = 25;

groove_width = 1;
groove_depth = 2;
// groove_depth_shallow = 0.5;
// groove_depth_deep = 7.5;

function layer_z(layer) = layer < 1
  ? first_layer_height*layer
  : layer_height*(layer-1) + first_layer_height;
function step_layer(step) = step*layers_per_step;
function step_z(step, layer=0) = layer_z(step_layer(step) + layer);

height = step_z(steps, 1);

echo(str("Height: ", height));
echo(str("Layers: ", step_layer(steps) + 1));
echo("0: initial layer");

module mark(depth) if (depth > 0) ring(90, n=4) translate([0, size/2, 0]) hull() flipX()
  translate([size/2, 0, 0]) rotate(45) spindle(0, r=depth*sqrt(2), p=depth, $fn=4);

module advance() {
  difference() {
    union() {
      difference() {
        box([size, size, height], [0,0,1]);
        for (i = [0:               1:steps]) translate([0, 0, step_z(i, 0.5)]) mark(unit_mark_depth);
        for (i = [0:minor_mark_steps:steps]) translate([0, 0, step_z(i, 0.5)]) mark(minor_mark_depth);
        for (i = [0:major_mark_steps:steps]) translate([0, 0, step_z(i, 0.5)]) mark(major_mark_depth);
      }
      intersection() {
        box([size*2, size*2, height], [0,0,1]);
        union() {
          for (i = [0:               1:steps]) translate([0, 0, step_z(i, 0.5)]) mark(-unit_mark_depth);
          for (i = [0:minor_mark_steps:steps]) translate([0, 0, step_z(i, 0.5)]) mark(-minor_mark_depth);
          for (i = [0:major_mark_steps:steps]) translate([0, 0, step_z(i, 0.5)]) mark(-major_mark_depth);
        }
      }
    }
    translate([size/2-groove_depth, 0, height/2]) box([groove_depth+1, groove_width, height*2], [1,0,0]);
    translate([0, groove_depth-size/2, height/2]) box([groove_width, groove_depth+1, height*2], [0,-1,0]);
    // translate([size/2-groove_depth_shallow, -size/6, height/2]) box([groove_depth_shallow+1, groove_width, height*2], [1,0,0]);
    // translate([size/6, groove_depth_shallow-size/2, height/2]) box([groove_width, groove_depth_shallow+1, height*2], [0,-1,0]);
    // translate([size/2-groove_depth_deep, size/6, height/2]) box([groove_depth_deep+1, groove_width, height*2], [1,0,0]);
    // translate([-size/6, groove_depth_deep-size/2, height/2]) box([groove_width, groove_depth_deep+1, height*2], [0,-1,0]);
  }
}

advance();

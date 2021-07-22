use <nz/nz.scad>

layer_height = 0.2;         // [0.1:0.05:0.8]
first_layer_height = 0.3;   // [0.1:0.05:0.8]

steps = 26;                 // [1:1:100]
layers_per_step = 16;       // [1:1:100]
layers_per_gutter = 4;      // [9:1:10]
gutter_inset = 0.2;         // [0.1:0.05:0.5]

steps_per_division = 5;     // [0:1:100]

layers_bottom_margin = 2;   // [0:1:10]
layers_top_margin = 2;      // [0:1:10]

halve_last_step = true;

size = 25;                  // [1:1:50]

groove_width = 1;           // [0:0.1:10]
groove_depth = 2;           // [0:0.1:10]
// groove_depth_shallow = 0.5; // [0:0.1:10]
// groove_depth_deep = 7.5;    // [0:0.5:50]

layers = steps*layers_per_step + (steps-1)*layers_per_gutter + layers_bottom_margin + layers_top_margin;

height = first_layer_height + (layers-1)*layer_height;
step_height = layers_per_step*layer_height;
gutter_height = layers_per_gutter*layer_height;
bottom_margin_height = first_layer_height + (layers_bottom_margin-1)*layer_height;
top_margin_height = layers_top_margin*layer_height;

echo(bottom_margin_height);
echo(str("Height: ", height));
echo(str("Layers: ", layers));
echo("0: initial layer");

difference() {
  union() {
    box([size-2*gutter_inset, size-2*gutter_inset, height], [0,0,1]);
    for (i = [0:1:steps-1]) {
      translate([0, 0, bottom_margin_height + i*(step_height+gutter_height)])
        box([size, size, step_height], [0,0,1]);
      if (i != 0) echo(str(layers_bottom_margin + i*(layers_per_step+layers_per_gutter) - layers_per_gutter, ": gutter"));
      echo(str(layers_bottom_margin + i*(layers_per_step+layers_per_gutter), ": step"));
    }
  }
  translate([size/2-groove_depth, 0, -1]) box([groove_depth+1, groove_width, height+2], [1,0,1]);
  translate([0, groove_depth-size/2, -1]) box([groove_width, groove_depth+1, height+2], [0,-1,1]);
  // translate([size/2-groove_depth_shallow, -size/6, -1]) box([groove_depth_shallow+1, groove_width, height+2], [1,0,1]);
  // translate([size/6, groove_depth_shallow-size/2, -1]) box([groove_width, groove_depth_shallow+1, height+2], [0,-1,1]);
  // translate([size/2-groove_depth_deep, size/6, -1]) box([groove_depth_deep+1, groove_width, height+2], [1,0,1]);
  // translate([-size/6, groove_depth_deep-size/2, -1]) box([groove_width, groove_depth_deep+1, height+2], [0,-1,1]);
  if (halve_last_step)
    translate([0, 0, bottom_margin_height + (steps-1)*(step_height+gutter_height) + step_height/2])
      box([size+1, size+1, step_height+top_margin_height], [0,0,1]);
}

use <nz/nz.scad>

layer_height = 0.2;        // [0.1:0.05:0.8]
first_layer_height = 0.3;  // [0.1:0.05:0.8]
layers = 37;               // [2:1:25]

size = 25;                 // [1:1:50]
letter_depth = 2;          // [0:0.5:10]
letter_margin = 1;         // [0:0.1:10]

height = first_layer_height + (layers-1)*layer_height;
letter_height = height - 2*letter_margin;

echo(str("Height: ", height));

difference() {
  box([size, size, height], [0,0,1]);
  translate([size/2-letter_depth, 0, height/2-height/85])
    rotate([90,0,90])
      scale([letter_height/9.53, letter_height/9.53, 1])
        flip()
          translate([0.5, 0, 0])
            linear_extrude(letter_depth+1)
              text("Y", halign="center", valign="center");
  translate([0, letter_depth-size/2, height/2-height/85])
    rotate([90,0,0])
      scale([letter_height/9.53, letter_height/9.53, 1])
        flip()
          translate([0.5, 0, 0])
            linear_extrude(letter_depth+1)
              text("X", halign="center", valign="center");
}

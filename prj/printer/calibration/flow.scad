use <nz/nz.scad>

layer_height = 0.2;        // [0.1:0.05:0.8]
first_layer_height = 0.3;  // [0.1:0.05:0.8]
layers = 12;               // [2:1:25]

height = first_layer_height + (layers-1)*layer_height;

echo(str("Height: ", height));

box([20, 20, height], [0,0,1]);

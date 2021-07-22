use <nz/nz.scad>

// Y axis backlash calibration grid
//
// Originally derived from https://www.thingiverse.com/thing:2040624/files
//
// Set backlash compensation to 0 in your software while sampling an axis.
// Locate the figure with the smallest offset value and add backlash offset to it.
// This calculated value is your backlash offset to be entered in the printer software.
//
// E.g., if columns = 10, backlash start = 0.5, backlash step = 0.01, and the correct figure is
//   3rd up from the bottom and 4th from the left:
// 0.5 + (3-1)*10*0.01 + (4-1)*0.01 = 0.73
//
// To calibrate the X axis, rotate 90 degrees.

/* [Test points] */

// Number of strips to print
rows    = 5;   // [1:1:20]
columns = 10;  // [1:1:20]

backlash_start = 0.00;  // [0.0:0.1:2]
backlash_step  = 0.01;  // [0.0:0.005:0.1]

/* [Line width and height] */

line_height = 0.3;  // [0.1:0.05:0.8]
line_width  = 0.4;  // [0.1:0.05:1.6]

/* [Test size] */

reset_length  = 1;  // [0:0.5:10]
runway_length = 2;  // [0:0.5:10]
ramp_length   = 2;  // [0:0.5:10]
hold_length   = 2;  // [0:0.5:10]

/* [Test spacing] */

row_gap    = 8;   // [0:0.5:10]
column_gap = 2;   // [0:0.1:5]
mirror_gap = 1.2; // [0:0.1:5]


module rect(size, align) box([size[0], size[1], line_height], [align[0], align[1], 1]);

unitW = 2*runway_length + 2*ramp_length + hold_length;
colW = unitW + column_gap;

unitH = reset_length;
mirrorH = 2*unitH + mirror_gap;
rowH = mirrorH + row_gap;

module bl_unit(bl) {
  theta = atan2(bl, ramp_length);
  corner = (line_width)*tan(theta/2);
  translate([0, -line_width]) {
    translate([hold_length/2+ramp_length+runway_length-line_width, reset_length]) rect([column_gap+line_width*2, line_width*2], [1,1]);
    flip() {
      translate([hold_length/2+ramp_length+runway_length-line_width, 0]) rect([line_width*2, reset_length+line_width*2], [1,1]);
      translate([hold_length/2+ramp_length-corner, 0]) rect([runway_length+corner+line_width, line_width*2], [1,1]);
      translate([hold_length/2+corner, bl+line_width*2]) rotate(-theta) rect([sqrt(ramp_length*ramp_length+bl*bl)+2*corner, line_width*2], [1,-1]);
    }
    translate([hold_length/2+corner, bl]) rect([hold_length+2*corner, line_width*2], [-1,1]);
  }
}

// bl_unit(2);

module bl_mirror(bl) flip([0,1]) translate([0, mirror_gap/2]) bl_unit(bl);

module bl_row(start, step, end) {
  n = round((end-start)/step + 1);
  translate([unitW/2+line_width, 0]) for (i = [0:n-1]) translate([i*colW, 0]) bl_mirror(start+i*step);
  translate([n*colW, mirrorH/2]) rect([line_width*2, mirrorH], [1,-1]);
}

// bl_row(1, 0.2, 2.6);

module bl_grid(start, step, rows, cols) {
  union() {
    for (i = [0:rows-1]) translate([0, i*rowH]) bl_row(start+i*cols*step, step, start+(i+1)*cols*step-step);
    for (i = [1:rows-1]) translate([0, i*rowH]) translate([0, -mirrorH/2]) rect([line_width*2, row_gap], [1,-1]);
  }
}

bl_grid(backlash_start, backlash_step, rows, columns);

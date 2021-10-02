use <nz/nz.scad>


ffn = 32;
cfn = 128;

slop = 0.15;

lineW = 0.6;


ribH = lineW*2 - slop; //0.75;
ribR = lineW*2; //lineW*4;

depth = 10;


// // VERTICAL
// ribsC = 4;
// ribsS = 2;
// // normal
// legW = 70.00;
// legH = 27.75;
// // mirrored
// legW = 70.50;
// legH = 27.75;
// //    measured       tested
// //    70.25-71.00    70.75  70.00  70.25  70.50  69.75  70.00
// //    28.40-29.10    28.75  28.00  28.00  27.75  27.75  27.75

// // HORIZONTAL
ribsC = 2;
ribsS = 3;
legH = 31;
legW = 70;
// //    measured       tested
// //    30.50-31.70    30.00  31.00
// //    69.90-70.40    70.00  70,00


wall = lineW*6;
cupH = legH + ribH*2 + wall*2;
cupW = legW + ribH*2 + wall*2;

ribSL = (legW - legH + (ribsC>0 ? (legH+ribR*2)*PI/(ribsC*2) : 0))*(ribsC>0 ? 1 : 1+2/ribsS);


extrude(depth) difference() {
  // cup shell
  rect([cupW, cupH], [0,0], r=cupH/2, $fn=cfn);
  // cup cavity
  rect([cupW-wall*2, cupH-wall*2], [0,0], r=cupH/2-wall, $fn=cfn);
}
extrude(depth) intersection() {
  // ribs
  union() {
    if (ribsC>0) flipX() translate([cupW/2-cupH/2, 0]) rotate(90/ribsC-90)
      ring(ribsC, a=180/ribsC) translate([legH/2+ribR, 0]) circle(ribR, $fn=ffn);
    if (ribsS>0) flipY() translate([-ribSL/2, legH/2+ribR]) for (i=[1:ribsS])
      translate([ribSL*i/(ribsS+1), 0]) circle(ribR, $fn=ffn);
  }
  // cup shell
  rect([cupW, cupH], [0,0], r=cupH/2, $fn=cfn);
}

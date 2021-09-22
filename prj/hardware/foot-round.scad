use <nz/nz.scad>


ffn = 24;
cfn = 120;

fudge  = 0.01;
fudge2 = 0.02;

slop = 0.15;

lineW = 0.4;


legD = 10;
cupWall = lineW*6;
cupH = 12;
cupA = 15;

ribs = 6;
ribA = 90;
ribH = 0.5;
ribR = lineW*2;
ribFrontInset = 1;
ribBackInset = 1;

baseH = 3;
baseLip = 3;

cupSide = baseH;  // should be bigger than cupWall
cupGap = cupSide - cupWall;

legR  = legD/2;
holeR = legR + ribH;
cupR  = holeR + cupWall;

baseW = cupR*2;
baseD = cupR*2/cos(cupA);


translate([0, 0, baseH]) difference() {
  rotate([cupA]) rotate_extrude($fn=cfn) {
    difference() {
      // cup wall
      translate([cupR-cupSide/2, cupH-cupSide/2+tan(cupA)*holeR]) {
        rect([cupSide, cupSide/2-cupH-tan(cupA)*(holeR+cupR)], [0,1]);
        circle(d=cupSide, $fn=ffn);
      }
      // cup gap
      translate([cupR-cupWall, cupH+fudge+tan(cupA)*holeR]) rect([-cupGap-fudge, -cupH-fudge2-tan(cupA)*(holeR+cupR)]);
    }
    // cup bottom
    translate([cupR, tan(cupA)*holeR]) rect([-cupR, -tan(cupA)*(holeR+cupR)], [1,1]);
  }
  // trim cup
  translate([0,0,-fudge]) box([baseW+fudge2, baseD+fudge2, sin(cupA)*cupR*2+1], [0,0,-1]);
}
// ribs
translate([0, 0, baseH]) rotate([cupA])
  rotate(ribA) ring(ribs) translate([0, legR+ribR, cupH-ribR-ribFrontInset+tan(cupA)*holeR])
    tull([0, 0, -cupH+ribR*2+ribFrontInset+ribBackInset]) ball(ribR, $fn=ffn);
// base
extrude(baseH) scale([1, (baseD+baseLip*2-baseH)/(baseW+baseLip*2-baseH)]) circle(d=baseW+baseLip*2-baseH, $fn=cfn);
orbit(dX=baseW+baseLip*2-baseH, dY=baseD+baseLip*2-baseH, translate=[0, baseH/2], $fn=cfn)
  rotate(180) teardrop(d=baseH, truncate=baseH/2, $fn=ffn);

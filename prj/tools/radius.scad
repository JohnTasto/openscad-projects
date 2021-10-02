use <nz/nz.scad>


ffn = 64;
cfn = 360;

fudge  = 0.01;
fudge2 = 0.02;

slop = 0.14;

lineW = 0.6;//0.4;
layerH0 = 0.44;//0.32;
layerHN = 0.28;//0.2;

wall = lineW*6;
holeD = 5;
holeL = true;
holeR = false;

height = round_absolute_height_layer(1.5, layerHN, layerH0);

labelDepth = round_relative_height_layer(0.75, layerHN);
// labelSize = 7;
labelFont = "Liberation Sans:style=Bold";

arcR = 325;
arcL = 30;
hArcL = arcL/2;
endR = wall + holeD/2;

// // derived from
// //   endR = cos(adjHArcL)*midD/2
// // and other functions below.
// // solving numerically since too much trouble to solve algebraicly.
// midDF = function (x) cos(atan2(arcR*sin(hArcL), sqrt(arcR^2 - (x/2)^2)*cos(hArcL)))*x/2 - endR;
// midDF = function (x) cos(hArcL)*x/2 - endR;
// midDF = function (x) cos(hArcL*2 - atan2(arcR*sin(hArcL), sqrt(arcR^2 - (x/2)^2)*cos(hArcL)))*x/2 - endR;
midDF = function (x) cos(90 - atan2(arcR*cos(hArcL), sqrt(arcR^2 - (x/2)^2)*sin(hArcL)))*x/2 - endR;

midD = solve(midDF, min=0, max=arcL, epsilon=0.0001);

rX = sqrt(arcR^2 - (midD/2)^2);
rY = arcR;

// adjHArcL = atan2(rY*sin(hArcL), rX*cos(hArcL));            // inline
// adjHArcL = hArcL;                                          // simple
// adjHArcL = hArcL*2 - atan2(rY*sin(hArcL), rX*cos(hArcL));  // inline mirrored
adjHArcL = 90 - atan2(rY*cos(hArcL), rX*sin(hArcL));       // not sure, but best so far

segs = floor(max(1, adjHArcL*cfn/360));
segA = adjHArcL/segs;

isectA = asin(midD/2/arcR);


translate([0, midD/2-arcR, 0]) difference() {
  extrude(height, convexity=2) for (i=[0:segs-1]) {
    s = sin(segA*(i+0));
    c = cos(segA*(i+0));
    S = sin(segA*(i+1));
    C = cos(segA*(i+1));
    flipX() hull() {
      translate([rX*s, rY*c]) rotate(atan2(rY*s, -rX*c)) {
        rotate( 90+s*isectA) circle(c*midD/2, $fn=3);
        rotate(-90-s*isectA) circle(c*midD/2, $fn=3);
      }
      translate([rX*S, rY*C]) rotate(atan2(rY*S, -rX*C)) {
        rotate( 90+S*isectA) circle(C*midD/2, $fn=i==segs-1?ffn:3);
        rotate(-90-S*isectA) circle(C*midD/2, $fn=i==segs-1?ffn:3);
      }
    }
  }
  translate([0, 0, -fudge]) extrude(height+fudge2) {
    if (holeL) translate([-rX*sin(adjHArcL), rY*cos(adjHArcL)]) rotate(atan2(rY*sin(adjHArcL), rX*cos(adjHArcL))) hull() {
      rotate( 90+sin(adjHArcL)*isectA) circle(d=holeD, $fn=ffn);
      rotate(-90-sin(adjHArcL)*isectA) circle(d=holeD, $fn=ffn);
    }
    if (holeR) translate([rX*sin(adjHArcL), rY*cos(adjHArcL)]) rotate(atan2(rY*sin(adjHArcL), -rX*cos(adjHArcL))) hull() {
      rotate( 90+sin(adjHArcL)*isectA) circle(d=holeD, $fn=ffn);
      rotate(-90-sin(adjHArcL)*isectA) circle(d=holeD, $fn=ffn);
    }
  }
  if (labelDepth>0) translate([0, arcR-lineW/4, height-labelDepth]) extrude(labelDepth+fudge)
    text(str(arcR), size=midD-wall, font=labelFont, halign="center", valign="center", $fn=ffn);
}

// translate([0, midD/2-arcR, 0]) {
//   color("blue", .25) difference() {
//     translate([0,  midD/2]) circle(arcR, $fn=cfn);
//     translate([0, -midD/2]) circle(arcR, $fn=cfn);
//     flipX() rotate(-hArcL) rect([arcR+fudge, arcR+midD/2+fudge]);
//   }
// }

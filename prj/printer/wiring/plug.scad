use <nz/nz.scad>;


$fn = 60;

fudge  = 0.01;
fudge2 = 0.02;
slop   = 0.125;
slack  = 0.25;

lineW = 0.6;


// measurements:

holeW = 110;
holeH = 104 - 2;  // TODO: figure out why this -2 is necessary!
holeR = 40;

acrylicD = 2.5;
frameD = 6;

frameLip = 2.5;  // up to 2.7 towards edges, but pretty close to 2.5 around hole
frameLedge = 41.8;


// pfteH = 9;
// pfteThread = m_adjusted_thread_width(mm(3/8));
// pfteR = pfteThread/2;
pfteD = circumgoncircumdiameter(d=4+slack*2);
pfteR = pfteD/2;
wireR = 7.5;  // should match tie.scad


// options:

fillet = lineW*2;

plugLipD = lineW*2 + fudge;
plugLipW = 3;

pfteWall = lineW*4 + fudge;
wireWall = lineW*6 + fudge;
minWall  = lineW*2 + fudge;


// calculations:

plugD = acrylicD + slack*2 + plugLipD*2;

wireZ = frameLip + frameD*sqrt(2) + wireR*sqrt(2) + 1;  // +1 to account for curve over frameLip

pfteOuterR = pfteR + pfteWall;
wireOuterR = wireR + wireWall;

wireInsetOut = wireOuterR - sqrt(square(wireOuterR)-square(wireR));

wireExtraIn = wireOuterR - pfteOuterR;  // 0;  // pfteH;
wireExtraOut = wireOuterR - pfteOuterR - wireInsetOut;
wireHoleExtraOut = max(0, wireInsetOut - wireWall);

wireOffset = wireExtraIn/2 - wireExtraOut/2;
wireHoleOffset = wireOffset - wireHoleExtraOut/2;

pfteHousingL = plugD*sqrt(2) + pfteOuterR*2;
wireHousingL = pfteHousingL + wireExtraIn + wireExtraOut;
wireHoleL = wireHousingL + wireHoleExtraOut;

pfteX = wireR + pfteR + max(pfteWall+minWall, plugLipW+minWall);
echo(pfteX);


module plug() difference() {
  union() {
    base();
    translate([0, 0, wireZ]) rotate([45, 0, 0]) {
      flipX() translate([pfteX, 0, 0]) cylinder(pfteHousingL, r=pfteOuterR, center=true);
      difference() {
        translate([0, 0, wireOffset]) cylinder(wireHousingL, r=wireOuterR, center=true);
        // flipX() translate([pfteX, 0, wireOffset]) cylinder(wireHousingL+fudge2, r=pfteOuterR, center=true);
      }
    }
  }
  translate([0, 0, wireZ]) rotate([45, 0, 0]) {
    flipX() translate([pfteX, 0, 0]) cylinder(pfteHousingL+fudge2, r=pfteR, center=true);
    translate([0, 0, wireHoleOffset]) cylinder(wireHoleL+fudge2, r=wireR, center=true);
  }
}

// plug();

module plug_main() difference() {
  plug();
  multmatrix([[1,0,0,0],[0,1,0,0],[0,-1,1,0],[0,0,0,1]])
    translate([0, 0, -plugD/2]) {
      translate([0, -wireOffset/sqrt(2)-wireOuterR/sqrt(2)/2, 0])
        box([wireR*2, wireHousingL/sqrt(2)+wireOuterR/sqrt(2), plugD/2+wireZ], [0,0,1]);
      box([wireR*2+plugLipW*2, acrylicD+slop*2, plugD/2+wireZ], [0,0,1]);
    }
  flipX() translate([wireR-fudge, acrylicD/2+slop-fudge, frameLip+slop-fudge]) hull() {
    box([plugLipW+fudge, plugLipD+slack-slop+fudge2, fudge], [1,1,1]);
    box([fudge, plugLipD+slack-slop+fudge2, plugLipW+fudge], [1,1,1]);
  }
}

plug_main();

module plug_wire_cap() intersection() {
  plug();
  multmatrix([[1,0,0,0],[0,1,0,0],[0,-1,1,0],[0,0,0,1]])
    translate([0, 0, -plugD/2]) {
      translate([0, -wireOffset/sqrt(2)-wireOuterR/sqrt(2)/2, 0])
        box([wireR*2-slop*2, wireHousingL/sqrt(2)+wireOuterR/sqrt(2), plugD/2+wireZ], [0,0,1]);
      box([wireR*2+plugLipW*2-slop*2, acrylicD, plugD/2+wireZ-slop], [0,0,1]);
    }
}

// plug_wire_cap();

module hole() render(convexity=1) union() {
  box([holeW, acrylicD, holeH-holeR], [0,0,1]);
  box([holeW-holeR*2, acrylicD, holeH], [0,0,1]);
  flipX() translate([holeW/2-holeR, 0, holeH-holeR]) rotate([90,0,0])
    cylinder(acrylicD, r=holeR, center=true, $fn=$fn*2);
}

// hole();

module base() render(convexity=3) difference() {
  union() {
    // sides
    flipY() translate([0, acrylicD/2+slack, 0])
      difference() {
        translate([0, -fillet, 0])
          minkowski() {
            union() {
              box([holeW+plugLipW*2-fillet*2, plugLipD, holeH-holeR], [0,1,1]);
              box([holeW-holeR*2, plugLipD, holeH+plugLipW-fillet], [0,1,1]);
              flipX() translate([holeW/2-holeR, 0, holeH-holeR])
                rotate([-90,0,0]) cylinder(plugLipD, r=holeR+plugLipW-fillet, $fn=$fn*2);
            }
            difference() {
              sphere(circumgoncircumradius(fillet), $fn=ceil($fn/8)*4);
              box([fillet*2+fudge2, fillet*2+fudge2, fillet+fudge], [0,0,-1]);
            }
          }
        translate([0, 0, -fudge]) box([holeW+plugLipW*2+fudge2, fillet*2+fudge, holeH+plugLipW+fudge2], [0,-1,1]);
      }
    // middle
    box([holeW-slop*2, acrylicD+slack*2+plugLipD, holeH-holeR], [0,0,1]);
    box([holeW-holeR*2, acrylicD+slack*2+plugLipD, holeH-slop], [0,0,1]);
    flipX() translate([holeW/2-holeR, 0, holeH-holeR]) rotate([90,0,0])
      cylinder(acrylicD+slack*2+plugLipD, r=holeR-slop, center=true, $fn=$fn*2);
  }
  // frame lip
  hull() {
    translate([0, acrylicD/2, -fudge]) box([holeW+plugLipW*2+fudge2, fudge, frameLip+fudge], [0,1,1]);
    translate([0, acrylicD/2+slack+plugLipD, -fudge]) box([holeW+plugLipW*2+fudge2, fudge, frameLip+slack+plugLipD+fudge], [0,1,1]);
  }
  flipX() translate([holeW/2+plugLipW+fudge, acrylicD/2+slack-fudge, frameLip+slack-fudge]) hull() {
    box([plugLipW+slop+fudge, plugLipD+fudge2, fudge], [-1,1,1]);
    box([fudge, plugLipD+fudge2, plugLipW+slop+fudge], [-1,1,1]);
  }
}

// base();

// color([0.5,0,0,0.5]) hole($fn=fn);
// color([0.5,0,0,0.5]) base($fn=fn);

use <nz/nz.scad>;

$fn = 60;


// measurements:

holeW = 110;
holeH = 104 - 2;  // TODO: figure out why this -2 is necessary!
holeR = 40;

acrylicD = 2.5;
frameD = 6;

frameLip = 2.5;  // up to 2.7 towards edges, but pretty close to 2.5 around hole
frameLedge = 41.8;


pfteH = 9;
pfteThread = m_adjusted_thread_width(mm(3/8));
pfteR = pfteThread/2;
wireR = 7.5;  // should match tie.scad


// options:

slop = 0.3;
lineW = 0.4;

fillet = 4*lineW;

plugLipD = 4*lineW + 0.01;
plugLipW = 3;

pfteWall = 6*lineW + 0.01;
wireWall = 10*lineW + 0.01;
minWall = 2*lineW + 0.01;


// calculations:

plugD = acrylicD + 2*plugLipD + slop;

wireZ = frameLip + sqrt(2)*frameD + sqrt(2)*wireR + 1;  // 1 to account for curve over frameLip

pfteOuterR = pfteR + pfteWall;
wireOuterR = wireR + wireWall;

wireInsetOut = wireOuterR - sqrt(pow(wireOuterR, 2) - pow(wireR, 2));

wireExtraIn = pfteH;
wireExtraOut = wireOuterR - pfteOuterR - wireInsetOut;
wireHoleExtraOut = max(0, wireInsetOut - wireWall);

wireOffset = wireExtraIn/2 - wireExtraOut/2;
wireHoleOffset = wireOffset - wireHoleExtraOut/2;

pfteHousingL = sqrt(2)*plugD + 2*pfteOuterR;
wireHousingL = pfteHousingL + wireExtraIn + wireExtraOut;
wireHoleL = wireHousingL + wireHoleExtraOut;

pfteX = wireR + pfteR + max(pfteWall+minWall, plugLipW+minWall);
echo(pfteX);


module plug() {
  difference() {
    union() {
      base();
      translate([0, 0, wireZ]) rotate([45, 0, 0]) {
        flipX() translate([pfteX, 0, 0]) cylinder(pfteHousingL, r=pfteOuterR, center=true);
        difference() {
          translate([0, 0, wireOffset]) cylinder(wireHousingL, r=wireOuterR, center=true);
          flipX() translate([pfteX, 0, wireOffset]) cylinder(wireHousingL+1, r=pfteOuterR, center=true);
        }
      }
    }
    translate([0, 0, wireZ]) rotate([45, 0, 0]) {
      flipX() translate([pfteX, 0, 0]) cylinder(pfteHousingL+1, r=pfteR, center=true);
      translate([0, 0, wireHoleOffset]) cylinder(wireHoleL+1, r=wireR, center=true);
    }
  }
}

// plug();

module plug_main() {
  difference() {
    plug();
    multmatrix([[1,0,0,0],[0,1,0,0],[0,-1,1,0],[0,0,0,1]])
      translate([0, 0, -plugD/2]) {
        translate([0, -wireOffset/sqrt(2)-wireOuterR/sqrt(2)/2, 0])
          box([2*wireR, wireHousingL/sqrt(2)+wireOuterR/sqrt(2), plugD/2+wireZ], [0,0,1]);
        box([2*wireR+2*plugLipW, acrylicD+slop, plugD/2+wireZ], [0,0,1]);
      }
  }
}

// plug_main();

module plug_wire_cap() {
  intersection() {
    plug();
    multmatrix([[1,0,0,0],[0,1,0,0],[0,-1,1,0],[0,0,0,1]])
      translate([0, 0, -plugD/2]) {
        translate([0, -wireOffset/sqrt(2)-wireOuterR/sqrt(2)/2, 0])
          box([2*wireR-slop, wireHousingL/sqrt(2)+wireOuterR/sqrt(2), plugD/2+wireZ], [0,0,1]);
        box([2*wireR+2*plugLipW-slop, acrylicD, plugD/2+wireZ-slop/2], [0,0,1]);
      }
  }
}

plug_wire_cap();

module hole() {
  render(convexity=1) union() {
    box([holeW, acrylicD, holeH-holeR], [0,0,1]);
    box([holeW-2*holeR, acrylicD, holeH], [0,0,1]);
    flipX() translate([holeW/2-holeR, 0, holeH-holeR]) rotate([90,0,0])
      cylinder(acrylicD, r=holeR, center=true, $fn=2*$fn);
  }
}

// hole();

module base() {
  render(convexity=3)
    difference() {
      union() {
        // sides
        flipY() translate([0, acrylicD/2+slop/2, 0])
          difference() {
            translate([0, -fillet, 0])
              minkowski() {
                union() {
                  box([holeW+2*plugLipW-2*fillet, plugLipD, holeH-holeR], [0,1,1]);
                  box([holeW-2*holeR, plugLipD, holeH+plugLipW-fillet], [0,1,1]);
                  flipX() translate([holeW/2-holeR, 0, holeH-holeR])
                    rotate([-90,0,0]) cylinder(plugLipD, r=holeR+plugLipW-fillet, $fn=2*$fn);
                }
                difference() {
                  sphere(circumgoncircumradius(fillet), $fn=4*ceil($fn/8));
                  box([2*fillet+1, 2*fillet+1, fillet+1], [0,0,-1]);
                }
              }
            translate([0, 0, -1]) box([holeW+2*plugLipW+1, 2*fillet+1, holeH+plugLipW+2], [0,-1,1]);
          }
        // middle
        box([holeW-slop, acrylicD+slop+plugLipD, holeH-holeR], [0,0,1]);
        box([holeW-2*holeR, acrylicD+slop+plugLipD, holeH-slop/2], [0,0,1]);
        flipX() translate([holeW/2-holeR, 0, holeH-holeR]) rotate([90,0,0])
          cylinder(acrylicD+slop+plugLipD, r=holeR-slop/2, center=true, $fn=2*$fn);
      }
      // frame lip
      translate([0, acrylicD/2, -1]) box([holeW+2*plugLipW+1, plugLipD+1, frameLip+slop/2+1], [0,1,1]);
    }
}

// base();

// color([0.5,0,0,0.5]) hole($fn=fn);
// color([0.5,0,0,0.5]) base($fn=fn);

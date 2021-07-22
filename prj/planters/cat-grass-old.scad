use <nz/nz.scad>;


$fn = 24;


linkSlop = 0.3;
snap = .75;
spacing = 3;
lidSlop = 1;
lidSlop45 = (sqrt(2)-1)*lidSlop;

lineW = 0.4;

baseWall = lineW*4 + 0.01;
lidWall = lineW*10 + 0.01;
grillWall = lineW*4 + 0.01;

ledge = 2.5;

baseW = 200;
baseD = 150;
baseH = 20;

tongue = 2.45;
groove = tongue + lidSlop/2;
protrude = lidSlop/2 - lidSlop45/2;

floorH = 1.5;
topH = 0.5;
grillH = 1.5;

lidW = baseW - baseWall*2 - tongue*2 - lidSlop*2;
lidD = baseD - baseWall*2 - tongue*2 - lidSlop*2;
lidH = tongue*2 + lidSlop/2 + topH;  // TODO Is this still the best option here?

thumbD = 30;
thumbR = thumbD/2;

holeMaxW = 6;
holeUnitsL = 5;

linkInnerD = 5;
linkInnerR = linkInnerD/2;
linkOuterD = 8;
linkOuterR = linkOuterD/2;
linkDeltaD = linkOuterD - linkInnerD;
linkDeltaR = linkDeltaD/2;

linkInset = baseWall + linkSlop/2 + linkOuterR;
linkFrameR = max(linkInset, baseWall + groove + linkSlop/2 + linkInnerR);

fillet = min(groove - 1, linkInset);

module base(thumbX=true) {
  module shell() {
    box([baseW-linkInset*2, baseD, baseH-fillet], [0,0,1]);
    box([baseW, baseD-linkInset*2, baseH-fillet], [0,0,1]);
    box([baseW-linkInset*2, baseD-fillet*2, baseH], [0,0,1]);
    box([baseW-fillet*2, baseD-linkInset*2, baseH], [0,0,1]);
    flipX() translate([baseW/2-fillet, 0, baseH-fillet]) rotate([90,0,0])
      cylinder(baseD-linkInset*2, r=fillet, center=true);
    flipY() translate([0, baseD/2-fillet, baseH-fillet]) rotate([0,90,0])
      cylinder(baseW-linkInset*2, r=fillet, center=true);
  }
  difference() {
    union() {
      difference() {
        shell();
        // over ledge
        translate([0, 0, baseH-topH-groove]) box([lidW+lidSlop, lidD+lidSlop, baseH], [0,0,1]);
        translate([0, 0, floorH]) {
          // middle
          box([lidW-ledge*2+protrude*2, lidD-ledge*2+protrude*2, baseH], [0,0,1]);
          // ledge notch
          if (thumbX) box([lidW+lidSlop, thumbD, baseH], [0,0,1]);
          else        box([thumbD, lidD+lidSlop, baseH], [0,0,1]);
          // under ledge
          hull() {
            box([baseW-baseWall*2, baseD-baseWall*2, baseH-topH*2-groove*3-lidSlop45/2-ledge-floorH], [0,0,1]);
            box([lidW-ledge*2+protrude*2, lidD-ledge*2+protrude*2, baseH-topH*2-groove*2-floorH], [0,0,1]);
          }
        }
        // grooves
        translate([0, 0, baseH-topH-groove]) {
          flipX() translate([lidW/2+lidSlop/2, 0, 0]) hull() {
            rotate([90,0,0]) linear_extrude(thumbX?thumbD:lidD+lidSlop, center=true)
              polygon([[0, groove], [groove, 0], [0, -groove]]);
            box([ledge+1, lidD+lidSlop, groove*2], [-1,0,0]);
          }
          flipY() translate([0, lidD/2+lidSlop/2, 0]) hull() {
            rotate([0,90,0]) linear_extrude(thumbX?lidW+lidSlop:thumbD, center=true)
              polygon([[groove, 0], [0, groove], [-groove, 0]]);
            box([lidW+lidSlop, ledge+1, groove*2], [0,-1,0]);
          }
        }
      }
      // corners
      intersection() {
        flipX() flipY() translate([baseW/2-linkInset, baseD/2-linkInset, baseH/2])
          cylinder(baseH, r=linkFrameR, center=true);
        shell();
      }
    }
    // links
    flipX() flipY() translate([baseW/2-linkInset, baseD/2-linkInset, baseH/2]) {
      spindle(baseH-linkDeltaD*2-topH*2, d=linkOuterD+linkSlop, p=linkOuterD+linkSlop, center=true);
      hull() {
        spindle(baseH-linkDeltaD*2-topH*2, d=linkOuterD-snap+linkSlop, p=linkOuterD-snap+linkSlop, center=true);
        translate([linkInset*2, linkInset*2, 0])
          spindle(baseH-linkDeltaD*2-topH*2, d=linkOuterD-snap+linkSlop, p=linkOuterD-snap+linkSlop, center=true);
      }
      cylinder(baseH+1, d=linkInnerD+linkSlop, center=true);
      hull() {
        cylinder(baseH+1, d=linkInnerD-snap+linkSlop, center=true);
        translate([linkInset*2, linkInset*2, 0])
          cylinder(baseH+1, d=linkInnerD-snap+linkSlop, center=true);
      }
    }
  }
}

module lid(thumbX=true, symmetric=true, alternate=false) {

  cellMaxL = holeMaxW + grillWall;
  tileMaxL = cellMaxL * holeUnitsL*2;

  grillW = lidW - lidWall*2;
  grillD = lidD - lidWall*2;

  gridW = baseW + lidSlop; // grillW + grillWall;
  gridD = baseD + lidSlop; // grillD + grillWall;

  tilesW = ceil(gridW / tileMaxL);
  tilesD = ceil(gridD / tileMaxL);

  cellsW = tilesW * holeUnitsL*2;
  cellsD = tilesD * holeUnitsL*2;

  cellW = gridW / cellsW;
  cellD = gridD / cellsD;

  holeW = cellW - grillWall;
  holeD = cellD - grillWall;

  echo(holeW);
  echo(holeD);

  alt = alternate ? 1 : -1;

  module thumbCut()
    if (thumbX) flipX() translate([lidW/2, 0, 0]) cylinder(lidH+2, r=thumbR, center=true);
    else        flipY() translate([0, lidD/2, 0]) cylinder(lidH+2, r=thumbR, center=true);

  module linkCut() flipX() flipY() translate([baseW/2-linkInset, baseD/2-linkInset, 0])
    cylinder(lidH+2, r=linkFrameR+lidSlop/2, center=true);

  module holeD() box([holeW, cellD*holeUnitsL-grillWall, grillH+1], [1,1,0]);
  module holeW() box([cellW*holeUnitsL-grillWall, holeD, grillH+1], [1,1,0]);

  module tongueX(length) translate([0, 0, lidH/2-tongue]) hull() {
    rotate([90,0,0]) linear_extrude(length, center=true)
      polygon([[protrude, tongue], [tongue+protrude, 0], [0, -tongue-protrude]]);
    box([lidWall, lidD, tongue*2], [-1,0,0]);
  }

  module tongueY(length) translate([0, 0, lidH/2-tongue]) hull() {
    rotate([0,90,0]) linear_extrude(length, center=true)
      polygon([[tongue+protrude, 0], [0, tongue+protrude], [-tongue, protrude]]);
    box([lidW, lidWall, tongue*2], [0,-1,0]);
  }

  translate([0, 0, lidH/2]) {
    // frame
    difference() {
      box([lidW, lidD, lidH], [0,0,0]);
      box([grillW, grillD, lidH+1], [0,0,0]);
      thumbCut();
      linkCut();
    }
    difference() {
      union() {
        flipX() translate([lidW/2, 0, 0]) {
          // x tongues
          if (!thumbX) tongueX(lidD);
          else {
            difference() {
              tongueX(thumbD);
              box([max(lidWall, tongue)*2+1, thumbD, lidH+1], [0,0,0]);
            }
            // x thumbs
            difference() {
              tube(lidH, innerR=thumbR, outerR=thumbR+lidWall, center=true);
              box([thumbR+lidWall+1, thumbD+lidWall*2+1, lidH+1], [1,0,0]);
            }
          }
        }
        flipY() translate([0, lidD/2, 0]) {
          // y tongues
          if (thumbX) tongueY(lidW);
          else {
            difference() {
              tongueY(thumbD);
              box([thumbD, max(lidWall, tongue)*2+1, lidH+1], [0,0,0]);
            }
            // y thumbs
            difference() {
              tube(lidH, innerR=thumbR, outerR=thumbR+lidWall, center=true);
              box([thumbD+lidWall*2+1, thumbR+lidWall+1, lidH+1], [0,1,0]);
            }
          }
        }
        // links
        flipX() flipY() difference() {
          translate([baseW/2-linkInset, baseD/2-linkInset, 0])
            cylinder(lidH, r=linkFrameR+lidSlop/2+lidWall, center=true);
          translate([baseW/2-linkInset, lidD/2, 0])
            box([linkFrameR*2+lidSlop+lidWall*2+1, linkFrameR*2+lidSlop+lidWall*2+1, lidH+1], [0,1,0]);
          translate([lidW/2, baseD/2-linkInset, 0])
            box([linkFrameR*2+lidSlop+lidWall*2+1, linkFrameR*2+lidSlop+lidWall*2+1, lidH+1], [1,0,0]);
        }
      }
      linkCut();
    }
  }
  // grill
  translate([0, 0, grillH/2]) {
    difference() {
      box([lidW, lidD, grillH], [0,0,0]);
      translate([(grillWall-gridW)/2, (grillWall-gridD)/2, 0])
        for (i = [-cellsD : holeUnitsL*2 : cellsW])
          for (j = [-holeUnitsL : cellsD-1])
            translate([cellW*(i+(symmetric?holeUnitsL/2-.5:floor(holeUnitsL/2))*alt)+cellW*j, cellD*j, 0])
              if (alternate) {
                holeD();
                translate([cellW, 0, 0]) holeW();
              } else {
                holeW();
                translate([0, cellD, 0]) holeD();
              }
      thumbCut();
      linkCut();
    }
  }
}

module link()
  translate([0, 0, baseH/2]) {
    translate([linkInset+spacing/2, linkInset+spacing/2, 0]) {
      spindle(baseH-linkDeltaD*2-topH*2, d=linkOuterD, p=linkOuterD, center=true);
      cylinder(baseH+1, d=linkInnerD, center=true);
    }
    hull() {
      spindle(baseH-linkDeltaD*2-topH*2, d=linkOuterD-snap, p=linkOuterD-snap, center=true);
      translate([linkInset+spacing/2, linkInset+spacing/2, 0])
        spindle(baseH-linkDeltaD*2-topH*2, d=linkOuterD-snap, p=linkOuterD-snap, center=true);
    }
    hull() {
      cylinder(baseH+1, d=linkInnerD-snap, center=true);
      translate([linkInset+spacing/2, linkInset+spacing/2, 0])
        cylinder(baseH+1, d=linkInnerD-snap, center=true);
    }
  }

module link1() {
  intersection() {
    link();
    translate([spacing/2, spacing/2, 0]) {
      hull() {
        translate([linkInset, 0, 0])
          box([linkOuterR+1, linkInset+linkOuterR+1, baseH-fillet], [1,1,1]);
        translate([0, linkInset, 0])
          box([linkInset+linkOuterR+1, linkOuterR+1, baseH-fillet], [1,1,1]);
        translate([linkInset, fillet, 0])
          box([linkOuterR+1, linkInset+linkOuterR-fillet+1, baseH], [1,1,1]);
        translate([fillet, linkInset, 0])
          box([linkInset+linkOuterR-fillet+1, linkOuterR+1, baseH], [1,1,1]);
      }
      translate([linkInset, linkInset, baseH-fillet]) rotate_extrude() {
        translate([linkInset-fillet, 0, 0]) difference() {
          circle(r=fillet);
          rect([fillet+1, fillet*2+1], [-1,0]);
        }
        rect([linkInset-fillet, fillet*2], [1,0]);
      }
      translate([linkInset, fillet, baseH-fillet]) rotate([0,90,0]) cylinder(linkOuterR+1, r=fillet);
      translate([fillet, linkInset, baseH-fillet]) rotate([-90,0,0]) cylinder(linkOuterR+1, r=fillet);
    }
  }
  translate([spacing/2, spacing/2, 0])
    intersection() {
      box([linkInset-linkSlop/2, linkInset-linkSlop/2, baseH], [1,1,1]);
      translate([linkInset, linkInset, 0]) {
        cylinder(baseH-fillet, r=linkInset);
        translate([0, 0, baseH-fillet]) rotate_extrude() {
          translate([linkInset-fillet, 0, 0]) difference() {
            circle(r=fillet);
            rect([fillet+1, fillet*2+1], [-1,0]);
          }
          rect([linkInset-fillet, fillet*2], [1,0]);
        }
      }
    }
}

module link2() {
  intersection() {
    flipX() link();
    translate([0, spacing/2, 0]) {
      hull() {
        box([linkInset*2+linkOuterD+spacing+2, linkInset+linkOuterR+1, baseH-fillet], [0,1,1]);
        translate([0, fillet, 0])
          box([linkInset*2+linkOuterD+spacing+2, linkInset+linkOuterR-fillet+1, baseH], [0,1,1]);
      }
      translate([0, fillet, baseH-fillet]) rotate([0,90,0]) cylinder(linkInset*2+linkOuterD+spacing+2, r=fillet, center=true);
    }
  }
  translate([0, spacing/2, 0]) {
    box([linkInset*2+spacing-linkSlop, linkInset-linkSlop/2, baseH-fillet], [0,1,1]);
    translate([0, fillet, 0])
      box([linkInset*2+spacing-linkSlop, linkInset-linkSlop/2-fillet, baseH], [0,1,1]);
    translate([0, fillet, baseH-fillet]) difference() {
      rotate([0,90,0]) cylinder(linkInset*2+spacing-linkSlop, r=fillet, center=true);
      box([linkInset*2+spacing-linkSlop+1, fillet+1, fillet*2+1], [0,1,0]);
    }
  }
}

module link4() {
  intersection() {
    flipX() flipY() link();
    box([linkInset*2+linkOuterD+spacing+1, linkInset*2+linkOuterD+spacing+1, baseH], [0,0,1]);
  }
  box([linkInset*2+spacing-linkSlop, linkInset*2+spacing-linkSlop, baseH], [0,0,1]);
}

module demo() {
  color([0.35, 0.25, 0.15, 1.0])
    // render() {
      translate([+baseW/2+spacing/2, +baseD/2+spacing/2, 0]) base(thumbX=false);
      translate([-baseW/2-spacing/2, +baseD/2+spacing/2, 0]) base(thumbX=false);
      translate([-baseW/2-spacing/2, -baseD/2-spacing/2, 0]) base(thumbX=false);
      translate([+baseW/2+spacing/2, -baseD/2-spacing/2, 0]) base(thumbX=false);
    // }

  color([0.3, 0.7, 0.0, 1.0])
    // render() {
      translate([0, 0, baseH-topH-groove+lidH/2]) {
        translate([+baseW/2+spacing/2, +baseD/2+spacing/2, 0]) rotate([180,0,0]) lid(thumbX=false, symmetric=true, alternate=false);
        translate([-baseW/2-spacing/2, +baseD/2+spacing/2, 0]) rotate([180,0,0]) lid(thumbX=false, symmetric=true, alternate=false);
        translate([-baseW/2-spacing/2, -baseD/2-spacing/2, 0]) rotate([180,0,0]) lid(thumbX=false, symmetric=true, alternate=false);
        translate([+baseW/2+spacing/2, -baseD/2-spacing/2, 0]) rotate([180,0,0]) lid(thumbX=false, symmetric=true, alternate=false);
      }
      translate([+baseW+spacing,              0, 0]) rotate( 90) link2();
      translate([+baseW+spacing, +baseD+spacing, 0]) rotate(180) link1();
      translate([             0, +baseD+spacing, 0]) rotate(180) link2();
      translate([-baseW-spacing, +baseD+spacing, 0]) rotate(-90) link1();
      translate([-baseW-spacing,              0, 0]) rotate(-90) link2();
      translate([-baseW-spacing, -baseD-spacing, 0]) rotate(  0) link1();
      translate([             0, -baseD-spacing, 0]) rotate(  0) link2();
      translate([+baseW+spacing, -baseD-spacing, 0]) rotate( 90) link1();
      link4();
    // }
}

// demo();

module demo2() {
  color([0.35, 0.25, 0.15, 1.0])
    render() {
      translate([+baseW/2+spacing/2, +baseD/2+spacing/2, 0]) base(thumbX=false);
      translate([-baseW/2-spacing/2, +baseD/2+spacing/2, 0]) base(thumbX=false);
      translate([-baseW/2-spacing/2, -baseD/2-spacing/2, 0]) base(thumbX=false);
      translate([+baseW/2+spacing*3/2+linkInset*2, -baseD/2-spacing*3/2-linkInset*2, 0]) base(thumbX=false);
    }

  color([0.3, 0.7, 0.0, 1.0])
    render() {
      translate([0, 0, baseH-topH-groove+lidH/2]) {
        translate([+baseW/2+spacing/2, +baseD/2+spacing/2, 0]) rotate([180,0,0]) lid(thumbX=false, symmetric=true, alternate=false);
        translate([-baseW/2-spacing/2, +baseD/2+spacing/2, 0]) rotate([180,0,0]) lid(thumbX=false, symmetric=true, alternate=false);
        translate([-baseW/2-spacing/2, -baseD*3/2-spacing*3/2, -baseH+topH+groove-lidH/2]) rotate([  0,0,0]) lid(thumbX=false, symmetric=true, alternate=false);
        translate([+baseW/2+spacing*3/2+linkInset*2, -baseD/2-spacing*3/2-linkInset*2, baseH]) rotate([180,0,0]) lid(thumbX=false, symmetric=true, alternate=false);
      }
      translate([+baseW+spacing*3+linkInset*4,              0, 0]) rotate( 90) link2();
      translate([+baseW+spacing, +baseD+spacing, 0]) rotate(180) link1();
      translate([             0, +baseD+spacing, 0]) rotate(180) link2();
      translate([-baseW-spacing, +baseD+spacing, 0]) rotate(-90) link1();
      translate([-baseW-spacing,              0, 0]) rotate(-90) link2();
      translate([-baseW-spacing, -baseD-spacing, 0]) rotate(  0) link1();
      translate([             spacing+linkInset*2, -baseD-spacing*4-linkInset*6, 0]) rotate(  0) link2();
      translate([+baseW+spacing*3+linkInset*4, -baseD-spacing*3-linkInset*4, 0]) rotate( 90) link1();
      link4();
    }
}

// demo2();

// color([0.35, 0.25, 0.15, 1.0])
//   // render()
//     translate([baseW/2+spacing/2, baseD/2+spacing/2, 0]) base(thumbX=false);

// color([0.3, 0.7, 0.0, 1.0]) {
//   // render()
//     translate([baseW/2+spacing/2, baseD/2+spacing/2, baseH-topH-groove+lidH/2])
//       rotate([180,0,0]) lid(thumbX=false, symmetric=true, alternate=false);
//     render() link2();
// }

module cutaway() {
  difference() {
    color([0.35, 0.25, 0.15, 1.0])
      // render()
        base(thumbX=false);
    translate([thumbR, 0, 0]) box([baseW, baseD+1, baseH*2+1], [-1,0,0]);
    box([baseW+1, baseD, baseH*2+1], [0,-1,0]);
  }

  difference() {
    color([0.3, 0.7, 0.0, 1.0])
      // render()
        translate([0, 0, baseH])
          rotate([180,0,0]) lid(thumbX=false, symmetric=true, alternate=false);
    translate([thumbR, 0, 0]) box([baseW, baseD+1, baseH*2+1], [-1,0,0]);
    box([baseW+1, baseD, baseH*2+1], [0,-1,0]);
  }
}

cutaway();

// lid(thumbX=false, symmetric=true, alternate=false);

use <nz/nz.scad>;
use <nz/zigzag.scad>;


$fn = 60;


spacing = 1;
snap = 1.0;
linkSlop = 0.4;
lidSlop = 0.6;
lidSlop45 = lidSlop*(sqrt(2)-1);

lineW = 0.6;

baseWall = lineW*4 + 0.01;  // TODO: add correction if fillet is larger than point of groove
lidWall = lineW*4 + 0.01;
grillWall = lineW + 0.01;

ledge = lidWall;

baseW = 160;
baseD = 120;
baseH = 20;

thumbD = 25;
thumbR = thumbD/2;
thumbX = false;

holeMaxW = 12;
holeMaxD = 1.75;
gap = 0.03;   // my Cura starts ignoring the gap somewhere around 0.0275-0.02825
centerWLine = true;
centerDLine = true;
alternate = true;
reverse = false;

tongue = 2;
groove = tongue + lidSlop/2;

floorH = 1.65;
topH = 0.75;
grillH = 2.55;

floorChamfer = 2;

linkInnerD = 4;
linkInnerR = linkInnerD/2;
linkOuterD = 8;
linkOuterR = linkOuterD/2;
linkDeltaD = linkOuterD - linkInnerD;
linkDeltaR = linkDeltaD/2;

linkInset = baseWall + linkSlop/2 + linkOuterR;

fillet = min(baseWall+tongue, linkInset);

baseWallExtra = fillet < topH+tongue ? 0 : fillet-fillet*cos(asin((fillet-topH-tongue)/fillet));
echo(baseWallExtra);

lidW = baseW - baseWall*2 - baseWallExtra*2 - tongue*2 - lidSlop;
lidD = baseD - baseWall*2 - baseWallExtra*2 - tongue*2 - lidSlop;
lidH = tongue*2 + lidSlop45/2 + topH;

grillW = lidW - lidWall*2;
grillD = lidD - lidWall*2;

gridW = baseW + spacing;
gridD = baseD + spacing;

linkLidR = max(linkInset, baseWall+baseWallExtra+tongue+linkSlop/2+linkInnerR) + lidSlop/2;
linkLidCorner = linkInset + sqrt(square(linkLidR) - square(baseWall+baseWallExtra+groove-linkInset));
linkLidA = atan((linkLidCorner-linkInset)/(baseWall+baseWallExtra+groove-linkInset));


module base() {

  module shell() {
    box([baseW-linkInset*2, baseD, baseH-fillet], [0,0,1]);
    box([baseW, baseD-linkInset*2, baseH-fillet], [0,0,1]);
    box([baseW-linkInset*2, baseD-fillet*2, baseH], [0,0,1]);
    box([baseW-fillet*2, baseD-linkInset*2, baseH], [0,0,1]);
    flipX() translate([baseW/2-fillet, 0, baseH-fillet])
      rotate([90,0,0]) cylinder(baseD-linkInset*2, r=fillet, center=true);
    flipY() translate([0, baseD/2-fillet, baseH-fillet])
      rotate([0,90,0]) cylinder(baseW-linkInset*2, r=fillet, center=true);
  }

  difference() {
    union() {
      difference() {
        shell();
        // over ledge
        translate([0, 0, baseH-topH-tongue-lidSlop45/2]) box([lidW+lidSlop, lidD+lidSlop, baseH], [0,0,1]);
        translate([0, 0, floorH+floorChamfer]) {
          // middle
          box([lidW-ledge*2, lidD-ledge*2, baseH], [0,0,1]);
          // ledge notch
          if (thumbX) box([lidW+lidSlop45, thumbD, baseH], [0,0,1]);
          else        box([thumbD, lidD+lidSlop45, baseH], [0,0,1]);
          // under ledge
          hull() {
            box([lidW-ledge*2, lidD-ledge*2, baseH-lidH-lidSlop/2-topH-floorH-floorChamfer], [0,0,1]);
            box([baseW-baseWall*2, baseD-baseWall*2, baseH-lidH-lidSlop-topH-ledge-tongue-lidSlop45/2-floorH-floorChamfer], [0,0,1]);
            box([baseW-baseWall*2-floorChamfer*2, baseD-baseWall*2-floorChamfer*2, floorChamfer], [0,0,-1]);
          }
        }
        // grooves
        translate([0, 0, baseH-topH-tongue-lidSlop45/2]) {
          flipX() translate([lidW/2, 0, 0]) difference() {
            rotate([90,0,0]) linear_extrude(lidD+lidSlop, center=true)
              polygon([
                [        -ledge-1,       groove],
                [     lidSlop45/2,       groove],
                [tongue+lidSlop/2,  lidSlop45/2],
                [tongue+lidSlop/2, -lidSlop45/2],
                [     lidSlop45/2,      -groove],
                [        -ledge-1,      -groove] ]);
            if (thumbX) translate([lidSlop/2, 0, 0]) flipY() hull() {
              translate([tongue, thumbR, 0]) box([tongue+1, 1, groove*2+1], [1,1,0]);
              translate([0, baseD/2-linkLidCorner, 0]) box([tongue+1, linkLidCorner, groove*2+1], [1,1,0]);
            }
          }
          flipY() translate([0, lidD/2, 0]) difference() {
            rotate([0,-90,0]) linear_extrude(lidW+lidSlop, center=true)
              polygon([
                [      groove,         -ledge-1],
                [      groove,      lidSlop45/2],
                [ lidSlop45/2, tongue+lidSlop/2],
                [-lidSlop45/2, tongue+lidSlop/2],
                [     -groove,      lidSlop45/2],
                [     -groove,         -ledge-1] ]);
            if (!thumbX) translate([0, lidSlop/2, 0]) flipX() hull() {
              translate([thumbR, tongue, 0]) box([1, tongue+1, groove*2+1], [1,1,0]);
              translate([baseW/2-linkLidCorner, 0, 0]) box([linkLidCorner, tongue+1, groove*2+1], [1,1,0]);
            }
          }
        }
      }
      // corners
      intersection() {
        flipX() flipY() translate([baseW/2-linkInset, baseD/2-linkInset, baseH/2])
          rotate(thumbX?90-linkLidA:linkLidA) cylinder(baseH, r=linkLidR-lidSlop/2, center=true);
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


module lid() {

  module thumbCut(extraR=0)
    if (thumbX) flipX() translate([lidW/2, 0]) circle(r=thumbR+extraR);
    else        flipY() translate([0, lidD/2]) circle(r=thumbR+extraR);

  module linkCut(extraR=0) flipX() flipY() translate([baseW/2-linkInset, baseD/2-linkInset])
    rotate(thumbX?90-linkLidA:linkLidA) circle(r=linkLidR+extraR);

  module mask() difference() {
    rect([grillW-gap*2, grillD-gap*2], [0,0]);
    thumbCut(lidWall+gap);
    linkCut(lidWall+gap);
  }

  module grill() {
    mirror(reverse ? (alternate?[0,0,1]:[1,0,0]) : (alternate?[1,0,0]:[0,0,1]))
      if (alternate)
        rotate(90)
          zigzag(bounds=[gridD, gridW], holeMax=[holeMaxD, holeMaxW], centerLine=[centerDLine, centerWLine], wall=grillWall, gap=gap)
            rotate(-90) mask();
      else
        zigzag(bounds=[gridW, gridD], holeMax=[holeMaxW, holeMaxD], centerLine=[centerWLine, centerDLine], wall=grillWall, gap=gap)
          mask();
  }

  module tongueX(length) translate([0, 0, lidH/2-tongue]) hull() {
    rotate([90,0,0]) linear_extrude(length, center=true)
      polygon([[0, tongue], [tongue, 0], [0, -tongue]]);
    box([lidWall, baseD-linkLidCorner*2, tongue*2], [-1,0,0]);
  }

  module tongueY(length) translate([0, 0, lidH/2-tongue]) hull() {
    rotate([0,-90,0]) linear_extrude(length, center=true)
      polygon([[tongue, 0], [0, tongue], [-tongue, 0]]);
    box([baseW-linkLidCorner*2, lidWall, tongue*2], [0,-1,0]);
  }

  translate([0, 0, lidH/2]) {
    difference() {
      union() {
        // frame
        difference() {
          box([lidW, lidD, lidH], [0,0,0]);
          box([grillW, grillD, lidH+1], [0,0,0]);
        }
        flipX() translate([lidW/2, 0, 0]) {
          // x tongues
          if (!thumbX) tongueX(baseD-linkLidCorner*2);
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
          if (thumbX) tongueY(baseW-linkLidCorner*2);
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
            rotate(thumbX?90-linkLidA:linkLidA) cylinder(lidH, r=linkLidR+lidWall, center=true);
          translate([baseW/2-linkInset, lidD/2, 0])
            box([linkLidR*2+lidWall*2+1, linkLidR*2+lidWall*2+1, lidH+1], [0,1,0]);
          translate([lidW/2, baseD/2-linkInset, 0])
            box([linkLidR*2+lidWall*2+1, linkLidR*2+lidWall*2+1, lidH+1], [1,0,0]);
        }
      }
      extrude(lidH+2, center=true) thumbCut();
      extrude(lidH+2, center=true) linkCut();
      translate([0, 0, -lidH/2-1]) extrude(grillH+1) intersection() {
        offset(delta=gap) grill();
        offset(delta=grillWall+gap) mask();
      }
    }
  }
  extrude(grillH) grill();
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
        translate([linkInset, 0, 0])      box([linkOuterR+1, linkInset+linkOuterR+1, baseH-fillet], [1,1,1]);
        translate([0, linkInset, 0])      box([linkInset+linkOuterR+1, linkOuterR+1, baseH-fillet], [1,1,1]);
        translate([linkInset, fillet, 0]) box([linkOuterR+1, linkInset+linkOuterR-fillet+1, baseH], [1,1,1]);
        translate([fillet, linkInset, 0]) box([linkInset+linkOuterR-fillet+1, linkOuterR+1, baseH], [1,1,1]);
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



module demoRaiseLid() {
  color([0.35, 0.25, 0.15, 1.0])
    // render()
      base();

  color([0.3, 0.7, 0.0, 1.0])
    // render()
      translate([0, 0, baseH*2])
        rotate([180,0,0])
          lid();
}

// demoRaiseLid();


module demoLink() {
  color([0.35, 0.25, 0.15, 1.0])
    // render()
      translate([baseW/2+spacing/2, baseD/2+spacing/2, 0])
        base();

  color([0.3, 0.7, 0.0, 1.0]) {
    // render()
      translate([baseW/2+spacing/2, baseD/2+spacing/2, baseH])
        rotate([180,0,0])
          lid();
    // render()
      link2();
  }
}

// demoLink();


module demoGrid() {
  color([0.35, 0.25, 0.15, 1.0])
    // render() {
      translate([+baseW/2+spacing/2, +baseD/2+spacing/2, 0]) base();
      translate([-baseW/2-spacing/2, +baseD/2+spacing/2, 0]) base();
      translate([-baseW/2-spacing/2, -baseD/2-spacing/2, 0]) base();
      translate([+baseW/2+spacing/2, -baseD/2-spacing/2, 0]) base();
    // }

  color([0.3, 0.7, 0.0, 1.0])
    // render() {
      translate([0, 0, baseH]) {
        translate([+baseW/2+spacing/2, +baseD/2+spacing/2, 0]) rotate([180,0,0]) lid();
        translate([-baseW/2-spacing/2, +baseD/2+spacing/2, 0]) rotate([180,0,0]) lid();
        translate([-baseW/2-spacing/2, -baseD/2-spacing/2, 0]) rotate([180,0,0]) lid();
        translate([+baseW/2+spacing/2, -baseD/2-spacing/2, 0]) rotate([180,0,0]) lid();
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

// demoGrid();


module demoGridExplode() {
  color([0.35, 0.25, 0.15, 1.0])
    render() {
      translate([+baseW/2+spacing  /2            , +baseD/2+spacing  /2            , 0]) base();
      translate([-baseW/2-spacing  /2            , +baseD/2+spacing  /2            , 0]) base();
      translate([-baseW/2-spacing  /2            , -baseD/2-spacing  /2            , 0]) base();
      translate([+baseW/2+spacing*3/2+linkInset*2, -baseD/2-spacing*3/2-linkInset*2, 0]) base();
    }

  color([0.3, 0.7, 0.0, 1.0])
    render() {
      translate([0, 0, baseH]) {
        translate([+baseW/2+spacing/2              , +baseD  /2+spacing  /2            ,      0]) rotate([180,0,0]) lid();
        translate([-baseW/2-spacing/2              , +baseD  /2+spacing  /2            ,      0]) rotate([180,0,0]) lid();
        translate([-baseW/2-spacing/2              , -baseD*3/2-spacing*3/2            , -baseH]) rotate([  0,0,0]) lid();
        translate([+baseW/2+spacing*3/2+linkInset*2, -baseD  /2-spacing*3/2-linkInset*2,  baseH]) rotate([180,0,0]) lid();
      }
      translate([+baseW+spacing*3+linkInset*4,  0                          , 0]) rotate( 90) link2();
      translate([+baseW+spacing              , +baseD+spacing              , 0]) rotate(180) link1();
      translate([ 0                          , +baseD+spacing              , 0]) rotate(180) link2();
      translate([-baseW-spacing              , +baseD+spacing              , 0]) rotate(-90) link1();
      translate([-baseW-spacing              ,  0                          , 0]) rotate(-90) link2();
      translate([-baseW-spacing              , -baseD-spacing              , 0]) rotate(  0) link1();
      translate([       spacing  +linkInset*2, -baseD-spacing*4-linkInset*6, 0]) rotate(  0) link2();
      translate([+baseW+spacing*3+linkInset*4, -baseD-spacing*3-linkInset*4, 0]) rotate( 90) link1();
      link4();
    }
}

// demoGridExplode();


module demoCutaway(x, y) {
  color([0.35, 0.25, 0.15, 1.0])
    render()
      difference() {
        base();
        translate([x, 0, 0]) box([baseW, baseD+1, baseH*2+1], [-1,0,0]);
        translate([0, y, 0]) box([baseW+1, baseD, baseH*2+1], [0,-1,0]);
      }

  color([0.3, 0.7, 0.0, 1.0])
    render()
      difference() {
        translate([0, 0, baseH]) rotate([180,0,0]) lid();
        translate([x, 0, 0]) box([baseW, baseD+1, baseH*2+1], [-1,0,0]);
        translate([0, y, 0]) box([baseW+1, baseD, baseH*2+1], [0,-1,0]);
      }
}

// demoCutaway(0, 0);
// demoCutaway(thumbR-1, thumbR-1);


module demoQuarterBase(x, y) {
  difference() {
    base();
    translate([x, 0, 0]) box([baseW, baseD+1, baseH*2+1], [-1,0,0]);
    translate([0, y, 0]) box([baseW+1, baseD, baseH*2+1], [0,-1,0]);
  }
}

// demoQuarterBase(50, 30);


module demoQuarterLid(x, y) {
  difference() {
    lid();
    translate([-x, 0, 0]) box([baseW, baseD+1, lidH*2+1], [1,0,0]);
    translate([ 0, y, 0]) box([baseW+1, baseD, lidH*2+1], [0,-1,0]);
  }
  difference() {
    union() {
      translate([-x, y, 0]) box([lidW/2-x, grillWall*2, grillH], [-1,1,1]);
      translate([-x, y, 0]) box([grillWall*2, lidD/2-y, grillH], [-1,1,1]);
    }
    if (thumbX) flipX() translate([lidW/2, 0, -1]) cylinder(grillH+2, r=thumbR);
    else        flipY() translate([0, lidD/2, -1]) cylinder(grillH+2, r=thumbR);
  }
}

// demoQuarterLid(0, 0);


// base();
// lid();
link1();
// link2();
// link4();

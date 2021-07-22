use <nz/nz.scad>
use <../filter/filter.scad>

fn = 60;

switchW = 19.75;
switchL = 31;
switchH = 10;
threadD = 11.4;
spadeW = 6.4;
spadeD = 0.8;
copper = [0.85, 0.60, 0.35];
black  = [0.5, 0.5, 0.5];

sealW = 10;
sealD = 2.25;  // fills between 0.5 - 4.0
filterSealW = 12.5;
filterSealD = 2.25;  // 3.75 on filter   fills between 0.6 - 5.5

lineW = 0.4;

wall = 6*lineW + 0.01;
guardWall = 8*lineW + 0.01;
screwWall = 8*lineW + 0.01;
filterWall = 5*lineW + 0.01;
fillet = 10;
innerFillet = 8;
guardFillet = 2;
slop = 0.35;
slack = slop + 0.25;
thread = m_adjusted_thread_width(3, grip=0.1);
//function shank() = m_adjusted_shank_width(3);  // needs to be a function for correct $fn
//head = 6.5;

// in inner dimentions
holeX = 107;
holeY = 22.5;
holeZmin = 29.5;
holeZmax = holeZmin+26.5;

screwFXR = 52;
screwFXL = 92;
screwFY = holeY+3.5;

screwBXR = 45;
screwBXL = 93;
screwBY = holeY+149;
screwBH = 20 - 6;

ledXR = 15;
ledXL = 36;
ledY = 1.5;
door = 36;

fan = 80;

carbonD = 2.0;  // ~1.75 to ~5.0
hepaD = 0.5;    // ~0.4  to ~0.7

filterMargin = filterSealW/2;
filterSize = [fan+2*filterWall+2*sealD, 0, fan+2*filterWall+2*sealD];
filterDs     = [25+2*filterWall+2*sealD, 30,                              30         ];
filterSealWs = [0,                       filterMargin,                    filterSealW];
materialDs   = [100,                     carbonD,                         hepaD      ];
braceZs      = [0,                       0.75,                            0.75       ];
endZs        = [filterMargin-filterWall, filterMargin-filterWall-carbonD, 0.75       ];
minPleatGaps = [0,                       12,                              7          ];
latchW = filterWall + slack/2 + filterMargin/2;
cupSize = f_chain_cupSize(filterSize, filterDs, filterWall, filterSealD, slack, slop);
cupW = cupSize.x;
cupD = cupSize.y;
cupH = cupSize.z;

switches = 4;
switchA = 30;
switchY = 65;
switchSpacing = 2 + 0.005;

guardAngle = -20;
guardExtra = 2.5;

tongue = 2;
groove = tongue + (sqrt(2)-1)*slop/2;

filletArcProjY = fillet*cos(switchA);
filletArcProjZ = fillet-fillet*sin(switchA);
filletIsect = fillet*tan(45-switchA/2);
// innerFilletArcProjY = innerFillet*cos(switchA);
innerFilletArcProjZ = innerFillet-innerFillet*sin(switchA);
innerFilletIsect = innerFillet*tan(45-switchA/2);

// in outer dimensions
coverW = 116 - 2*slack;  // should be holeX + sealW, but not quite enough room
coverHF = holeZmin + sealW;
coverHB = screwBH + cupH + 2*tongue + fillet + sqrt(2)*slop;
coverD = 210;

// in outer dimensions
panelW = coverW - sealD - fillet - slop/2;
panelD = switchH + slack/2 + wall;
panelH = (coverHB-coverHF-filletArcProjZ-innerFilletArcProjZ)/cos(switchA) - slop;

switchesW = switches*switchW + switches*slack + (switches-1)*switchSpacing + 2*guardWall;
switchesH = switchL + slack + 2*guardWall;

switchMarginT = (panelH - switchesH)/2;
switchMarginB = panelH - switchesH - switchMarginT;
switchMarginL = 0;  // (panelW - switchesW - fillet - slop)/2;
switchMarginR = panelW - switchesW - switchMarginL;

coverDF = switchY - sin(switchA)*(switchesH/2 + switchMarginB + slop/2 + innerFilletIsect);
coverDB = coverD - switchY - sin(switchA)*(switchesH/2 + switchMarginT + slop/2 + filletIsect);

cupInset = 85;
maxInset = coverDB - filletIsect + filletArcProjY - panelD*cos(switchA) - tan(switchA)*(panelD*sin(switchA)+filletArcProjZ-fillet);

cupHoleW = panelW + slop/2;
cupHoleH = cupH + 2*groove + slop;

cupX = fillet - coverW + cupW/2 + slop/2;
cupY = coverD - cupInset;
cupZ = screwBH + cupHoleH/2;

wireW = -(cupX + cupW/2);
wireA = atan((maxInset-cupInset)/(cupHoleH/2));


module switch() {
  color(black) hull() flipY() translate([0, (switchL-switchW)/2, 0]) cylinder(switchH, d=switchW);
  rotate([180,0,0]) {
    color(black) cylinder(7.5, d=threadD);
    color(black) cylinder(9, d=10.5);
    color(copper) flipY() translate([0, 3.75, 0]) box([spadeW, spadeD, 9+9.5], [0,-1,1]);
    color(black) box([9.6, 3.15, 17.2], [0,0,1]);
    color(copper) box([spadeW, spadeD, 17.2+10], [0,0,1]);
  }
}

module shell()
  rotate([90,0,90])
    mirror([0,0,1])
      minkowski() {
        translate([0, 0, sealD])
          extrude(coverW-sealD-fillet, convexity=2)
            offset(-fillet-innerFillet) offset(innerFillet)
              polygon([
                [sealD-fillet,   sealD-fillet],
                [sealD-fillet,   coverHF],
                [coverDF,        coverHF],
                [coverD-coverDB, coverHB],
                [coverD,         coverHB],
                [coverD,         sealD-fillet],
              ]);
          difference() {
            teardrop_3d(circumgoncircumradius(fillet), truncate=fillet);
            box([2*fillet+1, 2*fillet+1, fillet+1], [0,0,-1]);
            box([2*fillet+1, fillet+1, 2*fillet+1], [0,-1,0]);
          }
        }

module cavity() {
  panelLowerFrontX = coverDF + innerFilletArcProjZ*tan(switchA);
  panelLowerFrontY = coverHF + innerFilletArcProjZ;
  underPanelCenterX = panelLowerFrontX - (innerFillet+wall-panelD)*cos(switchA);
  underPanelCenterY = panelLowerFrontY + (innerFillet+wall-panelD)*sin(switchA);
  deltaY = underPanelCenterY - panelLowerFrontY + innerFilletArcProjZ + fillet;
  deltaX = sqrt(pow(fillet+innerFillet, 2) - pow(deltaY, 2));
  preUnderPanelCenterY = coverHF - fillet;
  preUnderPanelCenterX = underPanelCenterX - deltaX;
  preUnderPanelX = preUnderPanelCenterX + fillet*tan(atan(deltaX/deltaY)/2);
  rotate([90,0,90])
    mirror([0,0,1])
      minkowski() {
        translate([0, 0, sealD])
          extrude(coverW-sealD-fillet, convexity=2)
            offset(-fillet-innerFillet) offset(innerFillet)
              polygon([
                [sealD-fillet,                              sealD-fillet],
                [sealD-fillet,                              coverHF],
                [preUnderPanelX,                            coverHF],
                [preUnderPanelX,                            coverHF-(panelD-wall)*sin(switchA)],
                [coverDF+(panelD-wall)*cos(switchA),        coverHF-(panelD-wall)*sin(switchA)],
                [coverD-coverDB+(panelD-wall)/cos(switchA), coverHB],
                [coverD-sealW+wall,                         coverHB],
                [coverD-sealW+wall,                         sealD-fillet],
              ]);
        difference() {
          // teardrop_3d(circumgoncircumradius(fillet-wall), truncate=fillet-wall);
          sphere(circumgoncircumradius(fillet-wall));
          translate([0, 0, -0.1]) box([2*fillet, 2*fillet, fillet], [0,0,-1]);
          translate([0, -0.1, 0]) box([2*fillet, fillet, 2*fillet], [0,-1,0]);
        }
      }
}

module wire_slot()
  translate([1, 0, 0])
    rotate([90,0,90])
      extrude(-wireW-1)
        polygon([
          [cupY+sealW,                                                -1],
          [cupY+sealW,                                                 cupZ+sealW*tan(wireA/2)],
          [cupY+sealW-(coverHB+1-cupZ-sealW*tan(wireA/2))*tan(wireA),  coverHB+1],
          [coverD+1,                                                   coverHB+1],
          [coverD+1,                                                  -1],
        ]);


module cover(show_panel=true, show_cup=true, show_filer=true) {

  module screw_front() {
    r = thread/2 + screwWall;
    z = coverHF/2 - wall;
    difference() {
      union() {
        rotate(90) extrude(coverHF) teardrop_2d(r);
        translate([-r, 0, z+wall])
          flipZ()
            rotate([90,0,0])
              extrude(2*lineW+0.01, center=true)
                polygon([[0, 0], [-z-1, z+1], [0, z+1]]);
      }
      translate([-r, 0, z+wall])
        rotate([90,0,0])
          extrude(2*r, center=true)
            polygon([[0, 0], [-z, z], [-z, -z]]);
    }
  }

  module filter_tongue()
    translate([panelW/2+slop/2, 0, 0])
      hull() flipX() translate([panelW/2+groove+slop/2, 0, 0])
        rotate([90,0,0]) spindle(0, r=tongue, center=true, $fn=4);

  module filter_groove()
    intersection() {
      hull() flipZ() translate([0, 0, cupHoleH/2])
        rotate([90,0,0]) spindle(0, r=groove, center=true, $fn=4);
      box([2*groove+1, 2*groove+1, cupHoleH], [0,0,0]);
    }

  color(black) render(convexity=7)
    difference() {
      union() {
        difference() {
          shell();
          translate([0, sealD, 0])
            box([2*coverW+1, fillet+1, 2*coverHF+1], [0,-1,0]);
          cavity();
          wire_slot();
        }
        intersection() {
          union() {
            shell();
            difference() {
              translate([0, holeY, 0])
                rotate([90,0,0])
                  extrude(sealW+holeY-coverD)
                    polygon([[sealW-coverW+sealD, 0], [sealW-coverW-1, sealD+1], [-sealD, sealD+1], [-sealD, 0]]);
              translate([1, cupY, -1]) box([coverW+2, sealW, sealD+2], [-1,1,1]);
            }
          }
          union() {

            // seal edges
            panelLowerBackX = coverDF + panelD*cos(switchA) + innerFilletArcProjZ*tan(switchA);
            panelLowerBackY = coverHF - panelD*sin(switchA) + innerFilletArcProjZ;
            deltaY = panelLowerBackY - coverHF;
            deltaX = deltaY*tan(switchA) + sealW/cos(switchA);
            translate([-sealD, panelLowerBackX-deltaX, panelLowerBackY-deltaY]) {
              rotate([0,90,0])
                rotate_extrude(angle=90-switchA, convexity=1)
                  polygon([[0,0], [0,-sealW-wall], [sealW,-wall], [sealW,0]]);
              rotate([-switchA, 0, 0])
                extrude(deltaY/cos(switchA)+sealW*tan(switchA))
                  polygon([[0,0], [0,sealW], [-wall,sealW], [-sealW-wall,0]]);
            }
            translate([-sealD, sealD, coverHF]) {
              rotate([-90, 0, 0])
                extrude(panelLowerBackX-deltaX-sealD)
                  polygon([[0,0], [0,sealW], [-wall,sealW], [-sealW-wall,0]]);
              rotate([0, -90, 0])
                extrude(coverW-sealD)
                  polygon([[0,0], [0,sealW+wall], [-sealW,wall], [-sealW,0]]);
            }
            translate([-wireW, coverD, coverHB])
              rotate([90, 0, 0])
                extrude(coverDB)
                  polygon([[0,0], [0,-fillet], [-wall,-fillet], [-fillet-wall,0]]);
            translate([-coverW, sealD, sealD]) {
              rotate([-90, 0, 0])
                extrude(coverD-sealD)
                  polygon([[0,0], [0,-sealW-wall], [sealW,-wall], [sealW,0]]);
              extrude(coverHF-sealD)
                polygon([[0,0], [0,sealW+wall], [sealW,wall], [sealW,0]]);
            }

            // front filter support
            translate([0, cupY+sealW/2, 0])
              difference() {
                union() {
                  // solid wall
                  translate([-sealD, 0, sealD])
                    box([coverW-sealD, sealW, coverHB-sealD], [-1,0,1]);
                  // angled wall side
                  translate([-coverW, -sealW/2, cupZ])
                    difference() {
                      multmatrix([[1,0,0,0],[0,1,tan(-wireA),0],[0,0,1,0],[0,0,0,1]])
                        scale([1, 1/cos(wireA), 1])
                          box([fillet, sealW, cupHoleH/2+fillet], [1,1,1]);
                      translate([0, sealW/2, 0]) box([2*fillet+1, sealW, cupHoleH+1], [0,1,0]);
                    }
                }
                translate([fillet-coverW, 0, cupZ])
                  difference() {
                    union() {
                      // wall hole
                      box([cupHoleW+1, sealW+1, cupHoleH], [1,0,0]);
                      // vertical groove
                      filter_groove();
                      // angled groove
                      difference() {
                        translate([0, -sealW/2, 0])
                          multmatrix([[1,0,0,0],[0,1,tan(-wireA),0],[0,0,1,0],[0,0,0,1]])
                            scale([1, 1/cos(wireA), 2])
                              translate([0, sealW/2, 0]) filter_groove();
                        box([2*groove+1, sealW, cupHoleH+1], [0,1,0]);
                      }
                    }
                    flipZ() translate([0, 0, cupHoleH/2])
                      filter_tongue();
                  }
                translate([1, 0, cupZ]) box([wireW+1, sealW+1, coverHB-cupZ+1], [-1,0,1]);
              }

            // front filter support angled top
            translate([-coverW, coverD-maxInset, coverHB-fillet]) {
              multmatrix([[1,0,0,0],[0,1,tan(-wireA),0],[0,0,1,0],[0,0,0,1]])
                scale([1, 1/cos(wireA), 1]) box([coverW-sealD, sealW, fillet], [1,1,1]);
              translate([fillet, (sealW/2)/cos(wireA), 0]) filter_tongue();
            }

            // floor supports
            translate([-coverW, 0, 0]) {
              translate([0, holeY, 0]) {
                multmatrix([[1,0,-1,0],[0,1,0,0],[0,0,1,0],[0,0,0,1]]) {
                  translate([0, wall, 0]) {
                    translate([0, 0, sealD])
                      rotate([0,90,0]) cylinder(sealW+sqrt(2)*(sealD+wall), r=wall);
                    box([sealW+sqrt(2)*(sealD+wall), coverD-holeY-wall-cupInset, sealD+wall], [1,1,1]);
                  }
                  box([sealW+sqrt(2)*(sealD+wall), coverD-holeY-cupInset, wall], [1,1,1]);
                }
              }
              translate([0, cupY, 0])
                box([coverW-screwFXR+screwWall+thread/2, wall, sealD+wall], [1,-1,1]);
            }

            // front screws
            difference() {
              union() {
                translate([-coverW, holeY+wall, 0]) {
                  rotate([0,90,0]) cylinder(coverW-screwFXR, r=wall);
                  box([coverW-screwFXR, cupY-holeY-wall, wall], [1,1,1]);
                }
                translate([0, holeY+screwWall+thread/2, 0]) {
                  translate([-screwFXR, 0, 0]) screw_front();
                  translate([-screwFXL, 0, 0]) screw_front();
                  translate([-coverW, 0, 0])
                    box([coverW-screwFXR+screwWall+thread/2, cupY-holeY-screwWall-thread/2, wall], [1,1,1]);
                }
              }
              translate([-screwFXR, screwFY, -1]) cylinder(coverHF+2, d=thread);
              translate([-screwFXL, screwFY, -1]) cylinder(coverHF+2, d=thread);
            }

            // rear screws
            difference() {
              union() {
                translate([-coverW, 0, 0]) {
                  translate([0, screwBY, 0]) box([coverW-wireW, 2*screwWall+thread, screwBH], [1,0,1]);
                  translate([0, coverD-sealW, sealD]) box([coverW-wireW, cupInset-2*sealW, wall], [1,-1,1]);
                }
                translate([-wireW, coverD-sealW, 0])
                  rotate([90, 0, 0])
                    extrude(cupInset-2*sealW)
                      polygon([[0,sealD], [0,screwBH], [-wall,screwBH], [-screwBH-wall+sealD,sealD]]);
              }
              translate([-screwBXR, screwBY, -1]) cylinder(screwBH+2, d=thread);
              translate([-screwBXL, screwBY, -1]) cylinder(screwBH+2, d=thread);
            }
          }
        }
      }

      // switch panel groove
      translate([-sealD, coverDF, coverHF])
        rotate([-switchA, 0, 0])
          translate([1, panelD/2, panelH/2+slop/2+innerFilletIsect])
            difference() {
              box([panelW+slop/2+1, panelD+slop, panelH+slop], [-1,0,0]);
              translate([-panelW/2, 0, 0])
                flipZ() translate([0, 0, panelH/2+slop/2])
                  hull() flipX() translate([panelW/2+slop/2+1, 0, 0])
                    rotate([90,0,0]) spindle(panelD-2*wall-2*tongue-(sqrt(2)-1)*slop, r=tongue, center=true);
              translate([-panelW-slop/2-1, 0, 0])
                hull() flipZ() translate([0, 0, panelH/2+slop/2])
                  rotate([90,0,0]) spindle(panelD-2*wall-2*tongue-(sqrt(2)-1)*slop, r=tongue, center=true);
            }

      // rear filter support
      translate([fillet-coverW, coverD-sealW/2, cupZ])
        difference() {
          union() {
            box([cupHoleW+1, sealW+1, cupHoleH], [1,0,0]);
            filter_groove();
          }
          flipZ() translate([0, 0, cupHoleH/2])
            filter_tongue();
        }

      // LED strips
      translate([0, 0, -1]) extrude(coverHF+2) polygon([
        [-ledXL-2*sealD-1, -1],
        [-ledXL-sealD+ledY, ledY+sealD],
        [-ledXR+sealD-ledY, ledY+sealD],
        [-ledXR+2*sealD+1, -1],
      ]);
    }

  if (show_panel)
    translate([-sealD, coverDF, coverHF])
      rotate([-switchA, 0, 0])
        translate([0, 0, slop/2+innerFilletIsect])
          switch_panel();
  if (show_cup)
    translate([cupX, cupY, cupZ]) {
      cup_bottom();
      cup_top();
    }
}


module print_cover()
  rotate([0,-90,-90])
    translate([coverW, 0, 0])
      cover(false, false);

module led_strip()
  translate([0, 0, holeZmin]) extrude(sealW) polygon([
    [-ledXL, 0],
    [-ledXL, ledY],
    [-ledXR, ledY],
    [-ledXR, 0],
  ]);

module switch_panel(show_switches=true) {
  switchStartX = -switchMarginR - switchW/2 - slack/2 - guardWall;
  switchStartZ = switchMarginB + switchL/2 + slack/2 + guardWall;
  switchC2C = -switchW - switchSpacing - slack;
  guardH = guardExtra + (switchL/2 + guardWall + slack/2) * tan(abs(guardAngle));
  guardHyp = 2 * (switchL/2 + guardWall + slack/2) / cos(guardAngle);
  color(black) render(convexity=2*switches+1)
    difference() {
      union() {
        // panel and grooves
        translate([0, panelD/2, panelH/2]) {
          difference() {
            box([panelW, panelD, panelH], [-1,0,0]);
            translate([-panelW/2, 0, 0])
              flipZ() translate([0, 0, panelH/2])
                hull() flipX() translate([panelW/2, 0, 0])
                  rotate([90,0,0]) spindle(panelD-2*wall-2*tongue, r=tongue, center=true);
            translate([-panelW, 0, 0])
              hull() flipZ() translate([0, 0, panelH/2])
                rotate([90,0,0]) spindle(panelD-2*wall-2*tongue, r=tongue, center=true);
          }
        }

        // finger guard
        difference() {
          minkowski() {
            difference() {
              for (i = [0 : switches-1]) {
                translate([switchStartX + i*switchC2C, guardFillet-guardH, switchStartZ]) {
                  hull() flipZ() translate([0, 0, (switchL-switchW)/2])
                    rotate([-90,0,0]) cylinder(guardH+1, d=switchW+2*guardWall+slack-2*guardFillet);
                }
              }
              translate([1, guardFillet-guardExtra, switchStartZ])
                rotate([guardAngle, 0, 0])
                  box([panelW+2, switchL+2*guardWall+slack+1, guardHyp], [-1,-1,0]);
            }
            sphere(circumgoncircumradius(guardFillet), $fn=4*round((1/16)*$fn));
          }
          translate([1, wall/2, -1]) box([panelW+2, panelD, panelH+2], [-1,1,1]);
        }
      }

      // switch cutout
      for (i = [0 : switches-1]) {
        translate([switchStartX + i*switchC2C, -guardH-1, switchStartZ]) {
          hull() flipZ() translate([0, 0, (switchL-switchW)/2])
            rotate([-90,0,0]) cylinder(guardH+switchH+slop+1, d=switchW+slack);
          rotate([-90,0,0]) cylinder(guardH+panelD+2, d=threadD+slack);
        }
      }
    }
  if (show_switches) {
    for (i = [0 : switches-1]) {
      translate([switchStartX + i*switchC2C, switchH, switchStartZ]) rotate([90,0,0]) switch();
    }
  }
}

module print_switch_panel()
  translate([0, 0, panelD])
    rotate([-90,0,0])
      switch_panel(false);

module cup_tongue()
  translate([-cupW/2, 0, 0])
    difference() {
      hull() flipZ() translate([0, 0, cupH/2+tongue])
        difference() {
          rotate([90,0,0]) spindle(0, r=tongue, $fn=4);
          box([tongue+1, 2*tongue+1, 2*tongue+1], [1,0,0]);
        }
      box([2*tongue+1, 2*tongue+1, cupH/2+2*tongue+1], [0,0,1]);
    }

module cup_groove()
  translate([0, 0, -cupH/2-groove])
    hull() flipX() translate([cupW/2+max(wireW-sealD,tongue), 0, 0])
      rotate([90,0,0]) spindle(0, r=groove, $fn=4);

module cup_base()
  // color(black) render(convexity=4)
    difference() {
      union() {
        translate([0, cupD/2, 0]) {
          f_chain_cup(filterSize, filterDs, filterWall, filterSealWs, filterSealD, latchW, slack, slop);
          translate([0, 0, filterWall-cupH/2])
            box([cupW, cupD, filterWall+groove], [0,0,-1]);
        }
        translate([0, sealW/2, 0]) cup_tongue();
        translate([0, cupInset-sealW/2, 0]) cup_tongue();
      }
      translate([0, sealW/2, 0]) cup_groove();
      translate([0, cupInset-sealW/2, 0]) cup_groove();
    }

module cup_top() {
  overhang = maxInset-cupInset-(slop/2)*tan(wireA);
  color(black) render(convexity=4)
    union() {
      flipZ(false) cup_base();
      difference() {
        union() {
          rotate([90,0,90]) extrude(cupW, center=true) polygon([
            [ 0,          0],
            [-overhang,   cupH/2+groove],
            [ filterWall, cupH/2+groove],
            [ filterWall, 0],
          ]);
          intersection() {
            multmatrix([[1,0,0,0],[0,1,tan(-wireA),0],[0,0,1,0],[0,0,0,1]])
              scale([1, 1/cos(wireA), 2])
                translate([0, sealW/2, 0]) flipZ(false) cup_tongue();
            translate([0, sealW/2, 0])
              box([cupW/2+groove+1, overhang+sealW/2, cupH/2+groove], [-1,-1,1]);
          }
          translate([cupW/2-filterWall, 0, 0])
            rotate([90,0,90])
              extrude(wireW+filterWall-sealD)
                polygon([
                  [ 0,                         0],
                  [-overhang,                  cupH/2+groove],
                  [-overhang+sealW/cos(wireA), cupH/2+groove],
                  [ sealW,                     sealW*tan(wireA/2)],
                  [ sealW,                     0],
                ]);
        }
        box([filterSize.x-2*filterSealW, 2*(overhang)+1, filterSize.z-2*filterSealW], [0,0,0]);
        translate([0, cupInset-maxInset+(sealW/2)/cos(wireA), 0])
          flipZ(false) cup_groove();
      }
    }
}

module print_cup_top()
  translate([0, 0, cupH/2+groove])
    rotate([180,0,0])
      cup_top();

module cup_bottom()
  color(black) render(convexity=4)
    union() {
      cup_base();
      difference() {
        translate([cupW/2-filterWall, 0, 0])
          box([wireW+filterWall-sealD, sealW, cupH/2+groove], [1,1,-1]);
        translate([0, sealW/2, 0]) cup_groove();
      }
    }

module print_cup_bottom()
  translate([0, 0, cupH/2+groove])
    cup_bottom();


// cup_base();
// cup_top();
// cup_bottom();

difference() {
  // cover($fn=fn, false, false);
  // cover($fn=fn, true, true);
  // translate([0,0,80]) box([coverW+1, coverD+1, 100], [-1,1,1]);
  // translate([-50,0,-1]) box([100, coverD+1, coverHB+2], [1,1,1]);
}
// led_strip();


// print_cover($fn=fn);
// print_switch_panel($fn=fn);
// print_cup_top($fn=fn);
// print_cup_bottom($fn=fn);

index = 1;

f_chain_stats(filterSize, filterDs, filterWall, filterSealWs, filterSealD, filterMargin, materialDs, endZs, braceZs, minPleatGaps, slack, slop);

// f_chain_print_frame_base(filterSize, filterDs, filterWall, filterSealD, filterMargin, materialDs, endZs, latchW, slack, slop);
// f_chain_print_frame_cap(filterSize, filterDs, filterWall, filterSealD, filterMargin, materialDs, endZs, latchW, slack, slop);
// f_chain_print_inner_fold(index, filterSize, filterDs, filterWall, filterSealWs, filterMargin, materialDs, braceZs, minPleatGaps, slack);
// f_chain_print_outer_fold(index, filterSize, filterDs, filterWall, filterSealWs, filterMargin, materialDs, braceZs, minPleatGaps, slack);
// f_chain_print_anchor(index, filterSize, filterDs, filterWall, filterSealWs, filterMargin, materialDs, endZs, slack, slop);
// f_chain_print_riser(index, filterSize, filterDs, filterWall, filterSealWs, filterMargin, materialDs, endZs, braceZs, minPleatGaps, slack);

f_chain_assembly(filterSize, filterDs, filterWall, filterSealWs, filterSealD, filterMargin, materialDs, endZs, braceZs, minPleatGaps, latchW, slack, slop, true, true);

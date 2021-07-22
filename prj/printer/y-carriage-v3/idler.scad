use <nz/nz.scad>;
use <base.scad>;
use <../x-carriage/base.scad>;
use <../belt/gear12.scad>;


show_original = false;
show_base = true;
show_rod_cap = true;

/* [Print] */
print_base = false;
print_rod_cap = false;
print_brush_mount = false;

/* [Components] */
show_rail = true;
show_idler = true;
show_brush_mount = true;

/* [X Carriage] */
show_x_carriage = true;
nest_x_carriage = false;
transparent_x_carriage = true;


/* [Hidden] */

fn = 60;

flipIdler = false;
aluCarriageOffset = 2.5;  // 1.75;  // was 1 for last print, motor pulley was still about 1mm behind idler
iZ = 0;
axleD = 8 + slop();
axleL = 27;
idlerD = 16;
idlerL = 21.5;
idlerY = 13.25 + aluCarriageOffset + (flipIdler ? 5 : 0);

fillet = 2;

blockVariance = 0.5;  // BIBO and MK8 appear to have slightly different block mounting holes

blClearance = 1;
blD = 15.8;
blY = -19.75;                    // -20 for BIBO, -19.5 for standard MK8
blRise = 21.75;
blDrop = 15;
blHeadH = 10.75;
blHeadW = 26 + blockVariance;
blScrewW = 18;
blScrewR = 3;
blScrewH = 2.5;
blBodyW = 13 + blockVariance;

feederClearance = 1;
feederY = -7.25;                 // middle Y - 7.5 for BIBO, 7.0 for standard MK8
feederZ = 44 - feederClearance;  // bottom Z
feederW = 10 + 2*feederClearance + blockVariance;
feederD = 10.5 + feederClearance;
feederH = 7 + 2*feederClearance;


brushBlFudge = 0.25;  // line up brush with BLTouch
nozzleY = -6.75 + brushBlFudge;  // -6.75: -7 for BIBO, -6.5 for standard MK8
nozzleZ = -22;

hotbedX = 87.5;
bedClampX = 84.5;  // 74;  // old clamp
platformX = 84.5;
bedClearance = 1;
reach = min(hotbedX, bedClampX, platformX) - bedClearance;

brushL = 41.25;
brushW = 11.5;
brushD = 8;
bristles = 13;  // between 11.5-14.5

railExtra = 5;

mountW = brushW + 2*fillet;
mountD = brushD + fillet;
railL = -nozzleZ + railExtra + bristles + mountD;
railD = mountW - 2*fillet - slack();


module y_carriage_idler_base(color) {
  color(color) render(convexity=2*clampTeeth()) union() {
    belt_clamp();
    difference() {
      union() {
        y_carriage_base();
        difference() {
          rail();
          translate([0, nozzleY, 1]) box([ycW(), railD+2, railL+railD/2+2], [1,0,-1]);
          // translate([-slop()/4, nozzleY, 1]) box([ycW(), railD+2, railL+railD/2+2], [1,0,-1]);
        }
      }

      idler();
      bltouch();
      // feeder_lever();

      translate([ycW()/2-3, nozzleY, 0])
        rotate([0,90,0])
          m_bolt(3, shank=ycW($fn=fnL()), socket=10, nut=[ycW($fn=fnL())-6, ycW($fn=fnL())], taper=supported()?0:45, $fn=fnS());
    }
  }
}

module y_carriage_idler_rod_cap(color) {
  color(color) render(convexity=6) difference() {
    union() {
      y_carriage_rod_cap();
      difference() {
        rail();
        translate([0, nozzleY, 1]) box([ycW(), railD+2, railL+railD/2+2], [-1,0,-1]);
        // translate([slop()/4, nozzleY, 1]) box([ycW(), railD+2, railL+railD/2+2], [-1,0,-1]);
      }
    }
    idler();
    bltouch();
    // feeder_lever();

    translate([ycW()/2-3, nozzleY, 0])
      rotate([0,90,0])
        m_bolt(3, shank=ycW($fn=fnL()), socket=10, nut=[ycW($fn=fnL())-6, ycW($fn=fnL())], taper=supported()?0:45, $fn=fnS());
  }
}

module rail()
  translate([0, nozzleY, 0]) {
    difference() {
      union() {
        box([ycW(), railD, railL], [0,0,-1]);
        translate([0, 0, -railL])
          rotate([0,90,0]) cylinder(ycW(), d=railD, center=true);
      }
      translate([0, -railD/2, -blDrop-blClearance-mountD/2])
        rotate([90,0,0])
          m_bolt(3, shank=railD+1, height=blDrop+blClearance+railD-railL, $fn=fnS());
      translate([ycW()/2-3, 0, -railL])
        rotate([0,90,0])
          m_bolt(3, shank=ycW($fn=fnL()), socket=10, nut=[ycW($fn=fnL())-6, ycW($fn=fnL())], taper=supported()?0:45, $fn=fnS());
    }
  }

module idler()
  translate([0, idlerY, iZ]) {
    box([ycW()+2, idlerL, idlerD], [0,0,0]);
    translate([-2, 0, 0]) {
      rotate([-90,0,0]) cylinder(axleL, d=axleD, center=true);
      box([ycW()/2-1, axleL, axleD], [-1,0,0]);
    }
  }

module bltouch()
  translate([ycW()/2-blD-blClearance, blY, 0])
    rotate([90,0,90])
      linear_extrude(blD+blClearance+1, convexity=2, slices=0)
        polygon([
          [ blScrewW/2 + blScrewR,    blRise + blScrewH                        + blClearance],
          [ blHeadW/2 + blClearance,  blRise                                   + blClearance/2],
          [ blHeadW/2 + blClearance,  blRise - blHeadH                         - blClearance/2],
          [ blBodyW/2 + blClearance,  blRise - blHeadH - (blHeadW-blBodyW)*2/3 - blClearance],
          [ blBodyW/2 + blClearance, -blDrop                                   - blClearance],
          [-blBodyW/2 - blClearance, -blDrop                                   - blClearance],
          [-blBodyW/2 - blClearance,  blRise - blHeadH - (blHeadW-blBodyW)*2/3 - blClearance],
          [-blHeadW/2 - blClearance,  blRise - blHeadH                         - blClearance/2],
          [-blHeadW/2 - blClearance,  blRise                                   + blClearance/2],
          [-blScrewW/2 - blScrewR,    blRise + blScrewH                        + blClearance],
        ]);

module feeder_lever()
  translate([ycW()/2+fillet, feederY, feederZ+fillet])
    minkowski() {
      box([feederD, feederW-2*fillet, feederH-2*fillet], [-1,0,1]);
      sphere(fillet);
    }

module mount(color)
  color(color) render(convexity=3)
    difference() {
      translate([-ycW()/2-slack()/2, 0, fillet]) minkowski() {
        box([slack()/2+ycW()+reach-fillet, mountW-2*fillet, mountD-2*fillet], [1,0,1]);
        sphere(fillet, $fn=fnS());
      }
      // slot
      translate([ycW()/2+slack()/2+fillet, 0, fillet]) box([reach, mountW-2*fillet, brushD+1], [1,0,1]);
      // rail hole
      translate([0, 0, -1]) box([ycW()+slack(), mountW-2*fillet, mountD+2], [0,0,1]);
      // bolt hole
      translate([0, -mountW/2, mountD/2])
        rotate([90,0,0]) m_bolt(3, shank=mountW+1, $fn=fnS());
    }


module print_y_carriage_idler_base()
  translate([0,0,ycW()/2]) rotate([0,-90,0]) y_carriage_idler_base();

module print_y_carriage_idler_rod_cap()
  translate([0,0,ycW()/2]) rotate([0,90,0]) y_carriage_idler_rod_cap();


if (show_original) color([.25,.25,.25,.5]) translate([-ycW()/2, 0, 24]) rotate([0,90,0])
  import("ref/y-carriage-seconday-lm8uu.stl");

if (show_base)
  y_carriage_idler_base(color=[.5,.5,.5,.75], $fn=fn);

if (show_rod_cap)
  y_carriage_idler_rod_cap(color=[.5,.5,.5,.75], $fn=fn);

if (show_rail)
  y_rail($fn=fn);

if (show_idler) translate([-2, idlerY, iZ]) rotate(flipIdler?-90:90)
  gear12(color=[.75, .75, .75, .75], $fn=fn);

if (show_brush_mount) translate([0, nozzleY, nozzleZ-bristles-mountD])
  mount(color=[.75,.75,.75,.25], $fn=fn);

if (show_x_carriage) translate([nest_x_carriage ? 87/2+ycW()/2 : 100, 0, 0])
  x_carriage(
    color=[.75, .75, .75, transparent_x_carriage ? .25 : 1],
    block=[.75, .75, .75, transparent_x_carriage ? .25 : 1],
    bltouch=[.75, .75, .75, .75],
    feederTabs=[.75, .75, .75, .25]
  );

if (print_base) print_y_carriage_idler_base($fn=fn);
if (print_rod_cap) print_y_carriage_idler_rod_cap($fn=fn);
if (print_brush_mount) mount($fn=fn);

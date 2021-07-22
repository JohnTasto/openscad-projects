use <nz/nz.scad>;
use <../belt/gt2.scad>;
use <../belt/tensioner3.scad>;


show_original = false;
show_new = true;
show_rail = true;
transparent = true;


/* [Hidden] */

fn = 12;

function slop() = 0.3;  // was 0.25 for last print
function slack() = 0.5;

xW = 70;

function xRodD() = 8;
xRodL = 6.25;  // past center of Y rods
xAccessD = 3;
function xRodWall() = 2.5;
function keel() = xRodD()/2 + xRodWall();  // 6.5 below X rod center

yRodD = 8;
function yRodSide() = 22.5;         // frame side wall to Y rod center

teethW = 7.5;                       // gear teeth width
teethD = 14;                        // diameter of belt wrapped around gear
beltSide = 25.25;                   // frame side wall to belt center
beltYRodZ = 6 + yRodD/2;            // 10 from Y rod center to belt back
beltYRodX = beltSide - yRodSide();  // 2.75 from Y rod center to belt center
beltW = teethW + 1;
beltH = 2;
function clampTeeth() = 10;
clampL = 2*clampTeeth() - 1;

lbL = 24 + slack();
lbD = 15;
lbWall = 2;


// should match motor.scad:
mZ = 0;
mD = 42.5;  // width & height

// should match idler.scad:
blClearance = 1;
blRise = 21.75 + blClearance;
blScrewH = 2.5;

// distance between X and Y rod centers (stock is 41)
// drop() = lbD/2 + lbWall + max(mD/2+mZ, blRise+blScrewH) + 2;
function drop() = blRise + blScrewH + lbWall/2 + m_adjusted_socket_head_width(3)/2 + m_adjusted_shank_width(3)/2 + lbWall + yRodD/2;

function ycL() = xW + 2*keel();   // 83
function ycW() = lbD + 2*lbWall;  // 19
function ycH() = drop() + keel() + lbD/2 + lbWall;


// 6.25 between rod and belt

module y_carriage(color) {
  color(color) render(convexity=2*clampTeeth())
    difference() {
      union() {
        flip([0,1,0]) translate([0, ycL()/2, 0])
          box([ycW(), lbL+2*lbWall, drop()], [0,-1,1]);
        box([ycW(), ycL(), drop()-(lbD-yRodD)/2], [0,0,1]);
        box([ycW(), xW, keel()], [0,0,-1]);

        // x rod
        flip([0,1,0]) translate([0, xW/2, 0]) rotate([0,90,0])
          cylinder(ycW(), d=ycL()-xW, center=true);

        // y rod
        flip([0,1,0]) translate([0, ycL()/2, drop()]) rotate([90,0,0])
          cylinder(lbL+2*lbWall, d=ycW());
        translate([0, 0, drop()-(lbD-yRodD)/2]) rotate([90,0,0])
          cylinder(lbL+2*lbWall, d=ycW(), center=true);

        // belt clamps
        flip([0,1,0]) render(convexity=2) translate([0, ycL()/2-lbWall-lbL/2, drop()]) {
          box([beltYRodX-lbWall+beltW/2,   clampL, beltYRodZ+beltH+lbWall], [1,0,1]);
          translate([0, 0, beltYRodZ+beltH+lbWall-ycW()/2]) {
            box([ycW()/2, clampL, beltYRodZ+beltH+lbWall-ycW()/2], [-1,0,-1]);
            difference() {
              rotate([90,0,0]) cylinder(clampL, d=ycW(), center=true);
              box([ycW(), clampL+2, ycW()+2], [1,0,0]);
            }
          }
          stupid = 0.25;  // cannot be <= 0 or everything gets royally f***ed for no f***ing reason
          render(convexity=2) union() translate([beltYRodX-lbWall+beltW/2, 0, beltYRodZ+beltH/2-stupid])
            flip([0,0,1])
              translate([0, 0, beltH/2])
                rotate([90,0,0])
                  cylinder(clampL, r=lbWall+stupid, center=true);
        }
      }

      // x rod             // is this slop() really necessary? it used to be 0.4 btw
      flip([0,1,0]) translate([-xRodL-slop(), xW/2, 0]) rotate([0,90,0])
        cylinder(ycW(), d=circumgoncircumdiameter(d=xRodD())+slop());
      flip([0,1,0]) translate([0, xW/2, 0]) rotate([0,90,0])
        cylinder(ycW()+2, d=xAccessD, center=true);
      flip([0,1,0]) translate([ycW()/2-xRodD()/2-1, xW/2, 0]) rotate([0,90,0])
        cylinder((ycL()-xW)/2, r1=0, r2=(ycL()-xW)/2);

      // y rod
      translate([0, 0, drop()]) rotate([-90,0,0])
        cylinder(ycL()+2, d=yRodD+2, center=true);

      // linear bearing
      flip([0,1,0]) translate([0, lbWall-ycL()/2, drop()]) rotate([-90, 0, 0])
        cylinder(lbL, d=circumgoncircumdiameter(d=lbD)+slop());

      // linear bearing screws
      translate([ycW()/2-3, 0, 0]) {
        flip([0,1,0]) translate([0, ycL()/2-m_adjusted_socket_head_width(3)/2-lbWall/2, drop()-lbD/2-lbWall/2-m_adjusted_shank_width(3)/2])
          rotate([0,90,0]) m_bolt(3, shank=ycW(), socket=10, nut=[ycW()-6, ycW()]);
        flip([0,1,0]) translate([0, ycL()/2-m_adjusted_shank_width(3)/2-lbL-2*lbWall, drop()-yRodD/2-lbWall-m_adjusted_shank_width(3)/2])
          rotate([90,0,90]) m_bolt(3, shank=ycW(), socket=10, nut=[ycW()-6, ycW()]);
      }

      // belt
      flip([0,1,0]) translate([beltYRodX-beltW/2, ycL()/2-lbWall-lbL/2, drop()+beltYRodZ])
        rotate(90) gt2([clampL+3, beltW+1, 1], [0,-1,1], [1, 1]);
    }
}

module y_rail(rod=[.75,.75,.75,.25], belt=[.25,.25,.25,.5]) {
  color(rod) translate([0, 0, drop()]) rotate([-90,0,0]) cylinder(200, r=4, center=true);
  color(belt) translate([beltYRodX, 0, drop()+beltYRodZ]) {
    box([6, 200, 1.375], [0,0,1]);
    translate([0, 0, teethD]) {
      box([6, 200, 1.375], [0,0,-1]);
      flip([0,1,0]) translate([0, 10, 0]) rotate([180,0,90]) tensioner();
    }
  }
}

module rod_block() translate([0, 0, 27.5]) box([ycW()/2+1, ycL()+2, 24], [0,0,1]);  // magic numbers here

//#rod_block();

module y_carriage_base() {
  difference() {
    y_carriage();
    rod_block();
  }
}

module y_carriage_rod_cap() {
  intersection() {
    y_carriage();
    translate([0, 0, 0.3]) rod_block();
  }
}

if (show_original) color([.25,.25,.25,.5]) translate([-ycW()/2, 0, 24]) rotate([0,90,0])
  import("ref/y-carriage-seconday-lm8uu.stl");

if (show_new) color([.5,.5,.5, transparent ? 0.5 : 1])
  y_carriage($fn=fn);

//y_carriage_base($fn=fn);
//y_carriage_rod_cap($fn=fn);

if (show_rail)
  y_rail($fn=fn);

use <nz/nz.scad>;
use <../belt/gt2.scad>;
use <../belt/tensioner3.scad>;


show_original = false;
show_new = true;
show_belt_clamp = true;
show_rail = true;
transparent = true;


/* [Hidden] */

fn = 12;

function fnL() = $fn;
function fnS() = ceil($fn/8)*4;

function slop() = 0.25;  // 0.3;  // 0.25;
function slack() = 0.5;

function supported() = false;

xW = 70;

function xRodD() = 8;
function adjXRodD() = circumgoncircumdiameter(d=xRodD()+slop());
xRodL = 6.25;  // past center of Y rods
xAccessD = 3;  // access hole diameter, useful for verifying X rods are inserted all the way
function xRodWall() = 2.4 + slop()/2;  // + 0.01;
function keel() = adjXRodD()/2 + xRodWall();  // 6.5 below X rod center

function yRodD() = 8;
function adjYRodD() = circumgoncircumdiameter(d=yRodD()+slop());
function yRodClearance() = 0;  // 1;
yRodWall = 1.2;
function yRodSide() = 22.5;         // frame side wall to Y rod center

beltSide = 25.25;                   // frame side wall to belt center
beltYRodX = beltSide - yRodSide();  // 2.75 from Y rod center to belt center
beltYRodZ = 10;                     // Y rod center to belt back

pulleyYRodZ = 9;                    // Y rod center to pulley edge (max height to slide under pulley)
pulleyD = 16;                       // diameter of pulley sides

teethW = 7.5;                       // pulley teeth width
teethD = 14;                        // diameter of belt wrapped around pulley

function clampTeeth() = 10;
clampL = clampTeeth()*2 - 1;
clampW = teethW + 1;
clampH = 2.15;
clampWall = clampH;

// linear bearing
lbL = 17;  // usually 17 or 24
function adjLbL() = lbL + slack();
function lbOWall() = 2.4;
function lbIWall() = 7.6;
lbD = 8;  // 15;
function adjLbD() = circumgoncircumdiameter(d=lbD+slop());
function lbDWall() = pulleyYRodZ - adjLbD()/2;

screwWall = 1.2;

// should match idler.scad:
blClearance = 1;
blRise = 21.75;
blScrewH = 2.5;

// distance between X and Y rod centers (stock is 41)
function drop()
  = blRise
  + blScrewH
  + blClearance
  + screwWall
  + m_adjusted_socket_head_width(3, $fn=fnS())/2
  + screwWall
  + m_adjusted_shank_width(3, $fn=fnS())/2
  + adjYRodD()/2;

function ycL() = xW + keel()*2;   // 83
function ycW() = adjLbD() + lbDWall()*2;  // 18
function ycH() = drop() + keel() + adjLbD()/2 + lbDWall();


module y_carriage(color)
  color(color) render(convexity=clampTeeth()*2)
    difference() {
      union() {
        // x rod
        box([ycW(), xW, keel()], [0,0,-1]);
        flip([0,1,0]) translate([0, xW/2, 0]) rotate([0,90,0])
          cylinder(ycW(), d=keel()*2, center=true);

        // y rod
        flip([0,1,0]) translate([0, ycL()/2, 0])
          box([ycW(), lbOWall()+adjLbL()+lbIWall(), drop()], [0,-1,1]);
        flip([0,1,0]) translate([0, ycL()/2, drop()]) rotate([90,0,0])
          if (supported()) cylinder(lbOWall()+adjLbL()+lbIWall(), d=ycW());
          else extrude(lbOWall()+adjLbL()+lbIWall()) flipX() rotate(90) teardrop_2d(d=ycW(), truncate=ycW()/2);

        // middle
        box([ycW(), ycL(), drop()+adjYRodD()/2+yRodClearance()+yRodWall-ycW()/2], [0,0,1]);
        translate([0, 0, drop()+adjYRodD()/2+yRodClearance()+yRodWall-ycW()/2]) rotate([90,0,0])
          if (supported()) cylinder(ycL(), d=ycW(), center=true);
          else extrude(ycL(), center=true) flipX() rotate(90) teardrop_2d(d=ycW(), truncate=ycW()/2);
      }

      // x rod             // is this slop() really necessary? it used to be 0.8 btw
      flip([0,1,0]) translate([-xRodL-slop()/2, xW/2, 0]) rotate([0,90,0])
        cylinder(ycW(), d=adjXRodD());
      flip([0,1,0]) translate([0, xW/2, 0]) rotate([0,90,0])
        cylinder(ycW($fn=fnL())+2, d=xAccessD, center=true, $fn=fnS());
      flip([0,1,0]) translate([ycW()/2-adjXRodD()/2-1, xW/2, 0]) rotate([0,90,0])
        cylinder((ycL()-xW)/2, r1=0, r2=(ycL()-xW)/2);

      // y rod
      translate([0, 0, drop()]) rotate([-90,0,0])
        cylinder(ycL()+2, d=adjYRodD()+yRodClearance()*2, center=true);

      // linear bearing
      flip([0,1,0]) translate([0, lbOWall()-ycL()/2, drop()]) rotate([-90,0,0])
        cylinder(adjLbL(), d=adjLbD());

      // linear bearing screws
      flip([0,1,0]) translate(
        [ ycW()/2-3
        , ycL()/2 - m_adjusted_socket_head_width(3, $fn=fnS())/2 - screwWall
        , drop() - adjLbD()/2 - screwWall - m_adjusted_shank_width(3, $fn=fnS())/2
        ])
        rotate([0,90,0])
          m_bolt(3, shank=ycW($fn=fnL()), socket=10, nut=[ycW($fn=fnL())-6, ycW($fn=fnL())], taper=supported()?0:45, $fn=fnS());
      flip([0,1,0]) translate(
        [ ycW()/2-3
        , ycL()/2 - m_adjusted_shank_width(3, $fn=fnS())/2 - lbOWall()-adjLbL()-screwWall
        , drop() - adjYRodD()/2 - screwWall - m_adjusted_shank_width(3, $fn=fnS())/2
        ])
        rotate([90,0,90])
          m_bolt(3, shank=ycW($fn=fnL()), socket=10, nut=[ycW($fn=fnL())-6, ycW($fn=fnL())], taper=supported()?0:45, $fn=fnS());

      // extra xRod screw
      translate(
        [ycW()/2-3
        , ycL()/2-screwWall-m_adjusted_socket_head_width(3, $fn=fnS())/2
        , keel()+m_adjusted_socket_head_width(3, $fn=fnS())/2
        ])
        rotate([0,90,0])
          m_bolt(3, shank=ycW($fn=fnL()), socket=10, nut=[ycW($fn=fnL())-6, ycW($fn=fnL())], taper=supported()?0:45, $fn=fnS());
    }

stupid = 0.25;  // cannot be <= 0 or everything gets royally f***ed for no f***ing reason

module belt_clamp_front()
  flip([0,1,0])
    render(convexity=2)
      translate([0, ycL()/2-lbOWall()-adjLbL()-lbIWall(), drop()+beltYRodZ+clampH/2-stupid]) {
        box([beltYRodX-clampWall+clampW/2, clampL, clampH+clampWall*2+stupid*2], [1,1,0]);
        translate([beltYRodX-clampWall+clampW/2, 0, 0])
          flip([0,0,1])
            translate([0, 0, clampH/2])
              rotate([-90,0,0])
                cylinder(clampL, r=clampWall+stupid, $fn=fnS());
      }

module belt_clamp_back()
  flip([0,1,0])
    render(convexity=2)
      translate([0, ycL()/2-lbOWall()-adjLbL()-lbIWall(), drop()+beltYRodZ+clampH+clampWall-ycW()/2]) {
        box([ycW()/2, clampL, beltYRodZ+clampH+clampWall-ycW()/2], [-1,1,-1]);
        difference() {
          rotate([-90,0,0])
            if (supported()) cylinder(clampL, d=ycW());
            else extrude(clampL) rotate(90) teardrop_2d(d=ycW(), truncate=ycW()/2);
          translate([1, -1, 0]) box([ycW(), clampL+2, ycW()+2], [1,1,0]);
          translate([0, -1, -1]) box([ycW()+2, clampL+2, ycW()], [0,1,-1]);
        }
      }

module belt_clamp_blank()
  render(convexity=3)
    difference() {
      union() {
        belt_clamp_front();
        belt_clamp_back();
      }
      flip([0,1,0])
        translate([0, ycL()/2-lbOWall()-adjLbL(), drop()]) rotate([-90, 0, 0])
          cylinder(adjLbL(), d=adjLbD());
      translate([0, 0, drop()]) rotate([-90, 0, 0])
        cylinder(ycL(), d=adjYRodD()+yRodClearance()*2, center=true);
      translate([-slop()/2, 0, drop()])
        box([ycW(), ycL()+2, beltYRodZ*2-clampWall*2-stupid*4], [1,0,0]);
    }

module belt_clamp_teeth()
  flip([0,1,0])
    translate([beltYRodX-clampW/2, ycL()/2-lbOWall()-adjLbL()-lbIWall()-1.5, drop()+beltYRodZ])
      rotate(90)
        gt2([clampL+3, clampW+1, 0.9], [1,-1,1], [1, 1], $fn=fnS());

module belt_clamp()
  render(convexity=clampTeeth()*2)
    difference() {
      belt_clamp_blank();
      belt_clamp_teeth();
    }

module rod_block()
  translate([0, 0, -keel()-1])
    box([ycW()/2+1, ycL()+2, ycH()+2], [1,0,1]);

// #rod_block($fn=fn);

module y_carriage_base()
  render(convexity=6)
    difference() {
      y_carriage();
      rod_block();
      // translate([-slop()/4, 0, 0]) rod_block();
    }

module y_carriage_rod_cap()
  render(convexity=6)
  difference() {
    intersection() {
      y_carriage();
      rod_block();
      // translate([slop()/4, 0, 0]) rod_block();
    }
    minkowski() {
      belt_clamp_front();
      cube(slop(), center=true);
    }
  }

module y_rail(rod=[.75,.75,.75,.25], belt=[.25,.25,.25,.5]) {
  color(rod) translate([0, 0, drop()]) rotate([-90,0,0]) cylinder(200, d=yRodD(), center=true);
  color(belt) translate([beltYRodX, 0, drop()+beltYRodZ]) {
    box([6, 200, 1.375], [0,0,1]);
    translate([0, 0, teethD]) {
      box([6, 200, 1.375], [0,0,-1]);
      flip([0,1,0]) translate([0, 10, 0]) rotate([180,0,90]) tensioner();
    }
  }
}

if (show_original) color([.25,.25,.25,.5]) translate([-ycW()/2, 0, 24]) rotate([0,90,0])
  import("ref/y-carriage-seconday-lm8uu.stl");

if (show_new) color([.5,.5,.5, transparent ? 0.5 : 1])
  y_carriage($fn=fn);

if (show_belt_clamp) color([.5,.5,.5, transparent ? 0.5 : 1])
  belt_clamp($fn=fn);

// belt_clamp_front($fn=fn);
// belt_clamp_back($fn=fn);
// belt_clamp_blank($fn=fn);
// belt_clamp_teeth($fn=fn);
// belt_clamp($fn=fn);
// y_carriage_base($fn=fn);
// y_carriage_rod_cap($fn=fn);

if (show_rail)
  y_rail($fn=fn);

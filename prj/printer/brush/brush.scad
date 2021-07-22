use <nz/nz.scad>;

$fn = 60;


slop = 0.3;
slack = 0.5;

xW = 70;         // from X/Y carriage
xRodD = 8;
xRodWall = 2.5;  // from Y carriage

wall = xRodWall;

snap = 1;
hook = 19;       // clearance of BLTouch mount
hookStem = 5;
hookExtra = hookStem - xRodWall;

supportW = 19;   // depth of Y carriage
supportZ = -xRodD/2 - xRodWall;
supportD = 5.7;

nozzleY = -7.5;  // 27.5 from the front, 42.5 from the back
nozzleZ = -22;
// BLTouch will be roughly 5mm from rod and 13.5mm wide, so
// 27.5 - 13.5 - 5  =  9mm clearance to nozzle, mount should be <18mm wide

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

mountW = brushW + 2*wall;
mountD = brushD + wall;
railL = supportZ - nozzleZ + railExtra + bristles + mountD;
railD = mountW - 2*wall - slack;

module hanger() {
  difference() {
    union() {
      // hooks
      flip([0,1,0]) {
        translate([0, xW/2, 0]) {
          difference() {
            union() {
              rotate([0,90,0]) cylinder(hook, d=xRodD+2*xRodWall);
              translate([0, -hookExtra, 0]) rotate([0,90,0]) cylinder(hook, d=xRodD+2*xRodWall);
              box([hook, hookExtra, xRodD+2*xRodWall], [1,-1,0]);
            }
            translate([-1,0,0]) rotate([0,90,0]) cylinder(hook+2, d=xRodD);
            translate([-1,-snap/2,0]) box([hook+2, xRodD-snap, xRodD/2+xRodWall+1], [1,0,-1]);
          }
          translate([0, -xRodD/2, 0]) {
            box([hook, hookStem, supportD-supportZ-hookStem/2], [1, -1, -1]);
            translate([-supportW, -hookStem/2, supportZ-supportD+hookStem/2])
              rotate([0,90,0]) cylinder(supportW+hook, d=hookStem);
          }
        }
      }

      // support
      translate([0, 0, supportZ]) {
        box([supportW, xW-xRodD-hookStem, supportD], [-1,0,-1]);
        box([supportW, xW-xRodD, supportD-hookStem/2], [-1,0,-1]);
      }

      // rail
      translate([0, nozzleY, supportZ]) {
        difference() {
          union() {
            box([supportW, railD, railL], [-1,0,-1]);
            box([supportW, railD-2*wall, railL+wall], [-1,0,-1]);
            flip([0,1,0]) translate([0, railD/2-wall, -railL]) rotate([0,-90,0]) cylinder(supportW, r=wall);
          }
          translate([-supportW/2, -railD/2, -supportD-mountD/2])
            rotate([90,0,0]) m_bolt(3, shank=railD+1, height=supportD+railD-railL);
        }
      }
    }
    flip([0,1,0]) translate([-supportW, xW/2-xRodD/2-supportD/2, supportZ-supportD/2])
      rotate([0,-90,0]) m_bolt(3, depth=supportW+hook-1, shank=supportW);
  }
}

module mount() {
  difference() {
    translate([-slack/2-supportW, 0, wall]) minkowski() {
      box([slack/2+supportW+reach-wall, mountW-2*wall, mountD-2*wall], [1,0,1]);
      sphere(wall);
    }
    // slot
    translate([slack/2+wall, 0, wall]) box([reach, mountW-2*wall, brushD+1], [1,0,1]);
    // rail hole
    translate([-slack/2-supportW, 0, -1]) box([supportW+slack, mountW-2*wall, mountD+2], [1,0,1]);
    // bolt hole
    translate([-supportW/2, -mountW/2, mountD/2])
      rotate([90,0,0]) m_bolt(3, shank=mountW+1);
  }
}

// hanger();
// translate([0, nozzleY, nozzleZ-bristles-mountD]) mount();

// translate([0, 0, supportW]) rotate([0,-90,0]) hanger();
mount();

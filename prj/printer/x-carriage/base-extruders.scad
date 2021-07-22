use <nz/nz.scad>;
use <block.scad>;

$fs = 1;

w = 85;
d = 90;
h = 17;
back = d/2;
front = -back;

lbR = 7.5;
lbL = 24;
lbWall = 2.5;
lbBlock = 2*lbR + 2*lbWall;

m3_shank = 3.5;
m3_thread = 2.5;


module mellow_bmg_aero()
  translate([-24.95, -14,0]) rotate([90,0,90])
    import("ref/mellow-bmg-aero/files/Mellow_BMG_Aero_v9.stl");

module bmg_aero()
  translate([-65.55, 142.125, -133.1608])
    import("ref/bmg-aero/files/BMG_Aero_Direct_Extruder.stl");

module e3d_hemera()
  translate([-17.4945, 52.0005, -20.0181]) rotate([90,0,0])
    import("ref/e3d-hemera/files/HEMERA-MODEL-1.1.STL");

module hemera_v6()
  translate([0,0,0]) rotate([0,0,0])
    import("ref/hemera-hotend/files/E3D_Hemera_Final.stl");

module hemera_volcano()
  translate([0,0,0]) rotate([0,0,0])
    import("ref/hemera-hotend/files/E3D_Hemera_Volcano_Final.stl");

// mellow_bmg_aero();
// bmg_aero();
// e3d_hemera();
// hemera_v6();
// hemera_volcano();

flipX() translate([23.425, 4.2, 10]) hemera_v6();
color([0.5,0.5,0.5,0.25]) translate([0,-7,-10]) box([33,1,1], [0,0,0]);

module x_carriage(color, block=false, bltouch=false, feederTabs=false) {
  translate([0, 0, lbWall+lbR]) {
    if (block) translate([0, front+31.5+17/2-0.5, -3]) block(color=block, bltouch=bltouch, feederTabs=feederTabs);
    color(color) render(convexity=5)
      difference() {
        box([w, d, h], [0,0,-1]);

        // linear bearings
        flip([0,1,0]) translate([0, front+lbWall+lbR, -lbWall-lbR]) rotate([0,90,0]) cylinder(w+2, r=lbR, center=true);
        flip([1,0,0]) flip([0,1,0]) {
          translate([w/2- 4.5, back+1, -lbWall-lbR]) rotate([90,0,0]) cylinder(lbWall+2, d=m3_thread);
          translate([w/2-20.5, back+1, -lbWall-lbR]) rotate([90,0,0]) cylinder(lbWall+2, d=m3_thread);
        }

        // undercut
        translate([0,0,-9]) box([w+2, d-2*lbBlock, h], [0,0,-1]);

        // main hole
        translate([0, front+lbBlock, 1]) box([63, 38, h], [0,1,-1]);

        // aluminum block
        translate([0, front+31.5, -3]) box([w+2, 17, h], [0,1,1]);
        flip() translate([37, front+31.5+17/2, 0]) cylinder(h, d=m3_shank, center=true);
        flip() hull() {
          translate([37, front+21.5+3.5, -5-h]) cylinder(h, r=3.5);
          translate([37, back-33.5-3.5, -5-h]) cylinder(h, r=3.5);
        }

        // top insets
        translate([0, front+lbBlock, -3]) box([w-3, 11.5+1, h], [0,1,1]);
        translate([0, back-24, -1]) box([w-12, 17.5+1, h], [0,-1,1]);

        // belt
        translate([0, back-24, -3.9]) box([w+2, 7, 1.9], [0,-1,-1]);
        translate([0, back-24, -3.9]) box([53, 7, h], [0,-1,-1]);
        translate([0, back-22, -5.8]) box([53, 10+1, h], [0,-1,-1]);
        flip() translate([77/2, back-24-7/2, -5.8+1-h]) cylinder(h, d=m3_thread);
        flip() translate([61/2, back-24-7/2, -5.8+1-h]) cylinder(h, d=m3_thread);
      }
  }
}

x_carriage(block=false, bltouch=true);

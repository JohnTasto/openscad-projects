use <nz/nz.scad>;

$fn = 24;

slop = 0.2;
width = 30;
margin = 3;
fillet = 2;

boltXY = 2.5;

bedZ = 1.6;
bedOL = margin + 2*boltXY;

glassX = 0.25;
glassY = 8.75;
glassZ = 3.0;
glassOL = 5;

height = margin*2 + bedZ + glassZ + slop;

difference() {
  rotate([-90,0,0])
    difference() {
      union() {
        // back
        translate([fillet, 0, fillet]) minkowski() {
          box([width-2*fillet, margin+bedOL-fillet, height-2*fillet], [1,-1,1]);
          sphere(fillet);
        }
        // top
        translate([fillet, 0, height-fillet]) minkowski() {
          box([width-2*fillet, margin+glassY+glassOL-fillet, margin+glassZ+bedZ+slop-2*fillet], [1,-1,-1]);
          sphere(fillet);
        }
        // side
        translate([fillet, 0, height-fillet]) minkowski() {
          box([margin+bedOL+2*slop-2*fillet, margin+glassY+glassOL-fillet, height-2*fillet], [1,-1,-1]);
          sphere(fillet);
        }
        // nut
        translate([fillet, 0, height-fillet]) minkowski() {
          box([2*margin+2*boltXY-2*fillet+2*slop, 2*margin+2*boltXY-fillet, height+3-2*fillet], [1,-1,-1]);
          sphere(fillet);
        }
      }
      // bed
      translate([margin, -margin, margin]) box([width, bedOL+glassOL+1, bedZ+slop], [1,-1,1]);
      // glass
      translate([margin+glassX, -margin-glassY, margin]) box([width, glassOL+1, glassZ+bedZ+slop], [1,-1,1]);
      // bolt
      translate([margin+boltXY+slop, -margin-boltXY, height-margin])
        rotate(90) m_bolt(3, shank=height, button=margin, nut=[height-margin, height+1]);
    }
  translate([-1, -1-3, 0]) box([width+2, height+3+2, fillet+1], [1,1,-1]);
}

use <nz/nz.scad>;
use <gt2.scad>;


fn = 12;

lineW = 0.4;
fillet = 1.5;

zipW = 4;
zipH = 2;

boltSize = 2;
nutW = m_nut_width(boltSize);
shankW = m_adjusted_shank_width(boltSize);

beltH = 0.9;
beltW = 7;
beltTeethH = 1.0;
beltTeeth = 6;
length = 2*beltTeeth - 1;

boltX = beltH + beltTeethH + lineW + nutW;
outerD = boltX + nutW + 2*fillet;
innerD = boltX + shankW + 2*lineW;


module tensioner() {
  render(convexity=6)
    translate([0, 0, boltX/2-nutW/2-lineW])
      rotate([90,90,0])
        difference() {
          union() {
            flip([0,1,0]) translate([0, zipW/2+fillet, 0])
              minkowski() {
                rotate([-90,0,0]) cylinder(length/2-2*fillet-zipW/2, d=outerD-2*fillet, $fn=6);
                sphere(circumgoncircumradius(fillet));
              }
            difference() {
              rotate([90,180,0]) extrude(zipW+2*fillet, center=true) teardrop(d=innerD);
              translate([0, 0, -ingonindiameter(d=(outerD-2*fillet), segments=6)/2-fillet])
                box([outerD+2, length+2, 1000], [0,0,-1]);
            }
          }
          flip() flip([0,1,0]) translate([boltX/2, length/2, 0])
            rotate([-90,0,0]) m_bolt(2, shank=length, nut=[0, 2]);
          translate([boltX/2-nutW/2-lineW, 0, -beltW/2])
            rotate([-90,0,90]) gt2([length+4, outerD, beltH], [0,-1,1], [1, beltTeethH]);
        }
}

translate([0, lineW-boltX/2+nutW/2, ingonindiameter(d=(outerD-2*fillet), segments=6)/2+fillet])
  rotate([-90,0,0])
    tensioner($fn=fn);

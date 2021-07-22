use <nz/nz.scad>;
use <gt2.scad>;

fn = 60;


zipW = 4;
outerD = 9.5;
innerD = 7;
beltW = 6.5;
beltTeeth = 6;
beltOffset = 0.375;
fillet = 1;
length = 2*beltTeeth - 1;


module belt_end(sides) {
  render(convexity=beltTeeth) difference() {
    minkowski() {
      render(convexity=2) union() {
        rotate([90,-90,90]) cylinder(length-2*fillet, d=innerD-2*fillet, center=true);
        flip() translate([zipW/2+fillet, 0, 0])
          rotate([90,sides?90-180/sides:-90,90]) cylinder(length/2-zipW/2-2*fillet, d=outerD-2*fillet, $fn=sides?sides:$fn);
        if(sides) difference() {
          intersection() {
            translate([0, (innerD/2-fillet)*sin(-360/sides), (fillet-innerD/2)*cos(-360/sides)])
              rotate([-360/sides,0,0]) box([length-2*fillet, outerD, innerD-2*fillet], [0,1,1]);
            translate([0, (fillet-innerD/2)*sin(-360/sides), (fillet-innerD/2)*cos(-360/sides)])
              rotate([360/sides,0,0]) box([length-2*fillet, outerD, innerD-2*fillet], [0,-1,1]);
          }
          translate([0, 0, -ingoninradius(d=outerD-2*fillet, sides=sides)]) box([2*outerD, 2*outerD, outerD], [0,0,-1]);
        }
      }
      sphere(fillet);
    }
    translate([0, beltOffset, -beltW/2]) rotate([-90,0,0]) gt2([length+4, outerD, 0.9], [0,-1,0], [1, 1]);
  }
}

belt_end(sides=6, $fn=fn);

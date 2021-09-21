use <nz/nz.scad>


$fn = 60;

fudge = 0.01;
fudge2 = 0.02;

h = 74;
r = 7.75;

domeH = r;
fillet = 1.5;

thumbH = 16;
thumbR1 = 5;
thumbR2 = 14;
thumbD = 1.5;
thumbA = -12;

flutings = 4;
flutingR = r;
flutingD = 1.125;
flutingTop = h;
flutingBot = thumbH;

difference() {
  rotate_extrude(convexity=2)
    difference() {
      minkowski() {
        offset(-fillet)
          difference() {
            union() {
              rect([r*2, h-domeH], [0,1]);
              translate([0, h-domeH]) scale([r, domeH]) circle();
            }
            translate([r+thumbR1-thumbD, thumbH]) rotate(thumbA) scale([thumbR1, thumbR2]) circle();
          }
        rotate(180) teardrop(fillet, truncate=fillet, $fn=$fn/2);
      }
      translate([0, -fudge]) rect([-r-fudge, h+fudge2]);
    }
  ring(90, n=flutings) translate([r+flutingR-flutingD, 0, flutingBot]) tull([0, 0, flutingTop-flutingBot]) revolve() teardrop(flutingR);
}

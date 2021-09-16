use <nz/nz.scad>;

fn = 12;

show_original = false;
show_new = true;
show_rail = true;

xW = 70;
drop = 41;

xRodD = 8;
xRodL = 6.25;  // past center of Y rods
xAccessD = 3;
xRodWall = 2.5;

yRodD = 8;
lbL = 24;
lbD = 15;
lbWall = 2;

l = xW + xRodD + 2*xRodWall;  // 83
w = lbD + 2*lbWall;           // 19

beltW = 10;
beltH = 1.375;
beltCapL = 30;


if (show_original) {
  color([.25,.25,.25,.5])
    translate([0, 0, 24]) rotate([0,90,0]) import("ref/y-carriage-seconday-lm8uu.stl");
}

// 6.25 between rod and belt

module y_carriage() {
  render(convexity=1) difference() {
    union() {
      box([w, l, drop], [1,0, 1]);
      box([w, xW, (l-xW)/2], [1,0,-1]);

      // x rod
      flip([0,1,0]) translate([0, xW/2, 0]) rotate([0,90,0]) cylinder(w, d=l-xW);

      // y rod
      translate([w/2, 0, drop]) rotate([-90,0,0]) cylinder(l, d=w, center=true);

      // belt cap
      translate([0          , 0, drop]) box([w,     beltCapL, w/2+beltH+.2],             [1,0,1]);
      translate([(w-beltW)/2, 0, drop]) box([beltW, beltCapL, w/2+beltH+(w-beltW)/2+.2], [1,0,1]);  // height 56.575
      translate([(w-beltW)/2, 0, drop+w/2+beltH+.2]) rotate([-90,0,0]) cylinder(beltCapL, d=w-beltW, center=true);
      translate([(w+beltW)/2, 0, drop+w/2+beltH+.2]) rotate([-90,0,0]) cylinder(beltCapL, d=w-beltW, center=true);
    }

    // x rod
    flip([0,1,0]) translate([w/2-xRodL-0.4, xW/2, 0]) rotate([0,90,0]) cylinder(w, d=circumgoncircumdiameter(d=xRodD+0.25));
    flip([0,1,0]) translate([-1, xW/2, 0]) rotate([0,90,0]) cylinder(w+2, d=xAccessD);
    flip([0,1,0]) translate([w-xRodD/2-1, xW/2, 0]) rotate([0,90,0]) cylinder((l-xW)/2, r1=0, r2=(l-xW)/2);

    // y rod
    translate([w/2, -l/2-2, drop]) rotate([-90,0,0]) cylinder(l+2, d=yRodD+2);

    // linear bearing
    flip([0,1,0]) translate([w/2, lbWall-l/2, drop]) rotate([-90, 0, 0]) cylinder(lbL+0.5, d=circumgoncircumdiameter(d=lbD+0.25));

    // linear bearing bolts
    // still lots of magic numbers here
    flip([0,1,0]) translate([1.5, beltCapL/2-m_socket_head_width(3)/2-1.95, drop+w/2-m_socket_head_width(3)/2-0.175])
      rotate([0,-90,0]) m_bolt(3, depth=16.4, shank=8, socket=10);
    flip([0,1,0]) translate([1.5, xW/2, 31])
      rotate([0,-90,0]) m_bolt(3, depth=16.4, shank=8, socket=10);

    // belt
    translate([(w-beltW)/2, 0, drop+w/2]) box([beltW, l+2, .5], [1,0,1]);
    translate([(w-beltW)/2, 0, drop+w/2+.2]) scale([beltW/6, 1, 1]) flip([0,1,0]) {
      gt2();
      translate([0,20,0]) gt2();
    }

    // belt cap bolts
    translate([  3, 0, drop+w/2+beltH+2+.2]) m_bolt(3, depth=22, shank=3.375, socket=10);
    translate([w-3, 0, drop+w/2+beltH+2+.2]) m_bolt(3, depth=22, shank=3.375, socket=10);
  }
}

module belt_block() translate([-1, 0, drop+w/2]) box([w+2, beltCapL, (w-beltW)/2+beltH+0.2], [1,0,1]);
module rod_block() translate([w/2, 0, 27.5]) box([w/2+1, l+2, 24], [1,0,1]);  // magic numbers here

//#belt_block();
//#rod_block();

module y_carriage_base() {
  difference() {
    y_carriage();
    belt_block();
    rod_block();
  }
}

module y_carriage_belt_cap() {
  intersection() {
    y_carriage();
    translate([0, 0, 0.0001]) belt_block();
  }
}

module y_carriage_rod_cap() {
  intersection() {
    difference() {
      y_carriage();
      belt_block();
    }
    translate([0, 0, 0.3]) rod_block();
  }
}

module gt2() {
  translate([6, 1, .825]) rotate([-90,0,90]) import("ref/gt2-belt-body.stl");
}

if (show_new) color([.5,.5,.5,1]) y_carriage($fn=fn);
//y_carriage_base($fn=fn);
//y_carriage_rod_cap($fn=fn);
//y_carriage_belt_cap($fn=fn);

module y_rail() {
  translate([w/2, 0, 41]) rotate([-90,0,0]) cylinder(200, r=4, center=true);
}

if (show_rail) color([.75,.75,.75,.25]) y_rail($fn=fn);

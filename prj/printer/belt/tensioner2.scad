use <nz/nz.scad>;
use <gt2.scad>;

$fn = 36;


// crossbar should be thicker to hold nylon nuts better

module tensioner_blank() {
  render(convexity=3)
    difference() {
        union() {
          box([8.1, 13.75, 8], [0,1,0]);
          box([23.3, 4, 8], [0,-1,0]);
        }
      translate([0, 3.25, 0]) rotate([0,0,90]) gt2_old([16, 6.5, 0], [1,0,1], offset=1.75, flip=true);
      // translate([0, 3.25, 0]) rotate([0,180,270]) gt2([16, 6.5, 0.73], [1,0,1]);
      // m3x6 is a little short still? (engages, but not completely)
      translate([0, 0.8, 2]) rotate([0,0,90]) m_bolt(3, shank=6.1, nut=[4, 6.1], socket=2.1);
      children();
    }
}

module tensioner_clamp() {
  render()
  intersection() {
    tensioner_blank();
    translate([0, -2.9, 0.2]) box([8.1, 24, 6], [0,1,1]);
  }
}

module tensioner_base() {
  render(convexity=4)
  difference() {
    tensioner_blank();
    translate([0, -3.2, 0]) box([8.5, 24, 6], [0,1,1]);
  }
}

module tensioner() {
  tensioner_base();
  tensioner_clamp();
}

module tensioner_base_nut() {
  difference() {
    tensioner_base();
    flip() translate([7.95, -2, 0]) rotate([-90,90,0]) m_bolt(3, shank=5.1, nut=[-2.1, 0]);
  }
}

module tensioner_base_cap() {
  difference() {
    tensioner_base();
    flip() translate([7.95, -2, 0]) rotate([-90,0,0]) m_bolt(3, shank=5.1, socket=2.01);
  }
}

module tensioner_print_layout() {
  translate([0, 10, 4]) tensioner_base_nut();
  translate([0, -10, 4]) rotate([0,0,180]) tensioner_base_cap();

  flip([0,1,0]) translate([25, 10, -.2]) tensioner_clamp();
}


// tensioner_blank();
// tensioner_base();
// tensioner_clamp();
tensioner_print_layout();

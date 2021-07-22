use <nz/nz.scad>;
use <gt2.scad>;

$fn = 36;


// crossbar should be thicker to hold nylon nuts better
module tensioner_blank() {
  render(convexity=3)
    difference() {
      box([8.1, 16, 8], [0,1,0]);
      translate([0, 5.5, 0]) rotate([0,0,90]) gt2([16, 6.5, 0], [1,0,1], offset=1.75, flip=true);
      translate([0, 4.05, 2]) rotate([0,0,90]) m_bolt(3, shank=6.1, nut=[4, 6.1], socket=2.1);
    }
}

module tensioner_clamp() {
  render()
    intersection() {
      tensioner_blank();
      union() {
        translate([0, -1, 0.2]) box([8.1+2, 8.1+1, 6], [0,1,1]);
        translate([0, -1, 0.2]) box([5.9, 24, 6], [0,1,1]);
      }
    }
}

module tensioner_base() {
  render(convexity=4)
    difference() {
      tensioner_blank();
      translate([0, -1, 0]) box([8.1+2, 8.4+1, 6], [0,1,1]);
      translate([0, -1, 0]) box([6.5, 24, 6], [0,1,1]);
    }
}

module tensioner() {
  tensioner_base();
  tensioner_clamp();
}

module tensioner_print_layout() {
  translate([-6, 0, -.2]) tensioner_clamp();
  translate([6, 0, 4]) tensioner_base();
}


//translate([-10,0,0]) tensioner_clamp();
//tensioner_blank();
//translate([10,0,0]) tensioner_base();
//translate([20,0,0]) tensioner();
tensioner_print_layout();

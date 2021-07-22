use <nz/nz.scad>;

$fn = 36;


module octahedron() {
  // octahedron based on code by Willliam A Adams
  octapoints =
	  [ [+1, 0, 0], [-1, 0, 0]
	  , [0, +1, 0], [0, -1, 0]
	  , [0, 0, +1], [0, 0, -1]
    ];
  octafaces =
    [ [4,2,0], [4,0,3], [4,3,1], [4,1,2]
    , [5,0,2], [5,3,0], [5,1,3], [5,2,1]
    ];
  polyhedron(points=octapoints,faces=octafaces);
}

module gt2() {
  translate([6, 1, .825]) rotate([-90,0,90]) import("ref/gt2-belt-body.stl");
}

module tensioner_blank() {
  render(convexity=3)
    difference() {
      minkowski() {
        union() {
          translate([0,8,0]) cube([8.5, 18, 6], center=true);
          translate([0,-2.5,0]) cube([26, 5, 6], center=true);
        }
        octahedron();
      }
      scale([6.5/6,1,1]) translate([-3, 5.625, -.625]) gt2();
      scale([6.5/6,1,1]) translate([-3, 5.625, -.88]) gt2();
      translate([0, 2.625, -.0625]) difference() {
        union() {
          translate([0, 1, 0]) cube([6.5, 2, 9], center=true);
          translate([0, 3, 0]) cube([6.5, 2, 5.575], center=true);
        }
        flip([0,0,1]) translate([0, 4, 2.8175]) rotate([0,90,0]) cylinder(7, d=4, center=true);
      }
      translate([0, -1, 2]) m_bolt(3, shank=6.1, nut=[4, 6.1], socket=2.1);
      children();
    }
}

module tensioner_clamp() {
  render()
  intersection() {
    tensioner_blank();
    union() {
      translate([0,13.25,3.1]) cube([10.5, 24, 6], center=true);
      translate([0,8,3.1]) cube([10, 24, 6], center=true);
    }
  }
}

module tensioner_base() {
  render(convexity=4)
  difference() {
    tensioner_blank();
    translate([0, 7.75, 2.9]) cube([10.5, 24, 6], center=true);
  }
}

module tensioner() {
  tensioner_base();
  tensioner_clamp();
}

module tensioner_base_nut() {
  difference() {
    tensioner_base();
    flip() translate([9.75, -1, 0]) rotate([-90,0,0]) m_bolt(3, shank=5.1, nut=[-2.1, 0]);
  }
}

module tensioner_base_cap() {
  difference() {
    tensioner_base();
    flip() translate([9.75, -1, 0]) rotate([-90,0,0]) m_bolt(3, shank=5.1, socket=2.01);
  }
}

module tensioner_print_layout() {
  translate([0, 10, 4]) tensioner_base_nut();
  translate([0, -10, 4]) rotate([0,0,180]) tensioner_base_cap();

  flip([0,1,0]) translate([25, 10, -.1]) tensioner_clamp();
}

// tensioner_blank();
// tensioner_base();
// tensioner_clamp();
tensioner_print_layout();

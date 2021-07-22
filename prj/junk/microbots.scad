$fn = 128;

module flip(v=[1, 0, 0], copy=true) {
    if (copy) children();
    mirror(v) children();
}

module gm23() {
  rotate([180,0,0])
    union() {
      translate([-6, -4.9, 0])
        cube([12, 19, 11]);
      translate([0, 19 - 4.9 - 7.5/2, 0])
        cylinder(d=7.5, h=24);
      gmShaft();
    }
}

module gm24() {
  rotate([180,0,0])
    union() {
      translate([-6, -5.2, 0])
        cube([12, 16.5, 11.3]);
      translate([0, -5.2, 11.3 - 7.6/2])
        rotate([-90, 0, 0])
          cylinder(d=7.6, h=30.4);
      gmShaft();
    }
}

module gmShaft() {
  cylinder(d=5, h=1, center=true);
  intersection() {
    cylinder(d=3.1, h=6.4, center=true);
    cube([4, 2.4, 8], center=true);
  }
}

translate([-24, 0, 0]) {
  translate([-12, 0, 0]) rotate([0, 90, 180]) gm23();
  translate([12, 0, 0]) rotate([0, 90, 0]) gm23();
}

translate([24, 0, 0]) {
  flip(v=[0, 1, 0]) {
    translate([-12, 30.4 - 5.2, 0]) rotate([0, -90, 0]) gm24();
    translate([12, 30.4 - 5.2, 0]) rotate([0, 90, 0]) gm24();
  }
}

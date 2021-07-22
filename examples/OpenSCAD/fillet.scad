// Similar to example here:
//   https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Tips_and_Tricks#Filleting_objects

render()
  difference() {
    offset_3d(2) offset_3d(-2)    // exterior fillets
      offset_3d(-4) offset_3d(4)  // interior fillets
        basic_model();
    // hole without fillet
    translate([0,0,10])
      cylinder(r=18, h=50);
  }

module basic_model() {
  cylinder(r=25, h=55);
  cube([80,80,10], center=true);
}

module offset_3d(r=1, size=1e3) {
  n = $fn == undef ? 12 : $fn;
  if (r == 0) children();
  else
    if (r > 0)
      minkowski() {
        children();
        sphere(r, $fn=n);
      }
    else {
      difference() {
        cube(size*[1,1,1], center=true);
        minkowski() {
          difference() {
            cube(size*[1,1,1], center=true);
            children();
          }
          sphere(-r, $fn=n);
        }
      }
    }
}

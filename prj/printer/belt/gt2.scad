use <nz/nz.scad>;

fn = 24;


module gt2_old(size=[10,6,0], align=[1,1,1], offset=0, flip=false) {
  scale([1, size.y, flip ? -1 : 1])
    translate([(sign(align.x)/2-0.5)*size.x, (sign(align.y)/2-0.5), align.z>0 ? size.z : align.z<0 ? -1.38 : -0.63])
      union() {
        box([size.x, 1, size.z], [1,1,-1]);
        render(convexity=10)
          difference() {
            for (i = [0 : 20 : size.x + ceil(mod(offset, 2)) - 1]) {
              translate([i-mod(offset, 2), 0, 0])
                scale([1, 1/6, 1])
                  translate([1, 0, .825])
                    rotate([-90,0,0])
                      import("ref/gt2-belt-body.stl");
            }
            translate([-21, -1, -1]) cube([21, 3, 4]);
            translate([size.x, -1, -1]) cube([21, 3, 4]);
          }
      }
}

translate([0, 6, 0]) gt2_old([10, 6, 0.1], [1,0,0]);
// gt2([10, 6.5, 0.1], [1,0,0], flip=true);


module gt2(size=[10,6,0.73], align=[1,1,1], tooth=[1.125, 0.75]) {
  length = 2*floor(size.x/2);
  translate([(sign(align.x)/2-0.5)*length, (sign(align.y)/2-0.5)*size.y+size.y, align.z>0 ? 0 : align.z<0 ? -size.z-tooth.y : -size.z])
    rotate([90,0,0]) {
      render(convexity=ceil(abs(length)/2))
        union() {
          linear_extrude(size.y, convexity=ceil(abs(length)/2), slices=0)
            fillet(max(tooth.x/2-tooth.y, tooth.x/4-0.5))
              polygon(concat(
                [ [0, 0],
                  [0, size.z]
                ],
                flatten([ for (i = [0 : 2 : length-2 ]) [
                  [i+1-tooth.x/2, size.z],
                  [i+1-tooth.x/2, size.z+tooth.y-tooth.x/2],
                  [i+1+tooth.x/2, size.z+tooth.y-tooth.x/2],
                  [i+1+tooth.x/2, size.z],
                  [i+2,           size.z]
                ] ]),
                [ [ length, 0 ] ]
              ));
         for (i = [0 : 2 : length-2 ])
           translate([i+1, size.z, 0]) {
             difference() {
               translate([0, tooth.y-tooth.x/2, 0]) cylinder(size.y, d=tooth.x);
               translate([0, 0, -1]) box([tooth.x+1, tooth.x/2+1, size.y+2], [0,-1,1]);
             }
             translate([0, tooth.y-tooth.x/2, 0]) box([tooth.x, tooth.y-tooth.x/2, size.y], [0,-1,1]);
           }
         cube([length, size.z, size.y]);
        }
    }
}


translate([0, 0, 0]) gt2([18, 6.5, 0.5], [0,1,0], tooth=[1,1], $fn=fn);
// translate([0, 0, 0]) gt2(align=[1,0,0], $fn=fn);


// unfinished, takes too long to render
// module gt2(size=[10,6,1], align=[1,1,1], offset=0, bite=1) {
//   normOffset = mod(offset, 2);
//   partSizeX = mod(size.x, 2);
//   wholeSizeX = size.x - partSizeX;
//   start = -ceil(normOffset/2)*2;
//   end = wholeSizeX + (partSizeX > normOffset ? 2 : 0);
//   difference() {
//   translate([normOffset, 0, 0])
//     linear_extrude(size.y)
//     fillet(0.48)
//       fillet(-0.24)
//         polygon(concat(
//           [ [start-1, 0],
//             [start-1, size.z]
//           ],
//           flatten([ for (i = [start : 2 : end-2 ]) [
//             [i+0.5, size.z],
//             [i+0.5, size.z+bite],
//             [i+1.5, size.z+bite],
//             [i+1.5, size.z],
//             [i+2.0, size.z]
//           ] ]),
//           [ [ end+1, size.z ] ],
//           [ [ end+1, 0 ] ]
//         ));
//     translate([-3, -1, -1]) cube([3, 3, size.y+2]);
//     translate([size.x, -1, -1]) cube([3, 3, size.y+2]);
//   }
// }


// translate([0,  -4, 0]) gt2([10.0, 6, 1], [1,0,0], offset=0.0, $fn=fn);  // 0.0      5
// translate([0,  -7, 0]) gt2([10.0, 6, 1], [1,0,0], offset=0.5, $fn=fn);  // 0.0  .   6
// translate([0, -10, 0]) gt2([10.0, 6, 1], [1,0,0], offset=1.0, $fn=fn);  // 0.0  .   6
// translate([0, -13, 0]) gt2([10.0, 6, 1], [1,0,0], offset=1.5, $fn=fn);  // 0.0  .   6
// translate([0, -16, 0]) gt2([10.0, 6, 1], [1,0,0], offset=2.0, $fn=fn);  // 0.0      5

// translate([0, -24, 0]) gt2([10.5, 6, 1], [1,0,0], offset=0.0, $fn=fn);  // 0.5   .  6
// translate([0, -27, 0]) gt2([10.5, 6, 1], [1,0,0], offset=0.5, $fn=fn);  // 0.5  .   6
// translate([0, -30, 0]) gt2([10.5, 6, 1], [1,0,0], offset=1.0, $fn=fn);  // 0.5  .   6
// translate([0, -33, 0]) gt2([10.5, 6, 1], [1,0,0], offset=1.5, $fn=fn);  // 0.5  .   6
// translate([0, -36, 0]) gt2([10.5, 6, 1], [1,0,0], offset=2.0, $fn=fn);  // 0.5   .  6

// translate([0, -44, 0]) gt2([11.0, 6, 1], [1,0,0], offset=0.0, $fn=fn);  // 1.0   .  6
// translate([0, -47, 0]) gt2([11.0, 6, 1], [1,0,0], offset=0.5, $fn=fn);  // 1.0  ..  7
// translate([0, -50, 0]) gt2([11.0, 6, 1], [1,0,0], offset=1.0, $fn=fn);  // 1.0  .   6
// translate([0, -53, 0]) gt2([11.0, 6, 1], [1,0,0], offset=1.5, $fn=fn);  // 1.0  .   6
// translate([0, -56, 0]) gt2([11.0, 6, 1], [1,0,0], offset=2.0, $fn=fn);  // 1.0   .  6

// translate([0, -64, 0]) gt2([11.5, 6, 1], [1,0,0], offset=0.0, $fn=fn);  // 1.5   .  6
// translate([0, -67, 0]) gt2([11.5, 6, 1], [1,0,0], offset=0.5, $fn=fn);  // 1.5  ..  7
// translate([0, -70, 0]) gt2([11.5, 6, 1], [1,0,0], offset=1.0, $fn=fn);  // 1.5  ..  7
// translate([0, -73, 0]) gt2([11.5, 6, 1], [1,0,0], offset=1.5, $fn=fn);  // 1.5  .   6
// translate([0, -76, 0]) gt2([11.5, 6, 1], [1,0,0], offset=2.0, $fn=fn);  // 1.5   .  6

// translate([0, -84, 0]) gt2([12.0, 6, 1], [1,0,0], offset=0.0, $fn=fn);  // 2.0   .  6
// translate([0, -87, 0]) gt2([12.0, 6, 1], [1,0,0], offset=0.5, $fn=fn);  // 2.0  ..  7
// translate([0, -90, 0]) gt2([12.0, 6, 1], [1,0,0], offset=1.0, $fn=fn);  // 2.0  ..  7
// translate([0, -93, 0]) gt2([12.0, 6, 1], [1,0,0], offset=1.5, $fn=fn);  // 2.0  ..  7
// translate([0, -96, 0]) gt2([12.0, 6, 1], [1,0,0], offset=2.0, $fn=fn);  // 2.0   .  6

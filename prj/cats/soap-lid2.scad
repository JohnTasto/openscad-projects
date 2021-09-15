use <nz/nz.scad>


// print settings:
//   top surface skin layers :  1
//
//   top and bottom concentric:
//     top surface skin pattern:      concentric   (found under Experimental)
//     bottom pattern initial layer:  concentric
//   all layers concentric:
//     top/bottom pattern:            concentric
//
//   wall line count:                 as many as it takes to fix inCurable concentric glitches
//   minimum wall flow:               >0
//   z-seam position:                 right or left
//   combing mode:                    not in skin
//
// .stl files are numbered by $fn, amount to add to wall, and base
//   Cura pukes on $fn=32 files
//   `soap-lid-24-+1-4.stl` slices well

fn = 24;  // should be divisible by 8


fudge = 0.01;
fudge2 = 0.02;


lineW = 0.4;
layerH0 = 0.32;
layerHN = 0.2;

function h(l) = layer_relative_height(l, layerHN);
function z(l) = layer_absolute_height(l, layerHN, layerH0);
function floorH(h) = floor_relative_height_layer(h, layerHN);
function  ceilH(h) =  ceil_relative_height_layer(h, layerHN);
function roundH(h) = round_relative_height_layer(h, layerHN);
function floorZ(z) = floor_absolute_height_layer(z, layerHN, layerH0);
function  ceilZ(z) =  ceil_absolute_height_layer(z, layerHN, layerH0);
function roundZ(z) = round_absolute_height_layer(z, layerHN, layerH0);

wall = lineW*4 + 0.01;

base = z(4);

// size = [136.1, 109.45, 10];   // 133.35-135.7 (2.35)  x  107.75-109.05 (1.3)
// size = [137.1, 110.45, 6];   // 133.35-135.7 (2.35)  x  107.75-109.05 (1.3)
// size = [138.0, 111.5, 6];   // 133.35-135.7 (2.35)  x  107.75-109.05 (1.3)
size = [138.0, 111.0, roundH(6)];   // 133.35-135.7 (2.35)  x  107.75-109.05 (1.3)

// snap = [3.125, 2.6];   // 1.75-2 (1.75 mostly)  x  1.25x-2 (1.5 mostly)
// snap = [2.0625, 1.8];   // 1.75-2 (1.75 mostly)  x  1.25x-2 (1.5 mostly)
// snap = [2.0, 1.8];   // 1.75-2 (1.75 mostly)  x  1.25x-2 (1.5 mostly)
snap = [2.0, 2.0];   // 1.75-2 (1.75 mostly)  x  1.25x-2 (1.5 mostly)
snapOffset = take(2, size)/2;

function ovalateX(extra=0) = (size.y+extra)/(size.x+extra);
module ovalateX(extra=0) scale([1, ovalateX(extra), 1]) children();

function ovalateY(extra=0) = (size.x+extra)/(size.y+extra);
module ovalateY(extra=0) scale([ovalateY(extra), 1, 1]) children();

r = circumgoncircumradius(wall/2, $fn=fn);

intersection() {
  minkowski() {
    translate([0, 0, base]) ovalateX(wall) rod(size.z+max(snap), d=size.x+wall, $fn=fn*8);
    scale([1, 1, -1]) teardrop_3d(r, truncate=base, $fn=fn);
  }
  union() {
    minkowski() {
      difference() {
        box([size.x+wall+fudge2, (size.x+wall)*ovalateX(wall)+fudge2, base+size.z+max(snap)], [0,0,1]);
        ovalateX(wall) translate([0,0,-fudge]) rod(base+size.z+max(snap)+fudge2, d=size.x+wall, $fn=fn*8);
      }
      difference() {
        sphere(r, $fn=fn);
        box([r*2+fudge2, r*2+fudge2, -r-fudge], [0,0,1]);
      }
    }
    box([size.x+fudge2, size.y+fudge2, base], [0,0,1]);
  }
}

flipX() intersection() {
  translate([-snapOffset.x, 0, 0])
    ovalateX(wall-snap.x*2) rotate(-22.5) rotate_extrude(angle=45, $fn=fn*16)
      translate([snapOffset.x+size.x/2+wall/2-snap.x, base+size.z]) {
        rotate(180/fn) circle(r=r, $fn=fn);
        polygon(
          [ [-wall/2*sqrt(2)/2,  wall/2*sqrt(2)/2     ]
          , [           snap.x,  wall/2*sqrt(2)+snap.x]
          , [           snap.x, -wall/2*sqrt(2)-snap.x]
          , [-wall/2*sqrt(2)/2, -wall/2*sqrt(2)/2     ]
          ]);
      }
  ovalateX(wall) rod(base+size.z+wall/2*(sqrt(2)/2)+snap.x, d=size.x+wall, $fn=fn*8);
}

flipY() intersection() {
  translate([0, -snapOffset.y, 0])
    ovalateY(wall-snap.y*2) rotate(67.5) rotate_extrude(angle=45, $fn=fn*16)
      translate([snapOffset.y+size.y/2+wall/2-snap.y, base+size.z]) {
        rotate(180/fn) circle(r=r, $fn=fn);
        polygon(
          [ [-wall/2*sqrt(2)/2,  wall/2*sqrt(2)/2     ]
          , [           snap.y,  wall/2*sqrt(2)+snap.y]
          , [           snap.y, -wall/2*sqrt(2)-snap.y]
          , [-wall/2*sqrt(2)/2, -wall/2*sqrt(2)/2     ]
          ]);
      }
  ovalateX(wall) rod(base+size.z+wall/2*sqrt(2)/2+snap.y, d=size.x+wall, $fn=fn*8);
}

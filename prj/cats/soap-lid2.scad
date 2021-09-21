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

ffn = 32;  // should be divisible by 8
cfn = 128;
// ffn = 16;  // should be divisible by 8
// cfn = 32;

fudge = 0.01;
fudge2 = 0.02;
slop = 0.15;

lineW = 0.4;
hExpand0 = -0.1;

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

// size = [136.1, 109.45, 10];   // 133.35-135.7 (2.35)  x  107.75-109.05 (1.3)
// size = [137.1, 110.45, 6];   // 133.35-135.7 (2.35)  x  107.75-109.05 (1.3)
// size = [138.0, 111.5, 6];   // 133.35-135.7 (2.35)  x  107.75-109.05 (1.3)
size = [138.0, 111.0, roundH(6)];   // 133.35-135.7 (2.35)  x  107.75-109.05 (1.3)

// snap = [3.125, 2.6];   // 1.75-2 (1.75 mostly)  x  1.25x-2 (1.5 mostly)
// snap = [2.0625, 1.8];   // 1.75-2 (1.75 mostly)  x  1.25x-2 (1.5 mostly)
// snap = [2.0, 1.8];   // 1.75-2 (1.75 mostly)  x  1.25x-2 (1.5 mostly)
snap = [2.0, 2.0];   // 1.75-2 (1.75 mostly)  x  1.25x-2 (1.5 mostly)
snapOffset = take(2, size)/2;

wall = lineW*4;

base = z(4);
lipR = 1.5;

wallR = 4.5;

minWall = lineW*2;
grooveW = wall + slop*2;

grooveCurveH = grooveW/2*sqrt(2)/2;
grooveFlatH = grooveW/2*sqrt(2)/2;
grooveD = grooveFlatH + grooveCurveH + .75;

grooveH = grooveD - grooveCurveH - grooveFlatH;

layerMid0 = layerH0/2;

lipWGrooveCurve = grooveW/2*(1 - cos(asin((grooveCurveH + grooveFlatH - grooveD + layerMid0) / (grooveW/2))));
lipWGrooveFlat  = grooveW/2*(1 - sqrt(2)/2) + grooveFlatH - grooveD + layerMid0;

lipWGroove
  = grooveD > layerMid0 + grooveFlatH + grooveCurveH ? 0
  : grooveD > layerMid0 + grooveFlatH                ? lipWGrooveCurve
  : grooveD > layerMid0                              ? lipWGrooveFlat
  :                                                    grooveW/2;

lipWLipR = lipR*(1 - sqrt(2)/2) > layerMid0
  ? layerMid0
  : sqrt(layerMid0*(lipR*2 - layerMid0)) - lipR*(sqrt(2) - 1);

lipW = grooveW/2 - wall/2 + lipR*2 - lipR*sqrt(2) - lipWGroove - lipWLipR + minWall - hExpand0*2;

function ovalateX(extra=0) = (size.y+extra)/(size.x+extra);
module ovalateX(extra=0) scale([1, ovalateX(extra), 1]) children();

function ovalateY(extra=0) = (size.x+extra)/(size.y+extra);
module ovalateY(extra=0) scale([ovalateY(extra), 1, 1]) children();


difference() {
  union() {
    // base
    ovalateX(wall*2+lipW*2-lipR*2) rod(base, d=size.x+wall*2+lipW*2-lipR*2, $fn=cfn);
    // wall
    orbit(dX=size.x+wall, dY=size.y+wall, translate=[0, base+size.z+max(snap)], $fn=cfn) union() {
      rect([wall, base+size.z+max(snap)], [0,-1]);
      circle(wall/2, $fn=ffn);
    }
    // lip
    orbit(dX=size.x+wall, dY=size.y+wall, translate=[wall/2+lipW-lipR, lipR], $fn=cfn) union() {
      difference() {
        rotate(180) teardrop(lipR, truncate=lipR, $fn=ffn);
        translate([lipR-lipW-wall/2, 0]) rect([lipR+fudge, lipR*2+fudge2], [-1,0]);
      }
      polygon(
        [ [ lipR-lipW-fudge ,  lipR*sqrt(2)+lipW-lipR ]
        , [ lipR-lipW       ,  lipR*sqrt(2)+lipW-lipR ]
        , [ lipR*sqrt(2)/2  ,  lipR*sqrt(2)/2         ]
        , [ 0               ,  0                      ]
        , [ 0               , -lipR                   ]
        , [ lipR-lipW-fudge , -lipR                   ]
        ]);
    }
    // inner minimum wall (make sure container will still fit!)
    orbit(dX=size.x+wall, dY=size.y+wall, translate=[0, grooveH], $fn=cfn) {
      polygon(
        [ [        0                           ,  grooveW/2*sqrt(2)+minWall ]  // top diagonal
        , [        0                           , -grooveH                   ]  // corner
        , [ -grooveW*sqrt(2)/2-grooveH-minWall , -grooveH                   ]  // bottom diagonal
        ]
      );
    }
  }
  // groove
  orbit(dX=size.x+wall, dY=size.y+wall, translate=[0, grooveH], $fn=cfn) {
    union() {
      difference() {
        teardrop(d=grooveW, $fn=ffn);
        rect([grooveW+fudge2, grooveW+fudge], [0,-1]);
        rotate(-45) rect([grooveW+fudge2, grooveW+fudge], [0,-1]);
      }
      polygon(
        [ [        0                         ,      grooveW/2*sqrt(2) ]  // top diagonal
        , [  grooveW/2                       ,            0           ]  // top vertical
        , [  grooveW/2                       , min(-grooveH-fudge, 0) ]  // bottom vertical
        , [ -grooveW*sqrt(2)/2-grooveH-fudge ,     -grooveH-fudge     ]  // bottom diagonal
        ]
      );
    }
  }
}

// outer wall fillet
difference() {
  orbit(dX=size.x+wall, dY=size.y+wall, translate=[wall/2, lipR*sqrt(2)+lipW + wallR*sqrt(2)-wallR], $fn=cfn)
    translate([-fudge, 0]) rect([wallR*(1-sqrt(2)/2)+fudge, wallR*sqrt(2)/2], [1,-1]);
  orbit(dX=size.x+wall, dY=size.y+wall, translate=[wall/2+wallR/2, lipR*sqrt(2)+lipW + wallR*sqrt(2)-wallR], $fn=cfn)
    translate([wallR/2, 0]) arc(wallR, [135, 225]);
}

flipX() intersection() {
  translate([-snapOffset.x, 0, 0])
    ovalateX(wall-snap.x*2) rotate(-22.5) rotate_extrude(angle=45, $fn=cfn*2)
      translate([snapOffset.x+size.x/2+wall/2-snap.x, base+size.z]) {
        circle(wall/2, $fn=ffn);
        polygon(
          [ [-wall/2*sqrt(2)/2,  wall/2*sqrt(2)/2     ]
          , [           snap.x,  wall/2*sqrt(2)+snap.x]
          , [           snap.x, -wall/2*sqrt(2)-snap.x]
          , [-wall/2*sqrt(2)/2, -wall/2*sqrt(2)/2     ]
          ]);
      }
  ovalateX(wall) rod(base+size.z+wall/2*(sqrt(2)/2)+snap.x, d=size.x+wall, $fn=cfn);
}

flipY() intersection() {
  translate([0, -snapOffset.y, 0])
    ovalateY(wall-snap.y*2) rotate(67.5) rotate_extrude(angle=45, $fn=cfn*2)
      translate([snapOffset.y+size.y/2+wall/2-snap.y, base+size.z]) {
        circle(wall/2, $fn=ffn);
        polygon(
          [ [-wall/2*sqrt(2)/2,  wall/2*sqrt(2)/2     ]
          , [           snap.y,  wall/2*sqrt(2)+snap.y]
          , [           snap.y, -wall/2*sqrt(2)-snap.y]
          , [-wall/2*sqrt(2)/2, -wall/2*sqrt(2)/2     ]
          ]);
      }
  ovalateX(wall) rod(base+size.z+wall/2*sqrt(2)/2+snap.y, d=size.x+wall, $fn=cfn);
}

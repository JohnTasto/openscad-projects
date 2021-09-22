use <nz/nz.scad>


// print settings:
//
// Walls
//   Wall Line Count                  half of what `wall` is set to here
//   Minimum Wall Flow                >0
//   z Seam Alignment                 User Specified
//   z Seam Position                  Left or Right
//   Seam Corner Preference           None
//
// Top/Bottom
//   Top Surface Skin Layers          1
//   Top Layers:                      1
//   Bottom Layers:                   above the base and below the snaps
//   Top/Bottom Pattern:              Concentric
//   Bottom Pattern Initial Layer     Concentric
//   Skin Removal Width               at least as high as what `wall` is set to here
//   Skin Expand Distance             0
//
// Infill
//   Infill Line Distance             1000
//   Infill X Offset                  500
//   Extra Infill Wall Count          0
//
// Travel
//   Combing Mode                     Not in Skin
//
// Experimental
//   Top Surface Skin Pattern         Concentric
//
//
// .stl files are numbered by $fn, amount to add to wall, and base
//   Cura pukes on $fn=32 files
//   `soap-lid-24-+1-4.stl` slices well


ffn = $preview ? 16 :  32;  // should be divisible by 8
cfn = $preview ? 32 : 128;  // anything greather than ~128 causes weird patterns in Cura

fudge  = 0.01;
fudge2 = 0.02;
slop   = 0.15;
slack  = 0.25;

lineW    =  0.6;//0.4;
hExpand0 = -0.15;//-0.10;

layerH0 = 0.44;//0.32;
layerHN = 0.28;//0.2;

function h(l) = layer_relative_height(l, layerHN);
function z(l) = layer_absolute_height(l, layerHN, layerH0);
function floorH(h) = floor_relative_height_layer(h, layerHN);
function  ceilH(h) =  ceil_relative_height_layer(h, layerHN);
function roundH(h) = round_relative_height_layer(h, layerHN);
function floorZ(z) = floor_absolute_height_layer(z, layerHN, layerH0);
function  ceilZ(z) =  ceil_absolute_height_layer(z, layerHN, layerH0);
function roundZ(z) = round_absolute_height_layer(z, layerHN, layerH0);

// 133.35-135.7 (2.35)  x  107.75-109.05 (1.3)
// size = [136.1, 109.45, 10];
// size = [137.1, 110.45, 6];
// size = [138.0, 111.5, 6];
// size = [138.0, 111.0, roundH(6)];
// size = [137.25, 111.75, roundH(6)];
// size = [136.25, 110.75, roundH(6)];
// size = [136.25, 110.75, roundH(6+2)];
// size = [137.50, 109.75, roundH(5.5)];
size = [137.75, 109.75, roundH(6.0)];

// 1.75-2 (1.75 mostly)  x  1.25x-2 (1.5 mostly)
// snap = [3.125, 2.6];
// snap = [2.0625, 1.8];
// snap = [2.0, 1.8];
// snap = [2.0, 2.0];
// snap = [1.5, 1.5];
snap = [1.5, 0.75];
snapRatio = [1/4, 1/4];

wall     = lineW*2;
baseWall = lineW*5;

base = z(6);
lipR = 1.5;
wallR = 4.5;//5.75;

minWall = lineW;//*2;
grooveW = wall + slack*2;

grooveCurveH = grooveW/2*sqrt(2)/2;
grooveFlatH = grooveW/2*sqrt(2)/2;
grooveD = grooveFlatH + grooveCurveH - 0;//layerHN*1;

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
    ovalateX(wall*2) rod(base, d=size.x+wall*2, $fn=cfn);
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
    orbit(dX=size.x+wall, dY=size.y+wall, $fn=cfn) {
      polygon(
        [ [        0                            , grooveW/2*sqrt(2)+grooveH+baseWall ]  // top diagonal
        , [        0                            ,       0                            ]  // corner
        , [ -grooveW*sqrt(2)/2-grooveH-baseWall ,       0                            ]  // bottom diagonal
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
  orbit(dX=size.x+wall, dY=size.y+wall, translate=[wall/2, lipR*sqrt(2)+lipW+wallR*(sqrt(2)-1)], $fn=cfn)
    translate([-fudge, 0]) rect([wallR*(1-sqrt(2)/2)+fudge, wallR*sqrt(2)/2], [1,-1]);
  orbit(dX=size.x+wall, dY=size.y+wall, translate=[wall/2+wallR/2, lipR*sqrt(2)+lipW+wallR*(sqrt(2)-1)], $fn=cfn)
    translate([wallR/2, 0]) arc(wallR, [135, 225], $fn=ffn*2);
}

flipX() intersection() {
  translate([-size.x*snapRatio.x, 0, 0])
    // ovalateX(wall-snap.x*2) rotate(-22.5) rotate_extrude(angle=45, $fn=cfn*2)
    ovalateX(wall-snap.x*2) rotate(180) rotate_extrude($fn=cfn*(1+snapRatio.x*2))
      // translate([size.x*snapRatio.x+size.x/2+wall/2-snap.x, base+size.z]) {
      translate([size.x*(snapRatio.x+0.5)+wall/2-snap.x, base+size.z]) {
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
  translate([0, -size.y*snapRatio.y, 0])
    // ovalateY(wall-snap.y*2) rotate(67.5) rotate_extrude(angle=45, $fn=cfn*2)
    ovalateY(wall-snap.y*2) rotate(-90) rotate_extrude($fn=cfn*(1+snapRatio.y*2))
      // translate([size.y*snapRatio.y+size.y/2+wall/2-snap.y, base+size.z]) {
      translate([size.y*(snapRatio.y+0.5)+wall/2-snap.y, base+size.z]) {
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

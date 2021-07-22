use <nz/nz.scad>


// TODO
//
// Frame
// [x] slide snaps
// [ ] drawer snaps
// [ ] drawer stops
// [ ] bottom hook inserts
// [x] improve fills
//   [x] bFill
//   [x] tBase
//   [x] lSide
//   [x] rSide
//   [x] tlSeamFill
//   [x] trSeamFill
//   [x] tlCorner?
//   [x] trCorner
// Drawers
// [ ] drawers
// [ ] wings
// [ ] ruffles
// [ ] snaps
// [ ] bin ridges?
// Bins
// [ ] bins
// [ ] grooves?
// Bonus
// [ ] either change `sliceN` API to use `align` or change `rect` and `box` to use `centerN`
// [ ] find better solution for adding fudge in `sliceN` functions


$fn = 60;


lineW = 0.6;
layerH0 = 0.45;
layerHN = 0.3;

fWall = lineW*2;
gap = 0.03;
fudge = 0.001;
fudge2 = 0.002;

// b - bin
// d - drawer
// f - frame
bSlopXY = 0.4;
bSlopZ = layerHN;
dSlopXY = 0.6;
dSlopZ = layerHN;
fSlopXY = 0.4;

top = layerHN*3;

bFloor = layerH0 + layerHN*3;
dFloor = layerH0 + layerHN*4;
fFloor = layerH0 + layerHN*3;

// s - snap
sPH = fSlopXY;  // *3/4;         // peak height
sPL = layerHN*2;                 // peak length
sLL = layerRelCeil(sPH);         // lock length
sRL = sLL*6;                     // ramp length
sIL = 0;  // max(sPL*2, sPH*4);  // inset length

bins = [2, 4];

hook = 2.5;  // fWall + fSlopXY/2;
claspW = hook + fWall*2 + fSlopXY/2;
claspD = fWall*2 + fSlopXY/2 + sPH;
hookD = claspD + fSlopXY/2;

function layerRelFloor(h) = div(h, layerHN)*layerHN;
function layerRelCeil(h) = div(h, layerHN)*layerHN + layerHN;
function layerAbsFloor(h) = max(0, div(h-layerH0, layerHN)*layerHN + layerH0);
function layerAbsCeil(h) = layerAbsFloor(h) + layerHN;

binXY = fWall*2 + claspD + fSlopXY + lineW*2 + dSlopXY;
binZ = layerAbsFloor(15);

drawerZ = binZ - layerH0 + layerHN*2 + dFloor;

fGrid = [binXY*(bins.x+1), fWall+hookD+drawerZ+dSlopZ, layerAbsCeil(binXY*bins.y+lineW*2+dSlopXY+fFloor)];



function fillAdjW    (w, flushSides=0) = abs(w) - (1-flushSides)*gap;
function fillWalls   (w, flushSides=0) = div(fillAdjW(w, flushSides) + fudge, fWall+gap);  // `fudge` compensates for some FP precision errors
function fillExtraW  (w, flushSides=0) = max(0, fillAdjW(w, flushSides) - fillWalls(w, flushSides)*(fWall+gap));  // ditto for `max(0, ...)`
function fillExtraGap(w, flushSides=0) = fillExtraW(w, flushSides) / (fillWalls(w, flushSides)*2 + 1-flushSides);
function fillGrid    (w, flushSides=0) = fillExtraGap(w, flushSides)*2 + fWall + gap;
function fillWall    (w, flushSides=0) = fillExtraGap(w, flushSides) + fWall;
function fillGap     (w, flushSides=0) = fillExtraGap(w, flushSides) + gap;



module sliceX(size, translate=[0,0]
, flushT=false, flushB=false, flushL=false, flushR=false
, centerX=false, centerY=false
, cutT=false, cutB=false, cutMid=false, cutAlt=false
) {
  x = abs(size.x);
  y = abs(size.y);
  flushSides = (flushL?1:0) + (flushR?1:0);
  flushEnds  = (flushT?1:0) + (flushB?1:0);
  flushEndOffset = (flushT?fudge/2:0) - (flushB?fudge/2:0);
  fillWalls = fillWalls(x, flushSides);
  fillGrid  = fillGrid (x, flushSides);
  fillWall  = fillWall (x, flushSides);
  fillGap   = fillGap  (x, flushSides);
  tx = translate.x + (centerX ? -size.x/2 : 0) + (size.x<0 ? size.x : 0);
  ty = translate.y + (centerY ? -size.y/2 : 0) + size.y/2;
  module antiChildren(dir) render() difference() {
    translate([flushL?-fudge:0, flushEndOffset]) rect([x+fudge*flushSides, y+fudge*flushEnds], [1,0]);  // bounds for gaps
    intersection() {
      translate([-tx, -ty]) hull() {
        translate([0, dir*y]) offset(delta=-gap) children();
        offset(delta=-gap) children();
      }
      translate([-fudge*2, gap*dir]) rect([x+fudge2*2, y], [1,0]);  // expose only top or bottom
    }
  }
  translate([tx, ty]) {
    if (fillWalls > 0) {
      if (cutMid) translate([flushL?-fudge:0, 0]) rect([x+fudge*flushSides, gap], [1,0]);
      for (i=[0:fillWalls-1]) {
        itx = fillGrid*i - (flushL ? fillGap : 0);
        if (i!=0) translate([itx, flushEndOffset]) rect([fillGap, y+fudge*flushEnds], [1,0]);
        if (cutT || cutB || cutAlt || is_num(cutAlt)) intersection() {
          translate([itx, flushEndOffset]) rect([fillWall+fillGap*2, y+fudge*flushEnds], [1,0]);  // one wall + both gaps
          if (cutT) antiChildren(-1) children();
          if (cutB) antiChildren(1) children();
          if (cutAlt || is_num(cutAlt)) antiChildren((mod(i+(is_num(cutAlt)?cutAlt:0), 2)*2-1)) children();
        }
      }
      if (!flushL) translate([0, flushEndOffset]) rect([fillGap, y+fudge*flushEnds], [1,0]);
      if (!flushR) translate([x-fillGap, flushEndOffset]) rect([fillGap, y+fudge*flushEnds], [1,0]);
    }
    else rect([x, y]);
  }
}

module sliceY(size, translate=[0,0]
, flushT=false, flushB=false, flushL=false, flushR=false
, centerX=false, centerY=false
, cutL=false, cutR=false, cutMid=false, cutAlt=false
) rotate(90) sliceX([size.y, -size.x], [translate.y, -translate.x]
  , flushT=flushL, flushB=flushR, flushL=flushB, flushR=flushT
  , centerX=centerY, centerY=centerX
  , cutT=cutL, cutB=cutR, cutMid=cutMid, cutAlt=cutAlt
  ) rotate(-90) children();

module eSliceX(h, size, translate=[0,0]
, flushT=false, flushB=false, flushL=false, flushR=false
, centerX=false, centerY=false, centerZ=false
, cutT=false, cutB=false, cutMid=false, cutAlt=false
) translate([0, 0, (centerZ?-h/2:0)+(h<0?h:0)])
    if (cutAlt || is_num(cutAlt)) for (i=[0:abs(h)/layerHN-1])
      translate([0, 0, layerHN*i]) extrude(layerHN+(abs(h)/layerHN-1?fudge:0)) sliceX(size, translate
      , flushT=flushT, flushB=flushB, flushL=flushL, flushR=flushR
      , centerX=centerX, centerY=centerY
      , cutT=cutT, cutB=cutB, cutMid=cutMid, cutAlt=mod(i+(is_num(cutAlt)?cutAlt:0), 2)
      ) children();
    else extrude(abs(h)+fudge) sliceX(size, translate
      , flushT=flushT, flushB=flushB, flushL=flushL, flushR=flushR
      , centerX=centerX, centerY=centerY
      , cutT=cutT, cutB=cutB, cutMid=cutMid
      );

module eSliceY(h, size, translate=[0,0]
, flushT=false, flushB=false, flushL=false, flushR=false
, centerX=false, centerY=false, centerZ=false
, cutL=false, cutR=false, cutMid=false, cutAlt=false
) translate([0, 0, (centerZ?-h/2:0)+(h<0?h:0)])
    if (cutAlt || is_num(cutAlt)) for (i=[0:abs(h)/layerHN-1])
      translate([0, 0, layerHN*i]) extrude(layerHN+(abs(h)/layerHN-1?fudge:0)) sliceY(size, translate
      , flushT=flushT, flushB=flushB, flushL=flushL, flushR=flushR
      , centerX=centerX, centerY=centerY
      , cutL=cutL, cutR=cutR, cutMid=cutMid, cutAlt=mod(i+(is_num(cutAlt)?cutAlt:0), 2)
      ) children();
    else extrude(abs(h)+fudge) sliceY(size, translate
      , flushT=flushT, flushB=flushB, flushL=flushL, flushR=flushR
      , centerX=centerX, centerY=centerY
      , cutL=cutL, cutR=cutR, cutMid=cutMid
      );

module eSlice(h, size, translate=[0,0]
, flushT=false, flushB=false, flushL=false, flushR=false
, centerX=false, centerY=false, centerZ=false
, cutT=false, cutB=false, cutL=false, cutR=false
, cutMidX=false, cutMidY=false, cutAltX=false, cutAltY=false
) if (fillExtraGap(size.x, (flushL?1:0)+(flushR?1:0)) < fillExtraGap(size.y, (flushT?1:0)+(flushB?1:0)))
    eSliceX(h, size, translate
    , flushT=flushT, flushB=flushB, flushL=flushL, flushR=flushR
    , centerX=centerX, centerY=centerY, centerZ=centerZ
    , cutT=cutT, cutB=cutB, cutMid=cutMidX, cutAlt=cutAltX
    ) children();
  else
    eSliceY(h, size, translate
    , flushT=flushT, flushB=flushB, flushL=flushL, flushR=flushR
    , centerX=centerX, centerY=centerY, centerZ=centerZ
    , cutL=cutL, cutR=cutR, cutMid=cutMidY, cutAlt=cutAltY
    ) children();



// intermediate calculations
fTopOY = fGrid.y/2 - fSlopXY/4;
fSideOX = fGrid.x/2 - claspD/2 - fSlopXY/2;
fBulgeOX = fGrid.x/2 - fSlopXY/4;
fBulgeOY = fTopOY - claspW - fSlopXY/2;
fBulgeIY = fBulgeOY - fWall;
fWallGrid = fWall + fSlopXY/2;
fWall2 = fWallGrid + fWall;



module hook(dir, d=hookD, hang=gap) translate([-dir*claspW/2, 0]) {
  translate([0, -hang]) rect([fWall*dir, d+hang]);
  translate([0, d]) rect([(fWall+hook)*dir, -fWall]);
}

module snap(dir, d=hookD, hang=gap) {
  extrude(fGrid.z) translate([-dir*claspW/2, -hang]) rect([fWall*dir, d+hang]);
  translate([-dir*claspW/2, d]) rotate([180,270,0]) extrude((fWall+hook)*dir) children();
}

// module bump() polygon(
// [ [                          0               , 0        ]
// , [                          0               , fWall    ]
// , [layerAbsFloor(        sIL+sRL+sPL        ), fWall    ]
// , [layerAbsFloor(        sIL+sRL+sPL  +sPH  ), fWall+sPH]
// , [layerAbsCeil (        sIL+sRL+sPL*2+sPH  ), fWall+sPH]
// , [layerAbsCeil (        sIL+sRL+sPL*2+sPH*2), fWall    ]
// , [layerAbsFloor(fGrid.z-sIL-sRL-sPL*2-sPH*2), fWall    ]
// , [layerAbsFloor(fGrid.z-sIL-sRL-sPL*2-sPH  ), fWall+sPH]
// , [layerAbsCeil (fGrid.z-sIL-sRL-sPL  -sPH  ), fWall+sPH]
// , [layerAbsCeil (fGrid.z-sIL-sRL-sPL        ), fWall    ]
// , [              fGrid.z                     , fWall    ]
// , [              fGrid.z                     , 0        ]
// ]);

// module dent() polygon(
// [ [                      0                     , 0        ]
// , [                      0                     , fWall    ]
// , [layerAbsFloor(        sIL                  ), fWall    ]
// , [layerAbsFloor(        sIL+sRL              ), fWall+sPH]
// , [layerAbsFloor(        sIL+sRL  +sPL        ), fWall+sPH]
// , [layerAbsFloor(        sIL+sRL  +sPL  +sPH*1), fWall    ]
// , [layerAbsCeil (        sIL+sRL  +sPL*2+sPH*1), fWall    ]
// , [layerAbsCeil (        sIL+sRL  +sPL*2+sPH*2), fWall+sPH]
// , [layerAbsCeil (        sIL+sRL  +sPL*3+sPH*2), fWall+sPH]
// , [layerAbsCeil (        sIL+sRL*2+sPL*3+sPH*2), fWall    ]
// , [layerAbsFloor(fGrid.z-sIL-sRL*2-sPL*3-sPH*2), fWall    ]
// , [layerAbsFloor(fGrid.z-sIL-sRL  -sPL*3-sPH*2), fWall+sPH]
// , [layerAbsFloor(fGrid.z-sIL-sRL  -sPL*2-sPH*2), fWall+sPH]
// , [layerAbsFloor(fGrid.z-sIL-sRL  -sPL*2-sPH*1), fWall    ]
// , [layerAbsCeil (fGrid.z-sIL-sRL  -sPL  -sPH*1), fWall    ]
// , [layerAbsCeil (fGrid.z-sIL-sRL  -sPL        ), fWall+sPH]
// , [layerAbsCeil (fGrid.z-sIL-sRL              ), fWall+sPH]
// , [layerAbsCeil (fGrid.z-sIL                  ), fWall    ]
// , [              fGrid.z                       , fWall    ]
// , [              fGrid.z                       , 0        ]
// ]);

module bump() polygon(
[ [        0                          , 0        ]
, [        0                          , fWall    ]
, [layerH0-layerHN+sIL+sRL+sPL        , fWall    ]
, [layerH0-layerHN+sIL+sRL+sPL  +sLL  , fWall+sPH]  // peak
, [layerH0-layerHN+sIL+sRL+sPL*2+sLL  , fWall+sPH]  // peak
, [layerH0-layerHN+sIL+sRL+sPL*2+sLL*2, fWall    ]
, [        fGrid.z-sIL-sRL-sPL*2-sLL*2, fWall    ]
, [        fGrid.z-sIL-sRL-sPL*2-sLL  , fWall+sPH]  // peak
, [        fGrid.z-sIL-sRL-sPL  -sLL  , fWall+sPH]  // peak
, [        fGrid.z-sIL-sRL-sPL        , fWall    ]
, [        fGrid.z                    , fWall    ]
, [        fGrid.z                    , 0        ]
]);

module dent() polygon(
[ [        0                            , 0        ]
, [        0                            , fWall    ]
, [layerH0-layerHN+sIL                  , fWall    ]
, [layerH0-layerHN+sIL+sRL              , fWall+sPH]
, [layerH0-layerHN+sIL+sRL  +sPL        , fWall+sPH]
, [layerH0-layerHN+sIL+sRL  +sPL  +sLL  , fWall    ]  // peak
, [layerH0-layerHN+sIL+sRL  +sPL*2+sLL  , fWall    ]  // peak
, [layerH0-layerHN+sIL+sRL  +sPL*2+sLL*2, fWall+sPH]
, [layerH0-layerHN+sIL+sRL  +sPL*3+sLL*2, fWall+sPH]
, [layerH0-layerHN+sIL+sRL*2+sPL*3+sLL*2, fWall    ]
, [        fGrid.z-sIL-sRL*2-sPL*3-sLL*2, fWall    ]
, [        fGrid.z-sIL-sRL  -sPL*3-sLL*2, fWall+sPH]
, [        fGrid.z-sIL-sRL  -sPL*2-sLL*2, fWall+sPH]
, [        fGrid.z-sIL-sRL  -sPL*2-sLL  , fWall    ]  // peak
, [        fGrid.z-sIL-sRL  -sPL  -sLL  , fWall    ]  // peak
, [        fGrid.z-sIL-sRL  -sPL        , fWall+sPH]
, [        fGrid.z-sIL-sRL              , fWall+sPH]
, [        fGrid.z-sIL                  , fWall    ]
, [        fGrid.z                      , fWall    ]
, [        fGrid.z                      , 0        ]
]);

// module tHooks()             flipX() translate([fSideOX-fWallGrid-claspW/2, fTopOY-fWallGrid])       hook( 1);
module bHooks() rotate(180) flipX() translate([fSideOX-fWallGrid-claspW/2, fTopOY+fWallGrid-hookD]) hook(-1);
// module lHooks() rotate(90)  flipX() translate([fTopOY-claspW/2, fSideOX]) hook( 1);
// module rHooks() rotate(270) flipX() translate([fTopOY-claspW/2, fSideOX]) hook(-1);

// module blHook(d=hookD, hang=gap) rotate(180) translate([ fSideOX-fWallGrid-claspW/2, fTopOY+fWallGrid-hookD]) hook(-1, d, hang);
// module brHook(d=hookD, hang=gap) rotate(180) translate([-fSideOX+fWallGrid+claspW/2, fTopOY+fWallGrid-hookD]) hook( 1, d, hang);

module tSnaps()             flipX() translate([fSideOX-fWallGrid-claspW/2, fTopOY-fWallGrid])       snap( 1) dent();
module bSnaps() rotate(180) flipX() translate([fSideOX-fWallGrid-claspW/2, fTopOY+fWallGrid-hookD]) snap(-1) bump();
module lSnaps() rotate(90)  flipX() translate([fTopOY-claspW/2, fSideOX]) snap( 1) dent();
module rSnaps() rotate(270) flipX() translate([fTopOY-claspW/2, fSideOX]) snap(-1) bump();

module blSnap(d=hookD, hang=gap) rotate(180) translate([ fSideOX-fWallGrid-claspW/2, fTopOY+fWallGrid-hookD]) snap(-1, d, hang) bump();
module brSnap(d=hookD, hang=gap) rotate(180) translate([-fSideOX+fWallGrid+claspW/2, fTopOY+fWallGrid-hookD]) snap( 1, d, hang) bump();

// bSnaps();



module tlSeamFill(l) translate([fGrid.x*l-fBulgeOX, claspD-fTopOY]) {
  rB = [fBulgeOX-fSideOX+fWall2, -claspD];
  rL = rB - [fWall, -fWall];
  extrude(fFloor) rect(rB);
  translate([0, 0, fGrid.z-top]) difference() {
    hull() {
      extrude(top) rect(rB);
      extrude(rL.y) rect([rB.x, -fWall]);
    }
    translate([0, -fWall]) {
      eSliceX(rL.y, rL, flushL=true);
      eSliceX(top, [rL.x, rL.y+fWall], flushL=true, cutAlt=true);
      // doesn't seem to be ncessary:
      // eSliceY(top, [rL.x, -fWall], translate=[0, rL.y+fWall], flushL=true, flushT=true, flushB=true);
    }
  }
}

module trSeamFill(r) translate([fGrid.x*r+fBulgeOX, claspD-fTopOY]) {
  rB = [fSideOX-fBulgeOX-fWall2, -claspD];
  rL = rB - [-fWall, -fWall];
  extrude(fFloor) rect(rB);
  translate([0, 0, fGrid.z-top]) difference() {
    hull() {
      extrude(top) rect(rB);
      extrude(rL.y) rect([rB.x, -fWall]);
    }
    translate([0, -fWall]) {
      eSliceX(rL.y, rL, flushR=true);
      eSliceX(top, [rL.x, rL.y+fWall], flushR=true, cutAlt=true);
      // doesn't seem to be ncessary:
      // eSliceY(top, [rL.x, -fWall], translate=[0, rL.y+fWall], flushR=true, flushT=true, flushB=true);
    }
  }
}

module bFill() translate([0, fTopOY-fWall2]) {
  rB = [fSideOX*2-fSlopXY-claspW*2, hookD+fWall];
  rL = rB - [fWall*2, fWall];
  extrude(fFloor) rect(rB, [0,1]);
  translate([0, 0, fGrid.z-top]) difference() {
    hull() {
      extrude(top) rect(rB, [0,1]);
      extrude(-rL.y) rect([rB.x, fWall], [0,1]);
    }
    translate([0, fWall]) {
      eSliceX(-rL.y, rL, centerX=true);
      eSliceX(top, [rL.x, rL.y-fWall], centerX=true, cutAlt=true);
      eSliceY(top, [rL.x, fWall], translate=[0, rL.y-fWall], flushT=true, flushB=true, centerX=true, cutAlt=true);
    }
  }
}

module bSeamFill() translate([fGrid.x/2, fTopOY-fWall2]) {
  rB = [claspD+fWallGrid*2, fWall2];
  rL = rB - [fWall*2, fWall];
  extrude(fFloor) rect(rB, [0,1]);
  translate([0, 0, fGrid.z-top]) difference() {
    hull() {
      extrude(top) rect(rB, [0,1]);
      extrude(-rL.y) rect([rB.x, fWall], [0,1]);
    }
    translate([0, fWall]) {
      eSliceX(-rL.y, rL, centerX=true);
      eSliceY(top, rL, flushT=true, centerX=true, cutAlt=true);
    }
  }
}

module blSeamFill(l) translate([fGrid.x*l-fBulgeOX, fTopOY-fWall2]) {
  rB = [fBulgeOX-fSideOX+fWall, fWall2];
  rL = rB - [fWall, fWall];
  extrude(fFloor) rect(rB);
  translate([0, 0, fGrid.z-top]) difference() {
    hull() {
      extrude(top) rect(rB);
      extrude(-rL.y) rect([rB.x, fWall]);
    }
    translate([0, fWall]) {
      eSliceX(-rL.y, rL, flushL=true);
      eSliceY(top, rL, flushT=true, flushL=true);
    }
  }
}

module brSeamFill(r) translate([fGrid.x*r+fBulgeOX, fTopOY-fWall2]) {
  rB = [fSideOX-fBulgeOX-fWall, fWall2];
  rL = rB - [-fWall, fWall];
  extrude(fFloor) rect(rB);
  translate([0, 0, fGrid.z-top]) difference() {
    hull() {
      extrude(top) rect(rB);
      extrude(-rL.y) rect([rB.x, fWall]);
    }
    translate([0, fWall]) {
      eSliceX(-rL.y, rL, flushR=true);
      eSliceY(top, rL, flushT=true, flushR=true);
    }
  }
}



module tBase(l=0, r=0) if (l<=r) for (i=[l:r]) translate([fGrid.x*i, 0]) {
  bSnaps();
  if (i!=r) translate([fGrid.x/2, claspD-fTopOY]) {
    rB = [claspD+fWall2*2+fSlopXY, -claspD];
    rL = rB - [fWall*2, -fWall];
    extrude(fFloor) rect(rB, [0,1]);
    translate([0, 0, fGrid.z-top]) difference() {
      hull() {
        extrude(top) rect(rB, [0,1]);
        extrude(rL.y) rect([rB.x, -fWall], [0,1]);
      }
      translate([0, -fWall]) {
        eSliceX(rL.y, rL, centerX=true);
        eSliceX(top, [rL.x, rL.y+fWall], centerX=true, cutAlt=true);
        eSliceY(top, [rL.x, -fWall], translate=[0, rL.y+fWall], flushT=true, flushB=true, centerX=true, cutAlt=true);
      }
    }
  }
}

module bBase(l=0, r=0) if (l<=r) for (i=[l:r]) translate([fGrid.x*i, 0]) {
  extrude(fGrid.z) flipX() translate([fGrid.x/2-claspD/2-fSlopXY/2, fGrid.y/2-fSlopXY/4]) rect([-fWall, -fWall2]);
  tSnaps();
  if (i!=r) bSeamFill();
  bFill();
}



module tSide(l=0, r=0) {
  if (l<=r) {
    extrude(fGrid.z) translate([fGrid.x*l-fBulgeOX, hookD+fSlopXY/4-fGrid.y/2-fWallGrid]) rect([fGrid.x*(r-l)+fBulgeOX*2, fWall]);
    tlSeamFill(l);
    trSeamFill(r);
  }
  tBase(l=l, r=r);
}

module bSide(l=0, r=0) {
  if (l<=r) {
    extrude(fGrid.z) translate([fGrid.x*l-fBulgeOX, fTopOY-fWallGrid]) rect([fGrid.x*(r-l)+fBulgeOX*2, -fWall]);
    blSeamFill(l);
    brSeamFill(r);
  }
  bBase(l=l, r=r);
}

module lSide(b=0, t=0) if (b<=t) {
  extrude(fGrid.z) translate([fSideOX, fGrid.y*b-fTopOY]) rect([-fWall, fGrid.y*(t-b)+fTopOY*2]);
  for (i=[b:t]) translate([0, fGrid.y*i]) rSnaps();
  extrude(fFloor) for (i=[b:t]) if (i!=b) translate([fSideOX-fWall, fGrid.y*(i-0.5)]) rect([claspD+fWallGrid, fWall2], [1,0]);
  for (i=[b:t]) translate([fBulgeOX+(fSideOX-fBulgeOX-fWall), fGrid.y*i]) {
    rB = [-fSideOX+fBulgeOX+fWall, fTopOY*2-claspW*2-fSlopXY];
    rL = rB - [fWall, 0];
    extrude(fFloor) rect(rB, [1,0]);
    translate([0, 0, fGrid.z-top]) difference() {
      hull() {
        extrude(top) rect(rB, [1,0]);
        extrude(-rL.x) rect([fWall, rB.y], [1,0]);
      }
      translate([fWall, 0]) {
        eSliceY(-rL.x, rL, flushT=true, flushB=true, centerY=true);
        eSliceY(top, [rL.x-fWall, rL.y-fWall*2], centerY=true, cutAlt=true);
        eSliceX(top, [fWall, rL.y-fWall*2], translate=[rL.x-fWall, 0], flushL=true, flushR=true, centerY=true, cutAlt=true);
      }
    }
  }
}

module rSide(b=0, t=0) if (b<=t) {
  extrude(fGrid.z) translate([-fSideOX, fGrid.y*b-fTopOY]) rect([fWall, fGrid.y*(t-b)+fTopOY*2]);
  for (i=[b:t]) translate([0, fGrid.y*i]) lSnaps();
  for (i=[b:t]) translate([-fBulgeOX+(fBulgeOX+fWall-fSideOX), fGrid.y*i]) {
    rB = [-fBulgeOX-fWall+fSideOX, fTopOY*2-claspW*2+fWall*2];
    rL = rB - [-fWall, fWall*2];
    extrude(fFloor) rect(rB, [1,0]);
    translate([0, 0, fGrid.z-top]) difference() {
      hull() {
        extrude(top) rect(rB, [1,0]);
        extrude(rL.x) rect([-fWall, rB.y], [1,0]);
      }
      translate([-fWall, 0]) {
        eSliceY(rL.x, rL, centerY=true);
        eSliceY(top, [rL.x+fWall, rL.y], centerY=true, cutAlt=true);
        eSliceX(top, [-fWall, rL.y], translate=[rL.x+fWall, 0], flushL=true, flushR=true, centerY=true, cutAlt=true);
      }
    }
  }
}



module corner(edge, r, align) translate([(fGrid.x-edge)*align.x, (fGrid.y-fTopOY)*align.y]) difference() {
  circle(r=r);
  circle(r=r-fWall);
  translate([0, -align.y*(r-fWall)]) rect([r*2*align.x, r*2*align.y]);
  translate([-align.x*(r-fWall), 0]) rect([r*2*align.x, r*2*align.y]);
}

module cornerMask(edge, r, align) translate([(fGrid.x-edge)*align.x, (fGrid.y-fTopOY)*align.y]) {
  circle(r=r);
  translate([0, -align.y*r]) rect([(fGrid.x/2+edge)*align.x, (fGrid.y+r-fSlopXY/4)*align.y]);
  translate([-align.x*r, 0]) rect([(fGrid.x/2+edge+r)*align.x, (fGrid.y-fSlopXY/4)*align.y]);
}

module cornerFloor(edge, r, size, align) intersection() {
  translate([(fGrid.x-edge-r)*align.x, (fGrid.y-fTopOY-r)*align.y]) rect([size.x*align.x, size.y*align.y]);
  cornerMask(edge, r, align);
}



module tlCorner(b=-1, r=1) {
  edge = fSideOX + fWallGrid;
  fillet = claspD + fSlopXY/2;
  if (1 <= r) {
    extrude(fGrid.z) {
      translate([fGrid.x-edge, hookD+fSlopXY/4-fGrid.y/2-fWallGrid]) rect([fGrid.x*(r-1)+fBulgeOX+edge, fWall]);
      corner(edge, fillet, [1,-1]);
    }
    trSeamFill(r);
    rIB = [claspD+fWallGrid*3, -fillet+fSlopXY/2];
    rIL = [fWall+fSlopXY, rIB.y+fWall];
    rOB = [claspD+fWallGrid, -fillet-fWall];
    rOL = rOB - [fWall, -fWall*2];
    align = [1, -1];
    tx = fGrid.x-edge-fillet;
    ty = -fGrid.y+fTopOY+fillet;
    extrude(fFloor) {
      intersection() {
        translate([tx, ty]) rect(rIB);
        cornerMask(edge, fillet, align);
      }
      intersection() {
        translate([tx, ty]) rect(rOB);
        cornerMask(edge, fillet, align);
      }
    }
    translate([0, 0, fGrid.z-top]) difference() {
      intersection() {
        translate([tx, ty]) {
          hull() {
            extrude(top) rect(rIB);
            extrude(rIL.y) rect([rIB.x, -fWall]);
          }
          hull() {
            extrude(top) rect([rOB.x, rOB.y+fWall]);
            extrude(rOL.y) rect([rOB.x, -fWall]);
          }
        }
        extrude((min(rIL.y, rOL.y)-top)*2, center=true) cornerMask(edge, fillet, align);
      }
      eSliceX(rOL.y, rOL, translate=[tx+fWall, ty-fWall], flushR=true);
      eSliceX(rIL.y, rIL, translate=[tx+rOB.x, ty-fWall]);
      eSliceX(top, rOL, translate=[tx+fWall, ty-fWall], flushR=true, cutAlt=1) offset(delta=-fWall) cornerMask(edge, fillet, align);
      eSliceX(top, [rIL.x, rIL.y+fWall], translate=[tx+rOB.x, ty-fWall], cutAlt=1);
      eSliceY(top, [rIL.x, -fWall], translate=[tx+rOB.x, ty+rIL.y], flushT=true, flushB=true, cutAlt=true);
    }
  }
  tBase(l=1, r=r);
  lSide(b=b, t=-1);
}

module trCorner(b=-1, l=-1) {
  edge = fSideOX + fWallGrid;
  fillet = claspD + fSlopXY/2;
  if (l <= -1) {
    extrude(fGrid.z) {
      translate([edge-fGrid.x, hookD+fSlopXY/4-fGrid.y/2-fWallGrid]) rect([fGrid.x*(l+1)-fBulgeOX-edge, fWall]);
      corner(edge, fillet, [-1,-1]);
    }
    tlSeamFill(l);
    rB = [-claspD-fWallGrid*3, -fillet+fSlopXY/2];
    rL = rB - [-fWall*2, -fWall];
    align = [-1, -1];
    tx = -fGrid.x+edge+fillet;
    ty = -fGrid.y+fTopOY+fillet;
    extrude(fFloor) intersection() {
      translate([tx, ty]) rect(rB);
      cornerMask(edge, fillet, align);
    }
    translate([0, 0, fGrid.z-top]) difference() {
      intersection() {
        translate([tx, ty]) hull() {
          extrude(top) rect(rB);
          extrude(rL.y) rect([rB.x, -fWall]);
        }
        extrude((rL.y-top)*2, center=true) cornerMask(edge, fillet, align);
      }
      eSliceX(rL.y, rL, translate=[tx-fWall, ty-fWall]);
      eSliceX(top, [rL.x, rL.y+fWall], translate=[tx-fWall, ty-fWall], cutAlt=true) offset(delta=-fWall) cornerMask(edge, fillet, align);
      eSliceY(top, [rL.x, -fWall], translate=[tx-fWall, ty+rL.y], flushT=true, flushB=true, cutAlt=1) offset(delta=-fWall) cornerMask(edge, fillet, align);
    }
  }
  tBase(l=l, r=-1);
  rSide(b=b, t=-1);
}

module blCorner(t=1, r=1) {
  edge = fGrid.x/2 + claspD/2 - fWallGrid;
  fillet = fWallGrid*2;
  if (1 <= r) {
    extrude(fGrid.z) {
      translate([fGrid.x-edge, fTopOY-fWallGrid]) rect([fGrid.x*(r-1)+fBulgeOX+edge, -fWall]);
      corner(edge, fillet, [1,1]);
    }
    brSeamFill(r);
    rIB = [claspD+fWallGrid*2, fillet-fSlopXY/2];
    rIL = [fSlopXY/2, rIB.y-fWall];
    rOB = [claspD+fWallGrid, fillet+fWall];
    rOL = rOB - [fWall, fWall*2];
    align = [1, 1];
    tx = fGrid.x-edge-fillet;
    ty = fGrid.y-fTopOY-fillet;
    extrude(fFloor) {
      intersection() {
        translate([tx, ty]) rect(rIB);
        cornerMask(edge, fillet, align);
      }
      intersection() {
        translate([tx, ty]) rect(rOB);
        cornerMask(edge, fillet, align);
      }
    }
    translate([0, 0, fGrid.z-top]) difference() {
      intersection() {
        translate([tx, ty]) {
          hull() {
            extrude(top) rect(rIB);
            // extrude(-rIL.y) rect([rIB.x, fWall]);  // too narrow to print
          }
          hull() {
            extrude(top) rect([rOB.x, rOB.y-fWall]);
            extrude(-rOL.y) rect([rOB.x, fWall]);
          }
        }
        extrude((max(rIL.y, rOL.y)+top)*2, center=true) cornerMask(edge, fillet, align);
      }
      // eSliceX(rIL.y, rIL, translate=[tx+claspD+fWallGrid, ty-fWall]);
      eSliceX(-rOL.y, rOL, translate=[tx+fWall, ty+fWall], flushR=true);
      eSliceY(top, rIL, translate=[tx+claspD+fWallGrid, ty+fWall], flushT=true, cutAlt=true);
      eSliceX(top, rOL, translate=[tx+fWall, ty+fWall], flushR=true, cutAlt=1) offset(delta=-fWall) cornerMask(edge, fillet, align);
    }
  }
  bBase(l=1, r=r);
  lSide(b=1, t=t);
}

module brCorner(t=1, l=-1) {
  edge = fGrid.x/2 + claspD/2 - fWallGrid;
  fillet = fWallGrid*2;
  if (l <= -1) {
    extrude(fGrid.z) {
      translate([edge-fGrid.x, fTopOY-fWallGrid]) rect([fGrid.x*(l+1)-fBulgeOX-edge, -fWall]);
      corner(edge, fillet, [-1,1]);
    }
    blSeamFill(l);
    rB = [-claspD-fWallGrid*2, fillet-fSlopXY/2];
    rL = rB - [-fWall*2, +fWall];
    align = [-1, 1];
    tx = -fGrid.x+edge+fillet;
    ty = fGrid.y-fTopOY-fillet;
    extrude(fFloor) intersection() {
      translate([tx, ty]) rect(rB);
      cornerMask(edge, fillet, align);
    }
    translate([0, 0, fGrid.z-top]) difference() {
      intersection() {
        translate([tx, ty]) hull() {
          extrude(top) rect(rB);
          extrude(-rL.y) rect([rB.x, fWall]);
        }
        extrude((rL.y+top)*2, center=true) cornerMask(edge, fillet, align);
      }
      eSliceX(-rL.y, rL, translate=[tx-fWall, ty+fWall]);
      eSliceY(top, rL, translate=[tx-fWall, ty+fWall], flushT=true, cutAlt=true) offset(delta=-fWall) cornerMask(edge, fillet, align);
    }
  }
  bBase(l=l, r=-1);
  rSide(b=1, t=t);
}



module perimeter(t=0, b=0, l=0, r=0) {
  translate([0, fGrid.y*(t+1)]) tSide(l+1, r-1);
  translate([0, fGrid.y*(b-1)]) bSide(l+1, r-1);
  translate([fGrid.x*(l-1), 0]) lSide(b+1, t-1);
  translate([fGrid.x*(r+1), 0]) rSide(b+1, t-1);
  translate([fGrid.x*(l-1), fGrid.y*(t+1)]) tlCorner(b=-1, r= 1);
  translate([fGrid.x*(r+1), fGrid.y*(t+1)]) trCorner(b=-1, l=-1);
  translate([fGrid.x*(l-1), fGrid.y*(b-1)]) blCorner(t= 1, r= 1);
  translate([fGrid.x*(r+1), fGrid.y*(b-1)]) brCorner(t= 1, l=-1);
}



module frame(t=0, b=0, l=0, r=0) {

  module bulge() extrude(fGrid.z) translate([0, fBulgeOX]) {
    flipX() translate([fBulgeOY, 0]) rect([-fWall, fSideOX-fBulgeOX-fWall]);
    rect([fBulgeOY*2, -fWall], [0,1]);
  }

  module lBulge() rotate(90)  bulge();
  module rBulge() rotate(270) bulge();

  module tFrame(l=0, r=0) {
    for (i=[l:r]) translate([fGrid.x*i, 0]) {
      tSnaps();
      extrude(fGrid.z) flipX() translate([fGrid.x/2-claspD/2-fSlopXY/2, fGrid.y/2-fSlopXY/4]) rect([-fWall, -fWall2]);
    }
    extrude(fGrid.z) translate([fGrid.x*r+fSideOX, fTopOY-fWallGrid]) rect([fGrid.x*(l-r)-fSideOX*2, -fWall]);
  }

  module bFrame(l=0, r=0) {
    translate([fGrid.x*l, fWall+fWallGrid-hookD]) blSnap(fWall2, claspD-fWall2);
    translate([fGrid.x*r, fWall+fWallGrid-hookD]) brSnap(fWall2, claspD-fWall2);
    extrude(fGrid.z) {
      translate([fGrid.x*r+fSideOX, -fTopOY]) rect([-fWall2, fWall]);
      translate([fGrid.x*l-fSideOX, -fTopOY]) rect([ fWall2, fWall]);
    }
  }

  module lFrame(b=0, t=0) {
    for (i=[b:t]) translate([0, fGrid.y*i]) {
      lSnaps();
      lBulge();
      if (i < t) extrude(fGrid.z) translate([-fSideOX, fBulgeIY]) rect([fWall, fGrid.y-2*fBulgeIY]);
    }
    extrude(fGrid.z) {
      translate([-fSideOX, fGrid.y*t+fBulgeIY]) rect([fWall, fTopOY-fBulgeIY]);
      translate([-fSideOX, fGrid.y*b-fBulgeIY]) rect([fWall, fBulgeIY-fTopOY]);
    }
  }

  module rFrame(b=0, t=0) {
    for (i=[b:t]) translate([0, fGrid.y*i]) {
      rSnaps();
      rBulge();
      if (i < t) extrude(fGrid.z) translate([fSideOX, fBulgeIY]) rect([fWall, fGrid.y-2*fBulgeIY], [-1,1]);
    }
    extrude(fGrid.z) {
      translate([fSideOX, fGrid.y*t+fBulgeIY]) rect([-fWall, fTopOY-fBulgeIY]);
      translate([fSideOX, fGrid.y*b-fBulgeIY]) rect([-fWall, fBulgeIY-fTopOY]);
    }
  }

  translate([0, fGrid.y*t]) tFrame(l, r);
  translate([0, fGrid.y*b]) bFrame(l, r);
  translate([fGrid.x*l, 0]) lFrame(b, t);
  translate([fGrid.x*r, 0]) rFrame(b, t);

  extrude(fFloor) {
    translate([fGrid.x*r+fSideOX, fGrid.y*t+fTopOY-fWallGrid]) rect([fGrid.x*(l-r)-fSideOX*2, fGrid.y*(b-t)-fTopOY*2+claspD+fSlopXY/2]);
    translate([fGrid.x*r+fSideOX, fGrid.y*t+fTopOY-fWallGrid]) rect([-fWall2, fGrid.y*(b-t)-fTopOY*2+fWallGrid]);
    translate([fGrid.x*l-fSideOX, fGrid.y*t+fTopOY-fWallGrid]) rect([ fWall2, fGrid.y*(b-t)-fTopOY*2+fWallGrid]);
    for (i=[b:t]) if (i!=b) translate([fGrid.x*(r+0.5)+claspD/2, fGrid.y*(i-0.5)]) rect([-claspD-fWallGrid, -fWall2], [1,0]);
    for (i=[b:t]) translate([fGrid.x*l-fBulgeOX, fGrid.y*i]) rect([fBulgeOX-fSideOX+fWall, fTopOY*2-claspW*2+fWall*2], [1,0]);
    for (i=[b:t]) translate([fGrid.x*r+fBulgeOX, fGrid.y*i+fBulgeOY]) rect([fGrid.x*(l-r)-fBulgeOX*2, -fBulgeOY*2]);
    // TODO: make clip-in top version
    for (i=[l:r]) if (i!=r) translate([fGrid.x*(i+0.5), fGrid.y*b-fTopOY]) rect([claspD+fWallGrid*4, hookD], [0,1]);
    for (i=[l:r]) translate([fGrid.x*i, fGrid.y*b]) bHooks();
  }
  for (i=[l:r]) if (i!=r) translate([fGrid.x*i, fGrid.y*t]) bSeamFill();
  for (i=[l:r]) translate([fGrid.x*i, fGrid.y*t]) bFill();
}

module drawer(units) {

}

module bin(fraction, space) {

}





module demoFrame() {
  color([0.6,0.6,0.6,1])
    rotate([90]) {
      // translate([0,0,300]) frame();
      // translate([-fGrid.x/2, -fGrid.y/2, 150]) frame(t=1, b=0, l=0, r=1);

      frame(t= 2, b= 2, l=-4, r=-3);
      frame(t= 1, b= 1, l=-4, r=-3);
      frame(t= 0, b= 0, l=-4, r=-3);
      frame(t=-1, b=-2, l=-4, r=-3);

      frame(t= 2, b= 2, l=-2, r=-2);
      frame(t= 1, b= 1, l=-2, r=-2);
      frame(t= 0, b= 0, l=-2, r=-2);
      frame(t=-1, b=-2, l=-2, r=-1);

      frame(t= 2, b= 2, l=-1, r=1);
      frame(t= 1, b= 1, l=-1, r=1);
      frame(t= 0, b= 0, l=-1, r=1);

      frame(t=-1, b=-1, l= 0, r= 0);
      frame(t=-2, b=-2, l= 0, r= 0);

      frame(t= 2, b= 2, l= 2, r= 2);
      frame(t= 1, b= 1, l= 2, r= 2);
      frame(t= 0, b= 0, l= 2, r= 2);
      frame(t=-1, b=-2, l= 1, r= 2);

      frame(t= 2, b= 2, l= 3, r= 4);
      frame(t= 1, b= 1, l= 3, r= 4);
      frame(t= 0, b= 0, l= 3, r= 4);
      frame(t=-1, b=-2, l= 3, r= 4);
    }
  color([0.85,0.6,0.0,1])
    rotate([90]) {
      perimeter(t=2, b=-2, l=-4, r=4);
  }
}

demoFrame();

// frame();
// frame(t=1, b=-1, l=-1, r=1);

// color([0.5,0.5,0.5,1]) extrude(fGrid.z) perimeter();
// color([0.5,0.5,0.5,1]) extrude(fGrid.z) perimeter(t=1, b=-2, l=-1, r=2);


// box([212, 1, 1], [0,0,0]);


// translate([0,7,0]) tSide(-1,1);
// translate([0,-7,0]) bSide(-1,1);
// tlCorner();
// trCorner();
// blCorner();
// brCorner();



module demoFill(w) {
  echo(flush=2, fillWalls=fillWalls(w, 2), fillExtraW=fillExtraW(w, 2), fillExtraGap=fillExtraGap(w, 2));
  echo(flush=1, fillWalls=fillWalls(w, 1), fillExtraW=fillExtraW(w, 1), fillExtraGap=fillExtraGap(w, 1));
  echo(flush=0, fillWalls=fillWalls(w, 0), fillExtraW=fillExtraW(w, 0), fillExtraGap=fillExtraGap(w, 0));
  baseColor = [0.0, 0.2, 0.4];
  gapColor = [0.4, 0.2, 0.0];
  lineColor = [0.8, 0.5, 0.0];
  cutColor = [0.5, 0.5, 0.5, 0.5];
  baseH = -0.25;
  gapH = 0.1;
  lineH = 0.1;
  cutH = 0.2;
  // normal, tightly packed
  translate([0,0]) {
    fillWalls = div(w-gap+fudge, fWall+gap);
    color(baseColor) extrude(baseH) rect([w, 1]);
    if (fillWalls > 0) {
      color(gapColor) extrude(gapH) rect([gap, 1]);
      for (i=[0:fillWalls-1]) translate([i*(fWall+gap)+gap, 0]) {
        color(lineColor) extrude(lineH) rect([fWall, 1]);
        color(gapColor) extrude(gapH) translate([fWall, 0]) rect([gap, 1]);
      }
    }
  }
  // spread evenly
  translate([0,1.5]) {
    fillWalls = fillWalls(w, 0);
    fillWall  = fillWall (w, 0);
    fillGap   = fillGap  (w, 0);
    fillGrid  = fillGrid (w, 0);
    color(baseColor) extrude(baseH) rect([w, 1]);
    if (fillWalls > 0) {
      color(gapColor) extrude(gapH) rect([gap/2, 1]);
      color(gapColor) extrude(gapH) translate([fillGap-gap/2, 0]) rect([gap/2, 1]);
      for (i=[0:fillWalls-1]) translate([i*fillGrid+fillGap, 0]) {
        color(lineColor) extrude(lineH) rect([fWall/2, 1]);
        color(lineColor) extrude(lineH) translate([fillWall-fWall/2, 0]) rect([fWall/2, 1]);
        color(gapColor) extrude(gapH) translate([fillWall, 0]) rect([gap/2, 1]);
        color(gapColor) extrude(gapH) translate([fillGrid-gap/2, 0]) rect([gap/2, 1]);
      }
      for (i=[0:fillWalls-1]) translate([i*fillGrid+fillGap, 0])
        color(cutColor) extrude(cutH) translate([fillWall, 0]) rect([fillGap, 1]);
    }
    color(cutColor) extrude(cutH) rect([fillGap, 1]);
  }
  // flush to end
  translate([0,3]) {
    fillWalls = fillWalls(w, 1);
    fillWall  = fillWall (w, 1);
    fillGap   = fillGap  (w, 1);
    fillGrid  = fillGrid (w, 1);
    color(baseColor) extrude(baseH) rect([w, 1]);
    if (fillWalls > 0) {
      for (i=[0:fillWalls-1]) translate([i*fillGrid, 0]) {
        color(lineColor) extrude(lineH) translate([fillGap, 0]) rect([fWall/2, 1]);
        color(lineColor) extrude(lineH) translate([fillGrid-fWall/2, 0]) rect([fWall/2, 1]);
        color(gapColor) extrude(gapH) rect([gap/2, 1]);
        color(gapColor) extrude(gapH) translate([fillGap-gap/2, 0]) rect([gap/2, 1]);
      }
      for (i=[0:fillWalls-1]) translate([i*fillGrid, 0])
        color(cutColor) extrude(cutH) rect([fillGap, 1]);
    }
    else color(cutColor) extrude(cutH) rect([w, 1]);
  }
  // flush to start
  translate([0,4.5]) {
    fillWalls = fillWalls(w, 1);
    fillWall  = fillWall (w, 1);
    fillGap   = fillGap  (w, 1);
    fillGrid  = fillGrid (w, 1);
    color(baseColor) extrude(baseH) rect([w, 1]);
    if (fillWalls > 0) {
      for (i=[0:fillWalls-1]) translate([i*fillGrid, 0]) {
        color(lineColor) extrude(lineH) rect([fWall/2, 1]);
        color(lineColor) extrude(lineH) translate([fillWall-fWall/2, 0]) rect([fWall/2, 1]);
        color(gapColor) extrude(gapH) translate([fillWall, 0]) rect([gap/2, 1]);
        color(gapColor) extrude(gapH) translate([fillGrid-gap/2, 0]) rect([gap/2, 1]);
      }
      for (i=[0:fillWalls-1]) translate([i*fillGrid, 0])
        color(cutColor) extrude(cutH) translate([fillWall, 0]) rect([fillGap, 1]);
    }
    else color(cutColor) extrude(cutH) rect([w, 1]);
  }
  // flush to start and end
  translate([0,6]) {
    fillWalls = fillWalls(w, 2);
    fillWall  = fillWall (w, 2);
    fillGap   = fillGap  (w, 2);
    fillGrid  = fillGrid (w, 2);
    color(baseColor) extrude(baseH) rect([w, 1]);
    if (fillWalls > 0) {
      for (i=[0:fillWalls-1]) translate([i*fillGrid-fillGap, 0]) {
        if (i!=0) color(gapColor) extrude(gapH) rect([gap/2, 1]);
        if (i!=0) color(gapColor) extrude(gapH) translate([fillGap-gap/2, 0]) rect([gap/2, 1]);
        color(lineColor) extrude(lineH) translate([fillGap, 0]) rect([fWall/2, 1]);
        color(lineColor) extrude(lineH) translate([fillGrid-fWall/2, 0]) rect([fWall/2, 1]);
      }
      for (i=[0:fillWalls-1]) translate([i*fillGrid-fillGap, 0])
        if (i!=0) color(cutColor) extrude(cutH) rect([fillGap, 1]);
    }
    else color(cutColor) extrude(cutH) rect([w, 1]);
  }
  echo();
}

// translate([ 0,32,0]) demoFill(fWall*1-gap*1);
// translate([ 0,24,0]) demoFill(fWall*1+gap*0);
// translate([ 0,16,0]) demoFill(fWall*1+gap*1);
// translate([ 0, 8,0]) demoFill(fWall*1+gap*2);
// translate([ 0, 0,0]) demoFill(fWall*1+gap*3);

// translate([ 3,32,0]) demoFill(fWall*2+gap*0);
// translate([ 3,24,0]) demoFill(fWall*2+gap*1);
// translate([ 3,16,0]) demoFill(fWall*2+gap*2);
// translate([ 3, 8,0]) demoFill(fWall*2+gap*3);
// translate([ 3, 0,0]) demoFill(fWall*2+gap*4);

// translate([ 7,32,0]) demoFill(fWall*3+gap*1);
// translate([ 7,24,0]) demoFill(fWall*3+gap*2);
// translate([ 7,16,0]) demoFill(fWall*3+gap*3);
// translate([ 7, 8,0]) demoFill(fWall*3+gap*4);
// translate([ 7, 0,0]) demoFill(fWall*3+gap*5);

// translate([12,32,0]) demoFill(fWall*4+gap*2);
// translate([12,24,0]) demoFill(fWall*4+gap*3);
// translate([12,16,0]) demoFill(fWall*4+gap*4);
// translate([12, 8,0]) demoFill(fWall*4+gap*5);
// translate([12, 0,0]) demoFill(fWall*4+gap*6);



module demoSliceX(r, translate
, flushT=false, flushB=false, flushL=false, flushR=false
, centerX=false, centerY=false
, cutT=false, cutB=false, cutMid=false, cutAlt=false
) difference() {
    // translate([centerX?0:-fudge*sign(r.x), centerY?0:-fudge*sign(r.y)]) rect(r+[fudge2*sign(r.x),fudge2*sign(r.y)], [centerX?0:1,centerY?0:1]);
    rect(r, [centerX?0:1,centerY?0:1]);
    sliceX(r, translate, flushT, flushB, flushL, flushR, centerX, centerY, cutT, cutB, cutMid, cutAlt) children();
  }

module demoSliceY(r, translate
, flushT=false, flushB=false, flushL=false, flushR=false
, centerX=false, centerY=false
, cutL=false, cutR=false, cutMid=false, cutAlt=false
) difference() {
    // translate([centerX?0:-fudge*sign(r.x), centerY?0:-fudge*sign(r.y)]) rect(r+[fudge2*sign(r.x),fudge2*sign(r.y)], [centerX?0:1,centerY?0:1]);
    rect(r, [centerX?0:1,centerY?0:1]);
    sliceY(r, translate, flushT, flushB, flushL, flushR, centerX, centerY, cutL, cutR, cutMid, cutAlt) children();
  }

translate([0, 0, -1]) {
  // demoSliceX([-6, 7], [0,0]
  // , flushT=false, flushB=false, flushL=true, flushR=false
  // , centerX=false, centerY=false
  // , cutT=false, cutB=false, cutMid=false, cutAlt=1
  // ) translate([-2.25, 2]) circle(4);
  // demoSliceY([-6, -7], [0,0]
  // , flushT=true, flushB=false, flushL=false, flushR=false
  // , centerX=false, centerY=true
  // , cutL=false, cutR=false, cutMid=false, cutAlt=1
  // );
}

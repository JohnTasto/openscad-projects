use <nz/nz.scad>

/*
Features
  - store small items securely
    - detents hold drawers closed and prevent pulling drawers out too far
    - frame completely surrounds the drawer opening
    - roof over drawers is flat; nothing for contents to get caught on
    - bins are slightly rounded at the bottom to aid removal of contents with one finger
  - modular
    - both bins and drawers can be rearranged as needs change
    - any bin works in any drawar of the same height that is wide enough for it to fit
      - a bin unit is the distance from the inside of one drawer to the inside of the next
        - i.e., the width of the wall between drawers, including the drawer walls
      - possible drawer sizes (in bin units) include:
        - 2n + 1  =  1,  3,  5,  7,  9, 11, ...   requires very narrow hooks
        - 3n + 2  =  2,  5,  8, 11, 14, 17, ...   most fine grained grid resolution for general purpose
        - 4n + 3  =  3,  7, 11, 15, 19, 23, ...   wider drawers spread out hooks to use less material
  - parametric
    - adjustable line width, layer height, and slop to accommodate various printer setups
    - several available drawer handle styles
    - drawer grid size is configurable to match 25mm or 1" pegboard spacing, etc
  - prints in spiralize/vase mode for easy high quality prints
    - perimeter folds back on itself to fill gaps and increase strength
    - drawer sides are corrugated for added rigidity


TODO

General
  [-] make size overridable
    [-] x
      [x] make stretchable
      [x] make rail depth same regardless of `stretchX`
      [x] make `railW` a constant and calculate `railTop`
      [x] calculate maximum `stretchX`
      [x] adjust back/floor fill
      [x] adjust front corner fills
      [x] option to fill behind hooks
      [ ] calculate `stretchX` from desired `fGridX`
    [-] y
      [ ] calculate `binZ` from desired `fGridY`
  [x] instead of t/b/f/b/l/r, make everything instead take x/y/z/h
    - if they're a single number, center it
    - if it's a list of two numbers, keep current functionality except order should not matter
  [ ] customizer
    - for slopes, use 0-1 sliders and set the slope to 1/ the input
  [x] consider requiring h>1
    - can h=2 be made to stay under 33 tall for ditto printing?  Yes, with 0.4mm line width
Bumps
  [x] parameterize bottom bump width
Frame
  [x] hook snaps
  [x] drawer snaps
  [x] drawer stops
  [x] bottom hook inserts
  [-] improve fills
    [x] bFill
    [x] tSideBase
    [x] lSide
    [x] rSide
    [x] tlSeamFill
    [x] trSeamFill
    [x] tlSide?
    [x] trSide
  [x] thicken top to compensate drawers being layer quantized (only along edges to keep strength)
  [x] mounting holes
  [x] move Y hooks down so horn is taller instead of extra hang on bottom hooks
  [x] make `hook` adjustable per axis
Drawers
  [x] drawers
  [x] wings
  [x] ruffles
  [x] handles
  [x] snaps
Handles
  [x] draw "ellipse" and "tray" handles
    [x] make "ellipse" and "tray" handles double walled?
  [x] draw "rect" handle
Bins
  [x] bins
  [x] make floor full size and square so bins don't roll
Sides
  [x] figure out how to make top side fit over bottom bump
  [-] trim
    [x] make top have room for fill
    [x] reduce top corner radii
    [-] hollow out fills
      [x] draw wall in `bSideBase` to hold trim
      [x] raise `tSideBase` by `bPH` to allow full line widths in trim
    [x] draw trim
    [x] draw snaps
  [ ] add support walls along the edges
Bonus
  [ ] either change `sliceN` API to use `align` or change `rect` and `box` to use `centerN`
  [x] find better solution for adding fudge in `sliceN` functions
  [ ] SLA mode
    - align edges with pixel borders
    - set slop to 1px
    - remove slices
  [ ] change the fill equations so they space lines exactly even when given enough space
    - the exterior space is one `gap` wider than the interior space, since that's how
      it already has to be is when lines are packed at tightly as possible
    - would require reserving the first `gap` worth of `fillResidue` per line for `fillWall`,
      then splitting the remainder evenly. `fillResidueShare` would need to be split in two
*/


peak = 0;  // [0.00:0.05:1.00]
slop = 0;  // [0.00:0.05:1.00]
stretch = 0;  // [0.00:0.05:5.00]
// peak = 0.32;  // [0.00:0.05:1.00]
// slop = 0.11;  // [0.00:0.05:1.00]
// stretch = 0.26;  // [0.00:0.05:5.00]

/* [Main] */
Active_model = "small assembly - h>1";  // [--PRINT--, frame, drawer, bin, side, trim, hook insert,  , --ALIGNMENT--, bump alignment - drawer shut, bump alignment - drawer open, z alignment,  , --LARGE DEMOS--, small assembly, small assembly - h>1, large assembly, large assembly - h>1,  , --SMALL DEMOS--, hooks, perimeter, sides, fills]
// for side and trim
Side = "top";  // [top, top left, left, bottom left, bottom, bottom right, right, top right]
// in bin units
Frame_unit_width = 2;  // [1:1:12]
// in bin units
Frame_unit_depth = 24;  // [2:1:60]
// in frame units, used for frames, drawers, sides, and trim
Frame_width = 4;  // [1:1:8]
// in frame units, used for frames, drawers, bins, sides, and trim
Frame_height = 2;  // [1:1:8]
// in bin units, used only for bins
Bin_width = 2;  // [0:1:16]
// in bin units, used only for bins
Bin_depth = 2;  // [0:1:16]

/* [Demo Settings] */
Show_drawers_in_assembly_demos = false;
Show_trim_in_assembly_demos = false;



/* [Hidden] */

$fn = 24;

// b - bin
// d - drawer
// f - frame

bWall = 0.6;
bWall2 = bWall*2;
bLayerH0 = 0.44;
bLayerHN = 0.28;
bSlopXY = 0.15;
bSlopZ = bLayerHN;
bFloor = bLayerH0 + bLayerHN*3;

dWall = 0.6;
dWall2 = dWall*2;
dLayerH0 = 0.44;
dLayerHN = 0.28;
dSlopXY = 0.25;
dSlopZ = dLayerHN + slop;
dSlop45 = max(0, dSlopZ - dSlopXY);
dFloor = dLayerH0 + dLayerHN*4;

fWall = 0.4;
fWall2 = fWall*2;
fLayerH0 = 0.3;
fLayerHN = 0.2;
fSlopXY = 0.2;
fSlopZBack = -fLayerHN*5/4;   // hook overhang
fSlopZFront = -fLayerHN*3/2;  // hook bumps
fSlopZTrim = -fLayerHN*5/4;   // trim bumps
fFloor = fLayerH0 + fLayerHN*3;
fTop = fLayerHN*3;

fudge  = 0.01;
fudge2 = 0.02;
gap    = 0.03;  // by empirical testing, Cura needs at least a 0.03mm gap to prevent merging parts

function bLayerRelFloor(h) = div(h, bLayerHN)*bLayerHN;
function bLayerAbsFloor(h) = max(0, div(h-bLayerH0, bLayerHN)*bLayerHN + bLayerH0);
function bLayerRelCeil(h) = bLayerRelFloor(h) + (mod(h, bLayerHN)==0 ? 0 : bLayerHN);
function bLayerAbsCeil(h) = bLayerAbsFloor(h) + (mod(h-bLayerH0, bLayerHN)==0 ? 0 : (h<bLayerH0 ? bLayerH0 : bLayerHN));
function bLayerRelRound(h) = let (f=bLayerRelFloor(h), c=bLayerRelCeil(h)) h-f < c-h ? f : c;
function bLayerAbsRound(h) = let (f=bLayerAbsFloor(h), c=bLayerAbsCeil(h)) h-f < c-h ? f : c;

function dLayerRelFloor(h) = div(h, dLayerHN)*dLayerHN;
function dLayerAbsFloor(h) = max(0, div(h-dLayerH0, dLayerHN)*dLayerHN + dLayerH0);
function dLayerRelCeil(h) = dLayerRelFloor(h) + (mod(h, dLayerHN)==0 ? 0 : dLayerHN);
function dLayerAbsCeil(h) = dLayerAbsFloor(h) + (mod(h-dLayerH0, dLayerHN)==0 ? 0 : (h<dLayerH0 ? dLayerH0 : dLayerHN));
function dLayerRelRound(h) = let (f=dLayerRelFloor(h), c=dLayerRelCeil(h)) h-f < c-h ? f : c;
function dLayerAbsRound(h) = let (f=dLayerAbsFloor(h), c=dLayerAbsCeil(h)) h-f < c-h ? f : c;

function fLayerRelFloor(h) = div(h, fLayerHN)*fLayerHN;
function fLayerAbsFloor(h) = max(0, div(h-fLayerH0, fLayerHN)*fLayerHN + fLayerH0);
function fLayerRelCeil(h) = fLayerRelFloor(h) + (mod(h, fLayerHN)==0 ? 0 : fLayerHN);
function fLayerAbsCeil(h) = fLayerAbsFloor(h) + (mod(h-fLayerH0, fLayerHN)==0 ? 0 : (h<fLayerH0 ? fLayerH0 : fLayerHN));
function fLayerRelRound(h) = let (f=fLayerRelFloor(h), c=fLayerRelCeil(h)) h-f < c-h ? f : c;
function fLayerAbsRound(h) = let (f=fLayerAbsFloor(h), c=fLayerAbsCeil(h)) h-f < c-h ? f : c;

// l - lock
lPH = peak;//0.75;//1.5;            // peak height
lPC = max(0, lPH-fSlopXY*2);  // peak extra clearance (in addition to normal slop)
lWS = 0;//.28;//fWall/2;        // wall seperation (makes the latch a bit more springy)
lLL = fLayerHN*2;           // latch length (at peak)
lSL = fLayerHN*8;           // strike length (at peak)
lRL = fLayerHN*48;          // ramp length
lIL = fTop;                 // inset length

// s - snap
sPH = fSlopXY*7/4;             // peak height
sPL = fLayerHN*2;              // peak length
sLL = fLayerRelCeil(sPH*3/2);  // latch length
sRL = fLayerRelCeil(sPH*6);    // ramp length
sFI = 0;                       // front inset length
sBI = 0;                       // back inset length

stretchX = stretch;
fillStretch = true;

hookLR = 1.25;
hookTB = 2.5;
claspW = fWall2*2 + fSlopXY + lPH + lPC + lWS;
claspD = fWall2*2 + fSlopXY + sPH;
hookD = claspD + fSlopXY;

bins = [Frame_unit_width, Frame_unit_depth];

bGridXY = fWall2*2 + claspD + stretchX + fSlopXY*2 + dWall*2 + dSlopXY*2;
binXY = bGridXY - bSlopXY*2;
binZ = bLayerAbsFloor(10);
binR = binXY;

echo(str("Bin grid spacing: ", bGridXY, " X&Y"));

drawerX = bGridXY*bins.x + dWall*2;
drawerY = bGridXY*bins.y + dWall*2;
drawerZ = dLayerRelCeil(binZ + bSlopZ) + dFloor;

fGridX = bGridXY*(bins.x+1);
fGridY = fWall2 + hookD + drawerZ + dSlopZ*2;

echo(str("Drawer grid spacing: ", fGridX, " X, ", fGridY, " Z"));


handleElliptical = false;
handleReach = 15;
handleLip = 5;
handleR = 5;  // only applies to "rectangle" handle
handleTray = false;


// O - outer
// I - inner
fWallGrid = fWall2 + fSlopXY;
fWall4 = fWallGrid + fWall2;

fHornY = fGridY/2 - fSlopXY/2;
fTopOY = fHornY - claspD + fWall2;
fTopIY = fTopOY - fWall2;
fBotIY = -fHornY + claspD - fWallGrid;
fSideOX = fGridX/2 - claspD/2 - stretchX/2 - fSlopXY;
fSideIX = fSideOX - fWall2;
fBulgeOX = fGridX/2 - fSlopXY/2;
fBulgeIX = fBulgeOX - fWall2;
fBulgeOY = fHornY - claspW - hookLR - fSlopXY;
fBulgeIY = fBulgeOY - fWall2;
fBulgeWall = fBulgeOX - fSideOX;
fTHookY = fTopOY;
fBHookY = -fHornY + fWallGrid;

fGridZIdeal = fFloor + fBulgeWall + drawerY + gap;  // gap is from behind the drawer face
fGridZ = fLayerAbsCeil(fGridZIdeal);
fGridZError = fGridZ - (fGridZIdeal);


mountingHoleD = 4;  // set to 0 to disable


railD = fBulgeWall/2 - stretchX/4;

dFS = 1;                // drawer front slope
dBS = 4;                // drawer back slope
cRS = 8;                // catch ramp slope
hRS = 6;                // hold ramp slope
kRS = 1;                // keep ramp slope
bRS = 1;                // bottom ramp slope

// drawer
dPH = railD;            // drawer peak height
dPL = fLayerHN*2;       // drawer peak length
dFL = dPH*dFS;          // drawer front length
dBL = dPH*dBS;          // drawer back length

// catch: back, holds drawer shut
cPH = railD*3/4;        // catch peak height
cPL = fLayerHN*2;       // catch peak length
cFL = cPH*cRS;          // catch front length
cBL = cPH*dFS;          // catch back length
cIL = 0;                // catch inset length
cCH = dSlopXY;          // catch cushion height

// hold: front, holds drawer open
hPH = railD;            // hold peak height
hPL = fLayerHN*2;       // hold peak length
hFL = hPH*dBS;          // hold front length
hBL = hPH*hRS;          // hold back length
hIL = 0;                // hold inset length

// keep: front, holds drawer in
kPH = railD*9/8;        // keep peak height
kPL = fLayerHN*3/2;     // keep peak length
kFL = kPH*kRS;          // keep front length
kBL = kPH*dFS;          // keep back length
kIL = fLayerHN/2;       // keep inset length

// bottom: bottom, holds drawer in
bPH = dLayerH0 + dLayerHN*3/2;  // bottom peak height  (never as tall as it should be due to filament dragging)
bSH = dLayerH0 + dLayerHN;      // bottom slot height
bPL = fLayerHN*5/2;             // bottom peak length
bFL = bPH*bRS;                  // bottom front length
bBL = bPH*bRS;                  // bottom back length
bIL = fLayerHN/2;               // bottom inset length
bW  = fWall4;                   // bottom width

peakWN = 1.5;  // bump peak width for h>1
// calculate the steepest peak underhang at 45° (but how?)
railWN = peakWN + max(dPH*2, cPH*2-railD*2+dSlop45*2, hPH*2-railD*2+dSlop45*2, kPH*2-railD*2+dSlop45*2);

stopLinesH0 = 2;
stopLinesHN = 3;


peakW1 = peakWN - (fWall2 + gap)*stopLinesH0
       + dLayerAbsFloor(fGridY - claspW - hookLR - fWallGrid*2 - dSlopZ*2)
       - (fGridY - claspW - hookLR - fWallGrid*2 - dSlopZ*2);

echo(str("peakW1=", peakW1, (peakW1<0 ? ". Drawer h=1 is not recommended." : ".")));

bulgeH = fBulgeIY*2 - dSlop45*2 - fBulgeWall*2
       - railWN - railD*2;

echo(str(bulgeH, " rail clearance.", (bulgeH<0 ? " Parts are degenerate." : "")));


fDrawerLayerCompLines = 2;  // thicker drawer roof along edges to compensate for drawer height layer quantization


dFloat = dSlopXY/2;  // how far a fully closed drawer still sticks out due to rough mating surfaces
dFaceD = dWall2 + dFloat;  // how far the sides must extend to be flush with the drawer faces

cInset = cIL + dBL + dPL - (railD+dSlopXY-dPH)*dFS + dFloat + fFloor + fGridZError;  // back catch bump
dInset = kIL + kFL + kPL - (railD+dSlopXY-kPH)*dFS + dFloat - gap;                   // front drawer bump
hInset = hIL + dFL + dPL - (railD+dSlopXY-dPH)*dBS + dInset + gap - dFloat;          // front hold bump
kInset = kIL;                                                                        // front keep bump

dTravel = drawerY + fBulgeWall - dInset - dFL - dPL - dBL;


// t - trim
tPH = fSlopXY*7/4;             // peak height (set to 0 to disable trim - affects top sides some)
tPL = fLayerHN*2;              // peak length
tLL = fLayerRelCeil(tPH*3/2);  // latch length
tRL = fLayerRelCeil(tPH*6);    // ramp length
tIL = 0;                       // inset length

tLip = 2;  // extra trim thickness around front rim - important for giving trim pieces extra strength
tFloat = fSlopXY/2;  // how far the trim is expected to stick out due to rough mating surfaces
tFloor = fLayerAbsFloor(dFaceD - tFloat + tLip);
tInsert = tPH > 0 ? fLayerRelCeil(tFloat + fSlopZTrim + tIL + tRL + tPL*2 + tLL*2) : 0;
trimZ = tFloor + tInsert;
tClearance = (tPH > 0 ? fWallGrid : 0) + bPH;

fSideZ = fLayerAbsCeil(fGridZ + dFaceD + tLip);

drawerYFrameZAlign = fFloor + fGridZError + dFloat + fBulgeWall + drawerY/2;
drawerZFrameYAlign = fWall2 + dSlopZ - fHornY;


///////////
// HOOKS //
///////////


// dir      - the direction of the hook - should be -1 or 1
// stem     - the height above the origin of the stem
// hang     - how far below the origin to sink the stem into whatever its growing out of
// overlap  - how far past the stem the hook overlaps the floor of the adjacent piece (negative if the stem overlaps)
// stop     - width of the backstop - if set, indicates hook is a strike plate, otherwise its a latch
module hook(dir, hook, stem, hang=fudge, overlap=fSlopXY-fSlopZBack, stop=undef) render() translate([-dir*(claspW+hook)/2, stem]) {
  hookZ = max(0, fFloor-overlap);
  hangZ = max(0, fFloor-overlap-hang-stem);
  bumpZ = fLayerAbsCeil(hookZ + hook);
  // strike stem
  if (is_num(stop)) {
    scale([dir, 1]) rotate([90,0,0]) {
      // strike plate
      extrude(hang+stem) polygon(
      [ [         0, fGridZ                      ]
      , [fWall2    , fGridZ                      ]
      , [fWall2    , fGridZ-lIL                  ]
      , [fWall2+lPH, fGridZ-lIL-lRL              ]
      , [fWall2+lPH, fGridZ-lIL-lRL-lSL+lPH      ]
      , [fWall2    , fGridZ-lIL-lRL-lSL          ]
      , [fWall2    , fGridZ-lIL-lRL-lSL-lLL      ]
      , [fWall2+lPH, fGridZ-lIL-lRL-lSL-lLL-lRL/2]
      , [fWall2+lPH,                            0]
      , [         0,                            0]
      ]);
      // backstop
      translate([claspW+hook+fWallGrid, 0, claspD]) extrude(fSlopXY-stop) polygon(
      [ [          0, fGridZ                    ]
      , [-fWall2-lPC, fGridZ                    ]
      , [-fWall2-lPC, fGridZ-lIL                ]
      , [-fWall2    , fGridZ-lIL-lRL            ]
      , [-fWall2    , fGridZ-lIL-lRL-lSL-lLL    ]
      , [-fWall2-lPC, fGridZ-lIL-lRL-lSL-lLL-lRL]
      , [-fWall2-lPC,                          0]
      , [          0,                          0]
      ]);
    }
    // 90° strike plate
    translate([0, 0, fGridZ-lIL-lRL-lSL+fSlopZFront]) rotate([180,270,0]) extrude((lPH+fWall2)*dir) polygon(
    [ [ lSL-fSlopZFront,               0]
    , [   fWall2-claspD,               0]
    , [        fWall2/2, claspD-fWall2/2]
    , [claspD-stem-hang, stem+hang      ]
    , [ lSL-fSlopZFront, stem+hang      ]
    ]);
  }
  // latch stem (trimmed)
  else rotate([180,270,0]) extrude((fWall2+lWS)*dir) polygon(
  [ [(overlap+stem)<stem?hookZ:0,                                   0]
  , [(overlap+stem)<stem?hangZ:0, min(hang, fFloor-overlap-stem)+stem]
  , [(overlap+stem)<stem?hangZ:0,                           hang+stem]
  , [                   fGridZ  ,                           hang+stem]
  , [                   fGridZ  ,                                   0]
  ]);
  // hook
  translate([stop?0:dir*lWS, 0, 0]) difference() {
    rotate([180,270,0]) extrude((hook+lPH+fWall2)*dir)
      if (stop) polygon(
      [ [         0                                         , 0         ]
      , [         0                                         , fWall2    ]
      , [max(     0,  bumpZ+fSlopZFront+sBI    +sPL  +sLL  ), fWall2    ]
      , [max(     0,  bumpZ+fSlopZFront+sBI    +sPL  +sLL*2), fWall2+sPH]
      , [max(     0,  bumpZ+fSlopZFront+sBI    +sPL*2+sLL*2), fWall2+sPH]
      , [max(     0,  bumpZ+fSlopZFront+sBI+sRL+sPL*2+sLL*2), fWall2    ]
      , [min(fGridZ, fGridZ            -sFI-sRL-sPL  -sLL  ), fWall2    ]
      , [min(fGridZ, fGridZ            -sFI-sRL-sPL        ), fWall2+sPH]
      , [min(fGridZ, fGridZ            -sFI-sRL            ), fWall2+sPH]
      , [min(fGridZ, fGridZ            -sFI                ), fWall2    ]
      , [    fGridZ                                         , fWall2    ]
      , [    fGridZ                                         , 0         ]
      ]);
      else polygon(
      [ [     hookZ                                         , 0         ]
      , [     hookZ                                         , fWall2    ]
      , [max( hookZ,  bumpZ            +sBI                ), fWall2    ]
      , [max( hookZ,  bumpZ            +sBI          +sLL  ), fWall2+sPH]
      , [max( hookZ,  bumpZ            +sBI    +sPL  +sLL  ), fWall2+sPH]
      , [max( hookZ,  bumpZ            +sBI    +sPL  +sLL*2), fWall2    ]
      , [min(fGridZ, fGridZ-fSlopZFront-sFI-sRL-sPL*2-sLL*2), fWall2    ]
      , [min(fGridZ, fGridZ-fSlopZFront-sFI-sRL-sPL*2-sLL  ), fWall2+sPH]
      , [min(fGridZ, fGridZ-fSlopZFront-sFI-sRL-sPL  -sLL  ), fWall2+sPH]
      , [min(fGridZ, fGridZ-fSlopZFront-sFI-sRL-sPL        ), fWall2    ]
      , [    fGridZ                                         , fWall2    ]
      , [    fGridZ                                         , 0         ]
      ]);
    // latch mask
    if (!stop) translate([fWall2*dir, fudge, 0]) rotate([90,0,0]) extrude(sPH+fWall2+fudge) scale([dir, 1]) polygon(
    [ [hook+lPH+fudge, fGridZ+fudge                ]
    , [hook          , fGridZ+fudge                ]
    , [hook          , fGridZ-lIL-lRL-lSL          ]
    , [hook+lPH      , fGridZ-lIL-lRL-lSL          ]
    , [hook+lPH      , fGridZ-lIL-lRL-lSL-lLL      ]
    , [hook          , fGridZ-lIL-lRL-lSL-lLL-lRL/2]
    , [hook          ,  hookZ+hook                 ]
    , [        -fudge,  hookZ-fudge                ]
    , [hook+lPH+fudge,  hookZ-fudge                ]
    ]);
  }
}


module tHooks(drawHooks=true) flipX() translate([fSideIX-fSlopXY-claspW/2-hookTB/2, fTHookY, 0]) {
  translate([-claspW/2-hookTB/2, hookD, fGridZ-bIL-bFL]) hull() {
    translate([0, 0, bFL]) box([bW, -fudge, -bFL-bPL-bBL]);
    box([bW, bPH, -bPL]);
  };
  if (drawHooks) hook(1, hookTB, hookD, stop=claspD-fWall2);
}
module bHooks() rotate(180) flipX() translate([fSideIX-fSlopXY-claspW/2-hookTB/2-lPC, -fBHookY, 0]) hook(-1, hookTB, hookD,            hang=tClearance+fudge);
module lHooks() rotate( 90) flipX() translate([         fHornY-claspW/2-hookLR/2+lPC,  fSideOX, 0]) hook( 1, hookLR, hookD+stretchX/2);
module rHooks() rotate(270) flipX() translate([         fHornY-claspW/2-hookLR/2    ,  fSideOX, 0]) hook(-1, hookLR, hookD+stretchX/2, stop=claspD/2+fSlopXY/2);

module blHook() rotate(180) translate([ fSideIX-fSlopXY-claspW/2-hookTB/2-lPC, -fBHookY+fSlopXY, 0]) hook(-1, hookTB, hookD-fSlopXY, hang=0);
module brHook() rotate(180) translate([-fSideIX+fSlopXY+claspW/2+hookTB/2+lPC, -fBHookY+fSlopXY, 0]) hook( 1, hookTB, hookD-fSlopXY, hang=0);



//////////////////
// FILL HELPERS //
//////////////////


function fillAdjusted    (w, flushSides)        = abs(w) + (flushSides-1)*gap;
function fillWalls       (w, flushSides, wall2) = div(fillAdjusted(w, flushSides)+fudge, wall2+gap);  // `fudge` compensates for some FP precision errors
function fillResidue     (w, flushSides, wall2) = max(0, fillAdjusted(w, flushSides) - fillWalls(w, flushSides, wall2)*(wall2+gap));  // ditto for `max(0, ...)`
function fillResidueShare(w, flushSides, wall2) = fillResidue(w, flushSides, wall2) / (fillWalls(w, flushSides, wall2)*2 - flushSides + 1);
function fillGrid        (w, flushSides, wall2) = fillResidueShare(w, flushSides, wall2)*2 + wall2 + gap;
function fillWall        (w, flushSides, wall2) = fillResidueShare(w, flushSides, wall2) + wall2;
function fillGap         (w, flushSides, wall2) = fillResidueShare(w, flushSides, wall2) + gap;


module sliceX(size, translate=[0,0]
, flushT=false, flushB=false, flushL=false, flushR=false
, centerX=false, centerY=false
, cutT=false, cutB=false, cutMid=false, cutAlt=false
, wall2=fWall2
) {
  x = abs(size.x);
  y = abs(size.y);
  flushSides = (flushL?1:0) + (flushR?1:0);
  flushEnds  = (flushT?1:0) + (flushB?1:0);
  flushEndOffset = (flushT?fudge/2:0) - (flushB?fudge/2:0);
  fillWalls = fillWalls(x, flushSides, wall2);
  fillGrid  = fillGrid (x, flushSides, wall2);
  fillWall  = fillWall (x, flushSides, wall2);
  fillGap   = fillGap  (x, flushSides, wall2);
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
    if (fillWalls>0) {
      if (cutMid) translate([flushL?-fudge:0, 0]) rect([x+fudge*flushSides, gap], [1,0]);
      for (i=[0:fillWalls-1]) {
        itx = fillGrid*i - (flushL ? fillGap : 0);
        if (i>0) translate([itx, flushEndOffset]) rect([fillGap, y+fudge*flushEnds], [1,0]);
        if (cutT || cutB || cutAlt || is_num(cutAlt)) intersection() {
          translate([itx, flushEndOffset]) rect([fillWall+fillGap*2, y+fudge*flushEnds], [1,0]);  // one wall + both gaps
          if (cutT) { antiChildren(-1)
            if ($children>0) children();
            else translate(translate.x-tx, translate.y-ty) rect(size*4, [0,0]);
          }
          if (cutB) { antiChildren(1)
            if ($children>0) children();
            else translate(translate.x-tx, translate.y-ty) rect(size*4, [0,0]);
          }
          if (cutAlt || is_num(cutAlt)) { antiChildren((mod(i+(is_num(cutAlt)?cutAlt:0), 2)*2-1))
            if ($children>0) children();
            else translate(translate.x-tx, translate.y-ty) rect(size*4, [0,0]);
          }
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
, wall2=fWall2
) rotate(90) sliceX([size.y, -size.x], [translate.y, -translate.x]
  , flushT=flushL, flushB=flushR, flushL=flushB, flushR=flushT
  , centerX=centerY, centerY=centerX
  , cutT=cutL, cutB=cutR, cutMid=cutMid, cutAlt=cutAlt
  , wall2=wall2
  ) if ($children>0) rotate(-90) children();
    else translate(translate.y, -translate.x) rect([size.y*4, -size.x*4], [0,0]);

module eSliceX(h, size, translate=[0,0]
, flushT=false, flushB=false, flushL=false, flushR=false
, centerX=false, centerY=false, centerZ=false
, cutT=false, cutB=false, cutMid=false, cutAlt=false
, wall2=fWall2, layerH=fLayerHN, hFudge=0
) translate([0, 0, (centerZ?-h/2:0)+(h<0?h:0)])
    if ((cutAlt || is_num(cutAlt)) && (abs(h)>=layerH)) for (i=[0:abs(h)/layerH-1]) {
      translate([0, 0, layerH*i]) extrude(layerH+(epsilon_equals(i, abs(h)/layerH-1)?abs(hFudge):0)) sliceX(size, translate
      , flushT=flushT, flushB=flushB, flushL=flushL, flushR=flushR
      , centerX=centerX, centerY=centerY
      , cutT=cutT, cutB=cutB, cutMid=cutMid, cutAlt=mod(i+(is_num(cutAlt)?cutAlt:0), 2)
      , wall2=wall2
      ) if ($children>0) children();
        else translate(translate) rect(size*4, [0,0]);
    }
    // else extrude(abs(h)+fudge) sliceX(size, translate
    else extrude(abs(h)+abs(hFudge)) sliceX(size, translate
      , flushT=flushT, flushB=flushB, flushL=flushL, flushR=flushR
      , centerX=centerX, centerY=centerY
      , cutT=cutT, cutB=cutB, cutMid=cutMid
      , wall2=wall2
      ) translate(translate) rect(size*4, [0,0]);

module eSliceY(h, size, translate=[0,0]
, flushT=false, flushB=false, flushL=false, flushR=false
, centerX=false, centerY=false, centerZ=false
, cutL=false, cutR=false, cutMid=false, cutAlt=false
, wall2=fWall2, layerH=fLayerHN, hFudge=0
) translate([0, 0, (centerZ?-h/2:0)+(h<0?h:0)])
    if ((cutAlt || is_num(cutAlt)) && (abs(h)>=layerH)) for (i=[0:abs(h)/layerH-1]) {
      translate([0, 0, layerH*i]) extrude(layerH+(epsilon_equals(i, abs(h)/layerH-1)?abs(hFudge):0)) sliceY(size, translate
      , flushT=flushT, flushB=flushB, flushL=flushL, flushR=flushR
      , centerX=centerX, centerY=centerY
      , cutL=cutL, cutR=cutR, cutMid=cutMid, cutAlt=mod(i+(is_num(cutAlt)?cutAlt:0), 2)
      , wall2=wall2
      ) if ($children>0) children();
        else translate(translate) rect(size*4, [0,0]);
    }
    // else extrude(abs(h)+fudge) sliceY(size, translate
    else extrude(abs(h)+abs(hFudge)) sliceY(size, translate
      , flushT=flushT, flushB=flushB, flushL=flushL, flushR=flushR
      , centerX=centerX, centerY=centerY
      , cutL=cutL, cutR=cutR, cutMid=cutMid
      , wall2=wall2
      ) translate(translate) rect(size*4, [0,0]);

module eSlice(h, size, translate=[0,0]
, flushT=false, flushB=false, flushL=false, flushR=false
, centerX=false, centerY=false, centerZ=false
, cutT=false, cutB=false, cutL=false, cutR=false
, cutMidX=false, cutMidY=false, cutAltX=false, cutAltY=false
, wall2=fWall2, layerH=fLayerHN, hFudge=0
) if (fillResidueShare(size.x, (flushL?1:0)+(flushR?1:0), wall2) < fillResidueShare(size.y, (flushT?1:0)+(flushB?1:0), wall2)) {
    eSliceX(h, size, translate
    , flushT=flushT, flushB=flushB, flushL=flushL, flushR=flushR
    , centerX=centerX, centerY=centerY, centerZ=centerZ
    , cutT=cutT, cutB=cutB, cutMid=cutMidX, cutAlt=cutAltX
    , layerH=layerH, hFudge=hFudge
    , wall2=wall2
    ) if ($children>0) children();
      else translate(translate) rect(size*4, [0,0]);
  }
  else {
    eSliceY(h, size, translate
    , flushT=flushT, flushB=flushB, flushL=flushL, flushR=flushR
    , centerX=centerX, centerY=centerY, centerZ=centerZ
    , cutL=cutL, cutR=cutR, cutMid=cutMidY, cutAlt=cutAltY
    , layerH=layerH, hFudge=hFudge
    , wall2=wall2
    ) if ($children>0) children();
      else translate(translate) rect(size*4, [0,0]);
  }



///////////
// FILLS //
///////////


module tlSeamFill(l) translate([fGridX*l-fBulgeOX, -fHornY+tClearance+fWall4, 0]) {
  rB = [fBulgeWall+fWall4+lPC+lWS, -tClearance-fWall4];
  rL = rB - [fWall2+lWS, -fWall2];
  extrude(fFloor) rect(rB);
  translate([0, 0, fGridZ-fTop]) difference() {
    hull() {
      extrude(fTop) rect(rB);
      extrude(rL.y) rect([rB.x, -fWall2]);
    }
    translate([0, -fWall2, 0]) {
      eSliceX(rL.y, rL, flushL=true);
      eSliceX(fTop, [rL.x, rL.y+fWall2], flushL=true, cutAlt=true, hFudge=fudge);
    }
  }
}

module trSeamFill(r) translate([fGridX*r+fBulgeOX, -fHornY+tClearance+fWall4, 0]) {
  rB = [-fBulgeWall-fWall4-lPC-lWS, -tClearance-fWall4];
  rL = rB - [-fWall2-lWS, -fWall2];
  extrude(fFloor) rect(rB);
  translate([0, 0, fGridZ-fTop]) difference() {
    hull() {
      extrude(fTop) rect(rB);
      extrude(rL.y) rect([rB.x, -fWall2]);
    }
    translate([0, -fWall2, 0]) {
      eSliceX(rL.y, rL, flushR=true);
      eSliceX(fTop, [rL.x, rL.y+fWall2], flushR=true, cutAlt=true, hFudge=fudge);
    }
  }
}

module bFill(wall=0) translate([0, fHornY-claspD, 0]) {
  rB = [fSideOX*2-claspW*2-hookTB*2-fSlopXY*2, hookD+fWall2];
  rL = rB - [fWall2*2, fWall2];
  // #extrude(fFloor) rect(rB, [0,1]);
  translate([0, 0, fGridZ-wall-fTop]) difference() {
    union() {
      hull() {
        extrude(fTop) rect(rB, [0,1]);
        extrude(-rL.y) rect([rB.x, fWall2], [0,1]);
      }
      translate([0, rB.y, 0]) extrude(fTop+wall) rect([rB.x, -fWall2], [0,1]);
    }
    translate([0, fWall2, 0]) {
      eSliceX(-rL.y, rL, centerX=true);
      eSliceX(fTop, [rL.x, rL.y-fWall2], centerX=true, cutAlt=true, hFudge=fudge);
      eSliceY(fTop+wall, [rL.x, fWall2], translate=[0, rL.y-fWall2], flushT=true, flushB=true, centerX=true, cutAlt=true, hFudge=fudge);
    }
  }
}

module bSeamFill() translate([fGridX/2, fHornY-claspD, 0]) {
  rB = [claspD+stretchX+fWallGrid*2, claspD];
  rL = rB - [fWall2*2, fWall2];
  extrude(fFloor) rect(rB+[lPC*2, 0], [0,1]);
  translate([0, 0, fGridZ-fTop]) difference() {
    hull() {
      extrude(fTop) rect(rB, [0,1]);
      extrude(-rL.y) rect([rB.x, fWall2], [0,1]);
    }
    translate([0, fWall2, 0]) {
      eSliceX(-rL.y, rL, centerX=true);
      eSliceY(fTop, rL, flushT=true, centerX=true, cutAlt=true, hFudge=fudge);
    }
  }
}

module blSeamFill(l) translate([fGridX*l-fBulgeOX, fHornY-claspD, 0]) {
  rB = [fBulgeWall+fWall2, claspD];
  rL = rB - [fWall2, fWall2];
  extrude(fFloor) rect(rB+[lPC, 0]);
  translate([0, 0, fGridZ-fTop]) difference() {
    hull() {
      extrude(fTop) rect(rB);
      extrude(-rL.y) rect([rB.x, fWall2]);
    }
    translate([0, fWall2, 0]) {
      eSliceX(-rL.y, rL, flushL=true);
      eSliceY(fTop, rL, flushT=true, flushL=true, hFudge=fudge);
    }
  }
}

module brSeamFill(r) translate([fGridX*r+fBulgeOX, fHornY-claspD, 0]) {
  rB = [-fBulgeWall-fWall2, claspD];
  rL = rB - [-fWall2, fWall2];
  extrude(fFloor) rect(rB-[lPC, 0]);
  translate([0, 0, fGridZ-fTop]) difference() {
    hull() {
      extrude(fTop) rect(rB);
      extrude(-rL.y) rect([rB.x, fWall2]);
    }
    translate([0, fWall2, 0]) {
      eSliceX(-rL.y, rL, flushR=true);
      eSliceY(fTop, rL, flushT=true, flushR=true, hFudge=fudge);
    }
  }
}

module rHookFill() {
  rB = [fWall2+stretchX/2, claspW+hookLR-lPH];
  rL = rB - [fWall2, fWall2];
  flipY() translate([fSideIX, fBulgeIY, 0]) difference() {
    extrude(fGridZ) rect(rB);
    translate([fWall2, fWall2, fFloor]) eSliceY(fGridZ-fFloor, rL, flushT=true, flushR=true, hFudge=fudge);
  }
}

module ltHookFill(t) {
  rB = [-fWall2-stretchX/2, -hookLR-fWall2-lPH];
  rL = rB - [-fWall2, 0];
  translate([-fSideIX, fGridY*t+fHornY, 0]) difference() {
    extrude(fGridZ) rect(rB);
    translate([-fWall2, 0, fFloor]) eSliceY(fGridZ-fFloor, rL, flushT=true, flushB=true, flushL=true, hFudge=fudge);
  }
}

module lbHookFill(b) {
  rB = [-fWall2-stretchX/2, hookLR+fWall2+lPH];
  rL = rB - [-fWall2, 0];
  translate([-fSideIX, fGridY*b-fHornY, 0]) difference() {
    extrude(fGridZ) rect(rB);
    translate([-fWall2, 0, fFloor]) eSliceY(fGridZ-fFloor, rL, flushT=true, flushB=true, flushL=true, hFudge=fudge);
  }
}

module lHookFill() {
  rB = [-fWall2-stretchX/2, hookLR*2+fWall2*2+lPH*2+fSlopXY];
  rL = rB - [-fWall2, 0];
  translate([-fSideIX, fGridY/2, 0]) difference() {
    extrude(fGridZ) rect(rB, [1,0]);
    translate([-fWall2, 0, fFloor]) eSliceY(fGridZ-fFloor, rL, flushT=true, flushB=true, flushL=true, centerY=true, hFudge=fudge);
  }
}



///////////
// SIDES //
///////////


// BUMPS

module sideBumps(size) rotate([-90,0,0]) flipX() translate([size.x/2, -fGridZ, 0]) extrude(size.y) polygon(
  [ [fudge,        0               ]
  , [    0,        0               ]
  , [    0, max(0, tIL            )]
  , [ -tPH, max(0, tIL+tRL        )]
  , [ -tPH, max(0, tIL+tRL+tPL    )]
  , [    0, max(0, tIL+tRL+tPL+tLL)]
  , [    0,        tInsert         ]
  , [fudge,        tInsert         ]
  ]);

module trimBumps(size) rotate([-90,0,0]) flipX() translate([size.x/2, tFloor, 0]) extrude(size.y) polygon(
  [ [-fudge,        0                                      ]
  , [     0,        0                                      ]
  , [     0, max(0, tFloat+fSlopZTrim+tIL+tRL+tPL         )]
  , [   tPH, max(0, tFloat+fSlopZTrim+tIL+tRL+tPL  +tLL   )]
  , [   tPH, max(0, tFloat+fSlopZTrim+tIL+tRL+tPL*2+tLL   )]
  , [     0, max(0, tFloat+fSlopZTrim+tIL+tRL+tPL*2+tLL*2 )]
  , [     0,        tInsert                                ]
  , [-fudge,        tInsert                                ]
  ]);


// COMPONENTS

module tSideBase(l, r) for (i=[l:r]) translate([fGridX*i, 0, 0]) {
  bHooks();
  // between bottom bumps
  translate([0, -fHornY+tClearance+fWall4, fGridZ-tInsert-fTop]) {
    rB = [fSideOX*2-fSlopXY*4-claspW*2-hookTB*2-fWall2*2, -fWall2-tClearance];
    rL = rB - [0, -fWall2];
    difference() {
      hull() {
        extrude(fTop) rect(rB, [0,1]);
        extrude(rL.y) rect([rB.x, -fWall2], [0,1]);
      }
      translate([0, -fWall2, rL.y]) eSliceX(fTop-rL.y, rL, flushB=true, flushL=true, flushR=true, centerX=true, hFudge=fudge);
    }
  }
  // beside bottom bumps
  flipX() translate([fSideOX-claspW-hookTB, -fHornY+tClearance+fWall4, fGridZ-tInsert-fTop]) {
    rB = [fWall2+hookTB+lPH, -fWall2-tClearance];
    rL = rB - [fWall2, -fWall2];
    difference() {
      hull() {
        extrude(fTop) rect(rB);
        extrude(rL.y) rect([rB.x, -fWall2]);
      }
      translate([0, -fWall2, rL.y]) eSliceX(fTop-rL.y, rL, flushB=true, flushL=true, hFudge=fudge);
    }
  }
  if (tPH>0) translate([0, -fHornY+tClearance+fWall4, 0]) sideBumps([fSideOX*2-claspW*2+lPH*2, -fWall2-tClearance]);
  // seam
  if (i<r) translate([fGridX/2, -fHornY+tClearance+fWall4, 0]) {
    rB = [claspD+stretchX+fWall4*2+fSlopXY*2+lPC*2+lWS*2, -tClearance-fWall4];
    rL = rB - [fWall2*2+lWS*2, -fWall2];
    extrude(fFloor) rect(rB, [0,1]);
    translate([0, 0, fGridZ-fTop]) difference() {
      hull() {
        extrude(fTop) rect(rB, [0,1]);
        extrude(rL.y) rect([rB.x, -fWall2], [0,1]);
      }
      translate([0, -fWall2, 0]) {
        eSliceX(rL.y, rL, centerX=true);
        eSliceX(fTop, [rL.x, rL.y+fWall2], centerX=true, cutAlt=true, hFudge=fudge);
        eSliceY(fTop, [rL.x, -fWall2], translate=[0, rL.y+fWall2], flushT=true, flushB=true, centerX=true, cutAlt=true, hFudge=fudge);
      }
    }
  }
}

module bSideBase(l, r) for (i=[l:r]) translate([fGridX*i, 0, 0]) {
  extrude(fFloor) translate([0, fHornY-claspD]) rect([fSideOX*2-fWallGrid*4-lPC*2-lWS*2, claspD+fWallGrid+bPH], [0,1]);
  extrude(fGridZ) flipX() translate([fGridX/2-claspD/2-stretchX/2-fSlopXY, fGridY/2-fSlopXY/2]) rect([-fWall2, -claspD]);
  tHooks();
  if (i<r) bSeamFill();
  bFill(tInsert);
  if (tPH>0) translate([0, fHornY-claspD, 0]) rotate(180) sideBumps([fSideOX*2-claspW*2-hookTB*2-fSlopXY*2-fWall2*2, gap-hookD]);
}


// SIDES

module tSide(x=1, z=[0], trim=false) {
  if (trim && tPH>0) tTrim(x, z, print=false);
  assert(is_num(x) || is_list(x) && len(x)==2);
  assert(             is_list(z) && len(z)==1);
  l = is_list(x) ? min(x[0], x[1]) : -(abs(x)-1)/2;
  r = is_list(x) ? max(x[0], x[1]) :  (abs(x)-1)/2;
  y = z[0];
  if (l<=r) translate([0, fGridY*(y+1), 0]) {
    if (tPH>0) extrude(fFloor) translate([fGridX*l-fBulgeOX, fBHookY+bPH]) rect([fGridX*(r-l)+fBulgeOX*2, tClearance-bPH+fWall2]);
    extrude(fSideZ) translate([fGridX*l-fBulgeOX, fBHookY+tClearance]) rect([fGridX*(r-l)+fBulgeOX*2, fWall2]);
    tlSeamFill(l);
    trSeamFill(r);
    tSideBase(l, r);
  }
}

module bSide(x=1, z=[0], trim=false) {
  if (trim && tPH>0) bTrim(x, z, print=false);
  assert(is_num(x) || is_list(x) && len(x)==2);
  assert(             is_list(z) && len(z)==1);
  l = is_list(x) ? min(x[0], x[1]) : -(abs(x)-1)/2;
  r = is_list(x) ? max(x[0], x[1]) :  (abs(x)-1)/2;
  y = z[0];
  if (l<=r) translate([0, fGridY*(y-1), 0]) {
    // extrude(fFloor) translate([fGridX*l-fBulgeOX, fHornY]) rect([fGridX*(r-l)+fBulgeOX*2, -fWall4]);
    extrude(fSideZ) translate([fGridX*l-fBulgeOX, fTHookY]) rect([fGridX*(r-l)+fBulgeOX*2, -fWall2]);
    blSeamFill(l);
    brSeamFill(r);
    bSideBase(l, r);
  }
}

module lSide(x=[0], z=1, trim=false) {
  if (trim && tPH>0) lTrim(x, z, print=false);
  assert(             is_list(x) && len(x)==1);
  assert(is_num(z) || is_list(z) && len(z)==2);
  t = is_list(z) ? max(z[0], z[1]) :  (abs(z)-1)/2;
  b = is_list(z) ? min(z[0], z[1]) : -(abs(z)-1)/2;
  if (t>=b) translate([fGridX*(x[0]-1), 0, 0]) {
    extrude(fFloor) for (i=[b:t]) if (i>b) translate([fSideIX, fGridY*(i-0.5)]) rect([claspD+stretchX/2+fWallGrid, claspW*2+hookLR*2-fWall2*2-fSlopXY-lPC*2-lWS*2], [1,0]);
    extrude(fFloor) translate([fSideIX, fGridY*t]) translate([0,  fHornY]) rect([claspD+stretchX/2+fWallGrid, -claspW-hookLR+fWallGrid+lPC+lWS]);
    extrude(fFloor) translate([fSideIX, fGridY*b]) translate([0, -fHornY]) rect([claspD+stretchX/2+fWallGrid,  claspW+hookLR-fWallGrid-lPC-lWS]);
    extrude(fFloor) translate([fSideIX, fGridY*b-fHornY]) rect([fWall2+stretchX/2, fGridY*(t-b)+fHornY*2]);
    extrude(fFloor) for (i=[b:t]) translate([fBulgeOX, fGridY*i]) rect([-fBulgeWall-fWall2, fBulgeOY*2+lPC*2], [1,0]);
    extrude(fSideZ) translate([fSideOX, fGridY*b-fHornY]) rect([-fWall2, fGridY*(t-b)+fHornY*2]);
    for (i=[b:t]) translate([0, fGridY*i, 0]) {
      rHooks();
      if (fillStretch) rHookFill();
      translate([fSideIX, 0, 0]) {
        rB = [fBulgeWall+fWall2, fHornY*2-claspW*2-hookLR*2-fSlopXY*2];
        rL = rB - [fWall2, fWall2*2];
        flipY() translate([0, rL.y/2, 0]) extrude(fGridZ) rect([rB.x, fWall2]);
        translate([0, 0, fGridZ-tInsert-fTop]) difference() {
          hull() {
            extrude(fTop) rect(rB, [1,0]);
            extrude(-rL.x) rect([fWall2, rB.y], [1,0]);
          }
          translate([fWall2, 0, 0]) {
            eSliceY(-rL.x, rL, centerY=true);
            eSliceY(fTop, rL-[fWall2, 0], centerY=true, cutAlt=true, hFudge=fudge);
            eSliceX(fTop, [fWall2, rL.y], translate=[rL.x-fWall2, 0], flushL=true, flushR=true, centerY=true, cutAlt=true, hFudge=fudge);
          }
        }
        if (tPH>0) rotate(90) sideBumps([rL.y, -rB.x]);
      }
    }
  }
}

module rSide(x=[0], z=1, trim=false) {
  if (trim && tPH>0) rTrim(x, z, print=false);
  assert(             is_list(x) && len(x)==1);
  assert(is_num(z) || is_list(z) && len(z)==2);
  t = is_list(z) ? max(z[0], z[1]) :  (abs(z)-1)/2;
  b = is_list(z) ? min(z[0], z[1]) : -(abs(z)-1)/2;
  if (t>=b) translate([fGridX*(x[0]+1), 0, 0]) {
    extrude(fFloor) translate([-fSideOX-stretchX/2, fGridY*b-fHornY]) rect([fWall2+stretchX/2, fGridY*(t-b)+fHornY*2]);
    extrude(fSideZ) translate([-fSideOX, fGridY*b-fHornY]) rect([fWall2, fGridY*(t-b)+fHornY*2]);
    if (fillStretch) {
      ltHookFill(t);
      lbHookFill(b);
    }
    for (i=[b:t]) translate([0, fGridY*i, 0]) {
      lHooks();
      if (fillStretch && i<t) lHookFill();
      translate([-fSideIX, 0, 0]) {
        rB = [-fBulgeWall-fWall2, fHornY*2-claspW*2-hookLR*2+fWall2*2+lPC*2+lWS*2];
        rL = rB - [-fWall2, fWall2*2+lWS*2];
        extrude(fFloor) rect(rB, [1,0]);
        translate([0, 0, fGridZ-tInsert-fTop]) difference() {
          hull() {
            extrude(fTop) rect(rB, [1,0]);
            extrude(rL.x) rect([-fWall2, rB.y], [1,0]);
          }
          translate([-fWall2, 0, 0]) {
            eSliceY(rL.x, rL, centerY=true);
            eSliceY(fTop, [rL.x+fWall2, rL.y], centerY=true, cutAlt=true, hFudge=fudge);
            eSliceX(fTop, [-fWall2, rL.y], translate=[rL.x+fWall2, 0], flushL=true, flushR=true, centerY=true, cutAlt=true, hFudge=fudge);
          }
        }
        if (tPH>0) rotate(270) sideBumps([rL.y, rB.x]);
      }
    }
  }
}


// CORNER HELPERS

module cornerWall(r, offset, align, trim=undef, wall=fWall2) translate([(fGridX-offset.x)*align.x, (fGridY-offset.y)*align.y]) difference() {
  circle(r=r);
  circle(r=r-min(r, wall));
  translate([0, -(r-wall)*align.y]) rect([(r+fudge)*align.x, (r*2-wall+fudge)*align.y]);
  translate([-(r-wall)*align.x, 0]) rect([(r*2-wall+fudge)*align.x, (r+fudge)*align.y]);
  if (is_list(trim) && len(trim)==2) {
    if (is_num(trim[0])) translate([trim[0]*align.x, 0]) rect([(r-trim[0]+fudge)*align.x, r*2+fudge2], [1,0]);
    if (is_num(trim[1])) translate([0, trim[1]*align.y]) rect([r*2+fudge2, (r-trim[1]+fudge)*align.y], [0,1]);
  }
}

// translate([0,0,100]) cornerWall(5, [1,0], [1,-1], trim=[1, -2]);

module cornerSquare(r, offset, align, wall=[fWall2, fWall2]) translate([(fGridX-offset.x)*align.x, (fGridY-offset.y)*align.y]) difference() {
  circle(r=r);
  translate([-(r-wall.x)*align.x, -(r-wall.y)*align.y]) rect([(r*2-wall.x+fudge)*align.x, (r*2-wall.y+fudge)*align.y]);
}

module cornerMask(r, offset, align) translate([(fGridX-offset.x)*align.x, (fGridY-offset.y)*align.y]) {
  circle(r=r);
  translate([0, -align.y*r]) rect([(fGridX/2+offset.x)*align.x, (fGridY/2+offset.y+r)*align.y]);
  translate([-align.x*r, 0]) rect([(fGridX/2+offset.x+r)*align.x, (fGridY/2+offset.y)*align.y]);
}

// doesn't appear to be used anymore; I don't even remember what it was for
// module cornerFloor(r, size, offset, align) intersection() {
//   translate([(fGridX-offset.x-r)*align.x, (fGridY-offset.y-r)*align.y]) rect([size.x*align.x, size.y*align.y]);
//   cornerMask(r, offset, align);
// }


// CORNERS

module tlSide(x=1, z=[0], trim=false) {
  if (trim && tPH>0) tTrim(x, z, print=false);
  assert(is_num(x) || is_list(x) && len(x)==2);
  assert(             is_list(z) && len(z)==1);
  l = is_list(x) ? min(x[0], x[1]) : -(abs(x)-1)/2;
  r = is_list(x) ? max(x[0], x[1]) :  (abs(x)-1)/2;
  y = z[0];
  if (l<=r) {
    tPHAdj = tPH>0 ? 0 : fWallGrid;
    fillet = fWall2 + tClearance + tPHAdj;
    rise = claspD - fWall2 + fSlopXY - tPHAdj;
    edge = fSideOX + claspD + stretchX - tClearance + fSlopXY*2 - tPHAdj;
    align = [1, -1];
    translate([fGridX*(l-1), fGridY*(y+1), 0]) {
      tSideBase(1, r-l+1);
      if (tPH>0) extrude(fFloor) translate([fGridX-edge, fBHookY+bPH]) rect([fGridX*(r-l)+fBulgeOX+edge, tClearance-bPH+fWall2]);
      extrude(fSideZ) {
        translate([fGridX-edge, fBHookY+tClearance]) rect([fGridX*(r-l)+fBulgeOX+edge, fWall2]);
        cornerWall(fillet, [edge, fHornY+fWallGrid+fSlopXY-tPHAdj], align, trim=[undef, rise-claspD+fWall2*2]);
        if (tPH>0) translate([fGridX-edge-fillet, fBHookY]) rect([fWall2, -rise+claspD-fWall2*2]);
      }
      trSeamFill(r-l+1);
      rB = [claspD+stretchX+fWallGrid*3+lPC+lWS, -rise-fillet+claspD-fWall2*2];
      rL = rB - [fWall2*2+lWS, -fWall2];
      tx = fGridX - edge - fillet;
      ty = -fGridY + fHornY + fWallGrid + fillet + fSlopXY - tPHAdj;
      // #translate([tx, ty]) extrude(fGridZ+1) rect(rB);
      // #translate([tx+fWall2, ty-fWall2]) extrude(fGridZ+2) rect(rL);
      extrude(fFloor) intersection() {
        translate([tx, ty]) rect(rB);
        cornerMask(fillet, [edge, fHornY+fWallGrid+fSlopXY-tPHAdj], align);
      }
      translate([0, 0, fGridZ-fTop]) difference() {
        intersection() {
          translate([tx, ty, 0]) hull() {
            extrude(fTop) rect(rB);
            extrude(rL.y) rect([rB.x, -fWall2]);
          }
          extrude((rL.y-fTop)*2, center=true) cornerMask(fillet, [edge, fHornY+fWallGrid+fSlopXY-tPHAdj], align);
        }
        eSliceX(rL.y, rL, translate=[tx+fWall2, ty-fWall2]);
        eSliceX(fTop, [rL.x, rL.y+fWall2], translate=[tx+fWall2, ty-fWall2], cutAlt=true, hFudge=fudge)
          offset(delta=-fWall2) cornerMask(fillet, [edge, fHornY+fWallGrid+fSlopXY-tPHAdj], align);
        eSliceY(fTop, [rL.x, -fWall2], translate=[tx+fWall2, ty+rL.y], flushT=true, flushB=true, cutAlt=1, hFudge=fudge)
          offset(delta=-fWall2) cornerMask(fillet, [edge, fHornY+fWallGrid+fSlopXY-tPHAdj], align);
      }
    }
  }
}

module trSide(x=1, z=[0], trim=false) {
  if (trim && tPH>0) tTrim(x, z, print=false);
  assert(is_num(x) || is_list(x) && len(x)==2);
  assert(             is_list(z) && len(z)==1);
  l = is_list(x) ? min(x[0], x[1]) : -(abs(x)-1)/2;
  r = is_list(x) ? max(x[0], x[1]) :  (abs(x)-1)/2;
  y = z[0];
  if (l<=r) {
    tPHAdj = tPH>0 ? 0 : fWallGrid;
    fillet = fWall2 + tClearance + tPHAdj;
    rise = claspD - fWall2 + fSlopXY - tPHAdj;
    edge = fSideOX + claspD + stretchX - tClearance + fSlopXY*2 - tPHAdj;
    align = [-1, -1];
    translate([fGridX*(r+1), fGridY*(y+1), 0]) {
      tSideBase(l-r-1, -1);
      if (tPH>0) extrude(fFloor) translate([edge-fGridX, fBHookY+bPH]) rect([fGridX*(l-r)-fBulgeOX-edge, tClearance-bPH+fWall2]);
      extrude(fSideZ) {
        translate([edge-fGridX, fBHookY+tClearance]) rect([fGridX*(l-r)-fBulgeOX-edge, fWall2]);
        cornerWall(fillet, [edge, fHornY+fWallGrid+fSlopXY-tPHAdj], align, trim=[undef, rise-claspD+fWall2*2]);
        if (tPH>0) translate([edge-fGridX+fillet, fBHookY]) rect([-fWall2, -rise+claspD-fWall2*2]);
      }
      tlSeamFill(l-r-1);
      rB = [-claspD-stretchX-fWallGrid*3-lPC-lWS, -rise-fillet+claspD-fWall2*2];
      rL = rB - [-fWall2*2-lWS, -fWall2];
      tx = -fGridX + edge + fillet;
      ty = -fGridY + fHornY + fWallGrid + fillet + fSlopXY - tPHAdj;
      // #translate([tx, ty]) extrude(fGridZ+1) rect(rB);
      // #translate([tx-fWall2, ty-fWall2]) extrude(fGridZ+2) rect(rL);
      extrude(fFloor) intersection() {
        translate([tx, ty]) rect(rB);
        cornerMask(fillet, [edge, fHornY+fWallGrid+fSlopXY-tPHAdj], align);
      }
      translate([0, 0, fGridZ-fTop]) difference() {
        intersection() {
          translate([tx, ty, 0]) hull() {
            extrude(fTop) rect(rB);
            extrude(rL.y) rect([rB.x, -fWall2]);
          }
          extrude((rL.y-fTop)*2, center=true) cornerMask(fillet, [edge, fHornY+fWallGrid+fSlopXY-tPHAdj], align);
        }
        eSliceX(rL.y, rL, translate=[tx-fWall2, ty-fWall2]);
        eSliceX(fTop, [rL.x, rL.y+fWall2], translate=[tx-fWall2, ty-fWall2], cutAlt=true, hFudge=fudge)
          offset(delta=-fWall2) cornerMask(fillet, [edge, fHornY+fWallGrid+fSlopXY-tPHAdj], align);
        eSliceY(fTop, [rL.x, -fWall2], translate=[tx-fWall2, ty+rL.y], flushT=true, flushB=true, cutAlt=1, hFudge=fudge)
          offset(delta=-fWall2) cornerMask(fillet, [edge, fHornY+fWallGrid+fSlopXY-tPHAdj], align);
      }
    }
  }
}

module blSide(x=1, z=[0], trim=false) {
  if (trim && tPH>0) bTrim(x, z, print=false);
  assert(is_num(x) || is_list(x) && len(x)==2);
  assert(             is_list(z) && len(z)==1);
  l = is_list(x) ? min(x[0], x[1]) : -(abs(x)-1)/2;
  r = is_list(x) ? max(x[0], x[1]) :  (abs(x)-1)/2;
  y = z[0];
  if (l<=r) {
    fillet = claspD;
    edge = fGridX/2 - claspD/2 + fWallGrid + stretchX/2;
    align = [1, 1];
    translate([fGridX*(l-1), fGridY*(y-1), 0]) {
      bSideBase(1, r-l+1);
      extrude(fSideZ) {
        translate([fGridX-edge, fTHookY]) rect([fGridX*(r-l)+fBulgeOX+edge, -fWall2]);
        cornerWall(fillet, [edge, fHornY+fSlopXY], align, trim=[undef, 0]);
      }
      brSeamFill(r-l+1);
      rB = [claspD+fWallGrid*2+stretchX, fillet];
      rL = rB - [fWall2*2, fWall2];
      tx = fGridX - edge - fillet;
      ty = fGridY - fHornY - fillet - fSlopXY;
      // #translate([tx, ty]) extrude(fGridZ+1) rect(rB);
      // #translate([tx+fWall2, ty+fWall2]) extrude(fGridZ+2) rect(rL);
      extrude(fFloor) intersection() {
        translate([tx, ty]) rect(rB+[lPC, 0]);
        cornerMask(fillet, [edge, fHornY+fSlopXY], align);
      }
      translate([0, 0, fGridZ-fTop]) difference() {
        intersection() {
          translate([tx, ty, 0]) hull() {
            extrude(fTop) rect(rB);
            extrude(-rL.y) rect([rB.x, fWall2]);
          }
          extrude((rL.y+fTop)*2, center=true) cornerMask(fillet, [edge, fHornY+fSlopXY], align);
        }
        eSliceX(-rL.y, rL, translate=[tx+fWall2, ty+fWall2]);
        eSliceY(fTop, rL, translate=[tx+fWall2, ty+fWall2], flushT=true, cutAlt=true, hFudge=fudge)
          offset(delta=-fWall2) cornerMask(fillet, [edge, fHornY+fSlopXY], align);
      }
    }
  }
}

module brSide(x=1, z=[0], trim=false) {
  if (trim && tPH>0) bTrim(x, z, print=false);
  assert(is_num(x) || is_list(x) && len(x)==2);
  assert(             is_list(z) && len(z)==1);
  l = is_list(x) ? min(x[0], x[1]) : -(abs(x)-1)/2;
  r = is_list(x) ? max(x[0], x[1]) :  (abs(x)-1)/2;
  y = z[0];
  if (l<=r) {
    fillet = claspD;
    edge = fGridX/2 - claspD/2 + fWallGrid + stretchX/2;
    align = [-1, 1];
    translate([fGridX*(r+1), fGridY*(y-1), 0]) {
      bSideBase(l-r-1, -1);
      extrude(fSideZ) {
        translate([edge-fGridX, fTHookY]) rect([fGridX*(l-r)-fBulgeOX-edge, -fWall2]);
        cornerWall(fillet, [edge, fHornY+fSlopXY], align, trim=[undef, 0]);
      }
      blSeamFill(l-r-1);
      rB = [-claspD-fWallGrid*2-stretchX, fillet];
      rL = rB - [-fWall2*2, fWall2];
      tx = -fGridX + edge + fillet;
      ty = fGridY - fHornY - fillet - fSlopXY;
      // #translate([tx, ty]) extrude(fGridZ+1) rect(rB);
      // #translate([tx-fWall2, ty+fWall2]) extrude(fGridZ+2) rect(rL);
      extrude(fFloor) intersection() {
        translate([tx, ty]) rect(rB-[lPC, 0]);
        cornerMask(fillet, [edge, fHornY+fSlopXY], align);
      }
      translate([0, 0, fGridZ-fTop]) difference() {
        intersection() {
          translate([tx, ty, 0]) hull() {
            extrude(fTop) rect(rB);
            extrude(-rL.y) rect([rB.x, fWall2]);
          }
          extrude((rL.y+fTop)*2, center=true) cornerMask(fillet, [edge, fHornY+fSlopXY], align);
        }
        eSliceX(-rL.y, rL, translate=[tx-fWall2, ty+fWall2]);
        eSliceY(fTop, rL, translate=[tx-fWall2, ty+fWall2], flushT=true, cutAlt=true, hFudge=fudge)
          offset(delta=-fWall2) cornerMask(fillet, [edge, fHornY+fSlopXY], align);
      }
    }
  }
}


// TRIM

module tTrimBase(l, r) for (i=[l:r]) translate([fGridX*i, -fHornY+fWall2+tClearance, 0]) {
  extrude(-trimZ) {
    flipX() translate([fSideOX-claspW-hookTB, 0, 0]) rect([hookTB+lPH-tPH-fSlopXY, -tClearance+fSlopXY]);
    rect([fSideOX*2-claspW*2+lPH*2-tPH*2-fSlopXY*2, -tClearance+bPH+fSlopXY], [0,1]);
  }
  trimBumps([fSideOX*2-claspW*2+lPH*2-tPH*2-fSlopXY*2, -tClearance+fSlopXY]);
}

module bTrimBase(l, r) for (i=[l:r]) translate([fGridX*i, fHornY-claspD+fWallGrid, 0]) {
  extrude(-trimZ) rect([fSideIX*2-claspW*2-hookTB*2-tPH*2-fSlopXY*4, hookD-fWall2-fSlopXY*2], [0,1]);
  rotate(180) trimBumps([fSideIX*2-claspW*2-hookTB*2-tPH*2-fSlopXY*4, -hookD+fWall2+fSlopXY*2]);
}

module tTrim(x=1, z=[0], print=true) {
  assert(tPH > 0);
  assert(is_num(x) || is_list(x) && len(x)==2);
  assert(             is_list(z) && len(z)==1);
  l = is_list(x) ? min(x[0], x[1]) : -(abs(x)-1)/2;
  r = is_list(x) ? max(x[0], x[1]) :  (abs(x)-1)/2;
  y = z[0];
  if (l<=r) rotate([0, print?180:0, 0]) translate([0, fGridY*(y+1), print?0:fGridZ+tFloor+tFloat]) {
    extrude(-tFloor) translate([fGridX*l-fBulgeOX, fBHookY]) rect([fGridX*(r-l)+fBulgeOX*2, tClearance-fSlopXY]);
    tTrimBase(l, r);
  }
}

module bTrim(x=1, z=[0], print=true) {
  assert(tPH > 0);
  assert(is_num(x) || is_list(x) && len(x)==2);
  assert(             is_list(z) && len(z)==1);
  l = is_list(x) ? min(x[0], x[1]) : -(abs(x)-1)/2;
  r = is_list(x) ? max(x[0], x[1]) :  (abs(x)-1)/2;
  y = z[0];
  if (l<=r) rotate([0, print?180:0, 0]) translate([0, fGridY*(y-1), print?0:fGridZ+tFloor+tFloat]) {
    extrude(-tFloor) translate([fGridX*l-fBulgeOX, fTHookY+fSlopXY]) rect([fGridX*(r-l)+fBulgeOX*2, claspD]);
    bTrimBase(l, r);
  }
}

module lTrim(x=[0], z=1, print=true) {
  assert(tPH > 0);
  assert(             is_list(x) && len(x)==1);
  assert(is_num(z) || is_list(z) && len(z)==2);
  t = is_list(z) ? max(z[0], z[1]) :  (abs(z)-1)/2;
  b = is_list(z) ? min(z[0], z[1]) : -(abs(z)-1)/2;
  if (t>=b) rotate([0, print?180:0, 0]) translate([fGridX*(x[0]-1)+fSideIX+fWallGrid, 0, print?0:fGridZ+tFloor+tFloat]) {
    extrude(-tFloor) translate([0, fGridY*b-fHornY]) rect([fBulgeWall-fSlopXY, fGridY*(t-b)+fHornY*2]);
    for (i=[b:t]) translate([0, fGridY*i, 0]) {
      extrude(-trimZ) rect([fBulgeWall-fSlopXY, fBulgeOY*2-fWallGrid*2-tPH*2], [1,0]);
      rotate(90) trimBumps([fBulgeOY*2-fWallGrid*2-tPH*2, fSlopXY-fBulgeWall]);
    }
  }
}

module rTrim(x=[0], z=1, print=true) {
  assert(tPH > 0);
  assert(             is_list(x) && len(x)==1);
  assert(is_num(z) || is_list(z) && len(z)==2);
  t = is_list(z) ? max(z[0], z[1]) :  (abs(z)-1)/2;
  b = is_list(z) ? min(z[0], z[1]) : -(abs(z)-1)/2;
  if (t>=b) rotate([0, print?180:0, 0]) translate([fGridX*(x[0]+1)-fSideIX-fWallGrid, 0, print?0:fGridZ+tFloor+tFloat]) {
    extrude(-tFloor) translate([0, fGridY*b-fHornY]) rect([fSlopXY-fBulgeWall, fGridY*(t-b)+fHornY*2]);
    for (i=[b:t]) translate([0, fGridY*i, 0]) {
      extrude(-trimZ) rect([fSlopXY-fBulgeWall, fHornY*2-claspW*2-hookLR*2+lPC*2-tPH*2-fSlopXY*2], [1,0]);
      rotate(270) trimBumps([fHornY*2-claspW*2-hookLR*2+lPC*2-tPH*2-fSlopXY*2, fSlopXY-fBulgeWall]);
    }
  }
}

module tlTrim(x=1, z=1, print=true) {
  assert(tPH > 0);
  assert(is_num(x) || is_list(x) && len(x)==2);
  assert(is_num(z) || is_list(z) && len(z)==2);
  t = is_list(z) ? max(z[0], z[1]) :  (abs(z)-1)/2;
  b = is_list(z) ? min(z[0], z[1]) : -(abs(z)-1)/2;
  l = is_list(x) ? min(x[0], x[1]) : -(abs(x)-1)/2;
  r = is_list(x) ? max(x[0], x[1]) :  (abs(x)-1)/2;
  if (t>=b && l<=r) {
    fillet = tClearance - fSlopXY;
    rise = fWallGrid + fSlopXY;
    edge = fSideOX + claspD + stretchX - tClearance + fSlopXY*2;
    lTrim([l], z, print);
    rotate([0, print?180:0, 0]) translate([fGridX*(l-1), fGridY*(t+1), print?0:fGridZ+tFloor+tFloat]) {
      tTrimBase(1, r-l+1);
      extrude(-tFloor) {
        translate([fGridX-edge, fBHookY]) rect([fGridX*(r-l)+fBulgeOX+edge, tClearance-fSlopXY]);
        cornerSquare(fillet, [edge, fHornY+rise], [1, -1], [fBulgeWall-fSlopXY, tClearance-fSlopXY]);
        translate([fGridX-edge-fillet, fBHookY]) rect([fBulgeWall-fSlopXY, -rise-fudge]);
      }
    }
  }
}

module trTrim(x=1, z=1, print=true) {
  assert(tPH > 0);
  assert(is_num(x) || is_list(x) && len(x)==2);
  assert(is_num(z) || is_list(z) && len(z)==2);
  t = is_list(z) ? max(z[0], z[1]) :  (abs(z)-1)/2;
  b = is_list(z) ? min(z[0], z[1]) : -(abs(z)-1)/2;
  l = is_list(x) ? min(x[0], x[1]) : -(abs(x)-1)/2;
  r = is_list(x) ? max(x[0], x[1]) :  (abs(x)-1)/2;
  if (t>=b && l<=r) {
    fillet = tClearance - fSlopXY;
    rise = fWallGrid + fSlopXY;
    edge = fSideOX + claspD + stretchX - tClearance + fSlopXY*2;
    rTrim([r], z, print);
    rotate([0, print?180:0, 0]) translate([fGridX*(r+1), fGridY*(t+1), print?0:fGridZ+tFloor+tFloat]) {
      tTrimBase(l-r-1, -1);
      extrude(-tFloor) {
        translate([edge-fGridX, fBHookY]) rect([fGridX*(l-r)-fBulgeOX-edge, tClearance-fSlopXY]);
        cornerSquare(fillet, [edge, fHornY+rise], [-1, -1], [fBulgeWall-fSlopXY, tClearance-fSlopXY]);
        translate([edge-fGridX+fillet, fBHookY]) rect([fSlopXY-fBulgeWall, -rise-fudge]);
      }
    }
  }
}

module blTrim(x=1, z=1, print=true) {
  assert(tPH > 0);
  assert(is_num(x) || is_list(x) && len(x)==2);
  assert(is_num(z) || is_list(z) && len(z)==2);
  t = is_list(z) ? max(z[0], z[1]) :  (abs(z)-1)/2;
  b = is_list(z) ? min(z[0], z[1]) : -(abs(z)-1)/2;
  l = is_list(x) ? min(x[0], x[1]) : -(abs(x)-1)/2;
  r = is_list(x) ? max(x[0], x[1]) :  (abs(x)-1)/2;
  if (t>=b && l<=r) {
    fillet = claspD - fWallGrid;
    edge = fGridX/2 - claspD/2 + stretchX/2 + fWallGrid;
    lTrim([l], z, print);
    rotate([0, print?180:0, 0]) translate([fGridX*(l-1), fGridY*(b-1), print?0:fGridZ+tFloor+tFloat]) {
      bTrimBase(1, r-l+1);
      extrude(-tFloor) {
        translate([fGridX-edge, fTHookY+fSlopXY]) rect([fGridX*(r-l)+fBulgeOX+edge, claspD]);
        if (claspD-fillet>0) translate([fGridX-edge-fillet, fTHookY+fSlopXY+fillet]) rect([fGridX*(r-l)+fBulgeOX+edge+fillet, claspD-fillet]);
        cornerSquare(fillet, [edge, fHornY+fSlopXY], [1, 1], [fBulgeWall-fSlopXY, claspD]);
      }
    }
  }
}

module brTrim(x=1, z=1, print=true) {
  assert(tPH > 0);
  assert(is_num(x) || is_list(x) && len(x)==2);
  assert(is_num(z) || is_list(z) && len(z)==2);
  t = is_list(z) ? max(z[0], z[1]) :  (abs(z)-1)/2;
  b = is_list(z) ? min(z[0], z[1]) : -(abs(z)-1)/2;
  l = is_list(x) ? min(x[0], x[1]) : -(abs(x)-1)/2;
  r = is_list(x) ? max(x[0], x[1]) :  (abs(x)-1)/2;
  if (t>=b && l<=r) {
    fillet = claspD - fWallGrid;
    edge = fGridX/2 - claspD/2 + stretchX/2 + fWallGrid;
    rTrim([r], z, print);
    rotate([0, print?180:0, 0]) translate([fGridX*(r+1), fGridY*(b-1), print?0:fGridZ+tFloor+tFloat]) {
      bTrimBase(l-r-1, -1);
      extrude(-tFloor) {
        translate([edge-fGridX, fTHookY+fSlopXY]) rect([fGridX*(l-r)-fBulgeOX-edge, claspD]);
        if (claspD-fillet>0) translate([edge-fGridX+fillet, fTHookY+fSlopXY+fillet]) rect([fGridX*(l-r)-fBulgeOX-edge-fillet, claspD-fillet]);
        cornerSquare(fillet, [edge, fHornY+fSlopXY], [-1, 1], [fBulgeWall-fSlopXY, claspD]);
      }
    }
  }
}



///////////
// FRAME //
///////////


module frame(x=1, z=1, hookInserts=false, drawer=false, drawFace=true, drawTop=true, drawFloor=true, drawSides=true) {
  assert(is_num(x) || is_list(x) && len(x)==2);
  assert(is_num(z) || is_list(z) && len(z)==2);
  t = is_list(z) ? max(z[0], z[1]) :  (abs(z)-1)/2;
  b = is_list(z) ? min(z[0], z[1]) : -(abs(z)-1)/2;
  l = is_list(x) ? min(x[0], x[1]) : -(abs(x)-1)/2;
  r = is_list(x) ? max(x[0], x[1]) :  (abs(x)-1)/2;
  stopTop = /*fLayerRelFloor*/(drawerY + gap - dFloat - dTravel - fWall2*sqrt(2)/2 + dSlopXY);
  stopZIdeal = fGridY*(t-b+1) - claspW - hookLR - fWallGrid*2 - dSlopZ*2;
  stopZError = dLayerAbsFloor(stopZIdeal) - stopZIdeal;
  drawerZIdeal = fGridY*(t-b) + drawerZ;
  drawerZError = dLayerAbsFloor(drawerZIdeal) - drawerZIdeal;

  module rBulge(top=false) translate([fBulgeOX, 0, 0]) {
    extrude(fGridZ) {
      translate([0, fBulgeOY]) rect([-fBulgeWall-fWall2, (top?stopZError:0)-fWall2]);
      translate([0, -fBulgeOY]) rect([-fBulgeWall-fWall2, fWall2]);
      if (drawSides) rect([-fWall2, fBulgeOY*2], [1,0]);
    }
  }

  module lBulge(top=false) scale([-1,1,1]) rBulge(top=top);

  module tFrame(l=0, r=0) {
    for (i=[l:r]) translate([fGridX*i, 0, 0]) {
      tHooks(drawHooks=drawTop);
      extrude(fGridZ) flipX() translate([fGridX/2-claspD/2-stretchX/2-fSlopXY, fHornY]) rect([-fWall2, -fWall4]);
    }
    if (drawTop) extrude(fGridZ) translate([fGridX*r+fSideOX, fTHookY]) rect([fGridX*(l-r)-fSideOX*2, -fWall2]);
  }

  module bFrame(l=0, r=0) {
    translate([fGridX*l, 0, 0]) blHook();
    translate([fGridX*r, 0, 0]) brHook();
    extrude(fGridZ) {
      translate([fGridX*r+fSideOX, -fHornY]) rect([-fWall4-lPC-lWS, fWall2]);
      translate([fGridX*l-fSideOX, -fHornY]) rect([ fWall4+lPC+lWS, fWall2]);
    }
  }

  module lFrame(b=0, t=0) {
    if (fillStretch) {
      ltHookFill(t);
      lbHookFill(b);
    }
    for (i=[b:t]) translate([0, fGridY*i, 0]) {
      if (drawSides) lHooks();
      if (fillStretch && i<t) lHookFill();
      lBulge(top=i==t);
      // fill hole caused by locks (if used)
      flipY() translate([-fBulgeOX, fBulgeIY, fGridZ]) hull() {
        extrude(-fTop) rect([claspD/2/*+stretchX/2*/-fSlopXY/2, fWall2+lPC]);
        extrude(-fTop-lPC) rect([claspD/2/*+stretchX/2*/-fSlopXY/2, fWall2]);
      }
      if (i<t) extrude(fGridZ) translate([-fSideOX, fBulgeIY]) rect([fWall2, fGridY-fBulgeIY*2]);
    }
    if (drawSides) extrude(fGridZ) {
      translate([-fSideOX, fGridY*t+fBulgeIY]) rect([fWall2, fHornY-fBulgeIY]);
      translate([-fSideOX, fGridY*b-fBulgeIY]) rect([fWall2, fBulgeIY-fHornY]);
    }
  }

  module rFrame(b=0, t=0) {
    for (i=[b:t]) translate([0, fGridY*i, 0]) {
      if (drawSides) rHooks();
      if (fillStretch) rHookFill();
      rBulge(top=i==t);
      if (i<t) extrude(fGridZ) translate([fSideOX, fBulgeIY]) rect([fWall2, fGridY-fBulgeIY*2], [-1,1]);
    }
    if (drawSides) extrude(fGridZ) {
      translate([fSideOX, fGridY*t+fBulgeIY]) rect([-fWall2, fHornY-fBulgeIY]);
      translate([fSideOX, fGridY*b-fBulgeIY]) rect([-fWall2, fBulgeIY-fHornY]);
    }
  }

  if (t>=b && l<=r) {
    translate([0, fGridY*t, 0]) tFrame(l, r);
    translate([0, fGridY*b, 0]) bFrame(l, r);
    translate([fGridX*l, 0, 0]) lFrame(b, t);
    translate([fGridX*r, 0, 0]) rFrame(b, t);

    translate([fGridX*(r+l)/2, 0, 0]) flipX() {
      dStopLines = t-b==0 ? stopLinesH0 : stopLinesHN;
      stopHIdeal = (fWall2 + gap)*dStopLines;
      stopH = stopHIdeal - stopZError;
      railW = (railWN - ((t-b)==0 ? stopH : 0) + railD*2 - dSlop45*2) / (drawSides ? 1 : 2);
      peakW = (peakWN - ((t-b)==0 ? stopH : 0)) / (drawSides ? 1 : 2);
      railZ = fGridY*b - ((t-b)==0 ? stopH/2 : 0);

      // drawer rail bumps
      translate([fGridX*(r-l)/2+fBulgeIX, railZ, 0]) {
        // cushion
        hull() {
          box([fWall2, -railW, cInset+cBL+cPL], [1,drawSides?0:1,1]);
          box([-cCH, -peakW, cInset+cBL+cPL], [1,drawSides?0:1,1]);
        }
        // catch, in back, holds drawer shut
        hull() {
          translate([0, 0, cInset]) box([fWall2, -railW, cBL+cPL+cFL], [1,drawSides?0:1,1]);
          translate([0, 0, cInset+cBL]) box([-cPH, -peakW, cPL], [1,drawSides?0:1,1]);
        }
        // hold, in front, holds drawer open
        hull() {
          translate([0, 0, fGridZ-hInset]) box([fWall2, -railW, -hFL-hPL-hBL], [1,drawSides?0:1,1]);
          translate([0, 0, fGridZ-hInset-hFL]) box([-hPH, -peakW, -hPL], [1,drawSides?0:1,1]);
        }
        // keep, in front, holds drawer in
        hull() {
          translate([0, 0, fGridZ-kInset]) box([fWall2, -railW, -kFL-kPL-kBL], [1,drawSides?0:1,1]);
          translate([0, 0, fGridZ-kInset-kFL]) box([-kPH, -railW+kPH*(drawSides?2:1), -kPL], [1,drawSides?0:1,1]);
        }
      }
      // drawer stops
      if (dStopLines>=1) translate([fGridX*(r-l)/2+fBulgeIX, fGridY*t+fBulgeIY+stopZError, fGridZ]) {
        difference() {
          for (i=[0:dStopLines-1]) translate([fWall2, -fWall2*i-gap*(i+1), 0]) {
            hull() {
              box([-fBulgeWall-fWall2, -fWall2, -stopTop], [1,1,1]);
              box([-fWall2, -fWall2, -stopTop-fBulgeWall], [1,1,1]);
            }
          }
          if (stopTop>=fLayerHN) for (i=[0:2:fLayerRelFloor(stopTop)/fLayerHN-1]) translate([0, 0, -i*fLayerHN+(i==0?fudge:0)])
            box([-fBulgeWall/2+fWall2/2, -(fWall2+gap)*dStopLines-fudge, -fLayerHN-(i==0?fudge:0)]);
        }
        if (stopTop>=fLayerHN) for (i=[0:2:fLayerRelFloor(stopTop)/fLayerHN-1]) translate([-fBulgeWall/2+fWall2/2, fWall2-stopZError, -i*fLayerHN])
          box([-fBulgeWall/2-fWall2/2, -(fWall2+gap)*dStopLines-fWall2+stopZError, -fLayerHN]);
      }
      // drawerZError compensation
      if (fDrawerLayerCompLines>=1) for (i=[1:fDrawerLayerCompLines]) translate([fGridX*(r-l)/2+fSideOX-fWall2*i-gap*i, fGridY*t+fTopOY, 0])
        box([-fWall2, -fWall2+drawerZError, fGridZ]);
    }

    if (drawFloor)
      difference() {
        extrude(fFloor) {
          translate([fGridX*r+fSideOX+stretchX/2, fGridY*t+fTopOY]) rect([fGridX*(l-r)-fSideOX*2-stretchX/2, fGridY*(b-t-1)+claspD+fSlopXY*2+bPH]);
          // upper left
          translate([fGridX*l-fSideOX, fGridY*t+fHornY]) rect([fWall2+lPC, -fWall4]);
          // lower corners (also needed in case bPH is large)
          translate([fGridX*l-fSideOX, fGridY*b-fHornY]) rect([ fWall4+lPC+lWS, hookD+bPH]);
          translate([fGridX*r+fSideOX, fGridY*b-fHornY]) rect([-fWall4-lPC-lWS, hookD+bPH]);
          // right seam
          for (i=[b:t]) if (i>b) translate([fGridX*(r+0.5)+claspD/2, fGridY*(i-0.5)]) rect([-claspD-stretchX/2-fWallGrid, -fWall4], [1,0]);
          // upper right hook
          for (i=[b:t]) translate([fGridX*r+fSideIX-lPC, fGridY*i+fHornY]) rect([claspD+stretchX/2+fWallGrid+lPC, -claspW-hookLR+fWallGrid+lPC+lWS]);
          // lower right hook
          for (i=[b:t]) translate([fGridX*r+fSideIX-fWallGrid-lPC-lWS, fGridY*i-fHornY]) rect([claspD+stretchX/2+fWallGrid*2+lPC+lWS, claspW+hookLR-fWallGrid-lPC-lWS]);
          // left bulge
          for (i=[b:t]) translate([fGridX*l-fBulgeOX, fGridY*i]) rect([fBulgeWall+fWall2, fBulgeOY*2+lPC*2+fWallGrid*2+lWS*2], [1,0]);
          // right bulge
          for (i=[b:t]) translate([fGridX*r+fBulgeOX, fGridY*i]) rect([-fBulgeWall-fWall2, fBulgeOY*2+lPC*2], [1,0]);
          // top hooks
          for (i=[l:r]) translate([fGridX*i, fGridY*t+fHornY-claspD]) rect([fSideOX*2-fWallGrid*4-lPC*2-lWS*2, claspD+fWallGrid+bPH], [0,1]);
          // top seam  (is this necessary?)
          // #for (i=[l:r]) if (i<r) translate([fGridX*(i+0.5), fGridY*t+fHornY]) rect([claspD+stretchX+fWallGrid*2+lPC*2, -fWall4], [0,1]);
          // bottom seam
          for (i=[l:r]) if (i<r) translate([fGridX*(i+0.5), fGridY*b-fHornY]) rect([claspD+stretchX+fWallGrid*4+lPC*2+lWS*2, hookD+bPH], [0,1]);
          // bottom seam hooks
          for (i=[l:r]) if (i<r) translate([fGridX*(i+0.5)+claspD/2+stretchX/2+fWall2+fSlopXY*2+lPC, fGridY*b-fHornY-claspD+fWall2]) rect([ fWall2+lWS, claspD]);
          for (i=[l:r]) if (i<r) translate([fGridX*(i+0.5)-claspD/2-stretchX/2-fWall2-fSlopXY*2-lPC, fGridY*b-fHornY-claspD+fWall2]) rect([-fWall2-lWS, claspD]);
          // left hook fill
          translate([fGridX*l-fSideOX-stretchX/2, fGridY*b-fHornY]) rect([fWall2+stretchX/2, fGridY*(t-b)+fHornY*2]);
        }
        if (mountingHoleD>0 && t-b>0) for (i=[l:r]) for (j=[b:t-1]) translate([fGridX*i, fGridY*(j+0.5), -fudge])
          rod(fFloor+fudge2, r=circumgoncircumradius(d=mountingHoleD, $fn=$fn/2)+fSlopXY, $fn=$fn/2);
      }

    for (i=[l:r]) if (i<r) translate([fGridX*i, fGridY*t]) bSeamFill();
    if (drawTop) for (i=[l:r]) translate([fGridX*i, fGridY*t]) bFill();

    if (drawer || is_num(drawer))
      translate([0, drawerZFrameYAlign+fGridY*b, drawerYFrameZAlign+(is_num(drawer)?drawer:0)])
        rotate([-90,0,0]) drawer(x, h=t-b+1, drawFace=drawFace);

    if (hookInserts) for (i=[l:r]) if (i<r) translate([fGridX*(i+0.5), fGridY*b, fFloor]) hookInsert();
  }
}



////////////
// DRAWER //
////////////


module drawer(x=1, h=1, drawFace=true) {
  // h=1;
  assert(is_num(x) || is_list(x) && len(x)==2);
  assert(is_num(h) && h>=1);
  l = is_list(x) ? min(x[0], x[1]) : -(abs(x)-1)/2;
  r = is_list(x) ? max(x[0], x[1]) :  (abs(x)-1)/2;
  w = fGridX*(r-l) + drawerX;
  faceZ = dLayerAbsFloor(fGridY*h - dSlopZ);
  faceX = w - drawerX + fBulgeOX*2;
  bodyZ = dLayerAbsFloor(fGridY*(h-1) + drawerZ);
  stopZIdeal = fGridY*h - claspW - hookLR - fWallGrid*2 - dSlopZ*2;
  stopZ = dLayerAbsFloor(stopZIdeal);
  stopZError = stopZ - stopZIdeal;
  stopHIdeal = (fWall2 + gap)*(h==1 ? stopLinesH0 : stopLinesHN);
  stopH = stopHIdeal - stopZError;
  lipTop = dLayerRelRound(bodyZ - stopZ + stopHIdeal - dSlopZ + dSlop45);
  railW = railWN - (h==1 ? stopH : 0);
  peakW = peakWN - (h==1 ? stopH : 0);
  bulgeZ = fHornY - fWall2 - dSlopZ;
  railZ = bulgeZ - (h==1 ? stopH/2 : 0);

  module bump() hull() {
    box([-fudge, -dBL-dPL-dFL, railW], [1,1,0]);
    translate([0, -dBL, 0]) box([dPH, -dPL, peakW], [1,1,0]);
  }

  module handleProfile(r, trunc) {
    rotate(90) teardrop_2d(r=r, truncate=trunc, $fn=$fn/2);
    rotate(-90) teardrop_2d(r=r, truncate=r, $fn=$fn/2);
    if (handleTray) difference() {
      rotate(-22.5) teardrop_2d(r=r, a=67.5, $fn=$fn/2);
      rect([r*2+fudge2, -r-fudge], [0,1]);
      rotate(-45) rect([r*2+fudge2, -r-fudge], [0,1]);
    }
  }

  module handleOuter(r, trunc)
    rotate([0, 90, 0]) extrude(fudge, center=true) handleProfile(r, trunc);

  module handleInner(r, trunc)
    rotate([0, 90, 0]) extrude(fudge, center=true) difference() {
      intersection() {
        translate([0, -dWall2]) handleProfile(r, trunc);
        translate([0,  dWall2]) handleProfile(r, trunc);
      }
      translate([r-dFloor, 0]) rect([dFloor+fudge, r*8], [1,0]);
    }

  module handleCut(r, trunc)
    rotate([0, 90, 0]) extrude(fudge, center=true) translate([r-dFloor, 0]) rect([dLayerHN*2-trunc+dFloor-r, gap], [1,0]);

  // translate([0     ,0,100]) color("blue")  handleOuter(5, 3);
  // translate([fudge ,0,100]) color("green") handleInner(5, 3);
  // translate([fudge2,0,100]) color("red")   handleCut(5, 3);

  module handleSweep(r, a, b, step) translate([0, 0, r]) {
    if (handleElliptical) rotate(180) for (i=[0:step:180-step]) hull() {
      translate([a*cos(i), b*sin(i), 0]) rotate(atan2(b*cos(i), -a*sin(i))) children();
      translate([a*cos(i+step), b*sin(i+step), 0]) rotate(atan2(b*cos(i+step), -a*sin(i+step))) children();
    }
    else {
      if (handleR<b) flipX() translate([a, 0, 0]) tull([0, handleR-b, 0]) rotate(90) children();
      translate([0, -b, 0]) tull([handleR*2-a*2, 0, 0], center=true) children();
      flipX() translate([a-handleR, handleR-b]) hull_rotate_extrude(90) translate([0, -handleR, 0]) children();
    }
  }

  if (l<=r && h>=1) translate([fGridX*(r+l)/2, 0, 0]) {
    difference() {
      union() {
        box([w, drawerY, bodyZ], [0,0,1]);
        // bulges
        translate([0, 0, bulgeZ]) {
          innerBulge = fBulgeIY*2 - dSlop45*2 - fBulgeWall*2;
          for (i=[1:h]) translate([0, 0, fGridY*(i-1)-(i==h?stopH/2:0)]) hull() {
            box([w, drawerY, fBulgeIY*2-dSlop45*2-(i==h?stopH:0)], [0,0,0]);
            translate([0, fBulgeWall/2, 0]) box([w+fBulgeWall*2, drawerY+fBulgeWall, innerBulge-(i==h?stopH:0)], [0,0,0]);
          }
          translate([0, 0, -innerBulge/2]) {
            box([w, drawerY/2+fBulgeWall/2, innerBulge/2-bulgeZ], [0,1,1]);
            hull() {
              box([w, drawerY/2+fBulgeWall/2, innerBulge/2-bulgeZ+fLayerH0], [0,1,1]);
              box([w, drawerY/2+fBulgeWall, innerBulge/2-bulgeZ+fLayerH0+fBulgeWall/2], [0,1,1]);
            }
          }
          translate([0, 0, -(h==1?stopH/2:0)]) hull() {
            translate([0, fBulgeWall/2, -fBulgeWall/2]) box([w, drawerY+fBulgeWall, fBulgeIY*2-dSlop45*2-(h==1?stopH:0)-fBulgeWall], [0,0,0]);
            translate([0, fBulgeWall/2, 0]) box([w+fBulgeWall*2, drawerY+fBulgeWall, innerBulge-(h==1?stopH:0)], [0,0,0]);
          }
        }
        // stops
        translate([0, drawerY/2+fBulgeWall, stopZ])
          extrude(-stopHIdeal-fBulgeWall+dSlopZ-dSlop45) polygon(
          [ [ w/2+fBulgeWall*(1-sqrt(2)), -fBulgeWall*sqrt(2)-fWall2*sqrt(2)/2]
          , [ w/2+fBulgeWall            ,                    -fWall2*sqrt(2)/2]
          , [ w/2+fBulgeWall            ,                     0               ]
          , [-w/2-fBulgeWall            ,                     0               ]
          , [-w/2-fBulgeWall            ,                    -fWall2*sqrt(2)/2]
          , [-w/2-fBulgeWall*(1-sqrt(2)), -fBulgeWall*sqrt(2)-fWall2*sqrt(2)/2]
          ]);
        // back lip block
        translate([0, drawerY/2-dWall2, bodyZ]) box([w, fBulgeWall+dWall2, stopZ-bodyZ-fudge], [0,1,1]);
      }
      // back lip cut
      translate([0, drawerY/2, bodyZ-lipTop]) {
        rL = [w, fBulgeWall];
        difference() {
          eSliceX(-rL.y, rL+[0, fudge], flushL=true, flushR=true, centerX=true, wall2=dWall2);
          rotate([45,0,0]) box([w, -fBulgeWall*sqrt(2), -fBulgeWall*sqrt(2)], [0,1,1]);
        }
        eSliceX(lipTop, rL-[dWall2*2, dWall2], centerX=true, cutAlt=true, wall2=dWall2, layerH=dLayerHN, hFudge=fudge);
        eSliceY(lipTop, [rL.x-dWall2*2, dWall2], translate=[0, rL.y-dWall2], flushT=true, flushB=true, centerX=true, cutAlt=true, wall2=dWall2, layerH=dLayerHN, hFudge=fudge);
      }
      // rail
      flipX() translate([w/2+fBulgeWall, fBulgeWall/2, railZ]) hull() {
        box([fudge, drawerY+fBulgeWall+fudge2, railW+railD*2], [1,0,0]);
        box([-railD, drawerY+fBulgeWall+fudge2, railW], [1,0,0]);
      }
      // bottom slot
      if (bPH>0) for (i=[l:r]) translate([fGridX*i-fGridX*(r+l)/2, dFloat, 0])
        flipX() translate([fSideIX-fSlopXY-claspW-hookTB-dSlopXY, 0, 0]) hull() {
          translate([0, -drawerY/2+dTravel+bIL+bFL+bPL+bBL*(bSH/bPH)-gap, 0]) {
            box([bW+dSlopXY*2, -drawerY, -fudge]);
            translate([0, -bBL*(bSH/bPH), 0]) box([bW+dSlopXY*2, -drawerY, bSH]);
          }
        }
    }
    // bumps
    flipX() translate([w/2+fBulgeWall-railD, 0, railZ]) {
      translate([0, drawerY/2+fBulgeWall, 0]) bump();
      translate([0, -drawerY/2+dFL+dPL+dBL+dInset, 0]) bump();
    }
    // face
    if (drawFace) translate([0, -drawerY/2-gap-dWall2, 0]) {
      box([dWall2, dWall2+gap+fudge, bodyZ], [0,1,1]);
      box([faceX, dWall2, faceZ], [0,1,1]);
    }
    // handle
    if (drawFace && handleReach>0) {
      // naming things is hard, so h & r shaddow outer scope (r means right above, but radius here)
      h = dLayerAbsFloor(handleLip/2 + handleLip*sqrt(2)/2 - dWall2/2 + dLayerHN/2);
      r = (h*2 + dWall2 - dLayerHN)/(2 + sqrt(2)*2);  // derived by removing `dLayerAbsFloor` from above and solving for `handleLip`
      trunc = r*sqrt(2) - dWall2/2 + dLayerHN/2;
      a = faceX/2 - r;
      b = handleReach - r;
      step = 360/$fn;
      layers = dLayerRelFloor(r + trunc - dFloor) / dLayerHN;
      difference() {
        translate([0, -drawerY/2-gap-dWall2, 0]) {
          difference() {
            handleSweep(r, a, b, step) handleOuter(r, trunc);
            translate([0, dWall2, -fudge]) {
              if (r*2-dWall2>handleReach) box([faceX+fudge2, r*2-dWall2-handleReach+fudge, h+fudge2], [0,1,1]);
              if (!handleElliptical && handleR-dWall2>b) box([faceX+fudge2, handleR-dWall2-b+fudge, h+fudge2], [0,1,1]);
            }
            difference() {
              handleSweep(r, a, b, step) handleInner(r, trunc);
              translate([0, dWall2, 0]) box([faceX, -gap-dWall2*2, r+trunc], [0,1,1]);
            }
            difference() {
              handleSweep(r, a, b, step) handleCut(r, trunc);
              translate([0, dWall2, dFloor]) for (i=[0:layers-3]) translate([0, 0, i*dLayerHN])
                box([(a+r+fudge)*(mod(i, 2)==0?1:-1), -gap-dWall2*2, dLayerHN+fudge]);
            }
          }
          if (handleTray) extrude(dFloor) difference() {
            union() {
              if (handleElliptical) scale([a, b]) circle();
              else {
                rect([a*2-handleR*2, b*2], [0,0]);
                rect([a*2, b*2-handleR*2], [0,0]);
                flipX() translate([a-handleR, handleR-b, 0]) circle(handleR);
              }
            }
            translate([0, dWall2]) rect([a*2+fudge2, b], [0,1]);
          }
        }
        translate([0, -drawerY/2-gap, dFloor]) for (i=[0:layers-1]) translate([0, 0, i*dLayerHN]) {
          dir = mod(i, 2)==0 ? 1 : -1;
          box([(a+r+fudge)*dir*-1, -gap-dWall2, dLayerHN+fudge]);
          box([(a-dWall2/2)*dir, -gap-dWall2, dLayerHN+fudge]);
          translate([(a+dWall2/2)*dir, 0, 0]) box([(r-dWall2/2+fudge)*dir, -gap-dWall2, dLayerHN+fudge]);
        }
      }
    }
  }
}



/////////
// BIN //
/////////


module bin(x=1, y=1, h=1) {
  assert(is_num(x) || is_list(x) && len(x)==2);
  assert(is_num(y) || is_list(y) && len(y)==2);
  assert(is_num(h));
  f = is_list(y) ? min(y[0], y[1]) : -(abs(y)-1)/2;
  b = is_list(y) ? max(y[0], y[1]) :  (abs(y)-1)/2;
  l = is_list(x) ? min(x[0], x[1]) : -(abs(x)-1)/2;
  r = is_list(x) ? max(x[0], x[1]) :  (abs(x)-1)/2;
  w = bGridXY*(r-l) + binXY;
  d = bGridXY*(b-f) + binXY;
  echo(f=f, b=b, l=l, r=r);
  if (f<=b && l<=r && h>=1) translate([bGridXY*(r+l)/2, bGridXY*(b+f)/2, 0]) {
    box([w, d, bFloor], [0,0,1]);
    translate([0, 0, bFloor+binR*sqrt(2)/2]) {
      box([w, d, bLayerAbsFloor(fGridY*(h-1)+binZ)-bFloor-binR*sqrt(2)/2], [0,0,1]);
      box([w-binR*(2-sqrt(2)), d-binR*(2-sqrt(2)), -bFloor-binR*sqrt(2)/2], [0,0,1]);
      intersection() {
        hull() flipX() translate([w/2-binR, 0, 0]) difference() {
          rotate([90, 0]) cylinder(d, r=binR, center=true);
          translate([-binR*(1-sqrt(2)/2)/2-fudge, 0, 0]) box([binR*(1+sqrt(2)/2)+fudge2, d+fudge2, binR*2], [0,0,0]);
        }
        hull() flipY() translate([0, d/2-binR, 0]) difference() {
          rotate([0, 90]) cylinder(w, r=binR, center=true);
          translate([0, -binR*(1-sqrt(2)/2)/2-fudge, 0]) box([w+fudge2, binR*(1+sqrt(2)/2)+fudge2, binR*2], [0,0,0]);
        }
      }
    }
  }
}



/////////////////
// HOOK INSERT //
/////////////////


module hookInsert() render() {
  difference() {
    translate([0, 0, -fFloor]) {
      translate([ fGridX/2, 0, 0]) blHook();
      translate([-fGridX/2, 0, 0]) brHook();
    }
    box([fGridX, -fGridY, -fFloor-fudge], [0,1,1]);
  }
  translate([0, -fHornY+fWall2, 0]) box([claspD+stretchX+fWall4*2+fSlopXY*2+lPC*2+lWS*2, -fWall2, fGridZ-fFloor], [0,1,1]);
}



///////////
// DEMOS //
///////////


module demoHooks() {
  translate([     0,       0, 0]) color([0.6,0.6,0.6,1   ]) tHooks();
  translate([     0,  fGridY, 0]) color([0.6,0.6,0.6,0.25]) bHooks();

  translate([     0,       0, 0]) color([0.6,0.6,0.6,1   ]) rHooks();
  translate([fGridX,       0, 0]) color([0.6,0.6,0.6,0.25]) lHooks();

  translate([     0, -fGridY, 0]) color([0.6,0.6,0.6,1   ]) tHooks();
  translate([     0,       0, 0]) color([0.6,0.6,0.6,0.25]) blHook();
  translate([     0,       0, 0]) color([0.6,0.6,0.6,0.25]) brHook();
}

module demoFill(w) {
  echo(flush=2, fillWalls=fillWalls(w, 2, fWall2), fillResidue=fillResidue(w, 2, fWall2), fillResidueShare=fillResidueShare(w, 2, fWall2));
  echo(flush=1, fillWalls=fillWalls(w, 1, fWall2), fillResidue=fillResidue(w, 1, fWall2), fillResidueShare=fillResidueShare(w, 1, fWall2));
  echo(flush=0, fillWalls=fillWalls(w, 0, fWall2), fillResidue=fillResidue(w, 0, fWall2), fillResidueShare=fillResidueShare(w, 0, fWall2));
  baseColor = [0.0, 0.2, 0.4];
  gapColor = [0.4, 0.2, 0.0];
  lineColor = [0.8, 0.5, 0.0];
  cutColor = [0.5, 0.5, 0.5, 0.5];
  baseH = -0.25;
  gapH = 0.1;
  lineH = 0.1;
  cutH = 0.2;
  // normal, tightly packed
  translate([0, 0]) {
    fillWalls = div(w-gap+fudge, fWall2+gap);
    color(baseColor) extrude(baseH) rect([w, 1]);
    if (fillWalls > 0) {
      color(gapColor) extrude(gapH) rect([gap, 1]);
      for (i=[0:fillWalls-1]) translate([i*(fWall2+gap)+gap, 0]) {
        color(lineColor) extrude(lineH) rect([fWall2, 1]);
        color(gapColor) extrude(gapH) translate([fWall2, 0]) rect([gap, 1]);
      }
    }
  }
  // spread evenly
  translate([0, 1.5]) {
    fillWalls = fillWalls(w, 0, fWall2);
    fillWall  = fillWall (w, 0, fWall2);
    fillGap   = fillGap  (w, 0, fWall2);
    fillGrid  = fillGrid (w, 0, fWall2);
    color(baseColor) extrude(baseH) rect([w, 1]);
    if (fillWalls > 0) {
      color(gapColor) extrude(gapH) rect([gap/2, 1]);
      color(gapColor) extrude(gapH) translate([fillGap-gap/2, 0]) rect([gap/2, 1]);
      for (i=[0:fillWalls-1]) translate([i*fillGrid+fillGap, 0]) {
        color(lineColor) extrude(lineH) rect([fWall2/2, 1]);
        color(lineColor) extrude(lineH) translate([fillWall-fWall2/2, 0]) rect([fWall2/2, 1]);
        color(gapColor) extrude(gapH) translate([fillWall, 0]) rect([gap/2, 1]);
        color(gapColor) extrude(gapH) translate([fillGrid-gap/2, 0]) rect([gap/2, 1]);
      }
      for (i=[0:fillWalls-1]) translate([i*fillGrid+fillGap, 0])
        color(cutColor) extrude(cutH) translate([fillWall, 0]) rect([fillGap, 1]);
    }
    color(cutColor) extrude(cutH) rect([fillGap, 1]);
  }
  // flush to end
  translate([0, 3]) {
    fillWalls = fillWalls(w, 1, fWall2);
    fillWall  = fillWall (w, 1, fWall2);
    fillGap   = fillGap  (w, 1, fWall2);
    fillGrid  = fillGrid (w, 1, fWall2);
    color(baseColor) extrude(baseH) rect([w, 1]);
    if (fillWalls > 0) {
      for (i=[0:fillWalls-1]) translate([i*fillGrid, 0]) {
        color(lineColor) extrude(lineH) translate([fillGap, 0]) rect([fWall2/2, 1]);
        color(lineColor) extrude(lineH) translate([fillGrid-fWall2/2, 0]) rect([fWall2/2, 1]);
        color(gapColor) extrude(gapH) rect([gap/2, 1]);
        color(gapColor) extrude(gapH) translate([fillGap-gap/2, 0]) rect([gap/2, 1]);
      }
      for (i=[0:fillWalls-1]) translate([i*fillGrid, 0])
        color(cutColor) extrude(cutH) rect([fillGap, 1]);
    }
    else color(cutColor) extrude(cutH) rect([w, 1]);
  }
  // flush to start
  translate([0, 4.5]) {
    fillWalls = fillWalls(w, 1, fWall2);
    fillWall  = fillWall (w, 1, fWall2);
    fillGap   = fillGap  (w, 1, fWall2);
    fillGrid  = fillGrid (w, 1, fWall2);
    color(baseColor) extrude(baseH) rect([w, 1]);
    if (fillWalls > 0) {
      for (i=[0:fillWalls-1]) translate([i*fillGrid, 0]) {
        color(lineColor) extrude(lineH) rect([fWall2/2, 1]);
        color(lineColor) extrude(lineH) translate([fillWall-fWall2/2, 0]) rect([fWall2/2, 1]);
        color(gapColor) extrude(gapH) translate([fillWall, 0]) rect([gap/2, 1]);
        color(gapColor) extrude(gapH) translate([fillGrid-gap/2, 0]) rect([gap/2, 1]);
      }
      for (i=[0:fillWalls-1]) translate([i*fillGrid, 0])
        color(cutColor) extrude(cutH) translate([fillWall, 0]) rect([fillGap, 1]);
    }
    else color(cutColor) extrude(cutH) rect([w, 1]);
  }
  // flush to start and end
  translate([0, 6]) {
    fillWalls = fillWalls(w, 2, fWall2);
    fillWall  = fillWall (w, 2, fWall2);
    fillGap   = fillGap  (w, 2, fWall2);
    fillGrid  = fillGrid (w, 2, fWall2);
    color(baseColor) extrude(baseH) rect([w, 1]);
    if (fillWalls > 0) {
      for (i=[0:fillWalls-1]) translate([i*fillGrid-fillGap, 0]) {
        if (i>0) color(gapColor) extrude(gapH) rect([gap/2, 1]);
        if (i>0) color(gapColor) extrude(gapH) translate([fillGap-gap/2, 0]) rect([gap/2, 1]);
        color(lineColor) extrude(lineH) translate([fillGap, 0]) rect([fWall2/2, 1]);
        color(lineColor) extrude(lineH) translate([fillGrid-fWall2/2, 0]) rect([fWall2/2, 1]);
      }
      for (i=[0:fillWalls-1]) translate([i*fillGrid-fillGap, 0])
        if (i>0) color(cutColor) extrude(cutH) rect([fillGap, 1]);
    }
    else color(cutColor) extrude(cutH) rect([w, 1]);
  }
  echo();
}

module demoFills() {
  translate([ 0, 32, 0]) demoFill(fWall2*1-gap*1);
  translate([ 0, 24, 0]) demoFill(fWall2*1+gap*0);
  translate([ 0, 16, 0]) demoFill(fWall2*1+gap*1);
  translate([ 0,  8, 0]) demoFill(fWall2*1+gap*2);
  translate([ 0,  0, 0]) demoFill(fWall2*1+gap*3);

  translate([ 3, 32, 0]) demoFill(fWall2*2+gap*0);
  translate([ 3, 24, 0]) demoFill(fWall2*2+gap*1);
  translate([ 3, 16, 0]) demoFill(fWall2*2+gap*2);
  translate([ 3,  8, 0]) demoFill(fWall2*2+gap*3);
  translate([ 3,  0, 0]) demoFill(fWall2*2+gap*4);

  translate([ 7, 32, 0]) demoFill(fWall2*3+gap*1);
  translate([ 7, 24, 0]) demoFill(fWall2*3+gap*2);
  translate([ 7, 16, 0]) demoFill(fWall2*3+gap*3);
  translate([ 7,  8, 0]) demoFill(fWall2*3+gap*4);
  translate([ 7,  0, 0]) demoFill(fWall2*3+gap*5);

  translate([12, 32, 0]) demoFill(fWall2*4+gap*2);
  translate([12, 24, 0]) demoFill(fWall2*4+gap*3);
  translate([12, 16, 0]) demoFill(fWall2*4+gap*4);
  translate([12,  8, 0]) demoFill(fWall2*4+gap*5);
  translate([12,  0, 0]) demoFill(fWall2*4+gap*6);
}

module demoSliceX(r, translate
, flushT=false, flushB=false, flushL=false, flushR=false
, centerX=false, centerY=false
, cutT=false, cutB=false, cutMid=false, cutAlt=false
) difference() {
    // translate([centerX?0:-fudge*sign(r.x), centerY?0:-fudge*sign(r.y)]) rect(r+[fudge2*sign(r.x),fudge2*sign(r.y)], [centerX?0:1,centerY?0:1]);
    rect(r, [centerX?0:1,centerY?0:1]);
    sliceX(r, translate, flushT, flushB, flushL, flushR, centerX, centerY, cutT, cutB, cutMid, cutAlt)
      if ($children > 0) children();
      else rect(r*4, [0,0]);
  }

module demoSliceY(r, translate
, flushT=false, flushB=false, flushL=false, flushR=false
, centerX=false, centerY=false
, cutL=false, cutR=false, cutMid=false, cutAlt=false
) difference() {
    // translate([centerX?0:-fudge*sign(r.x), centerY?0:-fudge*sign(r.y)]) rect(r+[fudge2*sign(r.x),fudge2*sign(r.y)], [centerX?0:1,centerY?0:1]);
    rect(r, [centerX?0:1,centerY?0:1]);
    sliceY(r, translate, flushT, flushB, flushL, flushR, centerX, centerY, cutL, cutR, cutMid, cutAlt)
      if ($children > 0) children();
      else rect(r*4, [0,0]);
  }

module demoSides(trim=true) {
  lSide(x=[ 0.8], z=5, trim=trim);
  rSide(x=[-0.8], z=5, trim=trim);
  tlSide([-2, -1], [-0.8], trim=trim);
  trSide([ 1,  2], [-0.8], trim=trim);
  blSide([-2, -1], [ 0.8], trim=trim);
  brSide([ 1,  2], [ 0.8], trim=trim);
}

module demoPerimeter(x=2, z=2, cornerSize=1, trim=true) {
  assert(is_num(x) || is_list(x) && len(x)==2);
  assert(is_num(z) || is_list(z) && len(z)==2);
  t = is_list(z) ? max(z[0], z[1]) :  (abs(z)-1)/2;
  b = is_list(z) ? min(z[0], z[1]) : -(abs(z)-1)/2;
  l = is_list(x) ? min(x[0], x[1]) : -(abs(x)-1)/2;
  r = is_list(x) ? max(x[0], x[1]) :  (abs(x)-1)/2;
  assert(t-b>=cornerSize);
  assert(r-l>=cornerSize);
  tSide([l+cornerSize, r-cornerSize], [t], trim=false);
  bSide([l+cornerSize, r-cornerSize], [b], trim=false);
  lSide([l], [b, t], trim=false);
  rSide([r], [b, t], trim=false);
  tlSide([l, l+cornerSize-1], [t], trim=false);
  trSide([r, r-cornerSize+1], [t], trim=false);
  blSide([l, l+cornerSize-1], [b], trim=false);
  brSide([r, r-cornerSize+1], [b], trim=false);
  if (trim) {
    tTrim([l+cornerSize, r-cornerSize], [t], print=false);
    bTrim([l+cornerSize, r-cornerSize], [b], print=false);
    lTrim([l], [b+cornerSize, t-cornerSize], print=false);
    rTrim([r], [b+cornerSize, t-cornerSize], print=false);
    tlTrim([l, l+cornerSize-1], [t, t-cornerSize+1], print=false);
    trTrim([r, r-cornerSize+1], [t, t-cornerSize+1], print=false);
    blTrim([l, l+cornerSize-1], [b, b+cornerSize-1], print=false);
    brTrim([r, r-cornerSize+1], [b, b+cornerSize-1], print=false);
  }
}

module demoFrameSmall(drawers=true, trim=true) {
  color([0.6,0.6,0.6,1])
    rotate([90]) {
      translate([-fGridX*3/2, -fGridY*3/2, 0]) {
        frame([0,0], [3,3], hookInserts=true, drawer=drawers);
        frame([0,0], [1,2], hookInserts=true, drawer=drawers);
        frame([0,0], [0,0], hookInserts=true, drawer=drawers);

        frame([1,2], [3,3], hookInserts=true, drawer=drawers);
        frame([1,2], [1,2], hookInserts=true, drawer=drawers);
        frame([1,2], [0,0], hookInserts=true, drawer=drawers);

        frame([3,3], [3,3], hookInserts=true, drawer=drawers);
        frame([3,3], [1,2], hookInserts=true, drawer=drawers);
        frame([3,3], [0,0], hookInserts=true, drawer=drawers);
      }
    }
  color([0.85,0.6,0.0,1])
    rotate([90]) {
      demoPerimeter(4, 4, trim=trim);
  }
}

module demoFrameSmall2(drawers=true, trim=true) {
  color([0.6,0.6,0.6,1])
    rotate([90]) {
      translate([-fGridX*3, -fGridY*3, 0]) {
        frame([0,1], [5,6], hookInserts=true, drawer=drawers);
        frame([0,1], [2,4], hookInserts=true, drawer=drawers);
        frame([0,1], [0,1], hookInserts=true, drawer=drawers);

        frame([2,4], [5,6], hookInserts=true, drawer=drawers);
        frame([2,4], [2,4], hookInserts=true, drawer=drawers);
        frame([2,4], [0,1], hookInserts=true, drawer=drawers);

        frame([5,6], [5,6], hookInserts=true, drawer=drawers);
        frame([5,6], [2,4], hookInserts=true, drawer=drawers);
        frame([5,6], [0,1], hookInserts=true, drawer=drawers);
      }
    }
  color([0.85,0.6,0.0,1])
    rotate([90]) {
      demoPerimeter(7, 7, trim=trim);
  }
}

module demoFrameLarge(drawers=true, trim=true) {
  color([0.6,0.6,0.6,1])
    rotate([90]) {
      frame([-4, -3], [ 2,  2], hookInserts=true, drawer=drawers? 0.0:false);
      frame([-4, -3], [ 1,  1], hookInserts=true, drawer=drawers? 5.0:false);
      frame([-4, -3], [ 0,  0], hookInserts=true, drawer=drawers?10.0:false);
      frame([-4, -3], [-1, -2], hookInserts=true, drawer=drawers? 2.5:false);

      frame([-2, -2], [ 2,  2], hookInserts=true, drawer=drawers? 5.0:false);
      frame([-2, -2], [ 1,  1], hookInserts=true, drawer=drawers?10.0:false);
      frame([-2, -2], [ 0,  0], hookInserts=true, drawer=drawers?20.0:false);
      frame([-2, -1], [-1, -2], hookInserts=true, drawer=drawers? 7.5:false);

      frame([-1,  1], [ 2,  2], hookInserts=true, drawer=drawers?10.0:false);
      frame([-1,  1], [ 1,  1], hookInserts=true, drawer=drawers?20.0:false);
      frame([-1,  1], [ 0,  0], hookInserts=true, drawer=drawers?40.0:false);

      frame([ 0,  0], [-1, -1], hookInserts=true, drawer=drawers?20.0:false);
      frame([ 0,  0], [-2, -2], hookInserts=true, drawer=drawers?10.0:false);

      frame([ 2,  2], [ 2,  2], hookInserts=true, drawer=drawers? 5.0:false);
      frame([ 2,  2], [ 1,  1], hookInserts=true, drawer=drawers?10.0:false);
      frame([ 2,  2], [ 0,  0], hookInserts=true, drawer=drawers?20.0:false);
      frame([ 2,  1], [-1, -2], hookInserts=true, drawer=drawers? 7.5:false);

      frame([ 4,  3], [ 2,  2], hookInserts=true, drawer=drawers? 0.0:false);
      frame([ 4,  3], [ 1,  1], hookInserts=true, drawer=drawers? 5.0:false);
      frame([ 4,  3], [ 0,  0], hookInserts=true, drawer=drawers?10.0:false);
      frame([ 4,  3], [-1, -2], hookInserts=true, drawer=drawers? 2.5:false);
    }
  color([0.85,0.6,0.0,1])
    rotate([90]) {
      demoPerimeter(9, 5, cornerSize=2, trim=trim);
  }
}

module demoFrameLarge2(drawers=true, trim=true) {
  color([0.6,0.6,0.6,1])
    rotate([90]) {
      frame([-8, -7], [ 3,  4], hookInserts=true, drawer=drawers);
      frame([-6, -5], [ 3,  4], hookInserts=true, drawer=drawers);
      frame([-8, -5], [ 1,  2], hookInserts=true, drawer=drawers);
      frame([-8, -5], [-1,  0], hookInserts=true, drawer=drawers);
      frame([-8, -6], [-4, -2], hookInserts=true, drawer=drawers);

      frame([-4, -3], [ 2,  4], hookInserts=true, drawer=drawers);
      frame([-4, -2], [-1,  1], hookInserts=true, drawer=drawers);
      frame([-5, -2], [-4, -2], hookInserts=true, drawer=drawers);

      frame([-2,  2], [ 2,  4], hookInserts=true, drawer=drawers);
      frame([-1,  1], [ 0,  1], hookInserts=true, drawer=drawers);
      frame([-1,  1], [-2, -1], hookInserts=true, drawer=drawers);
      frame([-1,  1], [-4, -3], hookInserts=true, drawer=drawers);

      frame([ 3,  4], [ 2,  4], hookInserts=true, drawer=drawers);
      frame([ 2,  4], [-1,  1], hookInserts=true, drawer=drawers);
      frame([ 2,  5], [-4, -2], hookInserts=true, drawer=drawers);

      frame([ 7,  8], [ 3,  4], hookInserts=true, drawer=drawers);
      frame([ 5,  6], [ 3,  4], hookInserts=true, drawer=drawers);
      frame([ 5,  8], [ 1,  2], hookInserts=true, drawer=drawers);
      frame([ 5,  8], [-1,  0], hookInserts=true, drawer=drawers);
      frame([ 6,  8], [-4, -2], hookInserts=true, drawer=drawers);
    }
  color([0.85,0.6,0.0,1])
    rotate([90]) {
      demoPerimeter(17, 9, cornerSize=2, trim=trim);
  }
}

module demoDrawerBumpAlignment(x=1, h=1, drawer=dTravel)
  rotate([90,0,0]) translate([0, -drawerZFrameYAlign, -drawerYFrameZAlign-drawer]) {
    frame(x, [0, h-1], drawer=drawer, drawFace=false, drawFloor=false, drawSides=false);
    frame(x, [-1, -h], drawTop=false, drawFloor=false, drawSides=false);
  }

module demoDrawerZAlignment(x=1, h=1)
  rotate([90,0,0]) translate([0, -drawerZFrameYAlign, -drawerYFrameZAlign])
    frame(x, [0, h-1], drawer=true, drawFace=false, drawFloor=false);



/////////////////
// FINAL PARTS //
/////////////////


if (Active_model=="fills") demoFills();

if (Active_model=="sides") demoSides(trim=Show_trim_in_assembly_demos);

if (Active_model=="perimeter") color([0.5,0.5,0.5,1]) demoPerimeter();

if (Active_model=="hooks") demoHooks();

if (Active_model=="small assembly")       demoFrameSmall (drawers=Show_drawers_in_assembly_demos, trim=Show_trim_in_assembly_demos);
if (Active_model=="small assembly - h>1") demoFrameSmall2(drawers=Show_drawers_in_assembly_demos, trim=Show_trim_in_assembly_demos);
if (Active_model=="large assembly")       demoFrameLarge (drawers=Show_drawers_in_assembly_demos, trim=Show_trim_in_assembly_demos);
if (Active_model=="large assembly - h>1") demoFrameLarge2(drawers=Show_drawers_in_assembly_demos, trim=Show_trim_in_assembly_demos);

if (Active_model=="bump alignment - drawer shut") demoDrawerBumpAlignment(x=Frame_width, h=Frame_height, drawer=0);
if (Active_model=="bump alignment - drawer open") demoDrawerBumpAlignment(x=Frame_width, h=Frame_height, drawer=dTravel);
if (Active_model=="z alignment") demoDrawerZAlignment(x=Frame_width, h=Frame_height);

if (Active_model=="frame") frame(x=Frame_width, z=Frame_height);
if (Active_model=="drawer") drawer(x=Frame_width, h=Frame_height);
if (Active_model=="bin") bin(x=Bin_width, y=Bin_depth, h=Frame_height);
if (Active_model=="side") {
  if (Side==   "top"      )  tSide(x=Frame_width);
  if (Side==   "top left" ) tlSide(x=Frame_width);
  if (Side==       "left" )  lSide(z=Frame_height);
  if (Side=="bottom left" ) blSide(x=Frame_width);
  if (Side=="bottom"      )  bSide(x=Frame_width);
  if (Side=="bottom right") brSide(x=Frame_width);
  if (Side==       "right")  rSide(z=Frame_height);
  if (Side==   "top right") trSide(x=Frame_width);
}
if (Active_model=="trim") {
  if (Side==   "top"      )  tTrim(x=Frame_width                );
  if (Side==   "top left" ) tlTrim(x=Frame_width, z=Frame_height);
  if (Side==       "left" )  lTrim(               z=Frame_height);
  if (Side=="bottom left" ) blTrim(x=Frame_width, z=Frame_height);
  if (Side=="bottom"      )  bTrim(x=Frame_width                );
  if (Side=="bottom right") brTrim(x=Frame_width, z=Frame_height);
  if (Side==       "right")  rTrim(               z=Frame_height);
  if (Side==   "top right") trTrim(x=Frame_width, z=Frame_height);
}
if (Active_model=="hook insert") hookInsert();



/////////////
// SCRATCH //
/////////////


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


// difference() {
//   drawer(x=3, h=2);
//   // translate([0,0,5.1]) box([100,200, 40], [0,0,1]);
// }

// Side = "top";  // [top, top left, left, bottom left, bottom, bottom right, right, top right]


// color([.5,.5,.5,.125]) slice(dLayerH0, dLayerHN, minH=0, maxH=fGridY*3-dSlopZ, size=[25, 80, 0.01]);

// box([212, 1, 1], [0,0,0]);

// rect([33, 33], [0,0]);

// #translate([0, fBulgeIY, fGridZ]) box([1,1,1], [0,1,0]);
// #translate([0, -34, fBotIY]) box([1,1,1], [0,0,1]);

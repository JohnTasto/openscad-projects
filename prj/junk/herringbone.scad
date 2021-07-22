use <nz/nz.scad>

// not all these parameters are needed!
// just pasting here for now in case it ever becomes useful

spacing = 3;
snap = 0.75;
linkSlop = 0.3;
lidSlop = 0.75;
lidSlop45 = (sqrt(2)-1)*lidSlop;

lineW = 0.6;

baseWall = lineW*4 + 0.01;
lidWall = lineW*6 + 0.01;
grillWall = lineW + 0.01;

ledge = lidWall;

baseW = 100;  // 200;
baseD = 75;   // 150;
baseH = 20;

thumbD = 30;
thumbR = thumbD/2;
thumbX = false;

herringbone = false;
holeMaxW = 15;    // zigzag only
holeMaxD = 2.5;   // zigzag only
gap = 0.03;   // zigzag only   My Cura starts ignoring the gap somewhere around 0.0275-0.02825
centerWLine = false;  // zigzag only
centerDLine = true;  // zigzag only
holeMax = 3;     // herringbone only
holeUnitsL = 5;  // herringbone only
alternate = true;
reverse = false;

tongue = 2.5;
groove = tongue + lidSlop/2;

floorH = 1.5;
topH = 0.5;
grillH = 1.5;

lidW = baseW - baseWall*2 - tongue*2 - lidSlop;
lidD = baseD - baseWall*2 - tongue*2 - lidSlop;
lidH = tongue*2 + lidSlop45/2 + topH;

grillW = lidW - lidWall*2;
grillD = lidD - lidWall*2;

gridW = baseW + spacing;
gridD = baseD + spacing;

linkInnerD = 5;
linkInnerR = linkInnerD/2;
linkOuterD = 8;
linkOuterR = linkOuterD/2;
linkDeltaD = linkOuterD - linkInnerD;
linkDeltaR = linkDeltaD/2;

linkInset = baseWall + linkSlop/2 + linkOuterR;
linkLidR = max(linkInset, baseWall + tongue + linkSlop/2 + linkInnerR) + lidSlop/2;
linkLidCorner = linkInset + sqrt(pow(linkLidR, 2) - pow(baseWall+groove-linkInset, 2));
linkLidA = atan((linkLidCorner-linkInset)/(baseWall+groove-linkInset));

fillet = min(tongue+1, linkInset);


module herringbone() {
  cellMaxL = holeMax + grillWall;
  tileMaxL = cellMaxL * holeUnitsL*2;

  tilesW = ceil(gridW / tileMaxL);
  tilesD = ceil(gridD / tileMaxL);

  cellsW = tilesW * holeUnitsL*2;
  cellsD = tilesD * holeUnitsL*2;

  cellW = gridW / cellsW;
  cellD = gridD / cellsD;

  holeW = cellW - grillWall;
  holeD = cellD - grillWall;

  echo(holeW);
  echo(holeD);

  alt = alternate ? 1 : -1;

  module holeD() box([holeW, cellD*holeUnitsL-grillWall, grillH+1], [1,1,0]);
  module holeW() box([cellW*holeUnitsL-grillWall, holeD, grillH+1], [1,1,0]);

  difference() {
    box([lidW, lidD, grillH], [0,0,0]);
    mirror(reverse ? [1,0,0] : [0,0,1])
      translate([(grillWall-gridW)/2, (grillWall-gridD)/2, 0])
        for (i = [-cellsD : holeUnitsL*2 : cellsW])
          for (j = [-holeUnitsL : cellsD-1])
            translate([cellW*(i+(holeUnitsL/2-0.5)*alt)+cellW*j, cellD*j, 0])
              if (alternate) {
                holeD();
                translate([cellW, 0, 0]) holeW();
              } else {
                holeW();
                translate([0, cellD, 0]) holeD();
              }
  }
}

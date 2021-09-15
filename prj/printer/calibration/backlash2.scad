use <nz/nz.scad>


$fn=60;


function tileMax(holeMax, wall, gap) = [           holeMax.x + wall,   holeMax.y + wall*2 + gap ];
function tiles(bounds, tileMax)      = [ ceil(bounds.x / tileMax.x), ceil(bounds.y / tileMax.y) ];
function tile(bounds, tiles)         = [         bounds.x / tiles.x,         bounds.y / tiles.y ];
function hole(tile, wall, gap)       = [              tile.x - wall,      tile.y - wall*2 - gap ];

module zigzag(bounds, holeMax=[5, 5], tiles=undef, centerLine=[true, true], wall=0.41, gap=0.03, offsets=[[],[]], alternate=false, solid=false, step=0, stepStart=0) {

  tileMax = tileMax(holeMax, wall, gap);
  tiles = is_list(tiles) ? tiles : tiles(bounds, tileMax);
  tile = tile(bounds, tiles);
  hole = hole(tile, wall, gap);

  // echo(str("Tiles:  ", tiles));
  // echo(str("Tile size:  ", tile));
  // echo(str("Hole size:  ", hole));

  extra =
    [ (mod(tiles.x, 2) == 0 ? !centerLine.x :  centerLine.x) ? 1 : 0
    , (mod(tiles.y, 2) == 0 ?  centerLine.y : !centerLine.y) ? 1 : 0
    ];

  mainL = tile.y - wall*sqrt(2) - wall - gap*2*sqrt(2);
  rampL = wall + wall/2*sqrt(2) - gap/2*sqrt(2) + gap*2;
  sideStartX = wall/sqrt(2) + gap*2/sqrt(2) - gap/2;
  sideL = tile.x - wall - gap*sqrt(2);
  connL = wall*2*sqrt(2) - wall + gap*sqrt(2);

  // not used directly, except prior to simplifying some of these expressions
  pointX = wall/sqrt(2) - wall/2 - gap/2;

  bigRampStartY = mainL/2 - wall*sqrt(2) + wall;
  bigRampL = (wall+gap)*(sqrt(2)/2 + 1);
  bigSideL = tile.x + wall*2/sqrt(2) - wall*2 - gap;

  // extra.x == true  ?  outer two past bounds  :  none past bounds
  function x(i) = len(offsets.x) > i-extra.x
    ? i-extra.x < 0 ? -abs(offsets.x[0]) : offsets.x[i-extra.x]
    : len(offsets.x) > tiles.x-i
    ? tiles.x-i < 0 ? abs(offsets.x[0]) : -offsets.x[tiles.x-i]
    : 0;

  // one always past bounds
  function y(j) = len(offsets.y) > j-1
    ? j-1 < 0 ? -abs(offsets.y[0]) : offsets.y[j-1]
    : len(offsets.y) > tiles.y+extra.y-j
    ? tiles.y+extra.y-j < 0 ? abs(offsets.y[0]) : -offsets.y[tiles.y+extra.y-j]
    : 0;

  // for (i = [0 : tiles.x+extra.x]) echo(x(i));
  // for (j = [0 : tiles.y+extra.y]) echo(y(j));

  maskStart = alternate && ((mod(tiles.x, 2) == 0 && centerLine.x) || (mod(tiles.x, 2) == 1 && !centerLine.x)) ? -1 : 0;
  maskEnd = (mod(tiles.x, 2) == 0 && !centerLine.x && alternate) || (mod(tiles.x, 2) == 1 && centerLine.x && !alternate) ? -1 : 0;
  linesExtra = (mod(tiles.x, 2) == 0 && centerLine.x) || (mod(tiles.x, 2) == 1 && !centerLine.x) ? 1 : 0;

  if (!solid) intersection() {
    translate([(-bounds.x-tile.x*extra.x)/2, (-bounds.y-tile.y*extra.y)/2])
      for (i = [-linesExtra : tiles.x+extra.x+linesExtra])
        for (j = [0 : tiles.y+extra.y]) {
          lash = stepStart + step*j;
          move = mod(i, 2) == 0 ? lash : -lash;
          trim = mod(i, 2) == 1 ? step/2 : 0;
          translate([tile.x*i+x(i)-(mod(i,2)==0?lash:0), tile.y*j]) {
            translate([0, y(j)/2+y(j+1)/2]) rect([wall, mainL+y(j+1)-y(j)], [0,0]);
            translate([                        -wall/2,        mainL/2+y(j+1)]) rotate(-45) rect([wall, rampL], [ 1, 1]);
            translate([                         wall/2,       -mainL/2+y(j-0)]) rotate(-45) rect([wall, rampL], [-1,-1]);
            translate([                     sideStartX, tile.y/2-gap/2+y(j+1)]) rotate(-90) rect([wall, sideL-x(i)+x(i+1)+move-trim], [ 1, 1]);
            translate([                    -sideStartX, gap/2-tile.y/2+y(j-0)]) rotate(-90) rect([wall, sideL+x(i)-x(i-1)-move-trim], [-1,-1]);
            translate([ tile.x-(x(i)-x(i+1))+move-trim,       tile.y/2+y(j+1)]) rotate(-45) rect([wall, connL], [0,0]);
            translate([-tile.x-(x(i)-x(i-1))+move+trim,      -tile.y/2+y(j-0)]) rotate(-45) rect([wall, connL], [0,0]);
          }
        }
    offset(delta=wall) if ($children > 0) children(); else rect(bounds, [0,0]);
  }
  intersection() {
    translate([(-bounds.x-tile.x*(extra.x-1))/2, (-bounds.y-tile.y*extra.y)/2])
      for (i = [maskStart : tiles.x+extra.x+maskEnd])
        for (j = [0 : tiles.y+extra.y]) {
          lash = stepStart + step*j;
          move = mod(i, 2) == 0 ? lash : -lash;
          wide = mod(i, 2) == 0 ? 0 : 1;
          temp = mod(i, 2) == 0 ? -1 : 1;
          // if (mod(i, 2) == 0 ? j < (tiles.y+extra.y)/2 : j > (tiles.y+extra.y)/2)
          if (mod(i, 2) == (alternate?1:0))
            translate([tile.x*i-lash/2, tile.y*j]) {
              difference() {
                translate([x(i)/2+x(i+1)/2, y(j)/2+y(j+1)/2]) rect([hole.x+wall*2+x(i+1)-x(i)+move, hole.y+wall*2+y(j+1)-y(j)], [0,0]);
                translate([-hole.x/2-wall+x(i+0)-move/2,  hole.y/2+wall+y(j+1)]) rotate(-45) rect([rampL, rampL], [0,0]);
                translate([ hole.x/2+wall+x(i+1)+move/2, -hole.y/2-wall+y(j-0)]) rotate(-45) rect([rampL, rampL], [0,0]);
              }
              translate([ tile.x/2+wall/2+x(i+1)+move/2,  bigRampStartY+y(j+1)]) tull([-step/2*(wide-0), 0]) rotate(-45) rect([wall*2+gap, bigRampL], [-1, 1]);
              translate([-tile.x/2-wall/2+x(i-0)-move/2, -bigRampStartY+y(j-0)]) tull([-step/2*(wide-1), 0]) rotate(-45) rect([wall*2+gap, bigRampL], [ 1,-1]);
              translate([ tile.x+x(i+1)/2+x(i+2)/2-step/4,  tile.y/2+y(j+1)]) rotate(-90) rect([wall*2+gap, bigSideL-x(i+1)+x(i+2)-move+(wide-1/2)*step], [0,0]);
              translate([-tile.x+x(i-0)/2+x(i-1)/2+step/4, -tile.y/2+y(j-0)]) rotate(-90) rect([wall*2+gap, bigSideL+x(i-0)-x(i-1)-move-(wide-1/2)*step], [0,0]);
              translate([ tile.x+bigSideL/2+x(i+2)-move/2-(1-wide)*step/2,  hole.y/2+y(j+1)]) tull([step/2*(wide-1), 0]) rotate(-45) rect([wall*2+gap, bigRampL], [-1, 1]);
              translate([-tile.x-bigSideL/2+x(i-1)+move/2+(0+wide)*step/2, -hole.y/2+y(j-0)]) tull([step/2*(wide-0), 0]) rotate(-45) rect([wall*2+gap, bigRampL], [ 1,-1]);
            }
        }
    difference() {
      offset(delta=wall) if ($children > 0) children(); else rect(bounds, [0,0]);
      if (!solid) { if ($children > 0) children(); else rect(bounds, [0,0]); }
    }
  }
}


module zigzagMask(bounds, holeMax=[5, 5], tiles=undef, centerLine=[true, true], wall=0.41, gap=0.03, offsets=[[],[]], alternate=false, solid=false, step=0, stepStart=0)
  if ($children > 0)
    intersection() {
      offset(delta=gap)
        zigzag(bounds, holeMax, tiles, centerLine, wall, gap, offsets, alternate, solid, step, stepStart)
          children();
      offset(delta=wall+gap)
        children();
    }
  else
    offset(delta=gap)
      zigzag(bounds, holeMax, tiles, centerLine, wall, gap, offsets, alternate, solid, step, stepStart);

fudge = 0.01;

lineW = 0.4;//0.6;
outerWall = lineW*2;
gridWall = lineW;

layerH0 = 0.32;//0.45;
layerHN = 0.2;//0.3;

layers = 8;
height = layerH0 + layerHN*(layers-1);

size = [40, 160]*2/3;

gap = 0.03;

bounds = size - [.5, 1.25];//[1.75, 3.75];
mask = size - [outerWall*2+lineW*2+gap*2, outerWall*2+lineW*2+gap*2];
holeMax = [1, 4];
tiles = [16, 31];
centerLine = [false, false];
offsets = [[-2], [-3]];
alternate = true;
solid = true;
step = 0.01;
stepStart = -0.16;

tab = 8;

tile = tile(bounds, tiles);

module perimeter() rect(mask, [0,0]);

module tabWall() rotate([90,0,0]) extrude(outerWall, center=true, convexity=2)
  polygon([[0, 0], [height/2-tab, 0], [-height/2-tab, height], [0, height]]);

module tab() {
  translate([0, tab/2-outerWall/2, 0]) tabWall();
  translate([0, outerWall/2-tab/2, 0]) tabWall();
  rotate([90,0,0]) extrude(tab, center=true, convexity=2)
    polygon([[outerWall+height/2-tab, 0], [height/2-tab, 0], [-height/2-tab, height], [outerWall-height/2-tab, height]]);
}

module backlash() {
  extrude(height, convexity=2)
    zigzag(bounds, holeMax, tiles, centerLine, gridWall, gap, offsets, alternate, solid, step, stepStart)
      perimeter();

  extrude(height, convexity=2)
    difference() {
      union() {
        rect(size, [0,0]);
                        translate([size.x/2,        0 ]) rotate(45) square(outerWall*2.5, center=true);
        flipX() flipY() translate([size.x/2, tile.y*5 ]) rotate(45) square(outerWall*1.5, center=true);
        flipX() flipY() translate([size.x/2, tile.y*10]) rotate(45) square(outerWall*1.5, center=true);
                flipY() translate([size.x/2, tile.y*15]) rotate(45) square(outerWall*1.5, center=true);
      }
      perimeter();
      zigzagMask(bounds, holeMax, tiles, centerLine, gridWall, gap, offsets, alternate, solid, step, stepStart)
        perimeter();
    }
  translate(([outerWall-size.x/2, 0, 0])) {
    tab();
    flipY() translate(([0, size.y/2-tab/2, 0])) tab();
    translate([-tab/2, 0, 0]) {
      children();
      translate([0, size.y/2-tab/2, 0]) flipX() translate([outerWall/2+gap/2, 0, 0]) box([outerWall, tab, height], [0,0,1]);
      translate([0, tab/2-size.y/2, 0]) {
        flipX() translate([outerWall/2+gap/2, 0, 0]) box([outerWall, tab, height], [0,0,1]);
        flipY() translate([tab/2, outerWall/2+gap/2, 0]) tabWall();
      }
    }
  }
}

module x() intersection() {
  flipY() shear(xY=1) scale([1,sqrt(2),1]) flipY() translate([tab/2, outerWall/2+gap/2, 0]) tabWall();
  box([tab+height, tab, height], [0,0,1]);
}

module y() {
  flipY() rotate(45) {
    translate([gap/2, -gap/2, 0]) box([(tab/2-outerWall)*sqrt(2)-gap, -outerWall, height]);
    translate([gap/2*(sqrt(2)-1),  gap/2, 0]) box([(tab/2-outerWall-gap/2)*sqrt(2),  outerWall, height]);
  }
  intersection() {
    flipY() translate([tab/2, outerWall/2+gap/2, 0]) tabWall();
    translate([-gap/2*(sqrt(2)-1), 0, 0]) box([tab/2+height/2-gap/2*(sqrt(2)-1), tab, height], [-1,0,1]);
  }
}

// Initial Layer Horizontal Expansion - 0
// Z Seam Relative - true
// Wall Line Count - 1
// Infill Density - 0
// Bottom Layers - 0
// Top Layers - 0

// set Z Seam to Back Right
backlash() x();

// set Z Seam to Back Left
// rotate([0, 0, 90]) backlash() y();

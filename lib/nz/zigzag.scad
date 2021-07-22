use <nz.scad>


function tileMax(holeMax, wall, gap) = [           holeMax.x + wall,   holeMax.y + wall*2 + gap ];
function tiles(bounds, tileMax)      = [ ceil(bounds.x / tileMax.x), ceil(bounds.y / tileMax.y) ];
function tile(bounds, tiles)         = [         bounds.x / tiles.x,         bounds.y / tiles.y ];
function hole(tile, wall, gap)       = [              tile.x - wall,      tile.y - wall*2 - gap ];

module zigzag(bounds, holeMax=[5, 5], tiles=undef, centerLine=[true, true], wall=0.41, gap=0.03, offsets=[[],[]], alternate=false) {

  tileMax = tileMax(holeMax, wall, gap);
  tiles = is_list(tiles) ? tiles : tiles(bounds, tileMax);
  tile = tile(bounds, tiles);
  hole = hole(tile, wall, gap);

  // echo(str("Tiles:  ", tiles));
  // echo(str("Tile size:  ", tile));
  // echo(str("Hole size:  ", hole));

  extra = [
    (mod(tiles.x, 2) == 0 ? !centerLine.x : centerLine.x) ? 1 : 0,
    (mod(tiles.y, 2) == 0 ? centerLine.y : !centerLine.y) ? 1 : 0
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

  intersection() {
    translate([(-bounds.x-tile.x*extra.x)/2, (-bounds.y-tile.y*extra.y)/2])
      for (i = [-linesExtra : tiles.x+extra.x+linesExtra])
        for (j = [0 : tiles.y+extra.y])
          translate([tile.x*i+x(i), tile.y*j]) {
            translate([0, y(j)/2+y(j+1)/2]) rect([wall, mainL+y(j+1)-y(j)], [0,0]);
            translate([              -wall/2,        mainL/2+y(j+1)]) rotate(-45) rect([wall, rampL], [ 1, 1]);
            translate([               wall/2,       -mainL/2+y(j-0)]) rotate(-45) rect([wall, rampL], [-1,-1]);
            translate([           sideStartX, tile.y/2-gap/2+y(j+1)]) rotate(-90) rect([wall, sideL-x(i)+x(i+1)], [ 1, 1]);
            translate([          -sideStartX, gap/2-tile.y/2+y(j-0)]) rotate(-90) rect([wall, sideL+x(i)-x(i-1)], [-1,-1]);
            translate([ tile.x-(x(i)-x(i+1)),       tile.y/2+y(j+1)]) rotate(-45) rect([wall, connL], [0,0]);
            translate([-tile.x-(x(i)-x(i-1)),      -tile.y/2+y(j-0)]) rotate(-45) rect([wall, connL], [0,0]);
          }
    offset(delta=wall) if ($children > 0) children(); else rect(bounds, [0,0]);
  }
  intersection() {
    translate([(-bounds.x-tile.x*(extra.x-1))/2, (-bounds.y-tile.y*extra.y)/2])
      for (i = [maskStart : tiles.x+extra.x+maskEnd])
        for (j = [0 : tiles.y+extra.y])
          // if (mod(i, 2) == 0 ? j < (tiles.y+extra.y)/2 : j > (tiles.y+extra.y)/2)
          if (mod(i, 2) == (alternate?1:0))
            translate([tile.x*i, tile.y*j]) {
              difference() {
                translate([x(i)/2+x(i+1)/2, y(j)/2+y(j+1)/2]) rect([hole.x+wall*2+x(i+1)-x(i), hole.y+wall*2+y(j+1)-y(j)], [0,0]);
                translate([-hole.x/2-wall+x(i+0),  hole.y/2+wall+y(j+1)]) rotate(-45) rect([rampL, rampL], [0,0]);
                translate([ hole.x/2+wall+x(i+1), -hole.y/2-wall+y(j-0)]) rotate(-45) rect([rampL, rampL], [0,0]);
              }
              translate([ tile.x/2+wall/2+x(i+1)  ,  bigRampStartY+y(j+1)]) rotate(-45) rect([wall*2+gap, bigRampL], [-1, 1]);
              translate([-tile.x/2-wall/2+x(i-0)  , -bigRampStartY+y(j-0)]) rotate(-45) rect([wall*2+gap, bigRampL], [ 1,-1]);
              translate([ tile.x+x(i+1)/2+x(i+2)/2,       tile.y/2+y(j+1)]) rotate(-90) rect([wall*2+gap, bigSideL-x(i+1)+x(i+2)], [0,0]);
              translate([-tile.x+x(i-0)/2+x(i-1)/2,      -tile.y/2+y(j-0)]) rotate(-90) rect([wall*2+gap, bigSideL+x(i-0)-x(i-1)], [0,0]);
              translate([ tile.x+bigSideL/2+x(i+2),       hole.y/2+y(j+1)]) rotate(-45) rect([wall*2+gap, bigRampL], [-1, 1]);
              translate([-tile.x-bigSideL/2+x(i-1),      -hole.y/2+y(j-0)]) rotate(-45) rect([wall*2+gap, bigRampL], [ 1,-1]);
            }
    difference() {
      offset(delta=wall) if ($children > 0) children(); else rect(bounds, [0,0]);
      if ($children > 0) children(); else rect(bounds, [0,0]);
    }
  }
}


module zigzagMask(bounds, holeMax=[5, 5], tiles=undef, centerLine=[true, true], wall=0.41, gap=0.03, offsets=[[],[]], alternate=false)
  if ($children > 0)
    intersection() {
      offset(delta=gap)
        zigzag(bounds, holeMax, tiles, centerLine, wall, gap, offsets, alternate)
          children();
      offset(delta=wall+gap)
        children();
    }
  else
    offset(delta=gap)
      zigzag(bounds, holeMax, tiles, centerLine, wall, gap, offsets, alternate);



module demo() {
  bounds = [75, 50];
  holeMax = [8, 8];
  tiles = undef;
  centerLine = [false, true];
  wall = 0.61;
  gap = 0.3;
  offsets = [[-3], [-3]];
  alternate = false;

  module demoPerimeter() {
    module perimeter() {
      size = bounds - [cos($t*360)*10+20, sin($t*1080)*10+15];
      difference() {
        rect(size, [0,0]);
        flipX() flipY() translate(size/2) circle(10);
      }
    }
    color("yellow")
      extrude(1, center=true)
        zigzag(bounds, holeMax, tiles, centerLine, wall, gap, offsets, alternate)
          perimeter();
    color("gray", 0.5)
      extrude(1, center=true)
        difference() {
          rect(bounds, [0,0]);
          perimeter();
          zigzagMask(bounds, holeMax, tiles, centerLine, wall, gap, offsets, alternate)
            perimeter();
        }
  }

  module demoBounds() {
    color("yellow")
      extrude(1, center=true)
        zigzag(bounds, holeMax, tiles, centerLine, wall, gap, offsets, alternate);
    color("blue")
      extrude(-0.5)
        zigzagMask(bounds, holeMax, tiles, centerLine, wall, gap, offsets, alternate);
    color("grey", 0.25)
      extrude(0.5, center=true)
        rect(bounds, [0,0]);
  }

  // demoPerimeter($fn=60);
  demoBounds($fn=60);
}

demo();

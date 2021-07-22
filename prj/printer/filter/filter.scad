/**
  *  Pleated filter
  *
  *    - parametric
  *    - prints without supports
  *    - assembles without screws or glue
  *    - reusable/rebuildable
  *
  *  Copyright 2021 John Tasto
  *
  *
  *  Methods
  *
  *    Full model
  *
  *        `f_assembly(size, wall, sealW, sealD, margin, materialD, endZ, braceZ, minPleatGap, latchW, slack, slop, cup, cutaway)`
  *
  *    Parts aligned for printing
  *
  *    - frame: Print one each
  *
  *        `f_print_frame_base(size, wall, sealD, margin, materialD, endZ, latchW, slack, slop)`
  *        `f_print_frame_cap(size, wall, sealD, margin, materialD, endZ, latchW, slack, slop)`
  *
  *    - folds: Check `f_stats()` to see how many of each to print. There will always be one more
  *      inner fold
  *
  *        `f_print_inner_fold(size, wall, sealW, margin, materialD, braceZ, minPleatGap, slack)`
  *        `f_print_outer_fold(size, wall, sealW, margin, materialD, braceZ, minPleatGap, slack)`
  *
  *    - anchors: Print two. These go inside on the top and bottom to anchor the material in
  *      place.
  *
  *        `f_print_anchor(size, wall, sealW, margin, materialD, endZ, slack, slop)`
  *
  *    - riser: Print two (this method lays out a pair, so print two pairs)
  *      These could be part of the anchors, but they are seperate to avoid requiring
  *      supports.
  *
  *        `f_print_riser(size, wall, sealW, margin, materialD, endZ, braceZ, minPleatGap, slack)`
  *
  *    - shell: Print two (optional, an example of how to hold the cap in place)
  *
  *        `module f_print_cup(size, wall, sealW, sealD, latchW, slack, slop)`
  *
  *    Material requirements
  *
  *        `f_stats(size, wall, sealW, margin, materialD, endZ, braceZ, minPleatGap, slack)`
  *
  *
  *  Method parameters
  *
  *    - `size`: [number, number, number]
  *        [width, depth, height] of the outer dimensions
  *
  *    - `depths`: [number]
  *        used in chain methods to allow varying the depth of each filter element
  *
  *    - `wall`:
  *        narrowest wall thickness of the frame. I like to use at least 3x my line width
  *        otherwise surface quality suffers
  *
  *    - `sealW`:
  *        width of the seal around exit of filter - prevents air from bypassing filter
  *
  *    - `sealD`:
  *
  *    - `margin`:
  *        width of the external perimeter of the frame. It should be
  *          - larger than `wall` to create a groove for the pleats to slide into
  *          - smaller than `sealW` so the seal can make contact with the filter itself
  *            (might not be absolutely necessary depending on tolerances and the desing of
  *            the rest of the ducting)
  *
  *    - `materialD`:
  *        thickness of the filter material. It should be somewhere between completely loose
  *        and completely flat. I measured the thickness of two large fender washers as a
  *        baseline, then sandwiched my material with them to spread out the load, and
  *        measured again. (and then of course subtracted)
  *
  *    - `endZ`:
  *        additional depth the ends sink into the top and bottom. I almost always just set
  *        this to braceZ
  *
  *    - `braceZ`:
  *        narrowest part of the brace that supports the pleats. I usually use about three,
  *        maybe four layer heights worth on small filters. Two is pretty flimsy. You can
  *        also adjust the `beam*()` functions if you want to make further adjustments.
  *
  *    - `minPleatGap`:
  *        the minimum peak to peak distance betwen pleats. The actual distance will likely
  *        be a bit greater to space them evenly
  *
  *    - `latchW`:
  *        width of the latch holding the filter in the cup
  *
  *    - `slack`:
  *        tolerance for gaps that should slide together easily
  *
  *    - `slop`:
  *        tolerance for gaps that should slide together snugly
  *
  *    - `cup`: boolean
  *        render the outer cup
  *
  *    - `cutaway`: boolean
  *        render as a cutaway
  *
  *    Given the condition `margin < wall + materialD + endZ` that would otherwise result
  *    in a degenerate model, it instead hollows out the frame to the level of `endZ`. This
  *    is useful as a fan chamber. Trigger this by setting `materialD > margin`, then set
  *    `endZ = margin-wall` to make it square.
  *
  *
  *  Chain methods
  *
  *    These methods allow creating stacks of filters all built into one unit, for example
  *    a fan, followed by an activated charcole filter, then a hepa filter. Each parameter
  *    ending in an `s` now takes an array with one element per layer. There should of
  *    course be the same number of elements in each array. The `y`/`depth` element of
  *    `size` is ignored, replaced now by the array `depths`. Methods with an `index`
  *    parameter only generate one specific part out of a specific layer; the other methods
  *    work with all layers.
  *
  *    Full model and cutaway
  *
  *        `f_chain_assembly(size, depths, wall, sealWs, sealD, margin, materialDs, endZs, braceZs, minPleatGaps, latchW, slack, slop, cup, cutaway`
  *
  *    Parts aligned for printing
  *
  *    - frame:
  *
  *        `f_chain_print_frame_base(size, depths, wall, sealD, margin, materialDs, endZs, latchW, slack, slop)`
  *        `f_chain_print_frame_cap(size, depths, wall, sealD, margin, materialDs, endZs, latchW, slack, slop)`
  *
  *    - folds:
  *
  *        `f_chain_print_inner_fold(index, size, depths, wall, sealWs, margin, materialDs, braceZs, minPleatGaps, slack)`
  *        `f_chain_print_outer_fold(index, size, depths, wall, sealWs, margin, materialDs, braceZs, minPleatGaps, slack)`
  *
  *    - anchors & risers:
  *
  *        `f_chain_print_anchor(index, size, depths, wall, sealWs, margin, materialDs, endZs, slack, slop)`
  *        `f_chain_print_riser(index, size, depths, wall, sealWs, margin, materialDs, endZs, braceZs, minPleatGaps, slack)`
  *
  *    - shell:
  *
  *        `f_chain_print_cup(size, depths, wall, sealWs, sealD, latchW, slack, slop)`
  *
  *    Material requirements
  *
  *        `f_chain_stats(size, depths, wall, sealWs, sealD, margin, materialDs, endZs, braceZs, minPleatGaps, slack, slop)`
  *
  */

use <nz/nz.scad>;


function f_hollowX(size, wall) = size.x - 2*wall;
function f_hollowY(size, wall) = size.y - 2*wall;
function f_hollowZ(size, margin, materialD, endZ) = size.z - 2*margin + 2*materialD + 2*endZ;

function f_stackX(size, wall, slack) = f_hollowX(size, wall) - slack;
function f_stackY(size, wall, slack) = f_hollowY(size, wall) - slack;
function f_stackZ(size, sealW, braceZ) = size.z - 2*sealW + braceZ;

function f_pleatGap(size, sealW, braceZ, minPleatGap)
  = f_stackZ(size, sealW, braceZ) / floor(f_stackZ(size, sealW, braceZ)/minPleatGap);
function f_pleats(size, sealW, braceZ, minPleatGap)
  = f_stackZ(size, sealW, braceZ) / f_pleatGap(size, sealW, braceZ, minPleatGap);
function f_foldGap(size, sealW, braceZ, minPleatGap)
  = f_pleatGap(size, sealW, braceZ, minPleatGap)/2;

function f_wedgeX(sealW, wall, slack) = sealW - wall - slack/2;
function f_wedgeY(size, wall, materialD, slack) = f_stackY(size, wall, slack) - materialD;
function f_wedgeZ(size, sealW, braceZ, materialD, minPleatGap)
  = f_foldGap(size, sealW, braceZ, minPleatGap) - materialD - braceZ;  // TODO: adjust for angled materialD
function f_wedgeA(size, wall, sealW, materialD, braceZ, minPleatGap, slack)
  = atan(f_wedgeZ(size, sealW, braceZ, materialD, minPleatGap) / f_wedgeY(size, wall, materialD, slack));

function f_funnelH(sealW, margin) = sealW - margin;
function f_sideFunnelA(size, wall, sealW, margin, slack)
  = atan(f_funnelH(sealW, margin) / f_stackY(size, wall, slack));
function f_endFunnelA(size, wall, sealW, margin, materialD, slack)
  = atan(f_funnelH(sealW, margin) / f_wedgeY(size, wall, materialD, slack));

function f_anchorY(size, wall) = f_hollowY(size, wall)/4;
function f_anchorZ(size, wall, margin, materialD, endZ)
  = size.z/2 - f_hollowZ(size, margin, materialD, endZ)/2 - wall;

function f_braceX(size, margin) = size.x - 2*margin;
function f_braceY(size, wall, materialD, slack) = 2/3 * f_wedgeY(size, wall, materialD, slack);

function f_beamD(size, wall, materialD, slack) = 3/16 * f_braceY(size, wall, materialD, slack);
function f_beamFoldD(size, wall, materialD, slack) = 1/4 * f_braceY(size, wall, materialD, slack);
function f_beamBackD(size, wall, materialD, slack) = f_beamD(size, wall, materialD, slack);
function f_beamBackH(braceZ) = 2 * braceZ;

function f_cupSize(size, wall, sealD, slack, slop)
  = [size.x+2*wall+slack, size.y+wall+sealD+slop, size.z+2*wall+slack];
function f_chain_cupSize(size, depths, wall, sealD, slack, slop)
  = f_cupSize([size.x, sum(depths)-(len(depths)-1)*wall, size.z], wall, sealD, slack, slop);


module f_stats(size, wall, sealW, margin, materialD, endZ, braceZ, minPleatGap, slack) {
  if (margin >= wall+materialD+endZ) {
    stackX = f_stackX(size, wall, slack);
    stackY = f_stackY(size, wall, slack);
    pleatGap = f_pleatGap(size, sealW, braceZ, minPleatGap);
    pleats = f_pleats(size, sealW, braceZ, minPleatGap);
    foldGap = f_foldGap(size, sealW, braceZ, minPleatGap);
    wedgeY = f_wedgeY(size, wall, materialD, slack);
    wedgeZ = f_wedgeZ(size, sealW, braceZ, materialD, minPleatGap);
    funnelH = f_funnelH(sealW, margin);
    anchorZ = f_anchorZ(size, wall, margin, materialD, endZ);

    echo(str("Pleat gap: ", pleatGap));
    echo(str("Fold gap: ", foldGap));
    echo(str("Outer folds: ", pleats-1, " `f_fold(even=false)`"));
    echo(str("Inner folds: ", pleats,   " `f_fold(even=true)`"));

    materialL = 2*stackY + 2*anchorZ + 2*endZ + 2*funnelH - braceZ
              + 2*pleats * (materialD + braceZ + norm([wedgeY, wedgeZ]));

    echo("Filter material:");
    echo(str(
      materialL, " x ",
      stackX, " x ",
      materialD, " mm"
    ));
    echo(str(
      inches(materialL), " x ",
      inches(stackX), " x ",
      inches(materialD), " inches"
    ));
  }
  else {
    echo("Open chamber:");
    echo(str(
      size.x-2*wall, " x ",
      size.y-2*wall, " x ",
      size.z-2*margin+2*endZ, " mm"
    ));
    echo(str(
      inches(size.x-2*wall), " x ",
      inches(size.y-2*wall), " x ",
      inches(size.z-2*margin+2*endZ), " inches"
    ));
  }
}

module f_chain_stats(size, depths, wall, sealWs, sealD, margin, materialDs, endZs, braceZs, minPleatGaps, slack, slop) {
  cupSize = f_chain_cupSize(size, depths, wall, sealD, slack, slop);
  echo("Exterior cup size:");
  echo(str(
    cupSize.x, " x ",
    cupSize.y, " x ",
    cupSize.z, " mm"
  ));
  echo(str(
    inches(cupSize.x), " x ",
    inches(cupSize.y), " x ",
    inches(cupSize.z), " inches"
  ));
  for (i = [0:len(depths)-1]) {
    echo();
    echo(str("Layer ", i));
    echo("---------");
    f_stats([size.x, depths[i], size.z], wall, sealWs[i], margin, materialDs[i], endZs[i], braceZs[i], minPleatGaps[i], slack);
  }
}



module f_frame(size, wall, margin, materialD, endZ, slop) {
  hollowX = f_hollowX(size, wall);
  hollowY = f_hollowY(size, wall);
  hollowZ = f_hollowZ(size, margin, materialD, endZ);
  anchorY = f_anchorY(size, wall);
  anchorZ = f_anchorZ(size, wall, margin, materialD, endZ);
  // render(convexity=3)  // breaks `f_frame_cap()`
    difference() {
      box(size, [0,0,0]);
      // main hole
      box([size.x-2*margin, size.y+1, size.z-2*margin], [0,0,0]);
      if (margin >= wall+materialD+endZ) {
        // support channel
        box([hollowX, hollowY, hollowZ], [0,0,0]);
        // anchor channel (would normally add full slop to y, but needs to be tight)
        box([hollowX, anchorY+slop/2+2*materialD, hollowZ+2*anchorZ], [0,0,0]);
      }
      else {
        // hollow it out
        box([hollowX, hollowY, size.z-2*margin+2*endZ], [0,0,0]);
      }
    }
}



module f_frame_base(size, wall, sealD, margin, materialD, endZ, latchW, slack, slop) {
  hollowX = f_hollowX(size, wall);
  hollowY = f_hollowY(size, wall);
  hollowZ = f_hollowZ(size, margin, materialD, endZ);
  cupSize = f_cupSize(size, wall, sealD, slack, slop);
  render(convexity=4)
    union() {
      difference() {
        f_frame(size, wall, margin, materialD, endZ, slop);
        box([size.x-2*margin, size.y+1, size.z-2*margin], [0,0,1]);
        box([hollowX, hollowY, margin>=wall+materialD+endZ?hollowZ:size.z-2*margin+2*endZ], [0,0,1]);
        translate([0, 0, size.z/2+1]) box([size.x+1, size.y+1, wall+1], [0,0,-1]);
      }
      if (latchW > 0)
        flipX() flipZ()
          translate([-size.x/2, size.y/2, 0])
            mirror([0,0,1])
              linear_extrude((cupSize.z/2)*((latchW-wall-slack/2)/latchW), scale=0, convexity=1, slices=0)
                polygon([[0, -1], [0, (sealD/2)*((latchW-wall-slack/2)/(latchW-wall))], [latchW-wall-slack/2, 0], [latchW-wall-slack/2, -1]]);
    }
}

module f_print_frame_base(size, wall, sealD, margin, materialD, endZ, latchW, slack, slop)
  translate([0, 0, size.z/2])
    f_frame_base(size, wall, sealD, margin, materialD, endZ, latchW, slack, slop);

module f_chain_print_frame_base(size, depths, wall, sealD, margin, materialDs, endZs, latchW, slack, slop)
  translate([0, sum(depths)/2-(len(depths)-1)*wall/2, 0])
    union()
      for (i = [0:len(depths)-1])
        translate([0, -sum(take(i, depths))+i*wall-depths[i]/2, 0])
          f_print_frame_base([size.x, depths[i], size.z], wall, sealD, margin, materialDs[i], endZs[i], i==0?latchW:0, slack, slop);


module f_frame_cap(size, wall, sealD, margin, materialD, endZ, latchW, slack, slop)
  render(convexity=4)
    difference() {
      f_frame(size, wall, margin, materialD, endZ, slop);
      minkowski() {
        f_frame_base(size, wall, sealD, margin, materialD, endZ, latchW, slack, slop);
        box([slop, slop, slop/2], [0,0,-1]);
      }
      box(size, [0,0,-1]);  // clean up some OpenSCABs
    }

module f_print_frame_cap(size, wall, sealD, margin, materialD, endZ, latchW, slack, slop)
  rotate([180, 0, 0]) translate([0, 0, -size.z/2])
    f_frame_cap(size, wall, sealD, margin, materialD, endZ, latchW, slack, slop);

module f_chain_print_frame_cap(size, depths, wall, sealD, margin, materialDs, endZs, latchW, slack, slop)
  translate([0, sum(depths)/2-(len(depths)-1)*wall/2, 0])
    union()
      for (i = [0:len(depths)-1])
        translate([0, -sum(take(i, depths))+i*wall-depths[i]/2, 0])
          f_print_frame_cap([size.x, depths[i], size.z], wall, sealD, margin, materialDs[i], endZs[i], latchW, slack, slop);



module f_fold(even, size, wall, sealW, margin, materialD, braceZ, minPleatGap, slack) {
  stackX = f_stackX(size, wall, slack);
  stackY = f_stackY(size, wall, slack);
  wedgeX = f_wedgeX(sealW, wall, slack);
  wedgeY = f_wedgeY(size, wall, materialD, slack);
  wedgeZ = f_wedgeZ(size, sealW, braceZ, materialD, minPleatGap);
  funnelH = f_funnelH(sealW, margin);
  sideFunnelA = f_sideFunnelA(size, wall, sealW, margin, slack);
  braceX = f_braceX(size, margin);
  braceY = f_braceY(size, wall, materialD, slack);
  beamD = f_beamD(size, wall, materialD, slack);
  beamFoldD = f_beamFoldD(size, wall, materialD, slack);
  beamBackD = f_beamBackD(size, wall, materialD, slack);
  beamBackH = f_beamBackH(braceZ);
  render(convexity=5)
    rotate([0,180,even?0:180])
      translate([0, -stackY/2, 0]) {
        flipX()
          difference() {
            // wedge
            translate([-stackX/2, 0, 0]) rotate([90,0,90])
              linear_extrude(wedgeX, convexity=1, slices=0)
                polygon([
                  [0,       braceZ/2+wedgeZ],
                  [wedgeY,  braceZ/2],
                  [wedgeY, -braceZ/2],
                  [0,      -braceZ/2-wedgeZ],
                ]);
            // funnel
            translate([-braceX/2, even?stackY:0, 0]) rotate(sideFunnelA*(even?1:-1))
              box([funnelH, norm([stackY, funnelH]), 2*wedgeZ+braceZ+1], [1,even?-1:1,0]);
          }
        // brace
        translate([0, wedgeY, 0])
          multmatrix(m = [[1, 0, 0, 0], [0, 1, 0, 0], [0, wedgeZ/wedgeY, 1, 0], [0, 0, 0, 1]]) {
            // fold edge
            box([braceX+1, beamFoldD, braceZ], [0,-1,0]);
            // middle
            box([beamD, braceY, braceZ], [0,-1,0]);
            translate([0, -braceY, 0]) {
              // back
              translate([0, 0, beamBackH/2-braceZ/2]) box([braceX+1, beamBackD, beamBackH], [0,1,0]);
              supportY = braceY-beamFoldD-beamBackD+beamD;
              // angles
              flipX() translate([-braceX/2, beamBackD-beamD, 0]) rotate(atan(2*supportY/braceX))
                box([norm([braceX/2, supportY]), beamD, braceZ], [1,1,0]);
            }
          }
      }
}

module f_print_inner_fold(size, wall, sealW, margin, materialD, braceZ, minPleatGap, slack) {
  stackY = f_stackY(size, wall, slack);
  wedgeY = f_wedgeY(size, wall, materialD, slack);
  wedgeZ = f_wedgeZ(size, sealW, braceZ, materialD, minPleatGap);
  wedgeA = f_wedgeA(size, wall, sealW, materialD, braceZ, minPleatGap, slack);
  rotate([180+wedgeA, 0, 0]) translate([0, stackY/2-wedgeY/2, -wedgeZ/2-braceZ/2]) render(convexity=5)
    f_fold(true, size, wall, sealW, margin, materialD, braceZ, minPleatGap, slack);
}

module f_print_outer_fold(size, wall, sealW, margin, materialD, braceZ, minPleatGap, slack) {
  stackY = f_stackY(size, wall, slack);
  wedgeY = f_wedgeY(size, wall, materialD, slack);
  wedgeZ = f_wedgeZ(size, sealW, braceZ, materialD, minPleatGap);
  wedgeA = f_wedgeA(size, wall, sealW, materialD, braceZ, minPleatGap, slack);
  rotate([180-wedgeA, 0, 0]) translate([0, wedgeY/2-stackY/2, -wedgeZ/2-braceZ/2]) render(convexity=5)
    f_fold(false, size, wall, sealW, margin, materialD, braceZ, minPleatGap, slack);
}

module f_chain_print_inner_fold(index, size, depths, wall, sealWs, margin, materialDs, braceZs, minPleatGaps, slack)
  f_print_inner_fold([size.x, depths[index], size.z], wall, sealWs[index], margin, materialDs[index], braceZs[index], minPleatGaps[index], slack);

module f_chain_print_outer_fold(index, size, depths, wall, sealWs, margin, materialDs, braceZs, minPleatGaps, slack)
  f_print_outer_fold([size.x, depths[index], size.z], wall, sealWs[index], margin, materialDs[index], braceZs[index], minPleatGaps[index], slack);



module f_anchor(size, wall, sealW, margin, materialD, endZ, slack, slop) {
  stackX = f_stackX(size, wall, slack);
  stackY = f_stackY(size, wall, slack);
  wedgeX = f_wedgeX(sealW, wall, slack);
  wedgeY = f_wedgeY(size, wall, materialD, slack);
  funnelH = f_funnelH(sealW, margin);
  sideFunnelA = f_sideFunnelA(size, wall, sealW, margin, slack);
  anchorY = f_anchorY(size, wall);
  anchorZ = f_anchorZ(size, wall, margin, materialD, endZ);
  braceX = f_braceX(size, margin);
  render(convexity=2) {
    difference() {
      translate([-stackX/2, stackY/2-wedgeY, 0])
        rotate([90,0,90])
          linear_extrude(stackX, convexity=1, slices=0)
            polygon([
              [0,      endZ+funnelH],
              [wedgeY, endZ],
              [wedgeY, 0],
              [0,      0],
            ]);
      flipX()
        difference() {
          translate([-stackX/2-1, 0, -1])
            box([wedgeX+slop/2+1, anchorY+slop, endZ+funnelH+2], [1,0,1]);
          translate([-braceX/2+slop/2, stackY/2, -2]) rotate(sideFunnelA)
            box([funnelH, norm([stackY, funnelH]), endZ+funnelH+4], [1,-1,1]);
        }
    }
    difference() {
      translate([0, 0, -anchorZ]) box([braceX-slop, anchorY, endZ+anchorZ], [0,0,1]);
      flipX() translate([-braceX/2+slop/2, stackY/2, -anchorZ-1]) rotate(sideFunnelA)
        box([funnelH, norm([stackY, funnelH]), endZ+anchorZ+2], [-1,-1,1]);
    }
  }
}

module f_print_anchor(size, wall, sealW, margin, materialD, endZ, slack, slop) {
  stackY = f_stackY(size, wall, slack);
  wedgeY = f_wedgeY(size, wall, materialD, slack);
  funnelH = f_funnelH(sealW, margin);
  endFunnelA = f_endFunnelA(size, wall, sealW, margin, materialD, slack);
  rotate([180+endFunnelA, 0, 0]) translate([0, wedgeY/2-stackY/2, -funnelH/2-endZ])
    f_anchor(size, wall, sealW, margin, materialD, endZ, slack, slop);
}

module f_chain_print_anchor(index, size, depths, wall, sealWs, margin, materialDs, endZs, slack, slop)
  f_print_anchor([size.x, depths[index], size.z], wall, sealWs[index], margin, materialDs[index], endZs[index], slack, slop);



module f_riser(size, wall, sealW, margin, materialD, endZ, braceZ, minPleatGap, slack) {
  stackY = f_stackY(size, wall, slack);
  wedgeX = f_wedgeX(sealW, wall, slack);
  wedgeY = f_wedgeY(size, wall, materialD, slack);
  wedgeZ = f_wedgeZ(size, sealW, braceZ, materialD, minPleatGap);
  funnelH = f_funnelH(sealW, margin);
  sideFunnelA = f_sideFunnelA(size, wall, sealW, margin, slack);
  anchorY = f_anchorY(size, wall);
  anchorZ = f_anchorZ(size, wall, margin, materialD, endZ);
  render(convexity=2)
    difference() {
      union() {
        translate([0, stackY/2-wedgeY, 0])
          rotate([90,0,90])
            linear_extrude(wedgeX, convexity=1, slices=0)
              polygon([
                [0,      endZ+funnelH],
                [wedgeY, endZ+funnelH+wedgeZ],
                [wedgeY, endZ],
              ]);
        translate([0, 0, -anchorZ]) box([wedgeX, anchorY, endZ+funnelH+anchorZ], [1,0,1]);
      }
      translate([margin-wall-slack/2, stackY/2, -anchorZ-1]) rotate(sideFunnelA)
        box([funnelH, norm([stackY, funnelH]), endZ+funnelH+anchorZ+wedgeZ+2], [1,-1,1]);
    }
}

module f_print_riser(size, wall, sealW, margin, materialD, endZ, braceZ, minPleatGap, slack) {
  stackY = f_stackY(size, wall, slack);
  wedgeY = f_wedgeY(size, wall, materialD, slack);
  wedgeZ = f_wedgeZ(size, sealW, braceZ, materialD, minPleatGap);
  wedgeA = f_wedgeA(size, wall, sealW, materialD, braceZ, minPleatGap, slack);
  funnelH = f_funnelH(sealW, margin);
  rotate([180-wedgeA, 0, 0]) flipX() translate([2.5, wedgeY/2-stackY/2, -funnelH-endZ-wedgeZ/2])
    f_riser(size, wall, sealW, margin, materialD, endZ, braceZ, minPleatGap, slack);
}

module f_chain_print_riser(index, size, depths, wall, sealWs, margin, materialDs, endZs, braceZs, minPleatGaps, slack)
  f_print_riser([size.x, depths[index], size.z], wall, sealWs[index], margin, materialDs[index], endZs[index], braceZs[index], minPleatGaps[index], slack);



module f_cup(size, wall, sealW, sealD, latchW, slack, slop) {
  cupSize = f_cupSize(size, wall, sealD, slack, slop);
  render(convexity=3)
    translate([0, size.y/2+slop/2+sealD/2+wall/2, 0]) {
      difference() {
        box([cupSize.x, cupSize.y, cupSize.z/2], [0,-1,-1]);
        translate([0, 1, 0]) box([cupSize.x-2*wall, cupSize.y-wall+1, cupSize.z-2*wall], [0,-1,0]);
        box([size.x-2*sealW, cupSize.y+1, size.z-2*sealW], [0,-1,0]);
      }
      flipX()
        difference() {
          translate([-cupSize.x/2, 0, 0])
            mirror([0,0,1])
              linear_extrude(cupSize.z/2, scale=0, convexity=1, slices=0)
                polygon([[0, 0], [0, latchW], [latchW, 0]]);
          translate([-cupSize.x/2+wall, 0, 0])
            mirror([0,0,1])
              linear_extrude((cupSize.z/2)*((latchW-wall)/latchW), scale=0, convexity=1, slices=0)
                polygon([[0, -1], [0, sealD/2], [latchW-wall, 0], [latchW-wall, -1]]);
        }
    }
}

module f_print_cup(size, wall, sealW, sealD, latchW, slack, slop)
  translate([0, 0, size.z/2+wall+slack/2])
    f_cup(size, wall, sealW, sealD, latchW, slack, slop);

module f_chain_cup(size, depths, wall, sealWs, sealD, latchW, slack, slop)
  f_cup([size.x, sum(depths)-(len(depths)-1)*wall, size.z], wall, sealWs[len(sealWs)-1], sealD, latchW, slack, slop);

module f_chain_print_cup(size, depths, wall, sealWs, sealD, latchW, slack, slop)
  translate([0, 0, size.z/2+wall+slack/2])
    f_chain_cup(size, depths, wall, sealWs, sealD, latchW, slack, slop);



module f_assembly(size, wall, sealW, sealD, margin, materialD, endZ, braceZ, minPleatGap, latchW, slack, slop, cutaway=false) {
  hollowZ = f_hollowZ(size, margin, materialD, endZ);
  stackX = f_stackX(size, wall, slack);
  stackZ = f_stackZ(size, sealW, braceZ);
  pleats = f_pleats(size, sealW, braceZ, minPleatGap);
  foldGap = f_foldGap(size, sealW, braceZ, minPleatGap);
  difference() {
    union() {
      color("#3CE600") f_frame_base(size, wall, sealD, margin, materialD, endZ, latchW, slack, slop);
      color("#3CE600") if(!cutaway) f_frame_cap(size, wall, sealD, margin, materialD, endZ, latchW, slack, slop);
      if (margin >= wall+materialD+endZ) {
        translate([0, 0, -stackZ/2+foldGap]) {
          color("#6A0899")
            f_fold(true, size, wall, sealW, margin, materialD, braceZ, minPleatGap, slack);
          for (i = [1:round(pleats)-1]) {
            color("#B857E6") translate([0, 0, 2*i*foldGap-foldGap])
              f_fold(false, size, wall, sealW, margin, materialD, braceZ, minPleatGap, slack);
            color("#6A0899") translate([0, 0, 2*i*foldGap])
              f_fold(true, size, wall, sealW, margin, materialD, braceZ, minPleatGap, slack);
          }
        }
        flipZ() translate([0, 0, -hollowZ/2+materialD]) {
          color("#990F27")
            f_anchor(size, wall, sealW, margin, materialD, endZ, slack, slop);
          color("#E63C59") flipX() translate([-stackX/2, 0, 0])
            f_riser(size, wall, sealW, margin, materialD, endZ, braceZ, minPleatGap, slack);
        }
      }
    }
    if (cutaway) color("#222222") box(2*size, [1,0,0]);
  }
}

module f_chain_assembly(size, depths, wall, sealWs, sealD, margin, materialDs, endZs, braceZs, minPleatGaps, latchW, slack, slop, cup=false, cutaway=false) {
  cupSize = f_chain_cupSize(size, depths, wall, sealD, slack, slop);
  translate([0, sum(depths)/2-(len(depths)-1)*wall/2+(cup?sealD/2+wall/2:0), 0])
    for (i = [0:len(depths)-1])
      translate([0, i*wall-sum(take(i, depths))-depths[i]/2, 0])
        f_assembly([size.x, depths[i], size.z], wall, sealWs[i], sealD, margin, materialDs[i],
                    endZs[i], braceZs[i], minPleatGaps[i], i==0?latchW:0, slack, slop, cutaway);
  if (cup)
    if (cutaway)
      difference() {
        color("#E63C59") f_chain_cup(size, depths, wall, sealWs, sealD, latchW, slack, slop);
        color("#222222") box(2*cupSize, [1,0,0]);
      }
    else
      flipZ()
        color("#E63C59") f_chain_cup(size, depths, wall, sealWs, sealD, latchW, slack, slop);
}



module f_demo() {
  lineW = 0.4;
  slop = 0.3;
  slack = 0.5;

  fan = 80;

  carbon = 2.5;  // ~1.75 to ~5.0
  hepa = 0.5;    // ~0.4  to ~0.7


  size = [fan, 25, fan];
  wall = 4*lineW + 0.01;
  sealW = mm(0.5);
  sealD = 2;
  margin = mm(0.5)/2;
  materialD = hepa;
  endZ = 0.75;
  braceZ = 0.75;
  minPleatGap = 7;
  latchW = 2*wall + slack/2;

  f_stats(size, wall, sealW, margin, materialD, endZ, braceZ, minPleatGap, slack);

  // f_fold(true, size, wall, sealW, margin, materialD, braceZ, minPleatGap, slack);
  // f_fold(false, size, wall, sealW, margin, materialD, braceZ, minPleatGap, slack);
  // f_anchor(size, wall, sealW, margin, materialD, endZ, slack, slop);
  // f_riser(size, wall, sealW, margin, materialD, endZ, braceZ, minPleatGap, slack);
  // f_cup(size, wall, sealW, sealD, latchW, slack, slop);

  // f_print_frame_base(size, wall, sealD, margin, materialD, endZ, latchW, slack, slop);
  // f_print_frame_cap(size, wall, sealD, margin, materialD, endZ, latchW, slack, slop);
  // f_print_inner_fold(size, wall, sealW, margin, materialD, braceZ, minPleatGap, slack);
  // f_print_outer_fold(size, wall, sealW, margin, materialD, braceZ, minPleatGap, slack);
  // f_print_anchor(size, wall, sealW, margin, materialD, endZ, slack, slop);
  // f_print_riser(size, wall, sealW, margin, materialD, endZ, braceZ, minPleatGap, slack);
  // f_print_cup(size, wall, sealW, sealD, latchW, slack, slop);

  f_assembly(size, wall, sealW, sealD, margin, materialD, endZ, braceZ, minPleatGap, latchW, latchW, slack, slop, true);
}

// f_demo();


module f_chain_demo() {
  lineW = 0.4;
  slop = 0.3;
  slack = 0.5;

  fan = 80;

  carbon = 2.5;  // ~1.75 to ~5.0
  hepa = 0.5;    // ~0.4  to ~0.7


  wall = 5*lineW + 0.01;
  sealW = 12.5;
  sealD = 2.25;  // 3.75 on filter   fills between 0.6 - 5.5
  margin = sealW/2;
  size = [fan+2*(wall+2.25), 0, fan+2*(wall+2.25)];
  depths =       [25+2*(wall+2.25), 30,                 30   ];
  sealWs =       [0,                margin,             sealW];
  materialDs =   [100,              carbon,             hepa ];
  braceZs =      [0,                0.75,               0.75 ];
  endZs =        [margin-wall,      margin-wall-carbon, 0.75 ];
  minPleatGaps = [0,                14,                 7    ];
  latchW = wall + slack/2 + margin/2;

  index = 2;

  f_chain_stats(size, depths, wall, sealWs, sealD, margin, materialDs, endZs, braceZs, minPleatGaps, slack, slop);

  // f_chain_print_frame_base(size, depths, wall, sealD, margin, materialDs, endZs, latchW, slack, slop);
  // f_chain_print_frame_cap(size, depths, wall, sealD, margin, materialDs, endZs, latchW, slack, slop);
  // f_chain_print_inner_fold(index, size, depths, wall, sealWs, margin, materialDs, braceZs, minPleatGaps, slack);
  // f_chain_print_outer_fold(index, size, depths, wall, sealWs, margin, materialDs, braceZs, minPleatGaps, slack);
  // f_chain_print_anchor(index, size, depths, wall, sealWs, margin, materialDs, endZs, slack, slop);
  // f_chain_print_riser(index, size, depths, wall, sealWs, margin, materialDs, endZs, braceZs, minPleatGaps, slack);
  // f_chain_print_cup(size, depths, wall, sealWs, sealD, latchW, slack, slop);

  f_chain_assembly(size, depths, wall, sealWs, sealD, margin, materialDs, endZs, braceZs, minPleatGaps, latchW, slack, slop, true, true);
}

f_chain_demo();

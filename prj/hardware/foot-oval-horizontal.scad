use <nz/nz.scad>


ffn = 32;
cfn = 128;

fudge  = 0.01;
fudge2 = 0.02;

slop = 0.15;

lineW = 0.6;


ribsC = 2;
ribsS = 3;
ribH = lineW*2 - slop;
ribR = lineW*2;
ribFrontInset = 1;
ribBackInset = 2;

legH = 31;
legW = 70;
legD = 75;
wall = lineW*6;
cupH = legH + ribH*2 + wall*2;
cupW = legW + ribH*2 + wall*2;
cupD = legD - wall;

ribB = ribBackInset + ribR;
ribF = legD - ribFrontInset - ribR;
ribSL = (legW - legH + (ribsC>0 ? (legH+ribR*2)*PI/(ribsC*2) : 0))*(ribsC>0 ? 1 : 1+2/ribsS);


translate([0, 0, wall]) {
  // base cup center
  translate([0, 0, fudge]) extrude(-wall-fudge) rect([cupW-wall*2, cupH-wall*2], [0,0], r=cupH/2-wall, $fn=cfn);
  // base cup revolutions
  flipX() translate([cupW/2-cupH/2, 0, 0]) rotate(-90) revolve(180, $fn=cfn) translate([cupH/2-wall, 0]) intersection() {
    rotate(180) teardrop(wall, truncate=wall, $fn=ffn);
    translate([-fudge, fudge]) rect([wall+fudge, wall+fudge], [1,-1]);
  }
  // base cup extrusions
  translate([0, cupH/2-wall, 0]) rotate([90, 0, 90]) extrude(cupW-cupH, center=true) intersection() {
    rotate(180) teardrop(wall, truncate=wall, $fn=ffn);
    translate([-fudge, fudge]) rect([wall+fudge, wall+fudge], [1,-1]);
  }
  translate([0, wall-cupH/2, 0]) {
    // base foot revolutions
    flipX() translate([cupW/2-wall, 0, 0]) rotate(-90) revolve(180, $fn=ffn) intersection() {
      rotate(180) teardrop(wall, truncate=wall, $fn=ffn);
      translate([0, fudge]) rect([wall, wall+fudge], [1,-1]);
    }
    // base foot extrusions
    rotate([90, 0, 90]) extrude(cupW-wall*2, center=true) intersection() {
      rotate(180) teardrop(wall, truncate=wall, $fn=ffn);
      translate([0, fudge]) rect([wall*2, wall+fudge], [0,-1]);
    }
  }

  extrude(cupD) difference() {
    // cup shell
    union() {
      rect([cupW, cupH], [0,0], r=cupH/2, $fn=cfn);
      translate([0, -cupH/2]) rect([cupW, wall*2], [0,1], r=wall, $fn=ffn);
    }
    // cup cavity
    rect([cupW-wall*2, cupH-wall*2], [0,0], r=cupH/2-wall, $fn=cfn);
  }
  intersection() {
    // ribs
    union() {
      translate([0, 0, ribB]) extrude(ribF-ribB, convexity=2) {
        if (ribsC>0) flipX() translate([cupW/2-cupH/2, 0]) rotate(90/ribsC-90)
          ring(ribsC, a=180/ribsC) translate([legH/2+ribR, 0]) circle(ribR, $fn=ffn);
        if (ribsS>0) flipY() translate([-ribSL/2, legH/2+ribR]) for (i=[1:ribsS])
          translate([ribSL*i/(ribsS+1), 0]) circle(ribR, $fn=ffn);
      }
      translate([0, 0, ribB]) {
        if (ribsC>0) flipX() translate([cupW/2-cupH/2, 0, 0]) rotate(90/ribsC-90)
          ring(ribsC, a=180/ribsC) translate([legH/2+ribR, 0, 0]) spindle(0, r=ribR, $fn=ffn);
        if (ribsS>0) flipY() translate([-ribSL/2, legH/2+ribR, 0]) for (i=[1:ribsS])
          translate([ribSL*i/(ribsS+1), 0, 0]) spindle(0, r=ribR, $fn=ffn);
      }
      translate([0, 0, ribF]) {
        if (ribsC>0) flipX() translate([cupW/2-cupH/2, 0, 0]) rotate(90/ribsC-90)
          ring(ribsC, a=180/ribsC) translate([legH/2+ribR, 0, 0]) spindle(0, r=ribR, $fn=ffn);
        if (ribsS>0) flipY() translate([-ribSL/2, legH/2+ribR, 0]) for (i=[1:ribsS])
          translate([ribSL*i/(ribsS+1), 0, 0]) spindle(0, r=ribR, $fn=ffn);
          // translate([ribSL*i/(ribsS+1), 0, 0]) ball(ribR, $fn=ffn);
      }
    }
    union() {
      // cup shell
      extrude(cupD, convexity=2) {
        rect([cupW, cupH], [0,0], r=cupH/2, $fn=cfn);
        translate([0, -cupH/2]) rect([cupW, wall*2], [0,1], r=wall, $fn=ffn);
      }
      translate([0, 0, cupD]) rotate([0, 180, 0]) {
        // top cup center
        translate([0, 0, fudge]) extrude(-wall-fudge) rect([cupW-wall*2, cupH-wall*2], [0,0], r=cupH/2-wall, $fn=cfn);
        // top cup revolutions
        flipX() translate([cupW/2-cupH/2, 0, 0]) rotate(-90) revolve(180, $fn=cfn) translate([cupH/2-wall, 0]) intersection() {
          circle(wall, $fn=ffn);
          translate([-fudge, fudge]) rect([wall+fudge, wall+fudge], [1,-1]);
        }
        // top cup extrusions
        translate([0, cupH/2-wall, 0]) rotate([90, 0, 90]) extrude(cupW-cupH, center=true) intersection() {
          circle(wall, $fn=ffn);
          translate([-fudge, fudge]) rect([wall+fudge, wall+fudge], [1,-1]);
        }
      }
    }
  }

  translate([0, 0, cupD]) rotate([0, 180, 0]) {
    // top cup revolutions
    flipX() translate([cupW/2-cupH/2, 0, 0]) rotate(-90) revolve(180, $fn=cfn) translate([cupH/2-wall, 0]) intersection() {
      circle(wall, $fn=ffn);
      translate([0, fudge]) rect([wall, wall+fudge], [1,-1]);
    }
    // top cup extrusions
    translate([0, cupH/2-wall, 0]) rotate([90, 0, 90]) extrude(cupW-cupH, center=true) intersection() {
      circle(wall, $fn=ffn);
      translate([0, fudge]) rect([wall, wall+fudge], [1,-1]);
    }
    translate([0, wall-cupH/2, 0]) {
      // top foot revolutions
      flipX() translate([cupW/2-wall, 0, 0]) rotate(-90) revolve(180, $fn=ffn) intersection() {
        circle(wall, $fn=ffn);
        translate([0, fudge]) rect([wall, wall+fudge], [1,-1]);
      }
      difference() {
        // top foot extrusions
        rotate([90, 0, 90]) extrude(cupW-wall*2, center=true) intersection() {
          circle(wall, $fn=ffn);
          translate([0, fudge]) rect([wall*2, wall+fudge], [0,-1]);
        }
        translate([0, cupH/2-wall/2, fudge2]) extrude(-wall-fudge2) rect([cupW-wall, cupH-wall], [0,0], r=cupH/2-wall/2, $fn=cfn);
      }
    }
  }
}

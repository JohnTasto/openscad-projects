use <nz/nz.scad>


ffn = 32;
cfn = 112;
rfn = 512;

fudge  = 0.01;
fudge2 = 0.02;

slop = 0.15;

lineW = 0.6;


ribsC = 4;
ribsS = 2;
ribH = lineW*2 - slop;
ribR = lineW*2;
ribFrontInset = 1;
ribBackInset = 2;

legH = 70.50;
legW = 27.75;
legD = 75;
wall = lineW*6;
cupH = legH + ribH*2 + wall*2;
cupW = legW + ribH*2 + wall*2;
cupD = legD - wall;
cupR = 315;

arcL = (cupD*180)/(cupR*PI);
ribB = ((ribBackInset+ribR)*180)/(cupR*PI);
ribF = ((legD-ribFrontInset-ribR)*180)/(cupR*PI);
ribSL = (legH - legW + (ribsC>0 ? (legW+ribR*2)*PI/(ribsC*2) : 0))*(ribsC>0 ? 1 : 1+2/ribsS);


flipX(copy=false)
translate([0, 0, wall]) {
  // base cup center
  translate([0, 0, fudge]) extrude(-wall-fudge) rect([cupW-wall*2, cupH-wall*2], [0,0], r=cupW/2-wall, $fn=cfn);
  // base cup revolutions
  flipY() translate([0, cupH/2-cupW/2, 0]) revolve(180, $fn=cfn) translate([cupW/2-wall, 0]) intersection() {
    rotate(180) teardrop(wall, truncate=wall, $fn=ffn);
    translate([-fudge, fudge]) rect([wall+fudge, wall+fudge], [1,-1]);
  }
  // base cup extrusions
  flipX() translate([cupW/2-wall, 0, 0]) rotate([90, 0, 0]) extrude(cupH-cupW, center=true) intersection() {
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

  translate([cupR, 0, 0]) rotate([90, 0, 180]) {
    revolve(arcL, $fn=rfn) translate([cupR, 0]) difference() {
      // cup shell
      union() {
        rect([cupW, cupH], [0,0], r=cupW/2, $fn=cfn);
        translate([0, -cupH/2]) rect([cupW, wall*2], [0,1], r=wall, $fn=ffn);
      }
      // cup cavity
      rect([cupW-wall*2, cupH-wall*2], [0,0], r=cupW/2-wall, $fn=cfn);
    }
    intersection() {
      // ribs
      union() {
        rotate(ribB) revolve(ribF-ribB, convexity=2, $fn=rfn) translate([cupR, 0]) {
          if (ribsC>0) flipY() translate([0, cupH/2-cupW/2]) rotate(90/ribsC-90)
            ring(ribsC, a=180/ribsC) translate([0, legW/2+ribR]) circle(ribR, $fn=ffn);
          if (ribsS>0) flipX() translate([legW/2+ribR, -ribSL/2]) for (i=[1:ribsS])
            translate([0, ribSL*i/(ribsS+1)]) circle(ribR, $fn=ffn);
        }
        rotate([90, 0, ribB]) translate([cupR, 0, 0]) {
          if (ribsC>0) flipY() translate([0, cupH/2-cupW/2, 0]) rotate(90/ribsC-90)
            ring(ribsC, a=180/ribsC) translate([0, legW/2+ribR, 0]) spindle(0, r=ribR, $fn=ffn);
          if (ribsS>0) flipX() translate([legW/2+ribR, -ribSL/2, 0]) for (i=[1:ribsS])
            translate([0, ribSL*i/(ribsS+1), 0]) spindle(0, r=ribR, $fn=ffn);
        }
        rotate([90, 0, ribF]) translate([cupR, 0, 0]) {
          if (ribsC>0) flipY() translate([0, cupH/2-cupW/2, 0]) rotate(90/ribsC-90)
            ring(ribsC, a=180/ribsC) translate([0, legW/2+ribR, 0]) spindle(0, r=ribR, $fn=ffn);
          if (ribsS>0) flipX() translate([legW/2+ribR, -ribSL/2, 0]) for (i=[1:ribsS])
            translate([0, ribSL*i/(ribsS+1), 0]) spindle(0, r=ribR, $fn=ffn);
        }
      }
      union() {
        // cup shell
        revolve(arcL, $fn=rfn) translate([cupR, 0]) {
          rect([cupW, cupH], [0,0], r=cupW/2, $fn=cfn);
          translate([0, -cupH/2]) rect([cupW, wall*2], [0,1], r=wall, $fn=ffn);
        }
        rotate([90, 0, arcL]) translate([cupR, 0, 0]) {
          // top cup center
          translate([0, 0, fudge]) extrude(-wall-fudge) rect([cupW-wall*2, cupH-wall*2], [0,0], r=cupW/2-wall, $fn=cfn);
          // top cup revolutions
          flipY() translate([0, cupH/2-cupW/2, 0]) revolve(180, $fn=cfn) translate([cupW/2-wall, 0]) intersection() {
            circle(wall, $fn=ffn);
            translate([-fudge, fudge]) rect([wall+fudge, wall+fudge], [1,-1]);
          }
          // top cup extrusions
          flipX() translate([cupW/2-wall, 0, 0]) rotate([90, 0, 0]) extrude(cupH-cupW, center=true) intersection() {
            circle(wall, $fn=ffn);
            translate([-fudge, fudge]) rect([wall+fudge, wall+fudge], [1,-1]);
          }
        }
      }
    }
  }

  translate([cupR, 0, 0]) rotate([90, 0, 180]) rotate([90, 0, arcL]) translate([cupR, 0, 0]) {
    // top cup revolutions
    flipY() translate([0, cupH/2-cupW/2, 0]) revolve(180, $fn=cfn) translate([cupW/2-wall, 0]) intersection() {
      circle(wall, $fn=ffn);
      translate([0, fudge]) rect([wall, wall+fudge], [1,-1]);
    }
    // top cup extrusions
    flipX() translate([cupW/2-wall, 0, 0]) rotate([90, 0, 0]) extrude(cupH-cupW, center=true) intersection() {
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
        translate([0, cupH/2-wall/2, fudge2]) extrude(-wall-fudge2) rect([cupW-wall, cupH-wall], [0,0], r=cupW/2-wall/2, $fn=cfn);
      }
    }
  }
}

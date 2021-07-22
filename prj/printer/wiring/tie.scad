use <nz/nz.scad>;


slack = 0.5;

lineW = 0.4;

zipW = 3.5;
zipH = 1.5;  // actual is about 1.15
zipD = 0.2;  // depth to embed into wire ring

h = zipW + 2*zipH + 4;

pfteR = 2.1;
pfteWall = 4*lineW + 0.01;
armW = 2*pfteWall;

wireR = 7.5;
wireWall = 4*lineW + 0.01;
wireOffset = 3*lineW;
wireRibsPerMM = 1;
wireRibs = round(h*wireRibsPerMM);
wireRibDR = h/(2*wireRibs);  // delta R
wireDeg = 285;


module tie(pfte, pfteT, pfteB) {
  pfteB = is_list(pfteB) ? pfteB : pfte;
  pfteT = is_list(pfteT) ? pfteT : pfteB;
  pfteC = pfteB/2 + pfteT/2;
  dPfte = pfteT - pfteB;
  pfteA = dPfte.x == 0 ? 0 : atan(dPfte.y/dPfte.x);
  armA = atan((pfteC.y+wireOffset)/pfteC.x);
  stretch = 1/(cos(angle_between([0,0,1], [dPfte.x, dPfte.y, h])));
  wireIR = wireR + slack/2;
  wireOR = wireIR + wireWall;
  difference() {
    union() {
      // wire (outer)
      translate([0, -wireOffset, 0]) cylinder(h, r=wireOR, center=true);
      flip() {
        // arms
        translate([0, -wireOffset, 0]) shear(z=dPfte/h) rotate(armA)
          box([norm(pfteC+[0,wireOffset])-stretch*(pfteR+slack/2), armW, h], [1,0,0]);
        // pfte
        translate(pfteB+dPfte/2) shear(z=dPfte/h) rotate(pfteA) scale([stretch,1,1]) rotate(-pfteA)
          tube(h, outerR=pfteR+pfteWall+slack/2, innerR=pfteR+slack/2, center=true);
      }
    }
    // wire (inner)
    cylinder(h+1, r=wireIR-wireRibDR, center=true);
    // ribs
    render(convexity=wireRibs+1) translate([0, 0, -h/2])
      for (i = [0:wireRibs-1]) {
        translate([0, 0, i*2*wireRibDR]) cylinder(wireRibDR, r1=wireIR-wireRibDR, r2=wireIR);
        translate([0, 0, i*2*wireRibDR+wireRibDR]) cylinder(wireRibDR, r1=wireIR, r2=wireIR-wireRibDR);
      }
    // zip
    translate([0, -wireOffset, 0]) {
      tube(zipW, outerR=wireOR+zipH-zipD, innerR=wireOR-zipD, center=true);
      flip([0,0,1]) translate([0, 0, zipW/2]) {
        tube(zipH-zipD, outerR1=wireOR+zipH-zipD, outerR2=wireOR, innerR=wireOR);
        tube(zipH-zipD, outerR=wireOR, innerR1=wireOR-zipD, innerR2=wireOR);
      }
    }
    // wire opening
    a1 = 90+(360-wireDeg)/2;
    a2 = 90-(360-wireDeg)/2;
    r = 2*wireOR;
    linear_extrude(h+1, center=true, convexity=1, slices=0)
      polygon([
        [0,         0        ],
        [r*cos(a1), r*sin(a1)],
        [0,         r        ],
        [r*cos(a2), r*sin(a2)],
      ]);
  }
}


fn = 60;

// extruder inputs are 30mm apart
// wire is currently ~20mm behind extruder inputs, but could easily be 25mm or even more
//   scratch that, now 15mm or even a bit less with screw support

translate([0, 0, -60]) tie([15.0, -15.00], $fn=fn);
translate([0, 0, -45]) tie([14.8, -14.0], [14.6, -12.5], $fn=fn);
translate([0, 0, -30]) tie([14.2, (-15-wireOffset)/2-1.5], [13.8, (-15-wireOffset)/2+1.5], $fn=fn);
translate([0, 0, -15]) tie([13.4, -wireOffset-2.5], [13.2, -wireOffset-1], $fn=fn);
translate([0, 0,   0]) tie([13.0, -wireOffset], $fn=fn);
translate([0, 0,  15]) tie([13.4, -wireOffset], [13.6, -wireOffset], $fn=fn);
translate([0, 0,  30]) tie([14.0, -wireOffset], $fn=fn);

// tie([14.8, -14.0], [14.6, -12.5], $fn=fn);
// tie([14.2, (-15-wireOffset)/2-1.5], [13.8, (-15-wireOffset)/2+1.5], $fn=fn);
// tie([13.4, -wireOffset-2.5], [13.2, -wireOffset-1], $fn=fn);
// tie([13.0, -wireOffset], $fn=fn);
// tie([13.4, -wireOffset], [13.6, -wireOffset], $fn=fn);

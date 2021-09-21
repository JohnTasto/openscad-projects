use <nz/nz.scad>


$fn = 60;


lineW = 0.4;

slack = 0.5;

fanNominal = 40;
fanHoleR = 37/2;
fanMargin = 1;
fanH = 4*lineW + 0.01 + fanMargin;

screwFrameShank = m_adjusted_shank_width(3, slack);
screwFrameX = 48;
screwFanShank = m_adjusted_shank_width(5, slack);
screwFanX = 32;

plateFrameW = 10;
plateFrameD = 6;
plateFanD = 1.75;


plateFanFillet = fanNominal/2 - screwFanX/2;


difference() {
  union() {
    // fan plate
    box([screwFanX, fanH+fanNominal, plateFrameW], [0,1,1]);
    box([fanNominal, fanH+fanNominal-plateFanFillet, plateFrameW], [0,1,1]);
    translate([0, fanH+fanNominal/2, 0]) cylinder(plateFrameW, d=fanNominal+2*fanMargin);
    flipX() translate([screwFanX/2, fanH+fanNominal-plateFanFillet, 0])
      cylinder(plateFrameW, r=plateFanFillet);
    // frame plate
    box([screwFrameX, plateFrameD, plateFrameW], [0,1,1]);
    flipX() translate([screwFrameX/2, 0, plateFrameW/2])
      rotate([-90,0,0]) extrude(plateFrameD) teardrop(d=plateFrameW, truncate=plateFrameW/2);
  }
  // fan hole
  translate([0, fanH+fanNominal/2, -1]) cylinder(plateFrameW+2, r=fanHoleR);
  // fan screws
  flipX() translate([screwFanX/2, fanH, -1]) {
    translate([0, plateFanFillet, 0]) cylinder(plateFrameW+2, d=screwFanShank);
    translate([0, fanNominal-plateFanFillet, 0]) cylinder(plateFrameW+2, d=screwFanShank);
  }
  // frame screws
  flipX() translate([screwFrameX/2, -1, plateFrameW/2])
    rotate([-90,0,0]) cylinder(plateFrameD+2, d=screwFrameShank);
  // fan margin
  translate([0, fanH-fanMargin, plateFanD])
    box([fanNominal+2*fanMargin, fanNominal+2*fanMargin, plateFrameW], [0,1,1]);
}

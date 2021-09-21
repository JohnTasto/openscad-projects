handleType = "tire";  // "tire" or "nose"
handleReach = 12;
handleLip = 5;
handleHeight = dLayerAbsFloor(fGridY - dSlopZ);  // only applies to "tire" and "nose" handles

module innerVerticalHandle(midR, hW, trunc) {
  translate([midR, 0]) hull() {
    difference() {
      rotate(90) teardrop(d=hW, $fn=$fn/2);
      rect([hW/2+fudge, hW+fudge2], [1,0]);
    }
    rect([fudge, fudge], [0,0]);
  }
  rect([midR, dWall2], [1,0]);
}

module outerVerticalHandle(midR, hW, trunc) translate([midR, 0]) hull() {
  difference() {
    rotate(-90) teardrop(d=hW, truncate=hW*sqrt(2)/2-trunc, $fn=$fn/2);
    rect([-hW/2-fudge, hW+fudge2], [1,0]);
  }
  rect([-fudge, fudge], [0,0]);
}

if (handleType=="tire") {
  hL = handleReach;
  hW = handleLip;
  extR = handleHeight/2;
  extH = handleHeight;
  extL = hL - handleHeight/2;
  hR = extL > 0 ? extR : (square(handleHeight/2)+square(hL))/(hL*2);
  hH = extL > 0 ? extH : handleHeight;
  trunc = dWall2/2 - dLayerHN/2;
  midR = hR - hW*sqrt(2)/2 + trunc;
  segment = PI*midR*2/$fn;
  translate([0, -drawerY/2-gap, hH/2]) {
    difference() {
      translate([0, hR-dWall2-hL, 0]) difference() {
        rotate([180, 90, 0]) {
          rotate_extrude(angle=180) innerVerticalHandle(midR, hW, trunc);
          rotate(-360/$fn) rotate_extrude(angle=180+720/$fn) outerVerticalHandle(midR, hW, trunc);
        }
        flipX() translate([hW/2, segment, 0]) rotate(45) box([segment*sqrt(2), segment*sqrt(2), hH], [0,0,0]);
        // flipZ() translate([0, fudge, hH/2]) box([hW+fudge2, -hH/2-fudge2, hR-hH/2+hW/2+fudge], [0,1,1]);
      }
      // if (hL+dWall2<hR) box([hW+fudge2, hR-hL-dWall2+fudge, hH+fudge2], [0,1,0]);
      // if (extL<0) flipZ() translate([0, -dWall2-fudge, handleHeight/2]) box([hW+fudge2, hR-hL+fudge2, hR-handleHeight/2], [0,1,1]);
    }
    if (extL>0) difference() {
      flipZ() translate([0, 0, hR-hH/2]) rotate([0, 90, -90]) {
        extrude(extL+dWall2+fudge) innerVerticalHandle(midR, hW, trunc);
        extrude(extL+dWall2) outerVerticalHandle(midR, hW, trunc);
      }
      flipX() translate([hW/2, hR-dWall2-hL-fudge, 0]) rotate(45) box([fudge*sqrt(2), fudge*sqrt(2), hH], [0,0,0]);
    }
  }
  translate([0, -drawerY/2-gap, 0]) rotate([0, -90, 180]) extrude(dWall2, center=true) polygon(
  [ [ 0             ,    0                                      ]
  , [ 0             , extL+dWall2+hR*sqrt(2)/2-(hR-hR*sqrt(2)/2)]
  , [hR-hR*sqrt(2)/2, extL+dWall2+hR*sqrt(2)/2                  ]
  , [hR             , extL+dWall2+hR*sqrt(2)/2                  ]
  , [hR             ,    0                                      ]
  ]);
}

if (handleType=="nose") {
  hL = handleReach;
  hW = handleLip;
  adjH = handleHeight - dLayerHN/2;
  extR = (3+sqrt(2))*(adjH-hL)*sqrt(2)/7;
  extH = extR*sqrt(2);
  extL = hL - extR + extH/2;
  hR = extL > 0 ? extR : (square(adjH/2)+square(hL))/(hL*2);
  hH = extL > 0 ? extH : adjH;
  handle =
  [ [    0                  ,  dWall2/2]
  , [max(0, hR-dWall*2-hW/2),  dWall2/2]
  , [max(0, hR-dWall*2     ),      hW/2]
  , [max(0, hR             ),      hW/2]
  , [max(0, hR             ),     -hW/2]
  , [max(0, hR-dWall*2     ),     -hW/2]
  , [max(0, hR-dWall*2-hW/2), -dWall2/2]
  , [    0                  , -dWall2/2]
  ];
  translate([0, -drawerY/2-gap, hH/2]) {
    difference() {
      translate([0, hR-dWall2-hL, 0]) difference() {
        rotate([180, 90, 0]) rotate_extrude(angle=135) polygon(handle);
        flipZ() translate([0, fudge, hH/2]) box([hW+fudge2, -hH/2-fudge2, hR-hH/2+fudge], [0,1,1]);
      }
      if (hL+dWall2<hR) box([hW+fudge2, hR-hL-dWall2+fudge, hH+fudge2], [0,1,0]);
      if (extL<0) flipZ() translate([0, -dWall2-fudge, handleHeight/2]) box([hW+fudge2, hR-hL+fudge2, hR-handleHeight/2], [0,1,1]);
    }
    if (extL>0) {
      difference() {
        translate([0, hR/sqrt(2)-dWall2, hH+hL-hR*(1+sqrt(2)/2)])
          rotate([0, -135, 90]) extrude(extL*sqrt(2)+fudge) polygon(handle);
        #translate([0, -extL-dWall2, hH/2]) box([hW+fudge2, -fudge2/sqrt(2), -fudge2*sqrt(2)], [0,1,1]);
        translate([0, 0, -fudge]) box([hW+fudge2, hR/sqrt(2)-dWall2+fudge, hL-hR+hR/sqrt(2)+hH/2-dWall2+fudge2], [0,1,1]);
      }
      translate([0, 0, hR-hH/2]) rotate([0, 90, -90]) extrude(extL+dWall2) polygon(handle);
      rotate([0, -90, 0]) extrude(dWall2, center=true) polygon(
      [ [      0,       0]
      , [      0, hR/2-hL]  // `/2` is a guess that works fine barring some design change
      , [hL-hR/2,       0]  // ditto
      ]);
    }
  }
}

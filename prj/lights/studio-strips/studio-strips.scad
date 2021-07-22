// units in inches

// [width, depth, length]

/* [General] */

display_model            = true;
display_cut_list         = true;

height                   =  6;      // [  0.0   : 0.25   : 24.0]
distance                 =  6;      // [  0.0   : 0.25   : 24.0]
spread                   = 52;      // [  6.0   : 0.25   : 72.0]
toe_out                  = 15;      // [-15     : 1      : 45  ]

/* [Beam Visualization] */

display_main_beam        = true;
main_beam_throw          = 50;      // [  0     : 1      : 72  ]
main_beam_alpha          = 0.2;     // [  0.0   : 0.025  :  1.0]
display_front_reflection = true;
front_reflection_throw   = 35;      // [  0     : 1      : 72  ]
front_reflection_alpha   = 0.1;     // [  0.0   : 0.025  :  1.0]
display_back_reflection  = true;
back_reflection_throw    = 20;      // [  0     : 1      : 72  ]
back_reflection_alpha    = 0.05;    // [  0.0   : 0.025  :  1.0]

/* [Light Strip] */

strip_length             = 54;      // [ 12.0   : 0.25   : 96.0]
strip_width              =  0.625;  // [  0.25  : 0.0625 :  1.0]
strip_depth              =  0.25;   // [  0.0   : 0.0625 :  0.5]

front_shade_width        =  2.25;   // [  0.0   : 0.125  :  6.0]
back_shade_width         =  0.75;   // [  0.0   : 0.125  :  6.0]

base_width               =  1;      // [  0.5   : 0.125  :  2.0]
base_depth               = strip_width;
front_depth              =  0.25;   // [  0.125 : 0.0625 :  1.0]
back_depth               =  0.25;   // [  0.125 : 0.0625 :  1.0]

front_overhang           = front_shade_width + strip_depth;
back_overhang            = back_shade_width + strip_depth;
post_width               = base_width + front_overhang;

/* [Spanner] */

min_spread               = 36;      // [  6.0   : 0.25   : 72.0]
max_spread               = 52;      // [  6.0   : 0.25   : 72.0]

spanner_width            =  2.5;    // [  1.0   : 0.25   :  6.0]
spanner_depth            =  0.625;  // [  0.25  : 0.0625 :  2.0]
spanner_overhang         =  0.5;    // [  0.0   : 0.25   :  6.0]
spanner_slot_width       =  0.25;   // [  0.125 : 0.0625 :  0.5]

wire_clearance           =  0.25;   // [  0.0   : 0.0625 :  1.0]
top_block_length         =  1;      // [  0.0   : 0.125  :  6.0]
top_block_width          = front_overhang - wire_clearance;

/* [Legs] */

leg_adjustment           = 12;      // [  0.0   : 0.25   : 48.0]
leg_width                =  1;      // [  0.5   : 0.125  :  6.0]
leg_overlap              =  6;      // [  0.0   : 0.25   : 12.0]
leg_length               = leg_adjustment + leg_overlap;

latch_block_depth        =  1;      // [  0.0   : 0.0625 :  2.0]

/* [Colors] */

wood      = [0.55, 0.45, 0.35 ];
dark_wood = [0.35, 0.25, 0.15 ];
silver    = [0.5,  0.5,  0.525];
black     = [0.1,  0.1,  0.1  ];


post_length = strip_length + top_block_length + leg_length;

rotX = post_width - top_block_width/2;
rotY = front_depth + base_depth/2;


front_shade_panel = [base_width + front_overhang, front_depth, post_length];
base_panel        = [base_width,                  base_depth,  post_length];
back_shade_panel  = [base_width + back_overhang,  back_depth,  post_length];

leg_panel       = [                 leg_width, base_depth, leg_length];
leg_guide_panel = [front_overhang - leg_width, base_depth, leg_length];

latch_block_panel = [post_width, latch_block_depth, leg_overlap];
top_block_panel   = [top_block_width, base_depth, top_block_length];


spanner_length      = max_spread + 2*post_width + 2*spanner_overhang;
spanner_end_length  = rotX + spanner_overhang - spanner_slot_width/2;
spanner_slot_length = (max_spread-min_spread)/2 + spanner_slot_width;
spanner_mid_length  = spanner_length - 2*spanner_slot_length - 2*spanner_end_length;
spanner_side_width  = (spanner_width-spanner_slot_width)/2;

spanner_side_panel = [spanner_side_width, spanner_depth, spanner_length];
spanner_end_panel  = [spanner_slot_width, spanner_depth, spanner_end_length];
spanner_mid_panel  = [spanner_slot_width, spanner_depth, spanner_mid_length];


// all after translating by [base_width + strip_depth, front_depth]:

function unit(v) = v / norm(v);

ledXY = [0, base_depth/2];

shadeFXY = [front_shade_width, 0];
shadeBXY = [back_shade_width,  base_depth];

main_beam_back   = unit(shadeBXY - ledXY);
main_beam_front  = unit(shadeFXY - ledXY);

back_beam_back   = unit(shadeBXY - [3/5*back_shade_width, 0]);
back_beam_front  = unit([min(back_shade_width, 1/3*front_shade_width), base_depth] - ledXY);

front_beam_back  = unit(shadeBXY - [1/3*back_shade_width, 0]);
// front_beam_front = unit([front_shade_width, base_depth] - ledXY);
front_beam_front = [main_beam_front[0], -main_beam_front[1]];


function tail(v) = let (l = len(v))
  l >= 2 ? [ for (i = [1 : len(v)-1]) v[i] ] :
  l == 1 ? [] :
  undef;

if (display_cut_list) cut_list([
  [2, front_shade_panel],
  [2, base_panel],
  [2, back_shade_panel],
  [2, leg_panel],
  [2, leg_guide_panel],
  [2, latch_block_panel],
  [2, top_block_panel],
  [2, spanner_side_panel],
  [2, spanner_end_panel],
  [1, spanner_mid_panel],
]);

module cut_list(v) {
  if (len(v) > 0) {
    count = v[0][0];
    panel = v[0][1];
    translate([0, -panel[0], 0]) {
      color(wood, 1.0) cube([panel[2], panel[0], panel[1]]);
      translate([0, -1.5, 0]) {
        scale(.125) text(str(count, "x  ", panel[2], " x ", panel[0], " x ", panel[1]));
        translate([0, -1, 0]) cut_list(tail(v));
      }
    }
  }
}


module flip(v=[1, 0, 0], copy=true) {
  if (copy) children();
  mirror(v) children();
}

module rotateAbout(tv=[0, 0, 0], a=0, rv=[0, 0, 1]) {
  translate(tv) rotate(a, rv) translate([for (i=tv) -i]) children();
}


module knob(handle_height, shaft_height, handle_radius, shaft_radius) {
  cylinder(h=shaft_height, r=shaft_radius);
  translate([0, 0, shaft_height])
    cylinder(h=handle_height, r=handle_radius);
}

module spanner() {
  cube(spanner_side_panel);
  translate([spanner_side_width, 0, 0]) {
    cube(spanner_end_panel);
    translate([0, 0, spanner_end_length + spanner_slot_length])
      cube(spanner_mid_panel);
    translate([0, 0, spanner_length - spanner_end_length])
      cube(spanner_end_panel);
  }
  translate([spanner_side_width + spanner_slot_width, 0, 0])
    cube(spanner_side_panel);
}

if (display_model) {
  // spanner
  translate([0, -distance, 0])
    rotate([-15, 0, 0])
      translate([0, front_depth + base_depth/2, post_length + height])
        color(wood, 1.0)
          rotate([90,0,90])
            translate([-spanner_width/2, 0, -spanner_length/2])
              spanner();

  flip() translate([-spread/2 - post_width, -distance, 0]) rotate([-15, 0, 0]) {
    rotateAbout([rotX, rotY, 0], toe_out) {
      // leg
      translate([base_width, front_depth, 0])
        color(wood, 1.0)
          cube(leg_panel);

      // post
      translate([0, 0, height]) {
        translate([0, -latch_block_depth, 0]) {
          // latch block layer
          color(wood, 1.0)
            cube(latch_block_panel);
          color(silver, 1.0)
            translate([base_width + leg_width/2, 0, leg_overlap/2])
              rotate([90, 0, 0])
                knob(0.125, 0.5, 0.375, 0.1875);
        }
        {
          // front layer
          color(wood, 1.0) cube(front_shade_panel);
        }
        translate([0, front_depth, 0]) {
          // base layer
          color(wood, 1.0) {
            cube(base_panel);
            translate([base_width + wire_clearance, 0, post_length - top_block_length])
              cube(top_block_panel);
            translate([base_width + leg_width, 0, 0])
              cube(leg_guide_panel);
          }
        }
        translate([rotX, rotY, post_length + spanner_depth])
          color(black, 1.0)
            knob(0.5, 0.5, 1, 0.5);
        translate([0, front_depth + base_depth, 0]) {
          // back layer
          color(wood, 1.0)
            cube(back_shade_panel);
        }
      }
    }
  }

  // panel
  rotate([-15, 0, 0]) {
    translate([0, 0, 48])
      color(dark_wood, 0.25) cube([48, .25, 48], center=true);
  }
}

function r90(v) = [v[1], -v[0]];
function l90(v) = [-v[1], v[0]];

module line(start, direction, length, thickness) {
  polygon(points=[
    start,
    start + thickness,
    start + length*direction + thickness,
    start + length*direction,
  ]);
}

module panel(start, direction, length, height, thickness) {
  linear_extrude(height=height, slices=0) {
    line(start, direction, length, thickness);
  }
}

flip() translate([-spread/2 - post_width, -distance, 0]) rotate([-15, 0, 0]) {
  rotateAbout([rotX, rotY, 0], toe_out) {
    translate([base_width + strip_depth, front_depth, height + leg_length]) {
      if (display_back_reflection)
        color([1, 1, 1, back_reflection_alpha])
          panel(shadeBXY, back_beam_back, back_reflection_throw, strip_length, .001*r90(back_beam_back));
      if (display_front_reflection)
        color([1, 1, 1, front_reflection_alpha])
          panel(shadeBXY, front_beam_back, front_reflection_throw, strip_length, .001*r90(front_beam_back));
      if (display_main_beam)
        color([1, 1, 1, main_beam_alpha])
          panel(shadeBXY, main_beam_back, main_beam_throw, strip_length, .001*r90(main_beam_back));

      if (display_back_reflection)
        color([1, 1, 1, back_reflection_alpha])
          panel([min(3*back_shade_width, front_shade_width), 0], back_beam_front, back_reflection_throw, strip_length, .001*r90(back_beam_front));
      if (display_front_reflection)
        color([1, 1, 1, front_reflection_alpha])
          panel(shadeFXY, front_beam_front, front_reflection_throw, strip_length, .001*r90(front_beam_front));

      if (display_main_beam)
        color([1, 1, 1, main_beam_alpha])
          panel(shadeFXY, main_beam_front, main_beam_throw, strip_length, .001*l90(main_beam_front));
    }
  }
}

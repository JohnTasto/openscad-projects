// units in inches

// [length, width, depth]

/* [Render Options] */

show_full_model          = true;
show_post                = false;
show_inside              = false;
show_cross_section       = true;
show_cut_list            = true;


/* [User Adjustments] */

height                   =  0;      // [  0.0   : 0.25    : 24.0]
distance                 =  6;      // [  0.0   : 0.25    : 24.0]
spread                   = 52;      // [  6.0   : 0.25    : 72.0]
toe_out                  = 15;      // [-15     : 1       : 45  ]


/* [Stock Thickness] */

depth_18                 = 0.125;
depth_14                 = 0.25;
depth_12                 = 0.5;
depth_58                 = 0.625;
depth_34                 = 0.75;


/* [Light Strip] */

strip_length             = 54;      // [ 12.0   : 0.25    : 96.0]
strip_width              =  0.5625; // [  0.25  : 0.0625  :  1.0]
strip_depth              =  0.125;  // [  0.0   : 0.0625  :  0.5]

// the focal chord is the width of the parabola at its focus,
//   which is always 4x the distance between the focus and the vertex
// it may need a hair of clearance for smooth focusing
focal_chord              = strip_width;

reflector_front_depths   = [depth_18, depth_14, depth_12, depth_34, depth_34];
reflector_back_depths    = [depth_18, depth_14, depth_12, depth_34];

reflector_leg_overlap    = 1;       // [  0     : 1       :  4  ]


/* [Legs] */

leg_adjustment           = 16;      // [  0.0   : 0.25    : 48.0]
leg_width                =  1.375;  // [  0.5   : 0.125   :  6.0]
leg_depth                =  1.375;  // [  0.5   : 0.125   :  6.0]
leg_overlap              =  6;      // [  0.0   : 0.25    : 12.0]
leg_clearance            =  0.0625; // [  0.0   : 0.03125 :  0.5]
leg_length               = leg_adjustment + leg_overlap;
leg_cavity_width         = leg_width + leg_clearance;
leg_cavity_depth         = leg_depth + leg_clearance;


/* [Frame] */

front_depth              = depth_14;
back_depth               = depth_58;
outside_depth            = depth_14;
inside_depth             = reflector_back_depths[reflector_leg_overlap];
base_depth               = depth_12;

front_width              = outside_depth + leg_cavity_width + inside_depth;
back_width               = leg_cavity_width - sum(take(reflector_leg_overlap, reflector_back_depths));
outside_width            = leg_cavity_depth + back_depth;
inside_width             = outside_width;
base_width               = back_width - strip_depth - focal_chord/2;


/* [Spanner] */

min_spread               = 36;      // [  6.0   : 0.25    : 72.0]
max_spread               = 52;      // [  6.0   : 0.25    : 72.0]

spanner_width            =  2.5;    // [  1.0   : 0.25    :  6.0]
spanner_depth            = depth_34;
spanner_overhang         =  0.5;    // [  0.0   : 0.25    :  6.0]
spanner_slot_width       =  0.25;   // [  0.125 : 0.0625  :  0.5]


/* [Controls] */

// plunger extends about 1.5", but 1.0" of it is spring
// for that last 0.5", about 2/3 should be in the leg and about 1/3 in the frame
latch_block_depth        = 1.125 - inside_depth - leg_clearance/2;

top_block_depth          = depth_34;
top_block_clearance      =  0.25;   // [  0.0   : 0.125   :  6.0]
top_length               = top_block_depth + top_block_clearance;


focus_knob_margin        =  6;      // [  0.0   : 0.25    : 12.0]


/* [Totals] */

post_length              = leg_length + strip_length + top_length;
post_width               = front_width + sum(drop(reflector_leg_overlap+1, reflector_front_depths));
post_depth               = inside_width + front_depth;

focusX                   = outside_depth + back_width;
focusY                   = front_depth + leg_cavity_depth - focal_chord/2;

reflector_front_width    = leg_cavity_depth - focal_chord/2 + front_depth;
reflector_back_width     = reflector_front_width - lensY(sum(reflector_front_depths))
                                                 + lensY(sum(reflector_back_depths));

reflector_width          = reflector_front_width + reflector_back_width;


/* [Colors] */

wood      = [0.55, 0.45, 0.35 ];
dark_wood = [0.35, 0.25, 0.15 ];
silver    = [0.5,  0.5,  0.525];
black     = [0.1,  0.1,  0.1  ];
gray      = [0.25, 0.25, 0.25 ];
white     = [0.9,  0.9,  0.9  ];


/****************/
/* list helpers */
/****************/

function head(xs) = xs[0];
function last(xs) = xs[len(xs)-1];

function take(n, xs) = let (l = len(xs)) n > 0 ? [for (i = [0 : min(n,l)-1]) xs[i]] : [];
function drop(n, xs) = let (l = len(xs)) l > n ? [for (i = [max(0,n) : l-1]) xs[i]] : [];

function init(xs) = take(1, xs);
function tail(xs) = drop(1, xs);

function reverse(xs) = let (l = len(xs)) l > 0 ? [for (i = [0 : l-1]) xs[l-i-1]] : [];

function flatten(xss) = [for (xs = xss) for (x = xs) x];

function zip(xs, ys) = let (l = min(len(xs), len(ys))) l > 0
  ? [for (i = [0 : l-1]) [xs[i], ys[i]]]
  : [];

function interleave(xs, ys) = let (l = min(len(xs), len(ys)))
  concat(flatten(zip(xs, ys)), drop(l, xs), drop(l, ys));

function sum(xs) = len(xs) > 0 ? xs * [for (_ = xs) 1] : 0;


/**************/
/* primitives */
/**************/

module panel(v, color=wood, flip=false)
  color(color)
    if (is_list(v.y)) rotate([0, 90, 0]) linear_extrude(height=v.x, slices=0) polygon(points=[
        [   0, 0],
        [-v.z, 0],
        [-v.z, flip ? -v.y[1] : v.y[1]],
        [   0, flip ? -v.y[0] : v.y[0]],
      ]);
    else translate([0, flip ? -v.y : 0, 0]) cube(v);

module knob(handle_height, shaft_height, handle_radius, shaft_radius) {
  cylinder(h=shaft_height, r=shaft_radius);
  translate([0, 0, shaft_height]) cylinder(h=handle_height, r=handle_radius);
}


/************/
/* controls */
/************/

module thumb_screw() color(black)  knob(0.375, 0.125, 0.5,    0.3125,  $fn=24);
module plunger()     color(silver) knob(0.125, 0.5,   0.3125, 0.15625, $fn=24);


/***********************/
/* parabolic reflector */
/***********************/

function lensY(x) = sqrt(focal_chord * (focal_chord/4 + x));

reflector_front_cutout_width = front_depth;
reflector_back_cutout_width  = reflector_back_width - back_depth - focal_chord/2;

reflector_front_panels = [for (i = [0 : len(reflector_front_depths)-1]) [
  strip_length,
  [ reflector_front_width
      - lensY(sum(take(i,   reflector_front_depths)))
      - (i < reflector_leg_overlap+1 ? reflector_front_cutout_width : 0),
    reflector_front_width
      - lensY(sum(take(i+1, reflector_front_depths)))
      - (i < reflector_leg_overlap+1 ? reflector_front_cutout_width : 0),
  ],
  reflector_front_depths[i],
]];

reflector_back_panels = [for (i = [0 : len(reflector_back_depths)-1]) [
  i < reflector_leg_overlap ? post_length : strip_length,
  [ reflector_back_width
      - lensY(sum(take(i,   reflector_back_depths)))
      - (i < reflector_leg_overlap+1 ? reflector_back_cutout_width : 0),
    reflector_back_width
      - lensY(sum(take(i+1, reflector_back_depths)))
      - (i < reflector_leg_overlap+1 ? reflector_back_cutout_width : 0),
  ],
  reflector_back_depths[i],
]];

module reflector_front()
  translate([0, reflector_front_width, 0])
    for (i = [0 : len(reflector_front_panels)-1])
      translate([
        0,
        i < reflector_leg_overlap+1 ? -reflector_front_cutout_width : 0,
        sum(take(i, reflector_front_depths)),
      ])
        panel(reflector_front_panels[i], flip=true);

module reflector_back()
  translate([0, -reflector_back_width, 0])
    for (i = [0 : len(reflector_back_panels)-1])
      translate([
        i < reflector_leg_overlap ? -leg_length : 0,
        i < reflector_leg_overlap+1 ? reflector_back_cutout_width : 0,
        sum(take(i, reflector_back_depths)),
      ])
        panel(reflector_back_panels[i]);


/********/
/* post */
/********/

front_panel        = [post_length,      front_width,      front_depth      ];
back_panel         = [post_length,      back_width,       back_depth       ];
outside_panel      = [post_length,      outside_width,    outside_depth    ];
inside_upper_panel = [top_length,       inside_width,     inside_depth     ];
inside_lower_panel = [leg_length,       inside_width,     inside_depth     ];
leg_panel          = [leg_length,       leg_width,        leg_depth        ];

latch_block_panel  = [leg_overlap,      post_depth,       latch_block_depth];
top_block_panel    = [leg_cavity_width, leg_cavity_depth, top_block_depth  ];

base_panel         = [strip_length,     base_width,       base_depth       ];
strip              = [strip_length,     strip_width,      strip_depth      ];

module post(show_inside=show_inside)
  rotate([-90, -90, 0])
  {
    translate([0, outside_depth + leg_clearance/2, front_depth + leg_clearance/2])
      panel(leg_panel);
    translate([height, 0, 0]) {
      translate([leg_length, focusX, focusY]) rotate([-90, 0, 0]) {
        {
          reflector_front();
          reflector_back();
        }
      }
      translate([leg_length, focusX-strip_depth, front_depth+leg_cavity_depth]) {
        translate([0, 0, -strip_width]) rotate([-90, 0, 0]) panel(strip, flip=true, color=white);
        translate([0, -base_width, -base_depth]) panel(base_panel);
        translate([0, -base_width/2, back_depth]) {
          translate([focus_knob_margin, 0, 0]) thumb_screw();
          translate([strip_length-focus_knob_margin, 0, 0]) thumb_screw();
        }
      }
      translate([0, front_width, 0]) rotate([-90, 0, 0])
        panel(latch_block_panel, flip=true);
      translate([leg_overlap/2, front_width+latch_block_depth, post_depth/2]) rotate([-90, 0, 0])
        plunger();
      translate([post_length-top_block_depth, outside_depth, front_depth]) rotate([90, 0, 90])
        panel(top_block_panel);
      translate([post_length+spanner_depth, focusX, focusY]) rotate([90, 0, 90])
        thumb_screw();
      translate([0, outside_depth, front_depth+leg_cavity_depth])
        if (!show_inside) panel(back_panel);
        translate([0, outside_depth+leg_cavity_width, front_depth]) rotate([-90, 0, 0]) {
          panel(inside_lower_panel, flip=true);
          translate([leg_length+strip_length, 0, 0])
            panel(inside_upper_panel, flip=true);
        }
      if (!show_inside) {
        translate([0, 0, front_depth]) rotate([-90, 0, 0])
          panel(outside_panel, flip=true);
        panel(front_panel);
      }
    }
  }

if (show_post)
  translate([0, show_cut_list ? 2 : 0, 0])
    post();


/**********************/
/* post cross section */
/**********************/

module post_cross_section()
  let (d = 0.5, h = height + leg_length + focus_knob_margin - d/2)
    translate([0, 0, -h])
      intersection() {
        post(show_inside=false);
        translate([-1, -1, h])
          color(gray, show_inside ? 0.125 : 1.0) cube([post_width+2, reflector_width+2, d]);
      }

if (show_cross_section)
  translate([show_cut_list || show_post ? -(post_width+2) : 0, 0, 0])
    translate([0, show_cut_list ? -reflector_width : 0, 0])
      post_cross_section();


/***********/
/* spanner */
/***********/

spanner_length      = max_spread + 2*post_width + 2*spanner_overhang;
spanner_end_length  = focusX + spanner_overhang - spanner_slot_width/2;
spanner_slot_length = (max_spread-min_spread)/2 + spanner_slot_width;
spanner_mid_length  = spanner_length - 2*spanner_slot_length - 2*spanner_end_length;
spanner_side_width  = (spanner_width-spanner_slot_width)/2;

spanner_side_panel = [spanner_length,     spanner_side_width, spanner_depth];
spanner_end_panel  = [spanner_end_length, spanner_slot_width, spanner_depth];
spanner_mid_panel  = [spanner_mid_length, spanner_slot_width, spanner_depth];

module spanner() {
  cube(spanner_side_panel);
  translate([0, spanner_side_width, 0]) {
    cube(spanner_end_panel);
    translate([spanner_end_length+spanner_slot_length, 0, 0])
      cube(spanner_mid_panel);
    translate([spanner_length-spanner_end_length, 0, 0])
      cube(spanner_end_panel);
  }
  translate([0, spanner_side_width+spanner_slot_width, 0])
    cube(spanner_side_panel);
}


/************/
/* cut list */
/************/

function angle_between(u, v) = acos((u*v)/(norm(u)*norm(v)));

module cut_list(v, i=0)
  if (len(v) > i) {
    count = v[i][0];
    panel = v[i][1];
    translate([0, is_list(panel.y) ? -max(panel.y) : -panel.y, 0]) {
      panel(panel);
      translate([0, -1.5, 0]) {
        scale(.125) text(is_list(panel.y)
          ? str(count, "x  ", panel.x, " x ", panel.y, " x ", panel.z,
              "  (", angle_between([0, panel.y[0]-panel.y[1], panel.z], [0, 0, 1]) , "°)"
            )
          : str(count, "x  ", panel.x, " x ", panel.y, " x ", panel.z)
        );
        translate([0, -1, 0]) cut_list(v, i+1);
      }
    }
  }

if (show_cut_list) cut_list(concat(
  interleave([ for (panel = reverse(reflector_front_panels)) [2, panel] ],
             [ for (panel = reverse(reflector_back_panels))  [2, panel] ]),
  [ [2, base_panel],
    [2, back_panel],
    [2, front_panel],
    [2, outside_panel],
    [2, inside_upper_panel],
    [2, inside_lower_panel],
    [2, leg_panel],
    [2, latch_block_panel],
    [2, top_block_panel],
    [2, spanner_side_panel],
    [1, spanner_mid_panel],
    [2, spanner_end_panel],
  ]
));


/********************/
/* geometry helpers */
/********************/

module flip(v=[1,0,0], copy=true) {
  if (copy) children();
  mirror(v) children();
}

module rotateAbout(vt=[0,0,0], a=0, vr=[0,0,1])
  translate(vt) rotate(a, vr) translate([for (i = vt) -i]) children();


/***************/
/* final model */
/***************/

module lean_back()    rotate([-15, 0, 0]) children();
module pull_forward() translate([0, -distance, 0]) children();
module spread()       flip() translate([-(spread/2 + post_width), 0, 0]) children();

if (show_full_model)
  translate([0, show_cut_list ? distance+2 : 0, 0]) {
    // lights
    pull_forward() lean_back() {
      // post
      spread() rotateAbout([focusX, focusY, 0], toe_out)
        post();
      // spanner
      translate([0, focusY, post_length+height])
        translate([-spanner_length/2, -spanner_width/2, 0])
          color(wood) spanner();
    }
    // easel panel
    lean_back() translate([0, 0, 48])
      color(dark_wood, 0.25) cube([48, .25, 48], center=true);
  }

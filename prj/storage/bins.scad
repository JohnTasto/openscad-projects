use <nz/nz.scad>

/*
Features
  - secure storage for small parts
    - detents hold drawers closed and prevent pulling drawers out too far
    - frame completely surrounds the drawer opening when closed
    - roof over drawers is flat, so there is nothing for contents to get caught on
    - bins are slightly rounded at the bottom to aid removal of contents with one finger
  - parametric
    - two types of drawers that can be used interchangeably
      - bin drawers hold rearrangeable bins
      - fixed divider drawers have configurable divider walls built in
    - adjustable line width, layer height, and slop to accommodate various printer setups
    - several available drawer handle styles
    - drawer grid size is configurable to match 25mm or 1" pegboard spacing, etc
  - modular
    - both bins and drawers can be rearranged as needs change
    - any bin works in any drawer of the same height that is wide enough for it to fit
      - a bin unit is defined to be the distance from the inside of one drawer to the inside of the next
        - i.e., the width of the wall between drawers, including the drawer walls
      - possible drawer sizes (in bin units) include:
        - 2n + 1  =  1,  3,  5,  7,  9, 11, ...   requires very narrow vertical hooks
        - 3n + 2  =  2,  5,  8, 11, 14, 17, ...   most fine grained grid resolution for general purpose
        - 4n + 3  =  3,  7, 11, 15, 19, 23, ...   wider drawers spread out hooks to use less material
  - easy to print
    - everything except front trim pieces are designed for spiralize/vase mode
    - overhangs are all 45°
    - perimeter folds back on itself to fill gaps and increase strength
    - drawer sides are corrugated for added rigidity
    - optional double walled drawer that still prints in vase mode

Tips
  - drawers
    - Z seam:
      - double wall drawers: behind face on right side at the corner of face and body
      - single wall drawers: TODO
    - slightly more strength in normal (non-vase) mode since the layers are more uniform
      - particularly for fixed divider drawers
      - more ringing at Z seam if Z acceleration and jerk are high
      - may have problems with second layer overhangs if Initial Layer Horizontal Expansion is negative
          because Wall Line Count must be 1 so there is no inner wall for the outer wall to attach to
    - significantly more strength with ~25% higher Outer Wall Flow since layers are smashed together
      - set Wall Count to 1
      - set Outer Wall Wipe Distance to 0
      - set Top Surface Skin Layers and Top Layers to 1
      - set Skin Removal Width to some high number like 5
      - set Infill Density to 0

Possible future improvements
  [ ] carry handle
  [ ] label holder
  [ ] side and trim inside corners
  mounting hardware
    [ ] pegboard hooks
    [ ] suction cups
    [ ] specify required and calculate actual mount space behind drawers
    [ ] allow vertical or horizontal slots in addition to simple holes
  drawer rails
    [ ] center drawer bumps within `fBulgeWall`?
       -  currently drawer rail begins at a constant `fBulgeWall/2`
       -  if `dSW>0`, peaks are narrower than they could be
       -  otoh, pushing the drawer rail out makes the drawer more rigid, which was the original intention
    [ ] trim side bumps with shallow slopes (or highlight)
    [ ] additional bump rails on tall drawers
       -  should be optional (might be too stiff)
  [ ] highlight additional invalid states
  [ ] support ribs along length of side edges
     -  requires adjusting fills
     -  benefit is mostly visual since it will close up the gaps caused by abrupt u-turns
     -  not possible on right sides
  [ ] buttresses in voids behind radii of fixed divider drawers
    - automated solution may be very difficult
  [ ] use better sweep method for drawer handles to reduce polygon count by half
  printbed layout
    [ ] add rotation option
    [ ] calculate external dimensions
    [ ] calculate Z seam position
  [ ] make claspD and claspW consistent
  [ ] reduce complex expressions to existing or additional constants
  [ ] SLA mode (is resin even a good material for this?)
     -  align edges with pixel borders
     -  set slop to 1px
     -  remove slices
  `sliceN` functions
    [ ] pull out into external library
       -  parameterize constants
       -  document
    [ ] either change API to use `align` or change `rect` and `box` to use `centerN`
    [ ] change the fill equations so they space lines exactly even when given enough space
       -  the exterior space is one `gap` wider than the interior space, since that's how
            it already has to be is when lines are packed at tightly as possible
       -  would require reserving the first `gap` worth of `fillResidue` per line for `fillWall`,
            then splitting the remainder evenly. `fillResidueShare` would need to be split in two
*/

/* [Instructions] */
// Start with the bottommost section and work up. Dial in all system settings before starting a production run by printing test pieces until satisfied. Detents may feel pretty similar between single and double wall drawers or single and multi unit heights, so choose a small test size and single wall drawers to start with to save time and material. Drawer detents are much tighter when neighbor frame pieces are attached though, so a good test configuration is three across by two high. Only the top middle frame needs to be reprinted if only the drawer detents have changed between tests.
Overview = false;
// Main settings select individual components from a larger system of compatible parts, as well as several demo and cutaway scenes used to check part alignment. Check the demo scenes for highlighted features and the console for error messages before printing parts.
Main = false;
// Preview settings offer demo scene options and affect preview quality.
Preview = false;
// <local> settingss do not affect compatibility.
local = false;
// <sides> settings affect all side and trim parts, but no others.
side = false;
// <global> settings have system-wide effects, and changing any of these settings causes all new parts to be incompatible with any old parts.
global = false;

/* [Main] */
Active_model = "small assembly - h>1";  // [--PRINT--, frame, drawer, bin, side, trim, hook insert,  , --ALIGNMENT--, bump alignment - drawer shut, bump alignment - drawer open, z alignment, bin alignment,  , --LARGE DEMOS--, small assembly, small assembly - h>1, large assembly, large assembly - h>1,  , --SMALL DEMOS--, hooks, hooks - top & bottom, hooks - left & right, perimeter, sides, fills]
// specify which side if side or trim is selected above
Side = "top";  // [top, top left, left, bottom left, bottom, bottom right, right, top right]
// Fixed divider drawers are double walled and have configurable built in dividers, but bins will not fit. They may take a while to render.
Fixed_divider_drawer = false;
// in frame units
Part_width = 3;  // [1:1:8]
// in frame units
Part_height = 2;  // [1:1:8]
// in bin units
Bin_width = 2;  // [1:1:16]
// in bin units
Bin_depth = 2;  // [1:1:16]

/* [Preview] */
Full_resolution_corners = false;
Draw_cuts = false;
Render_transparent_parts = false;
Expose_bottom_trim_bumps = false;
Show_trim_in_demos = true;
Show_drawers_in_demos = false;

/* [Dividers] */
// in relative sizes, ordered front to back. While five are shown here, any number of divisions is possible. The first eight rows can be subdivided further below. In fact, any number of rows can be subdivided, and those subdivisions subdivided, and so on, but the customizer is extremely limited so any fancy arrangements must be specified as a nested array in code.
Divisions = [ 3, 4, 3, 0, 0 ];
Row_1_subdivisions = [4, 9, 0, 0, 0 ];
Row_2_subdivisions = [4, 5, 4, 0, 0 ];
Row_3_subdivisions = [9, 4, 0, 0, 0 ];
Row_4_subdivisions = [0, 0, 0, 0, 0 ];
Row_5_subdivisions = [0, 0, 0, 0, 0 ];
Row_6_subdivisions = [0, 0, 0, 0, 0 ];
Row_7_subdivisions = [0, 0, 0, 0, 0 ];
Row_8_subdivisions = [0, 0, 0, 0, 0 ];

/* [<local> Bins] */
// in mm. Applies to both bins and divider drawers.
Bin_radius = 15; // [0:1:50]
// Number of segments along rounded bin sections.
Bin_segments = 16;  // [1:1:64]

/* [<local> Drawers] */
// in mm. Length from drawer face to the tip of the handle.
Handle_length = 20;  // [0.0:0.5:100.0]
// in mm. Diameter of the handle bar.
Handle_circumference_diameter = 5.0;  // [2.5:0.5:25.0]
// Number of segments in the curved sections around the handle bar.
Handle_circumference_segments = 12;  // [4:4:64]
// Draw an elliptical handle instead of a rectangular one.
Elliptical_handle = false;
// in mm. Radius of the corners of rectangular handles. No effect on elliptical handles.
Handle_bend_radius = 5.0; // [0.0:0.5:25.0]
// Number of segments in the curved sections along the length of the handle.
Handle_bend_segments = 24;  // [8:2:128]
// Extend the drawer base into the handle.
Tray_handle = false;
// in mm. Makes it easier to insert drawers.
Back_bottom_chamfer = 2.075;  // [0.000:0.025:5.000]
// Number of segments around the back corners.
Back_fillet_segments = 6;  // [2:2:32]

/* [<local> Frames] */
// Add squiggles to fill gaps caused by bin drawer compensation. This may increase print time more than expected due to acceleration.
Fill_horizontal_gaps = false;
// Thicken frame drawer roof along sides to compensate for drawer height layer quantization. Too many lines will increase print time.
Drawer_layer_compensation_lines = 2;  // [0:1:5]
// in frame layers
Thickness_of_front_fills = 3;  // [0:1:10]
// in mm. Chamfer the wall on the upper left, which can be sharp.
Horn_chamfer = 0.75;  // [0.00:0.25:10.00]
// in mm. The back wall sometimes sticks to the piece below it and needs a bit more clearance to lay flat.
Back_wall_extra_slop = 0.10;  // [0.00:0.01:1.00]

/* [<sides> Trim Detents] */
// in mm
Trim_bump_height = 0.50;  // [0.00:0.05:5.00]
// in mm. Should be a bit looser.
Trim_bottom_bump_height = 0.40;  // [0.00:0.05:5.00]
// in frame layers
Trim_bump_peak_length = 2.00;  // [0.00:0.25:5.00]
Trim_bump_latch_slope = 0.500;  // [0.050:0.005:1.000]
Trim_bump_ramp_slope = 0.200;  // [0.050:0.005:1.000]
// in frame layers. Keep presure on the bumps even after they're fully inserted so they don't feel loose.
Trim_bump_overlap = -0.25;  // [-5.00:0.25:5.00]
// in frame layers. How far trim pieces stick out due to surface roughness.
Trim_float = 0.15;  // [0.00:0.05:1.00]

/* [<sides> Sides and Trim] */
// Add mount points to sides to accept trim. Increases height of top trim parts.
Enable_trim = true;
// in mm. Add lip around the front rim. Thickens the fragile trim pieces for extra strength. Pieces with different lip settings should fit together, but will not be flush.
Front_lip = 2.0;  // [0.0:0.1:10.0]
// Number of segments along side corners.
Side_corner_segments = 8;  // [2:1:32]

/* [<global> Mounting Holes] */
// Holes align with frame units.
Enable_mounting_holes = true;
// in mm
Fastener_shaft_diameter = 4.50;  // [2.00:0.05:10.00]
// in mm
Fastener_head_diameter = 8.5;  // [4.0:0.1:20.0]
// in mm
Fastener_head_height = 2.75;  // [2.00:0.05:10.00]
// in mm
Keyhole_length = 6.5;  // [4.0:0.1:20.0]
// in mm
Keyhole_width_offset = -1.00;  // [-2.50:0.05:0.00]
// in degrees
Keyhole_opening_bevel = 45;  // [0:5:85]
// in degrees
Keyhole_angle = 90;  // [0:15:180]
// Number of segments around mounting holes.
Mounting_hole_segments = 32;  // [8:4:64]

/* [<global> Drawer Detents - Main] */
// in mm. The bumps on the sides of drawers.
Drawer_bump_height = 0.65;  // [0.00:0.05:5.00]
// in frame layers
Drawer_bump_peak_length = 2.00;  // [0.00:0.25:5.00]
Drawer_bump_front_slope = 1.000;  // [0.050:0.005:1.000]
Drawer_bump_back_slope = 0.250;  // [0.050:0.005:1.000]
// in drawer layers. The size of the accordion fold above and below the drawer bumps.
Drawer_bump_spring_width = 5.0;  // [0.0:0.5:10.0]
// in frame layers. How far fully closed drawers still stick out due to surface roughness.
Drawer_float = 0.15;  // [0.00:0.05:1.00]

/* [<global> Drawer Detents - Catch (back)] */
// in mm. The bumps in the back of frames that catch on drawers when closed.
Catch_bump_height_offset = -0.10;  // [-0.50:0.01:0.50]
// in frame layers
Catch_bump_peak_length = 2.00;  // [0.00:0.25:5.00]
Catch_bump_ramp_slope = 0.125;  // [0.050:0.005:1.000]
// in mm
Catch_cushion_height_offset = 0.0;  // [-0.50:0.01:0.50]

/* [<global> Drawer Detents - Hold (inner front)] */
// in mm. The bumps in the front of frames that hold drawers open.
Hold_bump_height_offset = 0.10;  // [-0.50:0.01:0.50]
// in frame layers
Hold_bump_peak_length = 2.00;  // [0.00:0.25:5.00]
Hold_bump_ramp_slope = 0.175;  // [0.050:0.005:1.000]

/* [<global> Drawer Detents - Keep (outer front)] */
// in mm. The bumps in the front of frames that keep drawers from falling out too easily.
Keep_bump_height_offset = 0.10;  // [-0.50:0.01:0.50]
// in frame layers
Keep_bump_peak_length = 1.50;  // [0.00:0.25:5.00]
Keep_bump_ramp_slope = 1.000;  // [0.050:0.005:1.000]

/* [<global> Drawer Slots] */
// in absolute drawer layers. The slots in the drawer bottoms. Must be even if using spiralize in Cura.
Bottom_slot_height = 4;  // [0:1:10]
// in absolute drawer layers. The bumps on the top frame hooks that keep drawers from falling out too easily. Add a little extra over the slot height to overcome filament dragging.
Bottom_bump_height = 3.75;  // [0.00:0.25:12.00]
// in frame layers
Bottom_bump_peak_length = 2.50;  // [0.00:0.25:5.00]
// in frame double walls. Must leave room for trim clip if trim is enabled.
Bottom_bump_width = 2.50;  // [1.00:0.25:5.00]

/* [<global> Stops] */
// in frame double walls
Frame_stop_lines_for_single_unit_high_parts = 2;  // [0:1:10]
// in frame double walls
Frame_stop_lines_for_multi_unit_high_parts = 2;//3;  // [0:1:15]
// in drawer double walls
Drawer_stop_lines = 2;  // [0:1:5]

/* [<global> Grid] */
// Fixed divider drawers are already double walled; this setting makes bin drawers double walled as well. This also increases the minimum bin unit size as a side effect.
Double_bin_drawer_walls = true;
// Add an extra double line wall behind the faces of double wall drawers, creating a lip that makes it harder for parts to fall out. Single wall drawers already have a single line lip.
Add_lip_behind_face_of_double_wall_drawers = true;
// Required to enable bin drawers when frame width units are in mm or inches. This calculates the best fit bin grid and adjusts frame and drawer dimensions to work with bins, but wastes some horizontal space and narrows the drawer side rails.
Bin_drawer_compensation = true;
// Bin drawers are enabled only when frame width units are in bin units or bin drawer compensation is enabled above.
Frame_width_units = "inches";  // [bins:bin units, mm:mm, inches:inches]
Frame_unit_width_in_bin_units = 2;  // [1:1:6]
Frame_unit_width_in_mm = 20.000;  // [10.000:0.025:60.000]
Frame_unit_width_in_inches = 0.800;  // [0.400:0.001:2.400]
// Depth of bare frame pieces, not including drawers, sides, or trim.
Frame_depth_units = "bins";  // [same:same as width, bins:bin units - defaults to same as width if bin drawers are disabled, mm:mm, inches:inches]
Frame_depth_in_bin_units = 20;//12;  // [4:1:60]
Frame_depth_in_mm = 120.000;  // [40.00:0.25:600.00]
Frame_depth_in_inches = 4.800;  // [1.60:0.01:24.00]
// Ensure there is adequate space for drawer detents.
Frame_height_units = "same";  // [same:same as width - defaults to mm if width is bin units, mm:mm, inches:inches]
Frame_unit_height_in_mm = 20.000;  // [10.000:0.025:60.000]
Frame_unit_height_in_inches = 4/7;//0.571;  // [0.400:0.001:2.400]

/* [<global> Frame Detents - Left and Right Hooks] */
// in mm
Horizontal_hook_size = 1.25;  // [0.50:0.25:10.00]
// in mm
Horizontal_hook_bump_height = 0.85;  // [0.00:0.05:5.00]
// in frame layers
Horizontal_hook_bump_peak_length = 2.00;  // [0.00:0.25:5.00]
Horizontal_hook_bump_latch_slope = 0.750;  // [0.050:0.005:1.000]
Horizontal_hook_bump_ramp_slope = 0.175;  // [0.050:0.005:1.000]
// in mm. Move the bumps further apart, but keep them the size.
Horizontal_hook_gap_offset = 0.05;  // [-0.50:0.01:0.50]
// in mm. The margin provides room for the hooks to flex. This setting may appear to have no effect when bin drawers are
Horizontal_hook_margin_offset = 0.00;  // [-0.50:0.01:0.50]
// in frame layers. Keep presure on the bumps even after they're fully inserted so they don't feel loose.
Horizontal_hook_bump_overlap = -0.25;  // [-5.00:0.25:5.00]
// in frame layers
Horizontal_hook_bump_front_inset = 5.00;  // [0.00:0.25:10.00]
// in frame layers
Horizontal_hook_bump_back_inset = 5.00;  // [0.00:0.25:10.00]
// in mm. If there is room, an extra lip is added to the hooks which helps prevent them from derailing.
Horizontal_hook_bump_minimum_contact_patch = 0.5;  // [0.10:0.05:10.00]
// in mm
Horizontal_hook_chamfer = 0.75;  // [0.00:0.25:10.00]
// in mm
Horizontal_stem_chamfer = 10.00;  // [0.00:0.25:10.00]

/* [<global> Frame Detents - Top and Bottom Hooks] */
// in mm
Vertical_hook_size = 3.25;  // [0.50:0.25:10.00]
// in mm
Vertical_hook_bump_height = 1.00;  // [0.00:0.05:5.00]
// in frame layers
Vertical_hook_bump_peak_length = 2.00;  // [0.00:0.25:5.00]
Vertical_hook_bump_latch_slope = 0.750;  // [0.050:0.005:1.000]
Vertical_hook_bump_ramp_slope = 0.175;  // [0.050:0.005:1.000]
// in mm. Move the bumps further apart, but keep them the size.
Vertical_hook_gap_offset = 0.05;  // [-0.50:0.01:0.50]
// in mm. The margin provides room for the hooks to flex.
Vertical_hook_margin_offset = 0.00;  // [-0.50:0.01:0.50]
// in frame layers. Keep presure on the bumps even after they're fully inserted so they don't feel loose.
Vertical_hook_bump_overlap = -0.25;  // [-5.00:0.25:5.00]
// in frame layers
Vertical_hook_bump_front_inset = 5.00;  // [0.00:0.25:10.00]
// in frame layers
Vertical_hook_bump_back_inset = 5.00;  // [0.00:0.25:10.00]
// in mm. If there is room, an extra lip is added to the hooks which helps prevent them from derailing.
Vertical_hook_bump_minimum_contact_patch = 1.00;  // [0.10:0.05:10.00]
// in mm
Vertical_hook_chamfer = 0.75;  // [0.00:0.25:10.00]

/* [<global> General] */
// in mm. Minimum distance between walls. By empirical testing, Cura needs a 0.03 mm gap to prevent bridging cuts, plus leeway for curve approximations.
Cut_gap = 0.04;  // [0.0025:0.0025:0.1000]
// More difficult to print first layer of frames and sides.
Fancy_back = false;

/* [<global> Printer Config - Bins] */
Bin_line_width = 0.42;  // [0.05:0.01:1.50]
Bin_horizontal_slop = 0.15;  // [0.00:0.01:1.00]
Bin_layer_height = 0.20;  // [0.02:0.04:1.00]
Bin_first_layer_height = 0.32;  // [0.02:0.04:1.00]
// in absolute bin layers
Bin_base_layers = 5;  // [1:1:25]
// in bin layers
Bin_vertical_slop = 1.00;  // [-5.00:0.25:5.00]

/* [<global> Printer Config - Drawers] */
Drawer_line_width = 0.42;   // [0.05:0.01:1.50]
Drawer_horizontal_slop = 0.20;  // [0.00:0.01:1.00]
Drawer_layer_height = 0.20;  // [0.02:0.04:1.00]
Drawer_first_layer_height = 0.32;  // [0.02:0.04:1.00]
// in absolute drawer layers
Drawer_base_layers = 7;  // [1:1:25]
// in drawer layers
Drawer_vertical_slop = 1.50;  // [-5.00:0.25:5.00]

/* [<global> Printer Config - Frames] */
Frame_line_width = 0.400;  // [0.05:0.01:1.50]
Frame_horizontal_slop = 0.15;  // [0.00:0.01:1.00]
Frame_layer_height = 0.20;  // [0.02:0.04:1.00]
Frame_first_layer_height = 0.32;  // [0.02:0.04:1.00]
// in absolute frame layers
Frame_base_layers = 7;  // [1:1:25]
// in frame layers
Frame_vertical_slop = -0.25;  // [-5.00:0.25:5.00]

/* [Hidden] */

if (version_num()<20210100) echo("OpenSCAD version 2021.01 or newer is required.");
assert(version_num()>=20210100);

fWbu = Frame_unit_width_in_bin_units;
fDbu = Frame_depth_in_bin_units;

binDrawersEnabled = Bin_drawer_compensation || Frame_width_units == "bins";

fWUnits = Frame_width_units;
fDUnits = Frame_depth_units != "same" && (Frame_depth_units != "bins" || binDrawersEnabled) ? Frame_depth_units : fWUnits;
fHUnits = Frame_height_units != "same" ? Frame_height_units : fWUnits == "bins" ? "mm" : fWUnits;

fWmm = fWUnits == "mm"     ? Frame_unit_width_in_mm
     : fWUnits == "inches" ? mm(Frame_unit_width_in_inches)
     : 0;

fDmm = fDUnits == "mm"     ? Frame_depth_in_mm
     : fDUnits == "inches" ? mm(Frame_depth_in_inches)
     : 0;

fHmm = fHUnits == "mm"     ? Frame_unit_height_in_mm
     :                       mm(Frame_unit_height_in_inches);

dubWallBinDrawers = Double_bin_drawer_walls;
dubWallFaceLip = Add_lip_behind_face_of_double_wall_drawers;

fullFn = !$preview || Full_resolution_corners;

fudge  = 0.01;
fudge2 = 0.02;

gap = Cut_gap;
fancy = Fancy_back;


// some effort has been made to use:
//   x, y, z   for absolute postions
//   w, d, h   for relative dimensions
// but there are many exceptions and ambiguous cases
//
// prefixes:
//   d - Drawer

//   b - Bin
//   f - Frame


bWall = Bin_line_width;
bWall2 = bWall*2;
bLayerHN = Bin_layer_height;
bLayerH0 = Bin_first_layer_height;

dWall = Drawer_line_width;
dWall2 = dWall*2;
dLayerHN = Drawer_layer_height;
dLayerH0 = Drawer_first_layer_height;

fWall = Frame_line_width;
fWall2 = fWall*2;
fLayerHN = Frame_layer_height;
fLayerH0 = Frame_first_layer_height;

function bH(l) = layer_relative_height(l, bLayerHN);
function dH(l) = layer_relative_height(l, dLayerHN);
function fH(l) = layer_relative_height(l, fLayerHN);
function bZ(l) = layer_absolute_height(l, bLayerHN, bLayerH0);
function dZ(l) = layer_absolute_height(l, dLayerHN, dLayerH0);
function fZ(l) = layer_absolute_height(l, fLayerHN, fLayerH0);

bSlopXY = Bin_horizontal_slop;
bSlopZ  = bH(Bin_vertical_slop);

dSlopXY = Drawer_horizontal_slop;
dSlopZ  = dH(Drawer_vertical_slop);
dSlop45 = max(0, dSlopZ - dSlopXY);

fSlopXY = Frame_horizontal_slop;
fSlopB  = Back_wall_extra_slop;
fSlopZ  = fH(Frame_vertical_slop);  // hook overhang
fWallGrid = fWall2 + fSlopXY;
fWall4 = fWallGrid + fWall2;

bBase = bZ(Bin_base_layers);
dBase = dZ(Drawer_base_layers);
fBase = fZ(Frame_base_layers);
fTop = fH(Thickness_of_front_fills);

function bFloorH(h) = floor_relative_height_layer(h, bLayerHN);
function dFloorH(h) = floor_relative_height_layer(h, dLayerHN);
function fFloorH(h) = floor_relative_height_layer(h, fLayerHN);

function bCeilH(h)  =  ceil_relative_height_layer(h, bLayerHN);
function dCeilH(h)  =  ceil_relative_height_layer(h, dLayerHN);
function fCeilH(h)  =  ceil_relative_height_layer(h, fLayerHN);

function bRoundH(h) = round_relative_height_layer(h, bLayerHN);
function dRoundH(h) = round_relative_height_layer(h, dLayerHN);
function fRoundH(h) = round_relative_height_layer(h, fLayerHN);

function bFloorZ(z) = floor_absolute_height_layer(z, bLayerHN, bLayerH0);
function dFloorZ(z) = floor_absolute_height_layer(z, dLayerHN, dLayerH0);
function fFloorZ(z) = floor_absolute_height_layer(z, fLayerHN, fLayerH0);

function bCeilZ(z)  =  ceil_absolute_height_layer(z, bLayerHN, bLayerH0);
function dCeilZ(z)  =  ceil_absolute_height_layer(z, dLayerHN, dLayerH0);
function fCeilZ(z)  =  ceil_absolute_height_layer(z, fLayerHN, fLayerH0);

function bRoundZ(z) = round_absolute_height_layer(z, bLayerHN, bLayerH0);
function dRoundZ(z) = round_absolute_height_layer(z, dLayerHN, dLayerH0);
function fRoundZ(z) = round_absolute_height_layer(z, fLayerHN, fLayerH0);

// s - Snap: frame
sLS     = [   1/Horizontal_hook_bump_latch_slope           ,   1/Vertical_hook_bump_latch_slope           ];  // latch slope
sRS     = [   1/Horizontal_hook_bump_ramp_slope            ,   1/Vertical_hook_bump_ramp_slope            ];  // ramp slope
sPH     = [     Horizontal_hook_bump_height/2              ,     Vertical_hook_bump_height/2              ];  // peak height
sPL     = [  fH(Horizontal_hook_bump_peak_length)          ,  fH(Vertical_hook_bump_peak_length)          ];  // peak length
sLL     = [     sPH.x*sLS.x                                ,     sPH.y*sLS.y                              ];  // latch length
sRL     = [     sPH.x*sRS.x                                ,     sPH.y*sRS.y                              ];  // ramp length
sFI     = [  fH(Horizontal_hook_bump_front_inset+0.5)      ,  fH(Vertical_hook_bump_front_inset+0.5)      ];  // front inset length
sBI     = [  fH(Horizontal_hook_bump_back_inset)           ,  fH(Vertical_hook_bump_back_inset)           ];  // back inset length
sOL     = [  fH(Horizontal_hook_bump_overlap)              ,  fH(Vertical_hook_bump_overlap)              ];  // overlap

hookGO  = [     Horizontal_hook_gap_offset                 ,     Vertical_hook_gap_offset                 ];  // gap offset
hookMO  = [     Horizontal_hook_margin_offset              ,     Vertical_hook_margin_offset              ];  // margin offset
hookMin = [     Horizontal_hook_bump_minimum_contact_patch ,     Vertical_hook_bump_minimum_contact_patch ];  // minimum contact
hookW   = [     Horizontal_hook_size                       ,     Vertical_hook_size                       ];  // hook width

hookG   = [     sPH.x   + hookGO.x                         ,     sPH.y   + hookGO.y                       ];  // gap
hookM   = [     sPH.x/2 - hookGO.x/2 + hookMO.x            ,     sPH.y/2 - hookGO.y/2 + hookMO.y          ];  // margin
claspD  = [      fWall4 + hookG.x    + hookM.x*2           ,      fWall4 + hookG.y    + hookM.y*2         ];  // clasp depth
claspW  =        fWall4;                                                                                      // clasp width

fGridY = fHmm;
drawerZ = fGridY - claspD.y + hookM.y - fWallGrid - dSlopZ*2;
binZ = bFloorZ(drawerZ - dBase - bSlopZ);

dWallsX = dubWallBinDrawers ? dWall2*2 : dWall*2;
bMinGridXY = claspD.x + fWallGrid*2 + dWallsX + dSlopXY*2 + bSlopXY;

fWUseBU = fWUnits == "bins";
binsX    = fWUseBU ? fWbu              : floor(fWmm/bMinGridXY) - 1;
bGridXY  = fWUseBU ? bMinGridXY        : fWmm/(binsX+1);
binXY    = bGridXY - bSlopXY;
drawerX  = bGridXY*binsX + bSlopXY + dWallsX + (!fWUseBU && !Bin_drawer_compensation ? bGridXY-bMinGridXY : 0);
fGridX   = fWUseBU ? bGridXY*(binsX+1) : fWmm;
stretchX = !fWUseBU && Bin_drawer_compensation ? bGridXY-bMinGridXY : 0;

stretchXFill = Fill_horizontal_gaps;

// O - Outer
// I - Inner
fHornY = fGridY/2 - fSlopXY/2;
fTopOY = fHornY - claspD.y + hookM.y + fWall2;
fTopIY = fTopOY - fWall2;
fSideOX = fGridX/2 - claspD.x/2 - stretchX/2 - fSlopXY;
fSideIX = fSideOX - fWall2;
fBulgeOX = fGridX/2 - fSlopXY/2;
fBulgeIX = fBulgeOX - fWall2;
fBulgeOY = fHornY - claspW - hookW.x - fSlopXY;
fBulgeIY = fBulgeOY - fWall2;
fBulgeWall = fBulgeOX - fSideOX;
fTHookY = fTopOY;
fBHookY = -fHornY + fWallGrid;

stemD   = [    claspD.x + stretchX/2 - hookM.x + fSlopXY   ,           claspD.y - hookM.y + fSlopXY       ];  // stem depth
hookOL  = fancy
        ? [  0                                             ,  0                                           ]   // hook overlap
        : [ -fBulgeWall + stretchX/2 + hookM.x             ,  fWall2 - claspD.y + hookM.y*2               ];

railD = fBulgeWall/2;

dFS = 1/Drawer_bump_front_slope;                            // drawer front slope
dBS = 1/Drawer_bump_back_slope;                             // drawer back slope
cRS = 1/Catch_bump_ramp_slope;                              // catch ramp slope
hRS = 1/Hold_bump_ramp_slope;                               // hold ramp slope
kRS = 1/Keep_bump_ramp_slope;                               // keep ramp slope
bRS = 1;                                                    // bottom ramp slope

// d - Drawer
dPH = railD/2 + Drawer_bump_height/2;                       // drawer peak height
dPL = fH(Drawer_bump_peak_length);                          // drawer peak length
dFL = dPH*dFS;                                              // drawer front length
dBL = dPH*dBS;                                              // drawer back length
dSW = dH(Drawer_bump_spring_width);                         // drawer spring width

// c - Catch: back, holds drawer shut
cPH = dPH + Catch_bump_height_offset;                       // catch peak height
cPL = fH(Catch_bump_peak_length);                           // catch peak length
cFL = cPH*cRS;                                              // catch front length
cBL = cPH*dFS;                                              // catch back length
cIL = 0;                                                    // catch inset length (acts only on itself)
cCH = railD - dPH + Catch_cushion_height_offset + dSlopXY;  // catch cushion height

// h - Hold: front, holds drawer open
hPH = dPH + Hold_bump_height_offset;                        // hold peak height
hPL = fH(Hold_bump_peak_length);                            // hold peak length
hFL = hPH*dBS;                                              // hold front length
hBL = hPH*hRS;                                              // hold back length
hIL = 0;                                                    // hold inset length (acts only on itself)

// k - Keep: front, holds drawer in
kPH = dPH + Keep_bump_height_offset;                        // keep peak height
kPL = fH(Keep_bump_peak_length);                            // keep peak length
kFL = kPH*kRS;                                              // keep front length
kBL = kPH*dFS;                                              // keep back length
kIL = fH(0.5);                                              // keep inset length (also pulls hold and front drawer bump with it)

// b - Bottom: bottom, holds drawer in
bSH = dZ(Bottom_slot_height);                               // bottom slot height
bPH = dZ(Bottom_bump_height);                               // bottom peak height
bPL = fH(Bottom_bump_peak_length);                          // bottom peak length
bFL = bPH*bRS;                                              // bottom front length
bBL = bPH*bRS;                                              // bottom back length
bIL = fH(0.5);                                              // bottom inset length
bPW = fWall2*Bottom_bump_width;                             // bottom peak width

peakWN = fBulgeIY*2 - dSlop45*2 - dPH*2 - railD*2 - dSW*2;

// calculate rail width so the steepest peak overhang is 45°
railWN = peakWN + max(dPH*2, cPH*2-railD*2+dSlop45*2, hPH*2-railD*2+dSlop45*2, kPH*2-railD*2+dSlop45*2);

fStopLines0 = Frame_stop_lines_for_single_unit_high_parts;
fStopLinesN = Frame_stop_lines_for_multi_unit_high_parts;
dStopLines = Drawer_stop_lines;

peakW1 = peakWN - (fWall2 + gap)*fStopLines0
       + dFloorZ(fGridY - claspW - hookW.x - fWallGrid*2 - dSlopZ*2)
       -        (fGridY - claspW - hookW.x - fWallGrid*2 - dSlopZ*2);

keyholes = Enable_mounting_holes;
keyholeFn = fullFn ? Mounting_hole_segments : 8;
keyShaftR = circumgoncircumradius(d=Fastener_shaft_diameter+fSlopXY*2, $fn=keyholeFn);
keyOpeningR = circumgoncircumradius(d=Fastener_head_diameter+fSlopXY*2, $fn=keyholeFn);
keyOpeningB = Keyhole_opening_bevel;
keyHeadR = Fastener_head_diameter/2;
keyHeadH = keyholes ? Fastener_head_height : 0;
keyholeL = Keyhole_length + fSlopXY*2;
keyholeW = Fastener_shaft_diameter + fSlopXY*2 + Keyhole_width_offset;
keyholeA = Keyhole_angle - 90;

dFloat = Drawer_float;
dFaceD = dWall2 + dFloat;  // how far the sides must extend to be flush with the drawer faces
dBackD = max(fBulgeWall, keyHeadH);  // gap behind drawer
dWallsY = dubWallBinDrawers ? (dubWallFaceLip ? dWall2*2 : dWall2-gap) : dWall*2;

fDUseBU = fDUnits == "bins";
drawerMaxY  = fDUseBU ? undef                                  : fFloorZ(fDmm) - fBase - dBackD - gap;
binsY       = fDUseBU ? fDbu                                   : floor((drawerMaxY - bSlopXY - dWallsY)/bGridXY);
drawerY     = fDUseBU ? bGridXY*binsY + bSlopXY + dWallsY      : Bin_drawer_compensation ? bGridXY*binsY + bSlopXY + dWallsY : drawerMaxY;
fGridZIdeal = fDUseBU ? fBase + dBackD + drawerY + gap         : fDmm;
fGridZ      = fDUseBU ? fCeilZ(fGridZIdeal)                    : fFloorZ(fGridZIdeal);
stretchY    = fDUseBU ? fGridZ - fGridZIdeal + dBackD + dFloat : drawerMaxY - drawerY + dBackD + dFloat;

cInset = cIL + dBL + dPL - (railD+dSlopXY-dPH)*dFS + fBase + stretchY - fBulgeWall;  // back catch bump
dInset = kIL + kFL + kPL - (railD+dSlopXY-kPH)*dFS + dFloat - gap;               // front drawer bump
hInset = hIL + dFL + dPL - (railD+dSlopXY-dPH)*dBS + dInset + gap - dFloat;      // front hold bump
kInset = kIL;                                                                    // front keep bump

dTravel = drawerY + fBulgeWall - dInset - dFL - dPL - dBL;

drawerYFrameZAlign = fBase + stretchY + drawerY/2;
drawerZFrameYAlign = fWall2 + dSlopZ - fHornY;

trim = Enable_trim;

// t - Trim
// m - triM (bottom - should be a bit looser)
tLS = 1/Trim_bump_latch_slope;                              // latch slope
tRS = 1/Trim_bump_ramp_slope;                               // ramp slope
tPH = Trim_bump_height/2;                                   // peak height
mPH = Trim_bottom_bump_height/2;                            // peak height
tPL = fH(Trim_bump_peak_length);                            // peak length
tLL = tPH*tLS;                                              // latch length
mLL = mPH*tLS;                                              // latch length
tRL = tPH*tRS;                                              // ramp length
mRL = mPH*tRS;                                              // ramp length
tIL = fH(0.5);                                              // inset length
tOL = fH(Trim_bump_overlap);                                // overlap

tLip = Front_lip;
tFloat = fH(Trim_float);
tBase = fFloorZ(dFaceD - tFloat + tLip);
tInsert = trim ? fCeilH(tFloat + tIL - fSlopXY*tLS + tOL + tRL + tPL*2 + tLL*2) : 0;
mInsert = trim ? fCeilH(tFloat + tIL - fSlopXY*tLS + tOL + mRL + tPL*2 + mLL*2) : 0;
tClearance = (trim ? fWallGrid : 0) + max(bPH, hookM.y);

fSideZ = fCeilZ(fGridZ + dFaceD + tLip);

fDrawerLayerCompLines = Drawer_layer_compensation_lines;

dFilletFn = fullFn ? Back_fillet_segments*4 : 8;

cornerFn = fullFn ? Side_corner_segments*4 : 8;

binR = Bin_radius;
binFn = fullFn ? Bin_segments*8 : 8;

simpleDdivisions = [ for (i=[0:len(Divisions)-1]) if (Divisions[i]!=0) (
  if (i==0) [ abs(Divisions[i]), map(function (x) abs(x), filter(function (x) x!=0, Row_1_subdivisions)) ] else
  if (i==1) [ abs(Divisions[i]), map(function (x) abs(x), filter(function (x) x!=0, Row_2_subdivisions)) ] else
  if (i==2) [ abs(Divisions[i]), map(function (x) abs(x), filter(function (x) x!=0, Row_3_subdivisions)) ] else
  if (i==3) [ abs(Divisions[i]), map(function (x) abs(x), filter(function (x) x!=0, Row_4_subdivisions)) ] else
  if (i==4) [ abs(Divisions[i]), map(function (x) abs(x), filter(function (x) x!=0, Row_5_subdivisions)) ] else
  if (i==5) [ abs(Divisions[i]), map(function (x) abs(x), filter(function (x) x!=0, Row_6_subdivisions)) ] else
  if (i==6) [ abs(Divisions[i]), map(function (x) abs(x), filter(function (x) x!=0, Row_7_subdivisions)) ] else
  if (i==7) [ abs(Divisions[i]), map(function (x) abs(x), filter(function (x) x!=0, Row_8_subdivisions)) ] else
  abs(Divisions[i])
) ];

// It is possible to nest subdivisions much deeper than the two levels provided in the customizer.
// Each level rotates 90°, so the first level is front to back, level two is left to right, level
// three is back to front, and so on.
//
// Divisions are specified by an array of numbers indicating their relative sizes. To subdivide
// a division, wrap its number in another array, and add a nested array as the second element
// to specify the subdivisions.
//
// Uncomment this line for an example arrangement with three levels:
// bespokeDivisions = [  [2, [1,1]],  [4, [[2, [1,1]], 4, [2, [1,1]]]],  [3, [1,1,1]]  ];
// // levels:             1   2 2      1    2   3 3    2   2   3 3        1   2 2 2

divisions = is_undef(bespokeDivisions) ? simpleDdivisions : bespokeDivisions;

dChamfer = Back_bottom_chamfer;
hornC = min(Horn_chamfer, fHornY-fTopOY+fH(0.5));
stemC = [ min(Horizontal_stem_chamfer, fWallGrid+hookG.x/2+fH(0.5)), 0 ];
hookC = [ min(Horizontal_hook_chamfer, hookW.x+(stemC.x>0?0:fH(0.5))), min(Vertical_hook_chamfer, hookW.y-bPW+fWall2+fH(0.5)) ];

handleL = Handle_length;
handleD = Handle_circumference_diameter;
handleDFn = fullFn ? Handle_circumference_segments*2 : 8;
handleElliptical = Elliptical_handle;
handleR = Handle_bend_radius;
handleRFn = fullFn ? Handle_bend_segments*2 : 8;
handleTray = Tray_handle;

drawCuts = !$preview || Draw_cuts;

compensated = stretchX>0;

echo("Frame unit size:");
echo(str("    width: \t", fGridX, (compensated ? str(" mm, ", stretchX, " mm used for bin drawer compensation") : " mm")));
echo(str("    height:\t", fGridY, " mm"));
if (binDrawersEnabled) {
  echo("Bin unit size:");
  echo(str("    sides: \t", bGridXY, (compensated ? str(" mm, ", bMinGridXY, " mm minimum before compensation") : " mm")));
  echo("Bins units per frame unit:");
  echo(str("    width: \t", binsX, " bin unit", binsX==1 ? "" : "s"));
  echo(str("    depth: \t", binsY, " bin unit", binsY==1 ? "" : "s"));
}
echo("Depths:")
echo(str("    sides: \t", fSideZ, " mm"));
echo(str("    frame: \t", fGridZ, " mm"));
echo(str("    drawer travel:   \t", dTravel, " mm"));
echo(str("    face (closed):   \t", fGridZ+dFaceD , " mm"));
echo(str("    face (open):     \t", fGridZ+dFaceD+dTravel , " mm"));
echo(str("    handle (closed): \t", fGridZ+dFaceD+handleL, " mm"));
echo(str("    handle (open):   \t", fGridZ+dFaceD+handleL+dTravel, " mm"));
echo("Bump peak width:")
echo(str("    part height = 1: \t", peakW1, " mm"));
echo(str("    part height > 1: \t", peakWN, " mm"));
if (peakW1<0) {
  if (peakWN<0) echo("WARNING: Inadequate space for bumps.");
  else echo("WARNING: Inadequate space for bumps on single unit high parts. Multiple unit high drawers are ok.");
}



///////////////////
// COLOR HELPERS //
///////////////////


solidBlue   = [0.00, 0.20, 0.40, 1.00];
solidBrown  = [0.40, 0.20, 0.00, 1.00];
solidOrange = [0.85, 0.55, 0.02, 1.00];
solidGrey   = [0.60, 0.60, 0.60, 1.00];
transBlue   = [0.05, 0.40, 0.90, 0.30];
transGrey   = [0.50, 0.50, 0.50, 0.50];

errorColor  = [1.00, 0.33, 0.33, 0.50];

// highlight errors
module hl(e, msg) {
  if (e) {
    if (is_string(msg)) echo(str("ERROR: ", msg));
    #children();
  }
  else children();
}

// conditional color
module condColor(c) {
  if (is_list(c)) {
    assert(len(c)==3 || len(c)==4);
    if (len(c)==4 && c[3]<1) color(c) {
      if ($preview && Render_transparent_parts) render() children();
      else children();
    }
    else color(c) children();
  }
  else if (c) children();
}



///////////
// HOOKS //
///////////


// h    - hook handedness, -1 or 1
// d    - connection direction, 0 for horizontal or 1 for vertical
// p    - position, 0 for top/left or 1 for bottom/right
// hang - how far below the origin to sink the stem into whatever its growing out of
module latch(h, d, p, hang=fudge) {
  hookBZ = max(0, fBase-hookOL[d]);
  hangBZ = max(0, fBase-hookOL[d]-hang-stemD[d]);
  bumpBZ = hookBZ + hookW[d];
  bumpFZ = fGridZ - stemC[d] - hookC[d];
  maxBumpL = hookW[d] - fSlopXY;
  minBumpL = max(fWall2, maxBumpL/2+hookMin[d]/2);
  fullBumpL = maxBumpL - fWallGrid;
  bumpL = min(max(minBumpL, fullBumpL), maxBumpL);

  hl(bumpL<fWall2, "Frame hooks are not wide enough.") translate([-(claspW+hookW[d])*h/2, stemD[d], 0]) {
    translate([(hookW[d]+fWall2)*h, -fWall2, 0]) {
      // side stop
      if (minBumpL<=fullBumpL) translate([0, fudge, bumpFZ]) hull() {
        box([-fWall2*h, -fudge         , bumpBZ-bumpFZ         ]);
        box([-fWall2*h, -fudge-hookG[d], bumpBZ-bumpFZ+hookG[d]]);
      }
      rotate([90,0,-90]) extrude(bumpL*h, convexity=1) {
        // front bump
        polygon(
          [ [-fudge , bumpFZ-sFI[d]+(hookGO[d]+fSlopXY)*sLS[d]-sOL[d]-sRL[d]-sPL[d]            ]
          , [ 0     , bumpFZ-sFI[d]+(hookGO[d]+fSlopXY)*sLS[d]-sOL[d]-sRL[d]-sPL[d]            ]
          , [ sPH[d], bumpFZ-sFI[d]+(hookGO[d]+fSlopXY)*sLS[d]-sOL[d]-sRL[d]-sPL[d]  -sLL[d]   ]
          , [ sPH[d], bumpFZ-sFI[d]+(hookGO[d]+fSlopXY)*sLS[d]-sOL[d]-sRL[d]-sPL[d]*2-sLL[d]   ]
          , [ 0     , bumpFZ-sFI[d]+(hookGO[d]+fSlopXY)*sLS[d]-sOL[d]-sRL[d]-sPL[d]*2-sLL[d]*2 ]
          , [-fudge , bumpFZ-sFI[d]+(hookGO[d]+fSlopXY)*sLS[d]-sOL[d]-sRL[d]-sPL[d]*2-sLL[d]*2 ]
          ]);
        // back bump
        polygon(
          [ [-fudge , bumpBZ+sBI[d]                                         +sPL[d]  +sLL[d]*2 ]
          , [ 0     , bumpBZ+sBI[d]                                         +sPL[d]  +sLL[d]*2 ]
          , [ sPH[d], bumpBZ+sBI[d]                                         +sPL[d]  +sLL[d]   ]
          , [ sPH[d], bumpBZ+sBI[d]                                                  +sLL[d]   ]
          , [ 0     , bumpBZ+sBI[d]                                                            ]
          , [-fudge , bumpBZ+sBI[d]                                                            ]
          ]);
      }
    }
    // hook wall
    rotate([90,0,0]) extrude(fWall2, convexity=1) scale([h, 1]) translate([fWall2, 0]) polygon(
      [ [-fudge            , fGridZ-stemC[d]          ]
      , [ hookW[d]-hookC[d], fGridZ-stemC[d]          ]
      , [ hookW[d]         , fGridZ-stemC[d]-hookC[d] ]
      , [ hookW[d]         , bumpBZ                   ]
      , [ 0                , hookBZ                   ]
      , [-fudge            , hookBZ                   ]
      ]);
    // stem
    rotate([90,0,-90]) extrude(-fWall2*h, convexity=1) polygon(
      [ [                           0        ,             fGridZ-stemC[d] ]
      , [                           stemC[d] ,             fGridZ          ]
      , [                      hang+stemD[d] ,             fGridZ          ]
      , [                      hang+stemD[d] ,             fGridZ          ]
      , [                      hang+stemD[d] , hookOL[d]<0?hangBZ:0        ]
      , [ min(fBase-hookOL[d], hang+stemD[d]), hookOL[d]<0?hangBZ:0        ]
      , [                           0        , hookOL[d]<0?hookBZ:0        ]
      ]);
  }
}

// h    - hook handedness, -1 or 1
// d    - connection direction, 0 for horizontal or 1 for vertical
// p    - position, 0 for top/left or 1 for bottom/right
// hang - how far below the origin to sink the stem into whatever its growing out of
module plate(h, d, p, hang=fudge, stop=undef) {
  hookBZ = max(0, fBase-hookOL[d]);
  stopBZ = hookBZ - fSlopZ + hookW[d];
  bumpBZ = hookBZ + hookW[d];
  bumpFZ = fGridZ - stemC[d] - hookC[d];
  maxBumpL = hookW[d] - fSlopXY;
  minBumpL = max(fWall2, maxBumpL/2+hookMin[d]/2);
  fullBumpL = maxBumpL - fWallGrid;
  bumpL = min(max(minBumpL, fullBumpL), maxBumpL);

  hl(bumpL<fWall2, "Frame hooks are not wide enough.") translate([-(claspW+hookW[d])*h/2, stemD[d], 0]) {
    // hook stop
    translate([fWall2*h, hookM[d]*2-claspD[d], 0]) rotate([90,0,0]) extrude(-fWall2, convexity=1) scale([h, 1]) polygon(
      [ [-fudge   , stopBZ+fSlopXY+fudge   ]
      , [ hookW[d], stopBZ+fSlopXY-hookW[d]]
      , [ hookW[d],      0                 ]
      , [-fudge   ,      0                 ]
      ]);
    translate([(hookW[d]+fWall2)*h, -fWall2, 0]) {
      // side stop
      if (minBumpL<=fullBumpL) translate([0, fudge, 0]) box([-fWall2*h, -fudge-hookG[d], bumpFZ]);
      rotate([90,0,-90]) {
        // front bump
        extrude(bumpL*h, convexity=1) polygon(
          [ [-fudge   , bumpFZ-sFI[d]                                                            ]
          , [ 0       , bumpFZ-sFI[d]                                                            ]
          , [ sPH[d]  , bumpFZ-sFI[d]                                  -sRL[d]                   ]
          , [ sPH[d]  , bumpFZ-sFI[d]                                  -sRL[d]-sPL[d]            ]
          , [ 0       , bumpFZ-sFI[d]                                  -sRL[d]-sPL[d]  -sLL[d]   ]
          , [-fudge   , bumpFZ-sFI[d]                                  -sRL[d]-sPL[d]  -sLL[d]   ]
          ]);
        // back bump
        extrude(bumpL*h, convexity=1) polygon(
          [ [-fudge   , bumpBZ+sBI[d]-(hookGO[d]+fSlopXY)*sLS[d]+sOL[d]+sRL[d]+sPL[d]*2+sLL[d]*2 ]
          , [ 0       , bumpBZ+sBI[d]-(hookGO[d]+fSlopXY)*sLS[d]+sOL[d]+sRL[d]+sPL[d]*2+sLL[d]*2 ]
          , [ sPH[d]  , bumpBZ+sBI[d]-(hookGO[d]+fSlopXY)*sLS[d]+sOL[d]       +sPL[d]*2+sLL[d]*2 ]
          , [ sPH[d]  , bumpBZ+sBI[d]-(hookGO[d]+fSlopXY)*sLS[d]+sOL[d]       +sPL[d]  +sLL[d]*2 ]
          , [ 0       , bumpBZ+sBI[d]-(hookGO[d]+fSlopXY)*sLS[d]+sOL[d]       +sPL[d]  +sLL[d]   ]
          , [-fudge   , bumpBZ+sBI[d]-(hookGO[d]+fSlopXY)*sLS[d]+sOL[d]       +sPL[d]  +sLL[d]   ]
          ]);
        // back stop
        extrude(bumpL*h, convexity=1) polygon(
          [ [-fudge   , stopBZ+sBI[d]+(hookGO[d]+fSlopXY)*sLS[d]                       +sLL[d]   ]
          , [ 0       , stopBZ+sBI[d]+(hookGO[d]+fSlopXY)*sLS[d]                       +sLL[d]   ]
          , [ hookG[d], stopBZ+sBI[d]           +fSlopXY *sLS[d]                                 ]
          , [ hookG[d],      0                                                                   ]
          , [-fudge   ,      0                                                                   ]
          ]);
      }
    }
    // hook wall
    rotate([90,0,0]) extrude(fWall2, convexity=1) scale([h, 1]) translate([fWall2, 0]) polygon(
      [ [-fudge            , fGridZ-stemC[d]          ]
      , [ hookW[d]-hookC[d], fGridZ-stemC[d]          ]
      , [ hookW[d]         , fGridZ-stemC[d]-hookC[d] ]
      , [ hookW[d]         ,      0                   ]
      , [-fudge            ,      0                   ]
      ]);
    // stem
    translate([0, -stemD[d]-hang, 0]) hull() {
      box([fWall2*h, stemD[d]+hang, fGridZ-stemC[d]]);
      box([fWall2*h, stemD[d]+hang-stemC[d], fGridZ]);
    }
  }
}

module tHooks(drawHooks=true) hl(fSideIX-fSlopXY-claspW-hookW.y<gap/2, "Top hooks are too close.")
  flipX() translate([fSideIX-fSlopXY-claspW/2-hookW.y/2, fTHookY, 0]) {
    if (drawHooks) plate(1, 1, 0, stop=claspD.y-hookM.y-fWall2);
    hl(bPW<fWall2, "Bottom bumps are not wide enough.") translate([-claspW/2-hookW.y/2, stemD.y, fGridZ-bIL-bFL]) hull() {
      translate([0, 0, bFL]) box([bPW, -fudge, -bFL-bPL-bBL]);
      box([bPW, bPH, -bPL]);
    };
  }
module bHooks() rotate(180) flipX() translate([ fSideIX-fSlopXY-claspW/2-hookW.y/2, -fBHookY-hookM.y, 0]) latch(-1, 1, 1, hang=tClearance-hookM.y+fudge);
module blHook() rotate(180)         translate([ fSideIX-fSlopXY-claspW/2-hookW.y/2, -fBHookY-hookM.y, 0]) latch(-1, 1, 1, hang=-hookM.y-fSlopXY);
module brHook() rotate(180)         translate([-fSideIX+fSlopXY+claspW/2+hookW.y/2, -fBHookY-hookM.y, 0]) latch( 1, 1, 1, hang=-hookM.y-fSlopXY);

module lHooks() rotate( 90) flipX() translate([fHornY-claspW/2-hookW.x/2, fSideOX, 0]) latch( 1, 0, 0);
module rHooks() rotate(270) flipX() translate([fHornY-claspW/2-hookW.x/2, fSideOX, 0]) plate(-1, 0, 1, stop=claspD.x/2+fSlopXY/2);



//////////////////
// FILL HELPERS //
//////////////////


function fillAdjusted    (w, flushSides)        = abs(w) + (flushSides-1)*gap;
function fillWalls       (w, flushSides, wall2) = div(fillAdjusted(w, flushSides)+fudge, wall2+gap);  // `fudge` compensates for some FP precision errors
function fillResidue     (w, flushSides, wall2) = max(0, fillAdjusted(w, flushSides) - fillWalls(w, flushSides, wall2)*(wall2+gap));  // ditto for `max(0, ...)`
function fillResidueShare(w, flushSides, wall2) = fillResidue(w, flushSides, wall2) / (fillWalls(w, flushSides, wall2)*2 - flushSides + 1);
function fillGrid        (w, flushSides, wall2) = fillResidueShare(w, flushSides, wall2)*2 + wall2 + gap;
function fillWall        (w, flushSides, wall2) = fillResidueShare(w, flushSides, wall2) + wall2;
function fillGap         (w, flushSides, wall2) = fillResidueShare(w, flushSides, wall2) + gap;


module sliceX(bounds, translate=[0,0]
, flushT=false, flushB=false, flushL=false, flushR=false
, centerX=false, centerY=false
, cutT=false, cutB=false, cutMid=false, cutAlt=false
, wall2=fWall2
) {
  x = abs(bounds.x);
  y = abs(bounds.y);
  flushSides = (flushL?1:0) + (flushR?1:0);
  flushEnds  = (flushT?1:0) + (flushB?1:0);
  flushEndOffset = (flushT?fudge/2:0) - (flushB?fudge/2:0);
  fillWalls = fillWalls(x, flushSides, wall2);
  fillGrid  = fillGrid (x, flushSides, wall2);
  fillWall  = fillWall (x, flushSides, wall2);
  fillGap   = fillGap  (x, flushSides, wall2);
  tx = translate.x + (centerX ? -bounds.x/2 : 0) + (bounds.x<0 ? bounds.x : 0);
  ty = translate.y + (centerY ? -bounds.y/2 : 0) + bounds.y/2;
  module antiChildren(dir) render() difference() {
    translate([flushL?-fudge:0, flushEndOffset]) rect([x+fudge*flushSides, y+fudge*flushEnds], [1,0]);  // bounds for gaps
    intersection() {
      translate([-tx, -ty]) hull() {
        translate([0, dir*y]) offset(delta=-gap) children();
        offset(delta=-gap) children();
      }
      translate([-fudge*2, gap*dir]) rect([x+fudge2*2, y], [1,0]);  // expose only top or bottom
    }
  }
  translate([tx, ty]) {
    if (fillWalls>0) {
      if (cutMid) translate([flushL?-fudge:0, 0]) rect([x+fudge*flushSides, gap], [1,0]);
      for (i=[0:fillWalls-1]) {
        itx = fillGrid*i - (flushL ? fillGap : 0);
        if (i>0) translate([itx, flushEndOffset]) rect([fillGap, y+fudge*flushEnds], [1,0]);
        if (cutT || cutB || cutAlt || is_num(cutAlt)) intersection() {
          translate([itx, flushEndOffset]) rect([fillWall+fillGap*2, y+fudge*flushEnds], [1,0]);  // one wall + both gaps
          if (cutT) { antiChildren(-1)
            if ($children>0) children();
            else translate(translate.x-tx, translate.y-ty) rect(bounds*4, [0,0]);
          }
          if (cutB) { antiChildren(1)
            if ($children>0) children();
            else translate(translate.x-tx, translate.y-ty) rect(bounds*4, [0,0]);
          }
          if (cutAlt || is_num(cutAlt)) { antiChildren((mod(i+(is_num(cutAlt)?cutAlt:0), 2)*2-1))
            if ($children>0) children();
            else translate(translate.x-tx, translate.y-ty) rect(bounds*4, [0,0]);
          }
        }
      }
      if (!flushL) translate([0, flushEndOffset]) rect([fillGap, y+fudge*flushEnds], [1,0]);
      if (!flushR) translate([x-fillGap, flushEndOffset]) rect([fillGap, y+fudge*flushEnds], [1,0]);
    }
    else rect([x, y]);
  }
}

module sliceY(bounds, translate=[0,0]
, flushT=false, flushB=false, flushL=false, flushR=false
, centerX=false, centerY=false
, cutL=false, cutR=false, cutMid=false, cutAlt=false
, wall2=fWall2
) rotate(90) sliceX([bounds.y, -bounds.x], [translate.y, -translate.x]
  , flushT=flushL, flushB=flushR, flushL=flushB, flushR=flushT
  , centerX=centerY, centerY=centerX
  , cutT=cutL, cutB=cutR, cutMid=cutMid, cutAlt=cutAlt
  , wall2=wall2
  ) if ($children>0) rotate(-90) children();
    else translate(translate.y, -translate.x) rect([bounds.y*4, -bounds.x*4], [0,0]);

module eSliceX(h, bounds, translate=[0,0]
, flushT=false, flushB=false, flushL=false, flushR=false
, centerX=false, centerY=false, centerZ=false
, cutT=false, cutB=false, cutMid=false, cutAlt=false
, wall2=fWall2, layerH=fLayerHN, hFudge=0
) translate([0, 0, (centerZ?-h/2:0)+(h<0?h:0)])
    if ((cutAlt || is_num(cutAlt)) && (abs(h)>=layerH)) for (i=[0:abs(h)/layerH-1]) {
      translate([0, 0, layerH*i]) extrude(layerH+abs(hFudge)) sliceX(bounds, translate
      , flushT=flushT, flushB=flushB, flushL=flushL, flushR=flushR
      , centerX=centerX, centerY=centerY
      , cutT=cutT, cutB=cutB, cutMid=cutMid, cutAlt=mod(i+(is_num(cutAlt)?cutAlt:0), 2)
      , wall2=wall2
      ) if ($children>0) children();
        else translate(translate) rect(bounds*4, [0,0]);
    }
    // else extrude(abs(h)+fudge) sliceX(bounds, translate
    else extrude(abs(h)+abs(hFudge)) sliceX(bounds, translate
      , flushT=flushT, flushB=flushB, flushL=flushL, flushR=flushR
      , centerX=centerX, centerY=centerY
      , cutT=cutT, cutB=cutB, cutMid=cutMid
      , wall2=wall2
      ) translate(translate) rect(bounds*4, [0,0]);

module eSliceY(h, bounds, translate=[0,0]
, flushT=false, flushB=false, flushL=false, flushR=false
, centerX=false, centerY=false, centerZ=false
, cutL=false, cutR=false, cutMid=false, cutAlt=false
, wall2=fWall2, layerH=fLayerHN, hFudge=0
) translate([0, 0, (centerZ?-h/2:0)+(h<0?h:0)])
    if ((cutAlt || is_num(cutAlt)) && (abs(h)>=layerH)) for (i=[0:abs(h)/layerH-1]) {
      translate([0, 0, layerH*i]) extrude(layerH+abs(hFudge)) sliceY(bounds, translate
      , flushT=flushT, flushB=flushB, flushL=flushL, flushR=flushR
      , centerX=centerX, centerY=centerY
      , cutL=cutL, cutR=cutR, cutMid=cutMid, cutAlt=mod(i+(is_num(cutAlt)?cutAlt:0), 2)
      , wall2=wall2
      ) if ($children>0) children();
        else translate(translate) rect(bounds*4, [0,0]);
    }
    // else extrude(abs(h)+fudge) sliceY(bounds, translate
    else extrude(abs(h)+abs(hFudge)) sliceY(bounds, translate
      , flushT=flushT, flushB=flushB, flushL=flushL, flushR=flushR
      , centerX=centerX, centerY=centerY
      , cutL=cutL, cutR=cutR, cutMid=cutMid
      , wall2=wall2
      ) translate(translate) rect(bounds*4, [0,0]);

module eSlice(h, bounds, translate=[0,0]
, flushT=false, flushB=false, flushL=false, flushR=false
, centerX=false, centerY=false, centerZ=false
, cutT=false, cutB=false, cutL=false, cutR=false
, cutMidX=false, cutMidY=false, cutAltX=false, cutAltY=false
, wall2=fWall2, layerH=fLayerHN, hFudge=0
) if (fillResidueShare(bounds.x, (flushL?1:0)+(flushR?1:0), wall2) < fillResidueShare(bounds.y, (flushT?1:0)+(flushB?1:0), wall2)) {
    eSliceX(h, bounds, translate
    , flushT=flushT, flushB=flushB, flushL=flushL, flushR=flushR
    , centerX=centerX, centerY=centerY, centerZ=centerZ
    , cutT=cutT, cutB=cutB, cutMid=cutMidX, cutAlt=cutAltX
    , layerH=layerH, hFudge=hFudge
    , wall2=wall2
    ) if ($children>0) children();
      else translate(translate) rect(bounds*4, [0,0]);
  }
  else {
    eSliceY(h, bounds, translate
    , flushT=flushT, flushB=flushB, flushL=flushL, flushR=flushR
    , centerX=centerX, centerY=centerY, centerZ=centerZ
    , cutL=cutL, cutR=cutR, cutMid=cutMidY, cutAlt=cutAltY
    , layerH=layerH, hFudge=hFudge
    , wall2=wall2
    ) if ($children>0) children();
      else translate(translate) rect(bounds*4, [0,0]);
  }



///////////
// FILLS //
///////////


module tlSeamFill(l) translate([fGridX*l-fBulgeOX, -fHornY+tClearance+fWall4, 0]) {
  rB = [fBulgeWall+fWall4, -tClearance-fWall4];
  rL = rB - [fWall2, -fWall2];
  extrude(fBase) rect(rB);
  translate([0, 0, fGridZ-fTop]) difference() {
    hull() {
      extrude(fTop) rect(rB);
      extrude(rL.y) rect([rB.x, -fWall2]);
    }
    if (drawCuts) translate([0, -fWall2, 0]) {
      eSliceX(rL.y, rL, flushL=true);
      eSliceX(fTop, [rL.x, rL.y+fWall2], flushL=true, cutAlt=true, hFudge=fudge);
    }
  }
}

module trSeamFill(r) translate([fGridX*r+fBulgeOX, -fHornY+tClearance+fWall4, 0]) {
  rB = [-fBulgeWall-fWall4, -tClearance-fWall4];
  rL = rB - [-fWall2, -fWall2];
  extrude(fBase) rect(rB);
  translate([0, 0, fGridZ-fTop]) difference() {
    hull() {
      extrude(fTop) rect(rB);
      extrude(rL.y) rect([rB.x, -fWall2]);
    }
    if (drawCuts) translate([0, -fWall2, 0]) {
      eSliceX(rL.y, rL, flushR=true);
      eSliceX(fTop, [rL.x, rL.y+fWall2], flushR=true, cutAlt=true, hFudge=fudge);
    }
  }
}

module bFill(wall=0) translate([0, fHornY-claspD.y+hookM.y, 0]) {
  rB = [fSideOX*2-claspW*2-hookW.y*2-fSlopXY*2, stemD.y+fWall2];
  rL = rB - [fWall2*2, fWall2];
  // #extrude(fGridZ+1) rect(rB, [0,1]);
  // TODO: switch to an alternate fill instead of simply disabling when it gets too small
  if (rB.x>=fWall2*3+gap*2) translate([0, 0, fGridZ-wall-fTop]) difference() {
    union() {
      hull() {
        extrude(fTop) rect(rB, [0,1]);
        extrude(-rL.y) rect([rB.x, fWall2], [0,1]);
      }
      if (!$preview || !Expose_bottom_trim_bumps) translate([0, rB.y, 0]) extrude(fTop+wall) rect([rB.x, -fWall2], [0,1]);
    }
    if (drawCuts) translate([0, fWall2, 0]) {
      eSliceX(-rL.y, rL, centerX=true);
      eSliceX(fTop, [rL.x, rL.y-fWall2], centerX=true, cutAlt=true, hFudge=fudge);
      eSliceY(fTop+wall, [rL.x, fWall2], translate=[0, rL.y-fWall2], flushT=true, flushB=true, centerX=true, cutAlt=true, hFudge=fudge);
    }
  }
}

module bSeamFill() translate([fGridX/2, fHornY-claspD.y+hookM.y, 0]) {
  rB = [claspD.x+stretchX+fWallGrid*2, claspD.y-hookM.y];
  rL = rB - [fWall2*2, fWall2];
  extrude(fBase) rect(rB, [0,1]);
  translate([0, 0, fGridZ-fTop]) difference() {
    hull() {
      extrude(fTop) rect(rB, [0,1]);
      extrude(-rL.y) rect([rB.x, fWall2], [0,1]);
    }
    if (drawCuts) translate([0, fWall2, 0]) {
      eSliceX(-rL.y, rL, centerX=true);
      eSliceY(fTop, rL, flushT=true, centerX=true, cutAlt=true, hFudge=fudge);
    }
  }
}

module blSeamFill(l) translate([fGridX*l-fBulgeOX, fHornY-claspD.y+hookM.y, 0]) {
  rB = [fBulgeWall+fWall2, claspD.y-hookM.y];
  rL = rB - [fWall2, fWall2];
  extrude(fBase) rect(rB);
  translate([0, 0, fGridZ-fTop]) difference() {
    hull() {
      extrude(fTop) rect(rB);
      extrude(-rL.y) rect([rB.x, fWall2]);
    }
    if (drawCuts) translate([0, fWall2, 0]) {
      eSliceX(-rL.y, rL, flushL=true);
      eSliceY(fTop, rL, flushT=true, flushL=true, hFudge=fudge);
    }
  }
}

module brSeamFill(r) translate([fGridX*r+fBulgeOX, fHornY-claspD.y+hookM.y, 0]) {
  rB = [-fBulgeWall-fWall2, claspD.y-hookM.y];
  rL = rB - [-fWall2, fWall2];
  extrude(fBase) rect(rB);
  translate([0, 0, fGridZ-fTop]) difference() {
    hull() {
      extrude(fTop) rect(rB);
      extrude(-rL.y) rect([rB.x, fWall2]);
    }
    if (drawCuts) translate([0, fWall2, 0]) {
      eSliceX(-rL.y, rL, flushR=true);
      eSliceY(fTop, rL, flushT=true, flushR=true, hFudge=fudge);
    }
  }
}

module rHookFill() if (stretchXFill) {
  rB = [fWall2+stretchX/2, claspW+hookW.x];
  rL = rB - [fWall2, fWall2];
  flipY() translate([fSideIX, fBulgeIY, 0]) difference() {
    extrude(fGridZ) rect(rB);
    if (drawCuts) translate([fWall2, fWall2, fBase]) eSliceY(fGridZ-fBase, rL, flushT=true, flushR=true, hFudge=fudge);
  }
}

module ltHookFill(t) if (stretchXFill) {
  rB = [-fWall2-stretchX/2, -hookW.x-fWall2];
  rL = rB - [-fWall2, 0];
  translate([-fSideIX, fGridY*t+fHornY, 0]) difference() {
    extrude(fGridZ) rect(rB);
    if (drawCuts) translate([-fWall2, 0, fBase]) eSliceY(fGridZ-fBase, rL, flushT=true, flushB=true, flushL=true, hFudge=fudge);
  }
}

module lbHookFill(b) if (stretchXFill) {
  rB = [-fWall2-stretchX/2, hookW.x+fWall2];
  rL = rB - [-fWall2, 0];
  translate([-fSideIX, fGridY*b-fHornY, 0]) difference() {
    extrude(fGridZ) rect(rB);
    if (drawCuts) translate([-fWall2, 0, fBase]) eSliceY(fGridZ-fBase, rL, flushT=true, flushB=true, flushL=true, hFudge=fudge);
  }
}

module lHookFill() if (stretchXFill) {
  rB = [-fWall2-stretchX/2, hookW.x*2+fWall2*2+fSlopXY];
  rL = rB - [-fWall2, 0];
  translate([-fSideIX, fGridY/2, 0]) difference() {
    extrude(fGridZ) rect(rB, [1,0]);
    if (drawCuts) translate([-fWall2, 0, fBase]) eSliceY(fGridZ-fBase, rL, flushT=true, flushB=true, flushL=true, centerY=true, hFudge=fudge);
  }
}



///////////
// SIDES //
///////////


// BUMPS

module trimFBumps(size) rotate([-90,0,0]) flipX() translate([size.x/2, -fGridZ, 0]) extrude(size.y) polygon(
  [ [fudge, max(0, tIL            )]
  , [    0, max(0, tIL            )]
  , [ -tPH, max(0, tIL+tRL        )]
  , [ -tPH, max(0, tIL+tRL+tPL    )]
  , [    0, max(0, tIL+tRL+tPL+tLL)]
  , [fudge, max(0, tIL+tRL+tPL+tLL)]
  ]);

module trimMBumps(size) rotate([-90,0,0]) flipX() translate([size.x/2, tBase, 0]) extrude(size.y) polygon(
  [ [-fudge, max(0, tFloat+tIL-fSlopXY*tLS+tOL+tRL+tPL        )]
  , [     0, max(0, tFloat+tIL-fSlopXY*tLS+tOL+tRL+tPL        )]
  , [   tPH, max(0, tFloat+tIL-fSlopXY*tLS+tOL+tRL+tPL  +tLL  )]
  , [   tPH, max(0, tFloat+tIL-fSlopXY*tLS+tOL+tRL+tPL*2+tLL  )]
  , [     0, max(0, tFloat+tIL-fSlopXY*tLS+tOL+tRL+tPL*2+tLL*2)]
  , [-fudge, max(0, tFloat+tIL-fSlopXY*tLS+tOL+tRL+tPL*2+tLL*2)]
  ]);

module mirtFBumps(size) rotate([-90,0,0]) flipX() translate([size.x/2, -fGridZ, 0]) extrude(size.y) polygon(
  [ [fudge, max(0, tIL            )]
  , [    0, max(0, tIL            )]
  , [ -mPH, max(0, tIL+mRL        )]
  , [ -mPH, max(0, tIL+mRL+tPL    )]
  , [    0, max(0, tIL+mRL+tPL+mLL)]
  , [fudge, max(0, tIL+mRL+tPL+mLL)]
  ]);

module mirtMBumps(size) rotate([-90,0,0]) flipX() translate([size.x/2, tBase, 0]) extrude(size.y) polygon(
  [ [-fudge, max(0, tFloat+tIL-fSlopXY*tLS+tOL+mRL+tPL        )]
  , [     0, max(0, tFloat+tIL-fSlopXY*tLS+tOL+mRL+tPL        )]
  , [   mPH, max(0, tFloat+tIL-fSlopXY*tLS+tOL+mRL+tPL  +mLL  )]
  , [   mPH, max(0, tFloat+tIL-fSlopXY*tLS+tOL+mRL+tPL*2+mLL  )]
  , [     0, max(0, tFloat+tIL-fSlopXY*tLS+tOL+mRL+tPL*2+mLL*2)]
  , [-fudge, max(0, tFloat+tIL-fSlopXY*tLS+tOL+mRL+tPL*2+mLL*2)]
  ]);


// COMPONENTS

module tSideBase(l, r) for (i=[l:r]) translate([fGridX*i, 0, 0]) {
  bHooks();
  // between bottom bumps
  translate([0, -fHornY+tClearance+fWall4, fGridZ-tInsert-fTop]) {
    rB = [fSideOX*2-fSlopXY*4-claspW*2-hookW.y*2-fWall2*2, -fWall2-tClearance];
    rL = rB - [0, -fWall2];
    if (rB[0]>=fWall2) difference() {
      hull() {
        extrude(fTop) rect(rB, [0,1]);
        extrude(rL.y) rect([rB.x, -fWall2], [0,1]);
      }
      if (drawCuts) translate([0, -fWall2, rL.y]) eSliceX(fTop-rL.y, rL, flushB=true, flushL=true, flushR=true, centerX=true, hFudge=fudge);
    }
  }
  // over bottom bumps
  flipX() translate([fSideOX-claspW-hookW.y-fWall2-fSlopXY, -fHornY+tClearance+fWall4, fGridZ-tInsert-fTop]) {
    rB = [bPW, -fWall2-tClearance+max(bPH, hookM.y)];
    rL = rB - [fWall2, -fWall2];
    if (rB[0]>=fWall2) difference() {
      hull() {
        extrude(fTop) rect(rB);
        extrude(rL.y) rect([rB.x, -fWall2]);
      }
      if (drawCuts) translate([0, -fWall2, rL.y]) eSliceX(fTop-rL.y, rL, flushB=true, flushL=true, hFudge=fudge);
    }
  }
  // beside bottom bumps
  flipX() translate([fSideOX-claspW-hookW.y+bPW-fWall2, -fHornY+tClearance+fWall4, fGridZ-tInsert-fTop]) {
    rB = [fWall2*2+hookW.y-bPW, -fWall2-tClearance+hookM.y];
    rL = rB - [fWall2, -fWall2];
    if (rB[0]>=fWall2*2+gap) difference() {
      hull() {
        extrude(fTop) rect(rB);
        extrude(rL.y) rect([rB.x, -fWall2]);
      }
      if (drawCuts) translate([0, -fWall2, rL.y]) eSliceX(fTop-rL.y, rL, flushB=true, flushL=true, hFudge=fudge);
    }
  }
  if (trim) translate([0, -fHornY+tClearance+fWall4, 0]) trimFBumps([fSideOX*2-claspW*2, -fWall2-tClearance+hookM.y]);
  // seam
  if (i<r) translate([fGridX/2, -fHornY+tClearance+fWall4, 0]) {
    rB = [claspD.x+stretchX+fWall4*2+fSlopXY*2, -tClearance-fWall4];
    rL = rB - [fWall2*2, -fWall2];
    extrude(fBase) rect(rB, [0,1]);
    translate([0, 0, fGridZ-fTop]) difference() {
      hull() {
        extrude(fTop) rect(rB, [0,1]);
        extrude(rL.y) rect([rB.x, -fWall2], [0,1]);
      }
      if (drawCuts) translate([0, -fWall2, 0]) {
        eSliceX(rL.y, rL, centerX=true);
        eSliceX(fTop, [rL.x, rL.y+fWall2], centerX=true, cutAlt=true, hFudge=fudge);
        eSliceY(fTop, [rL.x, -fWall2], translate=[0, rL.y+fWall2], flushT=true, flushB=true, centerX=true, cutAlt=true, hFudge=fudge);
      }
    }
  }
}

module bSideBase(l, r) for (i=[l:r]) translate([fGridX*i, 0, 0]) {
  extrude(fBase) translate([0, fHornY-claspD.y+hookM.y]) rect([fSideOX*2-fWallGrid*4, claspD.y-hookM.y+fWallGrid+bPH-fSlopB], [0,1]);
  extrude(fGridZ) flipX() translate([fGridX/2-claspD.x/2-stretchX/2-fSlopXY, fGridY/2-fSlopXY/2]) rect([-fWall2, -claspD.y+hookM.y]);
  tHooks();
  if (i<r) bSeamFill();
  bFill(mInsert);
  if (trim) translate([0, fHornY-claspD.y+hookM.y, 0]) rotate(180) mirtFBumps([fSideOX*2-claspW*2-hookW.y*2-fSlopXY*2-fWall2*2, gap-stemD.y]);
}


// SIDES

module tSide(x=1, z=[0], color=true, trimColor=false) {
  assert(is_num(x) || is_list(x) && len(x)==2);
  assert(             is_list(z) && len(z)==1);
  l = is_list(x) ? min(x[0], x[1]) : -(abs(x)-1)/2;
  r = is_list(x) ? max(x[0], x[1]) :  (abs(x)-1)/2;
  y = z[0];
  if (l<=r) condColor(color) translate([0, fGridY*(y+1), 0]) {
    extrude(fBase) translate([fGridX*l-fBulgeOX, fBHookY+bPH]) rect([fGridX*(r-l)+fBulgeOX*2, tClearance-bPH+fWall2]);
    extrude(fSideZ) translate([fGridX*l-fBulgeOX, fBHookY+tClearance]) rect([fGridX*(r-l)+fBulgeOX*2, fWall2]);
    tlSeamFill(l);
    trSeamFill(r);
    tSideBase(l, r);
  }
  if (trim) condColor(trimColor) tTrim(x, z, print=false);
}

module bSide(x=1, z=[0], color=true, trimColor=false) {
  assert(is_num(x) || is_list(x) && len(x)==2);
  assert(             is_list(z) && len(z)==1);
  l = is_list(x) ? min(x[0], x[1]) : -(abs(x)-1)/2;
  r = is_list(x) ? max(x[0], x[1]) :  (abs(x)-1)/2;
  y = z[0];
  if (l<=r) condColor(color) translate([0, fGridY*(y-1), 0]) {
    if (fancy) extrude(fBase) translate([fGridX*l-fBulgeOX, fTHookY+hookM.y]) rect([fGridX*(r-l)+fBulgeOX*2, -fWall2-hookM.y]);
    else extrude(fBase) translate([fGridX*l-fBulgeOX, fTHookY-fWall2+claspD.y-hookM.y]) rect([fGridX*(r-l)+fBulgeOX*2, -claspD.y+hookM.y]);
    extrude(fSideZ) translate([fGridX*l-fBulgeOX, fTHookY]) rect([fGridX*(r-l)+fBulgeOX*2, -fWall2]);
    blSeamFill(l);
    brSeamFill(r);
    bSideBase(l, r);
  }
  if (trim) condColor(trimColor) bTrim(x, z, print=false);
}

module lSide(x=[0], z=1, color=true, trimColor=false) {
  assert(             is_list(x) && len(x)==1);
  assert(is_num(z) || is_list(z) && len(z)==2);
  t = is_list(z) ? max(z[0], z[1]) :  (abs(z)-1)/2;
  b = is_list(z) ? min(z[0], z[1]) : -(abs(z)-1)/2;
  if (t>=b) condColor(color) translate([fGridX*(x[0]-1), 0, 0]) {
    extrude(fBase) for (i=[b:t]) if (i>b) translate([fSideIX, fGridY*(i-0.5)]) rect([claspD.x-hookM.x+stretchX/2+fWallGrid, claspW*2+hookW.x*2-fWall2*2-fSlopXY], [1,0]);
    extrude(fBase) translate([fSideIX, fGridY*t]) translate([0,  fHornY]) rect([claspD.x-hookM.x+stretchX/2+fWallGrid, -claspW-hookW.x+fWallGrid]);
    extrude(fBase) translate([fSideIX, fGridY*b]) translate([0, -fHornY]) rect([claspD.x-hookM.x+stretchX/2+fWallGrid,  claspW+hookW.x-fWallGrid]);
    if (fancy) {
      extrude(fBase) translate([fSideIX, fGridY*b-fHornY]) rect([fWall2+hookM.x+stretchX/2, fGridY*(t-b)+fHornY*2]);
      extrude(fBase) for (i=[b:t]) translate([fBulgeOX, fGridY*i]) rect([-fBulgeWall-fWall2, fBulgeOY*2], [1,0]);
    }
    else extrude(fBase) translate([fBulgeOX, fGridY*b-fHornY]) rect([-fBulgeWall-fWall2, fGridY*(t-b)+fHornY*2]);
    extrude(fSideZ) translate([fSideOX, fGridY*b-fHornY]) rect([-fWall2, fGridY*(t-b)+fHornY*2]);
    for (i=[b:t]) translate([0, fGridY*i, 0]) {
      rHooks();
      rHookFill();
      translate([fSideIX, 0, 0]) {
        rB = [fBulgeWall+fWall2, fHornY*2-claspW*2-hookW.x*2-fSlopXY*2];
        rL = rB - [fWall2, fWall2*2];
        flipY() translate([0, rL.y/2, 0]) extrude(fGridZ) rect([rB.x, fWall2]);
        translate([0, 0, fGridZ-tInsert-fTop]) difference() {
          hull() {
            extrude(fTop) rect(rB, [1,0]);
            extrude(-rL.x) rect([fWall2, rB.y], [1,0]);
          }
          if (drawCuts) translate([fWall2, 0, 0]) {
            eSliceY(-rL.x, rL, centerY=true);
            eSliceY(fTop, rL-[fWall2, 0], centerY=true, cutAlt=true, hFudge=fudge);
            eSliceX(fTop, [fWall2, rL.y], translate=[rL.x-fWall2, 0], flushL=true, flushR=true, centerY=true, cutAlt=true, hFudge=fudge);
          }
        }
        if (trim) rotate(90) trimFBumps([rL.y, -rB.x]);
      }
    }
  }
  if (trim) condColor(trimColor) lTrim(x, z, print=false);
}

module rSide(x=[0], z=1, color=true, trimColor=false) {
  assert(             is_list(x) && len(x)==1);
  assert(is_num(z) || is_list(z) && len(z)==2);
  t = is_list(z) ? max(z[0], z[1]) :  (abs(z)-1)/2;
  b = is_list(z) ? min(z[0], z[1]) : -(abs(z)-1)/2;
  if (t>=b) condColor(color) translate([fGridX*(x[0]+1), 0, 0]) {
    extrude(fBase) translate([-fSideOX-hookM.x-stretchX/2, fGridY*b-fHornY]) rect([fWall2+hookM.x+stretchX/2, fGridY*(t-b)+fHornY*2]);
    extrude(fSideZ) translate([-fSideOX, fGridY*b-fHornY]) rect([fWall2, fGridY*(t-b)+fHornY*2]);
    ltHookFill(t);
    lbHookFill(b);
    for (i=[b:t]) translate([0, fGridY*i, 0]) {
      lHooks();
      if (i<t) lHookFill();
      translate([-fSideIX, 0, 0]) {
        rB = [-fBulgeWall-fWall2, fHornY*2-claspW*2-hookW.x*2+fWall2*2];
        rL = rB - [-fWall2, fWall2*2];
        extrude(fBase) rect(rB, [1,0]);
        translate([0, 0, fGridZ-tInsert-fTop]) difference() {
          hull() {
            extrude(fTop) rect(rB, [1,0]);
            extrude(rL.x) rect([-fWall2, rB.y], [1,0]);
          }
          if (drawCuts) translate([-fWall2, 0, 0]) {
            eSliceY(rL.x, rL, centerY=true);
            eSliceY(fTop, [rL.x+fWall2, rL.y], centerY=true, cutAlt=true, hFudge=fudge);
            eSliceX(fTop, [-fWall2, rL.y], translate=[rL.x+fWall2, 0], flushL=true, flushR=true, centerY=true, cutAlt=true, hFudge=fudge);
          }
        }
        if (trim) rotate(270) trimFBumps([rL.y, rB.x]);
      }
    }
  }
  if (trim) condColor(trimColor) rTrim(x, z, print=false);
}


// CORNER HELPERS

module cornerWall(r, offset, align, trim=false, wall=fWall2) translate([(fGridX-offset.x)*align.x, (fGridY-offset.y)*align.y]) difference() {
  circle(r=r, $fn=cornerFn);
  circle(r=r-min(r, wall), $fn=cornerFn);
  translate([0, -(r-wall)*align.y]) rect([(r+fudge)*align.x, (r*2-wall+fudge)*align.y]);
  translate([-(r-wall)*align.x, 0]) rect([(r*2-wall+fudge)*align.x, (r+fudge)*align.y]);
  if (is_list(trim) && len(trim)==2) {
    if (is_num(trim[0])) translate([trim[0]*align.x, 0]) rect([(r-trim[0]+fudge)*align.x, r*2+fudge2], [1,0]);
    if (is_num(trim[1])) translate([0, trim[1]*align.y]) rect([r*2+fudge2, (r-trim[1]+fudge)*align.y], [0,1]);
  }
}

// translate([0,0,100]) cornerWall(5, [1,0], [1,-1], trim=[1, -2]);

module cornerSquare(r, offset, align, wall=[fWall2, fWall2]) translate([(fGridX-offset.x)*align.x, (fGridY-offset.y)*align.y]) difference() {
  circle(r=r, $fn=cornerFn);
  translate([-(r-wall.x)*align.x, -(r-wall.y)*align.y]) rect([(r*2-wall.x+fudge)*align.x, (r*2-wall.y+fudge)*align.y]);
}

module cornerMask(r, offset, align) translate([(fGridX-offset.x)*align.x, (fGridY-offset.y)*align.y]) {
  circle(r=r, $fn=cornerFn);
  translate([0, -align.y*r]) rect([(fGridX/2+offset.x)*align.x, (fGridY/2+offset.y+r)*align.y]);
  translate([-align.x*r, 0]) rect([(fGridX/2+offset.x+r)*align.x, (fGridY/2+offset.y)*align.y]);
}


// CORNERS

module tlSide(x=1, z=[0], color=true, trimColor=false) {
  assert(is_num(x) || is_list(x) && len(x)==2);
  assert(             is_list(z) && len(z)==1);
  l = is_list(x) ? min(x[0], x[1]) : -(abs(x)-1)/2;
  r = is_list(x) ? max(x[0], x[1]) :  (abs(x)-1)/2;
  y = z[0];
  if (l<=r) condColor(color) {
    tPHAdj = trim ? 0 : fWallGrid;
    fillet = fWall2 + tClearance + tPHAdj;
    rise = claspD.y - hookM.y - fWall2 + fSlopXY - tPHAdj;
    edge = fSideOX + claspD.x + stretchX - tClearance + fSlopXY*2 - tPHAdj;
    align = [1, -1];
    translate([fGridX*(l-1), fGridY*(y+1), 0]) {
      tSideBase(1, r-l+1);
      extrude(fBase) translate([fGridX-edge, fBHookY+bPH]) rect([fGridX*(r-l)+fBulgeOX+edge, tClearance-bPH+fWall2]);
      extrude(fSideZ) {
        translate([fGridX-edge, fBHookY+tClearance]) rect([fGridX*(r-l)+fBulgeOX+edge, fWall2]);
        cornerWall(fillet, [edge, fHornY+fWallGrid+fSlopXY-tPHAdj], align, trim=[false, rise-claspD.y+hookM.y+fWall2*2]);
        if (trim) translate([fGridX-edge-fillet, fBHookY]) rect([fWall2, -rise+claspD.y-hookM.y-fWall2*2]);
      }
      trSeamFill(r-l+1);
      rB = [claspD.x+stretchX+fWallGrid*3, -rise-fillet+claspD.y-hookM.y-fWall2*2];
      rL = rB - [fWall2*2, -fWall2];
      tx = fGridX - edge - fillet;
      ty = -fGridY + fHornY + fWallGrid + fillet + fSlopXY - tPHAdj;
      // #translate([tx, ty]) extrude(fGridZ+1) rect(rB);
      // #translate([tx+fWall2, ty-fWall2]) extrude(fGridZ+2) rect(rL);
      extrude(fBase) intersection() {
        translate([tx, ty]) rect(rB);
        cornerMask(fillet, [edge, fHornY+fWallGrid+fSlopXY-tPHAdj], align);
      }
      translate([0, 0, fGridZ-fTop]) difference() {
        intersection() {
          translate([tx, ty, 0]) hull() {
            extrude(fTop) rect(rB);
            extrude(rL.y) rect([rB.x, -fWall2]);
          }
          extrude((rL.y-fTop)*2, center=true) cornerMask(fillet, [edge, fHornY+fWallGrid+fSlopXY-tPHAdj], align);
        }
        if (drawCuts) {
          eSliceX(rL.y, rL, translate=[tx+fWall2, ty-fWall2]);
          eSliceX(fTop, [rL.x, rL.y+fWall2], translate=[tx+fWall2, ty-fWall2], cutAlt=true, hFudge=fudge)
            offset(delta=-fWall2) cornerMask(fillet, [edge, fHornY+fWallGrid+fSlopXY-tPHAdj], align);
          eSliceY(fTop, [rL.x, -fWall2], translate=[tx+fWall2, ty+rL.y], flushT=true, flushB=true, cutAlt=1, hFudge=fudge)
            offset(delta=-fWall2) cornerMask(fillet, [edge, fHornY+fWallGrid+fSlopXY-tPHAdj], align);
        }
      }
    }
  }
  if (trim) condColor(trimColor) tlTrim(x, [z[0], z[0]], print=false);
}

module trSide(x=1, z=[0], color=true, trimColor=false) {
  assert(is_num(x) || is_list(x) && len(x)==2);
  assert(             is_list(z) && len(z)==1);
  l = is_list(x) ? min(x[0], x[1]) : -(abs(x)-1)/2;
  r = is_list(x) ? max(x[0], x[1]) :  (abs(x)-1)/2;
  y = z[0];
  if (l<=r) condColor(color) {
    tPHAdj = trim ? 0 : fWallGrid;
    fillet = fWall2 + tClearance + tPHAdj;
    rise = claspD.y - hookM.y - fWall2 + fSlopXY - tPHAdj;
    edge = fSideOX + claspD.x + stretchX - tClearance + fSlopXY*2 - tPHAdj;
    align = [-1, -1];
    translate([fGridX*(r+1), fGridY*(y+1), 0]) {
      tSideBase(l-r-1, -1);
      extrude(fBase) translate([edge-fGridX, fBHookY+bPH]) rect([fGridX*(l-r)-fBulgeOX-edge, tClearance-bPH+fWall2]);
      extrude(fSideZ) {
        translate([edge-fGridX, fBHookY+tClearance]) rect([fGridX*(l-r)-fBulgeOX-edge, fWall2]);
        cornerWall(fillet, [edge, fHornY+fWallGrid+fSlopXY-tPHAdj], align, trim=[false, rise-claspD.y+hookM.y+fWall2*2]);
        if (trim) translate([edge-fGridX+fillet, fBHookY]) rect([-fWall2, -rise+claspD.y-hookM.y-fWall2*2]);
      }
      tlSeamFill(l-r-1);
      rB = [-claspD.x-stretchX-fWallGrid*3, -rise-fillet+claspD.y-hookM.y-fWall2*2];
      rL = rB - [-fWall2*2, -fWall2];
      tx = -fGridX + edge + fillet;
      ty = -fGridY + fHornY + fWallGrid + fillet + fSlopXY - tPHAdj;
      // #translate([tx, ty]) extrude(fGridZ+1) rect(rB);
      // #translate([tx-fWall2, ty-fWall2]) extrude(fGridZ+2) rect(rL);
      extrude(fBase) intersection() {
        translate([tx, ty]) rect(rB);
        cornerMask(fillet, [edge, fHornY+fWallGrid+fSlopXY-tPHAdj], align);
      }
      translate([0, 0, fGridZ-fTop]) difference() {
        intersection() {
          translate([tx, ty, 0]) hull() {
            extrude(fTop) rect(rB);
            extrude(rL.y) rect([rB.x, -fWall2]);
          }
          extrude((rL.y-fTop)*2, center=true) cornerMask(fillet, [edge, fHornY+fWallGrid+fSlopXY-tPHAdj], align);
        }
        if (drawCuts) {
          eSliceX(rL.y, rL, translate=[tx-fWall2, ty-fWall2]);
          eSliceX(fTop, [rL.x, rL.y+fWall2], translate=[tx-fWall2, ty-fWall2], cutAlt=true, hFudge=fudge)
            offset(delta=-fWall2) cornerMask(fillet, [edge, fHornY+fWallGrid+fSlopXY-tPHAdj], align);
          eSliceY(fTop, [rL.x, -fWall2], translate=[tx-fWall2, ty+rL.y], flushT=true, flushB=true, cutAlt=1, hFudge=fudge)
            offset(delta=-fWall2) cornerMask(fillet, [edge, fHornY+fWallGrid+fSlopXY-tPHAdj], align);
        }
      }
    }
  }
  if (trim) condColor(trimColor) trTrim(x, [z[0], z[0]], print=false);
}

module blSide(x=1, z=[0], color=true, trimColor=false) {
  assert(is_num(x) || is_list(x) && len(x)==2);
  assert(             is_list(z) && len(z)==1);
  l = is_list(x) ? min(x[0], x[1]) : -(abs(x)-1)/2;
  r = is_list(x) ? max(x[0], x[1]) :  (abs(x)-1)/2;
  y = z[0];
  if (l<=r) condColor(color) {
    fillet = claspD.y - hookM.y;
    edge = fGridX/2 + claspD.x/2 + stretchX/2 - fillet + fWallGrid;
    align = [1, 1];
    translate([fGridX*(l-1), fGridY*(y-1), 0]) {
      bSideBase(1, r-l+1);
      if (fancy) extrude(fBase) translate([fGridX-edge, fTHookY+hookM.y]) rect([fGridX*(r-l)+fBulgeOX+edge, -fWall2-hookM.y]);
      else extrude(fBase) translate([fGridX-edge, fTHookY-fWall2+claspD.y-hookM.y]) rect([fGridX*(r-l)+fBulgeOX+edge, -claspD.y+hookM.y]);
      extrude(fSideZ) {
        translate([fGridX-edge, fTHookY]) rect([fGridX*(r-l)+fBulgeOX+edge, -fWall2]);
        cornerWall(fillet, [edge, fHornY+fSlopXY], align, trim=[false, 0]);
      }
      brSeamFill(r-l+1);
      rB = [claspD.x+fWallGrid*2+stretchX, fillet];
      rL = rB - [fWall2*2, fWall2];
      tx = fGridX - edge - fillet;
      ty = fGridY - fHornY - fillet - fSlopXY;
      // #translate([tx, ty]) extrude(fGridZ+1) rect(rB);
      // #translate([tx+fWall2, ty+fWall2]) extrude(fGridZ+2) rect(rL);
      extrude(fBase) intersection() {
        translate([tx, ty]) rect(rB);
        cornerMask(fillet, [edge, fHornY+fSlopXY], align);
      }
      translate([0, 0, fGridZ-fTop]) difference() {
        intersection() {
          translate([tx, ty, 0]) hull() {
            extrude(fTop) rect(rB);
            extrude(-rL.y) rect([rB.x, fWall2]);
          }
          extrude((rL.y+fTop)*2, center=true) cornerMask(fillet, [edge, fHornY+fSlopXY], align);
        }
        if (drawCuts) {
          eSliceX(-rL.y, rL, translate=[tx+fWall2, ty+fWall2]);
          eSliceY(fTop, rL, translate=[tx+fWall2, ty+fWall2], flushT=true, cutAlt=true, hFudge=fudge)
            offset(delta=-fWall2) cornerMask(fillet, [edge, fHornY+fSlopXY], align);
        }
      }
    }
  }
  if (trim) condColor(trimColor) blTrim(x, [z[0], z[0]], print=false);
}

module brSide(x=1, z=[0], color=true, trimColor=false) {
  assert(is_num(x) || is_list(x) && len(x)==2);
  assert(             is_list(z) && len(z)==1);
  l = is_list(x) ? min(x[0], x[1]) : -(abs(x)-1)/2;
  r = is_list(x) ? max(x[0], x[1]) :  (abs(x)-1)/2;
  y = z[0];
  if (l<=r) condColor(color) {
    fillet = claspD.y - hookM.y;
    edge = fGridX/2 + claspD.x/2 + stretchX/2 - fillet + fWallGrid;
    align = [-1, 1];
    translate([fGridX*(r+1), fGridY*(y-1), 0]) {
      bSideBase(l-r-1, -1);
      if (fancy) extrude(fBase) translate([edge-fGridX, fTHookY+hookM.y]) rect([fGridX*(l-r)-fBulgeOX-edge, -fWall2-hookM.y]);
      else extrude(fBase) translate([edge-fGridX, fTHookY-fWall2+claspD.y-hookM.y]) rect([fGridX*(l-r)-fBulgeOX-edge, -claspD.y+hookM.y]);
      extrude(fSideZ) {
        translate([edge-fGridX, fTHookY]) rect([fGridX*(l-r)-fBulgeOX-edge, -fWall2]);
        cornerWall(fillet, [edge, fHornY+fSlopXY], align, trim=[false, 0]);
      }
      blSeamFill(l-r-1);
      rB = [-claspD.x-fWallGrid*2-stretchX, fillet];
      rL = rB - [-fWall2*2, fWall2];
      tx = -fGridX + edge + fillet;
      ty = fGridY - fHornY - fillet - fSlopXY;
      // #translate([tx, ty]) extrude(fGridZ+1) rect(rB);
      // #translate([tx-fWall2, ty+fWall2]) extrude(fGridZ+2) rect(rL);
      extrude(fBase) intersection() {
        translate([tx, ty]) rect(rB);
        cornerMask(fillet, [edge, fHornY+fSlopXY], align);
      }
      translate([0, 0, fGridZ-fTop]) difference() {
        intersection() {
          translate([tx, ty, 0]) hull() {
            extrude(fTop) rect(rB);
            extrude(-rL.y) rect([rB.x, fWall2]);
          }
          extrude((rL.y+fTop)*2, center=true) cornerMask(fillet, [edge, fHornY+fSlopXY], align);
        }
        if (drawCuts) {
          eSliceX(-rL.y, rL, translate=[tx-fWall2, ty+fWall2]);
          eSliceY(fTop, rL, translate=[tx-fWall2, ty+fWall2], flushT=true, cutAlt=true, hFudge=fudge)
            offset(delta=-fWall2) cornerMask(fillet, [edge, fHornY+fSlopXY], align);
        }
      }
    }
  }
  if (trim) condColor(trimColor) brTrim(x, [z[0], z[0]], print=false);
}


// TRIM

module tTrimBase(l, r) for (i=[l:r]) translate([fGridX*i, -fHornY+fWall2+tClearance, 0]) {
  w = hookW.y-bPW+fWall2-tPH-fSlopXY;
  hl(w<fWall2, "Inadequate space for top trim clip.") {
    extrude(-tBase-tInsert) {
      flipX() translate([fSideOX-claspW-hookW.y+bPW-fWall2, 0, 0]) rect([w, -tClearance+fSlopXY]);
      rect([fSideOX*2-claspW*2-tPH*2-fSlopXY*2, -tClearance+bPH+fSlopXY], [0,1]);
    }
    trimMBumps([fSideOX*2-claspW*2-tPH*2-fSlopXY*2, -tClearance+fSlopXY]);
  }
}

module bTrimBase(l, r) for (i=[l:r]) translate([fGridX*i, fHornY-claspD.y+hookM.y+fWallGrid, 0]) {
  w = fSideIX*2-claspW*2-hookW.y*2-mPH*2-fSlopXY*4;
  hl(w<fWall2, "Inadequate space for bottom trim clip.") {
    extrude((-tBase-mInsert)*(w<fWall2?2:1), center=w<fWall2?true:false) rect([w, stemD.y-fWall2-fSlopXY*2], [0,1]);
    rotate(180) mirtMBumps([w, -stemD.y+fWall2+fSlopXY*2]);
  }
}

module tTrim(x=1, z=[0], print=true) {
  assert(is_num(x) || is_list(x) && len(x)==2);
  assert(             is_list(z) && len(z)==1);
  l = is_list(x) ? min(x[0], x[1]) : -(abs(x)-1)/2;
  r = is_list(x) ? max(x[0], x[1]) :  (abs(x)-1)/2;
  y = z[0];
  if (l<=r) hl(!trim, "Trim is disabled.") rotate([0, print?180:0, 0]) translate([0, fGridY*(y+1), print?0:fGridZ+tBase+tFloat]) {
    extrude(-tBase) translate([fGridX*l-fBulgeOX, fBHookY]) rect([fGridX*(r-l)+fBulgeOX*2, tClearance-fSlopXY]);
    tTrimBase(l, r);
  }
}

module bTrim(x=1, z=[0], print=true) {
  assert(is_num(x) || is_list(x) && len(x)==2);
  assert(             is_list(z) && len(z)==1);
  l = is_list(x) ? min(x[0], x[1]) : -(abs(x)-1)/2;
  r = is_list(x) ? max(x[0], x[1]) :  (abs(x)-1)/2;
  y = z[0];
  if (l<=r) hl(!trim, "Trim is disabled.") rotate([0, print?180:0, 0]) translate([0, fGridY*(y-1), print?0:fGridZ+tBase+tFloat]) {
    extrude(-tBase) translate([fGridX*l-fBulgeOX, fTHookY+fSlopXY]) rect([fGridX*(r-l)+fBulgeOX*2, claspD.y-hookM.y]);
    bTrimBase(l, r);
  }
}

module lTrim(x=[0], z=1, print=true) {
  assert(             is_list(x) && len(x)==1);
  assert(is_num(z) || is_list(z) && len(z)==2);
  t = is_list(z) ? max(z[0], z[1]) :  (abs(z)-1)/2;
  b = is_list(z) ? min(z[0], z[1]) : -(abs(z)-1)/2;
  if (t>=b) hl(!trim, "Trim is disabled.") rotate([0, print?180:0, 0])
    translate([fGridX*(x[0]-1)+fSideIX+fWallGrid, 0, print?0:fGridZ+tBase+tFloat]) {
      extrude(-tBase) translate([0, fGridY*b-fHornY]) rect([fBulgeWall-fSlopXY, fGridY*(t-b)+fHornY*2]);
      for (i=[b:t]) translate([0, fGridY*i, 0]) {
        extrude(-tBase-tInsert) rect([fBulgeWall-fSlopXY, fBulgeOY*2-fWallGrid*2-tPH*2], [1,0]);
        rotate(90) trimMBumps([fBulgeOY*2-fWallGrid*2-tPH*2, fSlopXY-fBulgeWall]);
      }
    }
}

module rTrim(x=[0], z=1, print=true) {
  assert(             is_list(x) && len(x)==1);
  assert(is_num(z) || is_list(z) && len(z)==2);
  t = is_list(z) ? max(z[0], z[1]) :  (abs(z)-1)/2;
  b = is_list(z) ? min(z[0], z[1]) : -(abs(z)-1)/2;
  if (t>=b) hl(!trim, "Trim is disabled.") rotate([0, print?180:0, 0])
    translate([fGridX*(x[0]+1)-fSideIX-fWallGrid, 0, print?0:fGridZ+tBase+tFloat]) {
      extrude(-tBase) translate([0, fGridY*b-fHornY]) rect([fSlopXY-fBulgeWall, fGridY*(t-b)+fHornY*2]);
      for (i=[b:t]) translate([0, fGridY*i, 0]) {
        extrude(-tBase-tInsert) rect([fSlopXY-fBulgeWall, fHornY*2-claspW*2-hookW.x*2-tPH*2-fSlopXY*2], [1,0]);
        rotate(270) trimMBumps([fHornY*2-claspW*2-hookW.x*2-tPH*2-fSlopXY*2, fSlopXY-fBulgeWall]);
      }
    }
}

module tlTrim(x=1, z=1, print=true) {
  assert(is_num(x) || is_list(x) && len(x)==2);
  assert(is_num(z) || is_list(z) && len(z)==2);
  t = is_list(z) ? max(z[0], z[1]) :  (abs(z)-1)/2;
  b = is_list(z) ? min(z[0], z[1]) : -(abs(z)-1)/2;
  l = is_list(x) ? min(x[0], x[1]) : -(abs(x)-1)/2;
  r = is_list(x) ? max(x[0], x[1]) :  (abs(x)-1)/2;
  if (t>=b && l<=r) hl(!trim, "Trim is disabled.") {
    fillet = tClearance - fSlopXY;
    rise = fWallGrid + fSlopXY;
    edge = fSideOX + claspD.x + stretchX - tClearance + fSlopXY*2;
    lTrim([l], z, print);
    rotate([0, print?180:0, 0]) translate([fGridX*(l-1), fGridY*(t+1), print?0:fGridZ+tBase+tFloat]) {
      tTrimBase(1, r-l+1);
      extrude(-tBase) {
        translate([fGridX-edge, fBHookY]) rect([fGridX*(r-l)+fBulgeOX+edge, tClearance-fSlopXY]);
        cornerSquare(fillet, [edge, fHornY+rise], [1, -1], [fBulgeWall-fSlopXY, tClearance-fSlopXY]);
        translate([fGridX-edge-fillet, fBHookY]) rect([fBulgeWall-fSlopXY, -rise-fudge]);
      }
    }
  }
}

module trTrim(x=1, z=1, print=true) {
  assert(is_num(x) || is_list(x) && len(x)==2);
  assert(is_num(z) || is_list(z) && len(z)==2);
  t = is_list(z) ? max(z[0], z[1]) :  (abs(z)-1)/2;
  b = is_list(z) ? min(z[0], z[1]) : -(abs(z)-1)/2;
  l = is_list(x) ? min(x[0], x[1]) : -(abs(x)-1)/2;
  r = is_list(x) ? max(x[0], x[1]) :  (abs(x)-1)/2;
  if (t>=b && l<=r) hl(!trim, "Trim is disabled.") {
    fillet = tClearance - fSlopXY;
    rise = fWallGrid + fSlopXY;
    edge = fSideOX + claspD.x + stretchX - tClearance + fSlopXY*2;
    rTrim([r], z, print);
    rotate([0, print?180:0, 0]) translate([fGridX*(r+1), fGridY*(t+1), print?0:fGridZ+tBase+tFloat]) {
      tTrimBase(l-r-1, -1);
      extrude(-tBase) {
        translate([edge-fGridX, fBHookY]) rect([fGridX*(l-r)-fBulgeOX-edge, tClearance-fSlopXY]);
        cornerSquare(fillet, [edge, fHornY+rise], [-1, -1], [fBulgeWall-fSlopXY, tClearance-fSlopXY]);
        translate([edge-fGridX+fillet, fBHookY]) rect([fSlopXY-fBulgeWall, -rise-fudge]);
      }
    }
  }
}

module blTrim(x=1, z=1, print=true) {
  assert(is_num(x) || is_list(x) && len(x)==2);
  assert(is_num(z) || is_list(z) && len(z)==2);
  t = is_list(z) ? max(z[0], z[1]) :  (abs(z)-1)/2;
  b = is_list(z) ? min(z[0], z[1]) : -(abs(z)-1)/2;
  l = is_list(x) ? min(x[0], x[1]) : -(abs(x)-1)/2;
  r = is_list(x) ? max(x[0], x[1]) :  (abs(x)-1)/2;
  if (t>=b && l<=r) hl(!trim, "Trim is disabled.") {
    fillet = claspD.y - hookM.y - fWallGrid;
    edge = fGridX/2 + claspD.x/2 + stretchX/2 - fillet;
    lTrim([l], z, print);
    rotate([0, print?180:0, 0]) translate([fGridX*(l-1), fGridY*(b-1), print?0:fGridZ+tBase+tFloat]) {
      bTrimBase(1, r-l+1);
      extrude(-tBase) {
        translate([fGridX-edge, fTHookY+fSlopXY]) rect([fGridX*(r-l)+fBulgeOX+edge, claspD.y-hookM.y]);
        if (claspD.y-hookM.y-fillet>0) translate([fGridX-edge-fillet, fTHookY+fSlopXY+fillet])
          rect([fGridX*(r-l)+fBulgeOX+edge+fillet, claspD.y-hookM.y-fillet]);
        cornerSquare(fillet, [edge, fHornY+fSlopXY], [1, 1], [fBulgeWall-fSlopXY, claspD.y-hookM.y]);
      }
    }
  }
}

module brTrim(x=1, z=1, print=true) {
  assert(is_num(x) || is_list(x) && len(x)==2);
  assert(is_num(z) || is_list(z) && len(z)==2);
  t = is_list(z) ? max(z[0], z[1]) :  (abs(z)-1)/2;
  b = is_list(z) ? min(z[0], z[1]) : -(abs(z)-1)/2;
  l = is_list(x) ? min(x[0], x[1]) : -(abs(x)-1)/2;
  r = is_list(x) ? max(x[0], x[1]) :  (abs(x)-1)/2;
  if (t>=b && l<=r) hl(!trim, "Trim is disabled.") {
    fillet = claspD.y - hookM.y - fWallGrid;
    edge = fGridX/2 + claspD.x/2 + stretchX/2 - fillet;
    rTrim([r], z, print);
    rotate([0, print?180:0, 0]) translate([fGridX*(r+1), fGridY*(b-1), print?0:fGridZ+tBase+tFloat]) {
      bTrimBase(l-r-1, -1);
      extrude(-tBase) {
        translate([edge-fGridX, fTHookY+fSlopXY]) rect([fGridX*(l-r)-fBulgeOX-edge, claspD.y-hookM.y]);
        if (claspD.y-hookM.y-fillet>0) translate([edge-fGridX+fillet, fTHookY+fSlopXY+fillet])
          rect([fGridX*(l-r)-fBulgeOX-edge-fillet, claspD.y-hookM.y-fillet]);
        cornerSquare(fillet, [edge, fHornY+fSlopXY], [-1, 1], [fBulgeWall-fSlopXY, claspD.y-hookM.y]);
      }
    }
  }
}



///////////
// FRAME //
///////////


module frame(x=1, z=1, hookInserts=false, drawer=false, divisions=false, drawFace=true, drawTop=true, drawFloor=true, drawSides=true) {
  assert(is_num(x) || is_list(x) && len(x)==2);
  assert(is_num(z) || is_list(z) && len(z)==2);
  t = is_list(z) ? max(z[0], z[1]) :  (abs(z)-1)/2;
  b = is_list(z) ? min(z[0], z[1]) : -(abs(z)-1)/2;
  l = is_list(x) ? min(x[0], x[1]) : -(abs(x)-1)/2;
  r = is_list(x) ? max(x[0], x[1]) :  (abs(x)-1)/2;
  stopZIdeal = fGridY*(t-b+1) - claspW - hookW.x - fWallGrid*2 - dSlopZ*2;
  stopZError = dFloorZ(stopZIdeal) - stopZIdeal;
  drawerZIdeal = fGridY*(t-b) + drawerZ;
  drawerZError = dFloorZ(drawerZIdeal) - drawerZIdeal;

  module rBulge(top=false) translate([fBulgeOX, 0, 0]) {
    extrude(fGridZ) {
      translate([0, fBulgeOY]) rect([-fBulgeWall-fWall2, (top?stopZError:0)-fWall2]);
      translate([0, -fBulgeOY]) rect([-fBulgeWall-fWall2, fWall2]);
      if (drawSides) rect([-fWall2, fBulgeOY*2], [1,0]);
    }
  }

  module lBulge(top=false) scale([-1,1,1]) rBulge(top=top);

  module tFrame(l=0, r=0) {
    for (i=[l:r]) translate([fGridX*i, 0, 0]) {
      tHooks(drawHooks=drawTop);
      if (i>l) translate([-fGridX/2, 0, 0]) extrude(fGridZ) flipX()
        translate([-claspD.x/2-stretchX/2-fSlopXY, fTopIY]) rect([-fWall2, fHornY-fTopIY]);
      if (drawTop) bFill();
      // hook supports
      flipX() translate([fSideIX-fSlopXY, fTopIY, 0]) box([-fWall2, fWall2+hookM.y, fGridZ]);
    }
    if (drawTop) extrude(fGridZ) translate([fGridX*r+fSideOX, fTHookY]) rect([fGridX*(l-r)-fSideOX*2, -fWall2]);
    for (i=[l:r]) if (i<r) translate([fGridX*i, 0, 0]) bSeamFill();
  }

  module bFrame(l=0, r=0) {
    translate([fGridX*l, 0, 0]) blHook();
    translate([fGridX*r, 0, 0]) brHook();
    extrude(fGridZ) {
      translate([fGridX*r+fSideOX, -fHornY]) rect([-fWall4, fWall2]);
      translate([fGridX*l-fSideOX, -fHornY]) rect([ fWall4, fWall2]);
    }
  }

  module lFrame(b=0, t=0) {
    for (i=[b:t]) translate([0, fGridY*i, 0]) {
      lBulge(top=i==t);
      if (drawSides) {
        lHooks();
        if (i<t) {
          lHookFill();
          extrude(fGridZ) translate([-fSideOX, fBulgeIY]) rect([fWall2, fGridY-fBulgeIY*2]);
        }
      }
    }
    if (drawSides) {
      ltHookFill(t);
      lbHookFill(b);
      translate([-fSideOX, fGridY*t+fBulgeIY, 0]) hull() {
        box([fWall2, fHornY-fBulgeIY-hornC, fGridZ      ]);
        box([fWall2, fHornY-fBulgeIY      , fGridZ-hornC]);
      }
      extrude(fGridZ) translate([-fSideOX, fGridY*b-fBulgeIY]) rect([fWall2, fBulgeIY-fHornY]);
    }
  }

  module rFrame(b=0, t=0) {
    for (i=[b:t]) translate([0, fGridY*i, 0]) {
      rBulge(top=i==t);
      if (drawSides) {
        rHooks();
        rHookFill();
        if (i<t) extrude(fGridZ) translate([fSideOX, fBulgeIY]) rect([fWall2, fGridY-fBulgeIY*2], [-1,1]);
      }
    }
    if (drawSides) extrude(fGridZ) {
      translate([fSideOX, fGridY*t+fBulgeIY]) rect([-fWall2, fHornY-fBulgeIY]);
      translate([fSideOX, fGridY*b-fBulgeIY]) rect([-fWall2, fBulgeIY-fHornY]);
    }
  }

  module keyholes(head=false)
    if (keyholes && t-b>0) for (i=[l:r]) for (j=[b:t-1]) translate([fGridX*i, fGridY*(j+0.5)]) rotate(keyholeA)
      if (head) circle(keyHeadR, $fn=keyholeFn);
      else {
        rotate(180/keyholeFn) circle(keyShaftR, $fn=keyholeFn);
        rect([keyholeW, -keyholeL], [0,1]);
        translate([0, -keyholeL, 0]) teardrop_2d(keyOpeningR, a=keyOpeningB, truncate=keyholeL, $fn=keyholeFn);
      }

  if (t>=b && l<=r) {
    translate([0, fGridY*t, 0]) tFrame(l, r);
    translate([0, fGridY*b, 0]) bFrame(l, r);
    translate([fGridX*l, 0, 0]) lFrame(b, t);
    translate([fGridX*r, 0, 0]) rFrame(b, t);

    translate([fGridX*(r+l)/2, 0, 0]) flipX() {
      stopLines = t-b==0 ? fStopLines0 : fStopLinesN;
      stopTop = drawerY + gap - dFloat - dTravel - dWall2*sqrt(2)/2 + dSlopXY - (dWall2+gap)*sqrt(2)*(dStopLines-1);
      stopHIdeal = (fWall2 + gap)*stopLines;
      stopH = stopHIdeal - stopZError;
      railW = (railWN - ((t-b)==0 ? stopH : 0) + railD*2 - dSlop45*2) / (drawSides ? 1 : 2);
      peakW = (peakWN - ((t-b)==0 ? stopH : 0)) / (drawSides ? 1 : 2);
      railZ = fGridY*b - ((t-b)==0 ? stopH/2 : 0);

      // drawer rail bumps
      hl(peakW<0, "Inadequate space for frame side bumps.") translate([fGridX*(r-l)/2+fBulgeIX, railZ, 0]) {
        // cushion
        hull() {
          box([fWall2, -railW, cInset+cBL+cPL], [1,drawSides?0:1,1]);
          box([-cCH, -peakW, cInset+cBL+cPL], [1,drawSides?0:1,1]);
        }
        // catch, in back, holds drawer shut
        hull() {
          translate([0, 0, cInset]) box([fWall2, -railW, cBL+cPL+cFL], [1,drawSides?0:1,1]);
          translate([0, 0, cInset+cBL]) box([-cPH, -peakW, cPL], [1,drawSides?0:1,1]);
        }
        // hold, in front, holds drawer open
        hull() {
          translate([0, 0, fGridZ-hInset]) box([fWall2, -railW, -hFL-hPL-hBL], [1,drawSides?0:1,1]);
          translate([0, 0, fGridZ-hInset-hFL]) box([-hPH, -peakW, -hPL], [1,drawSides?0:1,1]);
        }
        // keep, in front, holds drawer in
        hull() {
          translate([0, 0, fGridZ-kInset]) box([fWall2, -railW, -kFL-kPL-kBL], [1,drawSides?0:1,1]);
          translate([0, 0, fGridZ-kInset-kFL]) box([-kPH, -railW+kPH*(drawSides?2:1), -kPL], [1,drawSides?0:1,1]);
        }
      }
      // drawer stops
      if (stopLines>0) hl(stopTop<0, "Inadequate space for frame stops.")
        translate([fGridX*(r-l)/2+fBulgeIX, fGridY*t+fBulgeIY+stopZError, fGridZ]) {
          difference() {
            for (i=[0:stopLines-1]) translate([fWall2, -fWall2*i-gap*(i+1), 0]) {
              hull() {
                box([-fBulgeWall-fWall2, -fWall2, -stopTop], [1,1,1]);
                box([-fWall2, -fWall2, -stopTop-fBulgeWall], [1,1,1]);
              }
            }
            if (stopTop>=fLayerHN && drawCuts) for (i=[0:2:fFloorH(stopTop)/fLayerHN-1])
              translate([0, 0, -i*fLayerHN+(i==0?fudge:0)])
                box([-fBulgeWall/2+fWall2/2, -(fWall2+gap)*stopLines-fudge, -fLayerHN-(i==0?fudge:0)]);
          }
          if (stopTop>=fLayerHN) for (i=[0:2:fFloorH(stopTop)/fLayerHN-1])
            translate([-fBulgeWall/2+fWall2/2, fWall2-stopZError, -i*fLayerHN])
              box([-fBulgeWall/2-fWall2/2, -(fWall2+gap)*stopLines-fWall2+stopZError, -fLayerHN]);
        }
      // drawerZError compensation
      if (fDrawerLayerCompLines>=1) for (i=[1:fDrawerLayerCompLines])
        translate([fGridX*(r-l)/2+fSideOX-fWall2*i-gap*i, fGridY*t+fTopOY, 0]) box([-fWall2, -fWall2+drawerZError, fGridZ]);
    }

    if (drawFloor) difference() {
      if (fancy) extrude(fBase, convexity=2) {
        translate([fGridX*r+fSideOX+hookM.x+stretchX/2, fGridY*t+fTopOY+hookM.y]) rect([fGridX*(l-r)-fSideOX*2-hookM.x*2-stretchX, fGridY*(b-t-1)+claspD.y-hookM.y*2+fSlopXY*2+bPH]);
        // upper left  (not sure this is needed for anything other than latch backstops, but not even that??)
        // #translate([fGridX*l-fSideOX-hookM.x, fGridY*t+fHornY]) rect([fWall2+hookM.x, -fWall4-hookM.y-hookG.y]);
        // lower corners
        translate([fGridX*l-fSideOX-hookM.x-stretchX/2, fGridY*b-fHornY]) rect([ fWall4+hookM.x+stretchX/2, fWall4+bPH]);
        translate([fGridX*r+fSideOX+hookM.x+stretchX/2, fGridY*b-fHornY]) rect([-fWall4-hookM.x-stretchX/2, fWall4+bPH]);
        // right seam
        for (i=[b:t]) if (i>b) translate([fGridX*(r+0.5)+claspD.x/2-hookM.x, fGridY*(i-0.5)]) rect([-claspD.x+hookM.x-stretchX/2-fWallGrid, -fWall4], [1,0]);
        // upper right hook
        for (i=[b:t]) translate([fGridX*r+fSideIX, fGridY*i+fHornY]) rect([claspD.x-hookM.x+stretchX/2+fWallGrid, -claspW-hookW.x+fWallGrid]);
        // lower right hook
        for (i=[b:t]) translate([fGridX*r+fSideIX-fWallGrid, fGridY*i-fHornY]) rect([claspD.x-hookM.x+stretchX/2+fWallGrid*2, claspW+hookW.x-fWallGrid]);
        // left bulge
        for (i=[b:t]) translate([fGridX*l-fBulgeOX, fGridY*i]) rect([fBulgeWall+fWall2, fBulgeOY*2+fWallGrid*2], [1,0]);
        // right bulge
        for (i=[b:t]) translate([fGridX*r+fBulgeOX, fGridY*i]) rect([-fBulgeWall-fWall2, fBulgeOY*2], [1,0]);
        // top hooks
        for (i=[l:r]) translate([fGridX*i, fGridY*t+fHornY-claspD.y+hookM.y]) rect([fSideOX*2-fWallGrid*4, claspD.y-hookM.y+fWallGrid+bPH-fSlopB], [0,1]);
        // bottom seam
        for (i=[l:r]) if (i<r) translate([fGridX*(i+0.5), fGridY*b-fHornY+fSlopB]) rect([claspD.x+stretchX+fWallGrid*4, fWall4+bPH-fSlopB], [0,1]);
        // bottom seam hooks
        for (i=[l:r]) if (i<r) translate([fGridX*(i+0.5)+claspD.x/2+stretchX/2+fWall2+fSlopXY*2, fGridY*b-fHornY-claspD.y+hookM.y*2+fWall2+fSlopB]) rect([ fWall2, claspD.y-hookM.y*2-fSlopB]);
        for (i=[l:r]) if (i<r) translate([fGridX*(i+0.5)-claspD.x/2-stretchX/2-fWall2-fSlopXY*2, fGridY*b-fHornY-claspD.y+hookM.y*2+fWall2+fSlopB]) rect([-fWall2, claspD.y-hookM.y*2-fSlopB]);
        // hook stem fills
        translate([fGridX*l-fSideOX-hookM.x-stretchX/2, fGridY*b-fHornY]) rect([ fWall2+hookM.x+stretchX/2, fGridY*(t-b)+fHornY*2]);
        translate([fGridX*r+fSideOX+hookM.x+stretchX/2, fGridY*b-fHornY]) rect([-fWall2-hookM.x-stretchX/2, fGridY*(t-b)+fHornY*2]);
      }
      else extrude(fBase, convexity=2) {
        translate([fGridX*r+fSideOX+fBulgeWall, fGridY*t+fTopOY+claspD.y-hookM.y-fWall2]) rect([fGridX*(l-r)-fSideOX*2-fBulgeWall-hookM.x-stretchX/2, fGridY*(b-t-1)+fWall2+fSlopXY*2+bPH]);
        // lower left corner
        translate([fGridX*l-fSideOX-hookM.x-stretchX/2, fGridY*b-fHornY]) rect([fWall4+hookM.x+stretchX/2, fWall4+bPH]);
        // right seam
        for (i=[b:t]) if (i>b) translate([fGridX*(r+0.5)+claspD.x/2-hookM.x, fGridY*(i-0.5)]) rect([-claspD.x+hookM.x-stretchX/2-fWallGrid, -fWall4], [1,0]);
        // upper right hook
        for (i=[b:t]) translate([fGridX*r+fSideIX, fGridY*i+fHornY]) rect([claspD.x-hookM.x+stretchX/2+fWallGrid, -claspW-hookW.x+fWallGrid]);
        // lower right hook
        for (i=[b:t]) translate([fGridX*r+fSideIX-fWallGrid, fGridY*i-fHornY]) rect([claspD.x-hookM.x+stretchX/2+fWallGrid*2, claspW+hookW.x-fWallGrid]);
        // left bulge
        for (i=[b:t]) translate([fGridX*l-fBulgeOX, fGridY*i]) rect([fBulgeWall+fWall2, fBulgeOY*2+fWallGrid*2], [1,0]);
        // top hooks
        for (i=[l:r]) translate([fGridX*i, fGridY*t+fHornY-claspD.y+hookM.y]) rect([fSideOX*2-fWallGrid*4, claspD.y-hookM.y+fWallGrid+bPH-fSlopB], [0,1]);
        // bottom seam
        for (i=[l:r]) if (i<r) translate([fGridX*(i+0.5), fGridY*b-fHornY+fSlopB]) rect([claspD.x+stretchX+fWallGrid*4, fWall4+bPH-fSlopB], [0,1]);
      }
      translate([0, 0, -fudge]) extrude(fBase+fudge2) keyholes();
    }
    else {
      extrude(fBase) keyholes();
      translate([0, 0, fBase]) extrude(keyHeadH) keyholes(head=true);
    }

    if (drawer || is_num(drawer))
      translate([0, drawerZFrameYAlign+fGridY*b, drawerYFrameZAlign+(is_num(drawer)?drawer:0)])
        rotate([-90,0,0]) drawer(x, h=t-b+1, divisions=divisions, drawFace=drawFace);

    if (hookInserts) for (i=[l:r]) if (i<r) translate([fGridX*(i+0.5), fGridY*b, fBase]) hookInsert();
  }
}



////////////
// DRAWER //
////////////


module drawer(x=1, h=1, divisions=false, drawFace=true) {
  assert(is_num(x) || is_list(x) && len(x)==2);
  assert(is_num(h) && h>=1);
  l = is_list(x) ? min(x[0], x[1]) : -(abs(x)-1)/2;
  r = is_list(x) ? max(x[0], x[1]) :  (abs(x)-1)/2;
  w = fGridX*(r-l) + drawerX;
  divided = is_list(divisions);
  dubWall = divided || dubWallBinDrawers;
  faceX = w - drawerX + fBulgeOX*2;
  faceZ = dFloorZ(fGridY*h - dSlopZ);
  bodyY = drawerY + (dubWall ? gap*2 : 0);
  bodyZ = dFloorZ(fGridY*(h-1) + drawerZ);
  stopZIdeal = fGridY*h - claspW - hookW.x - fWallGrid*2 - dSlopZ*2;
  stopZ = dFloorZ(stopZIdeal);
  stopZError = stopZ - stopZIdeal;
  stopHIdeal = (fWall2 + gap)*(h==1 ? fStopLines0 : fStopLinesN);
  stopH = stopHIdeal - stopZError;
  brace = fBulgeWall >= dWall2 + gap;
  braceTopIdeal = bodyZ - stopZ + stopHIdeal - dSlopZ + dSlop45 + (h>1?fBulgeWall:0);
  braceTop = dFloorH(braceTopIdeal);
  braceTopError = braceTop - braceTopIdeal;
  railW = railWN - (h==1 ? stopH : 0);
  peakW = peakWN - (h==1 ? stopH : 0);
  bulgeZ = fHornY - fWall2 - dSlopZ;
  bulgeMidH = fBulgeIY*2 - dSlop45*2 - fBulgeWall*2;
  railZ = bulgeZ - (h==1 ? stopH/2 : 0);

  module bump() hull() {
    box([-fudge, -dBL-dPL-dFL, railW], [1,1,0]);
    translate([0, -dBL, 0]) box([dPH, -dPL, peakW], [1,1,0]);
  }

  module dividerWall(length) rotate([90,0,90]) extrude(length, center=true) {
    difference() {
      union() {
        rect([dWall2+binR*2, dBase+binR*sqrt(2)/2], [0,1]);
        rect([dWall2, bodyZ], [0,1]);
      }
      rect([dWall2+binR*2, dBase*2-fudge2], [0,0]);
      flipX() translate([dWall2/2+binR, dBase+binR*sqrt(2)/2]) circle(r=binR, $fn=binFn);
    }
  }

  headOrID = function (x) is_list(x) ? head(x) : x;

  function positions(bounds, divisions) = let (total=sum(map(headOrID, divisions)))
    [for (i=-1, p=0; i<len(divisions); i=i+1, p=p+headOrID(divisions[min(i, len(divisions)-1)])) bounds.y*p/total];

  module dividerWalls(bounds, divisions, outer=true) {
    if (outer) {
      dividerWall(bounds.x);
      translate([0, bounds.y, 0]) dividerWall(bounds.x);
      flipX() translate([bounds.x/2, bounds.y/2, 0]) rotate(90) dividerWall(bounds.y);
    }
    if (is_list(divisions) && len(divisions)>=1) {
      dividers = positions(bounds, divisions);
      if (len(dividers)>=3) for (i=[1:len(dividers)-2]) translate([0, dividers[i], 0]) dividerWall(bounds.x);
      for (i=[0:len(divisions)-1]) if (is_list(divisions[i]) && len(divisions[i])==2) {
        subBounds = [dividers[i+1]-dividers[i], bounds.x];
        translate([-subBounds.y/2, dividers[i]+subBounds.x/2, 0]) rotate(-90) dividerWalls(subBounds, divisions[i][1], outer=false);
      }
    }
  }

  module dividerSurrogates(bounds, divisions) {
    if (is_list(divisions) && len(divisions)>=1) {
      dividers = positions(bounds, divisions);
      width = function (i) min((dividers[i+1]-dividers[i])/2, binR*(1-sqrt(2)/2)+dWall2/2);
      if (len(dividers)>=3) for (i=[1:len(dividers)-2])
        translate([0, dividers[i]-width(i-1)])
          rect([bounds.x, width(i-1)+width(i)], [0,1]);
      for (i=[0:len(divisions)-1]) if (is_list(divisions[i]) && len(divisions[i])==2) {
        subBounds = [dividers[i+1]-dividers[i], bounds.x];
        translate([-subBounds.y/2, dividers[i]+subBounds.x/2]) rotate(-90) dividerSurrogates(subBounds, divisions[i][1]);
      }
    }
  }

  module dividerCuts(bounds, divisions, outer=true) {
    divisions = outer ? concat(dubWallFaceLip?[[0]]:[], divisions, [[0]]) : divisions;
    if (is_list(divisions) && len(divisions)>=1) {
      dividers = positions(bounds, divisions);
      edge = dWall2 + gap;
      width = function (i) min((dividers[i+1]-dividers[i])/2, binR*(1-sqrt(2)/2)+edge/2);
      if (len(dividers)>=3) {
        // side cuts
        for (i=[1:len(dividers)-2]) for (j=[0:(bodyZ-dBase)/dLayerHN-1])
          translate([(bounds.x/2-edge/2)*(mod(j, 2)==0?1:-1), dividers[i], dBase+dLayerHN*j])
            box([gap, dWall2+gap, dLayerHN+fudge], [0,0,1]);
        // angle cuts
        translate([0, 0, dBase-fudge*2]) extrude(bodyZ-dBase+fudge*3) difference() {
          for (i=[1:len(dividers)-2]) flipX() translate([bounds.x/2-edge/2, dividers[i]]) {
            translate([0, -edge/2]) tull([-width(i-1)+edge/2, -width(i-1)+edge/2]) circle(d=gap, $fn=8);
            translate([0,  edge/2]) tull([-width(i  )+edge/2,  width(i  )-edge/2]) circle(d=gap, $fn=8);
          }
          for (i=[0:len(divisions)-1]) if (is_list(divisions[i]) && len(divisions[i])==2) {
            subBounds = [dividers[i+1]-dividers[i], bounds.x];
            translate([-subBounds.y/2, dividers[i]+subBounds.x/2]) rotate(-90) dividerSurrogates(subBounds, divisions[i][1]);
          }
        }
      }
      for (i=[0:len(divisions)-1]) {
        division = dividers[i+1] - dividers[i];
        subBounds = [division, bounds.x];
        // mid cuts
        if (division<bounds.x && division<binR*(2-sqrt(2))+edge && division>=edge)
          translate([0, 0, dBase-fudge*2]) extrude(bodyZ-dBase+fudge*3) difference() {
            hull() flipX() translate([bounds.x/2-division/2, dividers[i]+division/2]) rotate(-90) teardrop_2d(d=gap, $fn=8);
            if (is_list(divisions[i]) && len(divisions[i])==2)
              translate([-subBounds.y/2, dividers[i]+subBounds.x/2]) rotate(-90) dividerSurrogates(subBounds, divisions[i][1]);
          }
        // recurse
        if (is_list(divisions[i]) && len(divisions[i])==2)
          translate([-subBounds.y/2, dividers[i]+subBounds.x/2, 0]) rotate(-90) dividerCuts(subBounds, divisions[i][1], outer=false);
      }
    }
  }

  module handleProfile(r, trunc) {
    rotate(90) teardrop_2d(r=r, truncate=trunc, $fn=handleDFn);
    rotate(-90) teardrop_2d(r=r, truncate=r, $fn=handleDFn);
    if (handleTray) difference() {
      rotate(-22.5) teardrop_2d(r=r, a=67.5, $fn=handleDFn);
      rect([r*2+fudge2, -r-fudge], [0,1]);
      rotate(-45) rect([r*2+fudge2, -r-fudge], [0,1]);
    }
  }

  module handleOuter(r, trunc)
    rotate([0, 90, 0]) extrude(fudge, center=true) handleProfile(r, trunc);

  module handleInner(r, trunc)
    rotate([0, 90, 0]) extrude(fudge, center=true) difference() {
      intersection() {
        translate([0, -dWall2]) handleProfile(r, trunc);
        translate([0,  dWall2]) handleProfile(r, trunc);
      }
      translate([r-dBase, 0]) rect([dBase+fudge, r*8], [1,0]);
    }

  module handleCut(r, trunc)
    rotate([0, 90, 0]) extrude(fudge, center=true) translate([r-dBase, 0]) rect([dLayerHN*2-trunc+dBase-r, gap], [1,0]);

  // translate([0     ,0,100]) color("blue")  handleOuter(5, 3);
  // translate([fudge ,0,100]) color("green") handleInner(5, 3);
  // translate([fudge2,0,100]) color("red")   handleCut(5, 3);

  module handleSweep(r, a, b, step) translate([0, 0, r]) {
    if (handleElliptical) rotate(180) for (i=[0:step:180-step]) hull() {
      translate([a*cos(i), b*sin(i), 0]) rotate(atan2(b*cos(i), -a*sin(i))) children();
      translate([a*cos(i+step), b*sin(i+step), 0]) rotate(atan2(b*cos(i+step), -a*sin(i+step))) children();
    }
    else {
      if (handleR<b) flipX() translate([a, 0, 0]) tull([0, handleR-b, 0]) rotate(90) children();
      translate([0, -b, 0]) tull([handleR*2-a*2, 0, 0], center=true) children();
      flipX() translate([a-handleR, handleR-b]) hull_rotate_extrude(90, $fn=handleRFn) translate([0, -handleR, 0]) children();
    }
  }

  if (l<=r && h>=1) hl(!binDrawersEnabled && !divided, "Bin drawers are disabled.") translate([fGridX*(r+l)/2, dubWall?-gap:0, 0]) {
    difference() {
      union() {
        // main body
        translate([0, -bodyY/2, 0]) extrude(bodyZ) {
          rect([w, bodyY-dWall2], [0,1]);
          rect([w-dWall2*2, bodyY], [0,1]);
          flipX() translate([w/2-dWall2, bodyY-dWall2]) circle(dWall2, $fn=dFilletFn);
        }
        difference() {
          translate([0, bodyY/2-drawerY, bulgeZ]) {
            // bulges
            for (i=[1:h]) hl(bulgeMidH<(i==h?stopH:0), "Inadequate space for drawer rib.")
              translate([0, 0, fGridY*(i-1)-(i==h?stopH/2:0)]) hull() {
                box([w, drawerY-dWall2, fBulgeIY*2-dSlop45*2-(i==h?stopH:0)], [0,1,0]);
                box([w-dWall2*2, drawerY, fBulgeIY*2-dSlop45*2-(i==h?stopH:0)], [0,1,0]);
                flipX() translate([w/2-dWall2, drawerY-dWall2, 0]) rod(fBulgeIY*2-dSlop45*2-(i==h?stopH:0), r=dWall2, center=true, $fn=dFilletFn);
                box([w+fBulgeWall*2, drawerY-dWall2+fBulgeWall, bulgeMidH-(i==h?stopH:0)], [0,1,0]);
                box([w-dWall2*2+fBulgeWall*2, drawerY+fBulgeWall, bulgeMidH-(i==h?stopH:0)], [0,1,0]);
                flipX() translate([w/2-dWall2+fBulgeWall, drawerY-dWall2+fBulgeWall, 0]) rod(bulgeMidH-(i==h?stopH:0), r=dWall2, center=true, $fn=dFilletFn);
              }
            // bottom back edge
            translate([0, drawerY-dWall2-fudge, -(h==1?stopH/2:0)]) hull() {
              translate([0, 0, -fBulgeWall/2]) extrude(fBulgeIY*2-dSlop45*2-(h==1?stopH:0)-fBulgeWall, center=true) {
                rect([w, fBulgeWall+fudge], [0,1]);
                rect([w-dWall2*2, fBulgeWall+dWall2+fudge], [0,1]);
                flipX() translate([w/2-dWall2, fBulgeWall+fudge]) circle(dWall2, $fn=dFilletFn);
              }
              extrude(bulgeMidH-(h==1?stopH:0), center=true) {
                rect([w+fBulgeWall*2, fBulgeWall+fudge], [0,1]);
                rect([w+fBulgeWall*2-dWall2*2, fBulgeWall+dWall2+fudge], [0,1]);
                flipX() translate([w/2+fBulgeWall-dWall2, fBulgeWall+fudge]) circle(dWall2, $fn=dFilletFn);
              }
            }
          }
          // stop undercut (imperfect, but it helps with drawer insertion)
          translate([0, bodyY/2+fBulgeWall, h>1?fGridY*(h-1)+bulgeZ-stopH+bulgeMidH/2:railZ-railW/2])
            let (size=h>1?stopH-bulgeMidH-fBulgeWall:railW/2-fBulgeIY+dSlop45+stopH/2)
              shear(zY=1) translate([0, -dWall2, size]) extrude(fudge-size, convexity=2) difference() {
                rect([w+fBulgeWall*2+fudge2, fudge-size+dWall2], [0,1]);
                flipX() translate([w/2+fBulgeWall-dWall2, 0]) circle(dWall2, $fn=dFilletFn);
                rect([w+fBulgeWall*2-dWall2*2, dWall2*2], [0,0]);
              }
        }
        // bottom back edge
        translate([0, bodyY/2-dWall2-fudge, 0]) extrude(h>1?bulgeZ-fBulgeIY+dSlop45+fudge:railZ-railW/2) {
          rect([w, fBulgeWall+fudge], [0,1]);
          rect([w-dWall2*2, fBulgeWall+dWall2+fudge], [0,1]);
          flipX() translate([w/2-dWall2, fBulgeWall+fudge]) circle(dWall2, $fn=dFilletFn);
        }
        // stops
        if (dStopLines>0) hl(bulgeMidH<stopH, "Drawer stop is too tall.")
          translate([0, bodyY/2+fBulgeWall, stopZ]) extrude(-stopHIdeal-fBulgeWall+dSlopZ-dSlop45, convexity=4) difference() {
            for (i=[0:dStopLines-1]) translate([0, -(dWall2+gap)*sqrt(2)*i]) polygon(
              [ [ w/2+fBulgeWall*(1-sqrt(2))                                        , -fBulgeWall*sqrt(2)-dWall2*sqrt(2)/2]
              , [ w/2+fBulgeWall                                                    ,                    -dWall2*sqrt(2)/2]
              , [ w/2+fBulgeWall                                                    ,              i==0?0:dWall2*sqrt(2)/2]
              , [ w/2+fBulgeWall-(i>0||!brace?dWall2*sqrt(2)/2:0)                   ,                                    0]
              , [ w/2+fBulgeWall-(i>0||!brace?dWall2*sqrt(2)/2:0)-fBulgeWall*sqrt(2),    i>0||!brace?-fBulgeWall*sqrt(2):0]
              , [-w/2-fBulgeWall+(i>0||!brace?dWall2*sqrt(2)/2:0)+fBulgeWall*sqrt(2),    i>0||!brace?-fBulgeWall*sqrt(2):0]
              , [-w/2-fBulgeWall+(i>0||!brace?dWall2*sqrt(2)/2:0)                   ,                                    0]
              , [-w/2-fBulgeWall                                                    ,              i==0?0:dWall2*sqrt(2)/2]
              , [-w/2-fBulgeWall                                                    ,                    -dWall2*sqrt(2)/2]
              , [-w/2-fBulgeWall*(1-sqrt(2))                                        , -fBulgeWall*sqrt(2)-dWall2*sqrt(2)/2]
              ]);
            flipX() translate([w/2+fBulgeWall-dWall2, -dWall2]) difference() {
              rect([dWall2+fudge, dWall2+fudge], [1,1]);
              circle(dWall2, $fn=dFilletFn);
            }
          }
        // back brace block
        if (brace) translate([0, bodyY/2-dWall2-fudge, bodyZ]) extrude(stopZ-bodyZ-fudge) {
          rect([w, fBulgeWall+fudge], [0,1]);
          rect([w-dWall2*2, fBulgeWall+dWall2+fudge], [0,1]);
          flipX() translate([w/2-dWall2, fBulgeWall+fudge]) circle(dWall2, $fn=dFilletFn);
        }
      }
      // back brace cut
      if (brace && drawCuts) translate([0, bodyY/2, bodyZ-braceTop]) {
        rL = [w-dWall2*2, fBulgeWall];
        difference() {
          translate([0, 0, fudge]) eSliceX(-rL.y-fudge+(h>1?braceTopError:0), rL-[0, -fudge], centerX=true, wall2=dWall2);
          if (h==1) rotate([45,0,0]) box([w+fudge2, -fBulgeWall*sqrt(2), -fBulgeWall*sqrt(2)], [0,1,1]);
        }
        eSliceX(braceTop, rL-[0, dWall2], centerX=true, cutAlt=1, wall2=dWall2, layerH=dLayerHN, hFudge=fudge);
        eSliceY(braceTop, [rL.x, dWall2], translate=[0, rL.y-dWall2], flushT=true, flushB=true, centerX=true, cutAlt=mod(braceTop/dLayerHN+1, 2), wall2=dWall2, layerH=dLayerHN, hFudge=fudge);
      }
      // bottom front chamfer
      translate([0, bodyY/2+fBulgeWall-dChamfer-dWall2, 0]) shear(zY=1) translate([0, 0, -fudge]) extrude(dChamfer+fudge2, convexity=2) difference() {
        rect([w+fudge2, dChamfer+dWall2+fudge], [0,1]);
        flipX() translate([w/2-dWall2, 0]) circle(dWall2, $fn=dFilletFn);
        rect([w-dWall2*2, dWall2*2], [0,0]);
      }
      // cavity
      if (dubWall) translate([0, drawerY/2+gap-dWall2, dBase]) {
        if (divided) translate([0, fudge, 0])
          box([w-dWall2*2+fudge2, -drawerY+dWall2+(dubWallFaceLip?dWall2:-gap)-fudge2, bodyZ], [0,1,1]);
        box([w-dWall2*2, -drawerY+dWall2-gap-fudge, bodyZ], [0,1,1]);
      }
      // back wall cut
      if (dubWall && drawCuts) translate([0, drawerY/2+gap, dBase]) {
        eSliceY(bodyZ-dBase, [w-dWall2*2, dWall2], translate=[0, -dWall2], flushT=true, flushB=true, centerX=true, cutAlt=mod((bodyZ-dBase)/dLayerHN, 2), wall2=dWall2, layerH=dLayerHN, hFudge=fudge);
        flipX() translate([w/2-dWall2-gap, 0, 0]) box([gap, fBulgeWall+fudge,
          brace && h==1 ? bodyZ-braceTop-dBase+fudge :
          brace && h>1  ? fGridY*(h-2)+bulgeZ+fBulgeIY-dSlop45-dBase :
                          fGridY*(h-1)+bulgeZ+fBulgeIY-dSlop45-stopH-dBase
        ]);
      }
      // rail
      flipX() translate([w/2+fBulgeWall, fBulgeWall/2, railZ]) hull() {
        box([fudge, bodyY+fBulgeWall+fudge2, railW+railD*2], [1,0,0]);
        box([-railD, bodyY+fBulgeWall+fudge2, railW], [1,0,0]);
      }
      // bottom slots
      if (bPH>0) for (i=[l:r]) translate([fGridX*i-fGridX*(r+l)/2, dFloat, 0])
        flipX() translate([fSideIX-fSlopXY-claspW-hookW.y-dSlopXY, 0, 0]) hull() {
          translate([0, -drawerY/2+dTravel+bIL+bFL+bPL+bBL-(dSlopZ*bBL/bPH)-(dubWall?0:gap), 0]) {
            box([bPW+dSlopXY*2, -bodyY, -fudge]);
            translate([0, -bBL*(bSH/bPH), 0]) box([bPW+dSlopXY*2, -bodyY, bSH]);
          }
        }
    }
    // bumps
    hl(peakW<0, "Inadequate space for drawer side bumps.") flipX() translate([w/2+fBulgeWall-railD, bodyY/2, railZ]) {
      translate([0, fBulgeWall, 0]) render() difference() {
        bump();
        translate([-fudge*2, 0, bulgeMidH/2]) rotate([45]) box([dPH+fudge*3, fBulgeWall*sqrt(2)/2, fBulgeWall*sqrt(2)]);
        extrude(railW, center=true, convexity=2) flipX() translate([railD-dWall2, -dWall2, 0]) difference() {
          rect([dWall2+fudge, dWall2+fudge], [1,1]);
          circle(dWall2, $fn=dFilletFn);
        }
      }
      translate([0, -drawerY+dFL+dPL+dBL+dInset, 0]) bump();
    }
    // dividers
    if (divided) hl(bodyZ-dBase-dLayerHN<binR-binR*(1-sqrt(2)/2), "Bin radius is too large for drawer height.")
      translate([0, -drawerY/2-dWall2/2+(dubWallFaceLip?dWall2+gap:0), 0]) {
        bounds = [w-dWall2, drawerY+gap-(dubWallFaceLip?dWall2+gap:0)];
        difference() {
          render(convexity=len(divisions)) intersection() {
            dividerWalls(bounds, divisions);
            translate([0, dubWallFaceLip?-dWall2/2:0, 0]) box([bounds.x, bounds.y+(dubWallFaceLip?dWall2/2:0), bodyZ], [0,1,1]);
          }
          if (drawCuts) dividerCuts(bounds, divisions);
        }
      }
    // extra lip (bin drawers)
    if (!divided && dubWallBinDrawers && dubWallFaceLip) difference() {
      translate([0, -drawerY/2+gap, dBase-fudge]) box([w-dWall2, dWall2, bodyZ-dBase+fudge], [0,1,1]);
      if (drawCuts) translate([0, -drawerY/2+gap-fudge, dBase]) for (i=[0:(bodyZ-dBase)/dLayerHN-1])
        translate([(w-dWall2*2-gap)*(mod(i, 2)==0?1:-1)/2, 0, i*dLayerHN]) box([gap, dWall2+fudge2, dLayerHN+fudge], [0,1,1]);
    }
    // face
    if (drawFace) translate([0, -drawerY/2-(dubWall?0:gap)-dWall2, 0]) {
      if (!dubWall) box([dWall2, dWall2+gap+fudge, bodyZ], [0,1,1]);
      box([faceX, dWall2, faceZ], [0,1,1]);
    }
    // handle
    if (drawFace && handleL>0) {
      // h & r shaddow outer scope (above, r means right, but here, it means radius) (naming stuff is hard!)
      h = dFloorZ(handleD/2 + handleD*sqrt(2)/2 - dWall2/2 + dLayerHN/2);
      r = (h*2 + dWall2 - dLayerHN)/(2 + sqrt(2)*2);  // derived by removing `dFloorZ` from above and solving for `handleD`
      trunc = r*sqrt(2) - dWall2/2 + dLayerHN/2;
      a = faceX/2 - r;
      b = handleL - r;
      step = 360/handleRFn;
      layers = dFloorH(r + trunc - dBase) / dLayerHN;
      difference() {
        translate([0, -drawerY/2-(dubWall?0:gap)-dWall2, 0]) {
          difference() {
            handleSweep(r, a, b, step) handleOuter(r, trunc);
            translate([0, dWall2, -fudge]) {
              if (r*2-dWall2>handleL) box([faceX+fudge2, r*2-dWall2-handleL+fudge, h+fudge2], [0,1,1]);
              if (!handleElliptical && handleR-dWall2>b) box([faceX+fudge2, handleR-dWall2-b+fudge, h+fudge2], [0,1,1]);
            }
            if (drawCuts) {
              difference() {
                handleSweep(r, a, b, step) handleInner(r, trunc);
                translate([0, dWall2, 0]) box([faceX, -gap-dWall2*2, r+trunc], [0,1,1]);
              }
              difference() {
                handleSweep(r, a, b, step) handleCut(r, trunc);
                translate([0, dWall2, dBase]) for (i=[0:layers-3]) translate([0, 0, i*dLayerHN])
                  box([(a+r+fudge)*(mod(i, 2)==0?1:-1), -gap-dWall2*2, dLayerHN+fudge]);
              }
            }
          }
          if (handleTray) extrude(dBase) difference() {
            union() {
              if (handleElliptical) scale([a, b]) circle($fn=handleRFn);
              else {
                rect([a*2-handleR*2, b*2], [0,0]);
                rect([a*2, b*2-handleR*2], [0,0]);
                flipX() translate([a-handleR, handleR-b, 0]) circle(handleR, $fn=handleRFn);
              }
            }
            translate([0, dWall2]) rect([a*2+fudge2, b], [0,1]);
          }
        }
        if (drawCuts) translate([0, -drawerY/2-(dubWall?0:gap), dBase]) for (i=[0:layers-1]) translate([0, 0, i*dLayerHN]) {
          dir = mod(i, 2)==0 ? 1 : -1;
          box([(a+r+fudge)*dir*-1, -gap-dWall2, dLayerHN+fudge]);
          box([(a-dWall2/2)*dir, -gap-dWall2, dLayerHN+fudge]);
          translate([(a+dWall2/2)*dir, 0, 0]) box([(r-dWall2/2+fudge)*dir, -gap-dWall2, dLayerHN+fudge]);
        }
      }
    }
  }
}



/////////
// BIN //
/////////


module bin(x=1, y=1, h=1) {
  assert(is_num(x) || is_list(x) && len(x)==2);
  assert(is_num(y) || is_list(y) && len(y)==2);
  assert(is_num(h));
  f = is_list(y) ? min(y[0], y[1]) : -(abs(y)-1)/2;
  b = is_list(y) ? max(y[0], y[1]) :  (abs(y)-1)/2;
  l = is_list(x) ? min(x[0], x[1]) : -(abs(x)-1)/2;
  r = is_list(x) ? max(x[0], x[1]) :  (abs(x)-1)/2;
  w = bGridXY*(r-l) + binXY;
  d = bGridXY*(b-f) + binXY;
  z = bFloorZ(fGridY*(h-1) + binZ);
  bulge = binR*(1-sqrt(2)/2);

  if (f<=b && l<=r && h>=1)
    hl(!binDrawersEnabled, "Bins are disabled.")
    hl(bulge*2>w-bWall2, "Bin radius is too large for bin width.")
    hl(bulge*2>d-bWall2, "Bin radius is too large for bin depth.")
      translate([bGridXY*(r+l)/2, bGridXY*(b+f)/2, 0]) {
        box([w, d, bBase], [0,0,1]);
        box([w-binR*(2-sqrt(2)), d-binR*(2-sqrt(2)), z], [0,0,1]);
        translate([0, 0, bBase+binR-bulge]) {
          hl(z-bBase-bLayerHN/2<binR-bulge, "Bin radius is too large for bin height.") box([w, d, z-bBase-binR+bulge], [0,0,1]);
          intersection() {
            hull() flipX() translate([w/2-binR, 0, 0]) difference() {
              rotate([90, 0]) cylinder(d, r=binR, center=true, $fn=binFn);
              translate([-bulge/2-fudge, 0, 0]) box([binR*2-bulge+fudge2, d+fudge2, binR*2], [0,0,0]);
              translate([binR-bulge-fudge, 0, z-bBase-binR+bulge]) box([bulge+fudge2, d+fudge2, binR*2-bulge*2-z+bBase+fudge], [1,0,1]);
            }
            hull() flipY() translate([0, d/2-binR, 0]) difference() {
              rotate([0, 90]) cylinder(w, r=binR, center=true, $fn=binFn);
              translate([0, -bulge/2-fudge, 0]) box([w+fudge2, binR+(binR-bulge)+fudge2, binR*2], [0,0,0]);
              translate([0, binR-bulge-fudge, z-bBase-binR+bulge]) box([w+fudge2, bulge+fudge2, binR*2-bulge*2-z+bBase+fudge], [0,1,1]);
            }
          }
        }
      }
}


/////////////////
// HOOK INSERT //
/////////////////


module hookInsert() render() {
  difference() {
    translate([0, 0, -fBase]) {
      translate([ fGridX/2, 0, 0]) blHook();
      translate([-fGridX/2, 0, 0]) brHook();
    }
    box([fGridX, -fGridY, -fBase-fudge], [0,1,1]);
  }
  translate([0, -fHornY+fWall2, 0]) box([claspD.x+stretchX+fWall4*2+fSlopXY*2, -fWall2, fGridZ-fBase], [0,1,1]);
}



///////////
// DEMOS //
///////////


module demoHooks() {
  demoHooksTB();
  demoHooksLR();
}

module demoHooksTB() {
  translate([      0,  fGridY, 0]) condColor(solidOrange) blHook();
  translate([      0,  fGridY, 0]) condColor(solidOrange) brHook();
  translate([      0,       0, 0]) condColor(transBlue)   tHooks();

  translate([      0, -fGridY, 0]) condColor(solidOrange) tHooks();
  translate([      0,       0, 0]) condColor(transBlue)   bHooks();
}

module demoHooksLR() {
  translate([-fGridX,       0, 0]) condColor(solidOrange) rHooks();
  translate([      0,       0, 0]) condColor(transBlue)   lHooks();

  translate([ fGridX,       0, 0]) condColor(solidOrange) lHooks();
  translate([      0,       0, 0]) condColor(transBlue)   rHooks();
}

module demoFill(w) {
  echo(flush=2, fillWalls=fillWalls(w, 2, fWall2), fillResidue=fillResidue(w, 2, fWall2), fillResidueShare=fillResidueShare(w, 2, fWall2));
  echo(flush=1, fillWalls=fillWalls(w, 1, fWall2), fillResidue=fillResidue(w, 1, fWall2), fillResidueShare=fillResidueShare(w, 1, fWall2));
  echo(flush=0, fillWalls=fillWalls(w, 0, fWall2), fillResidue=fillResidue(w, 0, fWall2), fillResidueShare=fillResidueShare(w, 0, fWall2));
  baseH = -0.25;
  gapH = 0.1;
  lineH = 0.1;
  cutH = 0.2;
  // normal, tightly packed
  translate([0, 0]) {
    fillWalls = div(w-gap+fudge, fWall2+gap);
    color(solidBlue) extrude(baseH) rect([w, 1]);
    if (fillWalls > 0) {
      color(solidBrown) extrude(gapH) rect([gap, 1]);
      for (i=[0:fillWalls-1]) translate([i*(fWall2+gap)+gap, 0]) {
        color(solidOrange) extrude(lineH) rect([fWall2, 1]);
        color(solidBrown) extrude(gapH) translate([fWall2, 0]) rect([gap, 1]);
      }
    }
  }
  // spread evenly
  translate([0, 1.5]) {
    fillWalls = fillWalls(w, 0, fWall2);
    fillWall  = fillWall (w, 0, fWall2);
    fillGap   = fillGap  (w, 0, fWall2);
    fillGrid  = fillGrid (w, 0, fWall2);
    color(solidBlue) extrude(baseH) rect([w, 1]);
    if (fillWalls > 0) {
      color(solidBrown) extrude(gapH) rect([gap/2, 1]);
      color(solidBrown) extrude(gapH) translate([fillGap-gap/2, 0]) rect([gap/2, 1]);
      for (i=[0:fillWalls-1]) translate([i*fillGrid+fillGap, 0]) {
        color(solidOrange) extrude(lineH) rect([fWall2/2, 1]);
        color(solidOrange) extrude(lineH) translate([fillWall-fWall2/2, 0]) rect([fWall2/2, 1]);
        color(solidBrown) extrude(gapH) translate([fillWall, 0]) rect([gap/2, 1]);
        color(solidBrown) extrude(gapH) translate([fillGrid-gap/2, 0]) rect([gap/2, 1]);
      }
      for (i=[0:fillWalls-1]) translate([i*fillGrid+fillGap, 0])
        color(transGrey) extrude(cutH) translate([fillWall, 0]) rect([fillGap, 1]);
    }
    color(transGrey) extrude(cutH) rect([fillGap, 1]);
  }
  // flush to end
  translate([0, 3]) {
    fillWalls = fillWalls(w, 1, fWall2);
    fillWall  = fillWall (w, 1, fWall2);
    fillGap   = fillGap  (w, 1, fWall2);
    fillGrid  = fillGrid (w, 1, fWall2);
    color(solidBlue) extrude(baseH) rect([w, 1]);
    if (fillWalls > 0) {
      for (i=[0:fillWalls-1]) translate([i*fillGrid, 0]) {
        color(solidOrange) extrude(lineH) translate([fillGap, 0]) rect([fWall2/2, 1]);
        color(solidOrange) extrude(lineH) translate([fillGrid-fWall2/2, 0]) rect([fWall2/2, 1]);
        color(solidBrown) extrude(gapH) rect([gap/2, 1]);
        color(solidBrown) extrude(gapH) translate([fillGap-gap/2, 0]) rect([gap/2, 1]);
      }
      for (i=[0:fillWalls-1]) translate([i*fillGrid, 0])
        color(transGrey) extrude(cutH) rect([fillGap, 1]);
    }
    else color(transGrey) extrude(cutH) rect([w, 1]);
  }
  // flush to start
  translate([0, 4.5]) {
    fillWalls = fillWalls(w, 1, fWall2);
    fillWall  = fillWall (w, 1, fWall2);
    fillGap   = fillGap  (w, 1, fWall2);
    fillGrid  = fillGrid (w, 1, fWall2);
    color(solidBlue) extrude(baseH) rect([w, 1]);
    if (fillWalls > 0) {
      for (i=[0:fillWalls-1]) translate([i*fillGrid, 0]) {
        color(solidOrange) extrude(lineH) rect([fWall2/2, 1]);
        color(solidOrange) extrude(lineH) translate([fillWall-fWall2/2, 0]) rect([fWall2/2, 1]);
        color(solidBrown) extrude(gapH) translate([fillWall, 0]) rect([gap/2, 1]);
        color(solidBrown) extrude(gapH) translate([fillGrid-gap/2, 0]) rect([gap/2, 1]);
      }
      for (i=[0:fillWalls-1]) translate([i*fillGrid, 0])
        color(transGrey) extrude(cutH) translate([fillWall, 0]) rect([fillGap, 1]);
    }
    else color(transGrey) extrude(cutH) rect([w, 1]);
  }
  // flush to start and end
  translate([0, 6]) {
    fillWalls = fillWalls(w, 2, fWall2);
    fillWall  = fillWall (w, 2, fWall2);
    fillGap   = fillGap  (w, 2, fWall2);
    fillGrid  = fillGrid (w, 2, fWall2);
    color(solidBlue) extrude(baseH) rect([w, 1]);
    if (fillWalls > 0) {
      for (i=[0:fillWalls-1]) translate([i*fillGrid-fillGap, 0]) {
        if (i>0) color(solidBrown) extrude(gapH) rect([gap/2, 1]);
        if (i>0) color(solidBrown) extrude(gapH) translate([fillGap-gap/2, 0]) rect([gap/2, 1]);
        color(solidOrange) extrude(lineH) translate([fillGap, 0]) rect([fWall2/2, 1]);
        color(solidOrange) extrude(lineH) translate([fillGrid-fWall2/2, 0]) rect([fWall2/2, 1]);
      }
      for (i=[0:fillWalls-1]) translate([i*fillGrid-fillGap, 0])
        if (i>0) color(transGrey) extrude(cutH) rect([fillGap, 1]);
    }
    else color(transGrey) extrude(cutH) rect([w, 1]);
  }
  echo();
}

module demoFills() {
  translate([ 0, 32, 0]) demoFill(fWall2*1-gap*1);
  translate([ 0, 24, 0]) demoFill(fWall2*1+gap*0);
  translate([ 0, 16, 0]) demoFill(fWall2*1+gap*1);
  translate([ 0,  8, 0]) demoFill(fWall2*1+gap*2);
  translate([ 0,  0, 0]) demoFill(fWall2*1+gap*3);

  translate([ 3, 32, 0]) demoFill(fWall2*2+gap*0);
  translate([ 3, 24, 0]) demoFill(fWall2*2+gap*1);
  translate([ 3, 16, 0]) demoFill(fWall2*2+gap*2);
  translate([ 3,  8, 0]) demoFill(fWall2*2+gap*3);
  translate([ 3,  0, 0]) demoFill(fWall2*2+gap*4);

  translate([ 7, 32, 0]) demoFill(fWall2*3+gap*1);
  translate([ 7, 24, 0]) demoFill(fWall2*3+gap*2);
  translate([ 7, 16, 0]) demoFill(fWall2*3+gap*3);
  translate([ 7,  8, 0]) demoFill(fWall2*3+gap*4);
  translate([ 7,  0, 0]) demoFill(fWall2*3+gap*5);

  translate([12, 32, 0]) demoFill(fWall2*4+gap*2);
  translate([12, 24, 0]) demoFill(fWall2*4+gap*3);
  translate([12, 16, 0]) demoFill(fWall2*4+gap*4);
  translate([12,  8, 0]) demoFill(fWall2*4+gap*5);
  translate([12,  0, 0]) demoFill(fWall2*4+gap*6);
}

module demoSliceX(r, translate
, flushT=false, flushB=false, flushL=false, flushR=false
, centerX=false, centerY=false
, cutT=false, cutB=false, cutMid=false, cutAlt=false
) difference() {
    // translate([centerX?0:-fudge*sign(r.x), centerY?0:-fudge*sign(r.y)]) rect(r+[fudge2*sign(r.x),fudge2*sign(r.y)], [centerX?0:1,centerY?0:1]);
    rect(r, [centerX?0:1,centerY?0:1]);
    sliceX(r, translate, flushT, flushB, flushL, flushR, centerX, centerY, cutT, cutB, cutMid, cutAlt)
      if ($children > 0) children();
      else rect(r*4, [0,0]);
  }

module demoSliceY(r, translate
, flushT=false, flushB=false, flushL=false, flushR=false
, centerX=false, centerY=false
, cutL=false, cutR=false, cutMid=false, cutAlt=false
) difference() {
    // translate([centerX?0:-fudge*sign(r.x), centerY?0:-fudge*sign(r.y)]) rect(r+[fudge2*sign(r.x),fudge2*sign(r.y)], [centerX?0:1,centerY?0:1]);
    rect(r, [centerX?0:1,centerY?0:1]);
    sliceY(r, translate, flushT, flushB, flushL, flushR, centerX, centerY, cutL, cutR, cutMid, cutAlt)
      if ($children > 0) children();
      else rect(r*4, [0,0]);
  }

module demoSides(drawTrim=true) {
  trimColor = drawTrim ? transBlue : false;
  lSide(x=[ 0.8], z=5, color=solidOrange, trimColor=trimColor);
  rSide(x=[-0.8], z=5, color=solidOrange, trimColor=trimColor);
  tlSide([-2, -1], [-0.8], color=solidOrange, trimColor=trimColor);
  trSide([ 1,  2], [-0.8], color=solidOrange, trimColor=trimColor);
  blSide([-2, -1], [ 0.8], color=solidOrange, trimColor=trimColor);
  brSide([ 1,  2], [ 0.8], color=solidOrange, trimColor=trimColor);
}

module demoPerimeter(x=2, z=2, cornerSize=1, color=true, trimColor=true) {
  assert(is_num(x) || is_list(x) && len(x)==2);
  assert(is_num(z) || is_list(z) && len(z)==2);
  t = is_list(z) ? max(z[0], z[1]) :  (abs(z)-1)/2;
  b = is_list(z) ? min(z[0], z[1]) : -(abs(z)-1)/2;
  l = is_list(x) ? min(x[0], x[1]) : -(abs(x)-1)/2;
  r = is_list(x) ? max(x[0], x[1]) :  (abs(x)-1)/2;
  assert(t-b>=cornerSize);
  assert(r-l>=cornerSize);
  condColor(color) {
    if (r-cornerSize>l+cornerSize) {
      tSide([l+cornerSize, r-cornerSize], [t]);
      bSide([l+cornerSize, r-cornerSize], [b]);
    }
    lSide([l], [b, t]);
    rSide([r], [b, t]);
    tlSide([l, l+cornerSize-1], [t]);
    trSide([r, r-cornerSize+1], [t]);
    blSide([l, l+cornerSize-1], [b]);
    brSide([r, r-cornerSize+1], [b]);
  }
  if (trim) condColor(trimColor) {
    if (r-cornerSize>l+cornerSize) {
      tTrim([l+cornerSize, r-cornerSize], [t], print=false);
      bTrim([l+cornerSize, r-cornerSize], [b], print=false);
    }
    if (t-cornerSize>b+cornerSize) {
      lTrim([l], [b+cornerSize, t-cornerSize], print=false);
      rTrim([r], [b+cornerSize, t-cornerSize], print=false);
    }
    tlTrim([l, l+cornerSize-1], [t, t-cornerSize+1], print=false);
    trTrim([r, r-cornerSize+1], [t, t-cornerSize+1], print=false);
    blTrim([l, l+cornerSize-1], [b, b+cornerSize-1], print=false);
    brTrim([r, r-cornerSize+1], [b, b+cornerSize-1], print=false);
  }
}

module demoFrameSmall(drawers=true, drawTrim=true) {
  color(solidGrey)
    rotate([90]) {
      translate([-fGridX*3/2, -fGridY*3/2, 0]) {
        frame([0,0], [3,3], hookInserts=true, drawer=drawers);
        frame([0,0], [1,2], hookInserts=true, drawer=drawers);
        frame([0,0], [0,0], hookInserts=true, drawer=drawers);

        frame([1,2], [3,3], hookInserts=true, drawer=drawers);
        frame([1,2], [1,2], hookInserts=true, drawer=drawers);
        frame([1,2], [0,0], hookInserts=true, drawer=drawers);

        frame([3,3], [3,3], hookInserts=true, drawer=drawers);
        frame([3,3], [1,2], hookInserts=true, drawer=drawers);
        frame([3,3], [0,0], hookInserts=true, drawer=drawers);
      }
    }
  color(solidOrange)
    rotate([90]) {
      demoPerimeter(4, 4, trimColor=drawTrim);
  }
}

module demoFrameSmall2(drawers=true, drawTrim=true) {
  color(solidGrey)
    rotate([90]) {
      translate([-fGridX*3, -fGridY*3, 0]) {
        frame([0,1], [5,6], hookInserts=true, drawer=drawers);
        frame([0,1], [2,4], hookInserts=true, drawer=drawers);
        frame([0,1], [0,1], hookInserts=true, drawer=drawers);

        frame([2,4], [5,6], hookInserts=true, drawer=drawers);
        frame([2,4], [2,4], hookInserts=true, drawer=drawers);
        frame([2,4], [0,1], hookInserts=true, drawer=drawers);

        frame([5,6], [5,6], hookInserts=true, drawer=drawers);
        frame([5,6], [2,4], hookInserts=true, drawer=drawers);
        frame([5,6], [0,1], hookInserts=true, drawer=drawers);
      }
    }
  color(solidOrange)
    rotate([90]) {
      demoPerimeter(7, 7, trimColor=drawTrim);
  }
}

module demoFrameLarge(drawers=true, drawTrim=true) {
  color(solidGrey)
    rotate([90]) {
      frame([-4, -3], [ 2,  2], hookInserts=true, drawer=drawers? 0.0:false);
      frame([-4, -3], [ 1,  1], hookInserts=true, drawer=drawers? 5.0:false);
      frame([-4, -3], [ 0,  0], hookInserts=true, drawer=drawers?10.0:false);
      frame([-4, -3], [-1, -2], hookInserts=true, drawer=drawers? 2.5:false);

      frame([-2, -2], [ 2,  2], hookInserts=true, drawer=drawers? 5.0:false);
      frame([-2, -2], [ 1,  1], hookInserts=true, drawer=drawers?10.0:false);
      frame([-2, -2], [ 0,  0], hookInserts=true, drawer=drawers?20.0:false);
      frame([-2, -1], [-1, -2], hookInserts=true, drawer=drawers? 7.5:false);

      frame([-1,  1], [ 2,  2], hookInserts=true, drawer=drawers?10.0:false);
      frame([-1,  1], [ 1,  1], hookInserts=true, drawer=drawers?20.0:false);
      frame([-1,  1], [ 0,  0], hookInserts=true, drawer=drawers?40.0:false);

      frame([ 0,  0], [-1, -1], hookInserts=true, drawer=drawers?20.0:false);
      frame([ 0,  0], [-2, -2], hookInserts=true, drawer=drawers?10.0:false);

      frame([ 2,  2], [ 2,  2], hookInserts=true, drawer=drawers? 5.0:false);
      frame([ 2,  2], [ 1,  1], hookInserts=true, drawer=drawers?10.0:false);
      frame([ 2,  2], [ 0,  0], hookInserts=true, drawer=drawers?20.0:false);
      frame([ 2,  1], [-1, -2], hookInserts=true, drawer=drawers? 7.5:false);

      frame([ 4,  3], [ 2,  2], hookInserts=true, drawer=drawers? 0.0:false);
      frame([ 4,  3], [ 1,  1], hookInserts=true, drawer=drawers? 5.0:false);
      frame([ 4,  3], [ 0,  0], hookInserts=true, drawer=drawers?10.0:false);
      frame([ 4,  3], [-1, -2], hookInserts=true, drawer=drawers? 2.5:false);
    }
  color(solidOrange)
    rotate([90]) {
      demoPerimeter(9, 5, cornerSize=2, trimColor=drawTrim);
  }
}

module demoFrameLarge2(drawers=true, drawTrim=true) {
  color(solidGrey)
    rotate([90]) {
      frame([-8, -7], [ 3,  4], hookInserts=true, drawer=drawers);
      frame([-6, -5], [ 3,  4], hookInserts=true, drawer=drawers);
      frame([-8, -5], [ 1,  2], hookInserts=true, drawer=drawers);
      frame([-8, -5], [-1,  0], hookInserts=true, drawer=drawers);
      frame([-8, -6], [-4, -2], hookInserts=true, drawer=drawers);

      frame([-4, -3], [ 2,  4], hookInserts=true, drawer=drawers);
      frame([-4, -2], [-1,  1], hookInserts=true, drawer=drawers);
      frame([-5, -2], [-4, -2], hookInserts=true, drawer=drawers);

      frame([-2,  2], [ 2,  4], hookInserts=true, drawer=drawers);
      frame([-1,  1], [ 0,  1], hookInserts=true, drawer=drawers);
      frame([-1,  1], [-2, -1], hookInserts=true, drawer=drawers);
      frame([-1,  1], [-4, -3], hookInserts=true, drawer=drawers);

      frame([ 3,  4], [ 2,  4], hookInserts=true, drawer=drawers);
      frame([ 2,  4], [-1,  1], hookInserts=true, drawer=drawers);
      frame([ 2,  5], [-4, -2], hookInserts=true, drawer=drawers);

      frame([ 7,  8], [ 3,  4], hookInserts=true, drawer=drawers);
      frame([ 5,  6], [ 3,  4], hookInserts=true, drawer=drawers);
      frame([ 5,  8], [ 1,  2], hookInserts=true, drawer=drawers);
      frame([ 5,  8], [-1,  0], hookInserts=true, drawer=drawers?dTravel:false, divisions=dividerDrawer?divisions:false);
      frame([ 6,  8], [-4, -2], hookInserts=true, drawer=drawers);
    }
  color(solidOrange)
    rotate([90]) {
      demoPerimeter(17, 9, cornerSize=2, trimColor=drawTrim);
  }
}

module demoDrawerBumpAlignment(x=1, h=1, drawer=dTravel, divisions=false)
  rotate([90,0,0]) translate([0, -drawerZFrameYAlign, -drawerYFrameZAlign-drawer]) {
    frame(x, [0, h-1], drawer=drawer, divisions=divisions, drawFace=true, drawFloor=false, drawSides=false);
    frame(x, [-1, -h], drawTop=false, drawFloor=false, drawSides=false);
  }

module demoDrawerZAlignment(x=1, h=1, divisions=false)
  rotate([90,0,0]) translate([0, -drawerZFrameYAlign, -drawerYFrameZAlign])
    frame(x, [0, h-1], drawer=true, divisions=divisions, drawFace=false, drawFloor=false);


module demoDrawerBinAlignment(x=1, h=1, divisions=false) {
  assert(is_num(x) || is_list(x) && len(x)==2);
  assert(is_num(h) && h>=1);
  l = is_list(x) ? min(x[0], x[1]) : -(abs(x)-1)/2;
  r = is_list(x) ? max(x[0], x[1]) :  (abs(x)-1)/2;
  w = fGridX*(r-l) + drawerX;
  bodyZ = dFloorZ(fGridY*(h-1) + drawerZ);
  dubWall = is_list(divisions) || dubWallBinDrawers;
  if (l<=r && h>=1) {
    difference() {
      drawer(x=x, h=h, divisions=divisions);
      if (!dubWall) translate([fGridX*(r+l)/2, drawerY/2-dWall, dBase]) box([w-dWall*2, -drawerY+dWall*2, bodyZ], [0,1,1]);
    }
    cols = (r-l+1)*(binsX+1) - 1;
    rows = binsY;
    translate([bGridXY*(1-cols)/2+fGridX*(r+l)/2, bGridXY*(1-rows)/2-(dubWall&&!dubWallFaceLip?dWall2/2+gap/2:0), dBase+bSlopZ])
      for (i=[0:cols-1]) for (j=[0:rows-1])
        translate([bGridXY*i, bGridXY*j, 0]) box([binXY, binXY, bFloorZ(fGridY*(h-1) + binZ)], [0,0,1]);
  }
}



/////////////////
// FINAL PARTS //
/////////////////


partW = Part_width;
partH = Part_height;

binW = Bin_width;
binD = Bin_depth;

showDrawers = Show_drawers_in_demos;
showTrim = Show_trim_in_demos;
dividerDrawer = Fixed_divider_drawer;
divs = dividerDrawer ? divisions : false;

if (Active_model=="fills") demoFills();

if (Active_model=="sides") demoSides(drawTrim=showTrim);

if (Active_model=="perimeter") demoPerimeter(color=solidOrange, trimColor=showTrim?transBlue:false);

if (Active_model=="hooks") demoHooks();
if (Active_model=="hooks - top & bottom") demoHooksTB();
if (Active_model=="hooks - left & right") demoHooksLR();

if (Active_model=="small assembly")       demoFrameSmall (drawers=showDrawers, drawTrim=showTrim);
if (Active_model=="small assembly - h>1") demoFrameSmall2(drawers=showDrawers, drawTrim=showTrim);
if (Active_model=="large assembly")       demoFrameLarge (drawers=showDrawers, drawTrim=showTrim);
if (Active_model=="large assembly - h>1") demoFrameLarge2(drawers=showDrawers, drawTrim=showTrim);

if (Active_model=="bump alignment - drawer shut") demoDrawerBumpAlignment(x=partW, h=partH, drawer=0, divisions=divs);
if (Active_model=="bump alignment - drawer open") demoDrawerBumpAlignment(x=partW, h=partH, drawer=dTravel, divisions=divs);
if (Active_model=="z alignment") demoDrawerZAlignment(x=partW, h=partH, divisions=divs);
if (Active_model=="bin alignment") demoDrawerBinAlignment(x=partW, h=partH, divisions=divs);

if (Active_model=="frame") frame(x=partW, z=partH);
if (Active_model=="drawer") drawer(x=partW, h=partH, divisions=divs);
if (Active_model=="bin") bin(x=binW, y=binD, h=partH);
if (Active_model=="side") {
  if (Side==   "top"      )  tSide(x=partW);
  if (Side==   "top left" ) tlSide(x=partW);
  if (Side==       "left" )  lSide(z=partH);
  if (Side=="bottom left" ) blSide(x=partW);
  if (Side=="bottom"      )  bSide(x=partW);
  if (Side=="bottom right") brSide(x=partW);
  if (Side==       "right")  rSide(z=partH);
  if (Side==   "top right") trSide(x=partW);
}
if (Active_model=="trim") {
  if (Side==   "top"      )  tTrim(x=partW         );
  if (Side==   "top left" ) tlTrim(x=partW, z=partH);
  if (Side==       "left" )  lTrim(         z=partH);
  if (Side=="bottom left" ) blTrim(x=partW, z=partH);
  if (Side=="bottom"      )  bTrim(x=partW         );
  if (Side=="bottom right") brTrim(x=partW, z=partH);
  if (Side==       "right")  rTrim(         z=partH);
  if (Side==   "top right") trTrim(x=partW, z=partH);
}
if (Active_model=="hook insert") hookInsert();



/////////////
// SCRATCH //
/////////////


translate([0, 0, -1]) {
  // demoSliceX([-6, 7], [0,0]
  // , flushT=false, flushB=false, flushL=true, flushR=false
  // , centerX=false, centerY=false
  // , cutT=false, cutB=false, cutMid=false, cutAlt=1
  // ) translate([-2.25, 2]) circle(4);
  // demoSliceY([-6, -7], [0,0]
  // , flushT=true, flushB=false, flushL=false, flushR=false
  // , centerX=false, centerY=true
  // , cutL=false, cutR=false, cutMid=false, cutAlt=1
  // );
}

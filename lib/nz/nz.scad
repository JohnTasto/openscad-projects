// More stuff at https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Tips_and_Tricks


/***********************/
/* logging & debugging */
/***********************/

$_debug = true;

function tap(x, msg="") = let(_ = [for (i = [1:1]) if ($_debug) echo(str(msg, ": ", x))]) x;

module noop() {}


/******************/
/* floating point */
/******************/

num_min = -1.79769313486231585574870450727757997810840606689453125*1e308;
num_max =  1.79769313486231585574870450727757997810840606689453125*1e308;

epsilon = 0.01;

function epsilon_equals(u, v, e=epsilon, i=0) = is_num(u) && is_num(v)
  ? abs(u - v) <= e
  : is_list(u) && is_list(v)
  ? len(u) != len(v)
    ? false
    : len(u) == i
    ? true
    : abs(u[i] - v[i]) <= e && epsilon_equals(u, v, e, i+1)
  : false;

// find a solution (x intercept) for `f` using binary search
// limit recursion depth using one or more of:
//   - `delta`   - tolerance of the independent variable
//   - `epsilon` - tolerance of the dependent variable
//   - `depth`   - strict recursion limit
// `f` must be monotonically increasing between `min` and `max`
// newton's method and related are faster but require knowing the derivatives of `f`
function solve(f, min=num_min, max=num_max, delta, epsilon, depth) =
  assert(is_function(f))
  assert(is_num(min) && is_num(max) && min <= max)
  assert(is_undef(delta)   || is_num(delta))
  assert(is_undef(epsilon) || is_num(epsilon))
  assert(is_undef(depth)   || is_num(depth) && depth >= 0)
  let ( x = (min + max)/2, y = f(x) )
  assert(is_num(y))
  is_num(delta)   && max-min <= abs(delta)   ? x :
  is_num(epsilon) && abs(y)  <= abs(epsilon) ? x :
  is_num(depth)   && depth   == 0            ? x :
  y > 0 ? solve(f, min, x, delta, epsilon, is_num(depth) ? depth-1 : undef) :
  y < 0 ? solve(f, x, max, delta, epsilon, is_num(depth) ? depth-1 : undef) :
          x;

// // example:
// echo(solve(function (x) x^3 - 5, -100, 100, epsilon=0.01));


/********************/
/* unit conversions */
/********************/

function mm(inches) = 25.4*inches;
function inches(mm) = mm/25.4;


/*********/
/* lists */
/*********/

function head(xs) = xs[0];
function last(xs) = xs[len(xs)-1];

function take(n, xs) = let (l = len(xs)) n > 0 ? [for (i = [0 : min(n,l)-1]) xs[i]] : [];
function drop(n, xs) = let (l = len(xs)) l > n ? [for (i = [max(0,n) : l-1]) xs[i]] : [];

function init(xs) = take(1, xs);
function tail(xs) = drop(1, xs);

function map(f, xs)    = [for (x = xs) f(x)];
function filter(f, xs) = [for (x = xs) if (f(x)) x];

function any(f, xs) = len(filter(f, xs)) > 0;
function all(f, xs) = len(filter(f, xs)) == len(xs);

function replicate(n, x) = n > 0 ? [for (i = [0 : n-1]) x] : [];

function reverse(xs) = let (l = len(xs)) l > 0 ? [for (i = [0 : l-1]) xs[l-i-1]] : [];

function flatten(xss) = [for (xs = xss) for (x = xs) x];

function zip(xs, ys) = let (l = min(len(xs), len(ys))) l > 0
  ? [for (i = [0 : l-1]) [xs[i], ys[i]]]
  : [];

function interleave(xs, ys) = let (l = min(len(xs), len(ys)))
  concat(flatten(zip(xs, ys)), drop(l, xs), drop(l, ys));

function sum(xs) = len(xs) > 0 ? xs * [for (_ = xs) 1] : 0;


/**************/
/* type tests */
/**************/

function is_def(x) = !is_undef(x);
function is_nan(x) = x != x;

function is_len   (n,    xs) = assert(is_num(n))                        is_list(xs) && len(xs) == n;
function is_of    (   f, xs) =                   assert(is_function(f)) is_list(xs)                 && all(f, xs);
function is_len_of(n, f, xs) = assert(is_num(n)) assert(is_function(f)) is_list(xs) && len(xs) == n && all(f, xs);

function is_bools        (   xs) = is_of    (   function(x) is_bool    (x), xs);
function is_nums         (   xs) = is_of    (   function(x) is_num     (x), xs);
function is_strings      (   xs) = is_of    (   function(x) is_string  (x), xs);
function is_lists        (   xs) = is_of    (   function(x) is_list    (x), xs);
function is_functions    (   xs) = is_of    (   function(x) is_function(x), xs);
function is_len_bools    (n, xs) = is_len_of(n, function(x) is_bool    (x), xs);
function is_len_nums     (n, xs) = is_len_of(n, function(x) is_num     (x), xs);
function is_len_strings  (n, xs) = is_len_of(n, function(x) is_string  (x), xs);
function is_len_lists    (n, xs) = is_len_of(n, function(x) is_list    (x), xs);
function is_len_functions(n, xs) = is_len_of(n, function(x) is_function(x), xs);


/********/
/* math */
/********/

// like `sign`, but
//   - also works on lists recursively
// TODO: extract this pattern as a function that takes a lambda, and use it everywhere it fits
function signum(xs) = is_num(xs) ? sign(xs) : is_list(xs) ? [for (x = xs) signum(x)] : undef;

// like `/`, but
//   - returns only the whole part of the result, excluding the remainder
function div(x, d) = floor(x/d);

// like `%`, but
//   - has consistent results between 0 and the divisor for dividends of any sign
function mod(x, d) = x - d*div(x, d);  // alternatively, mod(x, d) = (x%d + d)%d;

// often needed in distance calculations
// TODO: remove these and all references to them and switch to new syntax
function square(x) = x*x;
function cube(x) = x*x*x;

function _gcd(x, y) = y==0 ? x : _gcd(y, mod(x, y));
function gcd(x, y) = x==0 ? y : _gcd(x, y);
function lcm(x, y) = abs(x*y) / gcd(x, y);

function clamp(x, min, max) =
  assert(is_num(x))
  assert(is_num(min) && is_num(max) || is_len_nums(2, min) && is_undef(max))
  let ( low  = is_list(min) ? min[0] : min
      , high = is_list(min) ? min[1] : max
      )
  assert(low <= high)
  min(high, max(x, low));


/***********/
/* vectors */
/***********/

function angle_between(u, v) = acos((u*v)/(norm(u)*norm(v)));

// length of `u` projected on `v`
function norm_projection_of_on(u, v) = (u*v)/norm(v);

// vector of `u` projected on `v`
function projection_of_on(u, v) = ((u*v)/pow(norm(v), 2)) * v;


/************/
/* matrices */
/************/

function unit(v) =  v / norm(v);

function transpose(m) = [for (j = [0 : len(m[0])-1]) [for (i = [0 : len(m)-1]) m[i][j]]];

function identity(n) = [for (i = [0 : n-1]) [for (j = [0 : n-1]) i == j ? 1 : 0]];

function augment(n, m) = [for (i = [0 : n-1]) [for (j = [0 : n-1]) i < len(m) && j < len(m[i]) ? m[i][j] : i == j ? 1 : 0]];

// like the `translate()` module, but
//   - returns a matrix
//   - is unforgiving when given incomplete vectors
function translate(v) = augment(4,
  [ [1, 0, 0, v.x]
  , [0, 1, 0, v.y]
  , [0, 0, 1, v.z]
  ]);

function rotate_from_to(u, v) = let (uu = unit(u), uv = unit(v), uw = unit(cross(uu, uv)))
  uw*uw >= 0.99
    ? augment(4, transpose([uv, uw, cross(uw, uv)]) * [uu, uw, cross(uw, uu)])
    : epsilon_equals(uu, uv)
    ? identity(4)
    : undef;

function rotate_from(v) = rotate_from_to(v, [0,0,1]);
function rotate_to(v)   = rotate_from_to([0,0,1], v);

// like the `rotate()` module, but
//   - returns a matrix
//   - is unforgiving when given incomplete vectors
function rotate(a=0, v=[0,0,1]) = is_list(a)
  ? augment(4,
    [ [ cos(a.z), -sin(a.z),         0]
    , [ sin(a.z),  cos(a.z),         0]
    , [        0,         0,         1] ] *
    [ [ cos(a.y),         0,  sin(a.y)]
    , [        0,         1,         0]
    , [-sin(a.y),         0,  cos(a.y)] ] *
    [ [        1,         0,         0]
    , [        0,  cos(a.x), -sin(a.x)]
    , [        0,  sin(a.x),  cos(a.x)] ])
  : rotate_from_to([0,0,1], v) *
    augment(4,
    [ [cos(a), -sin(a)]
    , [sin(a),  cos(a)] ]) *
    rotate_from_to(v, [0,0,1]);

// like the `scale()` module, but
//   - returns a matrix
//   - is unforgiving when given incomplete vectors
function scale(v) = augment(4,
  [ [v.x,   0,   0]
  , [  0, v.y,   0]
  , [  0,   0, v.z] ]);

function shear(zX=0, zY=0, yZ=0, yX=0, xY=0, xZ=0, z, y, x) = let
  ( zx = is_list(z) && len(z) == 2 && is_num(z[0]) && is_num(z[1]) ? z[0] : zX
  , zy = is_list(z) && len(z) == 2 && is_num(z[0]) && is_num(z[1]) ? z[1] : zY
  , yz = is_list(y) && len(y) == 2 && is_num(y[0]) && is_num(y[1]) ? y[0] : yZ
  , yx = is_list(y) && len(y) == 2 && is_num(y[0]) && is_num(y[1]) ? y[1] : yX
  , xy = is_list(x) && len(x) == 2 && is_num(x[0]) && is_num(x[1]) ? x[0] : xY
  , xz = is_list(x) && len(x) == 2 && is_num(x[0]) && is_num(x[1]) ? x[1] : xZ
  )
  augment(4,
  [ [ 1, yx, zx]
  , [xy,  1, zy]
  , [xz, yz,  1] ]);

// multiply an array of matrices together, from index start to index end if given
function multmatrices(ms, prod=identity(4), start=0, end=undef)
  = start >= len(ms) || (is_num(end) && start >= end) ? prod
  : multmatrices(ms, prod*ms[start], start+1, end);

// old
// function multmatrices(ms, i=0, prod=identity(4)) = i >= len(ms) ? prod : multmatrices(ms, i+1, prod*ms[i]);

// // memoization attempt (doesn't work)
// // is memoization even compatible with tail recursion?
// function _multmatrices(ms, prod, start, end)
//   = start >= end ? prod
//   : _multmatrices(ms, ms[end-1]*prod, start, end-1);
// function multmatrices(ms, prod=identity(4), start=0, end=undef) = _multmatrices(ms, prod, start, is_num(end)?end:len(ms));

// // example:
// rot1   = [ 30,  0,  0 ];
// tran   = [  0,  0,  5 ];
// rot2   = [  0, 30,  0 ];
// size   = [  5,  5,  5 ];
// center = [  0,  0,  0 ];
// translate([-10, 0, 0])
//   rotate(rot2) translate(tran) rotate(rot1)
//     box(size, center);
// translate([0, 0, 0])
//   multmatrix(rotate(rot2) * translate(tran) * rotate(rot1))
//     box(size, center);
// translate([10, 0, 0])
//   multmatrix(multmatrices([rotate(rot2), translate(tran), rotate(rot1)]))
//     box(size, center);


/*******************/
/* transformations */
/*******************/

// like `mirror()`, but
//   - copies by default
module flip(v=[1, 0, 0], copy=true) {
  if (copy) children();
  mirror(v) children();
}

module flipX(copy=true) flip([1, 0, 0], copy) children();
module flipY(copy=true) flip([0, 1, 0], copy) children();
module flipZ(copy=true) flip([0, 0, 1], copy) children();


// translate & hull
module tull(v, center=false, flip=false) hull() {
  translate(center ? -v/2 : v*0) children();
  translate(center ?  v/2 : v*1)
    if (flip) mirror(v) children();
    else children();
}

// rotational array
//         -    +
//         321012
// n =  3  ...xxx
// n =  2  ...xx.
// n =  1  ...x..
// n =  0  ......
// n = -1  ..x...
// n = -2  .xx...
// n = -3  xxx...
module ring(n, a, v, start, end) {
  n = is_undef(n) ? $children : n;
  a = is_undef(a) ? 360/n : a;
  start = is_undef(start) ? min(n, 0) : start;
  end = is_undef(end) ? max(n-1, -1) : end;
  if (n != 0 && $children > 0)
    for (i = [start:end]) rotate(i*a, v) children(mod(i, $children));
}

// rotate about tv instead of the origin
// module rotate_about(tv=[0, 0, 0], a=0, rv=[0, 0, 1])
module rotate_about(tv, a, rv) translate(tv) rotate(a, rv) translate(-tv) children();

// rotate from u to v
module rotate_from_to(u, v) multmatrix(rotate_from_to(u, v)) children();

// rotate from v to [0,0,1]
module rotate_from(v) multmatrix(rotate_from(v)) children();

// rotate from [0,0,1] to v
module rotate_to(v) multmatrix(rotate_to(v)) children();

module shear(zX=0, zY=0, yZ=0, yX=0, xY=0, xZ=0, z, y, x) multmatrix(shear(zX, zY, yZ, yX, xY, xZ, z, y, x)) children();


/**********************/
/* circles & ellipses */
/**********************/

// number of fragments a circle of radius `r` or diameter `d` would have given current settings,
// rounded down to the nearest multiple of `base` if is given.
function fragments(r, d, base=1) = let (r = is_num(d) ? d/2 : r)
  $fn > 0     ? base*div($fn >= 3 ? $fn : 3, base) :
  is_undef(r) ? undef :
                base*div(ceil(max(min(360/$fa, r*2*PI/$fs), 5)), base);

// smallest radius of an OpenSCAD circle (or arbitrary polygon if `segments` is given) that fits
// fully around a perfect circle of radius `r` or diameter `d`.
function circumgoncircumradius(r=1, d, segments) = let (r = is_num(d) ? d/2 : r)
  r / cos(180 / (is_num(segments) ? segments : fragments(r)));

// smallest diameter of an OpenSCAD circle (or arbitrary polygon if `segments` is given) that fits
// fully around a perfect circle of radius `r` or diameter `d`.
function circumgoncircumdiameter(r=1, d, segments) = 2*circumgoncircumradius(r, d, segments);

// largest radius of a perfect circle that fits fully inside an OpenSCAD circle (or arbitrary
// polygon if `segments` is given) of radius `r` or diameter `d`.
function ingoninradius(r=1, d, segments) = let (r = is_num(d) ? d/2 : r)
  r * cos(180 / (is_num(segments) ? segments : fragments(r)));

// largest radius of a perfect circle that fits fully inside an OpenSCAD circle (or arbitrary
// polygon if `segments` is given) of radius `r` or diameter `d`.
function ingonindiameter(r=1, d, segments) = 2*ingoninradius(r, d, segments);

function point_on_ellipse(theta, a, b, size=[2,2]) =
  let ( phi = mod(theta, 360)
      , A   = (is_num(a) ? a : size.x/2)
      , B   = (is_num(b) ? b : size.y/2)
      )
  phi ==  90 ? [0,  B] :
  phi == 270 ? [0, -B] :
    [ (phi < 90 || 270 < phi ? 1 : -1) * (A*B / sqrt(A*A*tan(theta)*tan(theta) + B*B))
    , (phi < 90 || 270 < phi ? 1 : -1) * (A*B / sqrt(A*A*tan(theta)*tan(theta) + B*B)) * tan(theta)
    ];


/***************/
/* 2D geometry */
/***************/

// like `circle()`, but
//   - less so
// NOTE: `a` is either
//   - a number specifying the arc length in degrees
//   - a list of two numbers specifying the start and end angles in degrees
// TODO: add an r1, r2, d1, and d2 (or inner and outer????) To do full circles, call self for the
//   difference. Otherwise, draw the second arc in reverse order, and do not draw the center point.
module arc(r=1, a=360, d, segments, outer=false) {
                           assert(is_num(r)        && r >= 0);
                           assert(is_num(a) || is_len_nums(2, a));
  if (!is_undef(d))        assert(is_num(d)        && d >= 0);
  if (!is_undef(segments)) assert(is_num(segments) && segments >= 1);
  if (!is_undef(outer))    assert(is_bool(outer));
  A = is_list(a) ? a[0] : 0;
  arcL = clamp(is_list(a) ? a[1]-a[0] : a, -360, 360);
  if (arcL != 0) {
    r = is_num(d) ? d/2 : r;
    fn = fragments(r);
    segs = floor(is_num(segments) ? segments : max(1, abs(arcL)*fn/360));
    segA = arcL / segs;
    R = outer ? circumgoncircumradius(r, segments=segs*360/arcL) : r;
    polygon(concat
      ( abs(arcL) == 360 ? [] : [ [0, 0] ]
      , [ for (i = [0 : segs]) [R*cos(segA*i+A), R*sin(segA*i+A)] ]
      ));
  }
}

// like `square()`, but
//   - works with negative dimensions
//   - centers or +/- aligns each axis individually
//     -   -1: left   0: center   1: right
//   - optional rounded corners
// TODO: figure out an interface for selecting which corners to round and which sides to teardrop
// TODO: typecheck parameters
// TODO: allow a 2-digit number for align (save 5 characters potentially)
module rect(size=[1,1], align=[1,1], r=0) {
  if (r==0) { if (all(function (x) x!=0, size)) scale(size) translate(signum(align)/2-[.5,.5]) square(); }
  else {
    translate([align.x*r, 0]) rect(size-[r*2, 0], align);
    translate([0, align.y*r]) rect(size-[0, r*2], align);
    translate([align.x*size.x, align.y*size.y]/2) flipX() flipY() translate(size/2-[r,r]) circle(r, $fn=fragments(r, base=4));
  }
}

// fillets a polygon with radius `r` or diameter `d`; outer if positive, inner if negative
// TODO: probably better to add `!is_undef()` to every parameter, then assert at least one
//   argument is given for each type of parameter
module fillet(r=1) {
  assert(is_num(r));
  offset(r) offset(-r) children();
}

// like `circle()`, but
//   - has a peak tangent at `a` or of length `peak`
// TODO: probably better to add `!is_undef()` to every parameter, then assert at least one
//   argument is given for each type of parameter
module teardrop(r=1, a=45, d, peak, truncate) {
                           assert(is_num(r)    && r > 0);
                           assert(is_num(a)    && a >= 0 && a < 90);
  if (!is_undef(d))        assert(is_num(d)    && d > 0);
  if (!is_undef(peak))     assert(is_num(peak) && peak >= r);
  if (!is_undef(truncate)) assert(is_num(truncate));
  r = is_num(d) ? d/2 : r;
  a = is_num(peak) ? max(0, acos(r/peak)) : a;
  peak = is_num(peak) ? peak : r/cos(a);
  intersection() {
    hull() {
      rotate(90) circle(r);
      polygon(
        [ [-r*sin(a), r*cos(a)]
        , [ 0       , peak    ]
        , [ r*sin(a), r*cos(a)]
        ]);
    }
    if (is_num(truncate)) translate([0, -r]) rect([r*2, r+truncate], [0,1]);
  }
}


/***************/
/* 3D geometry */
/***************/

// like `sphere()`, but
//   - has vertices at the poles and along the equator
// TODO: give `revolve()` a `w` and `h` just in case someone wants a huge sphere
// TODO: revolve() an arc() instead to allow shells
module ball(r=1, d) {
                    assert(is_num(r) && r > 0);
  if (!is_undef(d)) assert(is_num(d) && d > 0);
  r = is_num(d) ? d/2 : r;
  fn = fragments(r, base=4);
  revolve($fn=fn) circle(r, $fn=fn);
}

// like `cube()`, but
//   - works with negative dimensions
//   - centers and +/- aligns each axis individually
//     -   -1: left   0: center   1: right
//   - optional rounded edges
// TODO: figure out an interface for selecting which edges to round and which faces to teardrop
// TODO: typecheck parameters
// TODO: allow a 3-digit number for align (save 7 characters potentially)
module box(size=[1,1,1], align=[1,1,1], r=0)
  if (r==0) { if (all(function (x) x!=0, size)) scale(size) translate(signum(align)/2-[.5,.5,.5]) cube(); }
  else {
    translate([0, 0, align.z*size.z/2]) rotate([  0,  0, 0]) extrude(size.z-r*2, center=true) rect([size.x, size.y], [align.x, align.y], r);
    translate([0, align.y*size.y/2, 0]) rotate([ 90,  0, 0]) extrude(size.y-r*2, center=true) rect([size.x, size.z], [align.x, align.z], r);
    translate([align.x*size.x/2, 0, 0]) rotate([  0,-90, 0]) extrude(size.x-r*2, center=true) rect([size.z, size.y], [align.z, align.y], r);
    translate([align.x*size.x, align.y*size.y, align.z*size.z]/2) flipX() flipY() flipZ() translate(size/2-[r,r,r]) ball(r);
  }

// like `cylinder()`, but
//   - works with negative height
// TODO: linear_extrude() an arc() instead; calculate scale from r1/r2 etc
module rod(h=1, r1, r2, r, d1, d2, d, center) {
  assert(is_num(h));
  scale([1,1,sign(h)])
    cylinder(h=abs(h), r1=r1, r2=r2, r=r, d1=d1, d2=d2, d=d, center=center);
}

// like `cylinder()`, but
//   - works with negative height
//   - has a hole
// TODO: probably better to add `!is_undef()` to every parameter, then assert at least one
//   argument is given for each type of parameter
// TODO: linear_extrude() an arc() instead; calculate scale from r1/r2 etc
module tube(h=1, outerR1=1, outerR2=1, innerR1=0.5, innerR2=0.5, outerR, innerR, outerD1, outerD2, innerD1, innerD2, outerD, innerD, center=false) {
                          assert(is_num(h));  // && h != 0);
                          assert(is_num(outerR1) && outerR1 >= 0);
                          assert(is_num(outerR2) && outerR2 >= 0);
                          assert(is_num(innerR1) && innerR1 >= 0);
                          assert(is_num(innerR2) && innerR2 >= 0);
                          assert(is_bool(center));
  if (!is_undef(outerR))  assert(is_num(outerR)  && outerR  >= 0);
  if (!is_undef(innerR))  assert(is_num(innerR)  && innerR  >= 0);
  if (!is_undef(outerD2)) assert(is_num(outerD1) && outerD1 >= 0);
  if (!is_undef(outerD2)) assert(is_num(outerD2) && outerD2 >= 0);
  if (!is_undef(innerD1)) assert(is_num(innerD1) && innerD1 >= 0);
  if (!is_undef(innerD2)) assert(is_num(innerD2) && innerD2 >= 0);
  if (!is_undef(outerD))  assert(is_num(outerD)  && outerD  >= 0);
  if (!is_undef(innerD))  assert(is_num(innerD)  && innerD  >= 0);
  // this might not have the same precedence as the built in `cylinder()`
  outerR1 = is_num(outerD) ? outerD/2 : is_num(outerR) ? outerR : is_num(outerD1) ? outerD1/2 : outerR1;
  outerR2 = is_num(outerD) ? outerD/2 : is_num(outerR) ? outerR : is_num(outerD2) ? outerD2/2 : outerR2;
  innerR1 = is_num(innerD) ? innerD/2 : is_num(innerR) ? innerR : is_num(innerD1) ? innerD1/2 : innerR1;
  innerR2 = is_num(innerD) ? innerD/2 : is_num(innerR) ? innerR : is_num(innerD2) ? innerD2/2 : innerR2;
  render(convexity=2)
    scale([1,1,sign(h)])
      difference() {
        cylinder(abs(h), r1=outerR1, r2=outerR2, center=center);
        cylinder(abs(h), r1=innerR1, r2=innerR2, center=center);
      }
}

// like `cylinder()`, but
//   - has tapered ends
// NOTE: negative `h` is degenerate
// TODO: probably better to add `!is_undef()` to every parameter, then assert at least one
//   argument is given for each type of parameter
module spindle(h=1, r1=1, r2=1, a1=45, a2=45, r, a, d1, d2, d, p1, p2, p, center=false) {
                     assert(is_num(h));
                     assert(is_num(r1) && r1 >= 0);
                     assert(is_num(r2) && r2 >= 0);
                     assert(is_num(a1) && a1 >= 0 && a1 < 90);
                     assert(is_num(a2) && a2 >= 0 && a2 < 90);
                     assert(is_bool(center));
  if (!is_undef(r))  assert(is_num(r)  && r  >= 0);
  if (!is_undef(a))  assert(is_num(a)  && a  >= 0 && a  < 90);
  if (!is_undef(d1)) assert(is_num(d1) && d1 >= 0);
  if (!is_undef(d2)) assert(is_num(d2) && d2 >= 0);
  if (!is_undef(d))  assert(is_num(d)  && d  >= 0);
  if (!is_undef(p1)) assert(is_num(p1) && p1 >= 0);
  if (!is_undef(p2)) assert(is_num(p2) && p2 >= 0);
  if (!is_undef(p))  assert(is_num(p)  && p  >= 0);
  // this might not have the same precedence as the built in `cylinder()`
  r1 = is_num(d) ? d/2 : is_num(r) ? r : is_num(d1) ? d1/2 : r1;
  r2 = is_num(d) ? d/2 : is_num(r) ? r : is_num(d2) ? d2/2 : r2;
  a1 = is_num(a) ? a : a1;
  a2 = is_num(a) ? a : a2;
  p1 = is_num(p) ? p : is_num(p1) ? p1 : tan(a1) * r1;
  p2 = is_num(p) ? p : is_num(p2) ? p2 : tan(a2) * r2;
  fn = (fragments(max(r1, r2)));
  hull()
    translate([0, 0, center?-h/2:0]) {
      translate([0, 0, -p1]) cylinder(p1, r1=0,  r2=r1, $fn=fn);
      translate([0, 0,  0 ]) cylinder(h,  r1=r1, r2=r2, $fn=fn);
      translate([0, 0,  h ]) cylinder(p2, r1=r2, r2=0,  $fn=fn);
    }
}

// like `cube()`, but
//   - not a cube
module octahedron(r=1, d) spindle(h=0, r=r, d=d, $fn=4);

// cylinder of radius `r` aligned with vector `v`
module line_segment(v, r=0.5)
  let (l = norm(v))
    rotate([0, acos(v.z/l), atan2(v.y, v.x)])
      cylinder(h=l, r=r);

// like `linear_extrude()`, but
//   - allows negative heights
//   - has less options
module extrude(h=1, center=false, convexity=1, scale=[1,1])
  scale([1,1,sign(h)])
    linear_extrude(abs(h), center=center, convexity=convexity, slices=0, scale=scale)
      children();

// like `linear_extrude()`, but
//   - fillets instead of twists
// TODO: probably better to add `!is_undef()` to every parameter, then assert at least one
//   argument is given for each type of parameter
module inflate(h, r=0, fillet, center, convexity) {
  if (!is_undef(h))         assert(is_num(h)         && h > 0);
                            assert(is_num(r)         && r >= 0);
  if (!is_undef(fillet))    assert(is_num(fillet)    && fillet >= 0);
  if (!is_undef(center))    assert(is_bool(center));
  if (!is_undef(convexity)) assert(is_num(convexity) && convexity > 0);
  outerR = r;
  innerR = is_num(fillet) ? fillet : outerR;
  minkowski() {
    linear_extrude(h, center=center, convexity=convexity, slices=0)
      offset(-(outerR+innerR)) offset(innerR) children();
    sphere(circumgoncircumradius(outerR));
  }
}

// like `rotate_extrude()`, but
//   - strips negative x coordinates (by default)
//   - allows negative x coordinates (if trim=false)
//   - `angle` is called `a`, like every other module
// TODO: figure out TODOs
module revolve(a=360, convexity=1, trim=true, w=10000, h=10000) {
  rotate_extrude(angle=a, convexity=convexity) intersection() {
    children();
    rect([w, h], [1,0]);
  }
  if (!trim) rotate_extrude(angle=a, convexity=convexity) difference() {
    children();
    rect([w, h], [1,0]);
  }
}

// like `rotate_extrude()`, but
//   - sweeps convex polygons around an ellipse
//   - x=0 becomes the rim of the ellipse rather than the center of rotation
// NOTE:
//   - each child should be a convext polygon
//   - the union of children should contain [0,0], ideally away from any edges
//   - use the `translate` parameter to compensate for this restriction
// NOTE: `a` is either
//   - a number specifying the arc length in degrees
//   - a list of two numbers specifying the start and end angles in degrees
// NOTE: `fudge` is either
//   - a number specifying the amount to extend each end
//   - a list of two numbers specifying the amounts to extend the start and end
// NOTE: these segments may not need to overlap since the vertices should line up exactly. However,
//   they are made to by a tiny amount just in case. If it isn't enough, `fDef` may need to be
//   increased to something proportional to `norm([RX*c, RY*s] - [RX*C, RY*S])*fn/360`.
module orbit(a=360, r=1, d, rX, rY, dX, dY, segments, translate=[0,0], fudge) {
                           assert(is_len_nums(2, a) || is_num(a));
                           assert(is_num(r)        && r  >= 0);
  if (!is_undef(d))        assert(is_num(d)        && d  >= 0);
  if (!is_undef(rX))       assert(is_num(rX)       && rX >= 0);
  if (!is_undef(rY))       assert(is_num(rY)       && rY >= 0);
  if (!is_undef(dX))       assert(is_num(dX)       && dX >= 0);
  if (!is_undef(dY))       assert(is_num(dY)       && dY >= 0);
  if (!is_undef(segments)) assert(is_num(segments) && segments >= 1);
                           assert(is_len_nums(2, translate));
  if (!is_undef(fudge))    assert(is_len_nums(2, fudge) || is_num(fudge));
  A = is_list(a) ? a[0] : 0;
  arcL = clamp(is_list(a) ? a[1]-a[0] : a, -360, 360);
  fDef = signum(arcL)/100;
  f = is_list(fudge) ? [max(0, fudge[0]), max(0, fudge[1])]*signum(arcL)
    : is_num(fudge)  ? [max(0, fudge   ), max(0, fudge   )]*signum(arcL)
    :                  [    0           ,     0           ];
  fBeg = f[0] != 0;
  fEnd = f[1] != 0;
  if (arcL != 0 && $children > 0) {
    RX = is_num(rX) ? rX : is_num(dX) ? dX/2 : is_num(d) ? d/2 : r;
    RY = is_num(rY) ? rY : is_num(dY) ? dY/2 : is_num(d) ? d/2 : r;
    fn = fragments(max(RX, RY));
    segs = floor(is_num(segments) ? segments : max(1, abs(arcL)*fn/360));
    segA = arcL / segs;
    for (i = [0 : segs-1]) for (j = [0 : $children-1]) {
      s = sin(A+segA*i     );
      c = cos(A+segA*i     );
      S = sin(A+segA*i+segA);
      C = cos(A+segA*i+segA);
      beg = abs(arcL) != 360 && i == 0;
      end = abs(arcL) != 360 && i == segs-1;
      hull() {
        translate([RX*c, RY*s, 0]) rotate([90, 0, atan2(RY*c, -RX*s)-90]) translate(translate) extrude(fDef*(beg && !fBeg ? -1 :  1), scale=0) children(j);
        translate([RX*C, RY*S, 0]) rotate([90, 0, atan2(RY*C, -RX*S)-90]) translate(translate) extrude(fDef*(end && !fEnd ?  1 : -1), scale=0) children(j);
      }
      if (beg && fBeg) translate([RX*c, RY*s, 0]) rotate([90, 0, atan2(RY*c, -RX*s)-90]) translate(translate) extrude( f[0], scale=1) children(j);
      if (end && fEnd) translate([RX*C, RY*S, 0]) rotate([90, 0, atan2(RY*C, -RX*S)-90]) translate(translate) extrude(-f[1], scale=1) children(j);
    }
  }
}

// // examples:
// orbit(a=[0, 90], rX=50, rY=100, translate=[20,10], fudge=[1, 1], $fn=36) teardrop(5, $fn=16);
// orbit(a=[30, -270], rX=50, rY=100, fudge=[50, 1], $fn=32) teardrop(5, $fn=16);


// like `rotate_extrude()`, but
//   - revolves 3D geometry
// NOTE: `a` is either
//   - a number specifying the arc length in degrees
//   - a list of two numbers specifying the start and end angles in degrees
// NOTE: `r` and `d` are only for autocalculating fragments. Somehow `rotate_extrude()` does this
//   automatically. If `$fn` is set, `r` and `d` are ignored. If `segments` is set, it overrides
//   everything else.
module hull_rotate_extrude(a=360, r, d, segments) {
                           assert(is_len_nums(2, a) || is_num(a));
  if (!is_undef(r))        assert(is_num(r)        && r >= 0);
  if (!is_undef(d))        assert(is_num(d)        && d >= 0);
  if (!is_undef(segments)) assert(is_num(segments) && segments >= 1);
  assert(!is_undef(r) || !is_undef(d) || !is_undef(segments) || $fn > 0);
  A = is_list(a) ? a[0] : 0;
  arcL = clamp(is_list(a) ? a[1]-a[0] : a, -360, 360);
  if (arcL != 0 && $children > 0) {
    r = is_num(d) ? d/2 : r;
    fn = fragments(r);
    segs = floor(is_num(segments) ? segments : max(1, abs(arcL)*fn/360));
    segA = arcL / segs;
    for (i = [0 : segs-1]) for (j = [0 : $children-1]) hull() {
      rotate(A+segA*(i  )) children(j);
      rotate(A+segA*(i+1)) children(j);
    }
  }
}

// // examples:
// hull_rotate_extrude([15, 255], r=25, segments=15.4) translate([25, 0, 0]) sphere(10);
// hull_rotate_extrude(45, $fn=60) translate([25, 0, 0]) tull([100, 0, 0]) rotate(45) spindle(0, r=10, $fn=4);

// // crazy ring thing:
// hull_rotate_extrude(360, segments=8) rotate_from([1,1,1]) translate([25, 0, 0]) spindle(10, $fn=4);


// could be useful for fillets
module top(r=1)
  rotate_extrude()
  difference() {
    rect([r, r*2], [1,0]);
    flipY() translate([r, r]) circle(r);
  }


/***************/
/* 3D printing */
/***************/

module slice(layerH0, layerHN, minL, maxL, minH, maxH, size, align=[0,0]) {
  minL = is_num(minH) ? (minH<layerH0 ? 0 : div(minH-layerH0, layerHN) + 1) : max(0, minL);
  maxL = is_num(maxH) ? (maxH<layerH0 ? 0 : div(maxH-layerH0, layerHN) + 1) : max(0, maxL);
  function layerFloor(l) = l<1 ? 0 : layerH0 + (l-1)*layerHN;
  function layerMid(l) = l<1 ? layerH0/2 : layerH0 + (l-1)*layerHN + layerHN/2;
  if (minL <= maxL) {
    if ($children>0)
      for (i = [minL : maxL])
        translate([0, 0, layerFloor(i)])
          extrude(i==0 ? layerH0 : layerHN)
            projection(cut=true)
              translate([0, 0, -layerMid(i)])
                children();
    if (is_list(size))
      for (i = [minL : maxL+1])
        translate([0, 0, layerFloor(i)])
          extrude(len(size)>2 ? size[2] : layerHN/10, center=true)
            rect(size, align);
  }
}

// float layer -> float height
function layer_relative_height(l, layerHN) =
  layerHN*l;

// float layer -> float position
function layer_absolute_height(l, layerHN, layerH0) =
  l<=0 ? 0 :
  l<=1 ? layerH0*l :
  layerH0 + layer_relative_height(l-1, layerHN);

// float height -> snap height
function floor_relative_height_layer(h, layerHN) = div(h, layerHN)*layerHN;
function  ceil_relative_height_layer(h, layerHN) = floor_relative_height_layer(h, layerHN)
                                                 + (mod(h, layerHN)==0 ? 0 : layerHN);
function round_relative_height_layer(h, layerHN) =
  let ( f =  floor_relative_height_layer(h, layerHN)
      , c =   ceil_relative_height_layer(h, layerHN)
      )
  h-f < c-h ? f : c;

// float position -> snap position
function floor_absolute_height_layer(z, layerHN, layerH0) = max(0, div(z-layerH0, layerHN)*layerHN + layerH0);
function  ceil_absolute_height_layer(z, layerHN, layerH0) = floor_absolute_height_layer(z, layerHN, layerH0)
                                                          + (mod(z-layerH0, layerHN)==0 ? 0 : z<layerH0 ? layerH0 : layerHN);
function round_absolute_height_layer(z, layerHN, layerH0) =
  let ( f =  floor_absolute_height_layer(z, layerHN, layerH0)
      , c =   ceil_absolute_height_layer(z, layerHN, layerH0)
      )
  z-f < c-z ? f : c;


/*********/
/* bolts */
/*********/

//                         m2          m2.5        m3          m4          m5          m6
// thread width            1.90        2.45        2.90   3.75-3.9        4.85        5.85
// button head height                              1.70
// button head width                               5.70
// socket head height   1.8-2.0        2.45     2.9-3.0     3.9-4.0    4.9-5.0     5.8-5.9
// socket head width    3.5-3.8        4.35     5.0-5.5         6.9        8.4     9.8-9.9
// nut height               1.60                   2.30        3.00       3.90        4.75
// nut sides                3.90                   5.40        6.80       7.75        9.75
// nut points               4.30                   5.95        7.60       8.75       11.05
// locknut height           2.90                   3.90        4.90       4.85        5.95
// locknut sides            3.95                   5.40        6.85       7.85        9.90
// locknut points           4.40                   6.00        7.55       8.85       11.05
// washer height             .40                    .55         .85        .85        1.20
// washer width             5.00                   7.05        9.00      10.05       12.10

function m_thread_width(m)       = m;
function m_button_head_height(m) = m-1;        // GUESSING!!!
function m_button_head_width(m)  = 1.5*m+1.5;  // GUESSING!!!
function m_socket_head_height(m) = m;
function m_socket_head_width(m)  = m<12 ? 1.5*m+1 : 1.5*m;
function m_nut_height(m)         = 0.8*m;
function m_nut_spanner(m)        = m<3 ? 2*m : m<5 ? 1.5*m+1 : m<8 ? 2*m-2 : m<12 ? 1.5*m+1 : m<30 ? 1.5*m : undef;
function m_nut_width(m)          = 1.1547*m_nut_spanner(m);
function m_locknut_height(m)     = m<5 ? m+0.9 : m-0.1;
function m_washer_height(m)      = 0.2*m;
function m_washer_width(m)       = m<5 ? 2*m+1 : 2*m;

// grip = 0.2;
gripA = 0.02;  // as in f(x) = ax + b
gripB = 0.04;

// .35mm clearance is enough for tool-free insertion after minor cleanup
// m3 measured at at 2.90 fits 3.25 hole, 3.125 hole needs drilling
slack = 0.5;

function m_adjusted_thread_width(m, grip=undef, gripA=gripA, gripB=gripB) = m_thread_width(m) - (grip?0:gripA?gripA:0)*m - (grip?grip:gripB?gripB:0);
function m_adjusted_shank_width(m, slack=slack)       = circumgoncircumdiameter(d=m_thread_width(m)+slack);
function m_adjusted_button_head_width(m, slack=slack) = circumgoncircumdiameter(d=m_button_head_width(m)+slack);
function m_adjusted_socket_head_width(m, slack=slack) = circumgoncircumdiameter(d=m_socket_head_width(m)+slack);
function m_adjusted_washer_width(m, slack=slack)      = circumgoncircumdiameter(d=m_washer_width(m)+slack);

// echo(m_adjusted_thread_width(2));
// echo(m_adjusted_thread_width(2.5));
// echo(m_adjusted_thread_width(3));
// echo(m_adjusted_thread_width(4));
// echo(m_adjusted_thread_width(5));
// echo(m_adjusted_thread_width(6));
// echo(m_adjusted_thread_width(8));
// echo(mm(3/8));
// echo(m_adjusted_thread_width(mm(3/8)));

module m_bolt_threads(m, depth=0, height=0, grip=undef, gripA=gripA, gripB=gripB)
  if (depth > 0) translate([0,0,height]) rod(-depth-height-epsilon, d=m_adjusted_thread_width(m, grip, gripA, gripB));

module m_bolt_shank(m, shank=0, height=0, slack=slack)
  if (shank > 0) translate([0,0,height]) rod(-shank-height-epsilon, d=m_adjusted_shank_width(m, slack));

module m_bolt_nut(m, nut=undef, taper=0) {
  d = m_nut_width(m);
  if (taper == 0) {
    if (is_num(nut)) translate([0, 0, -nut]) rod(-m_nut_height(m), d=d, $fn=6);
    if (is_list(nut)) translate([0, 0, -min(nut[0], nut[1])]) rod(-abs(nut[1]-nut[0]), d=d, $fn=6);
  }
  else {
    e = m/3;
    h = (d/2 - e)*tan(taper);
    if (is_num(nut)) translate([0, 0, -nut]) hull() {
      rod(-m_nut_height(m), d=d, $fn=6);
      rod(h, r=e, $fn=6);
    }
    if (is_list(nut)) translate([0, 0, -min(nut[0], nut[1])]) hull() {
      rod(-abs(nut[1]-nut[0]), d=d, $fn=6);
      rod(h, r=e, $fn=6);
    }
  }
}

module m_bolt_button(m, button=0, slack=slack, taper=0) if (button > 0) {
  d = m_adjusted_button_head_width(m, slack);
  if (taper == 0) rod(button, d=d);
  else {
    e = m/3;
    h = (d/2 - e)*tan(taper);
    hull() {
      rod(button, d=d);
      rod(-h, r=e);
    }
  }
}

module m_bolt_socket(m, socket=0, slack=slack, taper=0) if (socket > 0) {
  d = m_adjusted_socket_head_width(m, slack);
  if (taper == 0) rod(socket, d=d);
  else {
    e = m/3;
    h = (d/2 - e)*tan(taper);
    hull() {
      rod(socket, d=d);
      rod(-h, r=e);
    }
  }
}

module m_bolt_washer(m, washer=0, slack=slack, taper=0) if (washer > 0) {
  d = m_adjusted_washer_width(m, slack);
  if (taper == 0) rod(washer, d=d);
  else {
    e = m/3;
    h = (d/2 - e)*tan(taper);
    hull() {
      rod(washer, d=d);
      rod(-h, r=e);
    }
  }
}

// module m_bolt(m, depth=0, shank=0, nut, button=0, socket=0, $fn=24) {
//   if (depth > 0) translate([0, 0, -depth]) cylinder(depth+1, d=m_thread_width(m)-.2);
//   if (shank > 0) translate([0, 0, -shank]) cylinder(shank+1, d=circumgoncircumdiameter(d=m_thread_width(m)+.25));
//   if (is_num(nut)) translate([0, 0, -nut-m_nut_height(m)]) cylinder(m_nut_height(m), d=m_nut_width(m)+.1, $fn=6);
//   if (is_list(nut)) translate([0, 0, -nut[1]]) cylinder(nut[1]-nut[0], d=m_nut_width(m)+.1, $fn=6);
//   if (button > 0) cylinder(button, d=circumgoncircumdiameter(d=m_button_head_width(m)+.25));
//   if (socket > 0) cylinder(socket, d=circumgoncircumdiameter(d=m_socket_head_width(m)+.25));
// }

module m_bolt(m, depth=0, shank=0, nut=undef, button=0, socket=0, washer=0, width=0, height=0, grip=undef, gripA=gripA, gripB=gripB, slack=slack, taper=0) {
  if (width == 0 && height == 0) {
    m_bolt_threads(m, depth, max(button, socket, washer), grip, gripA, gripB);
    m_bolt_shank(m, shank, max(button, socket, washer), slack);
    m_bolt_nut(m, nut, taper);
    m_bolt_button(m, button, slack, taper);
    m_bolt_socket(m, socket, slack, taper);
    m_bolt_washer(m, washer, slack, taper);
  } else {
    hull() {
      m_bolt_threads(m, depth, max(button, socket, washer), grip, gripA, gripB);
      translate([width, height, 0]) m_bolt_threads(m, depth, max(button, socket, washer), grip, gripA, gripB);
    }
    hull() {
      m_bolt_shank(m, shank, max(button, socket, washer), slack);
      translate([width, height, 0]) m_bolt_shank(m, shank, max(button, socket, washer), slack);
    }
    hull() {
      m_bolt_nut(m, nut, taper);
      translate([width, height, 0]) m_bolt_nut(m, nut, taper);
    }
    hull() {
      m_bolt_button(m, button, slack, taper);
      translate([width, height, 0]) m_bolt_button(m, button, slack, taper);
    }
    hull() {
      m_bolt_socket(m, socket, slack, taper);
      translate([width, height, 0]) m_bolt_socket(m, socket, slack, taper);
    }
    hull() {
      m_bolt_washer(m, washer, slack, taper);
      translate([width, height, 0]) m_bolt_washer(m, washer, slack, taper);
    }
  }
}

// module m3(depth=0, shank=0, nut=undef, button=0, socket=0, $fn=36) {
//   if (depth > 0) translate([0, 0, -depth]) cylinder(depth+1, d=2.75);
//   if (shank > 0) translate([0, 0, -shank]) cylinder(shank+1, d=3.25);
//   if (is_num(nut)) translate([0, 0, -nut-2.2]) cylinder(2.2, d=6.25, $fn=6);
//   if (is_list(nut)) translate([0, 0, -nut[1]]) cylinder(nut[1]-nut[0], d=6.25, $fn=6);
//   if (button > 0) cylinder(button, d=6.15);
//   if (socket > 0) cylinder(socket, d=5.45);
// }
//
// module m3_slot(depth=0, button=0, socket=0, width=0, $fn=36) {
//   if (depth > 0) translate([0, 0, -depth]) cylinder(depth+1, d=3.25);
//   if (button > 0) cylinder(button, d=6.15);
//   if (socket > 0) cylinder(socket, d=5.45);
//   if (width > 0) {
//     if (depth > 0) {
//       translate([width, 0, -depth]) cylinder(depth+1, d=3.25);
//       translate([0, -1.625, -depth]) cube([width, 3.25, depth+1]);
//     }
//     if (button > 0) {
//       translate([width, 0, 0]) cylinder(button, d=6.15);
//       translate([0, -3.075, 0]) cube([width, 6.15, button]);
//     }
//     if (button > 0) {
//       translate([width, 0, 0]) cylinder(button, d=5.45);
//       translate([0, -2.725, 0]) cube([width, 5.45, button]);
//     }
//   }
// }


/***********/
/* garbage */
/***********/

function r90(v) = [v[1], -v[0]];
function l90(v) = [-v[1], v[0]];

module line_segment_2d(start, direction, length, thickness)
  polygon(points=[
    start,
    start + thickness,
    start + length*direction + thickness,
    start + length*direction,
  ]);

module panel(start, direction, length, height, thickness)
  linear_extrude(height=height, slices=0)
    line(start, direction, length, thickness);

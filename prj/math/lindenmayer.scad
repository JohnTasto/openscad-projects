use <nz/nz.scad>


function expand(s, rules, iterations=1)
  = iterations < 1 ? s
  : expand
    ( array_to_string([
        for (c = s)
        let (rs = concat(rules, [[c, c]]))
        rs[search(c, rs)[0]][1]
      ])
    , rules
    , iterations - 1
    );

function array_to_string(ss, s="")
  = len(ss) == 0 ? s
  : array_to_string(tail(ss), str(s, head(ss)));

function _bracket_match(s, i, bs, depth)
  = depth < 1 ? i-1
  : i < len(s) ? _bracket_match(s, i=i+1, bs=bs, depth=depth+(s[i]==bs[0] ? 1 : s[i]==bs[1] ? -1 : 0))
  : undef;

function bracket_match(s, i)
  = s[i] == "(" ? _bracket_match(s, i+1, bs="()", depth=1)
  : s[i] == "[" ? _bracket_match(s, i+1, bs="[]", depth=1)
  : s[i] == "{" ? _bracket_match(s, i+1, bs="{}", depth=1)
  : undef;

// echo(bracket_match("he[g[x]b[[vde]bb[aew]c]be[bh]ycw]emw", 2));

function next_group(s, start=0, end=undef)
  = start >= len(s) || (is_num(end) && start >= end) ? undef
  : let (match = bracket_match(s, start))
    is_num(match) ? [start, match]
  : next_group(s, start+1, end);

// echo(next_group("he[g[x]b[[vde]bb[aew]c]be[bh]ycw]emw", 10, 16));

module draw(s, moves=[], paints=[], color=function(depth) [.8,.8,.8], i=0, end=undef, depth=0, transform=identity(4), debug=false) {
  if ((!is_num(end) || i < end) && i < len(s)) {
    if (debug) echo(str("Draw: ", array_to_string([for (j = [i:is_num(end)?end-1:len(s)-1]) s[j]])));
    group = next_group(s, start=i, end=is_num(end)?min(i+9999, end):i+9999);
    stop = is_list(group) ? group[0] : is_num(end) ? end : len(s);
    chop = min(i+9999, stop);
    if (debug) echo(str("Drawing: ", i<chop ? array_to_string([for (j = [i:chop-1]) s[j]]) : ""));
    transforms = i < chop
      ? [ for (j = [i:chop-1])
          let (ms = concat(moves, [[s[j], identity(4)]]))
          ms[search(s[j], ms)[0]][1]
        ]
      : [];
    cumTransforms = [for (j=0, t=transform; j<=len(transforms); t=j==len(transforms)?t:t*transforms[j], j=j+1) t];
    color(color(depth))
      if (i < chop)
        for (j = [i:chop-1])
          let
          ( ps = concat(paints, [[s[j], -1]])
          , child = ps[search(s[j], ps)[0]][1]
          , $depth = depth
          )
            if (child >= 0) multmatrix(cumTransforms[j-i]) children(child);
    if (stop != chop)
      draw(s, moves=moves, paints=paints, color=color, i=i+9999, end=end, depth=depth, transform=cumTransforms[len(cumTransforms)-1], debug=debug)
        { if ($children > 0) children(0); if ($children > 1) children(1); if ($children > 2) children(2); if ($children > 3) children(3); if ($children > 4) children(4); if ($children > 5) children(5); if ($children > 6) children(6); if ($children > 7) children(7); if ($children > 8) children(8); if ($children > 9) children(9); }
    if (is_list(group)) {
      if (debug) echo(str("Matched brackets at ", group[0], " and ", group[1]));
      if (debug) echo(str("Drawing bracket contents: ", array_to_string([for (j = [group[0]+1:group[1]-1]) s[j]])));
      draw(s, moves=moves, paints=paints, color=color, i=group[0]+1, end=group[1], depth=depth+1, transform=cumTransforms[len(cumTransforms)-1], debug=debug)
        { if ($children > 0) children(0); if ($children > 1) children(1); if ($children > 2) children(2); if ($children > 3) children(3); if ($children > 4) children(4); if ($children > 5) children(5); if ($children > 6) children(6); if ($children > 7) children(7); if ($children > 8) children(8); if ($children > 9) children(9); }
      if (debug) echo(str("Resuming after brackets: ", array_to_string([for (j = [group[1]+1:is_num(end)?end-1:len(s)-1]) s[j]])));
      draw(s, moves=moves, paints=paints, color=color, i=group[1]+1, end=end, depth=depth+1, transform=cumTransforms[len(cumTransforms)-1], debug=debug)
        { if ($children > 0) children(0); if ($children > 1) children(1); if ($children > 2) children(2); if ($children > 3) children(3); if ($children > 4) children(4); if ($children > 5) children(5); if ($children > 6) children(6); if ($children > 7) children(7); if ($children > 8) children(8); if ($children > 9) children(9); }
    }
  }
}

// Koch curve
// draw
// ( expand("F", [["F", "F+F-F-F+F"]], 5)  //  6 ~ 0:15   7 ~ 5:15
// , [["F", translate([0, 5, 0])], ["-", rotate(-90)], ["+", rotate(90)]]
// , [["F", 0]]
// ) rect([1, 5], [0,1]);

// Sierpinski triangle
// draw
// ( expand("F-G-G", [["F", "F-G+F+G-F"], ["G", "GG"]], 6)  //  7 ~ 0.05   8 ~ 0:30   9 ~ 3:50
// , [["F", translate([0, 5, 0])], ["G", translate([0, 5, 0])], ["-", rotate(-120)], ["+", rotate(120)]]
// , [["F", 0], ["G", 0]]
// ) rect([1, 5], [0,1]);

// Sierpinski arrowhead curve
// draw
// ( expand("F", [["F", "G-F-G"], ["G", "F+G+F"]], 8)  //  8 ~ 0:07   9 ~ 0:40   10 ~ 5:30
// , [["F", translate([0, 5, 0])], ["G", translate([0, 5, 0])], ["-", rotate(-60)], ["+", rotate(60)]]
// , [["F", 0], ["G", 0]]
// ) rect([1, 5], [0,1]);

// Dragon curve
// draw
// ( expand("F", [["F", "F+G"], ["G", "F-G"]], 13)  //  13 ~ 0:15   14 ~ 1:00   15 ~ 3:30
// , [["F", translate([0, 5, 0])], ["G", translate([0, 5, 0])], ["-", rotate(-90)], ["+", rotate(90)]]
// , [["F", 0], ["G", 0]]
// // ) rect([1, 5], [0,1]);
// ) translate([0, 0]) rotate(45) rect([2.5*sqrt(2),2.5*sqrt(2)], [1,1]);

// Fractal plant
// draw
// ( expand("X", [["X", "F+[[X]-X]-F[-FX]+X"], ["F", "FF"]], 7),  //  6 ~ 0:25   7 ~ 5:45
// , [["F", translate([0, 5, 0])], ["-", rotate(-25)], ["+", rotate(25)]]
// , [["F", 0]]
// , function(depth) [.7, .5+depth/35, .5-depth/35]
// ) rect([1, 5], [0,1]);

// 3D fractal plant
draw
( expand("X", [["X", "F+[[X]-X]-F[-FX]+X"], ["F", "FF"]], 5),  //  6 ~ 0:25   7 ~ 5:45
, [["F", translate([0, 0, 5])], ["-", rotate([25, 25, 0])], ["+", rotate([-25, -25, -30])]]
, [["F", 0]]
, function(depth) [.7, .5+depth/35, .5-depth/35]
) rod(7.5, r=10-$depth/2, $fn=12);

// Gosper curve (flowsnake)
// draw
// ( expand("A", [["A", "A-B--B+A++AA+B-"], ["B", "+A-BB--B-A++A+B"]], 4)
// , [["A", translate([0, 5, 0])], ["B", translate([0, 5, 0])], ["-", rotate(-60)], ["+", rotate(60)]]
// , [["A", 0], ["B", 0]]
// ) rect([1, 5], [0,1]);

// Lévy C curve
// draw
// ( expand("F", [["F", "+F--F+"]], 12)
// , [["F", translate([0, 5, 0])], ["-", rotate(-45)], ["+", rotate(45)]]
// , [["F", 0]]
// ) rect([1, 5], [0,1]);

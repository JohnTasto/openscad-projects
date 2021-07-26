use <nz/nz.scad>


function expand(start, rules, iterations=1)
  = iterations < 1 ? start
  : expand
    ( array_to_string([
        for (s = start)
        let (rs = concat(rules, [[s, s]]))
        let (is = search(s, rs))
        rs[is[0]][1]
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

module draw(s, angle=15, i=0, end=undef, transform=identity(4), debug=false) {
  if ((!is_num(end) || i < end) && i < len(s)) {
    if (debug) echo(str("Draw: ", array_to_string([for (j = [i:is_num(end)?end-1:len(s)-1]) s[j]])));
    group = next_group(s, start=i, end=is_num(end)?min(i+1000, end):i+1000);
    stop = is_list(group) ? group[0] : is_num(end) ? end : len(s);
    chop = min(i+9999, stop);
    if (debug) echo(str("Drawing: ", i<chop ? array_to_string([for (j = [i:chop-1]) s[j]]) : ""));
    transforms = i < chop
      ? [ for (j = [i:chop-1])
          if (s[j] == "F" || s[j] == "G") translate([0, 5, 0]) else
          if (s[j] == "-") rotate(-angle) else
          if (s[j] == "+") rotate( angle) else
          identity(4)
        ]
      : [];
    cumTransforms = len(transforms) > 0
      ? [for (j=0, t=transform; j<=len(transforms); t=j==len(transforms)?t:t*transforms[j], j=j+1) t]
      : [transform];
    if (i < chop) for (j = [i:chop-1]) if (s[j] == "F" || s[j] == "G")
      multmatrix(cumTransforms[j-i]) rect([1, 5], [0,1]);
    if (stop != chop)
      draw(s, angle=angle, i=i+9999, end=end, transform=cumTransforms[len(cumTransforms)-1], debug=debug);
    if (is_list(group)) {
      if (debug) echo(str("Matched brackets at ", group[0], " and ", group[1]));
      if (debug) echo(str("Drawing bracket contents: ", array_to_string([for (j = [group[0]+1:group[1]-1]) s[j]])));
      draw(s, angle=angle, i=group[0]+1, end=group[1], transform=cumTransforms[len(cumTransforms)-1], debug=debug);
      if (debug) echo(str("Resuming after brackets: ", array_to_string([for (j = [group[1]+1:is_num(end)?end-1:len(s)-1]) s[j]])));
      draw(s, angle=angle, i=group[1]+1, end=end, transform=cumTransforms[len(cumTransforms)-1], debug=debug);
    }
  }
}

// Hits max recursion depth rather quickly
module draw_simple(s, angle=15, i=0, end=undef, debug=false) {
  if ((!is_num(end) || i < end) && i < len(s)) {
    match = bracket_match(s, i);
    if (is_num(match)) {
      if (debug) echo(str("Matched brackets at ", i, " and ", match));
      if (debug) echo(str("Drawing bracket contents: ", array_to_string([for (j = [i+1:match-1]) s[j]])));
      draw(s, angle=angle, i=i+1, end=match, debug=debug);
      if (debug) echo(str("Resuming after brackets: ", array_to_string([for (j = [match+1:is_num(end)?end-1:len(s)-1]) s[j]])));
      draw(s, angle=angle, i=match+1, end=end, debug=debug);
    }
    else if (s[i] == "F" || s[i] == "G") {
      if (debug) echo(s[i]);
      rect([1,10],[0,1]);
      translate([0,10])
        draw(s, angle=angle, i=i+1, end=end, debug=debug);
    }
    else if (s[i] == "-") {
      if (debug) echo(s[i]);
      rotate(-angle)
        draw(s, angle=angle, i=i+1, end=end, debug=debug);
    }
    else if (s[i] == "+") {
      if (debug) echo(s[i]);
      rotate(angle)
        draw(s, angle=angle, i=i+1, end=end, debug=debug);
    }
    else draw(s, angle=angle, i=i+1, end=end, debug=debug);
  }
}

// Koch curve
// draw(expand("F", [["F", "F+F-F-F+F"]], 6), 90);  //  6 ~ 0:15   7 ~ 5:15

// Sierpinski triangle
// draw(expand("F-G-G", [["F", "F-G+F+G-F"], ["G", "GG"]], 7), 120);  //  7 ~ 0.05   8 ~ 0:30   9 ~ 3:50

// Sierpinski arrowhead curve
// draw(expand("F", [["F", "G-F-G"], ["G", "F+G+F"]], 8), 60);  //  8 ~ 0:07   9 ~ 0:40   10 ~ 5:30

// Dragon curve
// draw(expand("F", [["F", "F+G"], ["G", "F-G"]], 13), 90);  //  13 ~ 0:15   14 ~ 1:00   15 ~ 3:30

// Fractal plant
draw(expand("X", [["X", "F+[[X]-X]-F[-FX]+X"], ["F", "FF"]], 6), 25, debug=false);  //  6 ~ 0:25   7 ~ 5:45

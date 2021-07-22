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

// echo(bracket_match("he[g[x]b[[vde]bb[aew]c]be[bh]ycw]", 2));

module draw(s, angle=15, i=0, end=undef, debug=false) {
  // if (!(is_num(end) && i >= end) && i < len(s)) {
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
// draw(expand("F", [["F", "F+F-F-F+F"]], 3), 90);

// Sierpinski triangle
// draw(expand("F-G-G", [["F", "F-G+F+G-F"], ["G", "GG"]], 4), 120);

// Sierpinski arrowhead curve
// draw(expand("F", [["F", "G-F-G"], ["G", "F+G+F"]], 5), 60);

// Dragon curve
// draw(expand("F", [["F", "F+G"], ["G", "F-G"]], 8), 90);

// Fractal plant
draw(expand("X", [["X", "F+[[X]-X]-F[-FX]+X"], ["F", "FF"]], 5), 25);

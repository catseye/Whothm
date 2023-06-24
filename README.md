The Whothm Drawing Language
===========================

Overview
--------

Whothm is a language for describing infinite two-colour bitmapped
graphics.

### Prerequisites

I'd love to tell you about Whothm, but first I need to tell you about
Joanie, the Gnostic Babysitter. Have you seen her? She's a very normal
twelve-year-old girl, with very normal twelve-year-old girl concerns —
she worries if her friends will make fun of her for liking different
music than they do, worries if that cute boy in home room likes her or
not, worries if she'll be able to achieve a transcendant state of gnosis
at the moment of her physical death so that her soul may be freed from
the reincarnation cycle. Because, you see, she's a Gnostic. Not just
curious about Gnosticism, not just going through a phase, or anything
like that — Joanie is a die-hard, demiurge-rejecting,
rotten-material-world-shunning Gnostic. And she charges $15 an hour.

OK, *now* I can tell you about Whothm.

### Program Structure

Each Whothm program consists of a variable declaration section and a
single infinite loop.

There are two possible data types for variables: rectangles and truth
tables. A rectangle is a structure of four integer members called x, y,
w and h. A truth table is a map from pairs of boolean values to a single
boolean value. A truth table is denoted by listing only the pairs which
evaluate to true; all other pairs evaluate to false.

Inside the infinite loop, there are two kinds of commands: draw commands
and delta commands. Draw commands apply a rectangle to the drawing
canvas. Every pixel on the canvas that lies within w pixels to the right
of the x position, and within h pixels to the bottom of the y position,
is changed. A truth table is given that determines how it is changed.
The existing pixel is looked up in the first column of the table, and
the pixel in the rectangle being drawn (which is always true) is looked
up in the second column; the resulting pixel state is read off the third
column. Truth maps to the foreground colour (typically black), while
falsehood maps to the background colour (typically white.)

Delta commands alter a named member of a named rectangle. They always
add a value to the member, although that value may be negative. The
value may be a literal constant, or it may be the current value of a
named member of a named rectangle.

Syntax
------

### Grammar

    Whothm      ::= {Declaration ";"} "begin" {Command ";"} "end".
    Declaration ::= Name<new> ":=" (RectDecl | TableDecl).
    RectDecl    ::= "(" IntLit "," IntLit "," IntLit "," IntLit ")".
    TableDecl   ::= TruthPair {"/" TruthPair}.
    TruthPair   ::= "TT" | "TF" | "FT" | "FF".
    Command     ::= DrawCmd | DeltaCmd.
    DrawCmd     ::= "draw" Name<Rect> "," Name<Table>.
    DeltaCmd    ::= MemberRef "+=" (IntLit | MemberRef).
    MemberRef   ::= Name<Rect> "." RectMember.
    RectMember  ::= "x" | "y" | "w" | "h".

### Example Program

    r := (0, 0, 1, 2);

    AND := TT;
    OR := TT/TF/FT;
    NAND := TF/FT/FF;
    NOR := FF;
    XOR := TF/FT;

    begin
    r.x += 5;
    r.y += r.w;
    draw r, XOR;
    end

Semantics
---------

The meaning of a Whothm program is fairly intuitive. The commands
between the `begin` and `end` are executed in sequence, altering the
state of the drawing canvas, and of one or more rectangles. (There is no
way to alter a truth table, once defined.) The whole sequence of
commands is then repeated, *ad infinitum*.

However, note that Whothm is a language for describing only shapes which
are (countably) infinte in extent. For this reason, it is an error for
the state of the program (that is, the variables and the canvas) to be
the same on any two (even non-consecutive) iterations of the loop.

Discussion
----------

Whothm raises some interesting questions, although not perhaps as
interesting as those raised by Joanie's grades this semester. The main
one is, what kinds of shapes can Whothm describe?

Clearly, the shapes cannot be chaotic in any strong sense, as the
equations involved are essentially linear. The sole exception is when a
truth tables like XOR, which can reverse previous pixels, is used. In
fact, the presence of XOR means that Whothm can generate infinite
drawings without a fixed point. (XOR seems a bit like sine in that
respect; you can't take the indefinite integral of it, because never
ever settles down.) Yet, I believe it is not necessary — any shape that
can be drawn with XOR can be drawn with suitable monotonic truth tables,
as well.

Further, despite not being able to produce clearly chaotic drawings,
Whothm can still produce what are in my opinion somewhat pretty ones.

Cat's Eye Technologies' implementation of Whothm is called JWhothm, as
it is written in Java. Using a browser which supports Java applets, it
can be interacted with in the [JWhothm
exhibit](http://catseye.tc/gallery/esolangs/jwhothm/) in the [Gallery of
Interactive Esolangs](http://catseye.tc/gallery/esolangs/).

Happy infinite drawing!  
Chris Pressey  
June 29, 2010  
Evanston, IL  
Birthplace of Donald Rumsfeld... and Grace Slick

% This is a modified MetaPost base with additional features (such as 
% Unicode names). This files is based on the mfplain.mp (v0.99).
% The modification have been made by Linus Romer for the 
% mf2outline.py script.

% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.

% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.

% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.

% Copyright 2014 by Linus Romer

string base_name, base_version; base_name="mf2outline"; base_version="20171029";

message "Preloading the mf2outline base, version "&base_version&": preliminaries,";

delimiters ();  % this makes parentheses behave like parentheses
def upto = step 1 until enddef; % syntactic sugar
def downto = step -1 until enddef;
def exitunless expr c = exitif not c enddef;
let relax = \;  % ignore the word `relax', as in TeX
let \\ = \; % double relaxation is like single
def ]] = ] ] enddef; % right brackets should be loners
def -- = {curl 1}..{curl 1} enddef;
def --- = .. tension infinity .. enddef;
def ... = .. tension atleast 1 .. enddef;

newinternal smoothing, autorounding, turningcheck, granularity;
warningcheck:=1;
tracinglostchars:=1;
smoothing:=1; autorounding:=2;  % These are ignored by MetaPost
turningcheck:=1; granularity:=1;

def gobble primary g = enddef; def killtext text t = enddef;
primarydef g gobbled gg = enddef;
def hide(text t) = exitif numeric begingroup t;endgroup; enddef;
def ??? = hide(interim showstopping:=1; showdependencies) enddef;
def stop expr s = message s; gobble readstring enddef;

def interact = % sets up to make "show" commands stop
 hide(showstopping:=1; tracingonline:=1) enddef;

def loggingall =        % puts tracing info into the log
 tracingcommands:=3; tracingtitles:=1; tracingequations:=1;
 tracingcapsules:=1; tracingspecs:=2; tracingchoices:=1; tracinglostchars:=1;
 tracingstats:=1; tracingoutput:=1; tracingmacros:=1; tracingrestores:=1;
 enddef;

def tracingall =        % turns on every form of tracing
 tracingonline:=1; showstopping:=1; loggingall enddef;

def tracingnone =       % turns off every form of tracing
 tracingcommands:=0; tracingtitles:=0; tracingequations:=0;
 tracingcapsules:=0; tracingspecs:=0; tracingchoices:=0; tracinglostchars:=0;
 tracingstats:=0; tracingoutput:=0; tracingmacros:=0; tracingrestores:=0;
 enddef;

message " basic constants and mathematical macros,";

% numeric constants
newinternal eps,epsilon,infinity,_;
eps := .00049;    % this is a pretty small positive number
epsilon := 1/256/256;   % but this is the smallest
infinity := 4095.99998;    % and this is the largest
_ := -1; % internal constant to make macros unreadable but shorter

newinternal mitered, rounded, beveled, butt, squared;
mitered:=0; rounded:=1; beveled:=2; % linejoin types
butt:=0;    rounded:=1; squared:=2; % linecap types


% pair constants
pair right,left,up,down,origin;
origin=(0,0); up=-down=(0,1); right=-left=(1,0);

% path constants
path quartercircle,halfcircle,fullcircle,unitsquare;
fullcircle = makepath pencircle;
halfcircle = subpath (0,4) of fullcircle;
quartercircle = subpath (0,2) of fullcircle;
unitsquare=(0,0)--(1,0)--(1,1)--(0,1)--cycle;

% transform constants
transform identity;
for z=origin,right,up: z transformed identity = z; endfor

% color constants
color black, white, red, green, blue;
black = (0,0,0);
white = (1,1,1);
red = (1,0,0);
green = (0,1,0);
blue = (0,0,1);

% picture constants
picture blankpicture,unitpixel;
blankpicture=nullpicture;
unitpixel=nullpicture; addto unitpixel contour unitsquare;

% string constants
string ditto; ditto = char 34; % ASCII double-quote mark

% pen constants
def capsule_def(suffix s) primary u = def s = u enddef enddef;
pen pensquare,penrazor,penspeck;
pensquare = makepen(unitsquare shifted -(.5,.5));
penrazor = makepen((-.5,0)--(.5,0)--cycle);
penspeck=pensquare scaled eps;

% nullary operators
vardef whatever = save ?; ? enddef;

% unary operators
let abs = length;

vardef round primary u =
 if numeric u: floor(u+.5)
 elseif pair u: (hround xpart u, vround ypart u)
 else: u fi enddef;
vardef hround primary x = floor(x+.5) enddef;
vardef vround primary y = floor(y.o_+.5)_o_ enddef;

vardef ceiling primary x = -floor(-x) enddef;

vardef byte primary s =
 if string s: ASCII fi s enddef;

vardef dir primary d = right rotated d enddef;

vardef unitvector primary z = z/abs z enddef;

vardef inverse primary T =
 transform T_; T_ transformed T = identity; T_ enddef;

vardef counterclockwise primary c =
 if turningnumber c <= 0: reverse fi c enddef;

vardef tensepath expr r =
 for k=0 upto length r - 1: point k of r --- endfor
 if cycle r: cycle else: point infinity of r fi enddef;

% binary operators

primarydef x mod y = (x-y*floor(x/y)) enddef;
primarydef x div y = floor(x/y) enddef;
primarydef w dotprod z = (xpart w * xpart z + ypart w * ypart z) enddef;

primarydef x**y = if y=2: x*x else: takepower y of x fi enddef;
def takepower expr y of x =
 if x>0: mexp(y*mlog x)
 elseif (x=0) and (y>0): 0
 else: 1
  if y=floor y:
   if y>=0: for n=1 upto y: *x endfor
   else: for n=_ downto y: /x endfor
   fi
  else: hide(errmessage "Undefined power: " & decimal x&"**"&decimal y)
  fi fi enddef;

vardef direction expr t of p =
 postcontrol t of p - precontrol t of p enddef;

vardef directionpoint expr z of p =
 a_:=directiontime z of p;
 if a_<0: errmessage("The direction doesn't occur"); fi
 point a_ of p enddef;

secondarydef p intersectionpoint q =
 begingroup save x_,y_; (x_,y_)=p intersectiontimes q;
 if x_<0: errmessage("The paths don't intersect"); origin
 else: .5[point x_ of p, point y_ of q] fi endgroup
enddef;

tertiarydef p softjoin q =
 begingroup c_:=fullcircle scaled 2join_radius shifted point 0 of q;
 a_:=ypart(c_ intersectiontimes p); b_:=ypart(c_ intersectiontimes q);
 if a_<0:point 0 of p{direction 0 of p} else: subpath(0,a_) of p fi
  ... if b_<0:{direction infinity of q}point infinity of q
   else: subpath(b_,infinity) of q fi endgroup enddef;
newinternal join_radius,a_,b_; path c_;

% special operators
vardef incr suffix $ = $:=$+1; $ enddef;
vardef decr suffix $ = $:=$-1; $ enddef;

def reflectedabout(expr w,z) =    % reflects about the line w..z
 transformed
  begingroup transform T_;
  w transformed T_ = w;  z transformed T_ = z;
  xxpart T_ = -yypart T_; xypart T_ = yxpart T_; % T_ is a reflection
  T_ endgroup enddef;

def rotatedaround(expr z, d) =    % rotates d degrees around z
 shifted -z rotated d shifted z enddef;
let rotatedabout = rotatedaround;   % for roundabout people

vardef min(expr u)(text t) = % t is a list of numerics, pairs, or strings
 save u_; setu_ u; for uu = t: if uu<u_: u_:=uu; fi endfor
 u_ enddef;

vardef max(expr u)(text t) = % t is a list of numerics, pairs, or strings
 save u_; setu_ u; for uu = t: if uu>u_: u_:=uu; fi endfor
 u_ enddef;

def setu_ primary u =
 if pair u: pair u_ elseif string u: string u_ fi;
 u_=u enddef;

def flex(text t) =           % t is a list of pairs
 hide(n_:=0; for z=t: z_[incr n_]:=z; endfor
  dz_:=z_[n_]-z_1)
 z_1 for k=2 upto n_-1: ...z_[k]{dz_} endfor ...z_[n_] enddef;
newinternal n_; pair z_[],dz_;

def superellipse(expr r,t,l,b,s)=
 r{up}...(s[xpart t,xpart r],s[ypart r,ypart t]){t-r}...
 t{left}...(s[xpart t,xpart l],s[ypart l,ypart t]){l-t}...
 l{down}...(s[xpart b,xpart l],s[ypart l,ypart b]){b-l}...
 b{right}...(s[xpart b,xpart r],s[ypart r,ypart b]){r-b}...cycle enddef;

vardef interpath(expr a,p,q) =
 for t=0 upto length p-1: a[point t of p, point t of q]
  ..controls a[postcontrol t of p, postcontrol t of q]
   and a[precontrol t+1 of p, precontrol t+1 of q] .. endfor
 if cycle p: cycle
 else: a[point infinity of p, point infinity of q] fi enddef;

vardef solve@#(expr true_x,false_x)= % @#(true_x)=true, @#(false_x)=false
 tx_:=true_x; fx_:=false_x;
 forever: x_:=.5[tx_,fx_]; exitif abs(tx_-fx_)<=tolerance;
 if @#(x_): tx_ else: fx_ fi :=x_; endfor
 x_ enddef; % now x_ is near where @# changes from true to false
newinternal tolerance, tx_,fx_,x_; tolerance:=.1;

message " macros for converting units,";

newinternal bpppix_, bp_per_pixel;  % drawing is done in `pixel' units
bpppix_:=0.02;

mm*bpppix_=2.83464;      pt*bpppix_=0.99626;
dd*bpppix_=1.06601;      bp*bpppix_=1;
cm*bpppix_=28.34645;     pc*bpppix_=11.95517;
cc*bpppix_=12.79213;     in*bpppix_=72;

mm#=2.84528;      pt#=1;        dd#=1.07001;      bp#=1.00375;
cm#=28.45276;     pc#=12;       cc#=12.84010;     in#=72.27;

newinternal hppp, vppp;
hppp:=pt;   vppp:=pt;

newinternal blacker, o_correction; % device-oriented corrections

def define_pixels(text t) =
 forsuffixes $=t: $:=$.#*pt; endfor enddef;
def define_blacker_pixels(text t) =
 forsuffixes $=t: $:=$.#*pt+blacker; endfor enddef;
def define_corrected_pixels(text t) =
 forsuffixes $=t: $:=$.#*pt*o_correction; endfor enddef;

def define_whole_pixels = define_pixels enddef;
def define_whole_vertical_pixels = define_pixels enddef;
def define_good_x_pixels = define_pixels enddef;
def define_good_y_pixels = define_pixels enddef;
def define_whole_blacker_pixels = define_blacker_pixels enddef;
def define_whole_vertical_blacker_pixels = define_blacker_pixels enddef;
def define_horizontal_corrected_pixels = define_corrected_pixels enddef;

def lowres_fix(text t) expr ratio = enddef;

message " macros and tables for various modes of operation,";

transform currenttransform;
def t_ = transformed currenttransform enddef;
let o_=\; let _o_=\;

def mode_setup =
 if unknown mode: mode=proof; fi
 numeric aspect_ratio; transform currenttransform;
 scantokens if string mode:("input "&mode) else: mode_name[mode] fi;
 if unknown mag: mag=1; fi
 if unknown aspect_ratio: aspect_ratio=1; fi
 bp_per_pixel:=bpppix_*mag;
 scantokens extra_setup; % the user's special last-minute adjustments
 if unknown currenttransform: currenttransform=identity; fi
 clearit;
 pickup pencircle scaled (.4pt+blacker);
 enddef;
def smode = string mode; mode enddef;
string extra_setup, mode_name[];
extra_setup="";          % usually there's nothing special to do

vardef magstep primary m = mexp(46.67432m) enddef;

def mode_def suffix $ =
 $:=incr number_of_modes;
 mode_name[$]:=str$ & "_";
 expandafter quote def scantokens mode_name[$] enddef;
newinternal number_of_modes;


newinternal proofing; % <0 to supress output; >1 to do labels
color proofcolor;     % color for output when proofing>0
proofcolor =.3[white,black];
color background;
background = white;

% proof mode: for initial design of characters
mode_def proof =
 proofing:=2;                   % yes, we're making full proofs
 fontmaking:=0;                 % no, we're not making a font
 tracingtitles:=1;              % yes, show titles online
 blacker:=0;                    % no additional blackness
 o_correction:=1;               % no reduction in overshoot
 if unknown mag: mag=36; else: mag:=36mag; fi
 enddef;

% smoke mode: for label-free proofs to mount on the wall
mode_def smoke =
 proof_;                        % same as proof mode, except:
 proofing:=1;                   % yes, we're making unlabeled proofs
 proofcolor:=black;             % with solid black pixels
 let makebox=maketicks;         % make the boxes less obtrusive
 if unknown mag: mag=36; else: mag:=36mag; fi
 enddef;

% lowres mode: for certain devices that print 200 pixels per inch
mode_def lowres =
 proofing:=0;                   % no, we're not making proofs
 fontmaking:=1;                 % yes, we are making a font
 tracingtitles:=0;              % no, don't show titles at all
 blacker:=0;                    % no extra blackness with PostScript
 o_correction:=1;               % no reduction in overshoot
 enddef;

localfont:=lowres;      % the mode most commonly used to make fonts

% It is not likely that additional modes are needed, but if they are,
% additional mode_def commands should be in another input file that
% gets loaded after the PLAIN base.  The auxiliary file should set
% base_version:=base_version&"/localname".


message " macros for drawing and filling,";

def pc_ =
  hide(if proofing>0: def pc_=do_pc_ enddef; else: def pc_= enddef; fi) pc_
enddef;
def do_pc_ = withcolor proofcolor enddef;

linejoin:=rounded;               % parameters that effect drawing
linecap:=rounded;
miterlimit:=10;

pen currentpen;
picture currentpicture;

def fill expr c = addto currentpicture contour c t_ pc_ enddef;
def draw expr p =
  addto currentpicture
  if picture p:
    also p
  else:
    doublepath p t_ withpen currentpen
  fi
  pc_
enddef;
def filldraw expr c =
  addto currentpicture contour c t_ withpen currentpen
  pc_ enddef;
def drawdot expr z =
  addto currentpicture contour makepath currentpen shifted z
  t_ pc_ enddef;

def unfill expr c = fill c withcolor background enddef;
def undraw expr p = draw p withcolor background enddef;
def unfilldraw expr c = filldraw c withcolor background enddef;
def undrawdot expr z = drawdot z withcolor background enddef;
def erase text t =
  def _e_ = withcolor background hide(def _e_=enddef;) enddef;
  t _e_
enddef;
def _e_= enddef;

def cutdraw text t =
  begingroup interim linecap:=butt; draw t _e_; endgroup enddef;

def pickup secondary q =
 if numeric q: numeric_pickup_ else: pen_pickup_ fi q enddef;
def numeric_pickup_ primary q =
 if unknown pen_[q]: errmessage "Unknown pen"; clearpen
 else: currentpen:=pen_[q];
  pen_lft:=pen_lft_[q];
  pen_rt:=pen_rt_[q];
  pen_top:=pen_top_[q];
  pen_bot:=pen_bot_[q];
  currentpen_path:=pen_path_[q] fi; enddef;
def pen_pickup_ primary q =
  currentpen:=q;
  pen_lft:=xpart penoffset down of currentpen;
  pen_rt:=xpart penoffset up of currentpen;
  pen_top:=ypart penoffset left of currentpen;
  pen_bot:=ypart penoffset right of currentpen;
  path currentpen_path; enddef;
newinternal pen_lft,pen_rt,pen_top,pen_bot,pen_count_;

vardef savepen = pen_[incr pen_count_]=currentpen;
 pen_lft_[pen_count_]=pen_lft;
 pen_rt_[pen_count_]=pen_rt;
 pen_top_[pen_count_]=pen_top;
 pen_bot_[pen_count_]=pen_bot;
 pen_path_[pen_count_]=currentpen_path;
 pen_count_ enddef;

def clearpen = currentpen:=nullpen;
 pen_lft:=pen_rt:=pen_top:=pen_bot:=0;
 path currentpen_path;
 enddef;
def clear_pen_memory =
 pen_count_:=0;
 numeric pen_lft_[],pen_rt_[],pen_top_[],pen_bot_[];
 pen currentpen,pen_[];
 path currentpen_path, pen_path_[];
 enddef;

vardef lft primary x = x + if pair x: (pen_lft,0) else: pen_lft fi enddef;
vardef rt primary x = x + if pair x: (pen_rt,0) else: pen_rt fi enddef;
vardef top primary y = y + if pair y: (0,pen_top) else: pen_top fi enddef;
vardef bot primary y = y + if pair y: (0,pen_bot) else: pen_bot fi enddef;
vardef good.x primary x = x enddef;
vardef good.y primary y = y enddef;
vardef good.lft primary z = z enddef;
vardef good.rt primary z = z enddef;
vardef good.top primary z = z enddef;
vardef good.bot primary z = z enddef;

vardef penpos@#(expr b,d) =
 (x@#r-x@#l,y@#r-y@#l)=(b,0) rotated d;
 x@#=.5(x@#l+x@#r); y@#=.5(y@#l+y@#r) enddef;

def penstroke text t =
 forsuffixes e = l,r: path_.e:=t; endfor
 fill path_.l -- reverse path_.r -- cycle enddef;
path path_.l,path_.r;

message " macros for proof labels and rules,";

string defaultfont;
newinternal defaultscale, labeloffset;
defaultfont = "cmr10";
defaultscale := 1;
labeloffset := 3;

vardef makelabel@#(expr s,z) = % puts string s near point z
  save p; picture p;
  if known z:
    p = s infont defaultfont scaled (defaultscale/bp_per_pixel);
    draw p shifted (z t_ + labeloffset/bp_per_pixel*laboff@# -
       (labxf@#*lrcorner p + labyf@#*ulcorner p
         + (1-labxf@#-labyf@#)*llcorner p
       )
    ) withcolor black;
    interim linecap:=rounded;
    draw z withpen pencircle scaled (3/bp_per_pixel) withcolor black;
  fi
enddef;

string lcode_;  % just in case someone refers to this
pair laboff, laboff.lft, laboff.rt, laboff.top, laboff.bot;
laboff.lft=(-1,0);   labxf.lft=1;   labyf.lft=.5;
laboff.rt =(1,0);    labxf.rt =0;   labyf.rt =.5;
laboff.bot=(0,-1);   labxf.bot=.5;  labyf.bot=1;
laboff.top=(0,1);    labxf.top=.5;  labyf.top=0;
laboff=laboff.top;   labxf=labxf.top; labyf=labyf.top;
% There could be fancy code to keep labels from overlapping!

vardef labels@#(text t) =
 if proofing>1: forsuffixes $=t:
  makelabel@#(str$,z$); endfor
 fi enddef;
vardef penlabels@#(text t) =
 if proofing>1: forsuffixes $$=l,,r: forsuffixes $=t:
  makelabel@#(str$.$$,z$.$$); endfor endfor
 fi enddef;

def range expr x = numtok[x] enddef;
def numtok suffix x=x enddef;
tertiarydef m thru n =
 m for x=m+1 step 1 until n: , numtok[x] endfor enddef;

def proofrule(expr w,z) =
  begingroup interim linecap:=squared;
  draw w..z withpen pencircle scaled (.4/bp_per_pixel) withcolor black;
  endgroup
enddef;
def screenrule(expr w,z) = enddef;
pen rulepen;

def makegrid(text xlist,ylist) =
 xmin_ := min(xlist); xmax_ := max(xlist);
 ymin_ := min(ylist); ymax_ := max(ylist);
 for x=xlist: proofrule((x,ymin_), (x,ymax_)); endfor
 for y=ylist: proofrule((xmin_,y), (xmax_,y)); endfor
 enddef;

vardef titlefont suffix $ = enddef;
vardef labelfont suffix $ = defaultfont:=str$ enddef;
vardef grayfont suffix $ = enddef;
vardef slantfont suffix $ = enddef;
def proofoffset primary z = enddef;
vardef proofrulethickness expr x =
 rulepen := pencircle scaled x enddef;

message " macros for character and font administration,";

% ----- start of modifications by Linus Romer -----

% replace circle pens by icosagon pens for faster import in fontforge
% (only in preview mode)
if (substring(8,12) of base_version) = "prev":
 pen penicosagoncircle;
 penicosagoncircle:=makepen(
  for alpha=0 step 360/20 until 359:
   (0.5 cosd alpha, 0.5 sind alpha)--
  endfor 
  cycle);
 pen pencircle;
 pencircle:=penicosagoncircle;
fi

% returns the hexadicmal string of a numeric
vardef hexadecimal primary n =
 save m,s;
 m:=abs round n; 
 string s; 
 s=
 if (m mod 16)<10:
  decimal(m mod 16)
 elseif (m mod 16)=10:
  "A"
 elseif (m mod 16)=11:
  "B"
 elseif (m mod 16)=12:
  "C"
 elseif (m mod 16)=13:
  "D"
 elseif (m mod 16)=14:
  "E"
 else:
  "F"
 fi
 ;
 forever:
  m:=m div 16; 
  exitif m=0;
  s:=
  if (m mod 16)<10:
   decimal(m mod 16)
  elseif (m mod 16)=10:
   "A"
  elseif (m mod 16)=11:
   "B"
  elseif (m mod 16)=12:
   "C"
  elseif (m mod 16)=13:
   "D"
  elseif (m mod 16)=14:
   "E"
  else:
   "F"
  fi
  & s; 
 endfor
 s
enddef;

% returns the unicode string of a word (which is a string or a numeric)
vardef unicode primary n = 
 save s,z;
 string s,z;
 s:=
 if string n:
  if length(n)=1: % assume n to be a glyph name like "W"
   hexadecimal(ASCII n);
  else: % assume n to be a unicode like "00004A", "004A" or "4A"
   n;
  fi
 else: % assume n to be a numeric 
  hexadecimal n;
 fi 
 % now fill zeroes to be a 6-digit word:
 z:=
 if length(s)<6:
  for i=1 upto (6-length(s)): "0" & endfor s;
 else:
  s;
 fi
 z
enddef;

% epscode(c) returns the code c multiplied by epsilon
def epscode(expr c) =
 (hex(substring(3,6) of unicode(c))*epsilon
 +epsilon*256*16*hex(substring(0,3) of unicode(c)))
enddef;

% unicodeeps(c) returns the unicode of an
% epscode c (code that was multiplied by epsilon)
% this is the inverse macro of epscode()
def unicodeeps(expr c) =
 (substring(3,6) of unicode(floor(c*16)))
  & (substring(3,6) of unicode(floor((c*16-floor(c*16))*256*16)))
enddef;

% c is no longer only a number or ASCII char (e.g. 65 or "A") 
% but can also be a unicode string, representing a
% hexadecimal number (eg "0041")
newinternal string charunicode;
def beginchar(expr c,w_sharp,h_sharp,d_sharp) =
  begingroup
    charunicode:=if known c: unicode c else: "000000" fi; 
    charcode:=hex(substring(4,6) of charunicode); % this is the place inside the unicode subplane
    charext:=hex(substring(0,4) of charunicode); % this is the number of the unicode plane and subplane
    charepscode:=epscode(charunicode); % this is the code multiplied by epsilon=1/65536
    charwd:=w_sharp;      charht:=h_sharp;       chardp:=d_sharp;
    w:=charwd*pt; h:=charht*pt; d:=chardp*pt;
    charic:=0; clearxy; clearit; clearpen; scantokens extra_beginchar;
enddef;

def endchar =
    scantokens extra_endchar;
    if proofing>0: makebox(proofrule); fi
    chardx:=w;     % desired width of the character in pixels
    special "% mf2outline: charwd " & decimal charwd;
    special "% mf2outline: charht " & decimal charht;
    special "% mf2outline: chardp " & decimal chardp;
    special "% mf2outline: charic " & decimal charic;
    special "% mf2outline: charcode " & decimal charcode;
    special "% mf2outline: charext " & decimal charext;
    special "% mf2outline: charunicode " & charunicode;
    shipit;
  endgroup
enddef;

string fontforgecommands_[], % list of fontforge command
 kernclassesl_[][], % list of left kerning classes
 kernclassesr_[][], % list of right kerning classes
 ligatures_[][]; % list of ligatures
numeric kernmatrix_[][], % matrix with kerning entries
 randvariants_[][];
fontforgecommands_[0]="0"; % number of commands (will be increased)
kernclassesl_[0][0]="0"; % number of kernclassesl (will be increased)
kernclassesr_[0][0]="0"; % number of kernclassesr (will be increased)
ligatures_[0][0]="0"; % number of ligatures (will be increased)
randvariants_[-1][0]:=0; % number glyphs with random variants (will be increased)

% store a fontforge command into fontforgecommands_[]
def fontforge(expr command) = 
 begingroup
  save i;
  numeric i;
  i:=hex(fontforgecommands_[0])+1;
  fontforgecommands_[0]:=hexadecimal i;
  fontforgecommands_[i]:=command;
 endgroup
enddef;

% add a left kerning class to kernclassesl
% a is a comma separated list of codes, like addkernclassl(86,87,"c","4A","00004B");
% the codes may be numbers, ASCII letters or unicode strings
% but they are always stored as unicode strings
% the lengths of the array is stored as hexadecimal strings
def addkernclassl(text a) = 
 begingroup
  save i,l;
  numeric i,l;
  l:=hex(kernclassesl_[0][0])+1;
  kernclassesl_[0][0]:=hexadecimal l;
  i:=0; % number of chars in current class
  for b=a:
   i:=i+1;
   kernclassesl_[l][i]:=unicode b;
  endfor
  % number of chars in current class is stored at 0th position
  kernclassesl_[l][0]:=hexadecimal i; 
 endgroup
enddef;

% add a right kerning class to kernclassesr
% a is a comma separated list of codes, addkernclassr(86,87,"c","4A","00004B");
def addkernclassr(text a) = 
 begingroup
  save i,l;
  numeric i,l;
  l:=hex(kernclassesr_[0][0])+1;
  kernclassesr_[0][0]:=hexadecimal l;
  i:=0; % number of chars in current class
  for b=a:
   i:=i+1;
   kernclassesr_[l][i]:=unicode b;
  endfor
  % number of chars in current class is stored at 0th position
  kernclassesr_[l][0]:=hexadecimal i; 
 endgroup
enddef;

% kern all chars of left class and right class by kvalue
% identification is done by the first code of the class
def addclasskern(expr left,right,kvalue) = 
 begingroup
  save i,j;
  numeric i,j;
  % get the indices i and j of the two classes:
  i:=0; % default value (cannot be true)
  j:=0; % default value (cannot be true)
  forever:
   i:=i+1;
   exitif kernclassesl_[i][1]=unicode(left);
   if i=hex(kernclassesl_[0][0]):
    errmessage("unknown left kerning class");
   fi
  endfor
  forever:
   j:=j+1;
   exitif kernclassesr_[j][1]=unicode(right);
   if j=hex(kernclassesr_[0][0]):
    errmessage("unknown right kerning class");
   fi
  endfor
  kernmatrix_[i][j]:=kvalue;
 endgroup
enddef;

% adds a (multi-)ligature, e.g.
% addligature("FB02","f","l");
% addligature("FB04","f","f","l");
def addligature(expr c)(text a) = 
begingroup
  save i,l;
  numeric i,l;
  l:=hex(ligatures_[0][0])+1;
  ligatures_[0][0]:=hexadecimal l;
  ligatures_[l][1]:=unicode c;
  i:=1; % counter for ligature components (normaly 2)
  for b=a:
   i:=i+1;
   ligatures_[l][i]:=unicode b;
  endfor
  % number of components + 1 is stored at 0th position
  ligatures_[l][0]:=hexadecimal i; 
 endgroup
enddef;

% add a random variant (unicode v) 
% for the original glyph (unicode o)
% the structure of the randvariants_[][] array is
% as follows: randvariants_[-1] stores the epscodes 
% of the glyphs that have variants;
% randvariants_[-1][0] is the number of such glyphs;
% randvariants_[epscode][1] contains the first variant
% of the glyph with epscode
def addrandvariant(expr o,v) = 
 % check if o has already been used
 for i=0 upto randvariants_[-1][0]:
  exitif randvariants_[-1][i]=epscode(o);
  if i=randvariants_[-1][0]:
   randvariants_[-1][0]:=randvariants_[-1][0]+1;
   randvariants_[-1][randvariants_[-1][0]]:=epscode(o);
   randvariants_[epscode(o)][0]:=0;
  fi
 endfor
 % now store variant
 randvariants_[epscode(o)][0]:=randvariants_[epscode(o)][0]+1;
 randvariants_[epscode(o)][randvariants_[epscode(o)][0]]:=epscode(v);
enddef;

% ------ end of modifications by Linus Romer -----

def italcorr expr x_sharp = if x_sharp>0: charic:=x_sharp fi enddef;

def change_width = enddef;

string extra_beginchar, extra_endchar;
extra_beginchar=extra_endchar="";

def makebox(text r) =
 for y=0,h,-d: r((0,y),(w,y)); endfor % horizontals
 for x=0,w:   r((x,-d),(x,h)); endfor % verticals
 if charic<>0: r((w+charic*pt,h),(w+charic*pt,.5h)); fi
 enddef;

def maketicks(text r) =
 for y=0,h,-d: r((0,y),(10,y)); r((w-10,y),(w,y)); endfor
 for x=0,w: r((x,10-d),(x,-d)); r((x,h-10),(x,h)); endfor
 if charic<>0: r((w+charic*pt,h-10),(w+charic*pt,h)); fi
 enddef;

% ----- start of some modifications by Linus Romer -----
def font_size expr x = designsize:=x enddef;
def font_slant expr x = font_slant_:=x; fontdimen 1: x enddef;
def font_normal_space expr x = font_normal_space_:=x; fontdimen 2: x enddef;
def font_normal_stretch expr x = font_normal_stretch_:=x; fontdimen 3: x enddef;
def font_normal_shrink expr x = font_normal_shrink_:=x; fontdimen 4: x enddef;
def font_x_height expr x = font_x_height_:=x; fontdimen 5: x enddef;
def font_quad expr x = font_quad_:=x; fontdimen 6: x enddef;
def font_extra_space expr x = font_extra_space_:=x; fontdimen 7: x enddef;
def font_os_weight expr x = font_os_weight_:=x enddef;
def font_os_width expr x = font_os_width_:=x enddef;
def font_identifier expr x = font_identifier_:=x enddef;
def font_coding_scheme expr x = font_coding_scheme_:=x enddef;
def font_version expr x = font_version_:=x enddef;
def font_copyright expr x = font_copyright_:=x enddef;
def font_name expr x = font_name_:=x enddef;
def font_fullname expr x = font_fullname_:=x enddef;
def font_familyname expr x = font_familyname_:=x enddef;
numeric font_range_[]; % font size feature (lower,upper,style number)
def font_range(expr lower,upper,style) = 
 font_range_[1]:=lower;
 font_range_[2]:=upper;
 font_range_[3]:=style;
enddef;
string font_identifier_, font_coding_scheme_, 
 font_name_, font_fullname_, font_familyname_,
 font_copyright_, font_version_;
font_identifier_=font_coding_scheme_="UNSPECIFIED";
% ----- end of some modifications by Linus Romer -----

message "and a few last-minute items.";

vardef z@#=(x@#,y@#) enddef;

def openit = enddef;
def showit = enddef;

def clearxy = save x,y enddef;
def clearit = currentpicture:=nullpicture enddef;
def shipit =
  if proofing>=0:
    shipout currentpicture transformed
      (identity shifted (xoffset,yoffset) scaled bp_per_pixel)
  fi
enddef;
def cull text t = enddef;
def cullit = enddef;
newinternal xoffset, yoffset;

def screenchars = enddef;
def screenstrokes = enddef;
def imagerules = enddef;
def gfcorners = enddef;
def nodisplays = enddef;
def notransforms = let t_ = \ enddef;

% ----- start of modifications by Linus Romer -----
inner end, bye; let savedend=end; let savedbye=bye;
def end = 
 write
 "mf2outline: font_size " & decimal designsize & char 10 &
 for fvar = "font_slant", "font_normal_space", "font_normal_stretch",
 "font_normal_shrink", "font_x_height", "font_quad", 
 "font_extra_space", "font_underline_position", 
 "font_underline_thickness", "font_os_weight", "font_os_width":
  if known scantokens (fvar & "_"):
   "mf2outline: " & fvar & " " &
   scantokens ("decimal " & fvar & "_") & char 10 &
  fi
 endfor
 if known font_range_[1]:
  "mf2outline: font_range " & decimal(font_range_[1]) 
   & " " & decimal(font_range_[2]) 
   & " " & decimal(font_range_[3]) & char 10 &
 fi
 for fvar = "font_identifier", "font_coding_scheme", "font_version",
  "font_copyright", "font_version", "font_name", "font_fullname", 
  "font_familyname":
   if known scantokens (fvar & "_"):
    "mf2outline: " & fvar & " " & scantokens (fvar & "_") & char 10 &
   fi
 endfor
 if hex(kernclassesl_[0][0])>0:
  "mf2outline: kerningclassesl " & char 10 &
  for i=1 upto hex(kernclassesl_[0][0]):
   for j=1 upto hex(kernclassesl_[i][0]):
    kernclassesl_[i][j] & char 32 &
   endfor
   char 10 &
  endfor
 fi
 if hex(kernclassesr_[0][0])>0:
  "mf2outline: kerningclassesr " & char 10 &
  for i=1 upto hex(kernclassesr_[0][0]):
   for j=1 upto hex(kernclassesr_[i][0]):
    kernclassesr_[i][j] & char 32 &
   endfor
   char 10 &
  endfor
 fi
 if (hex(kernclassesl_[0][0])>0) and (hex(kernclassesr_[0][0])>0):
  "mf2outline: kerningmatrix " & char 10 &
  for i=1 upto hex(kernclassesl_[0][0]):
   for j=1 upto hex(kernclassesr_[0][0]):
    if known kernmatrix_[i][j]:
     decimal(kernmatrix_[i][j]) & char 32 &
    else:
     char 48 & char 32 &
    fi
   endfor
   char 10 &
  endfor
 fi
 if hex(ligatures_[0][0])>0:
  "mf2outline: ligatures " & char 10 &
  for i=1 upto hex(ligatures_[0][0]):
   for j=1 upto hex(ligatures_[i][0]):
    ligatures_[i][j] & char 32 &
   endfor
   char 10 &
  endfor
 fi
 if randvariants_[-1][0]>0:
  "mf2outline: randvariants " & char 10 & 
  for i=1 upto randvariants_[-1][0]:
   unicodeeps(randvariants_[-1][i]) & char 32 & 
   for j=1 upto randvariants_[randvariants_[-1][i]][0]:
    unicodeeps(randvariants_[randvariants_[-1][i]][j]) & char 32 &
   endfor
   char 10 &
  endfor
 fi
 if hex(fontforgecommands_[0])>0:
  "mf2outline: fontforge " & char 10 &
  for i=1 upto hex(fontforgecommands_[0]):
   fontforgecommands_[i] & char 10 &
  endfor
 fi
 "mf2outline: eof"
 to "mf2outline.txt"; 
savedend; 
enddef;
let bye = end;
outer end, bye;
% ----- end of modifications by Linus Romer -----

clear_pen_memory;     % initialize the `savepen' mechanism
mode_setup;           % establish proof mode as the default
numeric mode,mag;     % but leave mode and mag undefined

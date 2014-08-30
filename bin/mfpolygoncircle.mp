% by Linus Romer (inspired by mf2pt1.mp)

input mfplain;

pen penpolygoncircle;
penpolygoncircle:=makepen(
 for alpha=0 step 360/20 until 359:
  (0.5 cosd alpha, 0.5 sind alpha)--
 endfor 
 cycle);
pen pencircle;
pencircle:=penpolygoncircle;

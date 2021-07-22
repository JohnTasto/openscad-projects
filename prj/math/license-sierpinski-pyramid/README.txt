                   .:                     :,                                          
,:::::::: ::`      :::                   :::                                          
,:::::::: ::`      :::                   :::                                          
.,,:::,,, ::`.:,   ... .. .:,     .:. ..`... ..`   ..   .:,    .. ::  .::,     .:,`   
   ,::    :::::::  ::, :::::::  `:::::::.,:: :::  ::: .::::::  ::::: ::::::  .::::::  
   ,::    :::::::: ::, :::::::: ::::::::.,:: :::  ::: :::,:::, ::::: ::::::, :::::::: 
   ,::    :::  ::: ::, :::  :::`::.  :::.,::  ::,`::`:::   ::: :::  `::,`   :::   ::: 
   ,::    ::.  ::: ::, ::`  :::.::    ::.,::  :::::: ::::::::: ::`   :::::: ::::::::: 
   ,::    ::.  ::: ::, ::`  :::.::    ::.,::  .::::: ::::::::: ::`    ::::::::::::::: 
   ,::    ::.  ::: ::, ::`  ::: ::: `:::.,::   ::::  :::`  ,,, ::`  .::  :::.::.  ,,, 
   ,::    ::.  ::: ::, ::`  ::: ::::::::.,::   ::::   :::::::` ::`   ::::::: :::::::. 
   ,::    ::.  ::: ::, ::`  :::  :::::::`,::    ::.    :::::`  ::`   ::::::   :::::.  
                                ::,  ,::                               ``             
                                ::::::::                                              
                                 ::::::                                               
                                  `,,`


https://www.thingiverse.com/thing:2573402
spiral vase Sierpinski pyramid (Openscad) by aeropic is licensed under the Creative Commons - Attribution license.
http://creativecommons.org/licenses/by/3.0/

# Summary

Ricktu has got a great idea to design a single line with contiuous cross section 3D fractal. It prints well when sliced with cura, but is not perfect when sliced with slic3r.

I then designed my own under openscad. It's a quite simple very small code using a recursive module.

Please, watch the video to see it printed and you'll get the idea of this fractal spiral mode object !  https://youtu.be/ihfkdBEPOOo

As it is designed with Openscad it becomes a customizable object where you can parametrize the width of the smallest pyramid and the fractal order.
- size parameter is the radius of the smallest pyramid in the fractal
- order defines the number of recursive iterations

The one you see in the first picture has been printed with a 3mm radius and a fractal order of 5. It's already a big object of 135mm which printed during 9 hours and 30 minutes.
[size = 3 order = 5] will buid a pyramid = 2^5 x 1.414 x 3mm = 135 mm of side lenght

EDIT 171117 : fixed a bug, now slices perfectly at size = 2

# Print Settings

Printer: ANET A8
Rafts: No
Supports: No
Resolution: 0.2 with a 0.4 nozzle
Infill: none - spiral vase

Notes: 
You'll have to set your slicer to spiral vase mode. No top layer, one single bottom layer.

Layer thickness has to be set à 0.2 mm

# How I Designed This

## what is spiral vase mode ?

the Spiral Vase setting of Slic3r  will raise Z continuously avoiding a layer-change point which would cause a visible seam.

To allow this 3D fractal to be printed in spiral mode, it is needed that every layer is a continuous non crossing pattern. Which is the case here as every layer is a Sierpinski 2D fractal known as a Sierpinski curve. (see: https://en.wikipedia.org/wiki/Sierpi%C5%84ski_curve)

Sierpiński curves are a recursively defined sequence of continuous closed plane fractal curves discovered by Wacław Sierpiński, which is an example of a space-filling curve.

![Alt text](https://cdn.thingiverse.com/assets/3d/8d/7d/ce/0b/RepetierHost_sierpinsky_curve.jpg)

Finally, the printer will follow a single continuous line from its entry point (red arrow at the bottom layer) up to the pyramid summit (red arrow on top).

This makes a mesmerizing print !

![Alt text](https://cdn.thingiverse.com/assets/4d/34/f7/18/17/RepetierHost_sierpinski.jpg)
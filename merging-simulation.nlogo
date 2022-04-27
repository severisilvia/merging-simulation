globals [
  lanes          ; a list of the y coordinates of different lanes
  number-of-lanes
  starting-number-of-cars

  xcor-start-of-merging-lane  ; CRITICAL ZONE
  xcor-merging-point
  xcor-end-of-merging-lane

  xcor-start-of-control-zone  ; CONTROL ZONE
  xcor-end-of-control-zone

  delta-x-min
]

turtles-own [
  speed          ; the current speed of the car
  top-speed      ; the maximum speed of the car
  target-lane    ; the desired lane of the car 1 main, -1 secondary
  forward-car    ; the forward car on the street
  associated-car ;the car on the main lane asocciated with me
]

to setup
  clear-all
  set-default-shape turtles "car"
  set number-of-lanes 2
  set starting-number-of-cars (number-of-cars-main-lane + number-of-cars-second-lane)

  if starting-number-of-cars > 8 [set starting-number-of-cars 8 ]
  if starting-number-of-cars < 3 [set starting-number-of-cars 3 ]

  ;CRITICAL ZONE
  set xcor-end-of-merging-lane 30
  set xcor-start-of-merging-lane (xcor-end-of-merging-lane - 5)
  set xcor-merging-point xcor-start-of-merging-lane + 3

  ;CONTROL ZONE
  set xcor-start-of-control-zone 5
  set xcor-end-of-control-zone xcor-merging-point

  set delta-x-min 6
  draw-road
  create-or-remove-cars-main-lane
  create-or-remove-cars-second-lane
  reset-ticks
end

to create-or-remove-cars-main-lane
  let road-patches-main patches with [pycor = 1]
  let road-patches-secondary patches with [pycor = -1 and pxcor <= xcor-start-of-merging-lane]
  if number-of-cars-main-lane > count road-patches-main  [
    set number-of-cars-main-lane count road-patches-main
  ]
   create-turtles (number-of-cars-main-lane - count turtles with [ycor = 1]) [
    set color car-color
    ifelse free road-patches-main != Nobody
      [ move-to min-one-of free road-patches-main [pxcor]
       set target-lane pycor
       set heading 90
       set top-speed 0.5
       set speed 0.3 + random-float 0.05
       set forward-car nobody
    ]
    [  set number-of-cars-main-lane number-of-cars-main-lane - 1
       die ]
  ]
  if count turtles with [ycor = 1] > starting-number-of-cars [
    let n count turtles with [ycor = 1] - starting-number-of-cars
    ask n-of n [ other turtles with [ycor = 1 and xcor > (xcor-end-of-merging-lane + 3)]] of one-of turtles [ die ]
  ]
end

to create-or-remove-cars-second-lane
  let road-patches-main patches with [pycor = 1]
  let road-patches-secondary patches with [pycor = -1 and pxcor <= xcor-start-of-merging-lane]
  if number-of-cars-second-lane > count road-patches-secondary  [
    set number-of-cars-second-lane  count road-patches-secondary
  ]
  create-turtles (number-of-cars-second-lane - count turtles with [ycor = -1]) [
    set color car-color
   ifelse free road-patches-secondary != Nobody
      [ move-to min-one-of free road-patches-secondary [pxcor]
       set target-lane pycor
       set heading 90
       set top-speed 0.5
       set speed 0.3 + random-float 0.05
       set forward-car nobody
    ]
    [  set number-of-cars-second-lane number-of-cars-second-lane - 1
       die ]


  ]
  if count turtles with [ycor = -1] > 4 [
    let n count turtles with [ycor = -1] - 4
    ask n-of n [ other turtles with [ycor = -1]] of one-of turtles [ die ]
  ]

end

to-report free [ road-patches ] ; turtle procedure
  let this-car self
  report road-patches with [remainder pxcor delta-x-min = 0 and not any? turtles-here and not any? turtles-on neighbors ]
end

;here I have to draw the merging between the two lanes
to draw-road
  ask patches [
    ; the road is surrounded by green grass of varying shades
    set pcolor pink + 2.5 - random-float 0.5
  ]
  set lanes n-values number-of-lanes [ n -> number-of-lanes - (n * 2) - 1 ]
  let n 0 - number-of-lanes
  ask patches with [ abs pycor > n and abs pycor <= number-of-lanes ] [set pcolor white - random-float 0.25]
  ask patches with [  pycor >= 0 and abs pycor <= number-of-lanes and pxcor <= xcor-end-of-merging-lane ] [set pcolor white - random-float 0.25]
  ask patches with [  pycor < 0  and pxcor > xcor-end-of-merging-lane ] [set pcolor pink + 2.5  - random-float 0.5]

  draw-road-lines

end

to draw-road-lines
  let y (last lanes) - 1 ; start below the "lowest" lane
  while [ y <= first lanes + 1 ] [
    if not member? y lanes [

      if y = number-of-lanes         ; draw upper lane line
        [ draw-line y black 1]
      if  y = (0 - number-of-lanes)   ; draw lower lane line
        [ draw-line y black  -1]
      if y = 0                       ;draw middle lane lines
        [ draw-line y black  0]      ;first horizontal middle line

    ]

    set y y + 1 ; move up one patch
  ]
end


to draw-line [ y line-color kind ]  ; kind=1 upper lane, kind=0 and kind=-1 middle lanes, kind=-2 lower lane
  ; We use a temporary turtle to draw the line:
  ; - with a gap of zero, we get a continuous line;
  ; - with a gap greater than zero, we get a dasshed line.
  create-turtles 1 [
    setxy (min-pxcor - 0.5) y
    hide-turtle
    set color line-color
    set heading 90

    if kind = 1 [                  ;upper  line
      pen-down
      forward world-width + 1
      pen-up
    ]
    if kind = 0 [                   ; first middle line
      pen-down
      forward xcor-start-of-merging-lane
      pen-up
     ]

    if kind = -1 [                     ; lower lines both horizontals and vertical
      pen-down
      forward xcor-end-of-merging-lane
      left 90
      forward number-of-lanes
      right 90
      forward (world-width - xcor-end-of-merging-lane + 2)
      pen-up
    ]
    die
  ]

end


to go
  create-or-remove-cars-second-lane
  create-or-remove-cars-main-lane
  ask turtles [move-forward] ;TRACKING ALGORITHM ALWAYS
  ask turtles with [target-lane = -1 and xcor >= xcor-start-of-control-zone and xcor <= xcor-merging-point] [change-speed] ; ALGORITHM TO FOLLOW ON THE CONTROL ZONE
  ask turtles with [target-lane = -1 and xcor >= xcor-merging-point and xcor < xcor-end-of-merging-lane] [do-merging] ; MERGING ON THE CRITICAL ZONE

  tick
end


to move-forward ; turtle procedure --> implementation of the tracking algorithm
  set heading 90
  let delta-x 0
  let forward-speed 0   ; information about speed of B
  let forward-position 0 ;information about position of B
  let n (world-width - xcor)
  if (n < 0)[ set n 0]
  if debug [print(word "in-cone radius " n)]
  let forward-cars other turtles in-cone n 45 with [ycor = [ycor] of myself ] ; I find the set of forward cars
  set forward-car min-one-of forward-cars [xcor - [xcor] of myself] ; I keep only the nearest forward car
  let flag 0
  ifelse forward-car = Nobody
  [ set forward-car min-one-of turtles with [ycor = [ycor] of myself][xcor]
    set delta-x  (world-width - xcor + [xcor] of forward-car - size)
    set flag 1 ] ; flag used for the right formula in the equation of stop
  [  set delta-x  ([xcor] of forward-car - xcor - size)  ;save the distance between me and the forward car -->
                                                                ;Δxmin = δ + xsize where xsize is fixed vehicle size and δ is minimal safe tracking distance
                                                                ; in our case xsize=1 because 0.5 from me and 0.5 from the forward car
  ]


  set forward-speed [speed] of forward-car
  set forward-position [xcor] of forward-car

  if debug [print(word "I am " who " and my distance between the forward car " forward-car " is " delta-x)]
  ;starting with the algorithm

  ifelse delta-x < delta-x-min
  [ ;if debug [print(word "turtle " who " decrease speed delta-x < delta-x-min")]
    decrease-speed
    update-position
    ;if debug [print(word "the speed of turtle " who " is: " speed)
    ;            print(word "the position of turtle " who " is: " xcor) ]
     ]
  [ ifelse forward-speed > speed
    [ ;if debug [print(word "turtle " who " increase speed because delta-x => delta-x-min and forward-speed > speed")]
      increase-speed
      update-position
     ;if debug [print(word "the speed of turtle " who " is: " speed)
     ;          print(word "the position of turtle " who " is: " xcor) ]
    ]
    [ifelse equation self forward-car flag < delta-x-min ; con questa velocità riesco a frenare in tempo?
      [ ;if debug [print(word "turtle " who " decrease speed because delta-x => delta-x-min but forward-speed <= speed and equation < delta-x-min ")]
       decrease-speed
       update-position
      ;if debug [print(word "the speed of turtle " who " is: " speed)
      ;          print(word "the position of turtle " who " is: " xcor) ]
      ]
      [;if debug [ print(word "turtle " who " increase speed because delta-x => delta-x-min and forward-speed <= speed and equation >= delta-x-min")]
       increase-speed
       update-position
      ;if debug [print(word "the speed of turtle " who " is: " speed)
      ;         print(word "the position of turtle " who " is: " xcor) ]
      ]
    ]
  ]

end

to-report equation[A B flag]  ;refers to equation (9)
  ;if debug [print(word "A: " A " initial-speed " [initial-speed] of A " initial-position " [initial-position] of A)]
  ;if debug [print(word "B: "B " initial-speed " [initial-speed] of B " initial-position " [initial-position] of B)]
  let one (((([speed] of A )^ 2 - ([speed] of B) ^ 2) / (2 * deceleration)) + (([speed] of B - [speed] of A) / 2))
  let ris 0
  ifelse flag = 1
  [set ris (one + world-width - [xcor] of A + [xcor] of B - size) ]
  [set ris (one + [xcor] of B  - [xcor] of A - size) ]

  ;if debug [print(word "result: "ris)]
  report (abs ris)
end

to increase-speed   ; refers to equation (3)
  set speed (speed + acceleration)
  if speed > top-speed [ set speed top-speed ]
end

to decrease-speed ; refers to equation (3)
  set speed (speed - deceleration)
  if speed < 0 [ set speed 0.05]
end
to update-position ;refers to equation (4)
  forward speed
end

to change-speed
  let associated-cars other turtles in-cone world-width 190
  if debug [print(word "associated cars : " associated-cars)]
  set associated-car min-one-of associated-cars with [target-lane = 1] [ distance myself ]  ; I do the association whith the nearest vehice in the main lane
  let delta-x_s xcor-merging-point - [xcor] of self
  let delta-x_m xcor-merging-point - [xcor] of associated-car
  if debug [print(word "association between " who " and " associated-car)]
  if debug [print(word "x_s  : " delta-x_s)]
  if debug [print(word "x_m  : " delta-x_m)]

  ifelse delta-x_s < delta-x_m
  [ ask associated-car [decrease-speed] ]
  [ decrease-speed ]
end


to do-merging
  set heading 0
  forward 2
  set target-lane 1
end

to-report car-color
  ; give all cars a blueish color, but still make them distinguishable
  report one-of [ blue cyan sky ] + 1.5 + random-float 1.0
end
@#$#@#$#@
GRAPHICS-WINDOW
225
10
1440
355
-1
-1
19.8
1
10
1
1
1
0
1
1
1
0
60
-8
8
1
1
1
ticks
30.0

BUTTON
10
10
75
45
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
150
10
215
45
go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
80
10
145
45
go once
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

SLIDER
10
50
215
83
number-of-cars-main-lane
number-of-cars-main-lane
1
8
5.0
1
1
NIL
HORIZONTAL

SLIDER
10
115
215
148
acceleration
acceleration
0.005
0.005
0.005
0
1
NIL
HORIZONTAL

SLIDER
10
80
215
113
number-of-cars-second-lane
number-of-cars-second-lane
0
3
1.0
1
1
NIL
HORIZONTAL

SLIDER
10
150
215
183
deceleration
deceleration
0.15
0.15
0.15
0
1
NIL
HORIZONTAL

SWITCH
10
185
215
218
debug
debug
1
1
-1000

PLOT
220
360
645
535
avarage speed on main lane
NIL
avarage speed
0.0
10.0
0.0
0.5
true
false
"" ""
PENS
"default" 1.0 0 -2064490 true "" "plot mean [ speed ] of turtles with [target-lane = 1]"

@#$#@#$#@
## SAFE MERGING SIMULATION ##
<br>This project is part of the exam for the course "Distributed Artificial intelligence" provided by University of Modena and Reggio Emilia.
<br>The project is a Netlogo simulation of the algorithms proposed in <a href="https://github.com/severisilvia/merging-simulation/blob/main/A%20Novel%20Safe%20Merging%20Algorithm%20for%20Connected%20Vehicles.pdf">this</a> paper.
<br>The parameters used for the simulation are:
<ul>
  <li> aacc =  0.005</li>
  <li> adec =  0.15 </li>
  <li> τ= 1 </li>
  <li> Δxmin =  6 </li>
  <li> Top-speed = 0.5</li>
  <li> Max initial number of cars on main lane = 8 </li>
  <li> Max initial number of cars on secondary lane = 3</li>
  <li> Max number of cars on the main lane after some merging = initial number of cars on main lane + initial number of cars on secondary lane </li>
</ul>
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.2.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
1
@#$#@#$#@

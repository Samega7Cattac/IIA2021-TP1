globals[gvar] ; gvar foi so para ter um exemplo de variavel global k n é um controlo
breed[cats cat]
breed[mice mouse]
turtles-own [energy]
mice-own [infected]
cats-own [death-infected]

to setup
  ca
  setup-patches
  setup-agents
  reset-ticks
end

to setup-patches
  ask patches[
    set-patch-default
  ]
end

to set-patch-default
  let x 28
  let y 48
  if pycor mod 2 = 0
  [set x 48 set y 28]
  ifelse pxcor mod 2 = 0
  [set pcolor x]
  [set pcolor y]
end

to setup-agents
  create-mice N-mice
  [
    set shape "mouse side"
    set color 4
    setxy random-pxcor random-pycor
    ifelse random 100 < pinfected [set infected true]
    [set infected false]
    set energy nenergy * 2
  ]
  create-cats N-cats
  [
    set shape "cat"
    set color black
    let x one-of patches with [not any? mice-here and not any? mice-on neighbors and not any? cats-here]
    setxy [pxcor] of x [pycor] of x
    set heading one-of [0 90 180 270]
    set energy nenergy
    set death-infected false
  ]
end

to go
  if random 100 < 25 [ask one-of patches with [not any? mice-here or not any? cats-here][set pcolor blue]]
  go-mice
  go-cats
  tick
  if count mice = 0 or count cats = 0 [stop]
end

to go-mice
  ask mice
  [
    move-mice
    eat-food
    little-mice
    set energy energy - energy_per_tick
    if energy < 0 [die]
  ]
end

to little-mice
  let x count mice-on patches in-radius 2
  if x > 2 and x < 5
  [
    if random 100 < pbreed [hatch-mice random 2]
  ]
end

to eat-food
  (ifelse any? patches in-cone 1 180 with [pcolor = red]
  [
    set energy energy + energy / 2
    ask one-of patches in-cone 1 180 with [pcolor = red] [set-patch-default]
  ]
  any? patches in-cone 1 180 with [pcolor = blue]
  [
    set energy energy + gain_energy
    ask one-of patches in-cone 1 180 with [pcolor = blue] [set-patch-default]
  ])
end

to-report detect-cats
  foreach [1 2 3 4]
  [
    if any? cats-on patches in-cone 5 90
    [
      rt 180
      report true
    ]
    rt 90
  ]
  report false
end

to-report detect-food
  foreach [1 2 3 4]
  [
    (ifelse any? patches in-cone 5 90 with [pcolor = red] [report true]
    any? patches in-cone 5 90 with [pcolor = blue] [report true])
    rt 90
  ]
  report false
end

to move-mice
  let food false
  if not detect-cats [set food detect-food]
  if not food and random 100 < pturn [rt one-of [90 60 -90 -60]]
  move-to patch-ahead 1
end

to-report detect-mouse
  rt 90
  if any? mice-on patches in-cone 3 90 [report true]
  rt 180
  if any? mice-on patches in-cone 3 90 [report true]
  rt 90
  report false
end

to-report move-to-mouse
  (ifelse any? mice-on patches in-cone 7 30
  [
    move-to patch-ahead 2
    report true
  ]
  detect-mouse
  [
    move-to patch-ahead 1
    report true
  ]
  [report false])
end

to go-cats
  ask cats
  [
    ifelse energy < max_energy
    [
      if not move-to-mouse [move-cat]
      eat-mouse
    ]
    [move-cat]
    set energy energy - energy_per_tick
    if energy < 0 [die-cat]
  ]
end

to move-cat
  if random 100 < pturn [rt one-of [90 60 -90 -60]]
  move-to patch-ahead 1
end

to die-cat
  ifelse death-infected [ask patch-here [set pcolor red]]
  [ask patch-here [set pcolor blue]]
  die
end

to eat-mouse
  if any? mice-on patches in-cone 1 180
  [
    ask one-of mice-on patches in-cone 1 180
    [
      ifelse infected [set gvar true]
      [set gvar false]
      die
    ]
    set death-infected gvar
    if death-infected [die-cat]
    ifelse energy + gain_energy > max_energy [set energy max_energy]
    [set energy energy + gain_energy]
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
647
448
-1
-1
13.0
1
10
1
1
1
0
1
1
1
-16
16
-16
16
0
0
1
ticks
30.0

SLIDER
23
63
195
96
N-mice
N-mice
0
20
20.0
1
1
NIL
HORIZONTAL

SLIDER
23
101
195
134
N-cats
N-cats
0
10
10.0
1
1
NIL
HORIZONTAL

BUTTON
24
25
90
58
NIL
setup\n
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
105
24
168
57
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
24
145
81
190
NIL
ticks
17
1
11

SLIDER
684
22
856
55
nenergy
nenergy
0
100
50.0
1
1
NIL
HORIZONTAL

SLIDER
687
77
859
110
max_energy
max_energy
0
100
75.0
1
1
NIL
HORIZONTAL

SLIDER
881
78
1055
111
gain_energy
gain_energy
0
max_energy
15.0
1
1
NIL
HORIZONTAL

SLIDER
881
23
1053
56
energy_per_tick
energy_per_tick
0
nenergy / 10
0.5
0.5
1
NIL
HORIZONTAL

SLIDER
689
190
861
223
pbreed
pbreed
0
100
15.0
1
1
NIL
HORIZONTAL

MONITOR
230
463
357
508
Numero de Ratos
count mice
0
1
11

MONITOR
426
463
555
508
Numero de Gatos
count cats
0
1
11

SLIDER
690
242
862
275
pinfected
pinfected
0
100
15.0
1
1
NIL
HORIZONTAL

SLIDER
688
137
860
170
pturn
pturn
0
100
25.0
1
1
NIL
HORIZONTAL

PLOT
701
318
1194
484
Numero de Ratos
tick
N
0.0
0.0
0.0
0.0
true
true
"" ""
PENS
"N Ratos" 1.0 0 -16777216 true "" "plot count mice"
"N Gatos" 1.0 0 -7500403 true "" "plot count cats"

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
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

cat
false
0
Line -7500403 true 285 240 210 240
Line -7500403 true 195 300 165 255
Line -7500403 true 15 240 90 240
Line -7500403 true 285 285 195 240
Line -7500403 true 105 300 135 255
Line -16777216 false 150 270 150 285
Line -16777216 false 15 75 15 120
Polygon -7500403 true true 300 15 285 30 255 30 225 75 195 60 255 15
Polygon -7500403 true true 285 135 210 135 180 150 180 45 285 90
Polygon -7500403 true true 120 45 120 210 180 210 180 45
Polygon -7500403 true true 180 195 165 300 240 285 255 225 285 195
Polygon -7500403 true true 180 225 195 285 165 300 150 300 150 255 165 225
Polygon -7500403 true true 195 195 195 165 225 150 255 135 285 135 285 195
Polygon -7500403 true true 15 135 90 135 120 150 120 45 15 90
Polygon -7500403 true true 120 195 135 300 60 285 45 225 15 195
Polygon -7500403 true true 120 225 105 285 135 300 150 300 150 255 135 225
Polygon -7500403 true true 105 195 105 165 75 150 45 135 15 135 15 195
Polygon -7500403 true true 285 120 270 90 285 15 300 15
Line -7500403 true 15 285 105 240
Polygon -7500403 true true 15 120 30 90 15 15 0 15
Polygon -7500403 true true 0 15 15 30 45 30 75 75 105 60 45 15
Line -16777216 false 164 262 209 262
Line -16777216 false 223 231 208 261
Line -16777216 false 136 262 91 262
Line -16777216 false 77 231 92 261

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

mouse side
false
0
Polygon -7500403 true true 38 162 24 165 19 174 22 192 47 213 90 225 135 230 161 240 178 262 150 246 117 238 73 232 36 220 11 196 7 171 15 153 37 146 46 145
Polygon -7500403 true true 289 142 271 165 237 164 217 185 235 192 254 192 259 199 245 200 248 203 226 199 200 194 155 195 122 185 84 187 91 195 82 192 83 201 72 190 67 199 62 185 46 183 36 165 40 134 57 115 74 106 60 109 90 97 112 94 92 93 130 86 154 88 134 81 183 90 197 94 183 86 212 95 211 88 224 83 235 88 248 97 246 90 257 107 255 97 270 120
Polygon -16777216 true false 234 100 220 96 210 100 214 111 228 116 239 115
Circle -16777216 true false 246 117 20
Line -7500403 true 270 153 282 174
Line -7500403 true 272 153 255 173
Line -7500403 true 269 156 268 177

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

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

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

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.1.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="5vs10" repetitions="30" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>count cats</metric>
    <metric>count mice</metric>
    <enumeratedValueSet variable="pbreed">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max_energy">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="gain_energy">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nenergy">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pturn">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="N-cats">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pinfected">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="N-mice">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy_per_tick">
      <value value="0.5"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="1vs20" repetitions="30" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>count cats</metric>
    <metric>count mice</metric>
    <enumeratedValueSet variable="pbreed">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max_energy">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="gain_energy">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nenergy">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pturn">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="N-cats">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pinfected">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="N-mice">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy_per_tick">
      <value value="0.5"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="10vs20" repetitions="30" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count cats</metric>
    <metric>count mice</metric>
    <enumeratedValueSet variable="pbreed">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max_energy">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="gain_energy">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nenergy">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pturn">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="N-cats">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pinfected">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="N-mice">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energy_per_tick">
      <value value="0.5"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
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
0
@#$#@#$#@

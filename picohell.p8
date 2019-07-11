pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- pico hell
-- by cpiod

-- state:
-- 0: player turn
-- 1: player aim
-- 2: enemy turn
-- 100: title screen
-- 101: game over screen

-- flag: 0:non-walkable
-- 1:bullet-opaque

-- sfx: 0:bullet
-- 1: error

function _init()
 poke(0x5f2d, 1)
 palt(0, false)
 palt(14, true)
 x=5
	y=8
	light_x=1
	light_y=1
	facing=1
	cam_x=0
	cam_y=0
	state=100
	--music(0)
 bullet_anim=false
 bullets={}
 entities={make_enemy(0,3,8)}
 barrels={make_barrel(2,10)}
 ammo={12,0,0}
 p_weapons={make_weapon(0)}
 p_currentw=1
end

function show_ctrl()
 title_cam_y=128
 old_state=state
 state=102
end

-->8
-- draw

title_cam_y=0

function _draw()
 if(state<100) _draw_game()
 if(state==100 or state==102) _draw_title()
 if state==101 then
  title_cam_y+=1.3
  _draw_title()
  if title_cam_y>=128 then
   state=1
   show_ctrl()
  end
 end
end

pentacle={{"o",0,0,47},
{"o",0,0,39},
{"l",38,-8,-24,31},
{"l",-24,31,3,-39},
{"l",3,-39,20,32},
{"l",20,32,-34,-16},
{"l",-34,-16,38,-8},
{"o",38,-8,8},
{"o",3,-39,4},
{"o",-34,-16,6},
{"o",-24,31,4},
{"o",20,32,6},
{"l",35,-17,10,-11},
{"l",35,-17,26,-9},
{"o",35,-17,3},
{"o",110-64,55-64,1},
{"l",34,19,-36,16},
{"o",-36,16,3},
{"p",-36,16},
{"l",34,19,19,5},
{"o",34,19,5},
{"p",35,-17},
{"l",-39,-2,-47,-3},
{"l",-39,-2,-22,-5},
{"l",-39,-2,-14,6},
{"o",-39,-2,2},
{"o",-47,-3,2},
{"l",-25,-30,-30,-36},
{"o",-30,-36,3},
{"p",-30,-36},
{"l",-25,-30,-18,-14},
{"l",-25,-30,7,-4},
{"o",7,-4,2},
{"l",-15,-22,-12,-30},
{"o",-15,-22,3},
{"o",-12,-30,3},
{"l",12,45,10,38},
{"o",12,45,2},
{"l",10,38,1,17},
{"l",10,38,10,23},
{"o",1,17,2},
{"o",-27,-38,1},
{"l",12,-45,11,-37},
{"o",12,-45,2},
{"l",11,-37,5,-30},
{"l",11,-37,8,-17}
}

function draw_pentacle(c)
 for v in all(pentacle) do
--  local c=2
  if v[1]=="l" then
   local x,y=rotate(v[2],v[3])
   local x2,y2=rotate(v[4],v[5])
   if(v[6]!=nil) c=v[6]
   line(x,y,x2,y2,c)
  elseif v[1]=="o" then
   local x,y=rotate(v[2],v[3])
   circfill(x,y,v[4]*mul,0)
   circ(x,y,v[4]*mul,c)
  elseif v[1]=="p" then
   local x,y=rotate(v[2],v[3])
   pset(x,y)
  end
 end
end

function rotate(x,y)
 return mul*(x*cosa-y*sina)+x0,mul*(x*sina+y*cosa)+y0
end

function _draw_title()
cls()
camera()
local a=t()/300
--local a=0
cosa,sina=cos(a),sin(a)
mul=min(t()/50+0.8,1.5)
x0=64
y0=64
draw_pentacle(9)
camera(0, title_cam_y)
--spr(64,40,45,7,4)
spr(64,13,55,7,2)
spr(96,8+7*8,55,7,2)
print_center("a jupiter hell demake by cpiod",15*8+1,6)
local y,d=168,7
print_center("press 🅾️ to start ",80,7)
print_center("controls",y-2*d,7)
print_center("press ⬅️⬆️⬇️➡️ to move    ",y,6)
print_center("press 🅾️ to shoot ",y+2*d,6)
print_center("hold 🅾️ to aim ",y+3*d,6)
print_center("press ❎ to reload ",y+5*d,6)
print_center("hold ❎ to switch weapon ",y+6*d,6)
print_center("hold ⬇️ to grab ",y+7*d,6)
print_center("kill all the demons!",y+9*d,8)
--print((stat(32)-64).." "..(stat(33)-64),0,0,11)
--pset(stat(32),stat(33),11)
end

function print_center(s,y,c)
local x=64-#s*2
rectfill(x-1,y-1,x+#s*4+3,y+5,0)
print(s,x,y,c)
end

-- x0,y0,mul,a0
pentacles_pos={{64,64,1.5,0}}
--{rnd()*128,rnd()*128,rnd(0.5)+0.5,rnd()}}

function _draw_game()
 cls()
 camera()
 clip(0,8,128,112)
 for p in all(pentacles_pos) do
  local a=t()/300+p[4]
  cosa,sina=cos(a),sin(a)
  mul=p[3]
  x0=p[1]
  y0=p[2]
	 draw_pentacle(2)
	end
 camera(cam_x+8*x-64,cam_y+8*y-64)
 
 -- unseen map and entities
 for i=0,7 do
  pal(i,0)
 end
 for i=8,15 do
  pal(i,5)
 end
 map(0,0,0,0)
 
 -- entities
 for e in all(entities) do
  if(is_visible(e.x,e.y,false)) spr(e.sprnb,8*e.x,8*e.y-2)
 end
 
  -- barrels
 for b in all(barrels) do
  if(is_visible(b.x,b.y,false)) spr(4,8*b.x,8*b.y-2)
 end
 
 -- lit map and entities
 pal()
  
 palt(0, false)
 palt(14, true)
 light_range=7
 if light_x>0 or light_y>0 then
  i0,i1=0,light_range
 else
  i0,i1=-light_range,0
 end
 for i=i0,i1 do
  l=ceil(abs(i)*2/3)
  for j=-l,l do
   local x2,y2
   if light_y!=0 then
    x2,y2=x+j,y+i
   else
    x2,y2=x+i,y+j
   end
 
   if is_visible(x2,y2,false) then
    map(x2,y2,8*x2,8*y2,1,1)
    -- color entities sprites
    for e in all(entities) do
     if(e.x==x2 and e.y==y2) spr(e.sprnb,8*e.x,8*e.y-2)
    end
    for b in all(barrels) do
     if(b.x==x2 and b.y==y2) spr(4,8*b.x,8*b.y-2)
    end
   end
  end
 end

 -- player
 local s=32
 if(t()%1>0.5) s=33
 spr(s,x*8,y*8-2,1,1,facing>0)
 
 -- aim
 if state==1 then
  local s=17
  -- aim on player
  if(a_x==x and a_y==y) s=19
  -- no los
  if(not is_visible(a_x,a_y,true)) s=19
--  if(los_line(a_x,a_y,x,y,nil_fun,chk_opaque,true)) s=19
  spr(s,a_x*8,a_y*8-2)
 end
-- los_line(x,y,1,1,los_test,chk_wall)
 
 if(bullet_anim) draw_bullets()
 
 clip()
 camera()
 -- health bar
 color(3)
 print("♥========",16,1)
 
 print(p_currentw.." "
 ..weapon_name[p_currentw].." "
 ..p_weapons[p_currentw].amm
 .."/"..p_weapons[p_currentw].mag
 .." ("..ammo[p_currentw]..")",
 16,15*8+1)
 flip()
end

function draw_bullets()
 for b in all(bullets) do
  pset(b.x0,b.y0)
  b.x0+=b.vx
  b.y0+=b.vy
  b.dur-=1
  if(b.dur==0) del(bullets,b)
 end
 if(#bullets==0) bullet_anim=false
end

function los_test(x,y)
-- if fget(mget(x,y))%2==1 then
  spr(2,x*8,y*8)
-- end
end

-->8
-- entity

-- weapons type:
-- 0: pistol
-- 1: shotgun
-- 2: rifle

weapon_name={"pistol","shotgun","rifle"}

-- weapon struct:
-- x,y: position (if on floor)
-- amm: current ammo in magazine
-- mag: magazine size
-- bul: bullet per shot
-- rng: max range
-- dmg: dmmage
-- disp: dispersion
function make_weapon(typ)
	if(typ==0) return {mag=6,amm=6,bul=1,rng=5,dmg=4,disp=1}
	return nil
end

-- enemy struct:
-- sprnb: sprite number
-- x,y: pos
-- hp: health point
-- wpn: weapon struct
function make_enemy(typ,x,y)
 if(typ==0) return {sprnb=48,x=x,y=y,hp=10,wpn=make_weapon(0)}
 return nil
end

-- barrel struct:
-- x,y: pos
function make_barrel(x,y)
	return {x=x,y=y}
end
-->8
-- gameloop

dep={{-1,0},{1,0},nil,{0,-1},
nil,nil,nil,{0,1}}

function _update()
 printh(stat(0).."kb "..(stat(1)*100).."%")
 if state==100 then
  if(btnp()!=0) state=101
 elseif state==101 or state==102 then
  if btnp()!=0 then
   menuitem(2,"show controls",show_ctrl)
   state=0
   music(-1)
  end
 end
 
 if(bullet_anim) return

 --player turn
 if state==0 then
  local d=dep[btnp()]
  --move
  if d!=nil then
   local next_x=x+d[1]
   local next_y=y+d[2]
   light_x=d[1]
   light_y=d[2]
   if(d[1]!=0) facing=d[1]
   --check collision
   if fget(mget(next_x,next_y))%2==0 then
    x=next_x
    y=next_y
    state=2 --end of turn
    --update camera
    local cam_xc=d[1]*20
    local cam_yc=d[2]*20
    if(cam_x<cam_xc) cam_x+=4
    if(cam_x>cam_xc) cam_x-=4
    if(cam_y<cam_yc) cam_y+=4
    if(cam_y>cam_yc) cam_y-=4
   end
  --start aim
  elseif btn(5) then
   if p_weapons[p_currentw].amm == 0 then
    --no ammo !
    sfx(1)
   else
    state=1
    --todo: aim an enemy
    a_x=x
    a_y=y
   end
  elseif btn(4) then
   printh(ammo)
   local w=p_weapons[p_currentw]
   local amount=min(ammo[p_currentw],w.mag-w.amm)
   ammo[p_currentw]-=amount
   w.amm+=amount
   state=2 --end of turn
  end
  
 --player aim
 elseif state==1 then
  local d=dep[band(btnp(),15)]
  --aim
  if d!=nil then
   a_x+=d[1]
   a_y+=d[2]
   --orient lamp according to aim
   local a=a_x-x
   local b=a_y-y
   if(a!=0) facing=a_x-x
   if(a>abs(b)) light_x,light_y=1,0
   if(b>abs(a)) light_x,light_y=0,1
   if(a<-abs(b)) light_x,light_y=-1,0
   if(b<-abs(a)) light_x,light_y=0,-1
  end
  if not btn(5) then
   --no self-shot
   if a_x==x and a_y==y then
    sfx(1)
    state=0
   else
    --succesful shot
    p_weapons[p_currentw].amm-=1
--	   bullet_anim=true
	   local vx=(a_x-x)
	   local vy=(a_y-y)
	   add(bullets,{x0=8*x+4,y0=8*y+4,vx=vx,vy=vy,dur=10})
	   state=2 --end of turn
	   sfx(0)
   end
  end
  
 -- enemy turn  
 elseif state==2 then
  printh("enemy turn")
--  for i=1,5 do
--   flip() -- placeholder
--  end
  state=0
 end
end
-->8
-- los

function nil_fun(x,y)
 --spr(48,8*x,8*y)
end


function chk_wall(x,y)
 return band(fget(mget(x,y)),1)!=0
end

function chk_opaque(x,y)
 return band(fget(mget(x,y)),2)!=0
end

function is_visible(x2,y2,chk_last)
 return not los_line(x2,y2,x,y,nil_fun,chk_opaque,chk_last)
end

function los_line(x1, y1, x2, y2, fun, chk, chk_first)
  delta_x = x2 - x1
  ix = delta_x > 0 and 1 or -1
  delta_x = 2 * abs(delta_x)
 
  delta_y = y2 - y1
  iy = delta_y > 0 and 1 or -1
  delta_y = 2 * abs(delta_y)
 
  if(chk_first and chk(x1,y1)) return true
  fun(x1, y1)
 
  if delta_x >= delta_y then
    error = delta_y - delta_x / 2
 
    while x1 != x2 do
      if (error > 0) or ((error == 0) and (ix > 0)) then
        error = error - delta_x
        y1 = y1 + iy
      end
 
      error = error + delta_y
      x1 = x1 + ix
 
						if(chk(x1,y1)) return true
      fun(x1, y1)
    end
  else
    error = delta_x - delta_y / 2
 
    while y1 != y2 do
      if (error > 0) or ((error == 0) and (iy > 0)) then
        error = error - delta_y
        x1 = x1 + ix
      end
 
      error = error + delta_x
      y1 = y1 + iy
      if(chk(x1,y1)) return true
      fun(x1, y1)
    end
  end
  return false
end


__gfx__
00000000777777210000000000000000ee8888eeeeeeeeee11111110111111100000000000000000555555515555555155555551555555515555555100000000
00000000776666d20000000000000000e9a8822eeeeeeeee10000011100000100000000090000000511111515111115551111151511111555111115100000000
00700700766667d20000000000000000e9aa982eeee88e8e10000000000000100000000090000000511111515111111111111151511111111111115100000000
00077000766766d10000000000000000e9aa982eee88888e10000000000000100000000000000000511111515111111111111151511111111111115100000000
00077000767666d10000000000000000e9aa982ee88888ee10000000000000109999999090000000511111515111111111111151511111111111115100000000
00700700766666d10000000000000000e9aa982ee888888e10000000000000109009009090000000511111515111115551111151511111111111115100000000
000000002dddddd10000000000000000ee9998eeee88888e11000000000001109009009090000000551115515555555155555551551111111111155100000000
00000000222111110000000000000000eeeeeeeeeeee8eee01000000000001009009009090000000151115111111111111111111151111111111151100000000
00000000eee3eeeeeeeeeeeeeeeeeeee028228200000000011000000000001100000000099999990551115510000000000000000551111111111155100000000
00000000ee333eeeee555eeeee888eee02822820dd1ddddd10000000000000100000000990090090511111510000000000000000511111111111115100000000
00000000e3eee3eee5eee5eee8eee8ee028228206dd6666610000000000000100000000990090090511111510000000000000000511111111111115100000000
0000000033e3e33ee5e5e5eee8e8e8ee0282282066666d6610000000000000100000000091191190511111510000000000000000511111111111115100000000
00000000e3eee3eee5eee5eee8eee8ee02822820dddddddd10000000000000100000000900000000511111510000000000000000511111111111115100000000
00000000ee333eeeee555eeeee888eee028228201111111110000000000000100000000901011010511111510000000000000000511111555111115100000000
00000000eee3eeeeeeeeeeeeeeeeeeee028228201111111110000000000000100000000900010010555555510000000000000000555555515555555100000000
00000000eeeeeeeeeeeeeeeeeeeeeeee028228200000000010000000000000100000000900000010111111110000000000000000111111111111111100000000
eee555eeeeeeeeeeeee555eeeee555ee000000000000000010000000000000101111111011111111111111101111111000000000000000000000000000000000
ee5cc55eeee555eeee5cc55eee5cc55e000000000000000010000000000000101000001110000000000000111000001000000000000000000000000000000000
ee5c5333ee5cc55eee5c5333ee5c5333000000000000000010000000000000101000000000000000000000000000001000000000000000000000000000000000
666666ffee5c5333666666ff666666ff000000000000000010000000000000101000000000000000000000000000001000000000000000000000000000000000
e49449ff666666ffe49449ffe49449ff000000000000000010000000000000101000000000000000000000000000001000000000000000000000000000000000
eee555eee49449ffeee555eeeee555ee000000000000000010000000000000101000000000000000000000000000001000000000000000000000000000000000
eee5e5eeeee555eeeee5e5eeee5ee5ee000000000000000011000000000001101100000000000000000000000000011000000000000000000000000000000000
eee5e5eeeee5e5eeeee5ee5eee5ee5ee000000000000000001000000000001000100000000000000000000000000010000000000000000000000000000000000
eee555ee000000000000000000000000000000000000000011000000000001101100000000000000000000000000011000000000000000000000000000000000
ee8585ee000000000000000000000000000000000000000010000000000000101000000000000000000000000000001000000000000000000000000000000000
ee55522e000000000000000000000000000000000000000010000000000000101000000000000000000000000000001000000000000000000000000000000000
6666669e000000000000000000000000000000000000000010000000000000101000000000000000000000000000001000000000000000000000000000000000
e494499e000000000000000000000000000000000000000010000000000000101000000000000000000000000000001000000000000000000000000000000000
eee555ee000000000000000000000000000000000000000010000011100000101000001110000000000000111000001000000000000000000000000000000000
eee5e5ee000000000000000000000000000000000000000011111110111111101111111011111111111111101111111000000000000000000000000000000000
eee5e5ee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000
eee888888888eeee888eee8888888888eeeee88888888eeeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000
eee8888888888eee8882ee88888888822eee8888888882eeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000
eee88888888882ee8882ee8888888822eee88888888882eeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000
eee88822222882ee8882ee888222222eeee88822228882eeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000
eee8882eeee882ee8882ee8882eeeeeeeee8882eee8882eeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000
eee88828888882ee8882ee8882eeeeeeeee8882eee8882eeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000
eee88828888882ee8882ee8882eeeeeeeee8882eee8882eeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000
eee8882e888882ee8882ee8882eeeeeeeee8882eee8882eeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000
eee8882ee22222ee8882ee8882eeeeeeeee8882eee8882eeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000
eee8882eeeeeeeee8882ee8882eeeeeeeee8882eee8882eeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000
eee8882eeeeeeeee8882ee8882eeeeeeeee8882eee8882eeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000
eee8882eeeeeeeee8882ee8888888888eee88888888882eeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000
eee8882eeeeeeeee8882ee88888888822ee88888888822eeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000
eee8882eeeeeeeee8882ee8888888822eee8888888822eeeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000
eeee222eeeeeeeeee222eee22222222eeeee22222222eeeeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000
e888eeee88eeee888888888eeee888eeeeeeeee888eeeeeeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000
e8882eee888eee8888888888eee8882eeeeeeee8882eeeeeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000
e8882eee8882ee88888888882ee8882eeeeeeee8882eeeeeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000
e8882eee8882ee88822222222ee8882eeeeeeee8882eeeeeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000
e8882eee8882ee888eeeeeeeeee8882eeeeeeee8882eeeeeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000
e8882eee8882ee888888888eeee8882eeeeeeee8882eeeeeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000
e88888888882ee8888888888eee8882eeeeeeee8882eeeeeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000
e88888888882ee88888888882ee8882eeeeeeee8882eeeeeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000
e88888888882ee88822222222ee8882eeeeeeee8882eeeeeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000
e88822228882ee888eeeeeeeeee8882eeeeeeee8882eeeeeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000
e8882eee8882ee888eeeeeeeeee8882eeeeeeee8882eeeeeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000
e8882eee8882ee888888888eeee8888888888ee8888888888eeeeeee000000000000000000000000000000000000000000000000000000000000000000000000
e8882eee8882eee8888888882ee88888888822e88888888822eeeeee000000000000000000000000000000000000000000000000000000000000000000000000
ee882eee8882eeee888888882ee8888888822ee8888888822eeeeeee000000000000000000000000000000000000000000000000000000000000000000000000
eee22eeee222eeeee22222222eee22222222eeee22222222eeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0003000003000000010100000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0101010101010101010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0106070607060706070607060706070607060706073a3b363706070607060701000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01161716171617161716010101161716171617161728292a2b16171617161701000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012a2b26270107010101070607010706070607060738393a3b06070607060701000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012a2b2627011701012a2b2627161716172a2b2627060728292a2b2627161701000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
013a3b3637010101063a3b3637070607063a3b3637161738393a3b3637060701000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0128292a2b0601161628292a2b1716171628292a2b2627060728292a2b262701000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0138393a3b06070607010101010101060738393a3b3637161738393a3b363701000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01060728292a2b2601010728292a012627060728292a2b2627060728292a2b01000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0116173839013b3601161738393a3b3637161738393a3b3637161738393a3b01000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012627060701292a012627060728292a2b2627060728292a2b26270607282901000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
013637161738393a010137161738013a3b3637161738393a3b36371617383901000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012a2b08080607282901010101010128292a2b2627060728292a2b2627060701000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
013a3b0918161738393a3b3637161738393a3b3637161738393a3b3637161701000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01282908082627060728292a2b2627060728292a2b2627060728292a2b262701000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0138393a3b3637161738393a3b3637161738393a3b3637161738393a3b363701000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01060728292a2b2627060728292a2b2627060728292a2b2627060728292a2b01000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01161738393a3b3637161738393a3b3637161738393a3b3637161738393a3b01000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012627060728292a2b2627060728292a2b2627060728292a2b26270607282901000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
013637161738393a3b3637161738393a3b3637161738393a3b36371617383901000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012a2b2627060728292a2b2627060728292a2b2627060728292a2b2627060701000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
013a3b3637161738393a3b3637161738393a3b3637161738393a3b3637161701000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0128292a2b2627060728292a2b2627060728292a2b2627060728292a2b262701000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0138393a3b3637161738393a3b3637161738393a3b3637161738393a3b363701000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01060728292a2b2627060728292a2b1617060728292a2b2627060728292a2b01000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01161738393a3b3637161738393a3b0607161738393a3b3637161738393a3b01000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01262706072801010116170607282916172627060728292a2b26270607282901000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01363716010101010126271617383906073637161738393a3b36371617383901000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0102010101010101010137262706071617161716170607282916172627060701000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101013716170607060706071617383906073637161701000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010102171617161716172627060716171617161701000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010101010101013637161701010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000f05016050190501e0502305027050290502a0502a0502705026050210500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200000205003050030500c0500c0500b0500a0500a050070500305002050010500005000050050000400003000020000200000000000000000000000000000000000000000000000000000000000000000000
001900000e0000e0000e0000e0000c0000c0000e00010000010000200002000010000000000000000000100001000010000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001a00000005000050000500505000050000500005000050000500005000050000500005000050060500005006050000500005000050000500005000050000500305000050000500005000050000500005000050
001a00000061000610006100061000610006100061000610006100161001610016100161001610006100061000610006100061000610006100061001610006100061000610006100061000610006100161000610
__music__
03 0a0b4344
00 4a424344


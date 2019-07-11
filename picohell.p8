pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- pico hell (jupiter hell demake)
-- by cpiod

-- state:
-- 0: player turn
-- 1: player aim
-- 2: enemy turn
-- 100: title screen
-- 101: game over screen

-- flag: 0:non-walkable
-- 1:bullet-opaque

function _init()
 poke(0x5f2d, 1)
	x=8
	y=8
	facing=1
	cam_x=0
	cam_y=0
	state=100
	music(0)
 bullet_anim=false
 bullets={}
 entities={}
 ammo={12,0,0}
 p_weapons={make_weapon(0)}
 p_currentw=1
end

function show_ctrl()
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
  title_cam_y+=1
  _draw_title()
  if title_cam_y==128 then
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

function draw_pentacle()
 for v in all(pentacle) do
  local c=9
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
 return mul*(x*cosa-y*sina)+64,mul*(x*sina+y*cosa)+64
end

function _draw_title()
cls()
camera()
local a=t()/300
--local a=0
cosa,sina=cos(a),sin(a)
mul=min(t()/50+0.8,1.5)
draw_pentacle()
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

function _draw_game()
 cls()
 camera()
 local a=t()/300
 cosa,sina=cos(a),sin(a)
 mul=1.5
-- draw_pentacle()
 clip(0,8,128,112)
 camera(cam_x+8*x-64,cam_y+8*y-64)
 -- todo: background art?
 map(0,0,0,0)
 -- player
 spr(16,x*8,y*8,1,1,facing>0)
 -- aim
 if state==1 then
  local s=17
  -- aim on player
  if(a_x==x and a_y==y) s=18
  -- no los
  -- todo: compute at aim change
  if(los_line(a_x,a_y,x,y,nil_fun,chk_opaque)) s=19
  spr(s,a_x*8,a_y*8)
 end
-- los_line(x,y,1,1,los_test,chk_wall)
 
 if(bullet_anim) draw_bullets()
 
 clip()
 camera()
 -- health bar
 color(3)
 print("♥========",16,1)
 
 print(p_currentw.." "..weapon_name[p_currentw].." "..p_weapons[p_currentw].mag.."/"..ammo[p_currentw],16,15*8+1)
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
-- mag: magazine size
-- bul: bullet per shot
-- rng: max range
-- dmg: dmmage
-- disp: dispersion
function make_weapon(typ)
	if(typ==0) return {mag=6,bul=1,rng=5,dmg=4,disp=1}
	return nil
end

-- enemy struct:
-- x,y: pos
-- hp: health point
-- wpn: weapon struct
function make_enemy(typ,x,y)
 if(typ==0) return {x=x,y=y,hp=10,wpn=make_weapon(0)}
 return nil
end
-->8
-- gameloop

dep={{-1,0},{1,0},nil,{0,-1},
nil,nil,nil,{0,1}}

function _update()
 printh(stat(0).."kb "..stat(1).."%")
 if state==100 then
  if(btnp()!=0) state=101
 elseif state==101 then
  return
 elseif state==102 then
  if btnp()!=0 then
   menuitem(2,"show controls",show_ctrl)
   state=0
   music(-1)
  end
 end
 
 if(bullet_anim) return

 -- player turn
 if state==0 then
  local d=dep[btnp()]
  -- move
  if d!=nil then
   local next_x=x+d[1]
   local next_y=y+d[2]
   if fget(mget(next_x,next_y))%2==0 then
    x=next_x
    y=next_y
    state=2
    if(d[1]!=0) facing=d[1]
    local cam_xc=d[1]*20
    local cam_yc=d[2]*20
    if(cam_x<cam_xc) cam_x+=4
    if(cam_x>cam_xc) cam_x-=4
    if(cam_y<cam_yc) cam_y+=4
    if(cam_y>cam_yc) cam_y-=4
   end
  -- shoot
  elseif btn(5) then
   state=1
   -- todo: aim an enemy
   a_x=x
   a_y=y
  -- action button
  elseif btn(4) then
   printh("action button pressed")
  end
  
 -- player aim
 elseif state==1 then
  local d=dep[band(btnp(),15)]
  -- aim
  if d!=nil then
   a_x+=d[1]
   a_y+=d[2]
  end
  if not btn(5) then
   -- no self-shot
   if a_x==x and a_y==y then
    sfx(1)
    state=0
   else 
	   bullet_anim=true
	   local vx=(a_x-x)
	   local vy=(a_y-y)
	   add(bullets,{x0=8*x+4,y0=8*y+4,vx=vx,vy=vy,dur=10})
	   state=2
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

function nil_fun() end

function chk_wall(x,y)
 return band(fget(mget(x,y)),1)!=0
end

function chk_opaque(x,y)
 return band(fget(mget(x,y)),2)!=0
end

function los_line(x1, y1, x2, y2, fun, chk)
  delta_x = x2 - x1
  ix = delta_x > 0 and 1 or -1
  delta_x = 2 * abs(delta_x)
 
  delta_y = y2 - y1
  iy = delta_y > 0 and 1 or -1
  delta_y = 2 * abs(delta_y)
 
  if(chk(x1,y1)) return true
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
00000000777777210000000000000000008888000000000000000000000000050000000000000000000000000000000000000000000000000000000000000000
00000000776666d20cc000000000000009a882200000000005555500055555050000000090000000000000000000000000000000000000000000000000000000
00700700766667d20c0000000dddddd009aa98200000000005000555550005050000000090000000000000000000000000000000000000000000000000000000
00077000766766d100000cc00d0dd00009aa98200000000005000000000005050000000000000000000000000000000000000000000000000000000000000000
00077000767666d100000c000000000009aa98200000000005000000000005059999999090000000000000000000000000000000000000000000000000000000
00700700766666d100cc00000000000009aa98200000000005500000000055059009009090000000000000000000000000000000000000000000000000000000
000000002dddddd100c0000000ddd0dd009998000000000000500000000050059009009090000000000000000000000000000000000000000000000000000000
00000000122111110000000000000dd0000000000000000000500000000050059009009090000000000000000000000000000000000000000000000000000000
00333300000000000000000000000000000000000000000000500000000050050000000099999990000000000000000000000000000000000000000000000000
00414100003330000055500000888000000000000000000005500000000055050000000990090090000000000000000000000000000000000000000000000000
00111100030003000500050008000800000000000000000005000000000005050000000990090090000000000000000000000000000000000000000000000000
00111000030303000505050008080800000000000000000005000000000005050000000091191190000000000000000000000000000000000000000000000000
08888800030003000500050008000800000000000000000005000555550005050000000900000000000000000000000000000000000000000000000000000000
00811800003330000055500000888000000000000000000005555500055555050000000901011010000000000000000000000000000000000000000000000000
00111000000000000000000000000000000000000000000000000000000000050000000900010010000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000055555555555555550000000900000010000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00088888888800008880008888888888000008888888800000000000000000000000000000000000000000000000000000000000000000000000000000000000
00088888888880008882008888888882200088888888820000000000000000000000000000000000000000000000000000000000000000000000000000000000
00088888888882008882008888888822000888888888820000000000000000000000000000000000000000000000000000000000000000000000000000000000
00088822222882008882008882222220000888222288820000000000000000000000000000000000000000000000000000000000000000000000000000000000
00088820000882008882008882000000000888200088820000000000000000000000000000000000000000000000000000000000000000000000000000000000
00088828888882008882008882000000000888200088820000000000000000000000000000000000000000000000000000000000000000000000000000000000
00088828888882008882008882000000000888200088820000000000000000000000000000000000000000000000000000000000000000000000000000000000
00088820888882008882008882000000000888200088820000000000000000000000000000000000000000000000000000000000000000000000000000000000
00088820022222008882008882000000000888200088820000000000000000000000000000000000000000000000000000000000000000000000000000000000
00088820000000008882008882000000000888200088820000000000000000000000000000000000000000000000000000000000000000000000000000000000
00088820000000008882008882000000000888200088820000000000000000000000000000000000000000000000000000000000000000000000000000000000
00088820000000008882008888888888000888888888820000000000000000000000000000000000000000000000000000000000000000000000000000000000
00088820000000008882008888888882200888888888220000000000000000000000000000000000000000000000000000000000000000000000000000000000
00088820000000008882008888888822000888888882200000000000000000000000000000000000000000000000000000000000000000000000000000000000
00002220000000000222000222222220000022222222000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08880000880000888888888000088800000000088800000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08882000888000888888888800088820000000088820000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08882000888200888888888820088820000000088820000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08882000888200888222222220088820000000088820000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08882000888200888000000000088820000000088820000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08882000888200888888888000088820000000088820000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08888888888200888888888800088820000000088820000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08888888888200888888888820088820000000088820000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08888888888200888222222220088820000000088820000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08882222888200888000000000088820000000088820000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08882000888200888000000000088820000000088820000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08882000888200888888888000088888888880088888888880000000000000000000000000000000000000000000000000000000000000000000000000000000
08882000888200088888888820088888888822088888888822000000000000000000000000000000000000000000000000000000000000000000000000000000
00882000888200008888888820088888888220088888888220000000000000000000000000000000000000000000000000000000000000000000000000000000
00022000022200000222222220002222222200002222222200000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0003000003000000010100000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0101010101010101010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0106070607060706070607060706070607060706070607000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0116171617161716171617161716171617161716171617000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0106070607060706070607060706070607060706070607000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0116171617161716171617161716171617161716171617000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0106070607060706070607060706070607060706070607000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0116171617161716171601161716171617161716171617000001010000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100000000000000000001000008080800000000000000000000010000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100000000000000000001000009001800000000000000000000010000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100000000000000000001000009001800000000000000000000010000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100000000000000010101000008080800000000000000000101010000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100000000000000000101000000000000000000000000000001010000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100000000000000000001000000000000000000000000000000010000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100000000000000000001000000000000000000000000000000010000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100000000000000000001000000000000000000000000000000010000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100000000000000010101000000000000000000000000000101010000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000f05016050190501e0502305027050290502a0502a0502705026050210500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200000205003050030500c0500c0500b0500a0500a050070500305002050010500005000050050000400003000020000200000000000000000000000000000000000000000000000000000000000000000000
001900000e0500e0500e0500e0500c0500c0500e05010050010000200002000010000000000000000000100001000010000000000000000000000000000000000000000000000000000000000000000000000000
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


pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- pico hell
-- by cpio

-- state:
-- 0: player turn
-- 1: player aim
-- 2: enemy turn
-- 100: title screen
-- 101: controls
-- 102: game over screen

-- flag: 0: non-walkable
-- 1: bullet-opaque

-- sfx: 0: pistol
-- 1: shotgun
-- 2: rifle
-- 3: explosion
-- 4: player hurt
-- 5: ?
-- 6: reload
-- 7: medkit used
-- 8: error

function _init()
-- poke(0x5f2d, 1) -- mouse debug
 palt(0, false)
 palt(14, true)
 btnstat=0
 
 -- light direction
	light_x,light_y=1,1
	-- player sprite direction
	facing=1
	maxhp=100
	cam_x=0
	cam_y=0
	cam_xc=0
	cam_yc=0
	cam_dx=0
	cam_dy=0
	state=100
	--music(0)
 anim=false
 player={x=5,y=8,ox=8*5,oy=8*8,hp=maxhp,ent=9,deltatime=rnd(),wpn=make_weapon(2)}
 bullets={}
 floor_weapons={}
 decor={}
 soot={}
 explosion={}
 blood={}
 medkits={make_medkit(4,9)}
 medkits_used={}
-- add_blood(5,8)
-- entities={}
 entities={make_enemy(0,3,7)}
 add(entities,make_enemy(0,2,7))
 add(entities,make_enemy(0,2,8))
 barrels={make_barrel(5,7),make_barrel(7,7),make_barrel(9,7)}
 ammo={12,10,0}
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
print_center("a jupiter hell demake by cpiod",15*8+1,6,0)
local y,d=168,7
print_center("press 🅾️ to start",80,7,1)
print_center("controls",y-2*d,7,0)
print_center("press ⬅️⬆️⬇️➡️ to move",y,6,4)
print_center("press 🅾️ to shoot",y+2*d,6,1)
print_center("hold 🅾️ to aim",y+3*d,6,1)
print_center("press ❎ to reload",y+5*d,6,1)
print_center("hold ❎ to pick up",y+6*d,6,1)
print_center("kill all the demons!",y+9*d,8,0)
--print((stat(32)-64).." "..(stat(33)-64),0,0,11)
--pset(stat(32),stat(33),11)
end

function print_center(s,y,c,d)
-- d because there are "double" symbols (such as ❎)
local x=64-(#s+d)*2
rectfill(x-1,y-1,x+(#s+d)*4-1,y+5,0)
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
	
 camera(cam_x+cam_dx+player.ox-64,cam_y+cam_dy+player.oy-64) 
 -- unseen map
 set_unseen_color()
 map(0,0,0,0)
 
 -- lit map
 unset_unseen_color()
 light_range=7
 if light_x>0 or light_y>0 then
  i0,i1=-1,light_range
 else
  i0,i1=-light_range,1
 end
 for i=i0,i1 do
  l=max(1,ceil(abs(i)*2/3))
  for j=-l,l do
   local x2,y2
   if light_y!=0 then
    x2,y2=player.x+j,player.y+i
   else
    x2,y2=player.x+i,player.y+j
   end
 
   if is_visible(x2,y2,false) then
    map(x2,y2,8*x2,8*y2,1,1)
   end
  end
 end

 set_unseen_color()
 --  unseen entities
 for e in all(entities) do
  if(is_visible(e.x,e.y,false)) spr(e.sprnb,8*e.x,8*e.y-2,1,1,e.x<=player.x)
 end
 
  -- unseen barrels
 for b in all(barrels) do
  if(is_visible(b.x,b.y,false)) spr(5,8*b.x,8*b.y-2)
 end

 unset_unseen_color()
 -- lit entities
 for i=i0,i1 do
  l=max(2,ceil(abs(i)*2/3))
  for j=-l,l do
   local x2,y2
   if light_y!=0 then
    x2,y2=player.x+j,player.y+i
   else
    x2,y2=player.x+i,player.y+j
   end
 
   if is_visible(x2,y2,false) then
    -- color sprites
    for d in all(soot) do
     if(d.x==x2 and d.y==y2) spr(d.sprnb,8*d.x,8*d.y-2)
    end
    for d in all(decor) do
     if(d.x==x2 and d.y==y2) spr(d.sprnb,8*d.x,8*d.y-2)
    end
    for e in all(floor_weapons) do
     if(e.x==x2 and e.y==y2) spr(e.sprnb,8*e.x,8*e.y-2)
    end
    for e in all(medkits) do
     if(e.x==x2 and e.y==y2) spr(e.sprnb,8*e.x,8*e.y-2)
    end
    for e in all(entities) do
     if(e.x==x2 and e.y==y2) spr(e.sprnb+get_sprite_delta(e),e.ox,e.oy-2,1,1,e.x<=player.x)
    end
    for b in all(barrels) do
     if(b.x==x2 and b.y==y2) spr(5,8*b.x,8*b.y-2)
    end
   end
  end
 end

 -- player
 d=get_sprite_delta(player)
 local s=32
 spr(s+d,player.ox,player.oy-2,1,1,facing>0)
 
 -- aim
 if state==1 then
  local s=17
  -- aim on player
  if(a_x==player.x and a_y==player.y) s=19
  -- no los
  if(not is_visible(a_x,a_y,true)) s=19
  spr(s,a_x*8,a_y*8-2)
 end
 
 animate()
 clip()
 camera()
 -- health bar
 color(3)
 print("♥======== "..player.hp.."/"..maxhp,16,1)
 
 print(weapon_name[player.wpn.typ].." "
 ..player.wpn.amm
 .."/"..player.wpn.mag
 .." ("..ammo[player.wpn.typ]..")",
 16,15*8+1)
 flip()
end

function animate()
 anim=false
 cam_dx,cam_dy=0,0
 for bul in all(bullets) do
  anim=draw_bullets(bul) or anim
 end
 for e in all(explosion) do
  anim=explode(e) or anim
 end
 anim=animate_camera() or anim
 for e in all(entities) do
  anim=animate_ent(e) or anim
 end
 anim=animate_ent(player) or anim
 for tim in all(medkits_used) do
  animate_medkit(tim) -- non-blocking
 end
 for e in all(blood) do
  anim=anim_blood(e) or anim -- non-blocking
 end
end

function animate_medkit(tim)
 if t()-tim<=0.25 then
  r=300/4-(t()-tim)*300
  circ(player.ox+4,player.oy+2,r,12)
  return true
 end
 del(medkit_used,tim)
 return false
end

function animate_camera()
 if(cam_x<cam_xc) cam_x+=4
 if(cam_x>cam_xc) cam_x-=4
 if(cam_y<cam_yc) cam_y+=4
 if(cam_y>cam_yc) cam_y-=4
 return cam_x!=cam_xc or cam_y!=cam_yc
end

function animate_ent(e)
 local x=e.x*8
 local y=e.y*8
 if e.ox!=x or e.oy!=y then
  if(x-1>e.ox) e.ox+=4
  if(x+1<e.ox) e.ox-=4
  if(y-1>e.oy) e.oy+=4
  if(y+1<e.oy) e.oy-=4
--  if(abs(x-e.ox)==1) e.ox=x
--  if(abs(y-e.oy)==1) e.oy=y
 end
 return false
end

function draw_bullets(bul)
 for b in all(bul[1]) do
  pset(b.x0,b.y0,6)
  b.x0+=b.vx
  b.y0+=b.vy
  b.dur-=1
  if(b.dur<=0) del(bul[1],b)
 end
 if #bul[1]==0 then
  for param in all(bul[2]) do
   damage(param[1],param[2])
  end
  del(bullets,bul)
 end
 return #bullets>0
end

function get_sprite_delta(e)
 local d=0
 local t=t()--+e.deltatime
 if 8*e.x==e.ox and 8*e.y==e.oy then
  -- still
  if(t%(0.7)>0.35) d=1
 else
  -- moving
  d=2
  if(flr(t*10)%2==0) d=3
 end
 return d
end

function anim_blood(e)
 if e[5]<t() then
  del(blood,e)
  return false
 else
  e[4]+=0.5
  e[1]+=e[3]
  e[2]+=e[4]
  pset(e[1],e[2],8)
  return true
 end
end

function explode(ex)
 cam_dx=rnd(6)-3
 cam_dy=rnd(6)-3
 for e in all(ex[1]) do
  circfill(e.x,e.y,min(e.rad,200*(t()-e.t)),8)
  circfill(e.x,e.y,min(e.rad,200*(t()-e.t-0.1)),9)
  circfill(e.x,e.y,min(e.rad,200*(t()-e.t-0.3)),0)
  if 200*(t()-e.t-0.3)>e.rad then
   del(ex[1],e)
  end
 end
 if #ex[1]==0 then
  for param in all(ex[2]) do
   damage(param[1],param[2])
  end
  del(explosion,ex)
  return false
 end
 return true
end

function set_unseen_color()
 for i=0,7 do
  pal(i,0)
 end
 for i=8,15 do
  pal(i,5)
 end
end

function unset_unseen_color()
 pal()  
 palt(0, false)
 palt(14, true)
end
-->8
-- entity

-- entity type:
-- 0: weapon
-- 1: enemy
-- 2: barrel
-- 3: decoration
-- 4: wall
-- 9: player

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
-- used: ammo per shot
-- rng: max range
-- dmg: damage
-- disp: dispersion
-- sprnb: sprite number
function make_weapon(typ)
	if(typ==1) return {typ=1,mag=6,amm=6,bul=1,rng=5,dmg=3,disp=1,ent=0,sprnb=71,used=1}
	if(typ==2) return {typ=2,mag=1,amm=1,bul=5,rng=3,dmg=5,disp=5,ent=0,sprnb=71,used=1}
	if(typ==3) return {typ=3,mag=24,amm=6,bul=4,rng=5,dmg=4,disp=2,ent=0,sprnb=71,used=4}
	assert(false)
end

-- enemy struct:
-- sprnb: sprite number
-- x,y: pos
-- facing: sprite direction
-- ox,oy: temporary pos (for anim)
-- hp: health point
-- wpn: weapon struct
-- rng: preferred range

function make_enemy(typ,x,y)
 if(typ==0) return {facing=1,sprnb=48,x=x,y=y,ox=8*x,oy=8*y,hp=10,wpn=make_weapon(1),ent=1,rng=3,deltatime=rnd()}
	assert(false)
end

-- barrel struct:
-- x,y: pos
-- dmg: damage
function make_barrel(x,y)
	return {x=x,y=y,hp=1,dmg=50,ent=2}
end

-- x,y: pos
-- hp: hp gain
function make_medkit(x,y)
 return {x=x,y=y,hp=50,sprnb=87}
end

-- decorative struct:
-- x,y: pos
-- sprnb: sprite number
function add_blood(x,y)
 local l=88
-- printh("add_blood")
 for e in all(decor) do
--  printh(e.x.." "..e.y.." "..x.." "..y.." "..e.sprnb)
  if(e.x==x and e.y==y) l=min(90,e.sprnb+1) printh(e.sprnb)
 end
 add(decor,{x=x,y=y,sprnb=l,ent=3})
end

function add_soot(x,y)
 add(soot,{x=x,y=y,sprnb=36,ent=3})
end

-->8
-- gameloop

dep={{-1,0},{1,0},nil,{0,-1},
nil,nil,nil,{0,1}}

function _update()
 printh(stat(0).."kb "..(stat(1)*100).."%")
 -- no update during animation
 printh("anim="..tostr(anim))
 if(anim) return
 
 if state==100 then
  if(btnp()!=0) state=101
 elseif state==101 or state==102 then
  if btnp()!=0 then
   menuitem(2,"show controls",show_ctrl)
   state=0
   music(-1)
  end
 end
 
 new_btnstat=btn()
-- printh(btnstat.." "..new_btnstat)
 -- player turn
 if state==0 then
  local d=dep[btnp()]
  -- move
  if d!=nil then
   local next_x=player.x+d[1]
   local next_y=player.y+d[2]
   update_facing(d[1],d[2])
   -- check collision
   if can_go(next_x,next_y) then
    player.x=next_x
    player.y=next_y
    state=2 -- end of turn
    -- update camera
    cam_xc=d[1]*16
    cam_yc=d[2]*16
    -- pick up medkits
    for e in all(medkits) do
     if e.x==player.x and e.y==player.y then
      del(medkits,e)
      add(medkits_used,t())
      sfx(7)
      player.hp=min(maxhp,player.hp+e.hp)
     end
    end
   else
    player.ox+=4*d[1]
    player.oy+=4*d[2]
   end
  -- start aim
  elseif btn(5) then
   if player.wpn.amm == 0 then
    -- no ammo !
    sfx(8)
   else
    state=1
    local e=closest_enemy(player.x,player.y)
    if e==nil then
     a_x=player.x
     a_y=player.y
    else
     a_x=e.x
     a_y=e.y
     update_facing(a_x-player.x,a_y-player.y)
    end
   end
  elseif btn(🅾️) then
   local w=player.wpn
   if w.mag!=w.amm then
    local amount=min(ammo[player.wpn.typ],w.mag-w.amm)
    ammo[player.wpn.typ]-=amount
    w.amm+=amount
    state=2 -- end of turn
    sfx(6)
   else
    sfx(8)
   end
  end
  
 -- player aim
 elseif state==1 then
  local d=dep[band(btnp(),15)]
  -- aim
  if d!=nil then
   a_x+=d[1]
   a_y+=d[2]
   -- orient lamp according to aim
   local a=a_x-player.x
   local b=a_y-player.y
   update_facing(a,b)
  end
  if not btn(❎) then
   -- no self-shot
   if a_x==player.x and a_y==player.y then
    sfx(8)
    state=0
   else
    -- successful shot
    local w=player.wpn
    w.amm-=w.used
	   shoot(player.x,player.y,a_x,a_y,player.wpn)
	   state=2 -- end of turn
	   sfx(player.wpn.typ-1)
   end
  end
  
 -- enemy turn  
 elseif state==2 then
  printh("enemy turn")
  state=0--end turn
  for e in all(entities) do
   local moved=false
   local d=dist(player.x,player.y,e.x,e.y)
   if not is_visible(e.x,e.y,true) then
    -- do nothing if player not seen
   elseif d>e.rng then
    local dx,dy
    if player.x>e.x then
     dx=1
    else
     dx=-1
    end
    if player.y>e.y then
     dy=1
    else
     dy=-1
    end
    local next_x,next_y=e.x,e.y
    if abs(player.x-e.x)>=d/2 and can_go(e.x+dx,e.y) then
     next_x+=dx
    elseif abs(player.y-e.y)>=d/2 and can_go(e.x,e.y+dy) then
     next_y+=dy
    end
    if can_go(next_x,next_y) then
     e.x=next_x
     e.y=next_y
     moved=true
    end
   end
   if not moved and d<=e.rng+3 then
    printh("enemy attacks")
   	shoot(e.x,e.y,player.x,player.y,e.wpn)
   	sfx(e.wpn.typ-1)
   end
  end
 end
 btnstat=new_btnstat
end

-- shoot from x1,y1 to x2,y2
function shoot(x1,y1,x2,y2,w)
 for i=1,w.bul do
 	local d=dist(x1,y1,x2,y2)
  local dmg=w.dmg
  if(w.rng<d) dmg=ceil(dmg/3)
  local dx,dy=0,0
  if(rnd(w.disp*d)>7) dx=1
  if(rnd()>0.5) dx*=-1
  if(rnd(w.disp*d)>7) dy=1
  if(rnd()>0.5) dy*=-1
  x2+=dx
  y2+=dy
  local b={{},{}}
  e=los_line(x1,y1,x2,y2,nil_fun,chk_ent_and_wall,false)
  if e then
   x2=e.x
   y2=e.y
   add(b[2],{e,dmg})  
  end
  local speed=3
  x2+=(rnd(4)-2)/8
  y2+=(rnd(4)-2)/8
  local d=sqrt((x2-x1)^2+(y2-y1)^2)
  local vx=speed*(x2-x1)/d
  local vy=speed*(y2-y1)/d
  add(b[1],{x0=8*x1+4,y0=8*y1+4,vx=vx,vy=vy,dur=d*8/speed})
  add(bullets,b)
 end
end

function damage(e,dmg)
 if(not e.hp) return
 e.hp-=dmg
 if (e.ent==1 or e==player) then
  if(e==player) sfx(4)
  if e.hp<=0 then -- if dead, project blood
   for i=1,5 do
    local v=1+rnd(1)
    local a=rnd(0.5)
    add(blood,{e.ox+4+rnd(2)-1,e.oy+rnd(2)-1,
    cos(a)*v,sin(a)*v,t()+0.2+rnd(0.1)})
   end
  end
  add_blood(e.x,e.y)
 end
 if e.hp<=0 then
  if e==player then
   state=102 --game over
  elseif(e.ent==1) then
   del(entities,e)
   e.wpn.x=e.x
   e.wpn.y=e.y
   add(floor_weapons,e.wpn)
  elseif e.ent==2 then -- barrel
   local ex={{},{}}
   add(explosion,ex)
   sfx(3)
   for i=1,8 do
    add(ex[1],{x=8*e.x+rnd(16)-8,y=8*e.y+rnd(16)-8,rad=5+rnd(20),t=t()+rnd(0.3)})
   end
   del(barrels,e)
   for i=-3,3 do
    for j=-3,3 do
     local dmg=flr(e.dmg/(abs(i)+abs(j)+1))
     local x3,y3=e.x+i,e.y+j
     if(not chk_wall(x3,y3) and rnd()>0.4) add_soot(x3,y3)
     e2=chk_ent(x3,y3)
     if(e2) add(ex[2],{e2,dmg})--damage(e2,dmg)
    end
   end
  end
 end
end

function dist(x1,y1,x2,y2)
 return abs(x1-x2)+abs(y1-y2)
end

function can_go(next_x,next_y)
 return fget(mget(next_x,next_y))%2==0
      and not chk_ent(next_x,next_y)
end

function closest_enemy(x,y)
 local e2=nil
 local m=0
 for e in all(entities) do
  if is_visible(e.x,e.y,true) then
   local d=dist(player.x,player.y,e.x,e.y)
   if e2==nil or d<m then
    e2=e
    m=d
   end
  end
 end
 return e2
end

function update_facing(a,b)
 if(a!=0) facing=a
 if(a>abs(b)) light_x,light_y=1,0
 if(b>abs(a)) light_x,light_y=0,1
 if(a<-abs(b)) light_x,light_y=-1,0
 if(b<-abs(a)) light_x,light_y=0,-1
end

function get_floor_weapon()
 for e in all(floor_weapons) do
  if(e.x==player.x and e.y==player.y) return e
 end
end
-->8
-- los

function nil_fun(x,y)
end

-- check collision with entities
function chk_ent(x1,y1)
 if(x1==player.x and y1==player.y) return player
 for e in all(entities) do
  if(e.x==x1 and e.y==y1) return e
 end
 for e in all(barrels) do
  if(e.x==x1 and e.y==y1) return e
 end
end

function chk_ent_and_wall(x,y)
 local e=chk_ent(x,y)
 if(e) return e
 if(chk_wall(x,y)) return {ent=4,x=x,y=y}
end

function chk_wall(x,y)
 return band(fget(mget(x,y)),1)!=0
end

function chk_opaque(x,y)
 return band(fget(mget(x,y)),2)!=0
end

function is_visible(x2,y2,chk_last)
 return not los_line(x2,y2,player.x,player.y,nil_fun,chk_opaque,chk_last)
end

function los_line(x1, y1, x2, y2, fun, chk, chk_first)
 delta_x = x2 - x1
 ix = delta_x > 0 and 1 or -1
 delta_x = 2 * abs(delta_x)

 delta_y = y2 - y1
 iy = delta_y > 0 and 1 or -1
 delta_y = 2 * abs(delta_y)
 
 local b=chk(x1,y1)
 if(chk_first and b) return b
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

   local b=chk(x1,y1)
   if(b) return b
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
   local b=chk(x1,y1)
   if(b) return b
   fun(x1, y1)
  end
 end
end


__gfx__
00000000777777210000000000000000ee8888eeee888eee11111110111111100000000000000000000000000000000000000000000000000000000000000000
00000000776666d20000000000000000e9a8822ee82228ee10000011100000100000000090000000000000000000000000000000000000000000000000000000
00700700766667d20000000000000000e9aa982ee82228ee10000000000000100000000090000000000000000000000000000000000000000000000000000000
00077000766766d10000000000000000e9aa982ee98889ee10000000000000100000000000000000000000000000000000000000000000000000000000000000
00077000767666d10000000000000000e9aa982ee89988ee10000000000000109999999090000000000000000000000000000000000000000000000000000000
00700700766666d10000000000000000e9aa982ee88888ee10000000000000109009009090000000000000000000000000000000000000000000000000000000
000000002dddddd10000000000000000ee9998eee88888ee11000000000001109009009090000000000000000000000000000000000000000000000000000000
00000000222111110000000000000000eeeeeeeeee888eee01000000000001009009009090000000000000000000000000000000000000000000000000000000
00000000eee3eeeeeeeeeeeeeeeeeeee000000000000000011000000000001100000000099999990000000000000000000000000000000000000000000000000
00000000ee333eeeee555eeeee888eee000000000000000010000000000000100000000990090090000000000000000000000000000000000000000000000000
00000000e3eee3eee5eee5eee8eee8ee000000000000000010000000000000100000000990090090000000000000000000000000000000000000000000000000
0000000033e3e33ee5e5e5eee8e8e8ee000000000000000010000000000000100000000091191190000000000000000000000000000000000000000000000000
00000000e3eee3eee5eee5eee8eee8ee000000000000000010000000000000100000000900000000000000000000000000000000000000000000000000000000
00000000ee333eeeee555eeeee888eee000000000000000010000000000000100000000901011010000000000000000000000000000000000000000000000000
00000000eee3eeeeeeeeeeeeeeeeeeee000000000000000010000000000000100000000900010010000000000000000000000000000000000000000000000000
00000000eeeeeeeeeeeeeeeeeeeeeeee000000000000000010000000000000100000000900000010000000000000000000000000000000000000000000000000
eee555eeeeeeeeeeeee555eeeee555eeeeeeeeee0000000010000000000000101111111011111111111111101111111000000000000000000000000000000000
ee5cc55eeee555eeee5cc55eee5cc55eeee5eeee0000000010000000000000101000001110000000000000111000001000000000000000000000000000000000
ee5c5333ee5cc55eee5c5333ee5c5333ee515eee0000000010000000000000101000000000000000000000000000001000000000000000000000000000000000
666666ffee5c5333666666ff666666ffe51115ee0000000010000000000000101000000000000000000000000000001000000000000000000000000000000000
e49449ff666666ffe49449ffe49449ffe511115e0000000010000000000000101000000000000000000000000000001000000000000000000000000000000000
eee555eee49449ffeee555eeeee555eeee5155ee0000000010000000000000101000000000000000000000000000001000000000000000000000000000000000
eee5e5eeeee555eeeee5e5eeee5ee5eeeee5eeee0000000011000000000001101100000000000000000000000000011000000000000000000000000000000000
eee5e5eeeee5e5eeeeee55eeee5ee55eeeeeeeee0000000001000000000001000100000000000000000000000000010000000000000000000000000000000000
ee5555eeeeeeeeeeee5555eeee5555ee000000000000000011000000000001101100000000000000000000000000011000000000000000000000000000000000
ee8585eeee5555eeee8585eeee8585ee000000000000000010000000000000101000000000000000000000000000001000000000000000000000000000000000
ee55522eee8585eeee55522eee55522e000000000000000010000000000000101000000000000000000000000000001000000000000000000000000000000000
6666669eee55522e6666669e6666669e000000000000000010000000000000101000000000000000000000000000001000000000000000000000000000000000
e494499e6666669ee494499ee494499e000000000000000010000000000000101000000000000000000000000000001000000000000000000000000000000000
eee555eee494499eeee555eeeee555ee000000000000000010000011100000101000001110000000000000111000001000000000000000000000000000000000
eee5e5eeeee555eeeee5e5eeee5ee5ee000000000000000011111110111111101111111011111111111111101111111000000000000000000000000000000000
eee5e5eeeee5e5eeeeee55eeee5ee55e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000
eee888888888eeee888eee8888888888eeeee88888888eeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000
eee8888888888eee8882ee88888888822eee8888888882eeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000
eee88888888882ee8882ee8888888822eee88888888882eeeeeeeeee6666644e0000000000000000000000000000000000000000000000000000000000000000
eee88822222882ee8882ee888222222eeee88822228882eeeeeeeeeee4444e540000000000000000000000000000000000000000000000000000000000000000
eee8882eeee882ee8882ee8882eeeeeeeee8882eee8882eeeeeeeeeeeeeeeee40000000000000000000000000000000000000000000000000000000000000000
eee88828888882ee8882ee8882eeeeeeeee8882eee8882eeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000
eee88828888882ee8882ee8882eeeeeeeee8882eee8882eeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000
eee8882e888882ee8882ee8882eeeeeeeee8882eee8882eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000
eee8882ee22222ee8882ee8882eeeeeeeee8882eee8882eeeeeeeeeee777775eeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000
eee8882eeeeeeeee8882ee8882eeeeeeeee8882eee8882eeeeeeeeeee778775eeeeeee8eeeeeeeeeeee88e8e0000000000000000000000000000000000000000
eee8882eeeeeeeee8882ee8882eeeeeeeee8882eee8882eeeeeeeeeee788875eeeeeeeeeeeee888eee88888e0000000000000000000000000000000000000000
eee8882eeeeeeeee8882ee8888888888eee88888888882eeeeeeeeeee778775ee8eeeeeeee8888eee88888ee0000000000000000000000000000000000000000
eee8882eeeeeeeee8882ee88888888822ee88888888822eeeeeeeeeee777775eeeee8eeeeeee8eeee888888e0000000000000000000000000000000000000000
eee8882eeeeeeeee8882ee8888888822eee8888888822eeeeeeeeeeeee55555eeeeeeeeeeeeeeeeeee88888e0000000000000000000000000000000000000000
eeee222eeeeeeeeee222eee22222222eeeee22222222eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee8eee0000000000000000000000000000000000000000
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
0003000000000000010100000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
01060728292a2b2601010728292a0126270d0728292a2b2627060728292a2b01000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0116173839013b3601161738393a3b3637161738393a3b3637161738393a3b01000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012627060701292a012627060728292a2b2627060728292a2b26270607282901000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
013637161738393a010137161738013a3b3637161738393a3b36371617383901000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012a2b26270607282901010101010128292a2b2627060728292a2b2627060701000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
013a3b3637161738393a3b3637161738393a3b3637161738393a3b3637161701000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0128292a2b2627060728292a2b2627060728292a2b2627060728292a2b262701000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
012627060728292a2b26270607282916172627060728292a2b26270607282901000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
013637161738393a3b36371617383906073637161738393a3b36371617383901000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0102010607282928292a2b262706071617161716170607282916172627060701000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101011617383938393a3b013716170607060706071617383906073637161701000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010106072829010102171617161716172627060716171617161701000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010101010101013637161701010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000d6303a6403f6503a65021650096500665004630006200062000620006100061000610006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
00060000236302363002620026203a6503a6503a6503a620026200262002620006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
000600000d630326500d6300d630386500d6300d6302d6500d6300d6303f6500d6300d6300d6100d6100160001600016000060000600006000060000600006000060000600006000060000600006000060000600
000500002c6502e650116100c6100b620156302c6403f6503f6503e6503e6503e6503d6503b65036650326502f65026650216401e6401b64018630136300e6300963007620056200362000620006000060000600
000300000e3400b340093300733005320033200231000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
0003000007350053500435003350023500e3500b35005350023500135001350003500035000350003500030000300003000030000300003000030000300003000030000300003000030000300003000030000300
00040000236002360002600026002c6002c6002c60002600026000260002600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
0008000038f7033f6038f5031f5038f5033f5038f4032f3038f3032f3025f0038f0038f0038f0038f0038f0000f0000f0000f0000f0000f0000f0000f0000f0000f0000f003ff0000f0000f0000f0000f0000f00
001300002825004230052000220002200342000020000200142000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001a00000005000050000500505000050000500005000050000500005000050000500005000050060500005006050000500005000050000500005000050000500305000050000500005000050000500005000050
001a00000061000610006100061000610006100061000610006100161001610016100161001610006100061000610006100061000610006100061001610006100061000610006100061000610006100161000610
__music__
03 0a0b4344
00 4a424344


-- title:  copia vampire survivo
-- author: Jonata Chermont
-- desc:   primeiro video yt
-- script: Lua

game={
 solids={},
 seconds=60,
	hundredths=0,
 tics=0,
 camera_x=0,
 camera_y=0,
	points=0,
	shown_points=function(number,len_zero)
	 local points=tostring(number)
		local size=string.len(points)
		for i=len_zero-size,1,-1 do
		 points="0"..points
		end
		return points
	end,
	draw_points=function(self)
	 spr(8,40,-2,6,1,0,0,5,2)
	 print(
		 game.shown_points(game.points,4),
			53,
			3,
			15
		)
	end,
	draw_seconds=function(self)
	 spr(13,93,-2,6,1,0,0,2,2)
		print(
	 	self.shown_points(self.seconds,2),
	 	96,
		 3,
		 12
	 )
	end,
 collisionCheck=function()
  for i,e in ipairs(enemies) do
		 if math.abs(player.x-e.x)<9
			and math.abs(player.y-e.y)<9
			and player.invincibility_time==0 then
			 player.life=player.life-1
			 player.blink_time=120
			 player.invincibility_time=120
		 end
		end
 end,
 timeinc=function(self)
		if self.hundredths==100 then
		 self.seconds=self.seconds-1
		 self.hundredths=0
		else
		 self.hundredths=self.hundredths+1
		end
		if self.seconds==0 then
		 player.x=player.x+1
		end
 end,
 isTooCloseToPlayer=function(x,y)
  return math.abs(player.x-x)<10
  and math.abs(player.y-y)<10
 end,
 init_enemy=function(nx,ny,nsp)
  return{
   x=nx,
   y=ny,
   vx=0.5,
   vy=0.5,
   alive=true,
   timer=1,
   sp=nsp
  }
 end,
 spawn_enemy=function(self)
  local min=1
  local max=#sprites.enemy
  if self.tics==30 then
   local enemyX, enemyY
   repeat
			 local spawnAreaX=player.x-50
				local spawnAreaY=player.y-50
				local spawnAreaWidth=200
				local spawnAreaHeight=200
    enemyX=math.random(
				 math.floor(spawnAreaX),
					math.floor(spawnAreaX+spawnAreaWidth)
				)
    enemyY=math.random(
				 math.floor(spawnAreaY),
					math.floor(spawnAreaY+spawnAreaHeight)
				)
   until not self.isTooCloseToPlayer(enemyX,enemyY)
  	table.insert(
    enemies,
    self.init_enemy(
     enemyX,
     enemyY,
     sprites.enemy[math.random(min,max)]
    )
   )
		 self.tics=0
		else
		 self.tics=self.tics+1
		end
 end,
 spawn_bullet=function(nx,ny,issuer,nsp)
  return{
   x=nx,
   y=ny,
   vx=1,
   vy=1,
   on_screan=true,
   iss=issuer,
   sp=nsp
  }
 end,
	game_over=function(self)
	 local death="GAME OVER"
		local reset="aperte A para jogar novamente"
		local points="sua pontuacao: "
		print(death,85,60,12)
		print(reset,30,67,12)
		print(points..self.points,75,100,12)
		if btnp(6) then
		 player.life=3
			table.remove(enemies)
			player.x=120-4
			player.y=140-4
			self.tics=0
			self.seconds=60
			self.hundredths=0
			self.points=0
		end
	end,
}

function _init() 
	solid=function(x,y)
		local id=mget((x)//8,(y)//8)
		return game.solids[id]
 end
end

game.solids[2]=true
game.solids[3]=true
game.solids[4]=true
game.solids[5]=true
game.solids[6]=true
game.solids[7]=true
game.solids[18]=true
game.solids[19]=true
game.solids[20]=true
game.solids[21]=true
game.solids[22]=true
game.solids[23]=true

issuer={
 "up",
 "down",
 "left",
 "right"
}

sprites={
 bullet=336,
 enemy={320,322,324,326},
	player_frames={
  idle={256},
  walk_up={256,258},
  walk_down={256,258},
  walk_left={288,290,292,294}
 }
}

player={
 x=120-4,
 y=140,
	vx=1,
	vy=1,
	current_frame=1,
 current_animation="idle",
 speed=0.1,
 timer=0,
 life=3,
	flip=0,
	blink_time=0,
	invincibility_time=0,
	draw=function(self)
		if self.blink_time==0
		or self.blink_time%4<2 then
		 local frame=sprites.player_frames[self.current_animation][self.current_frame]
			 spr(
				 frame,
					self.x+game.camera_x,
					self.y+game.camera_y,
					6,
					1,
					self.flip,
					0,
					2,
					2
			 )
	 end
	end,
	life_draw=function(self)
	 for i=1,3 do
		 spr(34,-13+i*11,-2,6,1,0,0,2,2)
		end
		for i=1,self.life do
	  spr(32,-13+i*11,-2,6,1,0,0,2,2)
	 end
	end,
	move=function(self,dt)
  if btn(0) then
   self.y=self.y-self.vy
			self.current_animation="walk_up"
  elseif btn(1) then
   self.y=self.y+self.vy
			self.current_animation="walk_down"
		elseif btn(2) then
   self.x=self.x-self.vx
			self.flip=0
			self.current_animation="walk_left"
  elseif btn(3) then
   self.x=self.x+self.vx
			self.flip=1
			self.current_animation="walk_left"
		else
		 self.current_animation="idle"
  end
  self.timer=self.timer+dt
  if self.timer>=self.speed then
   self.current_frame=self.current_frame+1
   if self.current_frame> #sprites.player_frames[self.current_animation] then
    self.current_frame=1
   end
   self.timer=0
  end
 end,
	blink=function(self)
	-- atualiza o tempo de piscar do player
	 if self.blink_time>0 then
		 self.blink_time=self.blink_time-1
		end
	end,
	invincibility=function(self)
	-- atualiza o tempo de invencibilidade do player
	 if self.invincibility_time>0 then
		 self.invincibility_time=self.invincibility_time-1
		 bullets.state=false
		else
		 bullets.state=true
		end
	end,
 shoot=function(self)
		if bullets.state then
			if btnp(4,60,60) then
		  for i=1,4 do
					table.insert(
					 bullets,
						game.spawn_bullet(
						 self.x+5+game.camera_x,
							self.y+6+game.camera_y,
							issuer[i],
							sprites.bullet
						)
					)
				end
		 end
		end
 end,
	collisionTiles=function(self)
	 if btn(0) and solid(self.x+2,self.y+9)
		or btn(0) and solid(self.x+5,self.y+9)
		or btn(0) and solid(self.x+10,self.y+9)
		or btn(0) and solid(self.x+13,self.y+9)
		or btn(1) and solid(self.x+2,self.y+16)
		or btn(1) and solid(self.x,5,self.y+16)
		or btn(1) and solid(self.x+10,self.y+16)
		or btn(1) and solid(self.x+13,self.y+16) then
		 self.vy=0
		else
		 self.vy=1
		end
		if btn(2) and solid(self.x+1,self.y+10)
		or btn(2) and solid(self.x+1,self.y+13)
		or btn(2) and solid(self.x+1,self.y+15)
		or btn(3) and solid(self.x+14,self.y+10)
		or btn(3) and solid(self.x+14,self.y+13)
		or btn(3) and solid(self.x+14,self.y+15) then
		 self.vx=0
		else
		 self.vx=1
		end
	end,
}

enemies={
	draw=function(self)
	 for i,e in ipairs(self) do
			if e.alive then
				spr(
				 e.sp+e.timer%60//30*2,
					e.x+game.camera_x,
					e.y+game.camera_y,
					0
			 )
			end
		end
	end,
	move=function(self)
	 for i,e in ipairs(self) do
		 if e.x<player.x then
			 e.x=e.x+e.vx
				e.timer=e.timer+2
			end
	  if e.x>player.x then
			 e.x=e.x-e.vx
				e.timer=e.timer+2
			end
	  if e.y<player.y then
			 e.y=e.y+e.vy
				e.timer=e.timer+2
			end
			if e.y>player.y then
			 e.y=e.y-e.vy
				e.timer=e.timer+2
			end
		end
	end,
}

bullets={
 state=true,
	draw=function(self)
  for i,b in ipairs(self) do
	  if b.on_screan then
				spr(
				 b.sp,
					b.x,
					b.y,
					6
				)
			end
  end
 end,
 move=function(self)
  for i,b in ipairs(self) do
	  if b.iss=="up" then
				b.y=b.y-2
			elseif b.iss=="down" then
				b.y=b.y+2
			elseif b.iss=="left" then
				b.x=b.x-2
			elseif b.iss=="right" then
				b.x=b.x+2
			end
  end
 end,
 flag_oos=function(self)
	 for i,b in ipairs(self) do
			if b.x<30
			or b.x>210
			or b.y<30
			or b.y>126 then
				b.on_screan=false
			end
		end
 end,
 remove_oos=function(self)
	 for i,b in ipairs(self) do
			if not b.on_screan then
				table.remove(self,i)
			end
		end
 end,
 hit_target=function(self)
	 for i,b in ipairs(self) do
		 local bullet_x=b.x-game.camera_x
	  local bullet_y=b.y-game.camera_y
			for j,e in ipairs(enemies) do
				e.alive=not(
				 bullet_x<e.x+8 and
					bullet_x+8>e.x and
					bullet_y<e.y+8 and
					bullet_y+8>e.y
				)
				b.on_screan=e.alive
				if not e.alive then
					table.remove(enemies,j)
					table.remove(self,i)
					game.points=game.points+1
				end
			end
		end
 end,
	hit_tiles=function(self)
	 for i,b in ipairs(self) do
		 if solid(b.x-game.camera_x,b.y-game.camera_y)
			or solid(b.x+7-game.camera_x,b.y-game.camera_y)
			or solid(b.x-game.camera_x,b.y+7-game.camera_y)
			or solid(b.x+7-game.camera_x,b.y+7-game.camera_y) then
			 table.remove(self,i)
			end
		end
	end,
}

_init()
function TIC()
 cls()
 game.camera_x=-player.x+120
 game.camera_y=-player.y+68
	map(0,0,100,100,game.camera_x,game.camera_y,6)
	bullets:draw()
	player:draw()
	if player.life>0
	and game.seconds>1 then
		game:timeinc()
		player:life_draw()
		game:draw_seconds()
		game:draw_points()
		game:timeinc()
	 game.collisionCheck()
	 game:spawn_enemy()
	 bullets:move()
		bullets:hit_tiles()
	 bullets:flag_oos()
	 bullets:remove_oos()
	 bullets:hit_target()
	 player:shoot()
		player:collisionTiles()
	 player:move(1/90)
	 player:blink()
	 player:invincibility()
		enemies:draw()
	 enemies:move()
	else
	 game:game_over()
	if pmem(0)<game.points then
		 pmem(0,game.points)
		end
	print("MAIOR PONTUACAO: "..pmem(0),70,107,12)
	end
end

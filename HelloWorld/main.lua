-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here
--print("Hello World");
scrollSpeed = 10;
rocknum = 5;
craternum = 5;
count = 0;
jumpflag = true;
--physics
local physics = require("physics");
physics.start();
physics.setGravity(0,6.8);
--bg settings
local background = display.newImage("jpg/background2.png");
background.x = 0;
background.y = display.contentHeight/2;
local background2 = display.newImage("jpg/background2.png");
background2.x = background.x+3598;
background2.y = display.contentHeight/2;
--car settings
local car = display.newImage("jpg/car2.png");
car.x = background.x + 40;
car.y = background.y + 20;
car.name = "car";
opos = car.y;
carDied = false;
physics.addBody(car,"dynamic",{friction=0, bounce = 0.1});
--ground
local ground = display.newRect(car.x, car.y+20,100,2)
ground.name = "ground";
ground:setFillColor(0,0,0,0);
physics.addBody(ground,"static",{friction=0});
--traps
local traps = {};
--crater
for i=1,craternum do
	local crater = display.newImage("jpg/crater0.png");
	crater.x = background.x + 100 + i*math.random(450,1250);
	crater.y = background.y + 41;
	crater.name = "obstacle";
	physics.addBody(crater,"static",{friction=0});
	traps[i] = crater;
end
--rocks
for i=craternum,craternum+rocknum do
	rock = display.newImage("jpg/rock0.png");
	rock.x = background.x + 100 + 2*(i-1)*math.random(150,250);
	rock.y = background.y + 20;
	rock.name = "obstacle";
	physics.addBody(rock,"static",{friction=0});
	traps[i] = rock;
end

local function jump(obj)
	obj:applyForce(0,-10,obj.x,obj.y)
	ground:applyForce(0,-10,ground.x,ground.y)
	--print("jump!!!!!")
end

--bullet fly
local function flyingshoot(obj)
	local params = obj.source.params
	--print("flying " .. params.param1.name)
	if params.param1.x~=nil then
		params.param1.x = params.param1.x + 2;
	end
end
--remove obj
local function removeObj(event)
	local params = event.source.params
	--print("remove " ..params.param1.name)
	if params.param1["removeSelf"]~=nil then
		params.param1:removeSelf()
		params.param1 = nil
	end
end
--collision
local function onCollision(self, event)
	--kill car
	print(self.name);
	if (self.name == "car" and event.other.name == "obstacle") then
		carDied = true;
 		local tm = timer.performWithDelay(1, removeObj, 1)
 		tm.params = {param1 = self}
 	end
 	--local params = self.source.params
 	--give car jumpflag
 	if (self.name == "flybullet" and event.other.name == "obstacle") then
 		print("hitrock")
 		local tm1 = timer.performWithDelay(1, removeObj, 1)
 		tm1.params = {param1 = self}
 		local tm2 = timer.performWithDelay(1, removeObj, 1)
 		tm2.params = {param1 = event.other}
 		--jumpflag = true;
 		--print("ground give jump")
 	end
 end

function fireshooot(event)
	if (car ~= nil) and (car.x ~= nil) then
		bullet = display.newRect(car.x+60, car.y,10,3);
		--bullet = display.newImage("jpg/car2.png");
		--bullet.x = car.x + 150;
		--bullet.y = car.y;
		bullet.name = "flybullet";
		physics.addBody(bullet,"dynamic",{density=1,friction=0});
		bullet.gravityScale = 0;
		bullet.collision = onCollision;
		bullet:addEventListener("collision",bullet);
		local tm = timer.performWithDelay(1, flyingshoot, -1);
		local tmkill = timer.performWithDelay(5000, removeObj, 1);
 		tm.params = {param1 = bullet}
 		tmkill.params = {param1 = bullet}
	end
end

local function handleSwipe(event)
	--print("swipe");
	--print(jumpflag);
	if (event.phase == "moved" and jumpflag==true) then
		--print("what?")
		dy = event.y - event.yStart;
		if(dy < -5) then
			jumpflag = false;
			jump(event.target);
			velocity = car:getLinearVelocity();
			--print("jumped");
			--print(velocity);
		end
	elseif (event.phase == "ended" or event.phase == "cancelled") then
		jumpflag = true
		--print("canjump")
	end
	return true
end
--show traps
local drawTraps = function( event)
	for i,obj in ipairs(traps) do
		if obj.x ~= nil then
			obj.x = obj.x -4
		end
	end
end

 function onGlobalCollision(event)
 	--print(event.object1.name)
 	--print(event.object2.name)

 	if(event.object1.name == "flybullet") then
 		print("hit")
 		if(event.object2.name == "obstacle") then
 			local tm1 = timer.performWithDelay(200, removeObj, 1)
 			tm1.params = {param1 = event.object1}
 			local tm2 = timer.performWithDelay(200, removeObj, 1)
 			tm2.params = {param1 = event.object2}
 		end
 	elseif(event.object2.name == "flybullet") then
 		if(event.object1.name == "obstacle") then
 			local tm1 = timer.performWithDelay(200, removeObj, 1)
 			tm1.params = {param1 = event.object1}
 			local tm2 = timer.performWithDelay(200, removeObj, 1)
 			tm2.params = {param1 = event.object2}
 		end
 	end
 end
--background
function bgupdate( event )
	background.x = background.x - 4;
	background2.x = background2.x - 4;

	-- body
end
Runtime:addEventListener("enterFrame", bgupdate);
Runtime:addEventListener("enterFrame", drawTraps);
Runtime:addEventListener("tap", fireshooot);
car:addEventListener("touch",handleSwipe);
car.collision = onCollision;
car:addEventListener("collision",car);
--Runtime:addEventListener("collision",onGlobalCollision);
--Runtime:addEventListener("collision", onCollision)
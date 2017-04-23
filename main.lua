lume = require "lume"
--serialize = require 'ser'
--require "Tserial"
serialize = require 'ser'


-- -- 800*600~w*h
-- -- tiles = 50*50
-- -- 0x0 to 15x12
-- function gID(x,y)
--   return (x+(y*16))
-- end

-- function gY(id)
--   return math.floor(id / 16)
-- end

-- function gX(id)
--   return (id % 16)
-- end

-- -- screen coords
-- function gIDfromCoords(x,y)
--   return gID(math.floor(x/50),math.floor(y/50))
-- end

function resetCombat(ballXVel)
  -- toss ball in one players direction first -> ballXVel

  objects.pone.body:setX(70)
  objects.pone.body:setY(300)
  objects.ptwo.body:setX(800-70)
  objects.ptwo.body:setY(300)
  objects.ball.body:setX(400)
  objects.ball.body:setY(300)

  objects.pone.body:setLinearVelocity(0,0)
  objects.ptwo.body:setLinearVelocity(0,0)
  objects.ball.body:setLinearVelocity(ballXVel,0)

  resetTimer = 3

end


function love.load()

  -- tweaky constants

  pvel = 500
  prad = 20
  radius = 10
  c = 4000 -- gravity mass constant

  -----

  -- gamestate vars

  reset = false
  resetTimer = 0

  --------

  scoreOne = 0
  scoreTwo = 0

  lfont = love.graphics.newFont(50)
  sfont = love.graphics.newFont(20)


  -- editor = true -- DISABLE LEVEL EDITING

  -- WORLD BASICS
  love.physics.setMeter(64)
  -- no gravity
  world = love.physics.newWorld(0, 0*1.6*9.81*64, true)
  world:setCallbacks(beginContact, endContact, preSolve, postSolve) 

  objects = {}

  -- walls
  objects.twall = {}
  objects.twall.body = love.physics.newBody(world, 800/2, 0-13) 
  objects.twall.shape = love.physics.newRectangleShape(800, 50) 
  objects.twall.fixture = love.physics.newFixture(objects.twall.body, objects.twall.shape); 
  objects.twall.fixture:setUserData("topwall")

  objects.bwall = {}
  objects.bwall.body = love.physics.newBody(world, 800/2, 600+13)
  objects.bwall.shape = love.physics.newRectangleShape(800, 50) 
  objects.bwall.fixture = love.physics.newFixture(objects.bwall.body, objects.bwall.shape); 
  objects.bwall.fixture:setUserData("topwall")

  -- pong ball
  
  objects.ball = {}
  objects.ball.isPlayer = true
  objects.ball.body = love.physics.newBody(world, 800/2, 600/2, "dynamic")
  objects.ball.shape = love.physics.newCircleShape(  radius ) --the ball's shape has a radius of 20
  objects.ball.fixture = love.physics.newFixture(objects.ball.body, objects.ball.shape, 1) -- Attach fixture to body and give it a density of 1.
  --objects.ball.fixture:setFriction(0.3) -- TODO 
  objects.ball.body:setFixedRotation( true )
  objects.ball.fixture:setUserData("ball")
  -- TODO 
  objects.ball.fixture:setRestitution(1) -- perfect bounce

  -- planets

  -- DYNAMIC?
  
  objects.pone = {}
  objects.pone.isPlayer = true
  objects.pone.body = love.physics.newBody(world, 70, 300, "dynamic")
  objects.pone.shape = love.physics.newCircleShape(  prad ) 
  objects.pone.fixture = love.physics.newFixture(objects.pone.body, objects.pone.shape, 1) -- Attach fixture to body and give it a density of 1.
  --objects.ball.fixture:setFriction(0.3) -- TODO 
  objects.pone.body:setFixedRotation( true )
  objects.pone.fixture:setUserData("pone")

  objects.ptwo = {}
  objects.ptwo.isPlayer = true
  objects.ptwo.body = love.physics.newBody(world, 800-70, 300, "dynamic")
  objects.ptwo.shape = love.physics.newCircleShape(  prad ) 
  objects.ptwo.fixture = love.physics.newFixture(objects.ptwo.body, objects.ptwo.shape, 1) -- Attach fixture to body and give it a density of 1.
  --objects.ball.fixture:setFriction(0.3) -- TODO 
  objects.ptwo.body:setFixedRotation( true )
  objects.ptwo.fixture:setUserData("ptwo")


  --musicPiece1 = love.audio.newSource("LudumDare37Kitschig1.ogg")
   
  --voice1:setLooping(false)
  --musicPiece1:setPitch(0.4)
  --musicPiece1:play() -- change whatever... no plan TODO

  -- STATIC CAMERA
  -- cameraY = 0

  --picVictory = love.graphics.newImage("victory.png")
  -- rotation = 0

  -- blah = 0

  -- objects = {}

  -- tiles = {}
  
  -- for i = 0, (gID(15,12)) do
  --   tiles[i] = 0
  -- end
  -- tiles[5] = 1
  -- tiles[15] = 1
  -- tiles[0] = 1
  -- tiles[30] = 1
  -- tiles[16*12-1] = 1

  --tiles[key] = 'test'
  --print(tiles[{2,1}])
  --print(tiles[key])
  -- voice1:play()


  -- objects.ball.body:setPosition(589, -1235)
  --     objects.ball.body:setLinearVelocity(0, -50)

  --construct()

  --initial graphics setup
  love.graphics.setBackgroundColor(5, 5, 5) --set the background color to a nice blue
  love.window.setMode(800, 600) --set the window dimensions to 650 by 650

  resetCombat(0) -- init state wooo ^_^

end

function love.update(dt)
  
  if reset == true then
    resetCombat(0)
    reset = false
  end

  if resetTimer > 0 then
    resetTimer = resetTimer - dt*3
    resetTimer = lume.clamp(resetTimer , 0, 99999999)
  end


  -- print(resetTimer)

  -- Physics?

  -- Apply forces in direction of both planets
  poX = objects.pone.body:getX()
  poY = objects.pone.body:getY()
  ptX = objects.ptwo.body:getX()
  ptY = objects.ptwo.body:getY()
  bX = objects.ball.body:getX()
  bY = objects.ball.body:getY()

  distOne = lume.distance(bX, bY, poX, poY, false) -- true = squared
  distTwo = lume.distance(bX, bY, ptX, ptY, false)
  -- print(distOne)

  

  -- del x, del y
  dX = bX - poX
  dY = bY - poY
  -- norm it
  norm = lume.distance(0, 0, dX, dY, false)
  dX = dX / norm
  dY = dY / norm
  -- apply gravity
  dX = c * dX / distOne
  dY = c * dY / distOne

  -- and number two
  -- del x, del y
  dXt = bX - ptX
  dYt = bY - ptY
  -- norm it
  normt = lume.distance(0, 0, dXt, dYt, false)
  dXt = dXt / normt
  dYt = dYt / normt
  -- apply gravity
  dXt = c * dXt / distTwo
  dYt = c * dYt / distTwo

  -- total
  -- print(dX .. ":" .. dY .. ":" .. dXt .. ":" .. dYt)
  xForce = dXt + dX
  yForce = dYt + dY

  objects.ball.body:applyForce(-xForce, -yForce)




    --musicPiece2:stop()

   -- if(musicPiece3:isStopped()) the
  
  --cameraY = lume.lerp(cameraY,-objects.ball.body:getY()+love.graphics.getHeight()-200,1) -- TODO
 
  --if love.keyboard.isDown("right") or love.keyboard.isDown("d") then --press the right arrow key to push the ball to the right
   -- objects.ball.body:applyForce(400, 0)
  --end

 -- if love.keyboard.isDown("down") or love.keyboard.isDown("s") then
  

 if(resetTimer == 0) then

  if love.keyboard.isDown("d") then
    objects.pone.body:applyForce(pvel, 0)
  elseif love.keyboard.isDown("a") then
    objects.pone.body:applyForce(-pvel, 0)
  end

  if love.keyboard.isDown("s") then
    objects.pone.body:applyForce(0, pvel)
  elseif love.keyboard.isDown("w") then
    objects.pone.body:applyForce(0, -pvel)
  end

  if love.keyboard.isDown("right") then
    objects.ptwo.body:applyForce(pvel, 0)
  elseif love.keyboard.isDown("left") then
    objects.ptwo.body:applyForce(-pvel, 0)
  end

  if love.keyboard.isDown("down") then
    objects.ptwo.body:applyForce(0, pvel)
  elseif love.keyboard.isDown("up") then
    objects.ptwo.body:applyForce(0, -pvel)
  end

  if objects.pone.body:getX() < 0 then
    objects.pone.body:setX(1)
    x, y = objects.pone.body:getLinearVelocity( )
    objects.pone.body:setLinearVelocity(-20,y)
  elseif objects.pone.body:getX() > 400 then
    objects.pone.body:setX(400-1)
    x, y = objects.pone.body:getLinearVelocity( )
    objects.pone.body:setLinearVelocity(20,y)
  end
  if objects.ptwo.body:getX() < 400 then
    objects.ptwo.body:setX(400+1)
    x, y = objects.ptwo.body:getLinearVelocity( )
    objects.ptwo.body:setLinearVelocity(-20,y)
  elseif objects.ptwo.body:getX() > 800 then
    objects.ptwo.body:setX(800-1)
    x, y = objects.ptwo.body:getLinearVelocity( )
    objects.ptwo.body:setLinearVelocity(20,y)
  end

 end

  

  world:update(dt)
   -- prevX = love.mouse:getX()
   -- prevY = love.mouse:getY()-cameraY

end

function love.keyreleased(key)

 -- if key == "l" then

end
 
function love.mousereleased( x, y, button )
 
--  id = os.time()  -- oh dear TODO... its in sec.
    --  id = love.math.random( 0, 1000 ) * id--  this is so good
    -- print(x .. ":" .. y)
    -- if tiles[gIDfromCoords(x,y)] == 1 then
    --   tiles[gIDfromCoords(x,y)] = 0
    -- else
    --   tiles[gIDfromCoords(x,y)] = 1
    -- end

end

function love.draw()

  love.graphics.setColor(50,50,50)
  -- love.graphics.setLineWidth( 0. )
  love.graphics.line(400,0,400,600)


  love.graphics.setColor(255, 255, 255) -- set the drawing color to green for the ground
  love.graphics.polygon("fill", objects.twall.body:getWorldPoints(objects.twall.shape:getPoints())) -- draw
  love.graphics.polygon("fill", objects.bwall.body:getWorldPoints(objects.bwall.shape:getPoints())) -- draw

  love.graphics.setColor(255,255,0)
  love.graphics.ellipse( "fill", objects.ball.body:getX(), objects.ball.body:getY(), radius, radius  )

  love.graphics.setColor(255,0,255)
  love.graphics.ellipse( "fill", objects.pone.body:getX(), objects.pone.body:getY(), prad, prad  )
  love.graphics.setColor(0,255,255)
  love.graphics.ellipse( "fill", objects.ptwo.body:getX(), objects.ptwo.body:getY(), prad, prad  )


  if resetTimer > 0 then
    love.graphics.setColor(255,0,0)
    -- set font
    love.graphics.setFont(lfont)
    love.graphics.printf(" ~ ".. math.floor(resetTimer)+1 .. " ~ ", 400-300/2-10, 100, 300,"center")
  end

  love.graphics.setColor(255,255,255)
  love.graphics.setFont(sfont)
  love.graphics.printf("P1: ".. scoreOne, 50, 30, 300,"center")
  love.graphics.printf("P2: ".. scoreTwo, 800-50-300, 30, 300,"center")


  -- CAMERA?
 -- love.graphics.translate( 0, cameraY ) -- TODO

  -- for i = 0, (gID(15,12)) do
  --   if (tiles[i] == 0) then
  --     love.graphics.setColor(255,0,0)
  --   end
  --   if(tiles[i] == 1) then
  --     love.graphics.setColor(0,0,255)
  --   end
  --   y = gY(i)
  --   x = gX(i)
  --   --print(i .. "," .. x .. ":" .. y)
  --   love.graphics.polygon("fill", x*50,y*50, x*50, y*50+50, x*50+50,y*50+50, x*50+50, y*50)
  -- end

  -- love.graphics.setColor(0, 250, 0)
  -- love.graphics.polygon('fill', 100, 100, 200, 100, 150, 200)


end

function beginContact(a, b, coll)
  
  -- in begin contact?

end
 
function endContact(a, b, coll)
  -- indexA, indexB = coll:getChildren()
  if (a:getUserData() == "pone" or b:getUserData() == "pone") then
    if (a:getUserData() == "ball" or b:getUserData() == "ball") then
      scoreTwo = scoreTwo + 1
      reset = true
    end
  elseif (a:getUserData() == "ptwo" or b:getUserData() == "ptwo") then
    if (a:getUserData() == "ball" or b:getUserData() == "ball") then
      scoreOne = scoreOne + 1
      reset = true
    end
  end

  print(a:getUserData())
  print(b:getUserData())
end
 
function preSolve(a, b, coll)
 
end
 
function postSolve(a, b, coll, normalimpulse, tangentimpulse)
 
end


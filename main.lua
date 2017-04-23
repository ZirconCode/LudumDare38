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

function resetGame()



end


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
  outTime = 0

  psystem:reset()

end


function love.load()

  -- tweaky constants

  pvel = 650
  prad = 30
  radius = 15
  c = 4500*2 -- gravity mass constant
  lindamp = 1.5

  -----

  -- gamestate vars

  reset = false
  resetFor = 1 -- player 1?
  resetTimer = 0

  outTime = 0 -- ballouttime (3second max)

  gameTime = 60*3 -- 3 minutes?

  pOneGod = 0
  pTwoGod = 0

  screenNumber = 0 --999 

  asg1 = love.graphics.newImage("Asgard1.jpg")
  asg0 = love.graphics.newImage("title.jpg")

  asg2 = love.graphics.newImage("asg2.png")
  asg3 = love.graphics.newImage("asg3.png")
  asg4 = love.graphics.newImage("asg4.png")
  asg5 = love.graphics.newImage("asg5.png")

  iImg = love.graphics.newImage("inst.jpg")

  sImg = love.graphics.newImage("charsel.png")

  vImg = love.graphics.newImage("victory.png")

  pImg = love.graphics.newImage("particle.png")

  -- 0 = title screen
  -- story
  -- instructions??
  -- character choice x 2
  -- game
  -- victory screen & play again

  music = love.audio.newSource("theme.ogg")
  music:setLooping(true)
  music:play() -- from beginning TODO ?

  --------

  scoreOne = 0
  scoreTwo = 0

  lfont = love.graphics.newFont(50)
  sfont = love.graphics.newFont(20)

  pWinner = 0 -- player 1/2 is winner

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
  objects.twall.shape = love.physics.newRectangleShape(800+9999, 50) -- TODO: flyout? !!!
  --- FLYOUT TIMEOUT ON SIDE = LOSE GAME, 2 seconds? !! TODO
  objects.twall.fixture = love.physics.newFixture(objects.twall.body, objects.twall.shape); 
  objects.twall.fixture:setUserData("topwall")

  objects.bwall = {}
  objects.bwall.body = love.physics.newBody(world, 800/2, 600+13)
  objects.bwall.shape = love.physics.newRectangleShape(800+9999, 50) 
  objects.bwall.fixture = love.physics.newFixture(objects.bwall.body, objects.bwall.shape); 
  objects.bwall.fixture:setUserData("topwall")

  -- TODO BACKWALLS?
  objects.wallo = {}
  objects.wallo.body = love.physics.newBody(world, 800/2, 600+13)
  objects.wallo.shape = love.physics.newRectangleShape(800+9999, 50) 
  objects.wallo.fixture = love.physics.newFixture(objects.wallo.body, objects.wallo.shape); 
  objects.wallo.fixture:setUserData("topwall")
  objects.wallt = {}
  objects.wallt.body = love.physics.newBody(world, 800/2, 600+13)
  objects.wallt.shape = love.physics.newRectangleShape(600, 50) 
  objects.wallt.fixture = love.physics.newFixture(objects.wallt.body, objects.wallt.shape); 
  objects.wallt.fixture:setUserData("sidewall")

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
  objects.pone.body:setLinearDamping(lindamp)
  objects.pone.fixture:setUserData("pone")

  objects.ptwo = {}
  objects.ptwo.isPlayer = true
  objects.ptwo.body = love.physics.newBody(world, 800-70, 300, "dynamic")
  objects.ptwo.shape = love.physics.newCircleShape(  prad ) 
  objects.ptwo.fixture = love.physics.newFixture(objects.ptwo.body, objects.ptwo.shape, 1) -- Attach fixture to body and give it a density of 1.
  --objects.ball.fixture:setFriction(0.3) -- TODO 
  objects.ptwo.body:setFixedRotation( true )
  objects.ptwo.body:setLinearDamping(lindamp)
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

  psystem = love.graphics.newParticleSystem(pImg, 100)
  psystem:setParticleLifetime(0.01, 1) -- Particles live at least 2s and at most 5s.
  psystem:setEmissionRate(40)
  psystem:setSizeVariation(1)
  psystem:setSizes(1,0.5,0.6,0.7,1.1,1.3)
  psystem:setSpin(-1,1,0.5)
  --psystem:setLinearAcceleration(-20, -20, 20, 20) -- Random movement in all directions.
  psystem:setColors(255, 255, 255, 255, 200, 200, 0, 255, 255, 255, 255, 0) -- Fade to transparency.
  -- TODO amazing wonderful cool particles, EXPLOSIONS>?

  --initial graphics setup
  love.graphics.setBackgroundColor(5, 5, 5) --set the background color to a nice blue
  love.window.setMode(800, 600) --set the window dimensions to 650 by 650

  resetCombat(0) -- init state wooo ^_^

end

function love.update(dt)

  if screenNumber == 100 then ---------------------

  if gameTime == 0 then
    -- victory screen
    -- TODO
    if scoreOne > scoreTwo then
      pWinner = 1
    elseif scoreTwo > scoreOne then
      pWinner = 2
    else
      pWinner = 3
    end

    screenNumber = 999
  end

  if gameTime > 0 and resetTimer == 0 then
    -- print(gameTime)
    gameTime = gameTime - dt
    gameTime = lume.clamp(gameTime, 0, 99999999)
  end

  if reset == true then
    if resetFor == 1 then
      resetCombat(50)
    elseif resetFor == 2 then
      resetCombat(-50)
    end
    reset = false
  end

  if resetTimer > 0 then
    resetTimer = resetTimer - dt*3
    resetTimer = lume.clamp(resetTimer , 0, 99999999)
  end

  if outTime > 3 then
    if objects.ball.body:getX() < 0 then
      scoreTwo = scoreTwo+1
      resetCombat(-50)
    elseif objects.ball.body:getX() > 800 then
      scoreOne = scoreOne+1
      resetCombat(50)
    end
    outTime = 0
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
  dX = c * dX / distOne--(distOne^2)
  dY = c * dY / distOne--(distOne^2)

  -- and number two
  -- del x, del y
  dXt = bX - ptX
  dYt = bY - ptY
  -- norm it
  normt = lume.distance(0, 0, dXt, dYt, false)
  dXt = dXt / normt
  dYt = dYt / normt
  -- apply gravity
  dXt = c * dXt / distTwo--(distTwo^2)
  dYt = c * dYt / distTwo--(distTwo^2)

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

  if objects.ball.body:getX() < 0 or objects.ball.body:getX() > 800 then
    outTime = outTime + dt
  else
    outTime = 0
  end
  -- print(outTime)

 end

  xv, yv = objects.ball.body:getLinearVelocity( )
  xv = -xv
  yv = -yv
  -- psystem:setLinearAcceleration(xv-25, yv-25, xv+25, yv+25)
  psystem:setLinearAcceleration(-50, -50, 50, 50)
  psystem:setPosition(objects.ball.body:getX(),objects.ball.body:getY())
  psystem:update(dt)

  world:update(dt)
   -- prevX = love.mouse:getX()
   -- prevY = love.mouse:getY()-cameraY

  end ---------------------

end

function love.keyreleased(key)

  if key == "space" then 

    if screenNumber < 5 then
      screenNumber = screenNumber +1
    elseif screenNumber == 5 then
      screenNumber = 50
    elseif screenNumber == 60 then
      screenNumber = 100
    end

  end

  --- PLEASE NOOOO

  if screenNumber == 51 then
    if key == "1" then 
      pTwoGod = 1
      screenNumber = 60
    elseif key == "2" then 
      pTwoGod = 2
      screenNumber = 60
      elseif key == "3" then 
      pTwoGod = 3
      screenNumber = 60
      elseif key == "4" then 
      pTwoGod = 4
      screenNumber = 60
    end
    print(pTwoGod)
  end

  if screenNumber == 50 then

  if key == "1" then 
      pOneGod = 1
      screenNumber = 51
    elseif key == "2" then 
      pOneGod = 2
      screenNumber = 51
      elseif key == "3" then 
      pOneGod = 3
      screenNumber = 51
    elseif key == "4" then 
      pOneGod = 4
      screenNumber = 51
    end

    print(pOneGod)
  
  end

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

 ------------- ahhhhhhh its so uglyyyyyyyyyyyy oh noooo
  -- This is some genius code:
  if screenNumber == 0 then
   love.graphics.setColor(255, 255, 255, 255)
   love.graphics.draw(asg0, 0, 0, 0, 1, 1, 0, 0)
  elseif screenNumber == 1 then
   love.graphics.setColor(255, 255, 255, 255)
   love.graphics.draw(asg1, 0, 0, 0, 1, 1, 0, 0)
   elseif screenNumber == 2 then
   love.graphics.setColor(255, 255, 255, 255)
   love.graphics.draw(asg2, 0, 0, 0, 1, 1, 0, 0)
   elseif screenNumber == 3 then
   love.graphics.setColor(255, 255, 255, 255)
   love.graphics.draw(asg3, 0, 0, 0, 1, 1, 0, 0)
   elseif screenNumber == 4 then
   love.graphics.setColor(255, 255, 255, 255)
   love.graphics.draw(asg4, 0, 0, 0, 1, 1, 0, 0)
   elseif screenNumber == 5 then
   love.graphics.setColor(255, 255, 255, 255)
   love.graphics.draw(asg5, 0, 0, 0, 1, 1, 0, 0)
   elseif screenNumber == 60 then
   love.graphics.setColor(255, 255, 255, 255)
   love.graphics.draw(iImg, 0, 0, 0, 1, 1, 0, 0)
  elseif screenNumber == 50 then
   love.graphics.setColor(255, 255, 255, 255)
   love.graphics.draw(sImg, 0, 0, 0, 1, 1, 0, 0)
   love.graphics.setColor(255,0,0)
   love.graphics.setFont(sfont)
   love.graphics.printf(" Player 1 Select your Champion", 300, 300, 200,"center")
  elseif screenNumber == 51 then
   love.graphics.setColor(255, 255, 255, 255)
   love.graphics.draw(sImg, 0, 0, 0, 1, 1, 0, 0)
   love.graphics.setColor(255,0,0)
   love.graphics.setFont(sfont)
   love.graphics.printf(" Player 2 Select your Champion", 300, 300, 200,"center")
  elseif screenNumber == 999 then
   love.graphics.setColor(255, 255, 255, 255)
   love.graphics.draw(vImg, 0, 0, 0, 1, 1, 0, 0)
   love.graphics.setColor(255,0,0)
   love.graphics.setFont(lfont)
   love.graphics.printf(" Player X WON! ", 300-150, 50, 500,"center")
  elseif screenNumber == 100 then
    -------------------------

    love.graphics.draw(psystem, 0, 0)

    love.graphics.setColor(50,50,50)
    -- love.graphics.setLineWidth( 0. )
    love.graphics.line(400,0,400,600)

    love.graphics.setColor(255,255,0)
    love.graphics.ellipse( "fill", objects.ball.body:getX(), objects.ball.body:getY(), radius, radius  )

    love.graphics.setColor(255,0,255)
    love.graphics.ellipse( "fill", objects.pone.body:getX(), objects.pone.body:getY(), prad, prad  )
    love.graphics.setColor(0,255,255)
    love.graphics.ellipse( "fill", objects.ptwo.body:getX(), objects.ptwo.body:getY(), prad, prad  )

    -- love.graphics.setColor(0,255,255)
    -- love.graphics.polygon("fill", )


    if resetTimer > 0 then
      love.graphics.setColor(255,0,0)
      -- set font
      love.graphics.setFont(lfont)
      love.graphics.printf(" ~ ".. math.floor(resetTimer)+1 .. " ~ ", 400-300/2-10, 100, 300,"center")
    end

    if outTime > 0 then
      love.graphics.setColor(255,0,0)
      -- set font
      love.graphics.setFont(sfont)
      love.graphics.printf("Out in  ".. (3-math.floor(outTime)) .. "s", 400-300/2-10, 100, 300,"center")
    end

    love.graphics.setColor(255,255,255)
    love.graphics.setFont(sfont)
    love.graphics.printf("P1: ".. scoreOne, 50, 30, 300,"center")
    love.graphics.printf("P2: ".. scoreTwo, 800-50-300, 30, 300,"center")

    love.graphics.setColor(255 ,255,255)
    love.graphics.setFont(sfont)
    love.graphics.printf("" .. math.floor(gameTime) .. "s", 300-50, 30, 300, "center")


    if objects.ball.body:getX() < 0 then
      love.graphics.setColor(255,0,0)
      love.graphics.ellipse( "line", 0 , objects.ball.body:getY() , prad/2, prad/2 )
      lvx, lvy = objects.ball.body:getLinearVelocity( )
      love.graphics.line(0,objects.ball.body:getY(),0+lvx,objects.ball.body:getY()+lvy)
    elseif objects.ball.body:getX() > 800 then
      love.graphics.setColor(255,0,0)
      love.graphics.ellipse( "line", 800 , objects.ball.body:getY() , prad/2, prad/2 )
      lvx, lvy = objects.ball.body:getLinearVelocity( )
      love.graphics.line(800,objects.ball.body:getY(),800+lvx,objects.ball.body:getY()+lvy)
    end


    love.graphics.setColor(255, 255, 255) -- set the drawing color to green for the ground
    love.graphics.polygon("fill", objects.twall.body:getWorldPoints(objects.twall.shape:getPoints())) -- draw
    love.graphics.polygon("fill", objects.bwall.body:getWorldPoints(objects.bwall.shape:getPoints())) -- draw

    -------------------------
  end





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

  -- Story Images: TODO



end

function beginContact(a, b, coll)
  
  -- in begin contact?

end
 
function endContact(a, b, coll)
  -- indexA, indexB = coll:getChildren()
  if (a:getUserData() == "pone" or b:getUserData() == "pone") then
    if (a:getUserData() == "ball" or b:getUserData() == "ball") then
      scoreTwo = scoreTwo + 1
      resetFor = 1
      reset = true
    end
  elseif (a:getUserData() == "ptwo" or b:getUserData() == "ptwo") then
    if (a:getUserData() == "ball" or b:getUserData() == "ball") then
      scoreOne = scoreOne + 1
      resetFor = 2
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


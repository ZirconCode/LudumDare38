lume = require "lume"
--serialize = require 'ser'
--require "Tserial"
serialize = require 'ser'


function construct()
 
end

function constructBlock(block,name)

end

function deleteObjectsAt(x,y)

end

function clear()

end

function love.load()

  editor = true -- DISABLE LEVEL EDITING

  --musicPiece1 = love.audio.newSource("LudumDare37Kitschig1.ogg")
   
  --voice1:setLooping(false)
  --musicPiece1:setPitch(0.4)
  --musicPiece1:play() -- change whatever... no plan TODO

  cameraY = 0

  --picVictory = love.graphics.newImage("victory.png")
  rotation = 0

  blah = 0

  objects = {} 
  -- voice1:play()

  --construct()

  --initial graphics setup
  love.graphics.setBackgroundColor(255, 5, 0) --set the background color to a nice blue
  love.window.setMode(800, 600) --set the window dimensions to 650 by 650
end

function love.update(dt)
  
    --musicPiece2:stop()

   -- if(musicPiece3:isStopped()) the
  
  --cameraY = lume.lerp(cameraY,-objects.ball.body:getY()+love.graphics.getHeight()-200,1) -- TODO
 
  --if love.keyboard.isDown("right") or love.keyboard.isDown("d") then --press the right arrow key to push the ball to the right
   -- objects.ball.body:applyForce(400, 0)
  --end

 -- if love.keyboard.isDown("down") or love.keyboard.isDown("s") then
   
   -- prevX = love.mouse:getX()
   -- prevY = love.mouse:getY()-cameraY

end

function love.keyreleased(key)

 -- if key == "l" then

end
 
function love.mousereleased( x, y, button )
 
--  id = os.time()  -- oh dear TODO... its in sec.
    --  id = love.math.random( 0, 1000 ) * id--  this is so good

end

function love.draw()

  love.graphics.setColor(0, 250, 0)
  love.graphics.polygon('fill', 100, 100, 200, 100, 150, 200)

  -- CAMERA?
 -- love.graphics.translate( 0, cameraY ) -- TODO

  --love.graphics.setColor(72, 160, 14) -- set the drawing color to green for the ground
 -- love.graphics.polygon("fill", objects.ground.body:getWorldPoints(objects.ground.shape:getPoints())) -- draw a "filled in" polygon using the ground's coordinates

  --love.graphics.draw(picSmiley, objects.ball.body:getX(), objects.ball.body:getY())

  for key,value in pairs(objects) do 
     print(key)
     print(value)
     love.graphics.setColor(0, 0, 250)
     love.graphics.polygon('fill', 100, 100, 200, 100, 150, 200)
  end

end

function beginContact(a, b, coll)

end
 
function endContact(a, b, coll)

end
 
function preSolve(a, b, coll)
 
end
 
function postSolve(a, b, coll, normalimpulse, tangentimpulse)
 
end


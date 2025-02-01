function love.load()
    love.window.setFullscreen(false)

    wf = require 'libraries/windfield'
    world = wf.newWorld(0, 5024)
    world:addCollisionClass('platform')

    box = world:newRectangleCollider(1000, 500, 1500, 50)
    box:setCollisionClass('platform')
    box:setType('static')

    camera = require 'libraries/camera'
    cam = camera()

    anim8 = require 'libraries/anim8'
    love.graphics.setDefaultFilter("nearest", "nearest")

    sti = require 'libraries/sti'

    player = {}
    player.collider = world:newBSGRectangleCollider(400, 250, 40, 80, 10)
    player.collider:setFixedRotation(true)
    player.x = 400
    player.y = 200
    player.speed = 300
    player.jumpPower = 2000
    player.spriteSheet = love.graphics.newImage('sprites/player-sheet.png')
    player.grid = anim8.newGrid( 12, 18, player.spriteSheet:getWidth(), player.spriteSheet:getHeight() )

    player.animations = {}
    player.animations.speed =  1 / (math.log(player.speed * 24))
    player.animations.left = anim8.newAnimation(player.grid('1-4', 1), player.animations.speed)
    player.animations.right = anim8.newAnimation(player.grid('1-4', 2), player.animations.speed)

    player.anim = player.animations.right

    background = love.graphics.newImage('sprites/background.png')
end


function love.update(dt)
    local isMoving = false
    local isAirborne = true
    local vx = 0
    local vy = 0
    local inputDelay = 0
    
    inputDelay = inputDelay - 1

    if player.collider:exit('platform') then
        isAirborne = false
    end

    if love.keyboard.isDown("right") then
        vx = player.speed
        player.anim = player.animations.right
        isMoving = true
    end
    if love.keyboard.isDown("left") then
        vx = player.speed * -1
        player.anim = player.animations.left
        isMoving = true
    end


    if love.keyboard.isDown("up") or inputDelay == 0 then
        if isAirborne then 
            inputDelay = 60
        else
            vy = player.jumpPower
        end 
    end
    
    
    if love.keyboard.isDown("down") then
        vy = player.speed
    end


    player.collider:setLinearVelocity(vx, vy)

    if isAirborne == true then
        player.anim:gotoFrame(5)
    elseif isMoving == false then
        player.anim:gotoFrame(2)
    end

    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()

    if cam.x < w/2 then
        cam.x = w/2
    end
    if cam.y < h/2 then
        cam.y = h/2
    end

    -- local mapH = background:getHeight()
    -- local mapW = background:getWidth()
    -- 
    -- if cam.x > (mapW - w/2) then
    --     cam.x = (mapW - w/2)
    -- end
    -- if cam.y > (mapH - h/2) then
    --     cam.y = (mapH - h/2)
    -- end
    player.anim:update(dt)

    world:update(dt)
    player.x = player.collider:getX()
    player.y = player.collider:getY()

    cam:lookAt(player.x, player.y)
end


function love.draw()
    cam:attach()    
        love.graphics.draw(background, 0, 0, nil, 4)
        player.anim:draw(player.spriteSheet, player.x, player.y, nil, 5, nil, 6, 8.5)
        world:draw()
    cam:detach()
end

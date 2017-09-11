
function love.load()
    screen_x = 500
    screen_y = 500

    player = {
        x = 100,
        y = 50,
        vx = 0,
        vy = 0,
        rot = 0
    }

    accel = 100
    rot_spd = 4

    bullets = {}
    shooting = 0
    bul_spd = 150

    love.window.setMode(screen_x, screen_y, {})
end

function love.update(dt)
    update_input(dt)
    update_object_movement(player, dt)

    dead_bullets = {}
    for id, bullet in pairs(bullets) do
        update_object_movement(bullet, dt)
        bullet.life = bullet.life - dt
        if bullet.life < 0 then
            table.insert(dead_bullets, id)
        end
    end

    for _, dead in pairs(dead_bullets) do
        table.remove(bullets, dead)
    end
end

function update_input(dt)
    comp_x = math.sin(player.rot)
    comp_y = -math.cos(player.rot)

    if love.keyboard.isDown('w') then
        player.vy = player.vy + accel * dt * comp_y
        player.vx = player.vx + accel * dt * comp_x
    end
    if love.keyboard.isDown('a') then
        player.rot = player.rot - rot_spd * dt
    end
    if love.keyboard.isDown('d') then
        player.rot = player.rot + rot_spd * dt
    end
    if love.keyboard.isDown('space') and shooting == 0 then
        shooting = 1
        table.insert(bullets, 
            {x = player.x, y = player.y,
             vx = player.vx + bul_spd*comp_x,
             vy = player.vy + bul_spd*comp_y,
             life = 5}
            )
    end
    if not love.keyboard.isDown('space') then
        shooting = 0
    end
end

function update_object_movement(obj, dt)
    obj.x = obj.x + obj.vx * dt
    obj.y = obj.y + obj.vy * dt

    if obj.x > screen_x then
        obj.x = obj.x - screen_x
    end
    if obj.x < 0 then
        obj.x = obj.x + screen_x
    end
    if obj.y > screen_y then
        obj.y = obj.y - screen_y
    end
    if obj.y < 0 then
        obj.y = obj.y + screen_y
    end
end

function love.draw()
    draw_ship(player.x, player.y, player.rot)
    for id, bullet in pairs(bullets) do
        love.graphics.points(bullet.x, bullet.y)
    end
end

function draw_ship(x, y, r)
    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.rotate(r)

    love.graphics.line(
          0, -15,
        -10,  15,
         10,  15,
          0,   -15)

    love.graphics.pop()
end

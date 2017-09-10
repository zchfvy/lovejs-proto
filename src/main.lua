
function love.load()
    screen_x = 500
    screen_y = 500

    p_x = 100
    p_y = 50
    v_x = 0
    v_y = 0
    rot = 0

    accel = 100
    rot_spd = 4

    bullets = {}
    shooting = 0
    bul_spd = 150

    love.window.setMode(screen_x, screen_y, {})
end

function love.update(dt)
    p_x = p_x + v_x * dt
    p_y = p_y + v_y * dt
    comp_x = math.sin(rot)
    comp_y = -math.cos(rot)

    if love.keyboard.isDown('w') then
        v_y = v_y + accel * dt * comp_y
        v_x = v_x + accel * dt * comp_x
    end
    if love.keyboard.isDown('a') then
        rot = rot - rot_spd * dt
    end
    if love.keyboard.isDown('d') then
        rot = rot + rot_spd * dt
    end
    if love.keyboard.isDown('space') and shooting == 0 then
        shooting = 1
        table.insert(bullets, 
            {x = p_x, y = p_y,
             vx = v_x + bul_spd*comp_x,
             vy = v_y + bul_spd*comp_y}
            )
    end
    if not love.keyboard.isDown('space') then
        shooting = 0
    end

    if p_x > screen_x then
        p_x = p_x - screen_x
    end
    if p_x < 0 then
        p_x = p_x + screen_x
    end
    if p_y > screen_y then
        p_y = p_y - screen_y
    end
    if p_y < 0 then
        p_y = p_y + screen_y
    end

    for id, bullet in pairs(bullets) do
        bullet.x = bullet.x + bullet.vx * dt
        bullet.y = bullet.y + bullet.vy * dt
    end
end

function love.draw()
    draw_ship(p_x, p_y, rot)
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


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

    asteroids = {}
    asteroid_time = 4
    asteroid_timer = 0

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

    exploded_asteroids = {}
    for id, ast in pairs(asteroids) do
        update_object_movement(ast, dt)
        ast.rot = ast.rot + ast.rot_vel

        for bul_id, bullet in pairs(bullets) do
            dist_2 = math.pow(bullet.x - ast.x, 2) + math.pow(bullet.y - ast.y, 2)
            if dist_2 < math.pow(ast.size, 2) then
                table.insert(exploded_asteroids, id)
                table.insert(dead_bullets, bul_id)
            end
        end
    end

    for _, explo in pairs(exploded_asteroids) do
        ast = asteroids[explo]
        if ast.size > 15 then
            for i=1,2 do
                table.insert(asteroids,
                    {x = ast.x, y = ast.y,
                     vx = 25 - 50 * math.random(),
                     vy = 25 - 50 * math.random(),
                     seed = math.random(),
                     rot = math.random() * 6.28,
                     size = ast.size/2,
                     rot_vel = (0.5 - math.random()) * 0.02})
            end
        end
        table.remove(asteroids, explo)
    end

    for _, dead in pairs(dead_bullets) do
        table.remove(bullets, dead)
    end

    asteroid_timer = asteroid_timer - dt
    if asteroid_timer < 0 then
        asteroid_timer = asteroid_time
        table.insert(asteroids,
            {x = screen_x * math.random(),
             y = screen_y * math.random(),
             vx = 25 - 50 * math.random(),
             vy = 25 - 50 * math.random(),
             seed = math.random(),
             rot = math.random() * 6.28,
             size = math.random() * 20 + 20,
             rot_vel = (0.5 - math.random()) * 0.02})
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
    for id, ast in pairs(asteroids) do
        draw_asteroid(ast.x, ast.y, ast.rot, ast.size, ast.seed)
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

function draw_asteroid(x, y, r, size, seed)
    love.graphics.push()
    love.graphics.translate(x,y)
    love.graphics.rotate(r)

    val = seed
    points = {}
    for i = 0,6 do
        val = (val * 8121 + 28411) % 134456
        table.insert(points, size*(.6*val/134436 + .3))
    end

    love.graphics.line(
         0.00            ,  1.0 * points[1],
         0.87 * points[2],  0.5 * points[2],
         0.87 * points[3], -0.5 * points[3],
         0               , -1.0 * points[4],
        -0.87 * points[5], -0.5 * points[5],
        -0.87 * points[6],  0.5 * points[6],
         0.00            ,  1.0 * points[1]
        )

    love.graphics.pop()
end

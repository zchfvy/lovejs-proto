
function love.load()
    screen_x = 500
    screen_y = 500

    love.window.setMode(screen_x, screen_y, {})

    gamestate = 'MENU'

    space_down = 0

    init_gameplay()

    sfx_shoot = love.audio.newSource('shoot.wav', 'static')
    sfx_explo_ast = love.audio.newSource('explo1.wav', 'static')
    sfx_explo_ship = love.audio.newSource('explo2.wav', 'static')
end

function love.update(dt)
    if gamestate == 'MENU' then
        update_menu()
    end
    if gamestate == 'GAMEPLAY' then
        update_gameplay(dt)
    end
end

function love.draw()
    if gamestate == 'MENU' then
        draw_menu()
    end
    if gamestate == 'GAMEPLAY' then
        draw_gameplay()
    end
end

function update_menu()
    if love.keyboard.isDown('space') and space_down == 0 then
        space_down = 1
        init_gameplay()
        gamestate = 'GAMEPLAY'
    end
    if not love.keyboard.isDown('space') then
        space_down = 0
    end
end

function draw_menu()
    love.graphics.printf("ASTEROIDS", 0, 100, screen_x, 'center')

    love.graphics.printf("Press SPACE to start", 0, 400, screen_x, 'center')
end

function init_gameplay()
    player = {
        x = screen_x/2,
        y = screen_y/2,
        vx = 0,
        vy = 0,
        rot = 0
    }

    accel = 100
    rot_spd = 4

    bullets = {}
    bul_spd = 150

    asteroids = {}
    asteroid_time = 4
    asteroid_timer = 0

    gameover_timer = 2

    score = 0

    detrius = {}
end

function update_gameplay(dt)
    if player then
        update_input(dt)
        update_object_movement(player, dt)
    else
        gameover_timer = gameover_timer - dt
        if gameover_timer < 0 then
            if love.keyboard.isDown('space') and space_down == 0 then
                space_down = 1
                gamestate = 'MENU'
            end
            if not love.keyboard.isDown('space') then
                space_down = 0
            end
        end
    end

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
        if player then
            dist_2 = math.pow(player.x - ast.x, 2) + math.pow(player.y - ast.y, 2)
            if dist_2 < math.pow(ast.size, 2) then
                love.audio.play(sfx_explo_ship)
                make_detrius(10, player.x, player.y)
                player = nil
            end
        end
    end

    for _, explo in pairs(exploded_asteroids) do
        love.audio.play(sfx_explo_ast)
        ast = asteroids[explo]
        if ast and ast.size > 15 then
            for i=1,2 do
                table.insert(asteroids,
                    {x = ast.x, y = ast.y,
                     vx = 25 - 50 * math.random(),
                     vy = 25 - 50 * math.random(),
                     seed = math.random(),
                     rot = math.random() * 6.28,
                     size = math.floor(ast.size/2),
                     rot_vel = (0.5 - math.random()) * 0.02})
            end
        end
        if ast then
            make_detrius(4, ast.x, ast.y)
            score = score + ast.size * 100
        end
        table.remove(asteroids, explo)
    end

    for _, dead in pairs(dead_bullets) do
        table.remove(bullets, dead)
    end

    expired = {}
    for det_id, det in pairs(detrius) do
        update_object_movement(det, dt)
        det.time = det.time - dt
        if det.time < 0 then
            table.insert(expired, det_id)
        end
    end

    for _, exp in pairs(expired) do
        table.remove(detrius, exp)
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
             size = math.floor(math.random() * 20 + 20),
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
    if love.keyboard.isDown('space') and space_down == 0 then
        space_down = 1
        love.audio.play(sfx_shoot)
        table.insert(bullets, 
            {x = player.x, y = player.y,
             vx = player.vx + bul_spd*comp_x,
             vy = player.vy + bul_spd*comp_y,
             life = 5}
            )
    end
    if not love.keyboard.isDown('space') then
        space_down = 0
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

function draw_gameplay()
    if player then
        love.graphics.printf(tostring(score), 10, 10, 150, 'left')
        draw_ship(player.x, player.y, player.rot)
    else
        love.graphics.printf("GAME OVER", 0, screen_y/2-50, screen_x, 'center')
        love.graphics.printf("Final Score: " .. tostring(score), 0, screen_y/2+50, screen_x, 'center')
        if gameover_timer < 0 then
            love.graphics.printf("Press SPACE to return to main menu", 0, screen_y/2+150, screen_x, 'center')
        end
    end



    for id, bullet in pairs(bullets) do
        love.graphics.points(bullet.x, bullet.y)
    end
    for id, ast in pairs(asteroids) do
        draw_asteroid(ast.x, ast.y, ast.rot, ast.size, ast.seed)
    end
    for id, det in pairs(detrius) do
        draw_detrius(det)
    end
end

function make_detrius(count, x, y)
    for i=1,count do
        table.insert(detrius,
            {x = x + 5 * math.random(),
             y = y + 5 * math.random(),
             vx = 25 - 50 * math.random(),
             vy = 25 - 50 * math.random(),
             len = math.random() * 5 + 5,
             rot = math.random() * 6.28,
             size = math.floor(math.random() * 20 + 20),
             time = 1,
             rot_vel = (0.5 - math.random()) * 0.02})
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

function draw_detrius(det)
    love.graphics.push()
    love.graphics.translate(det.x,det.y)
    love.graphics.rotate(det.rot)

    love.graphics.line(-det.len/2, 0, det.len/2, 0)

    love.graphics.pop()
end

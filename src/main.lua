
function love.load()
    r_x = 100
    r_y = 50
end

function love.update(dt)
    r_x = r_x + 5 * dt
    r_y = r_y + 5 * dt
end

function love.draw()
    love.graphics.rectangle('line', r_x, r_y, 200, 150)
end

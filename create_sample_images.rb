#!/usr/bin/ruby -Ilib

require 'images'

def save_image(image, file_name)
    image.write(file_name)
    puts "Saved #{file_name}"
end

image = Elevations::elevation_image(400, 400, [45, 46], [13, 14], 300)
save_image(image, 'istra.png')
#istra.display

miami = [25.787676, -80.224145]
image = Elevations::elevation_image(400, 400, [miami[0] - 1, miami[0] + 1.5], [miami[1] - 2, miami[1] + 0.5], 40)
save_image(image, 'miami.png')
#image.display

rio_de_janeiro = [-22.908333, -43.196389]
image = Elevations::elevation_image(400, 400, [rio_de_janeiro[0] - 0.5, rio_de_janeiro[0] + 2], [rio_de_janeiro[1] - 0.5, rio_de_janeiro[1] + 2], 1000)
save_image(image, 'rio.png')
#image.display

sidney = [-33.859972, 151.211111]
image = Elevations::elevation_image(400, 400, [sidney[0] - 1.5, sidney[0] + 1], [sidney[1] - 1.5, sidney[1] + 1], 1000)
save_image(image, 'sidney.png')
#image.display

image = Elevations::world_undulation_image(600, 300)
save_image(image, 'undulations.png')

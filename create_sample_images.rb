require_relative 'images'

=begin
istra = Elevations::elevation_image(400, 400, [45, 46], [13, 14], 300)
istra.display
=end

=begin
miami = [25.787676, -80.224145]
image = Elevations::elevation_image(400, 400, [miami[0] - 1, miami[0] + 1.5], [miami[1] - 2, miami[1] + 0.5], 40)
image.save('miami.png')
=end

=begin
rio_de_janeiro = [-22.908333, -43.196389]
image = Elevations::elevation_image(400, 400, [rio_de_janeiro[0] - 0.5, rio_de_janeiro[0] + 2], [rio_de_janeiro[1] - 0.5, rio_de_janeiro[1] + 2], 1000)
image.save('rio.png')
=end

sidney = [-33.859972, 151.211111]
image = Elevations::elevation_image(400, 400, [sidney[0] - 1.5, sidney[0] + 1], [sidney[1] - 1.5, sidney[1] + 1], 1000)
image.save('sidney.png')

=begin
Elevations::world_undulation_image(600, 300).display
=end

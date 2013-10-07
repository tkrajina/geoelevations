require 'RMagick'
include Magick

require_relative 'geoelevation'

module GeoElevation

    def self.elevation_image(width, height, latitude_interval, longitude_interval, max_elevation)
        #(latitude_interval and latitude_interval.length == 0) or raise "Invalid latitude_interval: #{latitude_interval}"
        srtm = GeoElevation::Srtm.new
        image = Image.new(width, height) { self.background_color='black' }
        for x in 0..height
            for y in 0..width
                latitude = latitude_interval[0] + (x / width.to_f) * (latitude_interval[1] - latitude_interval[0])
                longitude = longitude_interval[0] + (y / height.to_f) * (longitude_interval[1] - longitude_interval[0])
                elevation = srtm.get_elevation(latitude, longitude)

                #puts "(#{x}, #{y}) -> (#{latitude}, #{longitude}) #{elevation}, #{max_elevation}, #{elevation/max_elevation.to_f}"

                if elevation == nil
                    pixel = Pixel.new(255*256, 255*256, 255*256)
                elsif elevation == 0
                    pixel = Pixel.new(0*256, 0*256, 255*256)
                else
                    elevation_ratio = elevation/max_elevation.to_f
                    if elevation_ratio > 1.0
                        elevation_ratio = 1.0
                    end
                    pixel = Pixel.new(0*256, elevation_ratio*255*256, 0*256)
                end

                image.pixel_color(y, width - x, pixel)
            end
        end
        image
    end

    # Return RMagick image with undulations. In black are the positive 
    # values in white the negative. Used for debugging.
    def self.world_undulation_image(width, height)
        egm = GeoElevation::Undulations.new
        min, max = 0, 0

        file_position = nil
        image = Image.new(width, height) { self.background_color='black' }
        (0..height).each do |w|
            (0..width).each do |h|
                latitude = -(w / height.to_f) * 180 + 90
                longitude = (h / width.to_f) * 360 - 180
                value = egm.get_undulation(latitude, longitude) / 2
                #puts "#{binary[0..7]} #{binary[8..15]} #{binary[16..23]} #{binary[24..31]}"
                #puts "#{w}, #{h} -> #{latitude}, #{longitude} -> #{value}"
                min = value > max ? value : max
                max = value < min ? value : min
                #puts "value=#{value}, min=#{min}, max=#{max}"
                value = (value * 1100).to_i
                pixel = Pixel.new(value, value, value)
                image.pixel_color(h, w, pixel)
            end
        end
        puts file_position

        image
    end

end

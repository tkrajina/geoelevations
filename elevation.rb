require 'RMagick'
include Magick

require 'json'
require 'open-uri'
require 'zip/zip'
require 'zlib'

require_relative 'utils'

module Elevations

    SRTM_BASE_URL = 'http://dds.cr.usgs.gov/srtm'
    SRTM1_URL     = '/version2_1/SRTM1/'
    SRTM3_URL     = '/version2_1/SRTM3/'
    DIR_NAME      = "#{Dir.home}/.elevations.rb"

    #EGM2008_URL   = 'http://earth-info.nga.mil/GandG/wgs84/gravitymod/egm2008/Und_min2.5x2.5_egm2008_isw=82_WGS84_TideFree_SE.gz'
    # Test:
    EGM2008_URL   = 'http://localhost/Und_min2.5x2.5_egm2008_isw=82_WGS84_TideFree_SE.gz'

    class Srtm
        def initialize
            # Just in case...
            json = Retriever::prepare_folder
            # Dictionary with all files and urls (as is saved in ~/.elevations.rb/list.json)
            @files = JSON.load(json)
            @cached_srtm_contents = {}
        end

        def get_elevation(latitude, longitude)
            srtm_file = get_file(latitude, longitude)

            srtm_file.get_elevation(latitude, longitude)
        end

        def get_file(latitude, longitude)
            file_name = get_file_name(latitude, longitude)

            if ! @cached_srtm_contents.has_key?(file_name)
                puts "Retrieving #{file_name}"
                file, url = find_file_name_and_url(file_name, 'srtm1')
                if ! file && ! url
                    file, url = find_file_name_and_url(file_name, 'srtm3')
                end

                local_file_name = "#{Elevations::DIR_NAME}/#{file}"
                file_contents = nil
                file_name = file.sub('.zip', '')
                if ! File.exist?(local_file_name)
                    file_contents = open(url).read
                    open(local_file_name, 'wb').write(file_contents)
                end

                file_contents = Elevations::Utils::unzip(local_file_name, file_name)
                file_contents = file_contents.bytes.to_a

                @cached_srtm_contents[file_name] = file_contents
            end

            Elevations::SrtmFile.new(file_name, @cached_srtm_contents[file_name])
        end

        def find_file_name_and_url(file_name, srtm_version)
            for candidate_file_name in @files[srtm_version].keys
                if candidate_file_name.index(file_name) == 0
                    return [candidate_file_name, "#{Elevations::SRTM_BASE_URL}#{@files[srtm_version][candidate_file_name]}"]
                end 
            end

            nil
        end

        #
        # Return the file name no matter if the actual SRTM file exists.
        #
        def get_file_name(latitude, longitude)
            north_south = latitude >= 0 ? 'N' : 'S'
            east_west = longitude >= 0 ? 'E' : 'W'

            lat = latitude.floor.to_i.abs.to_s.rjust(2, '0')
            lon = longitude.floor.to_i.abs.to_s.rjust(3, '0')

            "#{north_south}#{lat}#{east_west}#{lon}.hgt"
        end

    end

    class SrtmFile
        def initialize(file_name, file_contents)
            @contents = file_contents
            @square_side = Math.sqrt(@contents.length / 2)
            @file_name = file_name

            if ! file_contents
                raise "Invalid file #{file_name}"
            end
            if @square_side != @square_side.to_i
                raise "Invalid file size #{@contents.length}"
            end
            
            parse_file_name_starting_position()
        end

        # Returns (latitude, longitude) of lower left point of the file
        def parse_file_name_starting_position()
            groups = @file_name.scan(/([NS])(\d+)([EW])(\d+)\.hgt/)[0]

            if groups.length != 4
                raise "Invalid file name #{@file_name}"
            end

            @latitude = groups[1].to_i * (groups[0] == 'N' ? 1 : -1)
            @longitude = groups[3].to_i * (groups[2] == 'E' ? 1 : -1)
        end

        def get_row_and_column(latitude, longitude)
            if latitude == nil || longitude == nil
                return nil
            end

            [ ((@latitude + 1 - latitude) * (@square_side - 1).to_f).floor, ((longitude - @longitude) * (@square_side - 1).to_f).floor ]
        end

        # If approximate is True then only the points from SRTM grid will be 
        # used, otherwise a basic aproximation of nearby points will be calculated.
        def get_elevation(latitude, longitude)
            if ! (@latitude <= latitude && latitude < @latitude + 1)
                raise "Invalid latitude #{latitude} for file #{@file_name}"
            end
            if ! (@longitude <= longitude && longitude < @longitude + 1)
                raise "Invalid longitude #{longitude} for file #{@file_name}"
            end

            row, column = get_row_and_column(latitude, longitude)

            #points = self.square_side ** 2

            get_elevation_from_row_and_column(row.to_i, column.to_i)
        end


        def get_elevation_from_row_and_column(row, column)
            i = row * (@square_side) + column

            i < @contents.length - 1 or raise "Invalid i=#{i}"

            byte_1 = @contents[i * 2].ord
            byte_2 = @contents[i * 2 + 1].ord

            result = byte_1 * 256 + byte_2

            if result > 9000
                # TODO(TK) try to detect the elevation from neighbour point:
                return nil
            end

            result
        end
    end

    # EGM stands for "Earth Gravitational Model" and is a parser for the 
    # EGM2008 file obtained from 
    # http://earth-info.nga.mil/GandG/wgs84/gravitymod/egm2008/index.html
    class Egm2008
        def initialize
            # Just in case...
            json = Retriever::prepare_folder

            @file_name = Elevations::EGM2008_URL.split('/')[-1]
            @local_file_name = "#{Elevations::DIR_NAME}/#{@file_name}".gsub(/.gz$/, '')

            if !File.exists?(@local_file_name)
                puts "Downloading and ungzipping #{Elevations::EGM2008_URL}"
                Elevations::Utils::ungzip(open(Elevations::EGM2008_URL), @local_file_name)
            end

            # EGM files will not be loaded in memory because they are too big. 
            # file.seek will be used to read values.

            file_size = File.size?(@local_file_name)

            lines = Math.sqrt(file_size / 2)
            puts "lines: #{lines}"
            lines == lines.to_i or raise "Invalid file size:#{file_size}"

            @rows = 180 * 24 * 2
            @columns = 360 * 24 + 2
            @file = open(@local_file_name)
        end

        def get_local_file_name()
             @local_file_name
        end

        def get_undulation(latitude, longitude)
            # TODO: Constants:
            la = -latitude + 90
            lo = longitude < 0 ? longitude + 360 : longitude
            row = (la * 24).floor
            column = (lo * 24).floor
            position = row * @columns + column

            #puts "#{latitude}, #{longitude} -> #{column}, #{row} -> #{position}"

            get_value_at_file_position(position)
        end

        # Loads a value from the n-th position in the EGM file. Every position 
        # is a 4-byte real number.
        def get_value_at_file_position(position)
            @file.seek(4 + position * 4)
            bytes = @file.read(4)

            begin
                value = bytes[0].ord * 256**0 + bytes[1].ord * 256**1 + bytes[2].ord * 256**2 + bytes[3].ord * 256**3
                result = unpack(value)
            rescue
                result = 0
            end

            result
        end

        # Unpacks a number from the EGM file
        def unpack(n)
            sign = n >> 31
            exponent = (n >> (32 - 9)) & 0b11111111
            value = n & 0b11111111111111111111111

            resul = nil
            if 1 <= exponent and exponent <= 254
                result = (-1)**sign * (1 + value * 2**(-23)) * 2**(exponent - 127)
            elsif exponent == 0
                result = (-1)**sign * value * 2**(-23) * 2**(-126)
            else
                # NaN, infinity...
                raise 'Invalid binary'
            end

            result.to_f
        end

    end

end

require 'tempfile'
require 'zip/zip'
require 'zlib'

module GeoElevation
    module Utils
        def self.get_common_string_start(urls)
            if ! urls
                return nil
            end
            result = urls[0]
            for url in urls[1..-1]
                for i in 1..([result.length, url.length].max)
                    if result[i] != url[i]
                        break
                    end
                end
                result = result[0..(i - 1)]
            end

            result
        end

        def self.unzip(zip_source, file_name)
            temp_file = Tempfile::new(file_name)
            temp_file.write(zip_source)
            temp_file.rewind
            Zip::ZipFile.open(temp_file) do |zip_file|
              zip_file.each do |f|
                next unless "#{f}" == file_name
                return f.get_input_stream.read
              end
            end
            raise "No #{file_name} found in #{zip_source}"
        end

        def self.ungzip(gzip_io, resulting_file_name)
            puts "Ungzipping"
            result = Zlib::GzipReader.new(gzip_io).read
            puts "Saving"
            open(resulting_file_name, 'wb').write(result)

            nil
        end

    end

    module Retriever
        MAX_DEPTH = 3

        def self.prepare_folder
            srtm_urls_file = "#{GeoElevation::DIR_NAME}/list.json"
            json = nil

            if ! File.directory?(GeoElevation::DIR_NAME)
                Dir.mkdir(GeoElevation::DIR_NAME)
            end
            if ! File.exist?(srtm_urls_file)
                json = self::get_json()
                pretty_json = JSON.pretty_generate(json)
                open(srtm_urls_file, 'w') { |file| file.write(pretty_json) }
            end

            if ! json
                json = open(srtm_urls_file, 'rb').read
            end

            json
        end

        def self.prepare_urls(urls, srtm_version)
            result = {}
            urls.each do |url|
                file_name = url.split('/')[-1]
                result[file_name] = url.gsub(GeoElevation::SRTM_BASE_URL, '').gsub('//', '/')
            end
            result
        end

        def self.get_json()
            result = {'srtm1' => {}, 'srtm3' => {}}

            srtm_1_urls = self.retrieve("#{GeoElevation::SRTM_BASE_URL}/#{GeoElevation::SRTM1_URL}")
            srtm_3_urls = self.retrieve("#{GeoElevation::SRTM_BASE_URL}/#{GeoElevation::SRTM3_URL}")

            {
                    'srtm1' => self.prepare_urls(srtm_1_urls, 'srtm1'),
                    'srtm3' => self.prepare_urls(srtm_3_urls, 'srtm3'),
            }
        end

        def self.retrieve(base_url)
            result = []
            self.retrieve_urls(result, base_url, depth=1)
        end

        def self.retrieve_urls(result, base_url, depth=1)
            puts "Retrieving #{base_url}"
            if depth > self::MAX_DEPTH
                return
            end
            contents = open(base_url) { |io| io.read }
            for url in contents.scan /href="([^\/][^"']+)/
                url = url[0]
                if url[-1] == '/'
                    self.retrieve_urls(result, "#{base_url}/#{url}", depth + 1)
                elsif url.match /^.*\.hgt\.zip$/
                    file_url = "#{base_url}/#{url}"
                    puts "Found #{file_url}"
                    result.push(file_url)
                end
            end

            result
        end
    end
end


require 'rubygems'
require 'test/unit'
require 'geoelevation'

class TestSimpleNumber < Test::Unit::TestCase
 
    def test_get_srtm_file_names
        srtm = GeoElevation::Srtm.new
        assert_equal(srtm.get_file_name(45, 13), 'N45E013.hgt')
        assert_equal(srtm.get_file_name(45.1, 13), 'N45E013.hgt')
        assert_equal(srtm.get_file_name(44.9, 13), 'N44E013.hgt')
        assert_equal(srtm.get_file_name(45, 13.1), 'N45E013.hgt')
        assert_equal(srtm.get_file_name(45, 12.9), 'N45E012.hgt')
        assert_equal(srtm.get_file_name(25, -80), 'N25W080.hgt')
        assert_equal(srtm.get_file_name(25, -80.1), 'N25W081.hgt')
        assert_equal(srtm.get_file_name(25, -79.9), 'N25W080.hgt')
        assert_equal(srtm.get_file_name(25.1, -80), 'N25W080.hgt')
        assert_equal(srtm.get_file_name(-32, 152), 'S32E152.hgt')

        # This file don't exists but the get_file_name is expected to return the supposed file:
        assert_equal(srtm.get_file_name(0, 0), 'N00E000.hgt')
    end

    def test_existing_srtm_file_urls
        srtm = GeoElevation::Srtm.new
        file_name = srtm.get_file_name(43, 13)
        file_name, url = srtm.find_file_name_and_url(file_name, 'srtm3')
        assert_equal('N43E013.hgt.zip', file_name)
        assert_equal('http://dds.cr.usgs.gov/srtm/version2_1/SRTM3/Eurasia/N43E013.hgt.zip', url)
    end

    def test_nonexisting_srtm_file_urls
        srtm = GeoElevation::Srtm.new
        file_name = srtm.get_file_name(0, 0)
        file_name, url = srtm.find_file_name_and_url(file_name, 'srtm3')
        assert_nil(file_name)
        assert_nil(url)
    end
 
    def test_egm_first_row_first_column
        egm = GeoElevation::Undulations.new
        assert_equal 1489, (egm.get_undulation(90, 0) * 100).to_i
    end

    def test_egm_row_change
        egm = GeoElevation::Undulations.new
        # The file contains data for every 2.5 minute => every degree has 24 
        # columns and rows:
        assert_equal 1489, (egm.get_undulation(90 - (1 / 24.2), 0) * 100).to_i
        assert_equal 1489, (egm.get_undulation(90 - (1 / 24.1), 0) * 100).to_i
        assert_equal 1496, (egm.get_undulation(90 - (1 / 23.9), 0) * 100).to_i
        assert_equal 1496, (egm.get_undulation(90 - (1 / 23.8), 0) * 100).to_i
    end

    def test_egm_column_change
        egm = GeoElevation::Undulations.new
        # The file contains data for every 2.5 minute => every degree has 24 
        # columns and rows:
        assert_equal 4268, (egm.get_undulation(45, 13 - (1 / 24.2)) * 100).to_i
        assert_equal 4268, (egm.get_undulation(45, 13 - (1 / 24.1)) * 100).to_i
        assert_equal 4282, (egm.get_undulation(45, 13 + (1 / 23.9)) * 100).to_i
        assert_equal 4282, (egm.get_undulation(45, 13 + (1 / 23.8)) * 100).to_i
    end

end

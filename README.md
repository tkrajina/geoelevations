# Geoelevations.rb

Geoelevations is a SRTM and EGM2008 undulations parser library for ruby.

[**SRTM**](http://www2.jpl.nasa.gov/srtm/): "The Shuttle Radar Topography Mission (SRTM) obtained elevation data on a near-global scale to generate the most complete high-resolution digital topographic database of Earth."

[**EGM2008**](http://earth-info.nga.mil/GandG/wgs84/gravitymod/egm2008/egm08_wgs84.html): "The official Earth Gravitational Model EGM2008". Part of this dataset is a "geoid undulation values with respect to WGS 84".

## Elevations

Example usage:

    require 'elevation'

    srtm = Elevations::Srtm.new
    elevation = srtm.get_elevation(45.276, 13.72)
    puts "Visnjan is #{elevation} meters above sea level"

Here are a few example images (see images.rb) created with this API:

Istra and Trieste:

![istra.png](http://tkrajina.github.io/geoelevations/istra.png)

Miami:

![miami.png](http://tkrajina.github.io/geoelevations/miami.png)

Rio de Janeiro:

![rio.png](http://tkrajina.github.io/geoelevations/rio.png)

Sydney:

![sidney.png](http://tkrajina.github.io/geoelevations/sidney.png)

## Geoid undulations

When you record a GPS track with a smartphone sometimes the elevation graph will differ from the actual elevation:

![GPX elevations](http://tkrajina.github.io/srtm.py/gpx_elevations.png)

The **black** line is the elevation data from a Samsung smartphone, the red line is the data obtained from SRTM. 

The first 700 meters of the track is obviously a measurement error (common for smartphones), but the rest of the track is recorded cca 40 meters above the actual elevation.

GPS technology is integrated in most of the smartphones currently available on today market. It is well known that GPS provides an ellipsoidal height with respect to WGS84 ellipsoid. For everyday use, this height is not sufficient as it is based on mathematical model not the real height (above the sea level), also called orthometric height. That is the main reason for the height difference in graph above. The earth is **not** an ellipsoid but rather a potato :) called geoid. GPS height must be converted to the orthometric height and this requires information about geoid undulation. Geoid undulations are calculated from earth gravity models like EGM96 or EGM2008 and is basically a difference between this potato-geoid and the mathematical ellipsoid (WGS84).

Some GPS devices and smarthphones do provide EGM96 geoid undulation information but applications that capture that data do not record it. EGM2008 is newer and more accurate version of earth gravity model.

An example image of the world obtained with GeoElevations.rb from the EGM2008 dataset:

![undulations.png](http://tkrajina.github.io/geoelevations/undulations.png)

In black are part of the world above the ideal (WGS84) ellipsoid, in white below.

Example library usage:

    require 'elevation'

    egm = Elevations::Egm2008.new
    undulation = egm.get_undulation(45.276, 13.72)
    puts "The ideal WGS ellipsoid is #{undulation} above the actual geoid" 

The result is:

    The ideal WGS ellipsoid is 45.049991607666016 above the actual geoid 

..and this is the actual error between the actual SRTM elevations and the GPS recordings from smartphones and GPSes without the EGM undulations database.

## License

Geoelevations.rb is licensed under the [Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0)

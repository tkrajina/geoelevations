Gem::Specification.new do |s|
  s.name        = 'geoelevation'
  s.version     = '0.0.1'
  s.date        = '2013-10-07'
  s.summary     = "Geoelevation.rb is a SRTM and EGM2008 undulations parser library for Ruby."
  s.description = "Geoelevation.rb allows you to retrieve elevation for any point on Earth (if present in the SRTM dataset) and the undulation value (the difference between the WGS84 ellipsoid and the actual Earth size)."
  s.authors     = ["Tomo Krajina"]
  s.email       = 'tkrajina@gmail.to'
  s.files       = ["lib/geoelevation.rb", "lib/images.rb", "lib/utils.rb"]
  s.homepage    = 'https://github.com/tkrajina/geoelevations'
  s.license       = 'Apache2.0'
end

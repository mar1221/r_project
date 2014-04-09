require 'dcf'

namespace :cran do
  desc 'Download the current version of PACKAGES.gz'
  task :download do
    `wget -P ./tmp http://cran.r-project.org/src/contrib/PACKAGES.gz`
    string = ''
    File.open('./tmp/PACKAGES.gz') do |f|
      gz = Zlib::GzipReader.new(f)
      string += gz.read
      gz.close
    end
    data = Dcf.parse string
    system 'rm "./tmp/PACKAGES.gz"'
  end
end
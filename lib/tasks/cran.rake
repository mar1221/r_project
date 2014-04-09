require 'dcf'
require 'rubygems/package'
require 'zlib'
require 'open-uri'

namespace :cran do

  desc "run all tasks needed to create / update r packages"
  task :run do
    Rake::Task['cran:packages:clean'].invoke
    Rake::Task['cran:packages:download'].invoke
    Rake::Task['cran:packages:update'].invoke
  end

  namespace :packages do
    desc 'download info about all packages'
    task :download do
      `wget -P ./tmp http://cran.r-project.org/src/contrib/PACKAGES.gz`
    end

    desc 'update packages in the system according to latest local PACKAGES.gz'
    task update: [:environment] do
      string = ''
      File.open('./tmp/PACKAGES.gz') do |f|
        gz = Zlib::GzipReader.new(f)
        string += gz.read
        gz.close
      end
      packages = Dcf.parse(string)

      packages.each do |pack|
        cran_service = CranService.new(pack['Package'], pack['Version'])
        pack = cran_service.package
        pack.each do |key, value|
          if value.class.name == 'String'
            value.force_encoding('UTF-8').encode
          end
        end

        package = Package.find_or_create_by(name: pack[:name])
        package.update!(pack)
      end
    end

    desc 'clean up temporary files'
    task :clean do
      system 'rm "./tmp/PACKAGES.gz"'
    end
  end
end

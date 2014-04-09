require 'dcf'

namespace :cran do

  desc "run all tasks needed to create / update r packages"
  task :run do
    Rake::Task['cran:packages:download'].invoke
    Rake::Task['cran:packages:update'].invoke
    Rake::Task['cran:packages:clean'].invoke
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
      packages = Dcf.parse string

      packages.each do |pack|
        package = Package.find_or_create_by(name: pack['Package'])
        package.version = pack['Version']
        package.license = pack['License']
        package.save!
      end
    end

    desc 'clean up temporary files'
    task :clean do
      system 'rm "./tmp/PACKAGES.gz"'
    end
  end
end
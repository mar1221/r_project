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
      packages = Dcf.parse string

      packages.each do |pack|
        uri = "http://cran.r-project.org/src/contrib/#{pack['Package']}_#{pack['Version']}.tar.gz"
        source = open(uri)

        if source.class.name == 'Tempfile'

          tar_extract = Gem::Package::TarReader.new(Zlib::GzipReader.open(source))
          tar_extract.rewind
          description = nil
          tar_extract.each do |entry|
            name = entry.full_name.split('/').last
            if entry.file? && name == 'DESCRIPTION'
              description = Dcf.parse(entry.read).first
            end
          end

          package = Package.find_or_create_by(name: pack['Package'])
          package.version = pack['Version']
          package.license = pack['License']
          package.title = description['Title']
          package.published_at = Time.new(description['Date/Publication'])
          package.author = description['Author']
          package.maintainer = description['Maintainer']
          package.description = description['Description']
          package.dependencies = description['Depends']
          package.save!
        end
      end
    end

    desc 'clean up temporary files'
    task :clean do
      system 'rm "./tmp/PACKAGES.gz"'
    end
  end
end
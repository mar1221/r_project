require 'dcf'
require 'rubygems/package'
require 'zlib'
require 'open-uri'

class CranService
  def initialize(package_name = nil, package_version = nil)
    @package_name = package_name
    @package_version = package_version
    @base_url = 'http://cran.r-project.org/src/contrib'
    @package_url = "#{@base_url}/#{package_name}_#{package_version}.tar.gz" if package_version
  end

  def package
    description = get_package_description
    if description.nil?
      return { name: @package_name, version: @package_version }
    else
      return { name: @package_name, version: @package_version, title: description['Title'],
        published_at: Time.new(description['Date/Publication']), author: description['Author'],
        maintainer: description['Maintainer'], description: description['description'],
        dependencies: description['Depends'] }
    end
  end

  private

    def get_package_description
      source = open(@package_url)
      if source.class.name == 'Tempfile'
        tar_extract = Gem::Package::TarReader.new(Zlib::GzipReader.open(source))
        tar_extract.rewind
        tar_extract.each do |entry|
          name = entry.full_name.split('/').last
          if entry.file? && name == 'DESCRIPTION'
            return Dcf.parse(entry.read).first
          end
        end
      end
    end
end

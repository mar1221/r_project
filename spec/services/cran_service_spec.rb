require 'spec_helper'

describe 'CranService' do
  describe '#initialize' do
    let! (:service) { CranService.new('TEST', '1.1.1') }

    it 'should have correct base_url' do
      base_url = service.instance_variable_get(:@base_url)
      base_url.should eq('http://cran.r-project.org/src/contrib')
    end

    it 'should have correct packages url' do
      base_url = service.instance_variable_get(:@packages_url)
      base_url.should eq('http://cran.r-project.org/src/contrib/PACKAGES.gz')
    end

    it 'should have correct package url' do
      base_url = service.instance_variable_get(:@package_url)
      base_url.should eq('http://cran.r-project.org/src/contrib/TEST_1.1.1.tar.gz')
    end
  end

  describe '#package' do
    let! (:service { CranService.new('A3', '0.9.2') })

    it 'should return all package details' do

    end
  end
end

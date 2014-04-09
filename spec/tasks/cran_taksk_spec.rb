require 'spec_helper'
require 'rake'

describe 'cran:packages:update' do
  before do
    RProject::Application.load_tasks
    system 'rm "../tmp/PACKAGES.gz"' if File.file?('../tmp/PACKAGES.gz')
  end

  it 'creates packages specified in PACKAGES.gz' do
  end

  it 'throws an exception if specified packages are invalid' do
  end
end
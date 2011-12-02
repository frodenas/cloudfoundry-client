begin
  require 'simplecov'
rescue LoadError
  # ignore
else
  SimpleCov.start do
    coverage_dir "doc/coverage"
    add_group "CloudFoundry Client", "lib/cloudfoundry"
    add_group "Specs", "spec"
  end
end

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rspec'
require 'rspec/autorun'
require 'webmock/rspec'
require 'cloudfoundry'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  # Make use_vcr_cassette available as a macro
  config.extend VCR::RSpec::Macros
end

def spec_fixture(filename)
  File.expand_path(File.join(File.dirname(__FILE__), "fixtures", filename))
end

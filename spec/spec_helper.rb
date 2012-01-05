require 'pathname'
dir = Pathname.new(__FILE__).parent
$LOAD_PATH.unshift(File.join(dir,'lib'))
require 'cobbler'
gem 'rspec', '~> 2.5.0'
require 'mocha'

RSpec.configure do |config|
  config.mock_with :mocha
end

def with_real_cobbler(calzz,&blk)
    unless ENV['NO_REAL_COBBLER'] == '1'
        config = (ENV['COBBLER_YML'] || File.expand_path(File.join(File.dirname(__FILE__),'..','config','cobbler.yml')))
        if File.exist?(config) && (yml = YAML::load(File.open(config))) && (yml['hostname'] && yml['username'] && yml['password'])
            yield(yml)
        else
            puts "No cobbler data found."
        end
    end
end
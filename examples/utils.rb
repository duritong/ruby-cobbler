#
# cli.rb
#
# Copyright (C) 2008,2009 Red Hat, Inc.
# Written by Darryl L. Pierce <dpierce@redhat.com>
# Extended 2012 by duritong <peter.meier@immerda.ch>
#
# This file is part of rubygem-cobbler.
#
# rubygem-cobbler is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published
# by the Free Software Foundation, either version 2.1 of the License, or
# (at your option) any later version.
#
# rubygem-cobbler is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with rubygem-cobbler.  If not, see <http://www.gnu.org/licenses/>.
#

require 'cobbler'
require 'yaml'

module Cobbler
    module Examples
        module Utils
            def self.enhance(clazz=Cobbler::Base)
                config = (ENV['COBBLER_YML'] || File.expand_path(File.join(File.dirname(__FILE__),'..','config','cobbler.yml')))
                if File.exist?(config) && (yml = YAML::load(File.open(config))) && (yml['hostname'] && yml['username'] && yml['password'])
                    clazz.hostname = yml['hostname']
                    clazz.username = yml['username']
                    clazz.password = yml['password']
                    clazz.debug_enabled = yml['debug']||false
                else
                    puts "Can't load configuration file (#{config}) with all necessary parameters. Either fix the yaml file or point COBBLER_YML to an appropriate file."
                    exit 1
                end
            end
        end
    end
end
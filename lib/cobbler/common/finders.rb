#
# finders.rb
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

# +Finders+ provides the basic 2 finder methods to query a cobbler server
#
# +find_one+ to fetch exactly one item based on its name
# +find+ to find all items, takes a block to work with the fetched items
module Cobbler
    module Common
        module Finders
            def self.included(base)
                base.extend(ClassMethods)
            end
            
            module ClassMethods
                def find(&block)
                    raise "No idea how to fetch a list of myself, as no find_all method is defined" unless api_methods[:find_all]
                    result = []
                    in_transaction { make_call(api_methods[:find_all]) }.to_a.each do |record|
                        c_record = new(record,false)
                        result << c_record
                        yield(c_record) if block_given?
                    end
                    return result
                end
                
                def find_one(name)
                    raise "No idea how to fetch myself, as no find_one method is defined" unless api_methods[:find_one]
                    properties = in_transaction { make_call(api_methods[:find_one],name) }
                    valid_properties?(properties) ? new(properties,false) : nil
                end
            end
        end
    end
end

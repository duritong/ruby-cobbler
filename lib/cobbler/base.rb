#
# base.rb
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

require 'cobbler/common/debug'
require 'cobbler/connection/handling'
require 'cobbler/connection/common'
require 'cobbler/common/lifecycle'
require 'cobbler/common/finders'

# +Base+ represents a type of item on the Cobbler server.
#
# Child classes can define fields that will be retrieved from Cobbler by
# using the +cobbler_field+ method. For example:
#
#   class System < Base
#       cobbler_lifecycle :find_all => 'get_systems'
#       cobbler_field :name
#       cobbler_collection :owners, :type => 'String', :packing => :hash
#   end
#
# declares a class named System that contains two fields and a class-level
# method.
#
# The first field, "name", is a simple property. It will be retrieved from
# the value "name" in the remote definition for a system, identifyed by the
# +:owner+ argument.
#
# The second field, "owners", is similarly retrieved from a property also
# named "owners" in the remote definition. However, this property is a
# collection: in this case, it is an array of definitions itself. The
# +:type+ argument identifies what the +local+ class type is that will be
# used to represent each element in the collection.
#
# A +cobbler_collection+ is packed in one of two ways: either as an array
# of values or as a hash of keys and associated values. These are defined by
# the +:packing+ argument with the values +Array+ and +Hash+, respectively.
#
# The +cobbler_lifecycle+ method allows for declaring different methods for
# retrieving remote instances of the class. +cobbler_lifecycle+ also declares
# automatically the various API methods if they aren't overwritten.
# These methods are (defaults are shown for an item called Model):
#
# +find_one+ - to find a single instance (get_model)
# +find_all+ - to find all instances (get_models)
# +remove+   - to remove an instance (remove_model)
# +handle+   - to obtain the handle for this item (get_model_handle)
# +save+     - to store an item (save_model)
# +new+      - to create a new item (new_model)
# +modify+   - to modify an existing model (modfiy_model)
#
module Cobbler
    class Base
        
        def initialize(defs = {},new_record = true)
            if new_record
                @user_definitions = defs
            else
                @definitions = defs
            end
        end
        
        include Cobbler::Common::Debug
        include Cobbler::Connection::Handling
        include Cobbler::Connection::Common
        
        include Cobbler::Common::Lifecycle
        include Cobbler::Common::Finders

        # Save an item on the remote cobbler server
        # This will first lookup if the item already exists on the remote server
        # and use its handle store the attributes. Otherwise a new item is created.
        def save
            unless [ :handle, :new, :modify, :save ].all?{|method| api_methods[method] }
                raise "Not all necessary api methods are defined to process this action!"            
            end
            entry = self.class.find_one(name)
            self.class.in_transaction(true) do |token|
                if entry
                    entryid = self.class.make_call(api_methods[:handle],name,token) 
                else
                    entryid = self.class.make_call(api_methods[:new],token)
                    self.class.make_call(api_methods[:modify],entryid,'name', name, token)
                end
                
                cobbler_record_fields.each do |field|
                    field_s = field.to_s
                    if !locked_fields.include?(field) && user_definitions.has_key?(field_s)
                        self.class.make_call(api_methods[:modify],entryid,field_s, user_definitions[field_s], token)
                    end
                end
                
                cobbler_collections_store_callbacks.each do |callback|
                    send(callback,entryid,token)
                end
                
                self.class.make_call(api_methods[:save],entryid,token)
            end
        end
        
        # delete the item on the cobbler server
        def remove
            raise "Not all necessary api methods are defined to process this action!" unless api_methods[:remove]
            self.class.in_transaction(true) do |token|
                self.class.make_call(api_methods[:remove],name,token)
            end
        end
    end
end
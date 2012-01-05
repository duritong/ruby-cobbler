#
# lifecycle.rb
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

# +Lifecycle+ implements a default set of functionality that a cobbler item
# can have.
# Usually the +Lifecycle+ methods are used to define query functions and define
# which fields of a cobbler item is exposed through the api.
module Cobbler
    module Common
        module Lifecycle
            def self.included(base)
                base.extend ClassMethods
            end
            
            def definitions
                @definitions ||= {}
            end
            
            def user_definitions
                @user_definitions ||= {}
            end
            
            def locked_fields
                self.class.locked_fields
            end
            
            def cobbler_record_fields
                self.class.cobbler_record_fields
            end
            def cobbler_collections_store_callbacks
                self.class.cobbler_collections_store_callbacks
            end
            
            def api_methods
                self.class.api_methods
            end
            
            module ClassMethods
                def api_methods
                    return @api_methods if @api_methods
                    model_name = self.name.gsub(/.*::/,'').underscore
                    @api_methods = {
                      :find_all => "get_#{model_name.pluralize}",
                      :find_one => "get_#{model_name}",
                      :handle => "get_#{model_name}_handle",
                      :remove => "remove_#{model_name}",
                      :save => "save_#{model_name}",
                      :new => "new_#{model_name}",
                      :modify => "modify_#{model_name}"
                    }
                end
                
                def cobbler_record_fields
                    @cobbler_record_fields ||= []
                end
                
                def locked_fields
                    @locked_fields ||= []
                end
                
                def cobbler_collections_store_callbacks
                    @cobbler_collections_store_callbacks ||= []
                end
                
                # Define/adjust all necessary lookup methods for a usual
                # cobbler item.
                #
                def cobbler_lifecycle(lookup_methods={})
                    api_methods.merge!(lookup_methods)
                end
                
                # Allows for dynamically declaring fields that will come from
                # Cobbler.
                #
                def cobbler_field(field,options={})
                    # name is always locked and findable as this is a special field
                    if field == :name
                        options[:locked] = true if options[:locked] || options[:locked].nil?
                        options[:findable] = api_methods[:find_one] if options[:findable] || options[:findable].nil? 
                    end
                    options.each do |key,value|
                        case key
                            when :findable then
                            if value
                                module_eval <<-"MEND"
                                def self.find_by_#{field}(value)
                                    properties = in_transaction{ make_call('#{value}',value) }
                                    valid_properties?(properties) ? new(properties,false) : nil
                                end
                                MEND
                            end
                            when :locked then
                            locked_fields << field if value
                        end
                    end
                    
                    module_eval("def #{field}() user_definitions['#{field}'] || definitions['#{field}']; end")
                    module_eval("def #{field}=(val) user_definitions['#{field}'] = val; end")
                    
                    cobbler_record_fields << field
                end
                
                # Declare many fields at once.
                def cobbler_fields(*fields)
                    fields.to_a.each {|field| cobbler_field field }
                end
                
                # Allows a field to be defined as a collection of objects. The type for that
                # other class must be provided.
                #
                def cobbler_collection(field, options={})
                    classname = options[:type] || 'String'
                    packing = options[:packing] ? options[:packing].to_s.classify : 'Array'
                    
                    packing_code = {
              'Array' => "(definitions['#{field}']||[]).each{|value| new_value << #{classname}.new(value) }",
              'Hash' => "(definitions['#{field}']||{}).each{|key,value| new_value[key] = #{classname}.new(value) }"
                    }
                    
                    cobbler_collections_store_callbacks << options[:store] if options[:store]
                    # unless we have a seperate store callback we store collections normally
                    cobbler_record_fields << field unless options[:store]
                    
                    module_eval <<-"MEND"
                    def #{field}
                        if !user_definitions['#{field}'] && !definitions['#{field}'].is_a?(#{packing})
                                                                                           new_value = #{packing}.new
                                                                                           #{packing_code[packing]}
                                                                                           definitions['#{field}'] = new_value
                        end
                        user_definitions['#{field}'] ||= definitions['#{field}']
                        # return always the user_definitions as we might do operations on these objects, e.g. <<
                        user_definitions['#{field}'] 
                    end
                    
                    def #{field}=(value)
                        user_definitions['#{field}'] = value
                    end
                    MEND
                end        
            end
        end
    end
end

#
# common.rb
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

# +Common+ provides common methods of the cobbler server exposed through the
# api. 
module Cobbler
    module Connection
        module Common
            def self.included(base)
                base.extend(ClassMethods)
            end
            
            module ClassMethods
                # tests a connections
                def test_connection
                    !in_transaction do
                        result = login
                        logout if result
                        result
                    end.nil?
                end
                
                # start a sync on the cobbler server
                def sync
                    in_transaction(true) do |token|
                        make_call('sync',token)
                    end
                end
                
                # get all events (for a certain user)
                def events(for_user='')
                    in_transaction do
                        make_call('get_events',for_user)
                    end
                end
                
                # get the log for a certain event
                def event_log(event_id)
                    in_transaction do
                        make_call('get_event_log',event_id)
                    end
                end
                
                # import a tree into cobbler
                def import(path,name,arch,additional_options={})
                    in_transaction(true) do |token|
                        make_call('background_import',{'path' => path ,'name' => name , 'arch' => arch}.merge(additional_options),token)
                    end
                end
                
                # start syncing the following repositories.
                def reposync(repos=[],tries=3)
                    in_transaction(true) do |token|
                        make_call('background_reposync',{'repos' => repos, 'tries' => tries},token)
                    end
                end
            end
        end
    end
end
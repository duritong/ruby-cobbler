#
# handling.rb
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

require 'active_support/core_ext/module'
require 'xmlrpc/client'

# +Handling+ provides common methods to handle the xmlrpc connection to the 
# cobbler server
module Cobbler
    module Connection
        module Handling
            include Cobbler::Common::Debug
            def self.included(base)
                base.extend ClassMethods
            end
            
            module ClassMethods
                
                # Set hostname, username, password for the Cobbler server, overriding any settings
                # from cobbler.yml.
                cattr_accessor :hostname, :username, :password
                
                # Returns the version for the remote cobbler instance.
                def remote_version
                    connect unless connection
                    @version ||= make_call("version")
                end
                
                # Logs into the Cobbler server.
                def login
                    @auth_token ||= make_call('login', username, password)
                end
                
                def logout
                    make_call('logout',@auth_token)
                    @auth_token = nil
                end


                # Makes a remote call.
                def make_call(*args)
                    raise Exception.new("No connection established on #{self.name}.") unless connection
                    
                    debug("Remote call: #{args.first} (#{args[1..-1].inspect})")
                    result = connection.call(*args)
                    debug("Result: #{result}\n")
                    result
                end

                def in_transaction(do_login=false,&blk)
                    begin
                        begin_transaction
                        token = do_login ? login : nil 
                        result = yield(token)
                        logout if do_login
                    ensure
                        end_transaction
                    end
                    result
                end

                protected
                # Returns a connection to the Cobbler server.
                def connect
                    debug("Connecting to http://#{hostname}/cobbler_api")
                    @connection = XMLRPC::Client.new2("http://#{hostname}/cobbler_api").tap do |client|
                        client.http_header_extra = { 'Accept-Encoding' => 'identity' }
                    end
                end
                
                private                
                # Establishes a connection with the Cobbler system.
                def begin_transaction
                    @connection = connect
                end
                # Ends a transaction and disconnects.
                def end_transaction
                    @connection = @auth_token = @version = nil
                end
                
                def connection
                    @connection
                end
                
                def valid_properties?(properties)
                    properties && !properties.empty? && properties != '~'
                end

            end
        end
    end
end

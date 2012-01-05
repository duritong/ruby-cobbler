#
# debug.rb
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

# +Debug+ provides a basic debugging infrastructure.
module Cobbler
    module Common
        module Debug
            def self.included(base)
                base.extend(ClassMethods)
            end
            
            def debug(msg)
                self.class.debug(msg)
            end
            
            module ClassMethods
                def debug_enabled
                    @debug_enabled ||= false
                end
                
                def debug_enabled=(enable)
                    @debug_enabled = enable
                end
                
                def output=(output)
                    @output = output
                end
                
                def output
                    @output ||= STDOUT
                end
                
                def debug(msg)
                    output.puts msg if @debug_enabled
                end
            end
        end
    end
end

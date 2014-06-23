#
# system.rb
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

# +System+ represents a system within Cobbler.
#
module Cobbler
    class System < Base
        cobbler_fields :name, :profile, :image, :kickstart, :netboot_enabled, :server, :virt_cpus,
        :virt_file_size, :virt_path, :virt_ram, :virt_auto_boot, :virt_type, :gateway, :hostname

        cobbler_collection :kernel_options, :packing => :hash
        cobbler_collection :ks_meta, :packing => :hash, :store => :store_ksmeta
        cobbler_collection :owners
        cobbler_collection :interfaces, :packing => :hash, :store => :store_interfaces

        def store_interfaces(sysid,token)
            interfaces.each do |interface,values|
                values2store = values.keys.inject({}) do |result,member|
                    result["#{member.to_s.gsub(/_/,'')}-#{interface}"] = values[member] if values[member]
                    result
                end
                self.class.make_call('modify_system',sysid,'modify_interface',values2store,token) unless values2store.empty?
            end
        end

        def store_ksmeta(sysid,token)
            result=''
            ks_meta.each { |meta,values| result << "#{meta}=#{values} " }
            self.class.make_call('modify_system',sysid,'ks_meta',result.strip,token) unless result.strip.empty?
        end

    end
end

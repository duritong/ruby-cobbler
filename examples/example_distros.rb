#
# example_version.rb
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

base = File.expand_path(File.join(File.dirname(__FILE__), ".."))
$LOAD_PATH << File.join(base, "lib")
$LOAD_PATH << File.join(base, "examples")

require 'utils'
Cobbler::Examples::Utils.enhance(Cobbler::Distro)

require 'getoptlong'

opts = GetoptLong.new(
  ['--show',    '-s', GetoptLong::REQUIRED_ARGUMENT ],
  ['--list',    '-l', GetoptLong::NO_ARGUMENT],
  ['--create',  '-c', GetoptLong::REQUIRED_ARGUMENT ],
  ['--remove',  '-r', GetoptLong::REQUIRED_ARGUMENT ],
  ['--testrun', '-t', GetoptLong::REQUIRED_ARGUMENT ]
)

def list
    puts "All distros:"
    Cobbler::Distro.find { |distro| puts "\"#{distro.name}\" is a breed of \"#{distro.breed}\"."}
end

def show(name)
  puts "Finding the distro named \"#{name}\""
    
  if (distro = Cobbler::Distro.find_one(name))
    puts "#{distro.name} exists, and is a breed of #{distro.breed}."
    puts "Kernel: #{distro.kernel} - Initrd: #{distro.initrd}"
  else
    puts "No such distro"
  end
end

def create(name)
    existing_distro = Cobbler::Distro.find.first
    unless existing_distro
        puts "No existing distro found to copy data from... -> abort!"
        exit 1
    end
    distro = Cobbler::Distro.new
    distro.name = name
    distro.breed = existing_distro.breed
    distro.kernel = existing_distro.kernel
    distro.initrd = existing_distro.initrd
    distro.arch = existing_distro.arch
    distro.save
    
    puts "Distro #{name} saved!"
end

def remove(name)
    if (distro=Cobbler::Distro.find_one(name))
        distro.remove
        puts "Distro #{name} successfully removed!"
    else
        puts "No such distro named #{name} found! -> abort!"
        exit 1
    end
end

def testrun(name)
    puts "Distros at the beginning"
    puts "------------------------"
    list
    puts
    puts "Create distro #{name}"
    puts "---------------------"
    create(name)
    puts
    puts "All distros after creating #{name}"
    puts "----------------------------------"
    list
    puts
    puts "Display distro #{name}"
    puts "----------------------"
    show(name)
    puts
    puts "Remove distro #{name}"
    puts "---------------------"
    remove(name)
    puts
    puts "Distros at the end"
    puts "------------------"
    list
end

opts.each do |opt, arg|
  case opt
    when '--show' then show(arg)
    when '--list' then list
    when '--create' then create(arg)
    when '--remove' then remove(arg)
    when '--testrun' then testrun(arg)
  end
  exit 0
end
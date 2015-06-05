# Copyright (C) 2008 Red Hat, Inc.
# Written by Darryl L. Pierce <dpierce@redhat.com>
# Extended 2012 by duritong <peter.meier@immerda.ch>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
# MA  02110-1301, USA.  A copy of the GNU General Public License is
# also available at http://www.gnu.org/copyleft/gpl.html.

# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'


require 'jeweler'
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib'))
require 'cobbler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docgem.rubygems.org/read/chapter/20 for more options
  gem.name = 'cobbler'
  gem.version = "2.0.3"
  gem.author = 'duritong'
  gem.email = 'peter.meier@immerda.ch'
  gem.homepage = 'http://github.com/duritong/ruby-cobbler/'
  gem.platform = Gem::Platform::RUBY
  gem.summary = 'An interface for interacting with a Cobbler server.'
  gem.license = 'GPLv2'
  gem.description = <<EOF
  Provides Ruby bindings to interact with a Cobbler server.
EOF
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :default => :spec

gem 'rdoc'
require 'rdoc/task'
RDoc::Task.new do |rdoc|
  version = '2.0.3'
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "cobbler #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end


# Generated from cobbler-0.0.1.gem by gem2rpm -*- rpm-spec -*-
%define ruby_sitelib %(ruby -rrbconfig -e "puts Config::CONFIG['sitelibdir']")
%define gemdir %(ruby -rubygems -e 'puts Gem::dir' 2>/dev/null)
%define gemname cobbler
%define geminstdir %{gemdir}/gems/%{gemname}-%{version}
%define installroot %{buildroot}%{geminstdir}

Summary: 	An interface for interacting with a Cobbler server
Name: 		rubygem-%{gemname}
Version: 	2.0.0
Release: 	1%{?dist}
Group: 		Development/Languages
License: 	LGPLv2+
URL: 		https://github.com/duritong/ruby-cobbler
Source0: 	https://rubygems.org/downloads/%{gemname}-%{version}.gem
BuildRoot: 	%{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
Requires: 	rubygems
BuildRequires:  ruby-flexmock
BuildRequires: 	rubygems
BuildRequires:  rubygem-rake
BuildArch: 	noarch
Provides: 	rubygem(%{gemname}) = %{version}

%description
Provides Ruby bindings to interact with a Cobbler server.

%prep

%build

%check 

cd %{installroot}

rake test

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}%{gemdir}
gem install --local --install-dir %{buildroot}%{gemdir} --force %{SOURCE0}

chmod +x %{installroot}/examples/*.rb

%clean
rm -rf %{buildroot}

%files
%defattr(-, root, root, -)
%{gemdir}/gems/%{gemname}-%{version}/
%{gemdir}/cache/%{gemname}-%{version}.gem
%{gemdir}/specifications/%{gemname}-%{version}.gemspec

%doc %{geminstdir}/COPYING 
%doc %{geminstdir}/NEWS 
%doc %{geminstdir}/README

%{geminstdir}/config/cobbler.yml


%changelog
* Thu Jan 05 2012 duritong <peter.meier@immerda.ch> - 2.0.0-1
- Fix all issues when API returns ~ on a nonexisting system
- Add some missing fields to the System model
- Remove unnecessary object abstraction for interfaces
- Fix storing of interfaces
- Rework connection handling
- Rewrite to enable capabilities for all items and to work against 2.0  

* Mon Sep 08 2008 Darryl Pierce <dpierce@redhat.com> - 0.1.0-1
- First official build for Fedora.

* Fri Sep 05 2008 Darryl Pierce <dpierce@redhat.com> - 0.0.2-4
- Bad BuildRequires slipped into the last version.

* Wed Sep 03 2008 Darryl Pierce <dpierce@redhat.com> - 0.0.2-3
- Added a build requirement for rubygem-rake.

* Tue Aug 26 2008 Darryl Pierce <dpierce@redhat.com> - 0.0.2-2
- Fixed the licensing in each source module to show the code is released under
  LGPLv2.1.
- Added %check to the spec file to run tests prior to creating the RPM.

* Thu Aug 21 2008 Darryl Pierce <dpierce@redhat.com> - 0.0.2-1
- Added a call to update prior to saving or updating a system. If the update
  fails, then an Exception is raised.

* Wed Aug 13 2008 Darryl Pierce <dpierce@redhat.com> - 0.0.1-3
- Added caching for the auth_token to prevent extraneous calls to login.
- Reworked and refined how cobbler_collection fields are processed, adding 
  support for both array and has properties.
- Rewrote the documentation for Cobbler::Base to make it easier to understand
  how to extend it to support other Cobbler types.
- Refactored the examples to clean up the code.

* Wed Aug 13 2008 Darryl Pierce <dpierce@redhat.com> - 0.0.1-2
- Removed markup of cobbler.yml and a config file. Fixed a few small bugs 
  in the code for using it as a gem.

* Mon Aug 04 2008 Darryl Pierce <dpierce@redhat.com> - 0.0.1-1
- Initial package

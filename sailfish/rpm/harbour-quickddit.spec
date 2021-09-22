Name:       harbour-quickddit

# >> macros
%define __requires_exclude ^/usr/bin/env$
# << macros

%{!?qtc_qmake:%define qtc_qmake %qmake}
%{!?qtc_qmake5:%define qtc_qmake5 %qmake5}
%{!?qtc_make:%define qtc_make make}
%{?qtc_builddir:%define _builddir %qtc_builddir}
Summary:    Reddit client for mobile phones
Version:    1.10.4
Release:    1
Group:      Qt/Qt
License:    GPLv3+
URL:        https://github.com/accumulator/Quickddit
Source0:    %{name}-%{version}.tar.bz2
Source100:  harbour-quickddit.yaml
Requires:   sailfishsilica-qt5
Requires:   mapplauncherd-booster-silica-qt5
Requires:   qt5-plugin-imageformat-gif
Requires:   pyotherside-qml-plugin-python3-qt5
BuildRequires:  pkgconfig(Qt5Core)
BuildRequires:  pkgconfig(Qt5Qml)
BuildRequires:  pkgconfig(Qt5Quick)
BuildRequires:  pkgconfig(Qt5Network)
BuildRequires:  pkgconfig(sailfishapp)
BuildRequires:  pkgconfig(nemonotifications-qt5)
BuildRequires:  pkgconfig(keepalive)

%description
Quickddit is a free and open source Reddit client for mobile phones.


%prep
%setup -q -n %{name}-%{version}

# >> setup
# << setup

%build
# >> build pre
# << build pre

%qtc_qmake5  \
    VERSION='%{version}-%{release}'

%qtc_make %{?_smp_mflags}

# >> build post
# << build post

%install
rm -rf %{buildroot}
# >> install pre
# << install pre
%qmake5_install

# >> install post
# << install post

%files
%defattr(-,root,root,-)
%{_bindir}
%{_datadir}
# >> files
# << files

%define __requires_exclude ^/usr/bin/env$
%{!?qtc_qmake:%define qtc_qmake %qmake}
%{!?qtc_qmake5:%define qtc_qmake5 %qmake5}
%{!?qtc_make:%define qtc_make make}
%{?qtc_builddir:%define _builddir %qtc_builddir}

Name:       harbour-quickddit
Summary:    Reddit client for mobile phones
Version:    1.11.0
Release:    1
Group:      Qt/Qt
License:    GPLv3+
URL:        https://github.com/accumulator/Quickddit
Source0:    %{name}-%{version}.tar.bz2
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
BuildRequires:  pkgconfig(qt5embedwidget)
BuildRequires:  qt5-qttools-linguist

%description
Quickddit is a free and open source Reddit client for mobile phones.


%prep
%setup -q -n %{name}-%{version}

%build

%qtc_qmake5  \
    VERSION='%{version}' \
    %{?quickddit_reddit_client_id: REDDIT_CLIENT_ID=%{quickddit_reddit_client_id}} \
    %{?quickddit_reddit_client_secret: REDDIT_CLIENT_SECRET=%{quickddit_reddit_client_secret}} \
    %{?quickddit_reddit_redirect_url: REDDIT_REDIRECT_URL=%{quickddit_reddit_redirect_url}}

%qtc_make %{?_smp_mflags}

%install
%qmake5_install

%files
%defattr(-,root,root,-)
%{_bindir}/%{name}
%{_datadir}/*

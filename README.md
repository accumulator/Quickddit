Quickddit
=========

Quickddit is a free and open source Reddit client for mobile phones.

Quickddit is developed using Qt and currently available for MeeGo Harmattan (Qt 4.7.4) and Sailfish OS (Qt 5.1).

Reddit API client id and secret
----------------------------------

If you want to build Quickddit with OAuth support, remember to [get your own Reddit API client
id and secret](https://github.com/reddit/reddit/wiki/OAuth2) and fill it up in
[src/quickdditmanager.cpp](src/quickdditmanager.cpp) or define `REDDIT_CLIENT_ID`,
`REDDIT_CLIENT_SECRET` and `REDDIT_REDIRECT_URL` in project file.

Optionally you can also define `IMGUR_CLIENT_ID` with your own Imgur API client id.

Download
--------
The binary of both Harmattan and Sailfish version available for download at
[OpenRepos](https://openrepos.net/content/dicksonleong/quickddit).

License
-------
All files in this project are licensed under the GNU GPLv3+, unless otherwise stated.

    Quickddit - Reddit client for mobile phones
    Copyright (C) 2013  Dickson Leong

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see [http://www.gnu.org/licenses/].

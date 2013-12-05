Quickddit
=========

Quickddit is an unofficial Reddit app for mobile phones, developed using Qt and Qt Quick.

As of now, Quickddit only available for MeeGo Harmattan (Qt 4.7.4), and I have planned to
port to SailfishOS as well.

Reddit API client id and secret
----------------------------------

If you want to build Quickddit with OAuth support, remember to [get your own Reddit API client
id and secret](https://github.com/reddit/reddit/wiki/OAuth2) and fill it up in
[src/quickdditmanager.cpp](src/quickdditmanager.cpp) or define `REDDIT_CLIENT_ID`,
`REDDIT_CLIENT_SECRET` and `REDDIT_REDIRECT_URL` in project file.

Optionally you can also define `IMGUR_CLIENT_ID` with your own Imgur API client id.

Download
--------
The binary of Harmattan version available for download at
[OpenRepos](https://openrepos.net/content/dicksonleong/quickddit).

License
-------
All files in this project (except for qt-json/*) is licensed under the GNU GPLv3+, unless otherwise stated.

    Quickddit - Reddit app for mobile phone
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

Quickddit
=========

Quickddit is a free and open source Reddit client for mobile phones. Quickddit is **not** an official client
of Reddit and is not affiliated with Reddit in anyway.

Quickddit is developed using Qt and currently available for MeeGo Harmattan (Qt 4.7.4) and Sailfish OS (Qt 5.1).
The logic part is developed in C++ while the UI is developed in QML.

Reddit API client id and secret
----------------------------------

If you want to build Quickddit with OAuth support, remember to [get your own Reddit API client
id and secret](https://github.com/reddit/reddit/wiki/OAuth2) and fill it up in
[src/quickdditmanager.cpp](src/quickdditmanager.cpp) or define `REDDIT_CLIENT_ID`,
`REDDIT_CLIENT_SECRET` and `REDDIT_REDIRECT_URL` in project file.

Optionally you can also define `IMGUR_CLIENT_ID` with your own Imgur API client id.

TODO
-----
Below is the list of TODOs I planned for future release, before reaching the 1.0.0 milestone.

- Compose new message (require Captcha)
- Notification of PM or comment reply
- Save and unsave posts
- View user profile

Additional TODOs after the 1.0.0 milestone
- Reddit Live
- Buy [reddit gold](http://www.reddit.com/gold/about)
- Multiple accounts

Download
--------
- MeeGo Harmattan (Nokia N9/N950): [OpenRepos](https://openrepos.net/content/accumulator/quickddit)
- SailfishOS (Jolla): [OpenRepos](https://openrepos.net/content/accumulator/quickddit-0)

License
-------
All files in this project are licensed under the GNU GPLv3+, unless otherwise stated.

    Quickddit - Reddit client for mobile phones
    Copyright (C) 2013-2014  Dickson Leong
    Copyright (C) 2015  Sander van Grieken

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

Quickddit
=========

Quickddit is a free and open source Reddit client for mobile phones. Quickddit is **not** an official client
of Reddit and is not affiliated with Reddit in any way.

Quickddit is developed using Qt and currently available for MeeGo Harmattan (Qt 4.7.4) and Sailfish OS (Qt 5.6).
The logic part is developed in C++ while the UI is developed in QML.

The Harmattan port has been left at 1.0.0 feature level, and will not receive new features.

Features
========
- Sign in with your Reddit account or browse anonymously
- Multi Account
- Very quick navigation through content
- Threaded comments view
- Browse your private messages, comment and post  replies, sent messages
- Manage your subscribed subreddit list
- Vote on comments and posts
- Save comments and posts
- Multireddit support
- Integrated image viewer
- Integrated imgur album viewer
- Integrated video player
- Integrated webviewer
- Search for posts and subreddits
- Add, reply, edit and delete comments
- Submit new links and self-posts
- Edit your posts and comments
- Inbox Notifications to the event screen
- Browse user's profile
- Watches clipboard for reddit links
- Option to use TOR

Reddit API client id and secret
----------------------------------

If you want to build Quickddit with OAuth support, remember to [get your own Reddit API client
id and secret](https://github.com/reddit/reddit/wiki/OAuth2) and fill it up in
[src/quickdditmanager.cpp](src/quickdditmanager.cpp) or define `REDDIT_CLIENT_ID`,
`REDDIT_CLIENT_SECRET` and `REDDIT_REDIRECT_URL` in project file or QtCreator.

Optionally you can also define `IMGUR_CLIENT_ID` with your own Imgur API client id.

TODO
-----

- (Local) browse history
- bookmark users, locally or using reddit 'friend' feature.
- Add more filtering options, e.g. by flair
- Reddit Live and/or a method of 'live' following a post
- de-censor a-la ceddit

Download
--------
- MeeGo Harmattan (Nokia N9/N950): [OpenRepos](https://openrepos.net/content/accumulator/quickddit)
- SailfishOS (Jolla): [OpenRepos](https://openrepos.net/content/accumulator/quickddit-0)

License
-------
All files in this project are licensed under the GNU GPLv3+, unless otherwise stated.

    Quickddit - Reddit client for mobile phones
    Copyright (C) 2013-2014  Dickson Leong
    Copyright (C) 2015-2020  Sander van Grieken

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

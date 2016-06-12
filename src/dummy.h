/*
    Quickddit - Reddit client for mobile phones
    Copyright (C) 2016  Sander van Grieken

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
*/

#ifndef DUMMY_H
#define DUMMY_H

#include <QObject>

class Dummy : public QObject
{
    Q_OBJECT
    // stub out libkeepalive properties
    Q_PROPERTY(bool preventBlanking READ preventBlanking WRITE setPreventBlanking)
public:
    explicit Dummy(QObject *parent = 0);

    bool preventBlanking();
    void setPreventBlanking(bool dummy);

signals:

public slots:
};

#endif // DUMMY_H

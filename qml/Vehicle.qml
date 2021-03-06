/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2013 Osmo Salomaa
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.0
import QtLocation 5.0
import QtPositioning 5.3
import Sailfish.Silica 1.0

MapQuickItem {
    id: vehicle
    anchorPoint.x: image.width/2
    anchorPoint.y: image.height/2
    sourceItem: Item {
        Image {
            id: image
            rotation: vehicle.bearing
            smooth: true
            source: app.getIcon(vehicle.type)
        }
        Rectangle {
            id: rectangle
            anchors.centerIn: image
            color: vehicle.color
            height: text.height
            width: text.width
        }
        Text {
            id: text
            anchors.centerIn: image
            color: "white"
            font.bold: true
            font.family: "sans-serif"
            font.pixelSize: Math.round(Theme.pixelRatio*18)
            text: vehicle.line
            textFormat: Text.PlainText
        }
    }
    property double bearing: 0
    property string color: "#007ac9"
    property string line: ""
    property string type: "bus"
    property string uid: ""
    Behavior on bearing {
        RotationAnimation {
            direction: RotationAnimation.Shortest
            duration: 3000
            easing.type: Easing.Linear
        }
    }
    Behavior on coordinate {
        CoordinateAnimation {
            duration: 3000
            easing.type: Easing.Linear
        }
    }
}

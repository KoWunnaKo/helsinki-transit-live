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
import QtPositioning 5.0
import "."

Map {
    id: map
    anchors.fill: parent
    center: QtPositioning.coordinate(60.169, 24.941)
    focus: true
    gesture.enabled: true
    plugin: MapPlugin {}
    property var positionMarker: PositionMarker {}
    property var vehicles: []
    property real zoomLevelPrev: 8

    Timer {
        interval: 1000
        repeat: true
        running: app.running
        triggeredOnStart: true
        onTriggered: {
            // XXX: For some reason we need to do something to trigger
            // a redraw to avoid only a part of tiles being displayed.
            map.pan(1, -1);
            map.pan(-1, 1);
        }
    }

    Component.onCompleted: {
        map.centerOnPosition();
        gps.onInitialCenterChanged.connect(map.centerOnPosition);
        map.setZoomLevel(15);
    }

    gesture.onPinchFinished: {
        // Round piched zoom level to avoid fuzziness.
        if (map.zoomLevel < map.zoomLevelPrev) {
            map.zoomLevel % 1 < 0.75 ?
                map.setZoomLevel(Math.floor(map.zoomLevel)):
                map.setZoomLevel(Math.ceil(map.zoomLevel));
        } else if (map.zoomLevel > map.zoomLevelPrev) {
            map.zoomLevel % 1 > 0.25 ?
                map.setZoomLevel(Math.ceil(map.zoomLevel)):
                map.setZoomLevel(Math.floor(map.zoomLevel));
        }
    }

    Keys.onPressed: {
        // Allow zooming with plus and minus keys on the emulator.
        (event.key == Qt.Key_Plus) && map.setZoomLevel(map.zoomLevel+1);
        (event.key == Qt.Key_Minus) && map.setZoomLevel(map.zoomLevel-1);
    }

    function addVehicle(id, props) {
        // Add a marker to the map for a new vehicle.
        var component = Qt.createComponent("Vehicle.qml");
        var item = component.createObject(map);
        item.vehicleId = id;
        item.coordinate = QtPositioning.coordinate(props.y, props.x);
        item.bearing = props.bearing;
        item.type = props.type;
        item.line = props.line;
        item.color = props.color;
        map.vehicles.push(item);
        map.addMapItem(item);
    }

    function centerOnPosition() {
        // Center map on current position.
        map.center.longitude = gps.position.coordinate.longitude;
        map.center.latitude = gps.position.coordinate.latitude;
    }

    function removeVehicle(id) {
        // Remove vehicle marker that matches id.
        for (var i = map.vehicles.length-1; i >= 0; i--) {
            if (map.vehicles[i].vehicleId != id) continue;
            map.removeMapItem(map.vehicles[i]);
            map.vehicles.splice(i, 1);
            return;
        }
    }

    function sendBBox() {
        // Send coordinates of the data download area to the Python backend.
        // Download data at a buffer outside screen to allow smooth panning.
        if (map.width <= 0 || map.height <= 0) return;
        var nw = map.toCoordinate(Qt.point(0, 0));
        var se = map.toCoordinate(Qt.point(map.width, map.height));
        var buffer = Math.min(se.longitude - nw.longitude,
                              nw.latitude  - se.latitude);

        var xmin = nw.longitude - buffer;
        var xmax = se.longitude + buffer;
        var ymin = se.latitude  - buffer;
        var ymax = nw.latitude  + buffer;
        py.call("htl.app.set_bbox", [xmin, xmax, ymin, ymax], null);
    }

    function setZoomLevel(zoom) {
        // Set the current zoom level.
        map.zoomLevel = zoom;
        map.zoomLevelPrev = zoom;
    }

    function updateVehicle(id, props) {
        // Update location marker of vehicle that matches id.
        for (var i = 0; i < map.vehicles.length; i++) {
            if (map.vehicles[i].vehicleId != id) continue;
            map.vehicles[i].coordinate.longitude = props.x;
            map.vehicles[i].coordinate.latitude = props.y;
            map.vehicles[i].bearing = props.bearing;
            map.vehicles[i].line = props.line;
            return;
        }
        // Add missing vehicle.
        map.addVehicle(id, props);
    }
}

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
import "."

Map {
    id: map
    anchors.fill: parent
    center: QtPositioning.coordinate(60.169, 24.941)
    focus: true
    gesture.enabled: true
    minimumZoomLevel: 12
    plugin: MapPlugin {}

    property bool changed: true
    property var  positionMarker: PositionMarker {}
    property var  vehicles: []
    property real zoomLevelPrev: 8

    Behavior on center {
        CoordinateAnimation {
            duration: 500
            easing.type: Easing.InOutQuad
        }
    }

    Timer {
        // XXX: For some reason we need to do something to trigger
        // a redraw to avoid only a part of tiles being displayed
        // right at start before any user panning or zooming.
        id: timer
        interval: 1000
        repeat: true
        running: app.running
        triggeredOnStart: true
        property var initTime: Date.now()
        onTriggered: {
            map.pan(+1, -1);
            map.pan(-1, +1);
            timer.running = Date.now() - timer.initTime < 5000;
        }
    }

    Timer {
        interval: 500
        repeat: true
        running: app.running
        onTriggered: map.changed && map.updateTracker();
    }

    MouseArea {
        anchors.fill: parent
        onDoubleClicked: map.centerOnPosition();
    }

    Component.onCompleted: {
        // Use a daytime gray street map if available.
        // Needed properties available since Sailfish OS 1.1.0.38.
        for (var i = 0; i < map.supportedMapTypes.length; i++) {
            var type = map.supportedMapTypes[i];
            if (type.style  === MapType.GrayStreetMap &&
                type.mobile === true &&
                type.night  === false) {
                map.activeMapType = type;
                break;
            }
        }
        map.centerOnPosition();
        gps.onInitialCenterChanged.connect(map.centerOnPosition);
        // XXX: Must set zoomLevel in onCompleted.
        // http://bugreports.qt-project.org/browse/QTBUG-40779
        map.setZoomLevel(14);
    }

    onCenterChanged: {
        // Ensure that vehicle tracking is updated after panning.
        // This gets fired ridiculously often, so keep simple.
        map.changed = true;
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
        (event.key === Qt.Key_Plus)  && map.setZoomLevel(map.zoomLevel+1);
        (event.key === Qt.Key_Minus) && map.setZoomLevel(map.zoomLevel-1);
    }

    function addVehicle(props) {
        // Add a marker to the map for a new vehicle.
        var component = Qt.createComponent("Vehicle.qml");
        var item = component.createObject(map);
        item.uid = props.id;
        item.coordinate = QtPositioning.coordinate(props.y, props.x);
        item.bearing = props.bearing || 0;
        item.type = props.type;
        item.line = props.line;
        item.color = props.color;
        map.vehicles.push(item);
        map.addMapItem(item);
    }

    function centerOnPosition() {
        // Center map on current position.
        map.center = QtPositioning.coordinate(
            gps.position.coordinate.latitude,
            gps.position.coordinate.longitude);

    }

    function removeVehicle(id) {
        // Remove vehicle marker that matches id.
        for (var i = map.vehicles.length-1; i >= 0; i--) {
            if (map.vehicles[i].uid !== id) continue;
            map.removeMapItem(map.vehicles[i]);
            map.vehicles[i].destroy();
            map.vehicles.splice(i, 1);
            return;
        }
    }

    function setZoomLevel(zoom) {
        // Set the current zoom level.
        map.zoomLevel = zoom;
        map.zoomLevelPrev = zoom;
    }

    function updateTracker() {
        // Send coordinates of the data download area to the Python backend.
        if (map.width <= 0 || map.height <= 0) return;
        var nw = map.toCoordinate(Qt.point(0, 0));
        var se = map.toCoordinate(Qt.point(map.width, map.height));
        py.call("htl.app.update_tracker", [{
            xmin: nw.longitude,
            xmax: se.longitude,
            ymin: se.latitude,
            ymax: nw.latitude
        }], null);
        map.changed = false;
    }

    function updateVehicle(props) {
        // Update vehicle marker that matches id.
        for (var i = 0; i < map.vehicles.length; i++) {
            if (map.vehicles[i].uid !== props.id) continue;
            var coord = QtPositioning.coordinate(props.y, props.x);
            // If bearing missing, calculate based on coordinates.
            props.bearing = props.bearing ||
                map.vehicles[i].coordinate.azimuthTo(coord);
            map.vehicles[i].coordinate = coord;
            map.vehicles[i].bearing = props.bearing;
            map.vehicles[i].line = props.line;
            return;
        }
        // Add missing vehicle.
        map.addVehicle(props);
    }
}

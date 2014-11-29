Helsinki Transit Live 0.9
=========================

 * Use a grey daytime street map if available (this should work on
   Sailfish OS 1.1.0.38 "Uitukka" and just fall back on the normal
   street map in earlier versions)

Helsinki Transit Live 0.8
=========================

 * Add an active mini map cover
 * Download data at a buffer outside screen to avoid having
   to wait for an update after minor panning
 * Fix icon shapes

Helsinki Transit Live 0.7
=========================

 * Fix map tiles not being displayed or only a part being displayed
   at start, before any interaction
 * Bump required PyOtherSide version to 1.2 (included in Sailfish OS
   1.0.4.20 "Ohijärvi" released 2014-03-17)

Helsinki Transit Live 0.6.1
===========================

 * Fix initial centering

Helsinki Transit Live 0.6
=========================

 * Use a persistent HTTP connection (this should make updating
   more regular and reliable)
 * Use discrete zoom levels to avoid fuzziness

Helsinki Transit Live 0.5
=========================

 * Don't crash anymore

Helsinki Transit Live 0.4
=========================

 * Center initially on current position
 * Show the current position with a marker
 * Shorten name in the app launcher to "Transit Live" (which is
   probably better than the clipped "Helsinki Tran...")
 * Redraw tram shape in icon

Helsinki Transit Live 0.3
=========================

 * Increase data download timeout to ten seconds
 * Set user agent for data downloading
 * Allow plus and minus keys to be used for zooming (this is to ease
   testing on the emulator and hopefully doesn't break anything in
   actual device use)

Helsinki Transit Live 0.2.4
===========================

 * Redraw icon using official template and change shape to match
   in-app vehicle icons

Helsinki Transit Live 0.2.3
===========================

 * Be more robust guessing vehicle type

Helsinki Transit Live 0.2.2
===========================

 * Fix guessing vehicle type
 * Use black color for vehicles of unrecognized type
 * Fix updating route label

Helsinki Transit Live 0.2.1
===========================

 * Fix vehicle icon anchor points

Helsinki Transit Live 0.2
=========================

 * Ship simple icons instead using ones from the web interface
 * Use text labels instead of icons for route names (this should
   fix missing route names for some newer lines)
 * Keep updating route label in case vehicle changes its route
 * Use labels "M" and "V" for metro instead of "1" and "2"

Helsinki Transit Live 0.1
=========================

Initial release.
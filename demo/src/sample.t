#charset "us-ascii"
//
// sample.t
// Version 1.0
// Copyright 2022 Diegesis & Mimesis
//
// This is a very simple demonstration "game" for the nightSkyView library.
//
// It can be compiled via the included makefile with
//
//	# t3make -f makefile.t3m
//
// ...or the equivalent, depending on what TADS development environment
// you're using.
//
// This "game" is distributed under the MIT License, see LICENSE.txt
// for details.
//
#include <adv3.h>
#include <en_us.h>

#include "date.h"
#include "nightSkyView.h"

versionInfo: GameID;
gameMain: GameMainDef initialPlayerChar = me;

startRoom: Room 'Room Indoors'
	"This is a room indoors. "
	north = outsideRoom
;
+me: Person;

outsideRoom: OutdoorRoom 'Room Outdoors'
	"This is an outdoor room. "
	south = startRoom
;

modify gameEnvironment
	currentDate = new Date(1979, 6, 22, 23, 0, 0, 0, 'EST-5EDT')
	latitude = 42
	longitude = -71
;
+EphemView 'lyra' 'Lyra is a perfect little triangle. ';

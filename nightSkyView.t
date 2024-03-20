#charset "us-ascii"
//
// nightSkyView.t
//
#include <adv3.h>
#include <en_us.h>

#include "nightSkyView.h"

// Module ID for the library
nightSkyViewModuleID: ModuleID {
        name = 'Night Sky View Library'
        byline = 'Diegesis & Mimesis'
        version = '1.0'
        listingOrder = 99
}

// Modification to the stock TADS3 defaultSky object.  It's added to
// OutdoorRoom instances by default.
// We add one of our custom preconditions to it, to provide a slightly
// more responsive failure message when the sky isn't visible for some reason
// (weather and so on).
modify defaultSky
	dobjFor(Examine) {
		preCond = static [ nightSkyViewingConditions ]
		verify() { dangerous; }
	}
;

// Add a multi-location unthing to handle attempts to interact with the sky
// when the player is indoors.
defaultIndoorSky: MultiLoc, Unthing
	'sky' 'sky'
	initialLocationClass = Room
	notHereMsg = &nightSkyCantSeeNotOutside
;

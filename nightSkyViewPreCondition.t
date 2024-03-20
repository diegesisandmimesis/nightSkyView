#charset "us-ascii"
//
// nightSkyViewPreCondition.t
//
//
#include <adv3.h>
#include <en_us.h>

#include "nightSkyView.h"

nightSkySeeing: PreCondition
	verifyPreCondition(obj) {
	}
;

nightSkyObjVisible: PreCondition
	// Very simple caching mechanism that only applies for the precond
	// checks.
	// Since our checks are always entirely dependent on the current
	// global sky config (for time and location) there's nothing in
	// the check that SHOULD be different between checks (for any given
	// object ID).
	// NOTE:  This assumption will fail if action internals are doing
	//	anything wacky with changing the global time or location
	//	and then resolving a DIFFERENT action (that also uses this
	// 	precondition).

	// Vector containing the cache, such as it is.
	// Elements are each 2-element lists consisting of the object ID
	// and it's visibilty for the current turn.
	_visibilityCache = perInstance(new Vector())
	_visibleCheckTurn = nil

	verifyPreCondition(obj) {
		local l, n;

		if(obj != nightSkyViewObjects)
			return;

		l = obj.getMatchingObjects();
		if(l.length == 0)
			return;

		n = new Vector(l.length);
		l.forEach(function(o) {
			if(_checkVisibility(o) != true) {
				//nightSkyViewReportManager.markVisible(o, nil);
				n.append(o);
			}
		});

		if(n.length == l.length) {
			illogical(&nightSkyCantSeenObjs, n);
		}
	}

	// Check to see if the named object is currently visible.
	_checkVisibility(id) {
		local i, r;

		// If the cache isn't for this turn, clear it.
		if(_visibleCheckTurn != libGlobal.totalTurns)
			_visibilityCache.setLength(0);

		// Check the cache.
		if(_visibilityCache.length > 0) {
			for(i = 1; i <= _visibilityCache.length; i++) {
				// Cache hit.
				if(_visibilityCache[i][1] == id) {
					return(_visibilityCache[i][2]);
				}
			}
		}

		// If we reach here, it's a cache miss.

		// Ask the global sky object if the given ID is
		// currently visible.
		r = gSky.checkCatalogObject(id);

		// Create a new cache entry.
		_visibilityCache.append([ id, r ]);
		_visibleCheckTurn = libGlobal.totalTurns;

		// Return the visibility.
		return(r);
	}
;

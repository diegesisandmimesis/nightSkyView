#charset "us-ascii"
//
// nightSkyViewObjects.t
//
#include <adv3.h>
#include <en_us.h>

#include "nightSkyView.h"

nightSkyView: MultiLoc, Distant, PreinitObject
	'sky' 'sky'

	initialLocationClass = Room

	execBeforeMe = static [ gameSky ]

	hideFromAll(action) { return(true); }

	// Vocabulary-matching properties.
	//
	// List of all objects (that match our vocabulary) mentioned
	// in this turn's action.
	nightSkyMatchList = perInstance(new Vector())
	//
	// The turn the matchlist is for.
	nightSkyMatchTurn = nil

	// Report-specific properties
	//
	// Flag, boolean true if the gActor can't see the sky this turn
	// for some reason (indoors, bad weather, and so on).
	seeingState = nil
	//
	// List of objects currently visible, generated from nightSkyMatchList
	// (so only includes objects mentioned in the command)
	nightSkyVisible = perInstance(new Vector())
	//
	// List of objects not currently visible (which were mentioned in
	// the current command).
	nightSkyHidden = perInstance(new Vector())

	nightSkyDayList = perInstance(new Vector())

	// Visibility cache properties
	//
	// The visibility cache.  Just a list of the objects we're worried
	// about this turn (that is, the ones mentioned in the current
	// command).
	_visibilityCache = perInstance(new Vector())
	//
	// The turn number the cache was created on.
	_visibilityCacheTurn = nil

	_directions = static [
		'north', 'northeast',
		'east',
		'southeast', 'south', 'southwest',
		'west',
		'northwest', 'north'
	]
	_elevations = static [ 'low', '', 'high', 'near zenith' ]

	// Check for "general" visibility.
	// This includes things like:  can the actor see the sky at all?
	// If so, is it too cloudy to see the stars?
	checkNightSkySeeing() {
		return(gNightSkySeeing == nightSkySeeingClear);
	}

	// Returns boolean true if the given object is visible, nil
	// otherwise.
	// Value is returned from cache if possible, computed and
	// cached otherwise.
	checkNightSkyVisibility(objID) {
		local i, r;

		// If the current turn isn't the turn the cache was created
		// on, we reset the cache.
		if(_visibilityCacheTurn != libGlobal.totalTurns)
			_visibilityCache.setLength(0);

		// If the cache exists, check it.
		if(_visibilityCache.length > 0) {
			// Our cache is just a list, where each element
			// is a 2-element list consisting of an object ID
			// and a boolean indicating its current visibility.
			for(i = 1; i <= _visibilityCache.length; i++) {
				// Cache hit.
				if(_visibilityCache[i][1] == objID)
					return(_visibilityCache[i][2]);
			}
		}

		// Cache miss.

		// Query the global sky object to see if the given object
		// is currently visible.
		r = gSky.checkCatalogObject(objID);

		// Add new cache entry.
		_visibilityCache.append([ id, r ]);
		_visibilityCacheTurn = libGlobal.totalTurns;

		return(r);
	}

	// Set the flag indicating the gActor is indoors.
	markIndoors() {
		// Set the flag.
		seeingState = gNightSkySeeing;

		// Make sure we're called after the action is resolved.
		gAction.callAfterActionMain(self);
	}

	// Store the visibility of the given object for this turn.
	// This will be used to create the report after the action
	// is resolved.
	markVisibility(objID, v) {
		if(v == true) {
			if(nightSkyVisible.indexOf(objID) == nil)
				nightSkyVisible.append(objID);
		} else {
			if(nightSkyHidden.indexOf(objID) == nil)
				nightSkyHidden.append(objID);
		}

		// Make sure we're called after the action is resolved.
		gAction.callAfterActionMain(self);
	}


	dobjFor(Examine) {
		// Make sure we're never examined implicitly.
		verify() { dangerous; }

		// Action handler.
		action() {
			// If the action isn't somehwere the sky is visible,
			// we're done.
			if(gNightSkySeeing == nightSkySeeingIndoors) {
				markIndoors();
				return;
			}

			if(nightSkyMatchList.length < 1)
				return;
			
			markVisibility(nightSkyMatchList[1],
				checkNightSkyVisibility(nightSkyMatchList[1]));

			nightSkyMatchList.splice(1, 1);
		}
	}

	execute() {
		_addCatalogs();
	}

	_addCatalogs() {
		forEachInstance(NightSkyCatalog, function(o) {
			_addCatalog(o);
		});
	}

	_addCatalog(obj) {
		if((obj == nil) || !obj.ofKind(NightSkyCatalog))
			return;
		obj.objectList.forEach(function(o) {
			_addObject(o);
		});
	}

	_addObject(obj) {
		if((obj == nil) || !obj.ofKind(Ephem))
			return;
		if(obj.name)
			_addVocab(obj.name);
		if(obj.abbr)
			_addVocab(obj.abbr);
	}

	_addVocab(txt) {
		cmdDict.addWord(self, txt, &noun);
	}

	matchNameCommon(origTokens, adjustedTokens) {
		if(nightSkyMatchTurn != libGlobal.totalTurns) {
			clearNightSky();
		}

		adjustedTokens.forEach(function(o) {
			if((dataTypeXlat(o) == TypeSString)
				&& (nightSkyMatchList.indexOf(o) == nil)) {
				nightSkyMatchList.append(o);
			}
		});

		return(inherited(origTokens, adjustedTokens));
	}

	clearNightSky() {
		nightSkyVisible.setLength(0);
		nightSkyHidden.setLength(0);
		nightSkyMatchList.setLength(0);
		nightSkyMatchTurn = libGlobal.totalTurns;
		seeingState = nil;
		nightSkyDayList.setLength(0);
	}

	getMatchingObjects() { return(nightSkyMatchList); }

	afterActionMain() {
		gTranscript.summarizeAction(
			function(x) { return(x.action_ == gAction); },
			function(vec) { return(''); }
		);

		nightSkyReport();

		clearNightSky();
	}

	nightSkyReport() {
		local l, nss, txt;

		nss = gNightSkySeeing;

		// If we're indoors, we can't see anything.
		if(nss == nightSkySeeingIndoors) {
			reportFailure(&nightSkyCantSeeNotOutside);
			return;
		}

		if(nss == nightSkySeeingDay) {
			nightSkyDayReport();
			return;
		}

		txt = new StringBuffer();

		// Describe each visible object.
		if(nightSkyVisible.length > 0) {
			nightSkyVisible.forEach(function(o) {
				if(nss == nightSkySeeingDay) {
					if((o.name = 'Sun') ||
						(o.name = 'Moon'))
						txt.append(describeObject(o));
					else
						nightSkyDayList.append(o);
				} else {
					txt.append(describeObject(o));
				}
			});
		}

		// Describe the hidden objects.
		if(nightSkyHidden.length > 0) {
			// Convert IDs to full names.
			l = new Vector(nightSkyHidden.length);
			nightSkyHidden.forEach(function(o) {
				l.append(gSky.getCatalogObjectName(o));
			});

			txt.append('You can\'t see ');
			txt.append(stringLister.makeSimpleList(l));
			txt.append('. ');
		}

		defaultReport(toString(txt));
	}

	_visibleDuringDay(obj) {
		if((obj.name == 'Sun') || (obj.name == 'Moon'))
			return(true);
		return(nil);
	}

	nightSkyDayReport() {
		local l0, l1, txt;

		if(gNightSkySeeing != nightSkySeeingDay)
			return;

		txt = new StringBuffer();

		l0 = new Vector(nightSkyVisible.length + nightSkyHidden.length);
		l1 = new Vector(nightSkyVisible.length + nightSkyHidden.length);
		if(nightSkyVisible.length > 0) {
			nightSkyVisible.forEach(function(o) {
				o = gSky.getCatalogObjectByID(o);
				if(_visibleDuringDay(o)) {
					txt.append(describeObject(o));
				} else {
					l0.append(o.name);
				}
			});
		}

		// Describe the hidden objects.
		if(nightSkyHidden.length > 0) {
			nightSkyHidden.forEach(function(o) {
				o = gSky.getCatalogObjectByID(o);
				if(_visibleDuringDay(o))
					l1.append(o.name);
				else
					l0.append(o.name);
			});
		}

		if(l1.length > 0) {
			txt.append('You can\'t see ');
			txt.append(stringLister.makeSimpleList(l1));
			txt.append('. ');
		}
		if(l0.length > 0) {
			txt.append(stringLister.makeSimpleList(l0));
			if(l0.length == 1)
				txt.append(' isn\'t ');
			else
				txt.append(' aren\'t ');
			txt.append('visible during the day. ');
		}

		defaultReport(toString(txt));
	}

	describeObject(objID) {
		local obj, dir, elev;

		if((obj = gSky.getCatalogObjectByID(objID)) == nil)
			return('');
		gSky.updateEphem(obj);

		elev = _elevations[toInteger((obj.alt / 30) + 1)];
		dir = _directions[toInteger((obj.az / 45) + 1)];

		return('<<obj.name>> is <<elev>> in the <<dir>>. ');
	}
;

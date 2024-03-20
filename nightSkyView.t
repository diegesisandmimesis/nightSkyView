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

modify defaultSky
//nightSkyView: MultiLoc, Distant
	//'sky' 'sky'

	//initialLocationClass = Room

	//hideFromAll(action) { return(true); }

	dobjFor(Examine) {
		preCond = static [ nightSkyViewingConditions ]
		verify() { dangerous; }
	}
;

defaultIndoorSky: MultiLoc, Unthing
	'sky' 'sky'
	initialLocationClass = Room
	notHereMsg = &nightSkyCantSeeNotOutside
;

nightSkyViewObjects: MultiLoc, Fixture, Vaporous, Distant, PreinitObject
	'' 'constellation'
	initialLocationClass = Room

	// List of all objects (that match our vocabulary) mentioned
	// in this turn's action.
	_nightSkyMatchList = perInstance(new Vector())
	_nightSkyMatchTurn = nil

	_nightSkyVisibleList = perInstance(new Vector())

	execBeforeMe = static [ gameSky ]

	hideFromAll(action) { return(true); }

	dobjFor(Examine) {
		preCond = static [
			nightSkyViewingConditions,
			nightSkyObjVisible
		]
		verify() { dangerous; }
		action() {
			//local l;

			//l = getVisibleObjects();
			//if(l.length < 1)
				//return;
			gAction.callAfterActionMain(nightSkyViewReportManager);
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
		if(_nightSkyMatchTurn != libGlobal.totalTurns) {
			_clearLists();
		}

		adjustedTokens.forEach(function(o) {
			if((dataTypeXlat(o) == TypeSString)
				&& (_nightSkyMatchList.indexOf(o) == nil)) {
				_nightSkyMatchList.append(o);
			}
		});

		return(self);
	}

	_clearLists() {
		_nightSkyMatchList.setLength(0);
		//_nightSkyVisibleList.setLength(0);

		_nightSkyMatchTurn = libGlobal.totalTurns;
	}

	getMatchingObjects() { return(_nightSkyMatchList); }

/*
	getVisibleObjects() { return(_nightSkyVisibleList); }

	markVisible(obj, v?) {
		_nightSkyVisibleList.append([ obj, (v ? true : nil) ]);
	}
	*/
;

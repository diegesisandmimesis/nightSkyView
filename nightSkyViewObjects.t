#charset "us-ascii"
//
// nightSkyViewObjects.t
//
#include <adv3.h>
#include <en_us.h>

#include "nightSkyView.h"

nightSkyViewObjects: MultiLoc, Distant, PreinitObject
	'sky' 'sky'

	initialLocationClass = Room

	execBeforeMe = static [ gameSky ]

	hideFromAll(action) { return(true); }

	// List of all objects (that match our vocabulary) mentioned
	// in this turn's action.
	nightSkyMatchList = perInstance(new Vector())
	nightSkyMatchTurn = nil

	indoorsFlag = nil
	nightSkyVisible = perInstance(new Vector())
	nightSkyHidden = perInstance(new Vector())

	_visibilityCache = perInstance(new Vector())
	_visibilityCacheTurn = nil

	checkNightSkyVisibility(objID) {
		local i, r;

		if(_visibilityCacheTurn != libGlobal.totalTurns)
			_visibilityCache.setLength(0);

		if(_visibilityCache.length > 0) {
			for(i = 1; i <= _visibilityCache.length; i++) {
				// Cache hit.
				if(_visibilityCache[i][1] == objID)
					return(_visibilityCache[i][2]);
			}
		}

		// Cache miss.

		r = gSky.checkCatalogObject(objID);

		// Add new cache entry.
		_visibilityCache.append([ id, r ]);
		_visibilityCacheTurn = libGlobal.totalTurns;

		return(r);
	}

	markIndoors() {
		indoorsFlag = true;
		gAction.callAfterActionMain(self);
	}

	markVisibility(objID, v) {
		if(v == true) {
			if(nightSkyVisible.indexOf(objID) == nil)
				nightSkyVisible.append(objID);
		} else {
			if(nightSkyHidden.indexOf(objID) == nil)
				nightSkyHidden.append(objID);
		}
		gAction.callAfterActionMain(self);
	}

	dobjFor(Examine) {
		verify() { dangerous; }
		action() {
			if(!gActor.getOutermostRoom().ofKind(OutdoorRoom)) {
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
		indoorsFlag = nil;
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
		local txt;

		if(indoorsFlag == true) {
			reportFailure(&nightSkyCantSeeNotOutside);
			return;
		}

		txt = new StringBuffer();
		if(nightSkyVisible.length > 0) {
			txt.append('You can see ');
			txt.append(stringLister.makeSimpleList(nightSkyVisible));
			txt.append('. ');
		}
		if(nightSkyHidden.length > 0) {
			txt.append('You can\'t see ');
			txt.append(stringLister.makeSimpleList(nightSkyHidden));
			txt.append('. ');
		}
		defaultReport(toString(txt));
	}
;

#charset "us-ascii"
//
// nightSkyViewObjects.t
//
#include <adv3.h>
#include <en_us.h>

#include "nightSkyView.h"

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
			local obj;

			if(_nightSkyMatchList.length < 1)
				return;

			obj = _nightSkyMatchList[1];

			nightSkyViewReportManager.markVisible(obj, true);
			defaultReport('{You/he} see{s} <<obj>>. ');
			_nightSkyMatchList.splice(1, 1);
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
		nightSkyViewReportManager.clear();

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

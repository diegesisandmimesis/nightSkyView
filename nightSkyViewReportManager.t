#charset "us-ascii"
//
// nightSkyViewReportManager.t
//
//
#include <adv3.h>
#include <en_us.h>

#include "bignum.h"

#include "nightSky.h"

nightSkyViewReportManager: object
	minLength = 0

	_indoorsFlag = nil
	_visibleObjects = perInstance(new Vector())
	_hiddenObjects = perInstance(new Vector())

	markIndoors() {
		_indoorsFlag = true;
		gAction.callAfterActionMain(self);
	}

	markVisible(obj, v?) {
		if(v == true) {
			if(_visibleObjects.indexOf(obj) == nil)
				_visibleObjects.append(obj);
		} else {
			if(_hiddenObjects.indexOf(obj) == nil)
				_hiddenObjects.append(obj);
		}
		gAction.callAfterActionMain(self);
	}

	clear() {
		_visibleObjects.setLength(0);
		_hiddenObjects.setLength(0);
		_indoorsFlag = nil;
	}

	afterActionMain() {
		if(gAction.dobjList_.length() < minLength) {
			return;
		}

		// We shouldn't have any reports to summarize, but we squish
		// 'em if we have 'em.
		gTranscript.summarizeAction(
			function(x) { return(x.action_ == gAction); },
			function(vec) { return(''); }
		);

		skyReport();

		clear();
	}

	skyReport() {
		if(_indoorsFlag == true)
	}
;

fooLister: SimpleLister
	showListItem(str, options, pov, infoTab) { say(str); }
	getArrangedListCardinality(singles, groups, groupTab) {
		return(singles.length());
	}
;

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
	minLength = 2

	_visibleObjects = perInstance(new Vector())
	_hiddenObjects = perInstance(new Vector())

	markVisible(obj, v?) {
		if(v == true) {
			if(_visibleObjects.indexOf(obj) == nil)
				_visibleObjects.append(obj);
		} else {
			if(_hiddenObjects.indexOf(obj) == nil)
				_hiddenObjects.append(obj);
		}
	}

	clear() {
		_visibleObjects.setLength(0);
		_hiddenObjects.setLength(0);
	}

	afterActionMain() {
		if(gAction.dobjList_.length() < minLength) {
			return;
		}
		gTranscript.summarizeAction(
			function(x) {
				return(x.action_ == gAction);
			},
			function(vec) {
				return('<<summarizeVisible(_visibleObjects)>>
					<<summarizeHidden(_hiddenObjects)>>');
			}
		);
		clear();
	}

	summarizeVisible(lst) {
		if((lst == nil) || (lst.length < 1))
			return('');
		return(playerActionMessages.nightSkyVisibleSummary(lst));
	}

	summarizeHidden(lst) {
		if((lst == nil) || (lst.length < 1))
			return('');
		return(playerActionMessages.nightSkyHiddenSummary(lst));
	}
;

fooLister: SimpleLister
	showListItem(str, options, pov, infoTab) { say(str); }
	getArrangedListCardinality(singles, groups, groupTab) {
		return(singles.length());
	}
;

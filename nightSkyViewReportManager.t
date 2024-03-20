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
	_visibleObjects = perInstance(new Vector())

	markVisible(obj, v?) {
		_visibleObjects.append([ obj, (v ? true : nil) ]);
	}
	getVisibleObjects() { return(_visibleObjects); }

	afterActionMain() {
		gTranscript.summarizeAction(
			function(x) {
				return(x.action_ == gAction);
			},
			function(vec) {
				local l, hidden, visible;
				l = getVisibleObjects();
				hidden = new Vector(l.length);
				visible = new Vector(l.length);
				l.forEach(function(o) {
					if(o[2] == true)
						visible.append(o[1]);
					else
						hidden.append(o[1]);
				});
				return('foo');
			}
		);
		_visibleObjects.setLength(0);
	}
;

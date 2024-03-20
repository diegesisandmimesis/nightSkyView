#charset "us-ascii"
//
// nightSkyViewMsg.t
//
//	Action messages used by the nightSkyView module.
//
//
#include <adv3.h>
#include <en_us.h>

#include "nightSkyView.h"

modify playerActionMessages
	// IMPORTANT:  The argument we never use is necessary, because
	// one of the things that uses this message is our sky Unthing,
	// and Unthing calls us via mainReport([propname], self).
	nightSkyCantSeeNotOutside(o?) {
		return('{You/he} can\'t see the sky from here. ');
	}

	nightSkyCantExamineMulti = '{You/he} can only examine one thing at a time. '

	nightSkyVisibleSummary(lst) {
		return('{You/he} see
			<<stringLister.makeSimpleList(lst)>>. ');
	}
	nightSkyHiddenSummary(lst) {
		return('{You/he} can\'t see
			<<fooLister.makeSimpleList(lst)>>. ');
	}

	nightSkyCantSeenObjs(lst) {
		return('{You/he} can\'t see
			<<stringLister.makeSimpleList(lst)>>. ');
	}
;

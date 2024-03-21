#charset "us-ascii"
//
// nightSkyViewPreCondition.t
//
//
#include <adv3.h>
#include <en_us.h>

#include "nightSkyView.h"

enum nightSkySeeingClear, nightSkySeeingCloudy, nightSkySeeingDay,
	nightSkySeeingIndoors;

nightSkySeeing: PreCondition
	verifyPreCondition(obj) {
		switch(gNightSkySeeing) {
			case nightSkySeeingIndoors:
				illogical(&nightSkyCantSeeNotOutside);
				break;
			case nightSkySeeingClear:
				break;
		}
	}
;

modify NightSky
	seeing = nil
	seeingTurn = nil

	getSeeing(ignoreActor?) {
		local ts;

		ts = libGlobal.totalTurns;
		if((ts == seeingTurn) && (seeing != nil))
			return(seeing);

		seeingTurn = ts;

		if((ignoreActor != true)
			&& !gActor.getOutermostRoom().ofKind(OutdoorRoom)) {
			seeing = nightSkySeeingIndoors;
			return(seeing);
		}

		if(abs(gSky.getSunMeridianPosition()) < 12) {
			seeing = nightSkySeeingDay;
			return(seeing);
		}
		
		seeing = nightSkySeeingClear;
		return(seeing);
	}
;

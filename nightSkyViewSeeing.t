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
	seeingTimestamp = nil

	getSeeing(ignoreActor?) {
		local ts;

		ts = calendar.getTimestamp();
		if((ts == seeingTimestamp) && (seeing != nil))
			return(seeing);

		seeingTimestamp = ts;

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

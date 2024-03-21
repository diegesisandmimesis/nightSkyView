//
// nightSkyView.h
//

#include "nightSky.h"
#ifndef NIGHT_SKY_H
#error "This module requires the nightSky module."
#error "https://github.com/diegesisandmimesis/nightSky"
#error "It should be in the same parent directory as this module.  So if"
#error "nightSkyView is in /home/user/tads/nightSkyView, then"
#error "nightSky should be in /home/user/tads/nightSky ."
#endif // NIGHT_SKY_H

#define gNightSkyReport (nightSkyViewReportManager)
#define gNightSkySeeing (gSky.getSeeing())

EphemView template 'name' 'view';

#define NIGHT_SKY_VIEW_H

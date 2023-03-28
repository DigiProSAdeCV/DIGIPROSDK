//
//  VDEnums.h
//  VDOnBoarding
//
//  Copyright © 2017 das-Nano. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 @brief (DEPRECATED) Enumeration that defines the documents available.
 */
typedef enum {
    VDVideoError = -1,
    VDVIDEO_DNI_20_ESPANA = 1,      ///< Spanish 2.0 document                // 1
    VDVIDEO_DNI_30_ESPANA,          ///< Spanish 3.0 document                // 2
    VDVIDEO_NIE_ESPANA_2011,        ///< Spanish NIE 2011                    // 3
    VDVIDEO_IFE_MEXICO_B,           ///< Mexican IFE B                       // 4
    VDVIDEO_IFE_MEXICO_C,           ///< Mexican IFE C                       // 5
    VDVIDEO_IFE_MEXICO_E = 7,           ///< Mexican IFE E                       // 7
    VDVIDEO_NIE_ESPANA_2010 = 10,   ///< Spanish NIE 2010                    // 10
    VDVIDEO_PASSPORT,               ///< Passport                            // 11
    VDVIDEO_KAD_MALASIA_2001,       ///< Malaysian KAD 2001                  // 12
    VDVIDEO_DNI_ARGENTINA_2009,     ///< Argentinian 2009 document           // 13
    VDVIDEO_DNI_ARGENTINA_2012,     ///< Argentinian 2012 document           // 14
    VDVIDEO_DNI_PERU_2013 = 20,     ///< Peruan 2013 document                // 20
    VDVIDEO_DNI_PERU_2007,          ///< Peruan 2007 document                // 21
    VDVIDEO_IDCARD_CO_2000,         ///< Colombian 2000 document             // 22
    VDVIDEO_CZ_IDCARD_2003 = 260,   ///< Czechia IDCard 2003                 // 260
    VDVIDEO_AT_IDCARD_2002 = 140,
    VDVIDEO_AT_IDCARD_2010 = 143,
    VDVIDEO_AT_DRIVINGLICENSE_2006 = 141,
    VDVIDEO_AT_DRIVINGLICENSE_2014 = 142,
    VDVIDEO_AT_DRIVINGLICENSE_2004 = 144
} VDDocumentVideoEnum;



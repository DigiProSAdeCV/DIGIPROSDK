//
//  ValiDasConstantes.h
//  ValiDasLibrary
//
//  Copyright © 2016 das-nano. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum {
    MODE_XML,
    MODE_TM,
    MODE_RECTANGLES,
} detectorMode;

/**
 Definición de tipos de documento a encontrar
 */
typedef enum {
    OBVERSE_WITHOUT_FLASH,
    OBVERSE_WITH_FLASH,
    REVERSE_WITHOUT_FLASH,
    REVERSE_WITH_FLASH,
    RECTANGLE_BOX_OBVERSE,
    RECTANGLE_BOX_REVERSE,
    PASSPORT_ANALYSIS,
    UNINITIALIZED
} AnalysisType;

/**
 @brief Definición de tipos de documento según el estandar de ICAO
 */
typedef enum {
    TD1,
    TD2,
    TD3,
} DocumentTravelType;

typedef enum{
    VIDEO,
    DOCUMENT
} SearchType;

typedef enum {
    PATTERN_ERROR,
    PATTERN_NOT_FOUND,
    PATTERN_FAR,
    PATTERN_MID_PROXIMITY,
    PATTERN_CLOSE,
    PATTERN_VERY_CLOSE,
    PATTERN_EXTREMELY_CLOSE,
    PATTERN_EXTREMELY_FAR,
    PATTERN_NOT_CENTERED
} PatternProximity;

/**
 Definición de tipos de error
 */
typedef enum {
    ANALYSIS_OK,
    ANALYSIS_KO
} ResultType;


@interface ValiDasConstantes : NSObject

/**
 Converts enum to string.
 */
extern NSString* __nonnull const PatternProximity_toString[];

/**
This constants (self-explanatory) declare the values used for the name in the UserAgent  struct.
*/
extern NSString* __nonnull const kUserAgentSDKDocument;
extern NSString* __nonnull const kUserAgentSDKPhotoSelfie;
extern NSString* __nonnull const kUserAgentSDKAliveSelfie;
extern NSString* __nonnull const kUserAgentSDKVideo;
extern NSString* __nonnull const kUserAgentSDKNfc;

@end


//
//  VDVideoSelfieCapture.h
//  VDVideoSelfieCapture
//
//  Copyright © 2017 das-nano. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <VDLibrary/ValiDas.h>
#import "VDEnums.h"

//@protocol VDLoggerProtocol;

/**
 @brief Enumeration that defines the different capturing modes available.
 */
typedef enum {
    VD_ONBOARDING,          ///< Full lifeproof mode with SEPBLAC requirements, showing ID card.
    VD_AUTHENTICATION,      ///< Lifeproof  mode to authenticate the user.
} VDLifeProofMode;

/**
 @brief Document ids constants
 */
static NSString* const VDVIDEO_ID_ES_IDCard_2006 = @"ES_IDCard_2006";
static NSString* const VDVIDEO_ID_ES_IDCard_2015 = @"ES_IDCard_2015";
static NSString* const VDVIDEO_ID_ES_IDCard_2021 = @"ES_IDCard_2021";
static NSString* const VDVIDEO_ID_ES_ResidencePermit_2010 = @"ES_ResidencePermit_2010";
static NSString* const VDVIDEO_ID_ES_ResidencePermit_2011 = @"ES_ResidencePermit_2011";
static NSString* const VDVIDEO_ID_MX_IDCard_2008 = @"MX_IDCard_2008";
static NSString* const VDVIDEO_ID_MX_IDCard_2014 = @"MX_IDCard_2014";
static NSString* const VDVIDEO_ID_AR_IDCard_2009 = @"AR_IDCard_2009";
static NSString* const VDVIDEO_ID_AR_IDCard_2012 = @"AR_IDCard_2012";
static NSString* const VDVIDEO_ID_PE_IDCard_2013 = @"PE_IDCard_2013";
static NSString* const VDVIDEO_ID_PE_IDCard_2007 = @"PE_IDCard_2007";
static NSString* const VDVIDEO_ID_CO_IDCard_2000 = @"CO_IDCard_2000";
static NSString* const VDVIDEO_ID_MYS2001 = @"MYS2001";
static NSString* const VDVIDEO_ID_AT_DrivingLicense_2006 = @"AT_DrivingLicense_2006";
static NSString* const VDVIDEO_ID_AT_DrivingLicense_2014 = @"AT_DrivingLicense_2014";
static NSString* const VDVIDEO_ID_AT_IDCard_2002 = @"AT_IDCard_2002";
static NSString* const VDVIDEO_ID_AT_IDCard_2010 = @"AT_IDCard_2010";


/**
 @brief Protocol that comunicates this framework with an app/framework/library that uses it. 
 @details Currently all methods are required.
 */
@protocol VDVideoSelfieCaptureProtocol <NSObject>

@required
/**
 @brief Delegate method which will notify when the selfie video is captured
 @param videoSelfieData (NSData*) Contains the data of the video selfie captured.
 */
- (void)VDVideoSelfieCaptured:(NSData*)videoSelfieData;
- (void)VDVideoSelfieCaptured:(NSData*)videoSelfieData withProcessInfo:(NSData*) processInfo;

/**
 @brief Delegate method which will notify when the video process has finished completely
 @param processFinished (Boolean) Indicates if the process has finish (true) or has been interrupted (false)
 @details This method will be called always at the end of the process or when stop has been called when everything is stopped.
 */
- (void)VDVideoSelfieAllFinished:(Boolean)processFinished;

@end

/**
 @brief Class that contains the main functions of the Framework.
 @details Its the main class of this Framework. The public methods of this class are the ones used to make this Framework work.
 */
@interface VDVideoSelfieCapture : NSObject

/**
 @brief This method will stop the SDK and all its functionalities, so it needs to be started again. The SDK will not provide any more outputs after this method and the app flow will be given to the app.
 */
+ (void)stop;

/**
 @brief (DEPRECATED)This method sets the token to add as metadata to the video.
 @param token (NSString*) The token to add.
 */
+ (void)setToken:(NSString*)token __attribute__((deprecated("Should be introduced via configuration")));

/**
 @brief (DEPRECATED) This methods sets the document to show in the video.
 @param document (VDDocumentEnum) The document to show in the video.
*/
+ (void)setDocumentToSearch:(VDDocumentVideoEnum)document __attribute__((deprecated("Should be used setDocumentStringToSearch"))); 

/**
 @brief This methods sets the document to show in the video.
 @param document (NSString) The document id to show in the video.
 */
+ (void)setDocumentStringToSearch:(NSString *)document;

/**
 @brief This method is needed to use the SDK. It programs the delegate to which the SDK will notify the outputs.
 @param delegate (UIViewController <VDPhotoSelfieCaptureProtocol>*) The instance to which the SDK will notify all its outputs.
 @param config (NSDictionary) The configuration of the SDK.
 @return (UIViewController*) The UIViewController that is shown.
 */
+ (UIViewController *)startWithDelegate:(UIViewController<VDVideoSelfieCaptureProtocol>*)delegate andConfiguration:(NSDictionary *)config;

/**
 @brief This method is needed to use the SDK. It programs the delegate to which the SDK will notify the outputs.
 @param delegate (UIViewController <VDPhotoSelfieCaptureProtocol>*) The instance to which the SDK will notify all its outputs.
 @param type (VDLifeProofMode) The type of video is going to be taken.
 @return (UIViewController*) The UIViewController that is shown.
 */
+ (UIViewController*)startWithDelegate:(UIViewController<VDVideoSelfieCaptureProtocol> *)delegate andMode:(VDLifeProofMode)type;

/**
 @brief This method is used to ask the SDK if it is already running
 @returns (BOOL) Whether the SDK is running or not
 */
+ (BOOL)isStarted;

/**
 @brief This method is used to ask for the SDK’s version.
 @returns (NSString *) A string which contains the SDK version
 */
+ (NSString*)getVersion;

/**
 @brief This method is used to ask for the configuration keys.
 @returns (NSArray *) A array which contains the keys.
 */
+ (NSArray*)getConfigurationKeys;

///**
// @brief This method is used to add a logger to the SDK
// @param logger (id <VDLoggerProtocol>*) type implementing a VDLogger protocol.
// @param loggerId (NSString*) Name of the logger.
// */
//+ (void) addLogger:(_Nonnull id<VDLoggerProtocol>)logger withId:(NSString * _Nonnull)loggerId;


@end

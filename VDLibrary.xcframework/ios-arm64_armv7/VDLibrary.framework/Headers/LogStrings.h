//
//  LogStrings.h
//  VDLibrary
//
//  Copyright © 2020 BBVA. All rights reserved.
//

#ifndef LogStrings_h
#define LogStrings_h
// General logs
static NSString* __nonnull const CONFIGURATED_KEYS_LOG = @"Configurated keys: ";
static NSString* __nonnull const SO_VERSION_LOG = @"SO version: ";
static NSString* __nonnull const SDK_VERSION_LOG = @"SDK version: ";
static NSString* __nonnull const BUNDLE_IDENTIFIER_LOG = @"Package name: ";
static NSString* __nonnull const START_SDK_LOG = @"Start";
static NSString* __nonnull const DEVICE_LOG = @"Brand: Apple; Model: %@; iOS verion: %@";


//image review
static NSString* __nonnull const REPEAT_LOG = @"Repeat pressed";
static NSString* __nonnull const CONTINUE_LOG = @"Continue pressed";
static NSString* __nonnull const SHOW_TUTORIAL_LOG = @"Tutorial is opened";

static NSString* __nonnull const CLOSE_BUTTON_LOG = @"Close button is pressed";
static NSString* __nonnull const ALL_FINISH_LOG = @"Finish success: %@";
static NSString* __nonnull const FPS_LOG = @"FPS: ";

static NSString* __nonnull const TEMPLATE_DISTANCE_LOG =  @"Template distance: ";
static NSString* __nonnull const VIEW_WILL_DISAPPEAR_LOG =  @"viewWillDissappear called";
static NSString* __nonnull const VIEW_WILL_APPEAR_LOG =  @"viewWillAppear called";
static NSString* __nonnull const VIEW_DID_APPEAR_LOG =  @"viewDidAppear called";
static NSString* __nonnull const PERMISIONS_REFUSED_LOG =  @"Permissions refused";
static NSString* __nonnull const PERMISSION_MICRO_LOG =  @"ios.permission.RECORD_AUDIO: %@";
static NSString* __nonnull const PERMISSION_CAMERA_LOG =  @"ios.permission.CAMERA: %@";

static NSString* __nonnull const CAPTURE_PREVIEW_SIZE_LOG =  @"Preview size: %fx%f; Capture size: %fx%f";


/// VDPhotoSelfieCapture logs
static NSString* __nonnull const ORIENTATION_KO_LOG = @"Orientation KO";
static NSString* __nonnull const ORIENTATION_OK_LOG = @"Orientation OK";
static NSString* __nonnull const FACE_DETECTED_LOG = @"Face detected in frame";
static NSString* __nonnull const FACE_NOT_DETECTED_LOG = @"Face NOT detected in frame";
static NSString* __nonnull const FACE_CAPTURED_LOG = @"Face captured";
static NSString* __nonnull const FACE_ALL_DETECTIONS_ARE_DONE_LOGS = @"Face all detections done";
/// VDPhotoSelfieAliveCapture logs
static NSString* __nonnull const FACE_NEED_SMILE_LOG = @"Selfie smile request with progress: %.2f";
static NSString* __nonnull const FACE_NEED_SERIUS_LOG = @"Selfie serious request with progress: %.2f";

/// VDDocumentCapture logs
static NSString* __nonnull const TIME_WITHOUT_PHOTO_TAKEN_LOG = @"Seconds without photo taken: ";
static NSString* __nonnull const DOCUMENT_OBVERSE_DETECTED = @"Obverse detected";
static NSString* __nonnull const DOCUMENT_REVERSE_DETECTED = @"Reverse detected";
static NSString* __nonnull const DOCUMENT_PASSPORT_DETECTED = @"Passport detected";
static NSString* __nonnull const SHUTTER_BUTTON_LOG = @"The capture is taken with shutter button";
static NSString* __nonnull const DOCUMENT_OBVERSE_CAPTURED_LOG = @"Obverse captured";
static NSString* __nonnull const DOCUMENT_OBVERSE_WITH_FLASH_CAPTURED_LOG = @"Obverse with flash captured";
static NSString* __nonnull const DOCUMENT_REVERSE_CAPTURED_LOG = @"Reverse captured";
static NSString* __nonnull const DOCUMENT_REVERSE_WITH_FLASH_CAPTURED_LOG = @"Reverse with flash captured";
static NSString* __nonnull const POSSIBLE_DOCUMENTS_LOG = @"Possible documents: ";
static NSString* __nonnull const DOCUMENT_PROGRESS_LOG = @"Progress: ";

/// VDVideoSelfieCapture
static NSString* __nonnull const VIDEO_DOCUMENT_LOG = @"Document set: %@";
static NSString* __nonnull const SMART_VIDEO_LOG = @"Smart video: %@";
static NSString* __nonnull const VIDEO_DOCUMENT_DETECTED_LOG = @"Document detected";
static NSString* __nonnull const VIDEO_FACE_ERROR_LOG = @"No face detected error";
static NSString* __nonnull const VIDEO_FACE_RECT_LOG = @"Face detected in: Rect(%f, %f, %f, %f)";
static NSString* __nonnull const VIDEO_DOC_RECT_LOG = @"Doc detected in: Rect(%f, %f, %f, %f)";
static NSString* __nonnull const VIDEO_TIMEOUT_LOG = @"Timeout with status: %@";


/// Messages
static NSString* __nonnull const MSG_TRUE =                   @"true";
static NSString* __nonnull const MSG_FALSE =                  @"false";

// Logger Levels
#define LOGGER_TRACE 0
#define LOGGER_DEBUG 1
#define LOGGER_INFO 2
#define LOGGER_NOTICE 3
#define LOGGER_WARNING 4
#define LOGGER_ERROR 5
#define LOGGER_ATTENTION 6
#define LOGGER_CRITICAL 7


#endif /* LogStrings_h */

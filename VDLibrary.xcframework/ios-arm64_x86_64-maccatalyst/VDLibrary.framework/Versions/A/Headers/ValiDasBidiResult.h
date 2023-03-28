//
//  ValiDasBidiResult.h
//  VDLibrary
//
//  Copyright © 2020 BBVA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <VDLibrary/ValiDasBidiCode.h>
//#import <GoogleMobileVision/GoogleMobileVision.h>

NS_ASSUME_NONNULL_BEGIN

@interface ValiDasBidiResult : NSObject

@property(nonatomic, strong, nonnull) NSString *bidiString;
@property(nonatomic) BidiType bidiType;

//-(id _Nonnull)initWithResult:(GMVBarcodeFeature*)result;

@end

NS_ASSUME_NONNULL_END

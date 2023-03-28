//
//  TimeConfigurations.h
//  VDLibrary
//
//  Copyright © 2020 BBVA. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TimeConfigurations : NSObject

@property (nonatomic, readonly) float secondsForObverseDetection;
@property (nonatomic, readonly) float secondsForReverseDetection;
@property (nonatomic, readonly) float secondsForObverseCountdown;
@property (nonatomic, readonly) float secondsForReverseCountdown;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype) initWithDocuments: (NSArray<NSString *> *) documents;

@end

NS_ASSUME_NONNULL_END

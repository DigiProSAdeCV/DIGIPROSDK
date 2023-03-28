//
//  Artifact.h
//  VDLibrary
//
//  Created by Veridas on 21/6/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Artifact : NSObject

@property(nonatomic, strong, nonnull) NSData *imageData;
@property(nonatomic, strong, nonnull) NSString *nameClass;

@end

NS_ASSUME_NONNULL_END

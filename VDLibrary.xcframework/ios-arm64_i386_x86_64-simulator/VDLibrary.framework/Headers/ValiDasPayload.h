//
//  ValiDasPayload.h
//  VDLibrary
//
//  Copyright © 2020 BBVA. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ValiDasPayload : NSObject

@property(nonatomic, strong, nonnull) NSString *className;
@property(nonatomic, strong, nonnull) NSString *mimeType;
@property(nonatomic, strong, nonnull) NSString *name;
@property(nonatomic, strong, nonnull) NSDictionary *params;
@property(nonatomic, strong, nonnull) NSString *body;

-(NSDictionary* _Nonnull)getMetadata;

@end

NS_ASSUME_NONNULL_END

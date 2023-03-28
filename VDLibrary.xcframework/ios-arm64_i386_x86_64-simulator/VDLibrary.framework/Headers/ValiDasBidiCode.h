//
//  ValiDasBidiCode.h
//  VDLibrary
//
//  Copyright © 2020 BBVA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum {
    CODE39 = 0,
    CODE128,
    DATAMATRIX,
    ITF14,
    PDF417,
    QR
} BidiType;

typedef enum {
    none = 0,
    deg90 = 90,
    deg180 = 180,
    deg270 = 270
} Rotation;

typedef enum {
    OBVERSE = 0,
    REVERSE
} SideType;

NS_ASSUME_NONNULL_BEGIN

@interface ValiDasBidiCode : NSObject

@property(nonatomic) CGRect region;
@property(nonatomic) int rotation;
@property(nonatomic) BOOL isInObverse;
@property(nonatomic) BOOL isInReverse;
@property(nonatomic) BidiType type;
@property(nonatomic, strong, nonnull) NSString *body;

- (id _Nonnull)initWithJson:(NSDictionary*)json;
+ (NSString* _Nonnull)getStringBidiType:(BidiType)type;
- (NSString * _Nonnull) description;

@end

NS_ASSUME_NONNULL_END

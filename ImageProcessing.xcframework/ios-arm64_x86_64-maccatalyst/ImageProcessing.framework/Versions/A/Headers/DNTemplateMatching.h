//
//  DNTemplateMatching.h
//  ImageProcessing
//
//  Copyright © 2016 das-nano. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class DNTemplateMatchingConfiguration;


@interface DNTemplateMatching : NSObject
/**
 @brief Public method that detect an object using template matching.
 @param set_image (UIImage *) Original image.
 @param set_template (UIImage *) Template image.
 @param set_config (FinderMatchingConfig *) Configuration object
 @returns CGRect Region of the object
 */
+ (CGRect)findObject:(UIImage *)set_image template:(UIImage *)set_template configuration:(DNTemplateMatchingConfiguration *)set_config;

@end

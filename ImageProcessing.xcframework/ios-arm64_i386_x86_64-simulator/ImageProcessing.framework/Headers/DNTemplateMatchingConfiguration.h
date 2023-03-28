//
//  DNTemplateMatchingObjects.h
//  ImageProcessing
//
//  Copyright © 2016 das-nano. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Clase que estructura el resultado del matching.
 */
@interface DNTemplateMatchingConfiguration : NSObject

@property NSInteger rangePyr;
@property double pyrFactor;
@property NSUInteger gray;
@property float factorROI;
@property float minFactorImgTempl;
@property double thMaxValue;
@property NSUInteger thArea;
@property NSUInteger prevMargin;
@property BOOL useCLAHE;
@property float xTransformationFactor;
@property float yTransformationFactor;
@property float widthTransformationFactor;
@property float heightTransformationFactor;

@end


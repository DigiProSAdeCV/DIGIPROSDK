//
//  BlurTechnics.h
//  ImageProcessing
//
//  Copyright © 2018 das-Nano SL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BlurTechnics : NSObject

+ (CGRect) findPassportInImage:(UIImage*) image referenceRect:(CGRect) rect;

@end


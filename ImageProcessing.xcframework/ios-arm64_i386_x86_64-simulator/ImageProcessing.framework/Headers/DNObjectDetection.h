//
//  DNObjectDetection.h
//  ImageProcessing
//
//  Copyright © 2016 das-nano. All rights reserved.
//

#import "DNObjectDetectionConfig.h"

#import <UIKit/UIKit.h>

@class OpenCVObjectDetectionWrapper;

@interface DNObjectDetection : NSObject {
    
    /**
     Instancia de pasarela entre código Objetive-C y C++
     */
    OpenCVObjectDetectionWrapper *_wrapper;
    
}

/**
 Método constructor que devuelve una instancia para buscar objetos
 @param aConfig Configuración de la búsqueda de objetos
 @returns Instancia para buscar objetos
 */
- (instancetype)init:(DNObjectDetectionConfig *)aConfig;

/**
 Método que devuelve una lista de candidatos a objetos
 @param image Imagen a analizar
 @returns Lista de CGRect
 */
- (NSArray *)findObjects:(UIImage *)image;

/**
 Método para finalizar la instancia de búsqueda de objetos
 */
- (void)finish;

/**
 Configuración de la búsqueda de objetos
 */
@property (nonatomic, readonly) DNObjectDetectionConfig *configuration;

@end

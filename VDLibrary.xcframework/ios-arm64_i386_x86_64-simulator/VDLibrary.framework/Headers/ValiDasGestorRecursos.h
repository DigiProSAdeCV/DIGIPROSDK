//
//  ValiDasGestorRecursos.h
//  ValiDasLibrary
//
//  Copyright © 2016 das-nano. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <VDLibrary/ValiDasConstantes.h>

#define kValiDasResourcesPath   @"valiDasResources"
#define kValiDasMyResourcesPath @"myResources"
#define kValiDasJsonConfigPath  @"myJson"
#define kValiDasDocumentName    @"documento_%i.jpg"

@interface ValiDasGestorRecursos : NSObject

/**
 Método invocado cuando se desea desempaquetar los recursos de la librería
 */
+ (void)unzipResources;

/**
 Método que obtiene la ruta del recurso solicitado
 @param name Nombre del recurso solicitado
 @returns NSString Ruta del recurso solicitado
 */
+ (NSString *)getPathForResourceName:(NSString *)name;

/**
 Método que obtiene la ruta del json solicitado
 @param name Nombre del json solicitado
 @returns NSString Ruta del json solicitado
 */
+ (NSString *)getPathForJsonName:(NSString*)name;

/**
 Método invocado cuando se desea eliminar los recursos de la librería
 */
+ (void)deleteResources;

/**
 Método que guarda una imagen para un tipo de análisis
 @param image UIImage la imagen a guardar
 @param type AnalysisType el tipo de análisis
 */
+ (void)saveImage:(UIImage*)image forAnalysisType:(AnalysisType)type;

/**
 Método que recupera una imagen guardada para un tipo de análisis
 @param type AnalysisType el tipo de análisis
 @returns UIImage la imagen guardada
 */
+ (UIImage*)getSavedImageForAnalysisType:(AnalysisType)type;

@end

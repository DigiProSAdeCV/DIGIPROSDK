//
//  ValiDasPais.h
//  ValiDasLibrary
//
//  Copyright © 2016 das-nano. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <VDLibrary/ValiDasConstantes.h>

/**
 @brief Clase que representa un país.
 @details Consta de tres propiedades. La primera representa la enumeración del país. La segunda el nombre con el que se conoce ese país (en un futuro se localizará este strin). La tercera almacena el códgigo ISO del país. Todas son sólo de lectura para evitar que se pueda meter de forma errónea valores. Cada constructor rellena todas las pripiedades.
 */
@interface ValiDasPais : NSObject

/**
 @brief Propiedad de sólo lectura que representa el código ISO internacional del país.
 */
@property(nonnull, nonatomic, strong, readonly) NSString *isoCode;

/**
 @brief Constructor de la clase que recibe un NSString con el código ISO del país a iniciar.
 @param isoCode (NSString *) Código ISO del país con el que iniciar la clase.
 */
- (instancetype _Nonnull)initWithIsoCode:(NSString * _Nonnull)isoCode;

@end

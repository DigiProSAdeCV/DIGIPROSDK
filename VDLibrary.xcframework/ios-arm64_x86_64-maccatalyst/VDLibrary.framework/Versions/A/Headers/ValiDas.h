//
//  ValiDasLibrary.h
//  ValiDasLibrary
//
//  Copyright © 2015 das-nano. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <ImageIO/ImageIO.h>
#import <VDLibrary/ValiDasDocumento.h>
#import <VDLibrary/ValiDasConstantes.h>
#import <VDLibrary/FirebaseTagProtocol.h>
#import <VDLibrary/ValiDasBidiCode.h>
#import <VDLibrary/ValiDasBidiResult.h>
#import <VDLibrary/ValiDasPayload.h>
#import <VDLibrary/UserAgent.h>
#import <VDLibrary/Artifact.h>

@protocol ProtocoloValiDas <NSObject>

@optional
/**
 @brief Método delegado invocado cuando se detecta el frontal del DNI.
 */
- (void)documentObverseDetected;

/**
 @brief Método delegado invocado cuando se detecta el reverso del DNI.
 */
- (void)documentReverseDetected;

/**
 @brief Método delegado invocado cuando se detecta el reverso del DNI.
 */
- (void)passportDetected;

/**
 @brief Método delegado invocado cuando se detecta el selfie del usuario.
 */
- (void)frontFaceDetected;

/**
 @brief Método delegado invocado cuando se desea alertar debido al brillo.
 */
- (void)brightDetected;

/**
 @brief Método delegado invocado cuando se desea quitar la alerta del brillo.
 */
- (void)deleteBright;

/**
 @brief Método delegado invocado cuando se desea notificar la distaincia a la que se encuentra el DNI.
 @param proximity Distancia a la que se encuentra el DNI.
 */
- (void)patternDistance:(PatternProximity)proximity;

/**
 @brief Método delegado invocado cuando se desea notificar la finalización de la detección de un documento
 @param result Tipo de resultado
 */
- (void)analysisFinished:(ResultType)result;

/**
 @brief Método que devuelve un diccionario con la información de los países y documentos disponibles para su procesado en la aplicación.
 @param dictionary (NSDictionary <NSString *, ValiDasDocumento *> *) Diccionario con la información de los paíse en las claves y de los documentos en los valores.
 */
- (void)getDocumentDictionary:(NSDictionary <NSString *, ValiDasDocumento *> *)dictionary;

/**
 @brief Método delegado que envía la información del documento encontrado.
 @param docType (NSArray<NSNumber *> *), tipo de documento encontrado.
 */
- (void)documentTypeFound: (NSArray<NSString *> *) docType;

- (void)fpsCalculated:(int)fps;

@end

@interface ValiDas : NSObject

/**
 @brief Método invocado cuando se desea inicializar el sistema vali-Das
 @param delegate (id) Instancia de la clase.
 */
+ (void)initWithDelegate:(Class)delegate;

/**
 @brief Método invocado cuando se desea finalizar el sistema vali-Das
 */
+ (void)finalizeInstance;

/**
 @brief Método que permite programar un delegado al que devolver los eventos del protocolo
 @param delegate (id) Instancia de la clase.
 */
+ (void)setDelegate:(id)delegate;

/**
 @brief Método que busca un documento en una imagen
 @param documentArray (NSArray<ValiDasDocumento*>*) Array de documentos a buscar
 @param type (AnalysisType) Tipo de análisis a realizar
 @param image (UIImage *) Imagen original
 @returns GRect Región que contiene las regiones del documento
 */
+ (CGRect)searchDocumentsWithDocs:(NSArray<ValiDasDocumento*>*)documentArray analysisType:(AnalysisType)type image:(UIImage*)image andSearchType: (SearchType) searchType;

/**
 @brief Método que busca una cara frontal en una imagen
 @param image (UIImage *) Imagen original
 @param tightness (NSString *)
 @returns GRect Región que contiene la región de la cara
 */
+ (CGRect)searchFrontalFace:(UIImage*)image withTightness:(NSString *)tightness;

/**
 @brief Método que busca una cara frontal en una imagen
 @param image (UIImage *) Imagen original
 @returns GRect Región que contiene la región de la cara
 */
+ (CGRect)searchFrontalFaceVideo:(UIImage*)image;

/**
 @brief Método que busca un código Bidi en una imagen. La librería rotará la imagen manualmente según las rotaciones recibidas.
 @param image (UIImage *) Imagen original.
 @param hints (NSArray) Array con los formatos a buscar. ENUM BidiType.
 @param rotations (NSArray) Array con las rotaciones de los códigos a buscar. ENUM Rotation.
 @returns NSArray<ValiDasBidiResult*>* Array deo bjetos con la info del código bidi leído o nil si no se lee nada
 */
+ (NSArray<ValiDasBidiResult*>*)searchBidiCodes:(UIImage*)image hints:(NSArray*)hints rotations:(NSArray*)rotations;

/**
 @brief Método que analiza una imagen que contiene una cara frontal
 @param image (UIImage *) Imagen original
 */
+ (void)analizeFrontalFace:(UIImage *)image;

/**
 @brief Método que analiza un vídeo en busca de pruebas de vida.
 */
+ (void)analizeProofOfLife;

/**
 @brief Método que indica fin de captura de datos.
 */
+ (void)stopCaptureData;

/**
 @brief Método que demanda la imagen selfie
 @returns UIImage Imagen selfie
 */
+ (UIImage *)getSelfieImage;

/**
 @brief Método que cancela el proceso de validación.
 */
+ (void)cancel;

/**
 @brief Método que devuelve la versión de la librería
 @returns NSString Versión de la librería
 */
+ (NSString *)version;

+ (UIImage *)getStoredImage:(int)analysisType;

/**
 @brief Método que devuelve el valor de enfoque a utilizar
 @param standardType (NSString*) Standard_type del documento
 @returns double Valor de enfoque
 */
+ (double)getFocusValue:(NSString*)standardType;

/**
 Sets the screen size for tests (device not available)
 @param size size of the screen.
 */
+ (void) setScreenSizeForTest: (CGSize) size;

/**
 @brief Get the reference region where to locate the document.
 @returns (CGRect) Rect with the region.
 */
+ (CGRect)getReferenceRegion;
+ (CGRect)getReferenceRegion:(NSString*)standardType;

/**
 @brief Get the reference region where to locate the passport.
 @returns (CGRect) Rect with the region.
 */
+ (CGRect)getReferenceRegionPassport;

/**
 @brief Gets the device model string.
 @returns (NSString *) String with the device model.
 */
+ (NSString *)getDeviceModel;
+ (void)restartSearch;
+ (CGRect)getReferenceRegionOpenCV:(CGSize)sizeImage;

/**
 @brief Returns all the available default configuration.
 @returns (NSDictionary*) Default configuration.
 */
+(NSDictionary*)getDefaultConfig;

/**
 @brief Returns all the available documents info ordered by group.
 @returns (NSDictionary *) Available Documents by Group.
 */
+ (NSDictionary*)getAvailableDocumentsByGroup;

/**
 @brief Returns all the available documents.
 @returns (NSArray *) Available Documents.
 */
+ (NSArray*)getAvailableDocuments;

/**
 @brief Returns the standard type for document.
 @param doc (NSString*) Document Id
 @returns (NSString *) standard type
 */
+ (NSString*)getStandardTypeForDocument:(NSString*)doc;

/**
 @brief Returns the image template name for document.
 @param doc (NSString*) Document Id
 @param forReverse (BOOL) If search for reverse or not
 @returns (NSString *) standard type
 */
+ (NSString*)getTemplateNameForDocument:(NSString*)doc forReverse:(BOOL)forReverse;

/**
@brief Returns the bidi documents for document.
@param doc (NSString*) Document Id
@returns (NSArray<ValiDasBidiCode>*) array with ValiDasBidiCode objects for the document or nil if there are no codes for that document
*/
+(NSArray<ValiDasBidiCode*>*)getBidiCodesForDocument:(NSString*)doc;

/**
@brief Returns the bidi documents for document in a given side.
@param doc (NSString*) Document Id
@param side (SideType) the document side for getting bidi codes.
@returns (NSArray<ValiDasBidiCode>*) array with ValiDasBidiCode objects for the document or nil if there are no codes for that document in that side
*/
+(NSArray<ValiDasBidiCode*>*)getBidiCodesForDocument:(NSString*)doc side:(SideType)side;

/**
 @brief Returns the document id for a document legacy id.
 @param legacyId (NSString*) legacy id
 @returns (NSString *) Document id
 */
+ (NSString*)getDocumentForLegacyId:(NSString*)legacyId;
+ (NSString*)getLegacyIdForDocument:(NSString*)document;


/**
 @brief Returns the ValiDasDocument for a document legacy id.
 @param legacyId (NSString*) id
 @returns (NSString *) ValiDasDocumento or nil
 */
+ (ValiDasDocumento*)getValiDasDocumentForLegacyId:(NSString*)legacyId;

/**
 @brief Returns if document is type Passport.
 @param docType (NSString*) Document Id
 @returns (BOOL) true if it's type Passport
 */
+ (BOOL)isDocumentTypePassport:(NSString*)docType;

/**
 @brief Returns if document is type At Driving License 2004.
 @param doc (NSString*) Document Id
 @returns (BOOL) true if it's type At Driving License 2004
 */
+ (BOOL)isDocumentTypeAtDrivingLicense2004:(NSString*)doc;

+ (BOOL) isDocumentSmart:(ValiDasDocumento*) document;

+(BOOL) isThereSomeNonIntelligentDocument:(NSArray<ValiDasDocumento*>*) documentArray analysisType:(AnalysisType) analysisType;

/**
@brief Returns the imageData with added bidi codes metadata in EXIF.UserComment field.
@param artifact (struct Artifact*) artifact struct information.
@param payloads (NSArray<ValiDasPayload*>*) array of ValiDasPayload.
@param agent (UserAgent*) user agent information.
@returns (NSData*) image data with the bidi code metadata inserted.
*/
+(NSData*)addVeridasMetadataWithArtifact:(Artifact*)artifact payloads:(NSArray<ValiDasPayload*>*)payloads userAgent:(UserAgent*)agent;

+ (void) setRectangleDetectorHardMode;
@end

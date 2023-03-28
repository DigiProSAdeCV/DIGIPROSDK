//
//  IntegrityCalculations.h
//  VDLibrary
//
//  Copyright © 2020 BBVA. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString* const SHA_256;
extern NSString* const HMAC_SHA_256;

@interface IntegrityCalculations : NSObject
/**
 * Converts a NSData into a valid string representation.
 * Ex: 0xAA 0xBB -> "AABB"
 *
 * @param data array of bytes to be converted.
 *
 * @return String with the converted bytes.
 */
+ (NSString *) hexToStringRepresentation: (NSData *) data;
/**
* Converts a ByteArray into the equivalent ASCII representation.
*
* @param data Array to be converted.
*
* @return String with the bytes converted.
*/
+ (NSString *) toString: (NSData *) data;
/**
 * Converts a String into the equivalent NSData representation using Ascii encoding.
 *
 * @param string String to be converted.
 *
 * @return Bytes with the string converted.
 */
+ (NSData *) toData: (NSString *) string;
/**
 * Creates a MAC with the key, data and algorithm provided.
 *
 * @param key secret key.
 * @param data data to be encrypted.
 * @param algorithm algorithm to be used to encrypt.
 *
 * @return Encrypted data.
 */
+ (NSData* _Nullable) generateMacWithKey: (NSData *) key data: (NSData *) data andAlgorithm: (NSString *) algorithm;
/**
 * Generates a hash string from an input string and a valid algorithm.
 *
 * @param input Data to be hashed.
 * @param algorithm algorithm to be used.
 *
 * @return String hashed.
 */
+ (NSData* _Nullable) hashStringWithInput: (NSData *) input andAlgorithm: (NSString *) algorithm;

@end

NS_ASSUME_NONNULL_END

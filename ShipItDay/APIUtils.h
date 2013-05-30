//
//  APIUtils.h
//  ShipItDay
//
//  Created by Sascha Möllering on 30.05.13.
//  Copyright (c) 2013 Sascha Möllering. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonHMAC.h>
#import <CommonCrypto/CommonDigest.h>

@interface APIUtils : NSObject

+ (NSString *)getNonce;
+ (NSNumber*)longUnixEpoch;
+ (NSString *)getDate;
+ (NSString *)getSecrectKey;
+ (NSString *)getPublicKey;
+ (NSString *)hmacsha1:(NSString *)data secret:(NSString *)key;
+ (NSString *) escape: (NSString *) yourInput;

@end

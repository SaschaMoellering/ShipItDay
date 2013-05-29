//
//  SoapConnect.h
//  ShipItDay
//
//  Created by Sascha Möllering on 29.05.13.
//  Copyright (c) 2013 Sascha Möllering. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonHMAC.h>
#import <CommonCrypto/CommonDigest.h>

#import "Base64.h"

@interface SoapConnect : NSObject<NSURLConnectionDelegate, NSXMLParserDelegate>

@property(nonatomic, strong) NSString *authToken;
@property(nonatomic, strong) NSArray *urlStringArray;

- (NSString *)getAuthToken:(NSString *)username password:(NSString *)password;

- (NSString *)hmacsha1:(NSString *)data secret:(NSString *)key;

@end

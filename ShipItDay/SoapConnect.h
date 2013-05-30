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
#import "SecondViewController.h"

@interface SoapConnect : NSObject<NSURLConnectionDelegate, NSXMLParserDelegate>

@property(nonatomic, strong) NSString *authToken;
@property(nonatomic, strong) NSArray *urlStringArray;
@property(nonatomic, strong) NSMutableData *soapData;
@property(nonatomic, strong) SecondViewController *target;

- (NSString *)getAuthToken:(NSString *)username password:(NSString *)password;

+ (SoapConnect *)getInstance;

- (NSMutableString *)createSoapRequest;

- (BOOL)sendSOAPRequest: (NSMutableString *)soapMessage;

@end

//
//  APIUtils.m
//  ShipItDay
//
//  Created by Sascha Möllering on 30.05.13.
//  Copyright (c) 2013 Sascha Möllering. All rights reserved.
//

#import "APIUtils.h"
#import "NSString+MD5.h"
#import "ASIFormDataRequest.h"
#import "Base64.h"

@implementation APIUtils

#pragma security

// get public key
+ (NSString *)getPublicKey {
    
    NSString *publicKey = @"24B3EA3491D9FD0C5BF6";
    
    return publicKey;
}

+ (NSString *)getSecrectKey {
    
    NSString *secretKey = @"ca1b535Ecc1548+FB00C393fDcb950/824e97947";
    
    return secretKey;
}

#pragma Nonce

// get nounce : an unique value
+ (NSString *)getNonce {
    
    NSNumber *num = [APIUtils longUnixEpoch];
    
    long randomNumber = arc4random();
    
    if (randomNumber < 0) {
        randomNumber = randomNumber * -1;
    }
    
    NSString *timeIntervalStr = [num stringValue];
    NSString *randomNumberStr =[[NSNumber numberWithLong:randomNumber] stringValue];
    
    //NSString *timeIntervalStr = [NSString stringWithFormat:@"%ll", timeInterval];
    //NSString *randomNumberStr = [NSString stringWithFormat:@"%ll", randomNumber];
    NSLog(@"Interval: <%@>", timeIntervalStr);
    NSLog(@"RandomNumber: <%@>", randomNumberStr);
    
    NSString *msg = [NSString stringWithFormat:@"%@%@", timeIntervalStr, randomNumberStr];
    NSLog(@"MSG: %@", msg);
    NSString *nonce = [msg MD5];
    NSLog(@"Nonce: %@", nonce);
    return nonce;
}

+ (NSNumber*) longUnixEpoch {
    return [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970] * 1000];
}

//get date

+ (NSString *)getDate {
    
    NSString *dateString;
    NSDate *date = [NSDate date];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // Note: We have to force the locale to "en_US" to avoid unexpected issues formatting data
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale: usLocale];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    [dateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss z"];
    //[dateFormatter setDateFormat:@"EEE,ddMMMyyyyHH:mm:ssz"];
    //[dateFormatter setDateFormat:@"yyyy-MM-dd"];
    dateString = [dateFormatter stringFromDate:date];
    
    return dateString;
}

#pragma Helper-methods

+ (NSString *)hmacsha1:(NSString *)data secret:(NSString *)key {
    
    const char *cKey  = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [data cStringUsingEncoding:NSASCIIStringEncoding];
    
    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    
    NSString *hash = [HMAC base64EncodedString];
    
    return hash;
}

+ (NSString *) escape: (NSString *) yourInput {
    
    NSString *escapedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes( NULL,	 (CFStringRef)yourInput,	 NULL,	 (CFStringRef)@"!’\"();:@&=+$,/?%#[]% ", kCFStringEncodingISOLatin1));
    return escapedString;
    
}

@end

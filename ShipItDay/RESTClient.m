//
//  RESTClient.m
//  ShipItDay
//
//  Created by Sascha Möllering on 30.05.13.
//  Copyright (c) 2013 Sascha Möllering. All rights reserved.
//

#import "RESTClient.h"
#import "APIUtils.h"
#import "NSString+MD5.h"

@implementation RESTClient

+ (RESTClient *)getInstance
{
    static RESTClient *sharedRESTConnect;
    
    @synchronized(self)
    {
        if (!sharedRESTConnect)
            sharedRESTConnect = [[RESTClient alloc] init];
        
        return sharedRESTConnect;
    }
}

- (NSArray *)getAdspaces: (NSString *) connectID {
    
    NSString *date = [APIUtils getDate];
    NSString *nonce = [self getNonceForREST];
    NSString *signatureString = [self getSignatureForREST: nonce : @"GET" : @"/reports/leads/date/2012-03-21"];
    
    return nil;
}

// get nounce : an unique value
- (NSString *)getNonceForREST {
    
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

//get timestamp
- (NSString *)getTimeStamp {
    
    NSString *dateString;
    NSDate *date = [NSDate date];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // Note: We have to force the locale to "en_US" to avoid unexpected issues formatting data
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale: usLocale];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    
    /* if ([@"rest" isEqualToString:@"rest"]) {
     [dateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss z"];
     dateString = [dateFormatter stringFromDate:date];
     } else {*/
    //[dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    [dateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss z"];
    dateString = [dateFormatter stringFromDate:date];
    //}
    
    return dateString;
}

// get SignToString
- (NSString *)getSignToStringMethodForREST:(NSString *)nonceString : (NSString *) service : (NSString *) method {
    
    NSString *timestamp   = [self getTimeStamp];
    
    
    NSString *signToString =[NSString stringWithFormat:@"%@%@%@%@", service, method, timestamp, nonceString];
    NSLog(@" --> Signstring: %@", signToString);
    
    // convert SignToString into UTF8-String
    NSString *utf8String = [NSString stringWithCString:[signToString cStringUsingEncoding:NSISOLatin1StringEncoding] encoding:NSUTF8StringEncoding];
    
    /*
     NSString *utf8String = [signToString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
     */
    NSLog(@"UTF8 String: %@",utf8String);
    /*
     NSLog(@"signToString:%@", signToString);
     NSData *utf8Data = [signToString dataUsingEncoding:NSUTF8StringEncoding];
     NSString *utf8String = [[NSString alloc] initWithData:utf8Data encoding:NSUTF8StringEncoding];
     NSLog(@"signToString:%@", utf8String);
     */
    return  utf8String;
}


// get signature
- (NSString *)getSignatureForREST: (NSString *)nounceValue : (NSString *) service : (NSString *) method{
    
    // get SignToString
    NSString *signToString = [self getSignToStringMethodForREST: nounceValue :service :method];
    
    // convertSignToString into HMAC-SHA1 coded string
    //NSString *signatureString = [self encodeWithHmacsha1:signToString :[self getSecrectKey]];
    
    NSString *signature = [APIUtils hmacsha1:signToString secret:[APIUtils getSecrectKey]];
    
    // convert HMAC-SHA1 string into BASE64 encoding
    //NSString *signature = [self sha1ith64Base: signatureString];
    
    NSLog(@"Signature: %@", signature);
    
    return signature;
}


@end

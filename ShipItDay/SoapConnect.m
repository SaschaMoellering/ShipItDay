//
//  SoapConnect.m
//  ShipItDay
//
//  Created by Sascha Möllering on 29.05.13.
//  Copyright (c) 2013 Sascha Möllering. All rights reserved.
//

#import "SoapConnect.h"
#import "ASIFormDataRequest.h"

@implementation SoapConnect

@synthesize authToken, urlStringArray;

// get auth token from zanoxconnect
- (NSString *)getAuthToken:(NSString *)username password:(NSString *)password {
    
    //NSString *username = @"venkateswarlu.nookala@zanox.com";
    //NSString *password = @"KhannAFEB28";
    //NSString *username = @"globalloonan2";
    //NSString *password = @"test01";
	NSURL *url = [NSURL URLWithString:@"https://auth.zanox.com/login?appid=9B7A7DB4A06987BC78DD"];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    [request setPostValue:username forKey:@"loginForm.userName"];
    [request setPostValue:password forKey:@"loginForm.password"];
    
    [request startSynchronous];
    
    return authToken;
}

/* get the response request, if request succeds at server */
- (void)requestFinished:(ASIHTTPRequest *)request {
	
    // get url components int array
    NSString *URLString = [NSString stringWithFormat:@"%@",[request url]];
    urlStringArray = [self getDataOfQueryString:URLString];
    
    // get authtoken from array with url components
    authToken = [self getAuthTokenValue: urlStringArray];
}

/* get authtoken from the array with url componenets  */
- (NSString *)getAuthTokenValue: (NSArray *)urlCompArray {
    
    return [[urlCompArray objectAtIndex:0] objectForKey:@"authtoken"];
}

/*  extract string componenest from responseURL into an array */
- (NSArray *)getDataOfQueryString:(NSString *)url{
    
    NSArray *strURLParse = [url componentsSeparatedByString:@"?"];
    NSMutableArray *arrQueryStringData = [[NSMutableArray alloc] init];
    if ([strURLParse count] < 2) {
        return arrQueryStringData;
    }
    NSArray *arrQueryString = [[strURLParse objectAtIndex:1] componentsSeparatedByString:@"&"];
    
    for (int i=0; i < [arrQueryString count]; i++) {
        NSMutableDictionary *dicQueryStringElement = [[NSMutableDictionary alloc]init];
        NSArray *arrElement = [[arrQueryString objectAtIndex:i] componentsSeparatedByString:@"="];
        if ([arrElement count] == 2) {
            [dicQueryStringElement setObject:[arrElement objectAtIndex:1] forKey:[arrElement objectAtIndex:0]];
        }
        [arrQueryStringData addObject:dicQueryStringElement];
    }
    
    return arrQueryStringData;
}

- (NSString *)hmacsha1:(NSString *)data secret:(NSString *)key {
    
    const char *cKey  = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [data cStringUsingEncoding:NSASCIIStringEncoding];
    
    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    
    NSString *hash = [HMAC base64EncodedString];
    
    return hash;
}

@end

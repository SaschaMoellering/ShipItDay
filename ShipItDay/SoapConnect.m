//
//  SoapConnect.m
//  ShipItDay
//
//  Created by Sascha Möllering on 29.05.13.
//  Copyright (c) 2013 Sascha Möllering. All rights reserved.
//

#import "SoapConnect.h"
#import "ASIFormDataRequest.h"
#import "NSString+MD5.h"
#import "XMLReader.h"
#import "APIUtils.h"

@implementation SoapConnect

@synthesize authToken, urlStringArray;
@synthesize soapData;
@synthesize loginTarget;
@synthesize secondTarget;

#pragma mark Singleton

+ (SoapConnect *)getInstance
{
    static SoapConnect *sharedSoapConnect;
    
    @synchronized(self)
    {
        if (!sharedSoapConnect)
            sharedSoapConnect = [[SoapConnect alloc] init];
        
        return sharedSoapConnect;
    }
}

#pragma mark Request-handling

/* get the response request, if request succeds at server */
- (void)requestFinished:(ASIHTTPRequest *)request {
	
    // get url components int array
    NSString *URLString = [NSString stringWithFormat:@"%@",[request url]];
    urlStringArray = [self getDataOfQueryString:URLString];
    
    // get authtoken from array with url components
    authToken = [self getAuthTokenValue: urlStringArray];
}

/* get the response request, if request fails at server */
- (void)requestFailed:(ASIHTTPRequest *)request {
	
    int statusCode = [request responseStatusCode];
    NSString *statusMessage = [request responseStatusMessage];
    
    NSLog(@"Oops: %@ %d", statusMessage, statusCode);
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [soapData setLength:0];
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [soapData appendData:data];
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"%@", error);
    [HUD hide:YES];
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
    // converts 'XML' DATA into dictionary form
    NSError *parseError = nil;
    NSDictionary *responseValues = [XMLReader dictionaryForXMLData: soapData error:parseError];
    
    NSMutableDictionary *fieldValues =  [responseValues objectForKey:@"soap:Envelope"];
    fieldValues = [fieldValues objectForKey:@"soap:Body"];
    fieldValues = [fieldValues objectForKey:@"ns2:getSessionResponse"];
    fieldValues = [fieldValues objectForKey:@"session"];
    NSDictionary *connectID = [fieldValues objectForKey:@"connectId"];
    NSDictionary *secretKey = [fieldValues objectForKey:@"secretKey"];
    NSDictionary *sessionExpires = [fieldValues objectForKey:@"sessionExpires"];
    NSDictionary *sessionKey = [fieldValues objectForKey:@"sessionKey"];
    
    NSLog(@"Values: %@", fieldValues);
    NSLog(@"ConnectID: %@", connectID);
    NSLog(@"Secret Key: %@", secretKey);
    NSLog(@"Session Expires : %@", sessionExpires);
    NSLog(@"Session Key: %@", sessionKey);
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *connectIDvalue = [connectID objectForKey:@"text"];
    [userDefaults setObject:connectIDvalue forKey:@"CONNECTID"];
    NSLog(@"connectID: %@",connectIDvalue );
    
    NSString *secretkeyValue = [secretKey objectForKey:@"text"];
    [userDefaults setObject: secretkeyValue forKey:@"SECRECTKEY"];
    NSLog(@"Secret Key: %@", secretkeyValue);
    
    NSString *sessionexpiresValue = [sessionExpires objectForKey:@"text"];
    [userDefaults setObject:sessionexpiresValue forKey:@"SESSIONEXPIRES"];
    NSLog(@"Session Expires: %@", sessionexpiresValue);
    
    NSString *sessionkeyValue = [sessionKey objectForKey:@"text"];
    [userDefaults setObject: sessionkeyValue forKey:@"SESSIONKEY"];
    NSLog(@"Session Key: %@", sessionkeyValue);
    
    [HUD hide:YES afterDelay:2];
    
    [loginTarget performSelectorOnMainThread:@selector(loginCallback:)
                           withObject:sessionkeyValue
                        waitUntilDone:false];
}

#pragma mark Auth-Token and query-parsing

// get auth token from zanoxconnect
- (NSString *)getAuthToken:(NSString *)username password:(NSString *)password {
    
	NSURL *url = [NSURL URLWithString:@"https://auth.zanox.com/login?appid=9B7A7DB4A06987BC78DD"];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    [request setPostValue:username forKey:@"loginForm.userName"];
    [request setPostValue:password forKey:@"loginForm.password"];
    
    [request startSynchronous];
    
    return authToken;
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

#pragma mark generating timestamps

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
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    dateString = [dateFormatter stringFromDate:date];
    //}
    
    return dateString;
}

#pragma mark Signature

// get signature
- (NSString *)getSignature: (NSString *)nounceValue{
    
    // get SignToString
    NSString *signToString = [self getSignToStringMethod: nounceValue];
    
    // convertSignToString into HMAC-SHA1 coded string
    //NSString *signatureString = [self encodeWithHmacsha1:signToString :[self getSecrectKey]];
    
    NSString *signature = [APIUtils hmacsha1:signToString secret:[APIUtils getSecrectKey]];
    
    // convert HMAC-SHA1 string into BASE64 encoding
    //NSString *signature = [self sha1ith64Base: signatureString];
    
    NSLog(@"Signature: %@", signature);
    
    return signature;
}

#pragma mark Sign to String

// get SignToString
- (NSString *)getSignToStringMethod:(NSString *)nonceString{
    
    NSString *service = @"connectservice";
    NSString *method   = @"getsession";
    NSString *timestamp   = [self getTimeStamp];
    
    
    NSString *signToString =[NSString stringWithFormat:@"%@%@%@%@", service, method, timestamp, nonceString];
    
    // convert SignToString into UTF8-String
    NSString *utf8String = [NSString stringWithCString:[signToString cStringUsingEncoding:NSISOLatin1StringEncoding] encoding:NSUTF8StringEncoding];

    return  utf8String;
}

#pragma mark SOAP-Requests

//get SOAP Request for GetSession
- (NSMutableString *)createSoapRequest {
    
    NSString *nonce = [APIUtils getNonce];
    NSString *authTokenValue = authToken;
    
    NSString *publicKey = [APIUtils getPublicKey];
    NSString *signature = [self getSignature: nonce];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:signature forKey:@"SIGNATURE"];
    
    NSString *timeStamp = [self getTimeStamp];
    //NSString *nounceValue = [self getNounce];
    
    
    NSMutableString *soapRequest = [[NSMutableString alloc] initWithString:@"<soapenv:Envelope xmlns:ns=\"http://auth.zanox.com/2011-05-01/\" xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\">"];
    [soapRequest appendString:@"<soapenv:Header/>"];
    [soapRequest appendString:@"<soapenv:Body>"];
    [soapRequest appendString:@"<ns:getSession>"];
    [soapRequest appendString:@"<authToken>%@</authToken>"];
    [soapRequest appendString:@"<publicKey>%@</publicKey>"];
    [soapRequest appendString:@"<signature>%@</signature>"];
    [soapRequest appendString:@"<nonce>%@</nonce>"];
    [soapRequest appendString:@"<timestamp>%@</timestamp>"];
    [soapRequest appendString:@"</ns:getSession>"];
    [soapRequest appendString:@" </soapenv:Body>"];
    [soapRequest appendString:@"</soapenv:Envelope>"];
    
    NSMutableString *soapRequestString =[NSMutableString stringWithFormat:soapRequest, authTokenValue, publicKey, signature, nonce, timeStamp];
    
    return soapRequestString;
}

//send SOAP Request for GetSession
- (BOOL)sendSOAPRequest: (NSMutableString *)soapMessage {
    
    NSURL *url = [NSURL URLWithString:@"https://auth.zanox.com/soap/2011-05-01"];
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    NSString *msgLength = [NSString stringWithFormat:@"%d", [soapMessage length]];
    
    [theRequest addValue: @"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [theRequest addValue: msgLength forHTTPHeaderField:@"Content-Length"];
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setHTTPBody: [soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
    
    HUD = [[MBProgressHUD alloc] initWithView:loginTarget.view];
    [loginTarget.view addSubview:HUD];
    
    HUD.delegate = loginTarget;
    [HUD show:YES];

    
    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    if( theConnection )
    {
        soapData = [[NSMutableData alloc] init];
        return YES;
    }

    return NO;
}

@end

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
#import "XMLReader.h"
#import "AdSpaceItem.h"

@implementation RESTClient
@synthesize target;
@synthesize pickData;

#pragma mark Singleton
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

#pragma mark AdSpaces
- (void)getAdspaces: (NSString *) connectID {
    
    NSString *date = [APIUtils getDate];
    NSString *nonce = [self getNonceForREST];
    NSString *signature = [self getSignatureForREST: nonce : @"GET" : @"/adspaces"];
    
    NSMutableString *restURL = [NSMutableString stringWithFormat: @"http://api.zanox.com/xml/2011-03-01/adspaces?connectid=%@&date=%@&signature=%@&nonce=%@",
                                connectID,
                                [APIUtils escape:date],
                                [APIUtils escape:signature],
                                [APIUtils escape:nonce]];
    
    NSURL *url = [NSURL URLWithString: restURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: url];
    [request setHTTPMethod:@"GET"];
    
    (void)[[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    return ;
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
    
    NSString *msg = [NSString stringWithFormat:@"%@%@", timeIntervalStr, randomNumberStr];
    NSString *nonce = [msg MD5];
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
    
    // convert SignToString into UTF8-String
    NSString *utf8String = [NSString stringWithCString:[signToString cStringUsingEncoding:NSISOLatin1StringEncoding] encoding:NSUTF8StringEncoding];
    
    return  utf8String;
}


// get signature
- (NSString *)getSignatureForREST: (NSString *)nounceValue : (NSString *) service : (NSString *) method{
    
    // get SignToString
    NSString *signToString = [self getSignToStringMethodForREST: nounceValue :service :method];
    
    NSString *signature = [APIUtils hmacsha1:signToString secret:[APIUtils getSecrectKey]];
    
    return signature;
}

#pragma mark Network-handling

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    int code = [httpResponse statusCode];
    NSLog(@"Response status code : %i", code);
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    
    NSDictionary *dic = [XMLReader dictionaryForXMLData:data error:nil];

    NSDictionary *adSpaceResponse = [dic objectForKey:@"GetAdspacesResponse"];
    NSDictionary *adSpaceResponseItems = [adSpaceResponse objectForKey:@"adspaceItems"];
    
    NSMutableArray *itemArr = [[NSMutableArray alloc] init];
    
    id tmpItem = [adSpaceResponseItems objectForKey:@"adspaceItem"];
    
    if ([tmpItem isMemberOfClass:[NSArray class]]) {
        NSArray *adSpaceResponseItem = [adSpaceResponseItems objectForKey:@"adspaceItem"];
        
        for (NSDictionary *tmpItem in adSpaceResponseItem) {
            NSDictionary *adSpaceResponseItem = [tmpItem objectForKey:@"adspaceItem"];
            NSMutableArray *tmpArr = [self convertItem:adSpaceResponseItem];
            [itemArr addObjectsFromArray:tmpArr];
        }
        
    } else {
        NSDictionary *adSpaceResponseItem = [adSpaceResponseItems objectForKey:@"adspaceItem"];
        NSMutableArray *tmpArr = [self convertItem:adSpaceResponseItem];
        [itemArr addObjectsFromArray:tmpArr];
    }
    
    self.pickData = itemArr;
    
    [target performSelectorOnMainThread:@selector(fillPicker:)
                             withObject:itemArr
                          waitUntilDone:false];
}

- (NSMutableArray *)convertItem:(NSDictionary *) adSpaceResponseItem {
    NSDictionary *name = [adSpaceResponseItem objectForKey:@"name"];
    
    NSDictionary *regions = [adSpaceResponseItem objectForKey:@"regions"];
    NSArray *region = [regions objectForKey:@"region"];
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    for (NSDictionary *tmpItem in region) {
        AdSpaceItem *item = [[AdSpaceItem alloc] init];
        item.name = [name objectForKey:@"text"];
        item.region = [tmpItem objectForKey:@"text"];
        [items insertObject:item atIndex:0];
    }
    
    return items;
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    
    NSLog(@"ERROR with connection: %@", error);
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
    NSArray * availableCookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:@"http://api.zanox.com"]];
    NSDictionary * headers = [NSHTTPCookie requestHeaderFieldsWithCookies:availableCookies];
}


@end

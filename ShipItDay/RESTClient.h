//
//  RESTClient.h
//  ShipItDay
//
//  Created by Sascha Möllering on 30.05.13.
//  Copyright (c) 2013 Sascha Möllering. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SecondViewController.h"

@interface RESTClient : NSObject<NSURLConnectionDelegate>

@property(nonatomic, strong) SecondViewController *target;
@property(nonatomic, strong) NSMutableArray *pickData;

+ (RESTClient *)getInstance;

- (void)getAdspaces: (NSString *) connectID;

@end

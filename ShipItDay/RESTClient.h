//
//  RESTClient.h
//  ShipItDay
//
//  Created by Sascha Möllering on 30.05.13.
//  Copyright (c) 2013 Sascha Möllering. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RESTClient : NSObject

+ (RESTClient *)getInstance;

- (NSArray *)getAdspaces: (NSString *) connectID;

@end

//
//  SecondViewController.m
//  ShipItDay
//
//  Created by Sascha Möllering on 29.05.13.
//  Copyright (c) 2013 Sascha Möllering. All rights reserved.
//

#import "SecondViewController.h"
#import "SoapConnect.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface SecondViewController ()

@end

@implementation SecondViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self login];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)login {
    
    SoapConnect *soapClient = [SoapConnect getInstance];
    NSMutableString *soapRequest = nil;
        
    NSString *authToken = [soapClient getAuthToken:@"venkateswarlu.nookala@zanox.com" password:@"KhannAFEB28"];
    soapClient.authToken = authToken;
        
    soapRequest = [soapClient createSoapRequest];
    BOOL result = [soapClient sendSOAPRequest:soapRequest];
}


@end

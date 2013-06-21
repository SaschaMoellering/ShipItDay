//
//  LoginViewController.m
//  ShipItDay
//
//  Created by Sascha Möllering on 30.05.13.
//  Copyright (c) 2013 Sascha Möllering. All rights reserved.
//

#import "LoginViewController.h"
#import "SoapConnect.h"

@interface LoginViewController ()

@end

@implementation LoginViewController
@synthesize usernameField;
@synthesize passwordField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    passwordField.secureTextEntry = YES;
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setUsernameField:nil];
    [self setPasswordField:nil];
    [super viewDidUnload];
}

- (IBAction)loginAction:(id)sender {
    NSLog(@"LoginAction");
    
    /*
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
	
	HUD.delegate = self;
	[HUD showWhileExecuting:@selector(login) onTarget:self withObject:nil animated:YES];
    */
    
    [self login];
}

- (void)loginCallback:(NSString *)sessionKey {
    NSLog(@"loginCallBack: %@", sessionKey);
    
    if ([sessionKey length] == 0) {
        NSLog(@"Login not valid");
    } else {
        NSLog(@"before loginSegue");

        NSLog(@"loginSegue");
        [self performSegueWithIdentifier:@"loginSegue" sender:nil];
    }
}

- (void)login {
    
    SoapConnect *soapClient = [SoapConnect getInstance];
    soapClient.loginTarget = self;
    NSMutableString *soapRequest = nil;
    
    NSString *authToken = [soapClient
                           getAuthToken:usernameField.text
                           password:passwordField.text];
    
    
    NSLog(@" --> username %@", usernameField.text);
    NSLog(@" --> password %@", passwordField.text);
    soapClient.authToken = authToken;
    
    (void) [soapClient sendSOAPRequest:soapRequest];
}

- (void)hudWasHidden:(MBProgressHUD *)hud {
	// Remove HUD from screen when the HUD was hidded
	[HUD removeFromSuperview];
	HUD = nil;
}


@end

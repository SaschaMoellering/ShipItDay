//
//  LoginViewController.h
//  ShipItDay
//
//  Created by Sascha Möllering on 30.05.13.
//  Copyright (c) 2013 Sascha Möllering. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MBProgressHUD/MBProgressHUD.h>

@interface LoginViewController : UIViewController<MBProgressHUDDelegate> {

    MBProgressHUD *HUD;
}

@property (strong, nonatomic) IBOutlet UITextField *usernameField;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;
- (IBAction)loginAction:(id)sender;

- (void)loginCallback:(NSString *)sessionKey;

@end

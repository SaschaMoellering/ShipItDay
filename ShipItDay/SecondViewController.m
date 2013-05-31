//
//  SecondViewController.m
//  ShipItDay
//
//  Created by Sascha Möllering on 29.05.13.
//  Copyright (c) 2013 Sascha Möllering. All rights reserved.
//

#import "SecondViewController.h"
#import "SoapConnect.h"
#import "RESTClient.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "AdSpaceItem.h"

@interface SecondViewController ()

@end

@implementation SecondViewController

@synthesize thePickerView;
@synthesize pickerList;
@synthesize selectedItem;

- (void)viewDidLoad
{
    thePickerView.showsSelectionIndicator = TRUE;
    
    [super viewDidLoad];
    
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Picker

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    return [pickerList count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    AdSpaceItem *item = [pickerList objectAtIndex:row];
    return [NSString stringWithFormat:@"%@ %@", item.name, item.region];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    AdSpaceItem *item = [pickerList objectAtIndex:row];
    selectedItem = item;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1; // or 2 or more
}

#pragma mark action

- (IBAction)bumpAction:(id)sender {
    [self getAdSpaces];
}

- (void) getAdSpaces {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *connectId = [userDefaults objectForKey:@"CONNECTID"];
    
    RESTClient *restClient = [RESTClient getInstance];
    restClient.target = self;
    [restClient getAdspaces:connectId];
}

- (void) fillPicker:(NSMutableArray *)pickerData {
    RESTClient *restClient = [RESTClient getInstance];
    self.pickerList = restClient.pickData;
    
    [self.thePickerView reloadAllComponents];
}


@end

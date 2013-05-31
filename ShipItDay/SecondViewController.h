//
//  SecondViewController.h
//  ShipItDay
//
//  Created by Sascha Möllering on 29.05.13.
//  Copyright (c) 2013 Sascha Möllering. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AdSpaceItem.h"

@interface SecondViewController : UIViewController<UIPickerViewDataSource, UIPickerViewDelegate>

@property (strong, nonatomic) IBOutlet UIPickerView *thePickerView;
@property (strong, nonatomic) NSMutableArray *pickerList;
@property (strong, nonatomic) AdSpaceItem *selectedItem;

- (void)getAdSpaces;
- (IBAction)bumpAction:(id)sender;
- (void)fillPicker:(NSMutableArray *)pickerData;

@end

//
//  DatePickerViewController.h
//  Origami
//
//  Created by CloudCraft on 04.02.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Protocols.h"




@interface DatePickerViewController : UIViewController

@property (nonatomic, weak) id<DateChoosingDelegate>delegate;
@property (nonatomic, strong) NSDate *currentDate;
@property (nonatomic) BOOL isBirthdayPicker;
@end

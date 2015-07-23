//
//  DatePickerViewController.m
//  Origami
//
//  Created by CloudCraft on 04.02.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import "DatePickerViewController.h"

@interface DatePickerViewController ()

@property (nonatomic, weak) IBOutlet UIDatePicker *datePicker;
@property (nonatomic, weak) IBOutlet UIDatePicker *timePicker;
@property (nonatomic, weak) IBOutlet UIButton *doneButton;
@property (nonatomic, weak) IBOutlet UILabel *selectedDateLabel;

@property (nonatomic, strong) NSDate *returnDate;
@property (nonatomic, strong) NSDate *timeDate;
@property (nonatomic, strong) NSDate *dateDate;

@end

@implementation DatePickerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _datePicker.datePickerMode = UIDatePickerModeDate;
    _timePicker.datePickerMode = UIDatePickerModeTime;
    
    
    [ _datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
    
    if (!_currentDate)
    {
        _currentDate = [NSDate date];
    }
    
    [_datePicker setDate:_currentDate];
    
    if (_isBirthdayPicker)
    {
        _timePicker.hidden = YES;
    }
    else
    {
        [_timePicker addTarget:self action:@selector(timeChanged:) forControlEvents:UIControlEventValueChanged];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 
-(void) dateChanged:(UIDatePicker *)sender
{
    self.dateDate = sender.date ;
}

-(void) timeChanged:(UIDatePicker *)sender
{
    self.timeDate = sender.date;
}

-(IBAction)doneTap:(id)sender
{
    if (!self.dateDate)
    {
        self.dateDate = _datePicker.date;
    }
    self.returnDate = self.dateDate;
    //calculate
   
    if (!self.isBirthdayPicker)
    {
         NSTimeInterval timeInterval = ceil([self.timeDate timeIntervalSinceNow]);
        self.returnDate = [self.returnDate dateByAddingTimeInterval:timeInterval];
    }
    
    
    //return
    [self.delegate dateChoosingDidFinishSelectingDate:self.returnDate];
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end

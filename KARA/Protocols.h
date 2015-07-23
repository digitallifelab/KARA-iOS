//
//  Protocols.h
//  KARA
//
//  Created by CloudCraft on 03.04.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#ifndef KARA_Protocols_h
#define KARA_Protocols_h


#endif

#import <Foundation/Foundation.h>
@protocol DismissDelegate
-(void) viewControllerWantsToDismiss:(UIViewController *)vc;
@end


@protocol TrendWordTapDelegate <NSObject>

-(void)trendWordHolderView:(UIView *)view didTapOnSubordinateWord:(NSString *)word;

@end

@protocol DateChoosingDelegate <NSObject>

-(void)dateChoosingDidFinishSelectingDate:(NSDate *)date;

@end

@class TableItemPickerVC;
@protocol TableItemPickerDelegate <NSObject>

-(void) tablePicker:(TableItemPickerVC *)pickerViewCotroller didSelectObject:(id)object currentType:(NSInteger)currentType;
-(void) tablePicker:(TableItemPickerVC *)pickerViewController doneButtonTapped:(UIButton *)sender;
-(BOOL) tablePickerShouldAllowMultipleSelection:(TableItemPickerVC *)pickerViewController;
@optional
-(void) tablePicker:(TableItemPickerVC *)pickerViewCotroller didDeselectObject:(id)object currentType:(NSInteger)currentType;
-(void) tablePicker:(TableItemPickerVC *)pickerViewCotroller didSelectItemAtIndex:(NSInteger)index currentType:(NSInteger)currentType;
-(void) tablePicker:(TableItemPickerVC *)pickerViewCotroller didDeselectItemAtIndex:(NSInteger)index currentType:(NSInteger)currentType;
@end


@protocol ContactProfileHeaderDelegate <NSObject>

@optional
//-(void) headerRejectContactButtonPressed:(UIButton *)sender;
//-(void) headerAcceptContactButtonPressed:(UIButton *)sender;
//-(void) headerDeleteContactButtonPressed:(UIButton *)sender;
//-(void) headerChatButtonPressed:(UIButton *)sender;
//-(void) headerFavouriteButtonPressed:(UIButton *)sender;
-(void) headerChangeImagePressed:(id)sender;

@end

@protocol ImagePickingDelegate <NSObject>
-(BOOL) avatarPickerShouldAllowEditing;
@optional
-(void) userDidSelectImage:(UIImage *)image withName:(NSString *)fileName;
@end
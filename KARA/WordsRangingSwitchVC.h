//
//  WordsRangingVC.h
//  Origami
//
//  Created by CloudCraft on 02.04.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WordsRangingSwitchVC; //ourselves

typedef enum : NSUInteger
{
    WordsRangingSwitchResultFailure = 0,
    WordsRangingSwitchResultUnchanged = 1,
    WordsRangingSwitchResultChanged = 2,
    
}WordsRangingSwitchResult;



@protocol WordsRangingSwitchDelegate <NSObject>

-(void) wordsRangingSwitchCancelButtonTapped:(WordsRangingSwitchVC *)viewController;
-(void) wordsRangingSwitchSubmitButtonTapped:(WordsRangingSwitchVC *)viewController withResult:(WordsRangingSwitchResult)result;

@end

@interface WordsRangingSwitchVC : UIViewController

@property (nonatomic, weak) id<WordsRangingSwitchDelegate>rangingDelegate;
@property (nonatomic, strong) NSArray *wordsToRange;
-(void) setUpRangingViews;
-(void) dismissByCancelling;
@end

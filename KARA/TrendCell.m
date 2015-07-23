//
//  TrendCell.m
//  KARA
//
//  Created by CloudCraft on 08.04.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import "TrendCell.h"

@implementation TrendCell

-(void)awakeFromNib
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(wordTapped:)];
    [self.contentView addGestureRecognizer:tap];
}

-(IBAction)wordTapped:(UITapGestureRecognizer *)tapSender
{
    CGPoint location = [tapSender locationInView:self.contentView];
    if (CGRectContainsPoint(self.leftLabel.frame , location))
    {
        [self.wordTapDelegate trendWordHolderView:self didTapOnSubordinateWord:self.leftLabel.text];
    }
    else if (CGRectContainsPoint(self.rightLabel.frame, location))
    {
        [self.wordTapDelegate trendWordHolderView:self didTapOnSubordinateWord:self.rightLabel.text];
    }
    
}


@end

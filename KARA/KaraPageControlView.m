//
//  KaraPageControlView.m
//  KARA
//
//  Created by CloudCraft on 28.04.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import "KaraPageControlView.h"
#import "UIView+OctagonMask.h"
#import "Constants.h"
@interface KaraPageControlView ()

@property (nonatomic, assign) NSUInteger numberOfPages;
@property (nonatomic, assign) NSUInteger page;

@end



@implementation KaraPageControlView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(instancetype) initWithFrame:(CGRect)frame andNumberOfPages:(NSInteger)pagesCount
{
    self = [super initWithFrame:frame];

    self.numberOfPages = MAX(MIN(pagesCount, 10), 0); //set from 0 to 10
    [self addPageIndicators:pagesCount parentFrame:frame];
    
    return self;
}
- (void)setCurrentPage:(NSUInteger)page
{
    self.page = MAX(MIN(self.numberOfPages, page), 0);  //set new page in borders of assigned numberOfPages
    
    for (NSInteger i = 0; i < self.subviews.count; i++)
    {
        UIView *lvSubView = [self.subviews objectAtIndex:i];
        if (i == self.page)
        {
            [lvSubView setBackgroundColor:Global_Tint_Color];
        }
        else
        {
            [lvSubView setBackgroundColor:[[UIColor whiteColor] colorWithAlphaComponent:0.9]];
        }
    }
}

- (NSUInteger)currentPage
{
    return self.page;
}

-(void) addPageIndicators:(NSInteger)quantity parentFrame:(CGRect)parentFrame
{
    //CGFloat parentHeight = parentFrame.size.height;
    CGFloat parentWidth = parentFrame.size.width;
    CGFloat itemWidth = parentWidth / (quantity * 2 - 1);
    
    for (NSInteger i = 0; i < quantity; i++)
    {
        CGRect viewFrame = CGRectMake(i * itemWidth * 2, 0, itemWidth , itemWidth);
        UIView *indicator = [[UIView alloc] initWithFrame:viewFrame];
        if (i == 0)
        {
            indicator.backgroundColor = [UIColor redColor];
        }
        else
        {
            indicator.backgroundColor = [UIColor whiteColor];
        }
        [indicator maskToCircle];
        [self addSubview:indicator];
    }
}

@end

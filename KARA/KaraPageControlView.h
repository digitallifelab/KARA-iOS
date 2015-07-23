//
//  KaraPageControlView.h
//  KARA
//
//  Created by CloudCraft on 28.04.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KaraPageControlView : UIView

-(instancetype) initWithFrame:(CGRect)frame andNumberOfPages:(NSInteger)pagesCount;

-(void) setCurrentPage:(NSUInteger)page;
-(NSUInteger)currentPage;
@end

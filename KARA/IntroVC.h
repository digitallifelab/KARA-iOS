//
//  Intro VC.h
//  KARA
//
//  Created by CloudCraft on 28.04.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Protocols.h"
@interface IntroVC : UIViewController
@property (nonatomic, weak) id <DismissDelegate> delegate;
@end

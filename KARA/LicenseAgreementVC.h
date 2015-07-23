//
//  LicenseAgreementVC.h
//  KARA
//
//  Created by CloudCraft on 27.05.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LicenseAgreementVC;
@protocol LicenseAgreementDelegate <NSObject>

-(void) licenseAgreementVC:(LicenseAgreementVC *)viewController didAcceptLicense:(BOOL)accepted;

@end

@interface LicenseAgreementVC : UIViewController
@property (nonatomic, weak) id<LicenseAgreementDelegate> delegate;
@end

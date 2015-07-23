//
//  LicenseAgreementVC.m
//  KARA
//
//  Created by CloudCraft on 27.05.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import "LicenseAgreementVC.h"

@interface LicenseAgreementVC ()
@property (weak, nonatomic) IBOutlet UITextView *licenseTextView;
@end

@implementation LicenseAgreementVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    __weak typeof(self) weakSelf = self;
    [self assignAttributedTextWithCompletion:^(NSAttributedString *attributedString)
     {
        weakSelf.licenseTextView.attributedText = attributedString;
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)toolbarButtonTap:(UIBarButtonItem *)sender
{
    if (self.delegate)
    {
        [self.delegate licenseAgreementVC:self didAcceptLicense:(sender.tag == 1)];
    }
}

-(void) assignAttributedTextWithCompletion:(void(^)(NSAttributedString *attributedString))completionBlock
{
    dispatch_queue_t asyncQueue = dispatch_queue_create("AsyncAttributesQueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(asyncQueue, ^
    {
        NSString *karaCentered = @"\rK.A.R.A.";
        NSRange karaRange = NSMakeRange(0, karaCentered.length);
        NSMutableAttributedString *karaMutable = [[NSMutableAttributedString alloc] initWithString:karaCentered];
        [karaMutable addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:karaRange];
        [karaMutable addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Segoe UI" size:20] range:karaRange];
        NSMutableParagraphStyle *karaCenterParagraph = [[NSMutableParagraphStyle alloc] init];
        [karaCenterParagraph setAlignment:NSTextAlignmentCenter];
        [karaCenterParagraph setParagraphSpacingBefore:10.0];
        [karaCenterParagraph setParagraphSpacing:10.0];
        [karaMutable addAttribute:NSParagraphStyleAttributeName value:karaCenterParagraph range:karaRange];
        
        
        NSString *eulaStart = NSLocalizedString(@"EULA-start", nil);
        NSRange startRange = NSMakeRange(0, eulaStart.length);
        NSMutableAttributedString *eulaStartAttributed = [[NSMutableAttributedString alloc] initWithString:eulaStart];
        [eulaStartAttributed addAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor], NSFontAttributeName:[UIFont fontWithName:@"Segoe UI" size:16]} range:startRange];
        [eulaStartAttributed addAttribute:NSParagraphStyleAttributeName value:karaCenterParagraph range:startRange];
        
        
        NSString *localizedEULA = NSLocalizedString(@"EULA", nil);
        NSRange eulaRange = NSMakeRange(0, localizedEULA.length);
        NSMutableAttributedString *eulaMutable = [[NSMutableAttributedString alloc] initWithString:localizedEULA];
        [eulaMutable addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:eulaRange];
        [eulaMutable addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Segoe UI" size:14] range:eulaRange];
        NSMutableParagraphStyle *textParagraph = [[NSMutableParagraphStyle alloc] init];
        [textParagraph setLineSpacing:5.0];
        [textParagraph setParagraphSpacing:10.0];
        [eulaMutable addAttribute:NSParagraphStyleAttributeName value:textParagraph range:eulaRange];
        
        
        NSMutableAttributedString *toReturnString = [[NSMutableAttributedString alloc] initWithAttributedString:karaMutable];
        [toReturnString appendAttributedString:eulaStartAttributed];
        [toReturnString appendAttributedString:eulaMutable];
        //return in main queue
        dispatch_async(dispatch_get_main_queue(), ^{
            
            completionBlock(toReturnString);
        });
    });
}

@end

//
//  TrendWordsSubordinateVC.m
//  KARA
//
//  Created by CloudCraft on 15.04.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import "TrendWordsSubordinateVC.h"

#import "RootTrendWordCell.h"
#import "ChildTrendWordMediumCell.h"
#import "ChildTrendWordLastCell.h"
#import "AnimationsCreator.h"
#import "DataSource.h"
#import "ServerRequester.h"

@interface TrendWordsSubordinateVC()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UITableView *structureDisplayTable;
@property (nonatomic, assign) NSInteger childsCount;
@property (nonatomic, strong) NSArray *childWords;
@property (nonatomic, strong) NSString *rootWord;
@property (nonatomic, weak) IBOutlet UIImageView *rotatingImageView;
@property (nonatomic, strong) NSString *tappedWord;

@end

@implementation TrendWordsSubordinateVC
#pragma mark -
-(void) viewDidLoad
{
    [super viewDidLoad];
    
    //[self setupTransparentNavigationBar];
    
    
    
    self.childsCount = 0;
    self.childWords = [self.shownWords objectForKey:self.shownWords.allKeys.firstObject];
    
    if (self.shownWords && self.childWords.count > 0)
    {
        self.rootWord = self.shownWords.allKeys.firstObject;
        self.childsCount = self.childWords.count;
//        [self setupTitleView];
        
        [self setupRightBarButton];
    }
    
    self.structureDisplayTable.delegate = self;
    self.structureDisplayTable.dataSource = self;
    
    //set out current title for next pushed VCs could write in on BACK button
    self.title = self.rootWord;
    // and hide title from our NavBar
    UILabel *label = [[UILabel alloc] init];
    self.navigationItem.titleView = label;
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self startAnimations];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self stopAnimations];
}

#pragma mark -
//- (void) setupTitleView
//{
//    
//    if(self.rootWord)
//    {
//        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 40)];
//        titleLabel.attributedText = [[NSAttributedString alloc] initWithString:self.rootWord
//                                                                    attributes:@{
//                                                                                 NSForegroundColorAttributeName:[UIColor yellowColor],
//                                                                                 NSFontAttributeName :[UIFont fontWithName:@"Arial" size:20]
//                                                                                 }];
//        [titleLabel sizeToFit];
//        
//        self.navigationItem.titleView = titleLabel;
//    }
// 
//}

- (void) setupTransparentNavigationBar
{
    self.navigationController.navigationBar.translucent = YES;
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init]; //remove thin line under navigation bar
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

-(void) setupRightBarButton
{
    if (self.navigationController.viewControllers.count > 2)
    {
        UIBarButtonItem *rightBarButton = [[ UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Echoe", nil) style:UIBarButtonItemStylePlain target:self action:@selector(popToRootVC:)];
        self.navigationItem.rightBarButtonItem = rightBarButton;
    }

}

#pragma mark -
-(void) popToRootVC:(UIBarButtonItem *)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - Animations
-(void) startAnimations
{
    //animation of mesh rotating
    AnimationsCreator *animationCreator = [[AnimationsCreator alloc] init];
    CAAnimation *smoothRotationAnimation = [animationCreator animationForMesh];
    [self.rotatingImageView.layer addAnimation:smoothRotationAnimation forKey:@"rotationAnimation"];
}

-(void) stopAnimations
{
    [self.rotatingImageView.layer removeAnimationForKey:@"rotationAnimation"];
}

#pragma mark - Delegates
#pragma mark UITableViewDelegate
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //detect word tapped
    NSString *tappedWord;
    if (indexPath.row == 0) //do nothing on root word tap
    {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
    else
    {
        tappedWord = [self childWordForRowAtIndexPath:indexPath];
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
    
    // querry new related subordinate words
    if (tappedWord)
    {
        self.tappedWord = tappedWord;
        
        __weak typeof(self) weakTrendSubordinateVC = self;
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        [[ServerRequester sharedRequester] getTrendLinkedWordsForWord:tappedWord withCompletion:^(NSDictionary *successResponse, NSError *error)
         {
             [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            // push new instance of us with new structure
             if (error)
             {
                 weakTrendSubordinateVC.tappedWord = nil;
             }
             else
             {
                 if (successResponse.allKeys.count > 0)
                 {
                     NSString *key = successResponse.allKeys.firstObject;
                     NSArray *valuesArray =  [successResponse objectForKey:key];
                     if (valuesArray.count > 5)
                     {
                         valuesArray = [valuesArray subarrayWithRange:NSMakeRange(0, 5)];
                     }
                     //all words should be capitalized
                     NSMutableArray *capitalizedStrings = [[NSMutableArray alloc] initWithCapacity:valuesArray.count];
                     for (NSString *lvWord in valuesArray)
                     {
                         NSString *capitalizedWord = [lvWord capitalizedString];
                         [capitalizedStrings addObject:capitalizedWord];
                     }
                     
                     TrendWordsSubordinateVC *newInstanceVC = [weakTrendSubordinateVC.storyboard instantiateViewControllerWithIdentifier:@"TrendSubordinate"];
                     newInstanceVC.shownWords = [NSDictionary dictionaryWithObject:capitalizedStrings forKey:key];
                     [weakTrendSubordinateVC.navigationController pushViewController:newInstanceVC animated:YES];
                 }
             }
        }];
    }
    
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 62;
    if (self.view.bounds.size.height > 667)
    {
        height = 100;
    }
//    CGFloat height = floorf(tableView.bounds.size.height / (self.childsCount + 2));
//    if (indexPath.row == 0)
//    {
//        height *= 1.5;
//    }
    
    return height;
}
#pragma mark UITableViewDataSource
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.childsCount + 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger childWordsCount = self.childsCount;
    NSInteger currentRow = indexPath.row;
    
    if (currentRow == 0)
    {
        RootTrendWordCell *rootCell = (RootTrendWordCell *)[tableView dequeueReusableCellWithIdentifier:@"RootWordCell" forIndexPath:indexPath];
        rootCell.rootWordLabel.text = self.rootWord;
        rootCell.selectionStyle = UITableViewCellSelectionStyleNone;
        return rootCell;
    }
    else
    {
        BOOL returnLastCell = NO;
        if (currentRow  == childWordsCount)
        {
            returnLastCell = YES;
        }
        
        NSString *childWord = [self childWordForRowAtIndexPath:indexPath];
        if (returnLastCell)
        {
            ChildTrendWordLastCell *childCell = (ChildTrendWordLastCell *)[tableView dequeueReusableCellWithIdentifier:@"LastChildCell" forIndexPath:indexPath];
            childCell.childWordLabel.text = childWord;
            childCell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            return childCell;
        }
        else
        {
            ChildTrendWordMediumCell *childCell = (ChildTrendWordMediumCell *)[tableView dequeueReusableCellWithIdentifier:@"MediumChildCell" forIndexPath:indexPath];
            childCell.childWordLabel.text = childWord;
            childCell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            return childCell;
        }
    }
}
-(NSString *)childWordForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *wordToReturn;
    if (indexPath.row == 0)
    {
        wordToReturn = self.rootWord;
    }
    else
    {
        wordToReturn = [self.childWords objectAtIndex:indexPath.row - 1];
    }
    
    return wordToReturn;
}

@end

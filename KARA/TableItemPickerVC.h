//
//  TableItemPickerVC.h
//  Origami
//
//  Created by CloudCraft on 05.02.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Protocols.h"
#import "Enumerators.h"
@interface TableItemPickerVC : UIViewController

@property (nonatomic, strong) NSMutableArray *itemsToChoose;

@property (nonatomic, weak) id<TableItemPickerDelegate> delegate;

@property (nonatomic) NSInteger startItem;
@property (nonatomic, weak) IBOutlet  UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIButton *doneBtton;

@property (nonatomic) TablePickerType currentType; //language, country, .... else

@end

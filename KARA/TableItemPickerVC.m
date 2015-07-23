//
//  TableItemPickerVC.m
//  Origami
//
//  Created by CloudCraft on 05.02.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import "TableItemPickerVC.h"
//#import "SettingsHandler.h"

#import "DataSource.h"
@interface TableItemPickerVC ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *indexKeysAndItemsValues;

@property (nonatomic, strong) NSArray *countriesIndex;

@end


@implementation TableItemPickerVC


-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    if ([_itemsToChoose.firstObject isKindOfClass:[CountryObject class]])
    {
        _currentType = PickCountry;
    }
    else if ([_itemsToChoose.firstObject isKindOfClass:[LanguageObject class]])
    {
        _currentType = PickLanguage;
    }
//    else if ([_itemsToChoose.firstObject isKindOfClass:[Contact class]])
//    {
//        _currentType = PickContact;
//    }
    
    
    
    if (!self.indexKeysAndItemsValues)
    {
       [self makeKeyedItemsArray];
    }
   

    if (self.modalPresentationStyle == UIModalPresentationPopover)
    {
        CGRect screenBounds = [UIScreen mainScreen].bounds;
        self.preferredContentSize = CGSizeMake(screenBounds.size.width * 0.9, screenBounds.size.height * 0.9);
    }
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (_startItem > 0)
    {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_startItem inSection:0]];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_startItem inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    }
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear: animated];
    
    
    if (self.delegate)
    {
        BOOL isAllowed = [self.delegate tablePickerShouldAllowMultipleSelection:self];
        self.tableView.allowsMultipleSelection = isAllowed;
    }
}

-(void) makeKeyedItemsArray
{
    if (!self.indexKeysAndItemsValues)
    {
        self.indexKeysAndItemsValues = [@[] mutableCopy];
    }
    
    NSMutableSet *lettersSet = [NSMutableSet setWithCapacity:34];
    
    switch (self.currentType)
    {
        case PickCountry:
        {
            for (CountryObject *lvCountry in _itemsToChoose)
            {
                [lettersSet addObject:[lvCountry.countryName substringToIndex:1]];
            }
            
            NSMutableArray *cleanLetters = [[lettersSet allObjects] mutableCopy];
            [cleanLetters sortUsingDescriptors: @[ [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES] ] ]; //sort strings in array
            
            for (NSString *lvCleanLetter in cleanLetters)
            {
                NSArray *foundLanguages = [[DataSource sharedInstance] countriesForCountryNameFirstLetter:lvCleanLetter];
                if (foundLanguages)
                {
                    [self.indexKeysAndItemsValues addObject:@{lvCleanLetter:foundLanguages}];
                }
            }
            [self.indexKeysAndItemsValues addObject:@{@"#":[NSNull null]}];
        }
            break;
        case PickLanguage:
        {
            for (LanguageObject *lvLanguage in _itemsToChoose)
            {
                [lettersSet addObject:[lvLanguage.languageName substringToIndex:1]];
            }
            
            NSMutableArray *cleanLetters = [[lettersSet allObjects] mutableCopy];
            [cleanLetters sortUsingDescriptors: @[ [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES] ] ]; //sort strings in array
            
            for (NSString *lvCleanLetter in cleanLetters)
            {
                NSArray *foundLanguages = [[DataSource sharedInstance] languagesForLanguageNameFirstLetter:lvCleanLetter];
                if (foundLanguages)
                {
                    [self.indexKeysAndItemsValues addObject:@{lvCleanLetter:foundLanguages}];
                }
            }
            [self.indexKeysAndItemsValues addObject:@{@"#":[NSNull null]}];
        }
            break;
            
//        case PickContact:
//        {
//            //to do...
//            for (Contact *lvContact in _itemsToChoose)
//            {
//                NSString *lvFirstName = lvContact.firstName;
//                if (lvFirstName.length > 0)
//                {
//                    [lettersSet addObject:[lvContact.firstName substringToIndex:1]];
//                }
//            }
//            
//            NSMutableArray *cleanLetters = [[lettersSet allObjects] mutableCopy];
//            [cleanLetters sortUsingDescriptors: @[ [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES] ] ]; //sort strings in array
//            
//            for (NSString *lvCleanLetter in cleanLetters)
//            {
//                NSArray *foundContacts = [[DataSource sharedInstance] contactsForContactFirstNameFirstLetter:lvCleanLetter];
//                if (foundContacts)
//                {
//                    [self.indexKeysAndItemsValues addObject: @{lvCleanLetter:foundContacts} ];
//                }
//            }
//            [self.indexKeysAndItemsValues addObject:@{@"#":[NSNull null]}];
//        }
//            break;
            
        default:
            break;
    }
}

#pragma mark -
- (id) objectAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.indexKeysAndItemsValues)
    {
        NSDictionary *container = [self.indexKeysAndItemsValues objectAtIndex:indexPath.section];
        NSArray *values = [container.allValues firstObject];
        return [values objectAtIndex:indexPath.row];
    }
    
    return nil;
}

-(NSString *)textForCellAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *toReturnString;
    switch (_currentType)
    {
        case PickCountry: //CountryObjects
        {
            CountryObject *currentCountry = (CountryObject *)[self objectAtIndexPath:indexPath];
            toReturnString = currentCountry.countryName;
        }
            break;
        case PickLanguage:
        {
            if (self.indexKeysAndItemsValues)
            {
                //NSLog(@"\r - Language IndexPath: Row = %ld, Section = %ld", indexPath.row, indexPath.section);
                NSDictionary *container = [self.indexKeysAndItemsValues objectAtIndex:indexPath.section];
                NSArray *values = [container.allValues firstObject];
                if (values)
                {
                    LanguageObject *lvLanguage = [values objectAtIndex:indexPath.row];
                    return lvLanguage.languageName;
                }
            }
            else
            {
                toReturnString = ((LanguageObject *)[_itemsToChoose objectAtIndex: indexPath.row]).languageName;
            }
        }
            break;
//        case PickContact: //contacts
//        {
//            if (self.indexKeysAndItemsValues)
//            {
//                Contact *currentContact = (Contact *)[self objectAtIndexPath:indexPath];
//                toReturnString = [self contactNameForContact:currentContact];
//            }
//            else
//            {
//                toReturnString = [[DataSource sharedInstance] nameStringForContact:(Contact *)[_itemsToChoose objectAtIndex:indexPath.row]];
//            }
//        }
//            break;
        default:
            toReturnString = @"_-_";
            break;
    }
    return toReturnString;
}

#pragma mark - UITableViewDataSource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.indexKeysAndItemsValues)
    {
        NSInteger sectionsCount = self.indexKeysAndItemsValues.count;
        return sectionsCount;
    }
    
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if (self.indexKeysAndItemsValues)
    {
        NSInteger rowsCount = 0;
        NSDictionary *container = [self.indexKeysAndItemsValues objectAtIndex:section];
        if (![container.allKeys.firstObject isEqualToString:@"#"])
        {
            NSArray *value = [container objectForKey: container.allKeys.firstObject];
            if (value)
            {
                rowsCount = value.count;
            }
        }
        return rowsCount;
    }
    
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PickerCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = [self textForCellAtIndexPath:indexPath];//[_itemsToChoose objectAtIndex:indexPath.row];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSDictionary *container = [self.indexKeysAndItemsValues objectAtIndex:section];
    return container.allKeys.firstObject;
}


#pragma mark UITableViewDelegate
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    if (self.delegate)
    {
        if (self.indexKeysAndItemsValues)
        {
            [self.delegate  tablePicker:self didSelectObject:[self objectAtIndexPath:indexPath] currentType:self.currentType];
        }
        else
        {
            [self.delegate tablePicker:self didSelectItemAtIndex:indexPath.row currentType:_currentType];
        }
    }
    
    
    
}

-(void) tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
    if (self.delegate)
    {
        if (self.indexKeysAndItemsValues)
        {
            [self.delegate tablePicker:self didDeselectObject:[self objectAtIndexPath:indexPath] currentType:self.currentType];
        }
        else
            [self.delegate tablePicker:self didDeselectItemAtIndex:indexPath.row currentType:_currentType];
    }

    
}


#pragma mark sections and index
-(NSArray *) sectionIndexTitlesForTableView:(UITableView *)tableView
{
    NSMutableArray *titles = [NSMutableArray arrayWithCapacity:self.indexKeysAndItemsValues.count];
    for (NSDictionary *lvDict in self.indexKeysAndItemsValues)
    {
        [titles addObject:lvDict.allKeys.firstObject];
    }
    
    return titles;
}

-(NSInteger) tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    NSInteger lvCount = self.indexKeysAndItemsValues.count;
    NSInteger toReturn = 0;
    BOOL shouldScroll = NO;
    for (int i = 0; i <  lvCount; i++)
    {
        // Here you return the name
        // and match the title for first letter of name
        // and move to that row corresponding to that indexpath as below
        NSDictionary *container = [self.indexKeysAndItemsValues objectAtIndex:i];
        NSString *key = container.allKeys.firstObject;
        
        if ([key isEqualToString:title])
        {
            toReturn = i;
            shouldScroll = YES;
            break;
        }
    }
    
    
    if (shouldScroll)
    {
        [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:toReturn] atScrollPosition:UITableViewScrollPositionTop animated:NO];//does not scroll animated also in native Contacts app
    }
    
    return toReturn;
}

#pragma mark -
-(IBAction) dismissSelf:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(tablePicker:doneButtonTapped:)])
    {
        [self.delegate tablePicker:self doneButtonTapped:sender];
    }
    else
        [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 
-(NSString *) contactNameForContact:(Contact *)contact
{
    NSMutableString *toReturn = [@"" mutableCopy];
    
    if (contact.firstName.length > 0)
    {
        [toReturn appendString:contact.firstName];
        if (contact.lastName.length > 0)
        {
            [toReturn appendFormat:@" %@",contact.lastName];
        }
    }
    else if (contact.lastName.length > 0)
    {
        if (contact.lastName.length > 0)
        {
            [toReturn appendString:contact.lastName];
        }
    }
    
    return toReturn;
}

@end

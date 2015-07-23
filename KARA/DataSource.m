//
//  DataSource.m
//  Origami
//
//  Created by CloudCraft on 11.02.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import "DataSource.h"



#import "ServerRequester.h"
#import "NSData+PhotoConverter.h"
#import "NSDate+Compare.h"
#import "NSString+ServerDate.h"

#import "Enumerators.h"

#import "AnimationsCreator.h"
#import "FileHandler.h"

@interface DataSource ()

@property (nonatomic, strong) NSOperationQueue  *messagesUpdaterQueue;// handles timers for querying new messages from server
@property (nonatomic, strong) NSTimer *refreshTimer;
@property (nonatomic, strong) NSDate *questionNulifyDate;
@end

@implementation DataSource


+(DataSource *) sharedInstance
{
    static DataSource *singletoneInstance;
    if (!singletoneInstance)
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            singletoneInstance = [[DataSource allocWithZone:NULL] init];

        });
    }
    
    if (!singletoneInstance.contacts)
        singletoneInstance.contacts = [@[] mutableCopy];
    
    if (!singletoneInstance.elements)
        singletoneInstance.elements = [@[] mutableCopy];
    
    if (!singletoneInstance.messages)
        singletoneInstance.messages = [@[] mutableCopy];
    
    if (!singletoneInstance.pendingQuestions)
        singletoneInstance.pendingQuestions = [@[] mutableCopy];
    
    if (!singletoneInstance.countries)
        singletoneInstance.countries = [@[] mutableCopy];
    
    if (!singletoneInstance.attaches)
        singletoneInstance.attaches = [@[] mutableCopy];
    
    if (!singletoneInstance.avatars)
        singletoneInstance.avatars = [@{} mutableCopy];
    
    if(!singletoneInstance.languages)
        singletoneInstance.languages = [@[] mutableCopy];
    
    if (!singletoneInstance.messagesUpdaterQueue)// handles timers for querying new messages from server
    {
        singletoneInstance.messagesUpdaterQueue = [[NSOperationQueue alloc] init];
    }
    
    return singletoneInstance;
}

#pragma mark - timer repeated request
-(void) startLastMessagesTimer
{
    //NSLog(@"\r - Starting Loading New Messages...");
    [DataSource sharedInstance].messagesUpdaterOperation = [[NSBlockOperation alloc]  init];
    __weak NSBlockOperation *newMessagesQueryOp = [DataSource sharedInstance].messagesUpdaterOperation;
    [newMessagesQueryOp addExecutionBlock:^
    {
        
        [[DataSource sharedInstance] invalidateTimer];
        if (!newMessagesQueryOp.isCancelled)
        {
            [DataSource sharedInstance].refreshTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:[DataSource sharedInstance] selector:@selector(loadNewMessagesWithCompletion:) userInfo:nil repeats:YES];
            NSRunLoop* runLoop = [NSRunLoop currentRunLoop];
            [runLoop addTimer:[DataSource sharedInstance].refreshTimer  forMode:NSRunLoopCommonModes];
            [runLoop run];
        }
        else
        {
#ifdef DEBUG
            NSLog(@"\n %@ messagesUpdaterOperation is Cancelled.\n", NSStringFromClass([self class]));
#endif
        }
        
    }];
                                  
    
    [self.messagesUpdaterQueue addOperation:newMessagesQueryOp];
    
}

-(void) invalidateTimer
{
    if (self.refreshTimer)
    {
        if (self.refreshTimer.isValid)
        {
            [self.refreshTimer invalidate];
        }
        
        self.refreshTimer = nil;
    }
}

-(void) loadNewMessagesWithCompletion:(networkCompletionBlock) completionBlock
{
    if ([DataSource sharedInstance].messagesUpdaterOperation.isCancelled)
    {
#ifdef DEBUG
        NSLog(@"\n %@ messagesUpdaterOperation is Cancelled. - invalidating timer.\n", NSStringFromClass([self class]));
#endif
        [[DataSource sharedInstance] invalidateTimer];
        return;
    }
    

//    NSLog(@"\n- Loading last messages...");
    [[DataSource sharedInstance].messagesUpdaterQueue addOperationWithBlock:^
     {
         [[DataSource sharedInstance] invalidateTimer];
     }];
    
    [[ServerRequester sharedRequester] loadLastMessagesWithCompletion:^(NSDictionary *successResponse, NSError *error)
    {
        if ([DataSource sharedInstance].pendingQuestions.count > 2)
        {
            [[DataSource sharedInstance].messagesUpdaterOperation cancel];
            //[[DataSource sharedInstance].messagesUpdaterQueue cancelAllOperations];
#ifdef DEBUG
            NSLog(@"\r - Current pending messages are more than 3. stopping recursive loading next new messages...");
#endif
            return;
        }
        
        [[DataSource sharedInstance].messagesUpdaterQueue addOperationWithBlock:^
        {
            [[DataSource sharedInstance] startLastMessagesTimer];
        }];
    }];
}


#pragma mark -
-(NSArray *) messagesForElementWithId:(NSNumber *)elementId
{
    NSArray *matches = [self.messages filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"elementId == %@", elementId]];
    
    return matches;
}

-(NSMutableArray *)contactsForElementWithId:(NSNumber *)elementId
{
    Element *currentElement = [self getElementById:elementId];
    if (currentElement)
    {
        if (currentElement.passWhomIds.count > 0)
        {
            NSMutableArray *contacts = [NSMutableArray arrayWithCapacity:currentElement.passWhomIds.count];
            for (NSNumber *lvContactId in currentElement.passWhomIds)
            {
                Contact *foundContact = [self getContactByContactId:lvContactId];
                if (foundContact)
                    [contacts addObject:foundContact];
            }
            return contacts;
        }
        return nil;
    }
    return nil;
}

-(Contact *) getContactByContactId:(NSNumber *)contactId
{
    NSArray *matches = [self.contacts filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"contactId == %@", contactId]];
    if (matches.count > 0)
    {
        return matches.firstObject;
    }
    return nil;
}

-(Contact *) getContactByElementId:(NSNumber *)contactElementId
{
    NSArray *matches = [self.contacts filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"elementId == %@", contactElementId]];
    if (matches.count > 0)
    {
        return matches.firstObject;
    }
    return nil;
}

-(NSString *) nameStringForContact:(Contact *)contact
{
    NSMutableString *toReturnName = [@"" mutableCopy];
    NSMutableString *toAppend = [@"" mutableCopy];
    //Contact *contact = [[DataSource sharedInstance] getContactByContactId:userId];
    if (contact)
    {
        if (contact.firstName.length > 0)
        {
            [toReturnName appendString:contact.firstName];
            [toAppend appendString:@" "];
        }
        if (contact.lastName.length > 0)
        {
            [toReturnName appendString:toAppend];
            
            [toReturnName appendString:contact.lastName];
        }
    }
    else
    {
        User *user = [[DataSource sharedInstance] getCurrentUser];
        if (user.userID == contact.contactId)
        {
            if (user.firstName.length > 0)
            {
                [toReturnName appendString:user.firstName];
                [toAppend appendString:@" "];
            }
            if (user.lastName.length > 0)
            {
                [toReturnName appendString:toAppend];
                [toReturnName appendString:user.lastName];
            }
        }
    }
    
    return toReturnName;
}

-(Contact *) getKaraContact
{
    NSArray *filtered = [self.contacts filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"loginName beginswith %@ ", @"K.A.R.A"]];
    if( filtered.count > 0)
    {
        if (!self.karaContact)
        {
            self.karaContact = filtered.firstObject;
        }
        return filtered.firstObject;
    }
    
    return nil;
}

-(User *)getCurrentUser
{
    return [ServerRequester sharedRequester].currentUser;
}

-(Element *) getElementById:(NSNumber *)elementId
{
    NSArray *matches = [self.elements filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"elementId == %@", elementId]];
    if (matches.count > 0)
    {
        return matches.firstObject;
    }
    else
        return nil;
    
}

-(Message *) lastMessageForElementId:(NSNumber *)elementId
{
    NSArray *messages = [[self.messages filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"elementId = %@", elementId]]
                         sortedArrayUsingComparator:^NSComparisonResult(Message *message1, Message *message2)
    {
        return [message1.dateCreated compare:message2.dateCreated];
    }];
    
    if (messages.count < 1)
    {
        return nil;
    }
    else
        return messages.lastObject;
    
}

-(NSArray *) signalElements
{
    NSArray *matches = [self.elements filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isSignal == 1"]];
    return matches;
}

-(NSArray *) favouriteElements
{
    NSArray *matches = [self.elements filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isFavourite == 1"]];
    return matches;
}

-(NSArray *) lastElements
{
    NSArray *matches = [self.elements filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isFavourite == 0 AND isSignal == 0"]];
    return matches ;
}

-(UIImage *)avatarImageForOwnerId:(NSNumber *)contactId
{
    UIImage *toReturn;
    if (contactId)
    {
        toReturn = [self.avatars objectForKey:contactId];
    }
    if (!toReturn)
    {
        toReturn = [UIImage imageNamed:@"contact-noAvatar"];
    }
        return toReturn;
}

-(UIImage *)avatarImageForLoggedUser
{
    return [self avatarImageForOwnerId:[ServerRequester sharedRequester].currentUser.userID];
}

- (NSArray *)attachesForElementId:(NSNumber *)elementId
{

    NSArray *matches = [self.attaches filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"elementID == %@", elementId]];
    if (matches.count > 0)
    {
        return matches;
    }
    else
        return @[];
    
}

- (AttachFile *) singleAttachByAttachId:(NSNumber *)attachId
{
    NSArray *matches = [self.attaches filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"attachID == %@", attachId]];
    if (matches.count > 0)
    {
        return matches.firstObject;
    }
    else
        return nil;
}

- (NSArray *) lastActiveContacts
{
    //trim array of messages to those whos date is earlier than 31 day
    NSMutableSet *lastActiveMessages = [NSMutableSet setWithCapacity:6];
    for (Message *lvMessage in self.messages.reverseObjectEnumerator)
    {
        if ([lvMessage.dateCreated lessThanMonthAgo])
        {
            [lastActiveMessages addObject:lvMessage];
            //NSLog(@"- Checked Message Date: %@", lvMessage.dateCreated);
        }
    }
    
    
    if (lastActiveMessages.count < 1)
    {
        return @[];
    }
    else
    {
        //sorting made by hint from here http://rypress.com/tutorials/objective-c/data-types/nsarray obj2 before obj1 if descending
        
        //sort, because SET easily will corrupt order of elements
        NSArray *sortedMessagesByDate = [lastActiveMessages.allObjects sortedArrayUsingComparator:^NSComparisonResult(Message *message1, Message *message2)
                             {
                                 NSComparisonResult compareResult = [message2.dateCreated compare:message1.dateCreated];
                                 
                                 return compareResult;
                             }];
        
        
        NSMutableSet *elementsSet = [NSMutableSet setWithCapacity:sortedMessagesByDate.count];
        for (Message *lvMessage in sortedMessagesByDate)
        {
            Contact *lvContactForMessage = [self getContactByElementId:lvMessage.elementId];
            if (lvContactForMessage)
            {
                if (![lvContactForMessage.loginName isEqualToString:@"K.A.R.A"])
                {
                    [elementsSet addObject:lvContactForMessage];
                }
            }
        }
        
        NSArray *sortedContacts = [elementsSet.allObjects sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES]]];
        
        return sortedContacts;
    }
}

- (NSArray *) countriesForCountryNameFirstLetter:(NSString *)firstLetter
{
    NSArray *foundCountries = [self.countries filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"countryName beginswith %@", firstLetter]];
    
    if (foundCountries)
    {
        return foundCountries;
    }
    
    
    return nil;
}


- (NSArray *) languagesForLanguageNameFirstLetter:(NSString *)firstLetter
{
    NSArray *foundLanguages = [self.languages filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"languageName beginswith %@", firstLetter]];
    
    if (foundLanguages)
    {
        return foundLanguages;
    }
    
    
    return nil;
}

-(NSArray *) contactsForContactFirstNameFirstLetter:(NSString *)firstLetter
{
    NSArray *foundContacts = [self.contacts filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"firstName beginswith %@", firstLetter]];
    
    if (foundContacts)
    {
        return foundContacts;
    }
    
    return nil;
}

#pragma mark Animations
// Animation
//- (CAKeyframeAnimation *)currentAmbientAnimationForContact:(Contact *)contact
//{
//    //get contact`s last ambient animation and return it
//    if (contact == [self getKaraContact])
//    {
//        AnimationsCreator *lvCreator = [[AnimationsCreator alloc] init];
//        CAKeyframeAnimation *animation = [lvCreator animationForEmotionType:KaraAnimationTypeAmbience emotionNamed:@"default"];
//        return animation;
//    }
//    return nil;
//}
-(CAKeyframeAnimation *) karaFaceAnimation
{
    if ([self getKaraContact] != nil)
    {
        AnimationsCreator *lvCreator = [[AnimationsCreator alloc] init];
        CAKeyframeAnimation *animation = [lvCreator animationForEmotionType:KaraAnimationTypeFace emotionNamed:@"default"];
        return animation;
    }
    return nil;
}

#pragma mark Sounds
-(void) playAmbienceSound
{
    if (self.ambiencePlayer)
    {
        [self.ambiencePlayer stop];
        self.ambiencePlayer = nil;
    }
    else
    {
        [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
            FileHandler *lvFileHandler = [[FileHandler alloc] init];
            NSError *lvError;
            [DataSource sharedInstance].ambiencePlayer = [[AudioPlayback alloc] initWithAudioURL:[lvFileHandler urlForAmbience] error:&lvError];
            //[NSThread detachNewThreadSelector:@selector(playIndefinitely) toTarget:self.ambiencePlayer withObject:nil];
            [[DataSource sharedInstance].ambiencePlayer playIndefinitely];
        }];
    }
}

-(void) stopPlaying
{
    if ([self.ambiencePlayer isPlaying])
    {
        [self.ambiencePlayer stop];
        self.ambiencePlayer = nil;
    }
}

-(void)fadeOutAmbienceSoundWithCompletion:(void (^)(void))completion
{
    [self.ambiencePlayer setVolume:0.0 duration:0.2 completion:completion];
}
#pragma mark - Key-Value Observing for arrays

#pragma mark -
#pragma mark Languages
- (NSUInteger) countOfLanguages
{
    return self.languages.count;
}
- (id) objectInLanguagesAtIndex:(NSUInteger)index
{
    return [self.languages objectAtIndex:index];
}

- (void) insertLanguages:(NSArray *)array atIndexes:(NSIndexSet *)indexes
{
    [self.languages insertObjects:array atIndexes:indexes];
#ifdef DEBUG
    NSLog(@" DataSource  inserted %ld languages", (long)array.count);
#endif
}
#pragma mark non KVO
-(void) cleanLanguages
{
    [self.languages removeAllObjects];
    self.languages = nil;
}

-(LanguageObject *)languageForDeviceLangID:(NSString *)devieLangId
{
    LanguageObject *toReturn;
    if ([devieLangId isEqualToString:@"ru"])
    {
        for (LanguageObject *lvLanguage in self.languages)
        {
            if ([lvLanguage.languageName isEqualToString:@"Russian"])
            {
                toReturn = lvLanguage;
                break;
            }
        }
    }
    else
    {
        for (LanguageObject *lvLanguage in self.languages)
        {
            if ([lvLanguage.languageName isEqualToString:@"English"])
            {
                toReturn = lvLanguage;
                break;
            }
        }
    }
    
    return toReturn;
}
#pragma mark -
#pragma mark Countries
- (NSUInteger) countOfCountries
{
    return  self.countries.count;
}
- (id) objectInCountriesAtIndex:(NSUInteger)index
{
    return [self.countries objectAtIndex:index];
}

- (void) insertCountries:(NSArray *)array atIndexes:(NSIndexSet *)indexes
{
    [self.countries insertObjects:array atIndexes:indexes];
#ifdef DEBUG
    NSLog(@" DataSource  inserted %ld countries", (long)array.count);
#endif
}
#pragma mark non KVO
-(void) cleanCountries
{
    [self.countries removeAllObjects];
    self.countries = nil;
}

#pragma mark -
#pragma mark Contacts
- (id)objectInContactsAtIndex:(NSUInteger)index
{
    return [self.contacts objectAtIndex:index];
}

- (NSUInteger)countOfContacts
{
    return self.contacts.count;
}

- (void)insertObject:(Contact *)object inContactsAtIndex:(NSUInteger)index
{
     //KVO Notification triggered after the whole method completes!
    [self.contacts insertObject:object atIndex:index];
    [self.contacts sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES selector:@selector(caseInsensitiveCompare:)]]];
}

-(void) insertContacts:(NSArray *)array atIndexes:(NSIndexSet *)indexes
{
    //KVO Notification triggered after the whole method completes!
    [self.contacts insertObjects:array atIndexes:indexes];
    self.karaContact = self.contacts.firstObject;
    //NSLog(@" DataSource inserted %ld  contacts", (long)array.count);
}

- (void)removeObjectFromContactsAtIndex:(NSUInteger)index
{
    [self.contacts removeObjectAtIndex:index];
}

- (void)replaceObjectInContactsAtIndex:(NSUInteger)index withObject:(id)object
{
     //KVO Notification triggered after the whole method completes!
    [self.contacts replaceObjectAtIndex:index withObject:object];
    [self.contacts sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES selector:@selector(caseInsensitiveCompare:)]]];
}

- (void)removeContactsObject:(Contact *)object
{
    if ([self.avatars objectForKey:object.contactId])
    {
        [self.avatars removeObjectForKey:object.contactId];
    }
    [self.contacts removeObject:object];
}
#pragma mark non KVO
-(void) removeContacts:(NSSet *)objects
{
    [self.contacts removeObjectsInArray:objects.allObjects];
#ifdef DEBUG
    NSLog(@"DataSourse removed all contacts,  Current Count = %ld", (long)self.contacts.count);
#endif
}

#pragma mark -
#pragma mark Messages

- (id)objectInMessagesAtIndex:(NSUInteger)index
{
    return [self.messages objectAtIndex:index];
}

- (NSUInteger)countOfMessages
{
    return self.messages.count;
}

- (void) insertObject:(Message *)object inMessagesAtIndex:(NSUInteger)index
{
    [self.messages insertObject:object atIndex:index];
#ifdef DEBUG
    NSLog(@" DataSource inserted message: %@", object.textBody);
#endif
}

-(void) insertMessages:(NSArray *)array atIndexes:(NSIndexSet *)indexes
{
    [self.messages insertObjects:array atIndexes:indexes];
    //NSLog(@" DataSource inserted %ld Messages.", (long)array.count);
}

-(void) addMessagesObject:(Message *)object
{
    [self.messages addObject:object];
#ifdef DEBUG
    NSLog(@"\n - %@ inserted a message", NSStringFromClass([self class]));
#endif
}

- (void) removeObjectFromMessagesAtIndex:(NSUInteger)index
{
    [self.messages removeObjectAtIndex:index];
}

-(void) replaceObjectInMessagesAtIndex:(NSUInteger)index withObject:(id)object
{
    [self.messages replaceObjectAtIndex:index withObject:object];
}

-(void) removeMessagesAtIndexes:(NSIndexSet *)indexes
{
    [self.messages removeObjectsAtIndexes:indexes];
}

#pragma mark non KVO
-(void) removeMessages:(NSSet *)objects
{
    if (objects)
    {
        [self.messages removeObjectsInArray:objects.allObjects];
    }
    else
    {
        [self.messages removeAllObjects];
    }
    
}

- (void) deleteAllMessagesForContactOrChatElementId:(NSNumber *)elementId
{
    NSIndexSet *messagesIndexSetTest = [self.messages indexesOfObjectsWithOptions:0
                                                                      passingTest:^BOOL(Message *testedMessage, NSUInteger idx, BOOL *stop)
    {
        return testedMessage.elementId == elementId;
    }];
    
    if (messagesIndexSetTest)
    {
#ifdef DEBUG
        NSLog(@"\n\n Removing messages by Contact");
#endif
        [self removeMessagesAtIndexes:messagesIndexSetTest];
    }
}

//- (Message *) getAssotiationsQuestionMessage
//{
//    NSArray *assotiations = [self.messages filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"typeId == 7"]];
//    if (assotiations.count > 0)
//    {
//        Message *lvQuestion = assotiations.lastObject;
//        if (lvQuestion.isNew.boolValue)
//        {
//            return lvQuestion;
//        }
//        return nil;
//    }
//    
//    return nil;
//}
//
//- (Message *) getConnectionsQuestionMessage
//{
//    NSArray *assotiations = [self.messages filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"typeId == 8"]];
//    if (assotiations.count > 0)
//    {
//        Message *lvQuestion = assotiations.lastObject;
//        if (lvQuestion.isNew.boolValue)
//        {
//            return lvQuestion;
//        }
//        return nil;
//    }
//    
//    return nil;
//}
//
//- (Message *) getRangeWordsQuestionMessage
//{
//    NSArray *assotiations = [self.messages filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"typeId == 9"]];
//    if (assotiations.count > 0)
//    {
//        return assotiations.lastObject;
//    }
//    
//    return nil;
//}

-(Message *) getNextRandomQuestion
{
    NSInteger countOfPending = self.pendingQuestions.count;
    Message *toReturn;
    if (countOfPending > 0)
    {
        NSInteger randomIndex = arc4random_uniform((uint32_t) countOfPending); // used casting here, because we always have less than 2^32 integer number
        toReturn = [[DataSource sharedInstance].pendingQuestions objectAtIndex:randomIndex];
        [self.pendingQuestions removeObjectAtIndex:randomIndex];
    }
    if (self.pendingQuestions.count < 3)
    {
        [self startLastMessagesTimer];
    }
#ifdef DEBUG
    NSLog(@"\r - Next random question: %@\n", toReturn.textBody);
#endif
    return toReturn;
}

-(void) setMessageWithText:(NSString *)messageText toBeNew:(BOOL)isNew
{
    NSNumber *boolIsNew = @(isNew);
    
    
    for (Message *lvMessage in self.messages)
    {
        if ([lvMessage.textBody isEqualToString:messageText])
        {
            lvMessage.isNew = boolIsNew;
            break;
        }
    }
}

#pragma mark -
#pragma mark Elements

- (id)objectInElementsAtIndex:(NSUInteger)index
{
    return [self.elements objectAtIndex:index];
}

- (NSUInteger)countOfElements
{
    return self.elements.count;
}

- (void)insertObject:(Element *)object inElementsAtIndex:(NSUInteger)index
{
    [self.elements insertObject:object atIndex:index];
}

- (void)insertElements:(NSArray *)array atIndexes:(NSIndexSet *)indexes
{
    [self.elements insertObjects:array atIndexes:indexes];
}
- (void)addElementsObject:(Element *)object
{
    [self.elements addObject:object];
}

-(void) replaceObjectInElementsAtIndex:(NSUInteger)index withObject:(id)object
{
    [self.elements replaceObjectAtIndex:index withObject:object];
}

-(void) removeObjectFromElementsAtIndex:(NSUInteger)index
{
    [self.elements removeObjectAtIndex:index];
}

-(void) removeElements:(NSSet *)objects
{
    [self.elements removeObjectsInArray:objects.allObjects];
}


#pragma mark Attaches
- (NSUInteger)countOfAttaches
{
    return self.attaches.count;
}

- (id)objectInAttachesAtIndex:(NSUInteger)index
{
    return [self.attaches objectAtIndex:index];
}

-(void) insertObject:(AttachFile *)object inAttachesAtIndex:(NSUInteger)index
{
    [self.attaches insertObject:object atIndex:index];
}

- (void) insertAttaches:(NSArray *)array atIndexes:(NSIndexSet *)indexes
{
    [self.attaches insertObjects:array atIndexes:indexes];
}

-(void) addAttachesObject:(AttachFile *)object
{
    [self.attaches addObject:object];
}

-(void) removeObjectFromAttachesAtIndex:(NSUInteger)index
{
    [self.attaches removeObjectAtIndex:index];
}

-(void) replaceObjectInAttachesAtIndex:(NSUInteger)index withObject:(id)object
{
    [self.attaches replaceObjectAtIndex:index withObject:object];
}

-(void) removeAttaches:(NSSet *)objects
{
    [self.attaches removeObjectsInArray:objects.allObjects];
}

#pragma mark - Avatars Dictionary
-(void) cleanAvatars
{
    [self.avatars removeAllObjects];
}




@end

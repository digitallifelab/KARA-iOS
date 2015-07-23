//
//  DataSource.h
//  Origami
//
//  Created by CloudCraft on 11.02.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "User.h"
#import "Contact.h"
#import "Message.h"
#import "Element.h"
#import "WordEcho.h"

#import "CountryObject.h"
#import "LanguageObject.h"

#import "AudioPlayback.h"


@interface DataSource : NSObject

@property (nonatomic, strong) NSMutableArray *pendingQuestions;
@property (nonatomic, strong) NSMutableArray *messages;
@property (nonatomic, strong) NSMutableArray *contacts;
@property (atomic, strong)    NSMutableArray *elements;
@property (nonatomic, strong) NSMutableArray *languages;
@property (nonatomic, strong) NSMutableArray *countries;

@property (nonatomic, strong) NSMutableArray *echoes;

@property (nonatomic, strong) AudioPlayback *ambiencePlayer;
@property (nonatomic, strong) NSMutableDictionary *avatars;

@property (nonatomic, strong) NSMutableArray *attaches;

@property (nonatomic, strong) Contact *karaContact;
@property (nonatomic, strong) NSBlockOperation *messagesUpdaterOperation;// handles timers for querying new messages from server


+ (DataSource *) sharedInstance;

#pragma mark executions
//- (void) loadNewMessagesWithCompletion:(void(^)(NSDictionary *success, NSError *error)) completionBlock;
- (void) startLastMessagesTimer;
#pragma mark Getting Data

- (NSArray *) messagesForElementWithId:(NSNumber *)elementId;

- (Message *) lastMessageForElementId:(NSNumber *)elementId;

//- (Message *) getAssotiationsQuestionMessage; // #07#
//- (Message *) getConnectionsQuestionMessage; // #08#
//- (Message *) getRangeWordsQuestionMessage; // #09#
- (Message *) getNextRandomQuestion;
- (Contact *) getKaraContact;

- (User *) getCurrentUser;

- (Element *) getElementById:(NSNumber *)elementId;
-(void) setMessageWithText:(NSString *)messageText toBeNew:(BOOL)isNew;

- (NSArray *) signalElements;

- (NSArray *) favouriteElements;

- (NSArray *) lastElements;

//- (NSArray *) subordinateElementsOfRootElementId:(NSNumber *)rootElementID filterByType:(NSInteger)type;

- (UIImage *) avatarImageForOwnerId:(NSNumber *)contactId;
- (UIImage *) avatarImageForLoggedUser;

- (NSArray *) attachesForElementId:(NSNumber *)elementId;

- (AttachFile *) singleAttachByAttachId:(NSNumber *)attachId;

- (NSArray *) lastActiveContacts;

- (NSArray *) countriesForCountryNameFirstLetter:(NSString *)firstLetter;

- (NSArray *) languagesForLanguageNameFirstLetter:(NSString *)firstLetter;
//contacts
- (NSArray *) contactsForContactFirstNameFirstLetter:(NSString *)firstLetter;
- (NSString *) nameStringForContact:(Contact *)contact;
- (NSMutableArray *) contactsForElementWithId:(NSNumber *)elementId;
- (Contact *) getContactByContactId:(NSNumber *)contactId;


//animations
//-(CAKeyframeAnimation *) currentAmbientAnimationForContact:(Contact *)contact;
-(CAKeyframeAnimation *) karaFaceAnimation;

//sounds
-(void) playAmbienceSound;
//-(void) playSoundForEmotionNumber:(NSInteger)emotionNumber;
-(void) stopPlaying;
-(void) fadeOutAmbienceSoundWithCompletion:(void(^)(void))completion;

#pragma mark Key-Value Observing

//Contacts
- (NSUInteger) countOfContacts;
- (void) insertObject:(Contact *)object inContactsAtIndex:(NSUInteger)index;

- (void) insertContacts:(NSArray *)array atIndexes:(NSIndexSet *)indexes;
- (void) removeContactsObject:(Contact *)object;
- (void)removeObjectFromContactsAtIndex:(NSUInteger)index;

//Messages
- (NSUInteger)countOfMessages;
- (id) objectInMessagesAtIndex:(NSUInteger)index;
- (void) addMessagesObject:(Message *)object;
- (void) insertObject:(Message *)object inMessagesAtIndex:(NSUInteger)index;
- (void) insertMessages:(NSArray *)array atIndexes:(NSIndexSet *)indexes;
- (void) removeObjectFromMessagesAtIndex:(NSUInteger)index;
- (void) replaceObjectInMessagesAtIndex:(NSUInteger)index withObject:(id)object;

- (void) deleteAllMessagesForContactOrChatElementId:(NSNumber *)elementId;

//Elements
- (NSUInteger)countOfElements;
- (id) objectInElementsAtIndex:(NSUInteger)index;
- (void) addElementsObject:(Element *)object;
- (void) insertObject:(Element *)object inElementsAtIndex:(NSUInteger)index;
- (void) insertElements:(NSArray *)array atIndexes:(NSIndexSet *)indexes;
- (void) removeObjectFromElementsAtIndex:(NSUInteger)index;
- (void) replaceObjectInElementsAtIndex:(NSUInteger)index withObject:(id)object;

//Attaches
- (NSUInteger) countOfAttaches;
- (id) objectInAttachesAtIndex:(NSUInteger)index;
- (void) addAttachesObject:(AttachFile *)object;
- (void) insertObject:(AttachFile *)object inAttachesAtIndex:(NSUInteger)index;
- (void) insertAttaches:(NSArray *)array atIndexes:(NSIndexSet *)indexes;
- (void) removeObjectFromAttachesAtIndex:(NSUInteger)index;
- (void) replaceObjectInAttachesAtIndex:(NSUInteger)index withObject:(id)object;

//Languages+Countries KVO
- (NSUInteger) countOfLanguages;
- (id) objectInLanguagesAtIndex:(NSUInteger)index;
- (void) insertLanguages:(NSArray *)array atIndexes:(NSIndexSet *)indexes;

- (NSUInteger) countOfCountries;
- (id) objectInCountriesAtIndex:(NSUInteger)index;
- (void) insertCountries:(NSArray *)array atIndexes:(NSIndexSet *)indexes;

-(LanguageObject *)languageForDeviceLangID:(NSString *)devieLangId;
//perform logout

-(void) removeAttaches:(NSSet *)objects;
-(void) removeContacts:(NSSet *)objects;
-(void) removeMessages:(NSSet *)objects;
-(void) removeElements:(NSSet *)objects;

-(void) cleanAvatars;

-(void) cleanLanguages;
-(void) cleanCountries;
@end

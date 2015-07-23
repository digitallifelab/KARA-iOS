//
//  ServerRequester.h
//  Origami
//
//  Created by CloudCraft on 24.01.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "LanguageObject.h"
#import "DataSource.h" 
#import <UIKit/UIKit.h>
#import "UIProgressView+AFNetworking.h"
#import "Constants.h"
#import "AFNetworking.h"
//#define BasicURL @"http://192.168.0.101:8002/OrigamiWCFService/OrigamiService/"

#define BasicURL @"http://cloudcraftt1.cloudapp.net:8003/OrigamiWCFService/OrigamiService/"

@interface ServerRequester : NSObject// <NSURLConnectionDelegate, NSStreamDelegate, NSURLSessionDelegate>

typedef void (^networkCompletionBlock)(NSDictionary *successResponse,  NSError *error);

@property (nonatomic, strong) User *currentUser;

+(ServerRequester *)sharedRequester;


#pragma mark - instance methods
// registration and login
- (void) changePasswordWithNewPassword:(NSString *)newPassword completionBlock:(networkCompletionBlock) completionBlock;

- (void) registrationRequestWithParams:(NSDictionary *)params completionBlock:(networkCompletionBlock) completionBlock;

- (void) loginRequestWithParams:(NSDictionary *)params completion:(networkCompletionBlock) completionBlock progressView:(UIProgressView *)progressView;

- (void) updateUserInfoWithCompletion:(networkCompletionBlock) completionBlock;

- (void) uploadNewAvatar:(UIImage *)photo withCompletion:(networkCompletionBlock)completionBlock;

- (void) getUserAvatarForUserName:(NSString *)userLoginName withCompletion:(networkCompletionBlock)completionBlock;


// common info
-(void) loadCountriesWithCompletion:(networkCompletionBlock)completionBlock;

-(void) loadLanguagesWithCompletion:(networkCompletionBlock)completionBlock;


// Contacts

-(void) loadContactsWithCompletion:(networkCompletionBlock)completionBlock progressView:(UIProgressView *)progressView;

-(void) searchForContactByEmail:(NSString *)email completion:(networkCompletionBlock) completionBlock; //in add contact VC

-(void) loadContactsForCurrentElementId:(NSNumber *)elementId withCompletion:(networkCompletionBlock)completionBlock;

//-(void) addContactWithId:(NSNumber *)idNumber completion:(networkCompletionBlock) completionBlock;

//-(void) removeContactWithId:(NSNumber *)idNumber comletion:(networkCompletionBlock) completionBlock;

//-(void) changeIsFavouriteContactWithId:(NSNumber *)idNumber completion:(networkCompletionBlock) completionBlock;

//-(void) acceptContactWithId:(NSNumber *)idNumber completion:(networkCompletionBlock) completionBlock;

//-(void) rejectContactWithId:(NSNumber *)idNumber completion:(networkCompletionBlock) completionBlock;


// Messages
- (void) loadAllMessagesWithCompletion:(networkCompletionBlock) completionBlock progressView:(UIProgressView *)progressView;
- (void) loadLastMessagesWithCompletion:(networkCompletionBlock) completionBlock;
- (void) loadPendingMessageIDsWithCompletion:(networkCompletionBlock) completionBlock;
- (void) sendMessage:(Message *)message toContact:(Contact *)contact withCompletion:(networkCompletionBlock)completionBlock;
//- (void) sendMessage:(Message *)message toGroupChat:(Element *)element withCompletion:(networkCompletionBlock)completionBlock;
- (void) sendRateMessage:(NSString *)text toContact:(Contact *)contact withCompletion:(networkCompletionBlock) completionBlock;

-(NSString *)fixMessageBody:(NSString *)messageBody;


// Elements
-(void) addNewElement:(Element *)newElement withCompletion:(networkCompletionBlock) completionBlock;

-(void) loadElementsWithCompletion:(networkCompletionBlock) completionBlock;

//-(void) editElement:(Element *)element withCompletion:(networkCompletionBlock) completionBlock;

//-(void) passElement:(Element *)element toUserID:(NSNumber *) userID forDeletion:(BOOL) delete withCompletion:(networkCompletionBlock) completionBlock;

//-(void) passElement:(Element *)element toSeveralUserIDs:(NSArray *)userIDs withCompletion:(networkCompletionBlock)completionBlock;

//-(void) deleteElement:(Element *)element withCompletion:(networkCompletionBlock) completionBlock;

//-(void) setFavouriteElement:(Element *)element withComletion:(networkCompletionBlock) completionBlock;

//-(void) setElementFinished:(Element *) element withCompletion:(networkCompletionBlock) completionBlock;

//-(void) setRemindMeDate:(Element *) element withCompletion:(networkCompletionBlock) completionBlock;

//-(void) setFinishState:(NSNumber *) stane forElement:(Element *)element withCompletion:(networkCompletionBlock) completionBlock;

//-(void) loadPassWhomIDsForElementId:(NSNumber *)elementId completion:(networkCompletionBlock) completionBlock;

//Attaches for elements
//-(void) getAttachesListForElementId:(NSNumber *)elementId withCompletion:(networkCompletionBlock) completionBlock; //returns AttachFile array

//-(void) attachFile:(NSData *)fileData withName:(NSString *)name toElementWithId:(NSNumber *)elementId completion:(networkCompletionBlock) completionBlock; //POSTs a file

//-(void) loadAttachFileDataForFileId:(NSNumber *)attachId completion:(networkCompletionBlock)completionBlock;

//-(void) removeAttachedFileWithName:(NSString *)fileName frolElementWithId:(NSNumber *)elementId completion:(networkCompletionBlock) completionBlock;

// uncomment to test
//-(void) testRequestWithParams:(NSDictionary *)params completion:(networkCompletionBlock) completionBlock;

//Social Networks
-(void)tryToRequestTwitterInfoWithResult:(void (^)(NSDictionary *result))requestResultBlock;

-(void)tryToRequestFacebookInfoWithResult:(void (^)(NSDictionary *))requestResultBlock;

//TrendWords

-(void) getListOfTrendWordsWithCompletion:(networkCompletionBlock) completionBlock;

-(void) getTrendLinkedWordsForWord:(NSString *)searchWord withCompletion:(networkCompletionBlock) completionBlock;

// random video
-(void) getRandomVideoWithCompletion:(networkCompletionBlock) completionBlock;


@end

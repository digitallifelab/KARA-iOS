
//  ServerRequester.m
//  Origami
//
//  Created by CloudCraft on 24.01.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import "ServerRequester.h"


#import "NSData+PhotoConverter.h"

#import <Social/Social.h>
#import <Accounts/Accounts.h>

#import "FileHandler.h"

#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@interface ServerRequester ()//<NSURLConnectionDelegate, NSStreamDelegate, NSURLSessionDelegate>

@property (nonatomic, strong) NSMutableData *responseData;

@property (nonatomic, strong) NSOperationQueue *backGroundQueue;

@end

@implementation ServerRequester

+(ServerRequester *)sharedRequester
{
    static ServerRequester *singletoneInstance = nil;
    if (!singletoneInstance)
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            singletoneInstance = [[super allocWithZone:NULL] init];
            singletoneInstance.backGroundQueue = [[NSOperationQueue alloc] init];
        });
    }
    
    return singletoneInstance;
}

#pragma mark - Login & Registration
-(void) changePasswordWithNewPassword:(NSString *)newPassword completionBlock:(networkCompletionBlock) completionBlock
{
    //additionally detect current device`s language
    if (self.currentUser.state.integerValue == 1)
    {
        LanguageObject *lvDefaultLang = [self checkUserLanguageFromDefaultAndSettings];
        self.currentUser.language = lvDefaultLang.languageName;
        self.currentUser.languageID = lvDefaultLang.languageId;
    }
    
    //NSString *lang = [[NSLocale currentLocale] displayNameForKey:NSLocaleLanguageCode value:langID];

    self.currentUser.password = newPassword;
    
    NSMutableDictionary *params = [[self.currentUser toDictionary] mutableCopy];

//    NSLog(@"Params: %@", params);
    NSString *editUserUrlString = [NSString stringWithFormat:@"%@EditUser", BasicURL];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFJSONRequestSerializer *serializer = [AFJSONRequestSerializer serializer];
    
    [serializer setTimeoutInterval:20];
    [serializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [serializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    manager.requestSerializer = serializer;
    
    AFJSONResponseSerializer *jsonSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    [jsonSerializer.acceptableContentTypes setByAddingObjectsFromArray:@[@"text/html",@"application/json"] ];
    manager.responseSerializer = jsonSerializer;
    NSDictionary *toPass = @{@"user":params};
//    NSLog(@"To Pass: \n%@", toPass.description);
    
    AFHTTPRequestOperation *postEditOp = [manager POST:editUserUrlString
                                            parameters:toPass
                                               success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        if (completionBlock)
        {
            completionBlock(responseObject,nil);
        }
    }
                                               failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
//        if (error.description)
//        {
//            //NSLog(@"%@", error.description);
//        }
        if (completionBlock)
        {
            completionBlock(nil,error);
        }
    }];
    
    [postEditOp start];
}

-(void)registrationRequestWithParams:(NSDictionary *)params completionBlock:(networkCompletionBlock) completionBlock
{
    NSString *email = params[@"UserName"];
    NSString *firstName = [params objectForKey:@"FirstName"];
    NSString *lastName = [params objectForKey:@"LastName"];
    BOOL shouldPassParameters = YES;
    if ([firstName isKindOfClass:[NSNull class]])
    {
        shouldPassParameters = NO;
        firstName = @"Null";
    }
    
    if ([lastName isKindOfClass:[NSNull class]])
    {
        shouldPassParameters = NO;
        lastName = @"Null";
    }
    
    NSString *urlString;
    
    if (shouldPassParameters)
    {
        urlString = [NSString stringWithFormat:@"%@RegisterUser", BasicURL];
    }
    else
    {
        urlString = [NSString stringWithFormat:@"%@RegisterUser?UserName=%@&FirstName=%@&LastName=%@", BasicURL, email, firstName,lastName];
    }
   
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //manager.requestSerializer.HTTPMethodsEncodingParametersInURI = [NSSet setWithArray:@[@"POST", @"GET", @"HEAD"]];
    [manager.requestSerializer setTimeoutInterval: 20];
    AFHTTPRequestOperation *requestOp = [manager GET:urlString
                                          parameters:(shouldPassParameters)?params:nil
                                             success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
//        NSLog(@"\n Success response:\n- %@",responseObject);
        
        if (completionBlock)
        {
            completionBlock(responseObject,nil);
        }
    }
                                             failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        //NSLog(@"\n registrationRequestWithParams Error: \n-%@", error.localizedDescription);
        //NSString *operationErrorString = operation.responseString;
        //NSLog(@"\n Registration error response: %@ ", operationErrorString);
//        NSData *responseData = operation.responseData;
//        id responseObject = operation.responseObject;
        
        if (completionBlock)
        {
            completionBlock(nil,error);
        }
    }];
    
    [requestOp start];
}

-(void)loginRequestWithParams:(NSDictionary *)params completion:(networkCompletionBlock) completionBlock progressView:(UIProgressView *)progressView
{
    //NSString *urlString = [NSString stringWithFormat:@"%@Login?username=%@&password=%@",BasicURL,params[@"username"], params[@"password"]];
    [[[NSOperationQueue alloc] init] addOperationWithBlock:^
    {
        NSString *urlString = [NSString stringWithFormat:@"%@Login", BasicURL];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager.requestSerializer setTimeoutInterval:40];
        
        AFHTTPRequestOperation *requestOp = [manager GET:urlString
                                              parameters:params
                                                 success:^(AFHTTPRequestOperation *operation, id responseObject)
                                             {
                                                 //NSLog(@"\n Success response:\n- %@",responseObject);
                                                 NSDictionary *responseDict = (NSDictionary *)responseObject;
                                                                                                  if (completionBlock)
                                                 {
                                                     completionBlock(responseDict, nil);//(@{@"LoginResult":toPass},nil);
                                                 }
                                             }
                                                 failure:^(AFHTTPRequestOperation *operation, NSError *error)
                                             {
                                                 //NSLog(@"\n loginRequestWithParams Error: \n-%@", error);
                                                 
                                                 if (completionBlock)
                                                 {
                                                     NSString *errorMessage = operation.responseString;
                                                     if (errorMessage)
                                                     {
                                                         NSError *lvError = [NSError errorWithDomain:@"Login error" code:701 userInfo:@{NSLocalizedDescriptionKey:errorMessage}];
                                                         completionBlock(nil, lvError);
                                                     }
                                                     else
                                                     {
                                                         completionBlock(nil, error);
                                                     }
                                                 }
                                             }];
        if (progressView != nil)
        {
            __block float oldProgress = 0.0;
            
            [requestOp setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead)
             {
                 float percent = ((float)totalBytesRead / (float)totalBytesExpectedToRead);
                 if (oldProgress != percent)
                 {
                     oldProgress = percent;
                     
                     NSInteger fifth = floor(oldProgress * 100);
                     if ((fifth % 5) == 0)
                     {
                         //NSLog(@"\n - Logging In progress: %f", roundf(oldProgress * 100));
                         [progressView setProgress:oldProgress];
                     }
                     
                 }
             }];
        }
        
        
        [requestOp start];
    }];
}

#pragma mark Update Current User Info
-(void) updateUserInfoWithCompletion:(networkCompletionBlock) completionBlock
{
    NSString *editUserUrlString = [NSString stringWithFormat:@"%@EditUser", BasicURL];
    NSDictionary *userToSend = [NSDictionary dictionaryWithObjectsAndKeys:[self.currentUser toDictionary] , @"user",nil];
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFJSONRequestSerializer *serializer = [AFJSONRequestSerializer serializer];
    
    [serializer setTimeoutInterval:20];
    [serializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [serializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    manager.requestSerializer = serializer;
    
    
    
    AFJSONResponseSerializer *jsonSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    [jsonSerializer.acceptableContentTypes setByAddingObjectsFromArray:@[@"text/html",@"application/json"] ];
    manager.responseSerializer = jsonSerializer;
    
    
    AFHTTPRequestOperation *postEditOp =
    [manager POST:editUserUrlString
       parameters:userToSend
          success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         if (completionBlock)
         {
             completionBlock(responseObject,nil);
         }
     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
//         if (error.description)
//         {
//            // NSLog(@"%@", error.description);
//         }
//         NSString *responseString = operation.responseString;
//         if (responseString)
//         {
//            // NSLog(@"\r\n updateUserInfoWithCompletion Error response: %@", responseString);
//         }
         if (completionBlock)
         {
             completionBlock(nil,error);
         }
     }];

    [postEditOp start];
    
}

- (void) uploadNewAvatar:(UIImage *)photo withCompletion:(networkCompletionBlock)completionBlock
{
    //"SetPhoto?token={token}"
    
    NSData *imageData = UIImagePNGRepresentation(photo);
//    NSInteger postLength = imageData.length;
//    NSLog(@"\r - uploadNewAvatar: Sending %ld bytes", (long)postLength);
    NSString *photoUploadURL = [NSString stringWithFormat:@"%@SetPhoto?token=%@", BasicURL, _currentUser.token];
    
    NSMutableURLRequest *mutableRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:photoUploadURL]];
    [mutableRequest setHTTPMethod:@"POST"];
    
    [mutableRequest setHTTPBody:imageData];
    
    [NSURLConnection sendAsynchronousRequest:mutableRequest
                                       queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
     {
         if (completionBlock)
         {
             if (data)
             {
                 
                 NSDictionary *responseDict = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                 if (responseDict)
                 {
                     completionBlock(responseDict, nil);
                 }
                 else
                 {
                     NSError *lvError = [NSError errorWithDomain:@"ImageUploading failure" code:NSKeyValueValidationError userInfo:@{NSLocalizedDescriptionKey:@"Wrong request format"} ];
                     completionBlock(nil, lvError);
                 }
            }
             else if (connectionError)
             {
                 //NSLog(@"Eror sending photo: %@", connectionError);
                 completionBlock(nil, connectionError);
             }
         }
    }];
}

- (void) getUserAvatarForUserName:(NSString *)userLoginName withCompletion:(networkCompletionBlock)completionBlock
{
    NSString *userAvatarRequestURL = [NSString stringWithFormat:@"%@GetPhoto?userName=%@", BasicURL, userLoginName];
    NSURL *requestURL = [NSURL URLWithString:userAvatarRequestURL];
    
    NSMutableURLRequest *avatarRequest = [NSMutableURLRequest requestWithURL:requestURL];
    [avatarRequest setHTTPMethod:@"GET"];
  
    [NSURLConnection sendAsynchronousRequest:avatarRequest
                                       queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
     {
         //NSLog(@"Response: \r %@", response);
         if (completionBlock)
         {
             if (!connectionError)
             {
                 if (data.length > 0)
                 {
                     NSError *jsonError;
                     id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
                     
                     if (jsonObject)
                     {
                         if ([(NSDictionary *)jsonObject objectForKey:@"GetPhotoResult"] != [NSNull null])
                         {
                             NSArray *result = [(NSDictionary *)jsonObject objectForKey:@"GetPhotoResult"];
                             
                             NSMutableData *mutableData = [NSMutableData data];
                             
                             for (NSNumber *number in result) //iterate through array and convert digits to bytes
                             {
                                 int digit = [number intValue];
                                 
                                 NSData *lvData = [NSData dataWithBytes:&digit length:1];
                                 
                                 [mutableData appendData:lvData];
                             }
                             
//                             NSData *photoData = [NSData dataFromIntegersArray:result];
                             
//                             if (mutableData.length == photoData.length)
//                             {
//                                 NSLog(@"\n  PHOTO TEST PASSED \n");
//                             }
                             
                             UIImage *photo = [UIImage imageWithData:mutableData];
                             if (photo)
                             {
                                 NSDictionary *photoDict = @{userLoginName : photo};
                                 completionBlock(photoDict, nil);
                             }
                             else
                             {
                                 NSError *lvError = [NSError errorWithDomain:@"Image Loading failure"
                                                                        code:NSKeyValueValidationError
                                                                    userInfo:@{NSLocalizedDescriptionKey:@"Could not convert data to Image"}];
                                 completionBlock(nil, lvError);
                             }
                             
                         }
                         else
                         {
                             NSError *lvError = [NSError errorWithDomain:@"Image Loading failure"
                                                                    code:NSKeyValueValidationError
                                                                userInfo:@{NSLocalizedDescriptionKey:@"No Image for User"}];
                             completionBlock(nil, lvError);
                         }
                     }
                     else
                     {
                         NSError *lvError = [NSError errorWithDomain:@"Image Loading failure"
                                                                code:NSKeyValueValidationError
                                                            userInfo:@{NSLocalizedDescriptionKey:@"Wrong response object"}];
                         completionBlock(nil, lvError);
                     }
                     
                 }
                 else
                 {
                     NSError *lvError = [NSError errorWithDomain:@"Image Loading failure"
                                                            code:NSKeyValueValidationError
                                                        userInfo:@{NSLocalizedDescriptionKey:@"Wrong data format"} ];
                     completionBlock(nil, lvError);
                 }
             }
             else
             {
                 completionBlock(nil, connectionError);
             }
         }
         
    }];
}

#pragma mark private methods
- (void) tryToLoadAvatarForContact:(Contact *)contact
{
    [[ServerRequester sharedRequester] getUserAvatarForUserName:contact.loginName withCompletion:^(NSDictionary *successResponse, NSError *error)
     {
         if (successResponse && [successResponse objectForKey:contact.loginName])
         {
             UIImage *avatarImage = [successResponse objectForKey:contact.loginName];
             
             [[DataSource sharedInstance].avatars setObject:avatarImage forKeyedSubscript:contact.contactId];
//             NSLog(@"\n -  Loaded image for %@ ", contact.loginName);
         }
//         else
//         {
//             NSLog(@"\n -  Did not Get Image for %@", contact.loginName);
//         }
         if (contact == [DataSource sharedInstance].contacts.lastObject)
         {
             if([UIApplication sharedApplication].networkActivityIndicatorVisible)
                 [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
         }
     }];
}

#pragma mark - Dictionaries

-(void)loadCountriesWithCompletion:(networkCompletionBlock)completionBlock
{
    [[[NSOperationQueue alloc] init] addOperationWithBlock:^
     {
         FileHandler *countriesHandler = [[FileHandler alloc] init];
         
         NSArray *countryDictionaries = [countriesHandler getCountriesFromDisk];
         if (countryDictionaries)
         {
             //NSLog(@"\n - (%@) loaded COUNTRIES from DISK.", NSStringFromClass([self class]));
             
             NSArray *countries = [[ServerRequester sharedRequester] convertDictionariesToCountries:countryDictionaries];
             NSRange countriesRange = NSMakeRange([[DataSource sharedInstance] countOfCountries], countries.count);
             NSIndexSet *lvCountriesIndexSet = [NSIndexSet indexSetWithIndexesInRange:countriesRange];
             
             [[DataSource sharedInstance] insertCountries:countries atIndexes:lvCountriesIndexSet];
             if (completionBlock)
             {
                 completionBlock(@{}, nil);
             }
         }//end of if statement
         else
         {
//             NSLog(@"\n - (%@) loading countries from SERVER...", NSStringFromClass([self class]));
             NSString *urlString = [NSString stringWithFormat:@"%@GetCountries",BasicURL];
             [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
             
             AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
             [manager.requestSerializer setTimeoutInterval:20];
             AFHTTPRequestOperation *requestOp =
             [manager GET:urlString
               parameters:nil
                  success:^(AFHTTPRequestOperation *operation, id responseObject)
              {
                  [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                  [[[NSOperationQueue alloc] init] addOperationWithBlock:^
                   {
                       NSDictionary *response = (NSDictionary *)responseObject;
                       
                       
                       NSArray *countriesResult = [response objectForKey:@"GetCountriesResult"];
                       
                       NSArray *countries = [[ServerRequester sharedRequester] convertDictionariesToCountries:countriesResult];
                       NSRange countriesRange = NSMakeRange([[DataSource sharedInstance] countOfCountries], countries.count);
                       NSIndexSet *lvCountriesIndexSet = [NSIndexSet indexSetWithIndexesInRange:countriesRange];
                       
                       [[DataSource sharedInstance] insertCountries:countries atIndexes:lvCountriesIndexSet];
                       
                       [[[FileHandler alloc] init] saveCountriesToDisk:countriesResult];
                       
                       if (completionBlock)
                       {
                           completionBlock(response, nil);
                       }
                   }];
              }
                  failure:^(AFHTTPRequestOperation *operation, NSError *error)
              {
                  [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                  //NSLog(@"\n loadCountriesWithCompletion Error: \n-%@", error);
                  if (completionBlock)
                  {
                      completionBlock(nil,error);
                  }
              }];
             
             [requestOp start];
         }//end of else statement
     }];//end of background queue
}

-(void) loadLanguagesWithCompletion:(networkCompletionBlock)completionBlock
{
    NSString *urlString = [NSString stringWithFormat:@"%@GetLanguages",BasicURL];
    
    [[[NSOperationQueue alloc] init] addOperationWithBlock:^
    {
        FileHandler *languagesHandler = [[FileHandler alloc] init];
        NSArray *languagesFromDisk = [languagesHandler getLanguagesFromDisk];
        if (languagesFromDisk)
        {
            //NSLog(@"\n - (%@) loaded LANGUAGES from DISK.", NSStringFromClass([self class]));
            
            NSArray *languages = [[ServerRequester sharedRequester] convertDictionariesToLanguageObjects:languagesFromDisk];
            NSRange languagesRange = NSMakeRange([[DataSource sharedInstance] countOfLanguages], languages.count);
            NSIndexSet *lvLanguagesIndexSet = [NSIndexSet indexSetWithIndexesInRange:languagesRange];
            
            [[DataSource sharedInstance] insertLanguages:languages atIndexes:lvLanguagesIndexSet];
            if (completionBlock)
            {
                completionBlock(@{}, nil);
            }
        }//end of if statement
        else
        {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            [manager.requestSerializer setTimeoutInterval:20];
            AFHTTPRequestOperation *requestOp = [manager GET:urlString
                                                  parameters:nil
                                                     success:^(AFHTTPRequestOperation *operation, id responseObject)
                                                 {
                                                     [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                                     //NSLog(@"\n Success response:\n- %@",responseObject);
                                                     NSDictionary *response = (NSDictionary *)responseObject;
                                                     
                                                     
                                                     NSArray *languages = [response objectForKey:@"GetLanguagesResult"];
                                                     [[[NSOperationQueue alloc] init] addOperationWithBlock:^
                                                      {
                                                          NSArray *lvLanguageObjects = [[ServerRequester sharedRequester] convertDictionariesToLanguageObjects:languages];
                                                          if (lvLanguageObjects)
                                                          {
                                                              NSRange lvRange = NSMakeRange([[DataSource sharedInstance] countOfLanguages], lvLanguageObjects.count);
                                                              NSIndexSet *lvIndexSet = [NSIndexSet indexSetWithIndexesInRange:lvRange];
                                                              [[DataSource sharedInstance] insertLanguages:lvLanguageObjects atIndexes:lvIndexSet];
                                                              
                                                              [[[FileHandler alloc] init] saveLanguagesToDisk:languages];
                                                          }
                                                          
                                                          if (completionBlock)
                                                          {
                                                              completionBlock(response,nil);
                                                          }
                                                      }];
                                                     
                                                 }
                                                     failure:^(AFHTTPRequestOperation *operation, NSError *error)
                                                 {
                                                     [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                                     //NSLog(@"\n loadLanguagesWithCompletion Error: \n-%@", error);
                                                     if (completionBlock)
                                                     {
                                                         completionBlock(nil,error);
                                                     }
                                                 }];
            
            [requestOp start];
        }//end of else statement
    }];//end of background queue
}

#pragma mark - Contact
-(void) searchForContactByEmail:(NSString *)email completion:(networkCompletionBlock)completionBlock
{
    //this is used in the app for downloading user`s photo
    //GetUserInfo
    
    NSString *requestUrlString = [NSString stringWithFormat:@"%@GetUserInfo", BasicURL];
    
    NSDictionary *parameters = @{@"userName":email, @"getPhoto":@"true"};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //[manager.requestSerializer setTimeoutInterval:15];
    
    AFHTTPRequestOperation *requestOp = [manager GET:requestUrlString
                                          parameters:parameters
                                             success:^(AFHTTPRequestOperation *operation, id responseObject)
                                         {
                                             [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                             
                                             [[[NSOperationQueue alloc] init] addOperationWithBlock:^
                                             {
                                                 NSDictionary *response = (NSDictionary *)responseObject;
                                                 NSDictionary *userDict = [response objectForKey:@"GetUserInfoResult"];
                                                 //NSLog(@"\n --searchForContactByEmail--Success response:\n- %@",response);
                                                 if (completionBlock)
                                                 {
                                                     completionBlock((userDict)?userDict:@{},nil);
                                                 }
                                             }];
                                             
                                             
                                             
                                             
                                         }
                                             failure:^(AFHTTPRequestOperation *operation, NSError *error)
                                         {
                                             [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                             //NSLog(@"\n --searchForContactByEmail Error: \n-%@", error);
                                             if (completionBlock)
                                             {
                                                 completionBlock(nil,error);
                                             }
                                             
                                             NSString *responseString = operation.responseString;
                                             if (responseString)
                                             {
                                                 //NSLog(@"Failure response while searching contact by email: \r \n%@",responseString);
                                             }
                                         }];
    
    [requestOp start];
}

-(void) loadContactsForCurrentElementId:(NSNumber *)elementId withCompletion:(networkCompletionBlock)completionBlock
{
    //  "GetChatContacts?elementId={elementId}&token={token}"  GET
    if (!_currentUser.token)
    {
        return;
    }
    
    NSString *chatContactsURL = [NSString stringWithFormat:@"%@GetChatContacts?token=%@&elementId=%@", BasicURL, _currentUser.token, elementId];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setTimeoutInterval:15];
    
    AFHTTPRequestOperation *requestOp = [manager GET:chatContactsURL
                                          parameters:nil
                                             success:^(AFHTTPRequestOperation *operation, id responseObject)
                                         {
                                             [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                             if (completionBlock)
                                             {
                                                 dispatch_queue_t bgQueue = dispatch_queue_create("inserterContactsQueue", DISPATCH_QUEUE_CONCURRENT);
                                                 dispatch_async(bgQueue, ^
                                                 {
                                                     NSDictionary *response = (NSDictionary *)responseObject;
                                                     NSArray *contacts = [self convertContactsDictionariesToContactObjects: response[@"GetChatContactsResult"]];
                                                     
                                                     NSRange indexRange = NSMakeRange([[DataSource sharedInstance] countOfContacts], contacts.count);
                                                     NSIndexSet *lvIndexSet = [NSIndexSet indexSetWithIndexesInRange:indexRange];
                                                     
                                                     [[DataSource sharedInstance] insertContacts:contacts atIndexes:lvIndexSet];
                                                     
                                                     
                                                     completionBlock(@{},nil);
                                                 });
                                                
                                             
                                             
                                                 
                                             }
                                             
                                             
                                             
                                         }
                                             failure:^(AFHTTPRequestOperation *operation, NSError *error)
                                         {
                                             [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                             //NSLog(@"\n loadContactsForCurrentElementId Error: \n-%@", error);
                                             if (completionBlock)
                                             {
                                                 completionBlock(nil,error);
                                             }
                                         }];
    
    [requestOp start];
    
}

-(void) addContactWithId:(NSNumber *)idNumber completion:(networkCompletionBlock) completionBlock
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    //AddContact?contactId={contactId}&token={token}
    NSString *requestUrlString = [NSString stringWithFormat:@"%@AddContact", BasicURL];
    
    NSDictionary *parameters = @{@"contactId":idNumber, @"token":_currentUser.token}; //we send UserID, not ContactID  here, because server returns USER object on search querry
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setTimeoutInterval:15];
    
    AFHTTPRequestOperation *requestOp = [manager GET:requestUrlString
                                          parameters:parameters
                                             success:^(AFHTTPRequestOperation *operation, id responseObject)
                                         {
                                             [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                             
                                             NSDictionary *response = (NSDictionary *)responseObject;
                                             
                                             //[[DataSource sharedInstance].contacts removeAllObjects];
                                             
                                             [[ServerRequester sharedRequester] loadContactsWithCompletion:^(NSDictionary *successResponse, NSError *error)
                                             {
                                                 if (completionBlock)
                                                 {
                                                     completionBlock(response,nil);
                                                 }
                                             } progressView:nil];
                                             
                                         }
                                             failure:^(AFHTTPRequestOperation *operation, NSError *error)
                                         {
                                             [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                             //NSLog(@"\n addContactWithId: Error: \n-%@", error);
                                             if (completionBlock)
                                             {
                                                 completionBlock(nil,error);
                                             }
                                         }];
    
    [requestOp start];
}

-(void) loadContactsWithCompletion:(networkCompletionBlock)completionBlock progressView:(UIProgressView *)progressView
{
    NSString *requestUrlString = [NSString stringWithFormat:@"%@GetContacts", BasicURL];
    
    NSString *lvToken;
    if (self.currentUser.token)
    {
        lvToken = self.currentUser.token;
    }
    else
    {
        lvToken = [[NSUserDefaults standardUserDefaults] objectForKey:CURRENT_USER_TOKEN];
    }
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:lvToken, @"token", nil]; //@{@"token":_currentUser.token};
    
    
    
    if (parameters.allKeys.count < 1)
    {
        if (completionBlock)
        {
            NSError *error = [NSError errorWithDomain:@"Data consistency failure"
                                                 code:NSKeyValueValidationError
                                             userInfo:@{NSLocalizedDescriptionKey:@"No User Token"}
                              ];
            completionBlock(nil, error);
        }
        return;
    }
    
    NSOperationQueue *backGroundQueue = [[NSOperationQueue alloc] init];
    [backGroundQueue addOperationWithBlock:^
    {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        //[manager.requestSerializer setTimeoutInterval:15];
        
        AFHTTPRequestOperation *requestOp =
        [manager GET:requestUrlString
          parameters:parameters
             success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             //[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
             
             dispatch_queue_t bgQueue = dispatch_queue_create("inserterContactsQueue", DISPATCH_QUEUE_SERIAL);
             dispatch_async(bgQueue, ^
                            {
                                NSDictionary *response = (NSDictionary *)responseObject;
                                NSArray *contacts = [[ServerRequester sharedRequester] convertContactsDictionariesToContactObjects: response[@"GetContactsResult"]];
                                if (contacts.count < 1)
                                {
                                    if (completionBlock)
                                        completionBlock(nil,nil);
                                    return ;
                                }
                                NSIndexSet *lvIndexSet = [NSIndexSet indexSetWithIndex:0];
                                [[DataSource sharedInstance] insertContacts:contacts atIndexes:lvIndexSet];
                                
                                //returning completion in this backgroud queue
                                
                                if (completionBlock)
                                    completionBlock(@{},nil);
                            });
             
         }
             failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
             //NSLog(@"\n loadContactsWithCompletion Error: \n-%@", error);
             if (completionBlock)
             {
                 completionBlock(nil,error);
             }
        }];
        
        
        if(progressView != nil) //some UI customization
        {
            __block float oldProgress = 0.0;
            
            [requestOp setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead)
             {
                 float percent = ((float)totalBytesRead / (float)totalBytesExpectedToRead);
                 if (oldProgress != percent)
                 {
                     oldProgress = percent;
                     NSInteger fifth = floor(oldProgress * 100);
                     
                     if ((fifth % 5) == 0)
                     {
                         dispatch_async(dispatch_get_main_queue(), ^
                                        {
                                            //NSLog(@"\n- Loading Contacts progress: %f",roundf(percent * 100));
                                            [progressView setProgress:percent];
                                        });
                     }
                     
                 }
                 
             }];
        }
        
        [requestOp start];
        
    }];
}

-(void) removeContactWithId:(NSNumber *)idNumber comletion:(networkCompletionBlock)completionBlock
{
    //RemoveContact?contactId={contactId}&token={token}
    NSString *requestUrlString = [NSString stringWithFormat:@"%@RemoveContact", BasicURL];
    
    NSDictionary *parameters = @{@"contactId":idNumber, @"token":_currentUser.token};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setTimeoutInterval:15];
    
    AFHTTPRequestOperation *requestOp = [manager GET:requestUrlString
                                          parameters:parameters
                                             success:^(AFHTTPRequestOperation *operation, id responseObject)
                                         {
                                             [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                             
                                             [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
                                                 //NSDictionary *response = (NSDictionary *)responseObject;
                                                 
                                                 //NSLog(@"\n--removeContactWithId-- Success response:\n- %@",response);
                                                 if (completionBlock)
                                                 {
                                                     completionBlock(@{idNumber:@"removed"},nil);
                                                 }                                             }];
                                             
                                             
                                             
                                             
                                         }
                                             failure:^(AFHTTPRequestOperation *operation, NSError *error)
                                         {
                                             [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                             NSString *failureString = operation.responseString;
                                             NSError *lvError;
                                             if (failureString)
                                             {
                                                 lvError = [NSError errorWithDomain:@"RemoveContactError" code:100510 userInfo:@{NSLocalizedDescriptionKey:failureString}];
                                             }
                                             //NSLog(@"\n removeContactWithId Error: \n-%@", error);
                                             if (completionBlock)
                                             {
                                                 
                                                 completionBlock(nil, (lvError)?lvError:error);
                                             }
                                         }];
    
    [requestOp start];
}

-(void) changeIsFavouriteContactWithId:(NSNumber *)idNumber completion:(networkCompletionBlock) completionBlock
{
    //SetFavoriteContact?contactId={contactId}&token={token}
    
    NSString *requestUrlString = [NSString stringWithFormat:@"%@SetFavoriteContact", BasicURL];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:_currentUser.token, @"token", idNumber, @"contactId", nil];//@{@"contactId":idNumber, @"token":_currentUser.token};
    
    if (parameters.allKeys.count < 2)
    {
        if (completionBlock)
        {
            completionBlock(nil,[NSError errorWithDomain:@"Data consistency failure" code:NSKeyValueValidationError userInfo:@{NSLocalizedDescriptionKey:@"No User Token or ContactId"} ]);
        }
        return;
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setTimeoutInterval:15];
    
    AFHTTPRequestOperation *requestOp = [manager GET:requestUrlString
                                          parameters:parameters
                                             success:^(AFHTTPRequestOperation *operation, id responseObject)
                                         {
                                             [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                             
                                             NSDictionary *response = (NSDictionary *)responseObject;
                                             
                                             //NSLog(@"\n --changeIsFavouriteContactWithId-- Success response:\n- %@",response);
                                             if (completionBlock)
                                             {
                                                 completionBlock(response, nil);
                                             }
                                             
                                             
                                             
                                         }
                                             failure:^(AFHTTPRequestOperation *operation, NSError *error)
                                         {
                                             [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                             //NSLog(@"\n changeIsFavouriteContactWithId Error: \n-%@", error);
                                             if (completionBlock)
                                             {
                                                 completionBlock(nil, error);
                                             }
                                         }];
    
    [requestOp start];
}

-(void) acceptContactWithId:(NSNumber *)idNumber completion:(networkCompletionBlock) completionBlock
{
    NSString *requestUrlString = [NSString stringWithFormat:@"%@AcceptInvitation", BasicURL];
    
    NSDictionary *parameters = @{@"contactId":idNumber, @"token":_currentUser.token};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setTimeoutInterval:15];
    
    AFHTTPRequestOperation *requestOp = [manager GET:requestUrlString
                                          parameters:parameters
                                             success:^(AFHTTPRequestOperation *operation, id responseObject)
                                         {
                                             [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                             
                                             NSDictionary *response = (NSDictionary *)responseObject;
                                             
                                             //NSLog(@"\n--acceptContactWithId-- Success response:\n- %@",response);
                                             if (completionBlock)
                                             {
                                                 completionBlock(response,nil);
                                             }
                                             
                                             
                                             
                                         }
                                             failure:^(AFHTTPRequestOperation *operation, NSError *error)
                                         {
                                             [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                             //NSLog(@"\n acceptContactWithId Error: \n-%@", error);
                                             if (completionBlock)
                                             {
                                                 completionBlock(nil, error);
                                             }
                                         }];
    
    [requestOp start];
}

-(void) rejectContactWithId:(NSNumber *)idNumber completion:(networkCompletionBlock) completionBlock
{
    NSString *requestUrlString = [NSString stringWithFormat:@"%@RejectInvitation", BasicURL];
    
    NSDictionary *parameters = @{@"contactId":idNumber, @"token":_currentUser.token};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setTimeoutInterval:15];
    
    AFHTTPRequestOperation *requestOp = [manager GET:requestUrlString
                                          parameters:parameters
                                             success:^(AFHTTPRequestOperation *operation, id responseObject)
                                         {
                                             [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                             
                                             NSDictionary *response = (NSDictionary *)responseObject;
                                             
                                            // NSLog(@"\n--rejectContactWithId-- Success response:\n- %@",response);
                                             if (completionBlock)
                                             {
                                                 completionBlock(response,nil);
                                             }
                                             
                                             
                                             
                                         }
                                             failure:^(AFHTTPRequestOperation *operation, NSError *error)
                                         {
                                             [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                             //NSLog(@"\n rejectContactWithId Error: \n-%@", error);
                                             if (completionBlock)
                                             {
                                                 completionBlock(nil, error);
                                             }
                                         }];
    
    [requestOp start];
}

#pragma mark - Message

-(void) loadAllMessagesWithCompletion:(networkCompletionBlock) completionBlock progressView:(UIProgressView *)progressView
{
//    //try to extract messages
//    FileHandler *lvFileHandler = [[FileHandler alloc] init];
//    NSArray *storedMessages = [lvFileHandler getSavedMessages];
//    
//    if (storedMessages && storedMessages.count > 0)
//    {
//        for (NSDictionary *lvMessageInfo in storedMessages)
//        {
//            Message *lvMessage = [[Message alloc] initWithParams:lvMessageInfo];
//            [[DataSource sharedInstance].pendingQuestions addObject:lvMessage];
//        }
//        completionBlock(@{},nil);
//        return;
//    }
    
    
    
    //or get messages
    
    
    NSString *urlString = [NSString stringWithFormat:@"%@GetMessages", BasicURL];
    NSDictionary *paramsDict = [NSDictionary dictionaryWithObjectsAndKeys:_currentUser.token, @"token", nil];// @{@"token":_currentUser.token};
    
    if (paramsDict.allKeys.count < 1)
    {
        completionBlock(nil, nil);
        return;
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFHTTPRequestOperation *messagesOp = [manager GET:urlString
                                           parameters:paramsDict
                                              success:^(AFHTTPRequestOperation *operation, id responseObject)
                                          {
                                              if (completionBlock)
                                              {
                                                  [[[NSOperationQueue alloc] init] addOperationWithBlock:^
                                                   {
                                                       NSArray *response = (NSArray *)[responseObject objectForKey:@"GetMessagesResult"];
                                                       
                                                       if (response.count > 0)
                                                       {
                                                           NSArray *messageObjects = [self messageDictionariesToMessages:response];
                                                           
                                                           [DataSource sharedInstance].pendingQuestions = [NSMutableArray arrayWithArray:messageObjects];
                                                           
                                                          /*NSMutableArray *messagesToInsert =*/ //[self fixQuestionMessagesIsNewValues:messageObjects];

                                                          // NSRange indexRange = NSMakeRange([[DataSource sharedInstance] countOfMessages], messagesToInsert.count);
                                                          // NSIndexSet *lvIndexSet = [NSIndexSet indexSetWithIndexesInRange:indexRange];
                                                           
                                                           //[[DataSource sharedInstance] insertMessages:messagesToInsert atIndexes:lvIndexSet]; //adding like this for KVO notifications
                                                           //NSMutableArray *testArray = [DataSource sharedInstance].pendingQuestions;
                                                           completionBlock(@{},nil);
                                                           
                                                       }
                                                       else
                                                       {
                                                           Message *emptyMessage = [[Message alloc] init];
                                                           emptyMessage.textBody = @"";
                                                           emptyMessage.dateCreated = [NSDate date];
                                                           emptyMessage.elementId = [DataSource sharedInstance].getCurrentUser.userID;
                                                           emptyMessage.isNew = @(0);
                                                           [[DataSource sharedInstance] insertMessages:@[emptyMessage] atIndexes:[NSIndexSet indexSetWithIndex:0]];
                                                           if (completionBlock)
                                                           {
                                                               completionBlock(@{},nil);
                                                           }
                                                       }
                                                   }];
                                              }
                                          }
                                              failure:^(AFHTTPRequestOperation *operation, NSError *error)
                                          {
                                              if (completionBlock)
                                              {
                                                  NSString *operationErrorString = operation.responseString;
                                                  if (operationErrorString)
                                                  {
                                                       //NSLog(@"LoadAllMessages Failure: %@", operationErrorString);
                                                  }
                                                 
                                                  completionBlock(nil, error);
                                              }
                                          }];
    
    if (progressView != nil)
    {
        __block float oldProgress = 0.0;
        
        [messagesOp setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead)
         {
             float percent = ((float)totalBytesRead / (float)totalBytesExpectedToRead);
             if (oldProgress != percent)
             {
                 oldProgress = percent;
                 NSInteger fifth = floor(oldProgress * 100);
                 if ((fifth & 4) == 0)
                 {
                     //NSLog(@"\n - Messages In progress: %f", roundf(oldProgress * 100));
                     [progressView setProgress:oldProgress ];
                 }
                 
             }
         }];
    }
    
    [messagesOp start];
}

-(void) loadLastMessagesWithCompletion:(networkCompletionBlock) completionBlock
{
    
    NSString *urlString = [NSString stringWithFormat:@"%@GetNewMessages", BasicURL];
    NSDictionary *paramsDict = [NSDictionary dictionaryWithObjectsAndKeys:_currentUser.token, @"token", nil];//@{@"token":_currentUser.token};
    
    if (paramsDict.allKeys.count < 1) //for example after logout
    {
        //NSLog(@"Testing..  No User Token..");
        if (completionBlock)
        {
            completionBlock(nil,nil);
        }
        return;
    }
    
    //NSLog(@"loading last messages %@", (completionBlock)?@"WITH completion block":@"WITHOUT completion block");
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    AFHTTPRequestSerializer *serializer = manager.requestSerializer;
    [serializer setTimeoutInterval:10];
    
    AFHTTPRequestOperation *messagesOp =
    [manager GET:urlString
      parameters:paramsDict
         success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         //                                              NSLog(@"\r  - Last Messages Result: %@", responseObject);
         if (completionBlock)
         {
             [[NSOperationQueue mainQueue] addOperationWithBlock:^
              {
                  NSArray *response = (NSArray *)[responseObject objectForKey:@"GetNewMessagesResult"];
                  
                  if (response.count > 0)
                  {
                      NSArray *messageObjects = [self messageDictionariesToMessages:response];
                      
                      [self fixQuestionMessagesIsNewValues:messageObjects]; //adds neq questions from Kara to datasourse`s pending questions.
                      
                      completionBlock(@{},nil);
                  }
                  else
                  {
#ifdef DEBUG
                      NSLog(@"GetNewMessagesResult  is Empty array");
#endif
                      completionBlock(@{},nil);
                  }
                 
              }];
         }
         else
         {
#ifdef DEBUG
             NSLog(@"\n - %@ No completionBlock....", NSStringFromClass([self class]));
#endif
         }
        
     }
         failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
#ifdef DEBUG
         NSString *lvResponseString = operation.responseString;
         NSLog(@"\r - LoadLastMessages Failure: %@ ", lvResponseString);
#endif
         if (completionBlock)
         {
             completionBlock(nil, error);
         }
     }];
    
    [messagesOp start];
}

- (void) loadPendingMessageIDsWithCompletion:(networkCompletionBlock) completionBlock
{
    /*"GetQuestions?token={token}"*/
    
    NSString *lvToken = [ServerRequester sharedRequester].currentUser.token;
    if (lvToken)
    {
        NSString *requestURL = [NSString stringWithFormat:@"%@GetQuestions", BasicURL];
        NSDictionary *tokenDict = [[NSDictionary alloc] initWithObjectsAndKeys:lvToken,@"token", nil];
        if (tokenDict.allKeys.count > 0)
        {
            AFHTTPRequestOperationManager *lvManager = [AFHTTPRequestOperationManager manager];
            AFHTTPRequestOperation *lvOperation =
            [lvManager GET:requestURL parameters:tokenDict success:^(AFHTTPRequestOperation *operation, id responseObject)
            {
                [[[NSOperationQueue alloc] init] addOperationWithBlock:^
                {
#ifdef DEBUG
                    NSLog(@"\r -- Loaded Pending messages IDs: \n %@", responseObject);
#endif
                    NSArray *messageIDs = [((NSDictionary *)responseObject) objectForKey:@"GetQuestionsResult"];
                    
                    NSMutableArray *foundQuestions = [[NSMutableArray alloc] initWithCapacity:2];
                    if (1 > [DataSource sharedInstance].pendingQuestions.count)
                    {
                        if (completionBlock)
                            completionBlock([NSDictionary dictionaryWithObject:messageIDs forKey:@"iDs"], nil);
                        return ;
                    }
                    
                    if (messageIDs && messageIDs.count > 0)
                    {
                        //check for normal messages
                        for (NSNumber *lvMessageId in messageIDs)
                        {
                            if (lvMessageId.integerValue != 0)
                            {
                                Message *lvMessage = [[DataSource sharedInstance].pendingQuestions filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"messageId == %@", lvMessageId]].lastObject;
                                if (!lvMessage)
                                {
                                    continue;
                                }
                                
                                if (!lvMessage.isNew.boolValue)
                                {
                                    lvMessage.isNew = @(YES);
                                }
                                [foundQuestions addObject:lvMessage];
                                NSNumber *questionType = lvMessage.typeId;
                                NSArray *allQuestionsByType = [[DataSource sharedInstance].pendingQuestions filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"typeId == %@", questionType]];
                                [[DataSource sharedInstance].pendingQuestions removeObjectsInArray:allQuestionsByType];
                            }
                        }
                        
                        
                        //deal if some Message IDs are zeroes AFTER all messageIds non zero saved to local variable array(foundQuestions)
                        if ([messageIDs containsObject:@(0)])
                        {
                            NSArray *copyOfAllRecievedMessages = [[DataSource sharedInstance].pendingQuestions copy];
                            [[DataSource sharedInstance].pendingQuestions removeAllObjects];
                            [[ServerRequester sharedRequester] fixQuestionMessagesIsNewValues:copyOfAllRecievedMessages];
                        }
                        
                        //add stored questions if present
                        if (foundQuestions.count > 0)
                        {
                            NSArray *lvPending = [DataSource sharedInstance].pendingQuestions;
                            if(lvPending.count > 0)
                                [ [DataSource sharedInstance].pendingQuestions removeAllObjects];
                            
                            [[DataSource sharedInstance].pendingQuestions addObjectsFromArray:foundQuestions];
                        }
                        
                    }
                    
                    // finally return
                    if (completionBlock)
                        completionBlock(nil, nil);
                }];

            }
                   failure:^(AFHTTPRequestOperation *operation, NSError *error)
             {
                 if  (completionBlock)
                     completionBlock(nil, error);
            }];
            
            [lvOperation start];
        }
    }
    else
    {
        completionBlock(nil,nil);
    }
}


-(void) sendMessage:(Message *)message toGroupChat:(Element *)element withCompletion:(networkCompletionBlock)completionBlock
{
    //NSLog(@"\r - Sending message %@ to chat named %@, elementID: %@", message.textBody, element.title, element.elementId);
    
    [self sendMessage:message toElementId:element.elementId withCompletion:completionBlock];
}

-(void) sendMessage:(Message *)message toContact:(Contact *)contact withCompletion:(networkCompletionBlock)completionBlock
{
    //NSLog(@"\r - Sending message \"%@\" to %@, elementID: %@", message.textBody ,contact.loginName, contact.elementId);
    [self sendMessage:message toElementId:contact.elementId withCompletion:completionBlock];
}
#pragma mark private message sending method
-(void) sendMessage:(Message *)message toElementId:(NSNumber *)elementId withCompletion:(networkCompletionBlock) completionBlock
{
    //POST
    //NSLog(@"\r - Current UserId = %ld", (long)_currentUser.userID.integerValue);
    NSString *postUrlString = [NSString stringWithFormat:@"%@SendElementMessage?token=%@&elementId=%@", BasicURL, _currentUser.token, elementId];
//    NSDictionary *messageDict = [message toDictionary];
    NSDictionary *params = @{@"msg":message.textBody};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    AFJSONRequestSerializer *serializer = [AFJSONRequestSerializer serializer];
    
    [serializer setTimeoutInterval:20];
    [serializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [serializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    manager.requestSerializer = serializer;
    
    AFHTTPRequestOperation *messageSendOp = [manager POST:postUrlString
                                               parameters:params
                                                  success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        if (completionBlock)
        {
            completionBlock(@{}, nil);
        }
    }
                                                  failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        if (completionBlock)
        {
            NSString *responseString = operation.responseString;
            if (responseString)
            {
#ifdef DEBUG
                NSLog(@"\r - Error Sending Message: \r %@", responseString);
#endif
                NSError *lvError = [NSError errorWithDomain:@"Failure sending message" code:703 userInfo:@{NSLocalizedDescriptionKey:responseString}];
                completionBlock(nil, lvError);
            }
            else
                completionBlock(nil, error);
        }
    }];
    
    [messageSendOp start];
}

- (void)sendRateMessage:(NSString *)text toContact:(Contact *)contact withCompletion:(networkCompletionBlock)completionBlock
{
    if (!text || text.length < 5 || !contact)
    {
        if (completionBlock)
        {
            completionBlock(nil,nil);
        }
        return;
    }
    
    
    //POST
    NSString *postUrlString = [NSString stringWithFormat:@"%@SendElementMessage?token=%@&elementId=%@", BasicURL, _currentUser.token, contact.elementId];
    //    NSDictionary *messageDict = [message toDictionary];
    NSDictionary *params = @{@"msg":text};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    AFJSONRequestSerializer *serializer = [AFJSONRequestSerializer serializer];
    
    [serializer setTimeoutInterval:20];
    [serializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [serializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    manager.requestSerializer = serializer;
    
    AFJSONResponseSerializer *jsonSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    [jsonSerializer.acceptableContentTypes setByAddingObjectsFromArray:@[@"text/html",@"application/json"] ];
    manager.responseSerializer = jsonSerializer;
    
    AFHTTPRequestOperation *messageSendOp =
    [manager POST:postUrlString
       parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         if (completionBlock)
         {
             completionBlock(@{}, nil);
         }
     }
          failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         if (completionBlock)
         {
             NSString *errorMessage = operation.responseString;
             if (errorMessage)
             {
                 NSError *lvError = [NSError errorWithDomain:@"Login error" code:701 userInfo:@{NSLocalizedDescriptionKey:errorMessage}];
                 completionBlock(nil, lvError);
             }
             else
             {
                 completionBlock(nil, error);
             }
         }

     }];
    
    [messageSendOp start];
}

#pragma mark - Element

-(void) addNewElement:(Element *)newElement withCompletion:(networkCompletionBlock) completionBlock
{
    //POST
    /*
     UriTemplate = "AddElement?token={token}")] // url string
     int AddElement(Element element, Guid token); //params
     */
    
    NSString *addElementStringURL = [NSString stringWithFormat:@"%@AddElement?token=%@", BasicURL, _currentUser.token];
    NSMutableDictionary *elementDict = [[newElement toDictionary] mutableCopy];
    
    NSMutableDictionary *toSend = [@{} mutableCopy];
    for (NSString *key in elementDict.allKeys)
    {
        if ([elementDict objectForKey:key] != [NSNull null])
        {
            [toSend setObject:[elementDict objectForKey:key] forKey:key];
        }
    }
    
    NSDictionary *params = @{@"element":toSend};
    
    AFHTTPRequestOperationManager *operationManager = [AFHTTPRequestOperationManager manager];
    
    AFJSONRequestSerializer *serializer = [AFJSONRequestSerializer serializer];
    
    [serializer setTimeoutInterval:15];
    [serializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [serializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    operationManager.requestSerializer = serializer;
    
    
    AFHTTPRequestOperation *postOperation = [operationManager POST:addElementStringURL
                                                        parameters:params
                                                           success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        if(completionBlock) completionBlock(responseObject, nil);
    }
                                                           failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        if(completionBlock) completionBlock(nil, error);
    }];
    
    [postOperation start];
}

-(void) loadElementsWithCompletion:(networkCompletionBlock)completionBlock
{
    /*
     UriTemplate = "GetElements?token={token}")
     */
    NSDictionary *paramsDict = [NSDictionary dictionaryWithObjectsAndKeys:_currentUser.token, @"token", nil];//@{@"token":_currentUser.token};
    if (paramsDict.allKeys.count < 1)
    {
        return;
    }
    
    [[[NSOperationQueue alloc] init] addOperationWithBlock:^
     {
     
         NSString *urlString = [NSString stringWithFormat:@"%@GetElements", BasicURL];
         
         
         AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
         AFHTTPRequestOperation *messagesOp = [manager GET:urlString
                                                parameters:paramsDict
                                                   success:^(AFHTTPRequestOperation *operation, id responseObject)
                                               {
                                                   // main thread
                                                   if (completionBlock)
                                                   {
                                                       NSArray *response = (NSArray *)[responseObject objectForKey:@"GetElementsResult"];
                                                    
                                                       if (response.count > 0)
                                                       {
                                                           // Attention! to detect KVO changes, always switch to main queue in observing view controller or other object
                                                           [[[NSOperationQueue alloc] init] addOperationWithBlock:^
                                                            {
                                                                NSArray *elementObjects = [self convertDictionariesToElements:response];
                                                                
                                                                NSRange indexRange = NSMakeRange([[DataSource sharedInstance] countOfElements], elementObjects.count);
                                                                NSIndexSet *lvIndexSet = [NSIndexSet indexSetWithIndexesInRange:indexRange];
                                                                
                                                                [[DataSource sharedInstance] insertElements:elementObjects atIndexes:lvIndexSet];
                                                                
                                                                completionBlock(@{@"elements":elementObjects},nil);
                                                                
                                                                for (Element *lvElement in [DataSource sharedInstance].elements)
                                                                {
                                                                    [[ServerRequester sharedRequester] loadPassWhomIDsForElementId:lvElement.elementId completion:^(NSDictionary *successResponse, NSError *error)
                                                                    {
                                                                        if (!error)
                                                                        {
                                                                            NSArray *iDs = [successResponse objectForKey:@"iDs"];
                                                                            if (iDs.count > 0)
                                                                            {
                                                                                for (NSNumber *lvNumber in iDs)
                                                                                {
                                                                                    [lvElement.passWhomIds addObject:lvNumber];
                                                                                }
                                                                            }
                                                                        }
                                                                    }];
                                                                }
                                                            }];
                                                           
                                                           
                                                       }
                                                       else
                                                       {
#ifdef DEBUG
                                                           NSLog(@" Load Elements Loaded Empty array! ");
#endif
                                                           completionBlock(@{},nil);
                                                       }
                                                   }
                                               }
                                                   failure:^(AFHTTPRequestOperation *operation, NSError *error)
                                               {
                                                   //main thread
                                                   if (completionBlock)
                                                   {
                                                       completionBlock(nil, error);
                                                   }
#ifdef DEBUG
                                                   NSLog(@" \"GetElements\" -loadElementsWithCompletion  Error: %@", error.description);
#endif
                                                   
//                                                   NSURLResponse *failureResponse = operation.response;
//                                                   NSData *responseData = operation.responseData;
//                                                   NSString *responseString =  operation.responseString;
                                                   
                                                   
                                               }];
         
         [messagesOp start];
     
     }];//end ob BG queue block
    
}

-(void) editElement:(Element *)element withCompletion:(networkCompletionBlock) completionBlock
{
    // EditElement?token={token}")
    //"POST"
    
    /*
     element.Title
     element.Description
     element.IsSignal
     element.FinishDate
     element.FinishState
     */
    
    NSString *editURL = [NSString stringWithFormat:@"%@EditElement?token=%@", BasicURL, _currentUser.token];
    NSDictionary *elementDict = [element toDictionary];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:elementDict , @"element", nil];
    
    AFHTTPRequestOperationManager *operationManager = [AFHTTPRequestOperationManager manager];
    
    AFJSONRequestSerializer *serializer = [AFJSONRequestSerializer serializer];
    
    [serializer setTimeoutInterval:20];
    [serializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [serializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    operationManager.requestSerializer = serializer;
    
    
    //AFJSONResponseSerializer *jsonSerializer = [AFJSONResponseSerializer serializer];
    
    AFHTTPRequestOperation *postOperation = [operationManager POST:editURL
                                                        parameters:params
                                                           success:^(AFHTTPRequestOperation *operation, id responseObject)
                                             {
                                                 if(completionBlock) completionBlock(responseObject, nil);
                                             }
                                                           failure:^(AFHTTPRequestOperation *operation, NSError *error)
                                             {
                                                 if(completionBlock) completionBlock(nil, error);
#ifdef DEBUG
                                                 NSLog(@" editElement: Error: %@", error.description);
#endif
                                             }];
    
    [postOperation start];
    
}

-(void) passElement:(Element *)element toUserID:(NSNumber *) userID forDeletion:(BOOL)deletion withCompletion:(networkCompletionBlock) completionBlock
{
    // "PassElement?elementId={elementId}&userPassTo={userPassTo}&token={token}" POST
    NSInteger elementIdInteger = element.elementId.integerValue;
    if (deletion)
    {
        elementIdInteger *= -1;
    }
    NSString *passWhomURL = [NSString stringWithFormat:@"%@PassElement?token=%@&elementId=%@&userPassTo=%@", BasicURL, _currentUser.token, @(elementIdInteger), userID];
    
    AFHTTPRequestOperationManager *operationManager = [AFHTTPRequestOperationManager manager];
    
    AFJSONRequestSerializer *serializer = [AFJSONRequestSerializer serializer];
    
    [serializer setTimeoutInterval:10];
    [serializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [serializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    operationManager.requestSerializer = serializer;
    
    AFHTTPRequestOperation *postOperation = [operationManager POST:passWhomURL
                                                        parameters:nil
                                                           success:^(AFHTTPRequestOperation *operation, id responseObject)
                                             {
                                                 if(completionBlock) completionBlock(responseObject, nil);
                                             }
                                                           failure:^(AFHTTPRequestOperation *operation, NSError *error)
                                             {
                                                 if(completionBlock) completionBlock(nil, error);
                                             }];
    
    [postOperation start];
    
}


-(void) passElement:(Element *)element toSeveralUserIDs:(NSArray *)userIDs withCompletion:(networkCompletionBlock)completionBlock;
{
    if (!element || !userIDs || userIDs.count < 1)
    {
        NSError *error = [NSError errorWithDomain:@"Check new chat" code:876 userInfo:nil];
        if (completionBlock)
            completionBlock(nil, error);
        return;
    }
    
    [[[NSOperationQueue alloc] init] addOperationWithBlock:^
    {
        NSMutableArray *failedIDs = [@[] mutableCopy];
        
        for (NSNumber *lvUserId in userIDs)
        {
            NSURL *addContactToChatURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@PassElement?token=%@&elementId=%@&userPassTo=%@", BasicURL, [ServerRequester sharedRequester].currentUser.token, element.elementId, lvUserId]];
            
            NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:addContactToChatURL];
            [postRequest setHTTPMethod:@"POST"];
            NSError *lvError;
            NSURLResponse *lvResponse;
            
            NSData *lvResponseData = [NSURLConnection sendSynchronousRequest:postRequest returningResponse:&lvResponse error:&lvError];
            if (!lvError)
            {
                NSDictionary *lvServerResponse = [NSJSONSerialization JSONObjectWithData:lvResponseData options:NSJSONReadingMutableContainers error:&lvError];
                
                if (!lvServerResponse || lvServerResponse.allKeys.count > 0)
                {
                    [failedIDs addObject:lvUserId];
                }
            }
        }
        
        if (completionBlock)
        {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^
            {
                completionBlock(@{@"failedIDs":failedIDs},nil);
            }];
        }
    }];
}

-(void) deleteElement:(Element *)element withCompletion:(networkCompletionBlock)completionBlock
{
    // "DeleteElement?elementId={elementId}&token={token}" POST
}

-(void) setFavouriteElement:(Element *)element withComletion:(networkCompletionBlock)completionBlock
{
    // "SetFavoriteElement?elementId={elementId}&token={token}" POST
    
    NSString *favURL = [NSString stringWithFormat:@"%@SetFavoriteElement?elementId=%@&token=%@", BasicURL, element.elementId, _currentUser.token];
    AFHTTPRequestOperationManager *operationManager = [AFHTTPRequestOperationManager manager];
    
    AFJSONRequestSerializer *serializer = [AFJSONRequestSerializer serializer];
    
    [serializer setTimeoutInterval:10];
    [serializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [serializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    operationManager.requestSerializer = serializer;
    
    
    //AFJSONResponseSerializer *jsonSerializer = [AFJSONResponseSerializer serializer];
    
    AFHTTPRequestOperation *postOperation = [operationManager POST:favURL
                                                        parameters:nil
                                                           success:^(AFHTTPRequestOperation *operation, id responseObject)
                                             {
                                                 if(completionBlock) completionBlock(responseObject, nil);
                                             }
                                                           failure:^(AFHTTPRequestOperation *operation, NSError *error)
                                             {
                                                 if(completionBlock) completionBlock(nil, error);
                                             }];
    
    [postOperation start];
    
}

-(void) setElementFinished:(Element *) element withCompletion:(networkCompletionBlock) completionBlock
{
    // "SetFinished?elementId={elementId}&date={date}&token={token}" POST
}

-(void) setRemindMeDate:(Element *)element withCompletion:(networkCompletionBlock)completionBlock
{
    //"SetEvent?elementId={elementId}&date={date}&token={token}"  POST
}

-(void) setFinishState:(NSNumber *)stane forElement:(Element *)element withCompletion:(networkCompletionBlock)completionBlock
{
    // "SetFinishState?elementId={elementId}&finishState={finishState}&token={token}" POST
}

-(void) loadPassWhomIDsForElementId:(NSNumber *)elementId completion:(networkCompletionBlock) completionBlock
{
    //GetPassWhom?elementId=%@&token=%@
    
    NSString *requestPassIDsString = [NSString stringWithFormat:@"%@GetPassWhomIds?elementId=%@&token=%@", BasicURL, elementId, _currentUser.token];
    
    [[[AFHTTPRequestOperationManager manager] GET:requestPassIDsString
                                       parameters:nil
                                          success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        //GetPassWhomIdsResult
        
        /*
         {
            GetPassWhomIdsResult =  (
                10,
                12
            );
         }
         */
        
        if (completionBlock)
        {
            [[ServerRequester sharedRequester].backGroundQueue addOperationWithBlock:^
            {
                if ([responseObject isKindOfClass:[NSDictionary class]])
                {
                    NSArray *recievedIDs = [responseObject objectForKey:@"GetPassWhomIdsResult"];
                    if (recievedIDs)
                    {
                        completionBlock(@{@"iDs":recievedIDs},nil);
                    }
                    else
                        completionBlock(@{@"iDs":@[]}, nil);
                    
                }
                else
                    completionBlock(@{@"iDs":@[]},nil);
            }];
        }
    }
                                          failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        if (completionBlock)
        {
            
        }
    }] start];
    
}

#pragma mark Attaches
-(void) getAttachesListForElementId:(NSNumber *)elementId withCompletion:(networkCompletionBlock) completionBlock
{
    //"GetElementAttaches?elementId={elementId}&token={token}"
    NSString *urlString = [NSString stringWithFormat:@"%@GetElementAttaches?elementId=%@&token=%@", BasicURL, elementId, _currentUser.token];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFHTTPRequestOperation *attachesOp = [manager GET:urlString
                                           parameters:nil
                                              success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        
        if (completionBlock)
        {
            
            dispatch_queue_t backGroundQueue = dispatch_queue_create("attachInserter", DISPATCH_QUEUE_CONCURRENT);
            dispatch_async(backGroundQueue, ^
                           {
                               NSArray *attachDicts = [(NSDictionary *)responseObject objectForKey:@"GetElementAttachesResult"];
                               if (attachDicts && attachDicts.count > 0)
                               {
                                   NSArray *attachObjects = [self convertDictionariesToAttaches:attachDicts];
                                   
                                   //filter recieved attaches to exclude duplicate entries
                                   NSMutableArray *filtered = [@[] mutableCopy];
                                   NSMutableArray *existingAttaches = [DataSource sharedInstance].attaches;
                                   
                                   for (AttachFile *lvNewAttach in attachObjects)
                                   {
                                       BOOL shouldInsert = YES;
                                       for (AttachFile *lvExistingAttach in existingAttaches)
                                       {
                                           if (lvExistingAttach.attachID.integerValue == lvNewAttach.attachID.integerValue)
                                           {
                                               shouldInsert = NO;
                                               break;
                                           }
                                       }
                                       if (shouldInsert)
                                       {
                                           [filtered addObject:lvNewAttach];
                                       }
                                   }
                                   
                                   NSInteger count = [[DataSource sharedInstance] countOfAttaches];
                                   NSRange attachesRange = NSMakeRange(count, filtered.count);
                                   NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:attachesRange];
                                   
                                   [[DataSource sharedInstance] insertAttaches:filtered atIndexes:indexSet];
                               }
//                               else
//                               {
//                                   NSLog(@"No Attaches For Element ID: %@", elementId);
//                               }
                           });
           
            
            
        }
        
        
    }
                                              failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        if (completionBlock)
        {
            completionBlock(nil, error);
        }
    }];
    
    [attachesOp start];
}

-(void) attachFile:(NSData *)fileData withName:(NSString *)fileName toElementWithId:(NSNumber *)elementId completion:(networkCompletionBlock)completionBlock
{
    //"AttachFileToElement?elementId={elementId}&fileName={fileName}&token={token}"
    
//    NSInteger postLength = fileData.length;
    //NSLog(@"uploadNewAvatar: Sending %ld bytes", (long)postLength);
    NSString *photoUploadURL = [NSString stringWithFormat:@"%@AttachFileToElement?elementId=%@&fileName=%@&token=%@", BasicURL, elementId, fileName, _currentUser.token];
    
    NSMutableURLRequest *mutableRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:photoUploadURL]];
    [mutableRequest setHTTPMethod:@"POST"];
    
    [mutableRequest setHTTPBody:fileData];
    
    [NSURLConnection sendAsynchronousRequest:mutableRequest
                                       queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
     {
         if (completionBlock)
         {
             if (data)
             {
                 NSDictionary *responseDict = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                 if (responseDict)
                 {
                     completionBlock(responseDict, nil);
                 }
                 else
                 {
                     NSError *lvError = [NSError errorWithDomain:@"File uploading failure" code:NSKeyValueValidationError userInfo:@{NSLocalizedDescriptionKey:@"Wrong request format"} ];
                     completionBlock(nil, lvError);
                 }
             }
             else if (connectionError)
             {
                 //NSLog(@"Eror sending photo: %@", connectionError);
                 completionBlock(nil, connectionError);
             }
         }
     }];
}

-(void) loadAttachFileDataForFileId:(NSNumber *)attachId completion:(networkCompletionBlock)completionBlock
{
    //"GetAttachedFile?fileId={fileId}&token={token}"
    NSString *fileRequestURL = [NSString stringWithFormat:@"%@GetAttachedFile?fileId=%@&token=%@", BasicURL, attachId, _currentUser.token];
    NSURL *requestURL = [NSURL URLWithString:fileRequestURL];
    
    NSMutableURLRequest *fileRequest = [NSMutableURLRequest requestWithURL:requestURL];
    [fileRequest setHTTPMethod:@"GET"];
    
    [NSURLConnection sendAsynchronousRequest:fileRequest
                                       queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
     {
         //NSLog(@"Response: \r %@", response);
         if (completionBlock)
         {
             if (!connectionError)
             {
                 if (data.length > 0)
                 {
                     NSError *jsonError;
                     id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
                     
                     if (jsonObject)
                     {
                         if ([(NSDictionary *)jsonObject objectForKey:@"GetAttachedFileResult"] != [NSNull null])
                         {
                             NSArray *result = [(NSDictionary *)jsonObject objectForKey:@"GetAttachedFileResult"];
                             
                             NSData *fileData = [NSData dataFromIntegersArray:result];
                             
                             
                             if (fileData)
                             {
                                 NSDictionary *fileDict = @{@"fileData" : fileData};
                                 completionBlock(fileDict, nil);
                             }
                             else
                             {
                                 NSError *lvError = [NSError errorWithDomain:@"File Loading failure"
                                                                        code:NSKeyValueValidationError
                                                                    userInfo:@{NSLocalizedDescriptionKey:@"Could not convert to NSData object"}];
                                 completionBlock(nil, lvError);
                             }
                             
                         }
                         else
                         {
                             NSError *lvError = [NSError errorWithDomain:@"File Loading failure"
                                                                    code:NSKeyValueValidationError
                                                                userInfo:@{NSLocalizedDescriptionKey:@"No File for Element"}];
                             completionBlock(nil, lvError);
                         }
                     }
                     else
                     {
                         NSError *lvError = [NSError errorWithDomain:@"File Loading failure"
                                                                code:NSKeyValueValidationError
                                                            userInfo:@{NSLocalizedDescriptionKey:@"Wrong response object"}];
                         completionBlock(nil, lvError);
                     }
                     
                 }
                 else
                 {
                     NSError *lvError = [NSError errorWithDomain:@"File Loading failure"
                                                            code:NSKeyValueValidationError
                                                        userInfo:@{NSLocalizedDescriptionKey:@"Wrong data format"} ];
                     completionBlock(nil, lvError);
                 }
             }
             else
             {
                 completionBlock(nil, connectionError);
             }
         }
         
     }];
}

-(void) removeAttachedFileWithName:(NSString *)fileName frolElementWithId:(NSNumber *)elementId completion:(networkCompletionBlock)completionBlock
{
    //"RemoveFileFromElement?elementId={elementId}&fileName={fileName}&token={token}"
    NSString *removeURL = [NSString stringWithFormat:@"%@RemoveFileFromElement?elementId=%@&fileName=%@&token=%@", BasicURL, elementId, fileName, _currentUser.token];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFHTTPRequestOperation *removeOp = [manager GET:removeURL
                                         parameters:nil
                                            success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        if (completionBlock)
        {
            NSDictionary *response = [(NSDictionary *)responseObject objectForKey:@"RemoveFileFromElementResult"];
            completionBlock(response, nil);
        }
    }
                                            failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        if (completionBlock)
        {
            completionBlock(nil, error);
        }
    }];
    
    [removeOp start];
}
#pragma mark - VideoAnimation
-(void) getRandomVideoWithCompletion:(networkCompletionBlock) completionBlock
{
    NSString *randomVideoUrlString = [NSString stringWithFormat:@"%@GetRandMovie", BasicURL];
    NSURL *randomVideoURL = [NSURL URLWithString:randomVideoUrlString];
//    NSMutableURLRequest *getRequest = [NSMutableURLRequest requestWithURL:randomVideoURL
//                                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
//                                                          timeoutInterval:15.0];
    
    NSURLSessionConfiguration *lvConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:lvConfig];
    
//    //test download
//    NSURLSessionDownloadTask *videoDownload = [session downloadTaskWithRequest:getRequest completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error)
//    {
//        if (location)
//        {
//            if (completionBlock)
//            {
//                completionBlock(@{@"url":location}, nil);
//            }
//        }
//        
//    }];
    
//    [videoDownload resume];
    //test data
    NSURLSessionDataTask *videoDataTask =
    [session dataTaskWithURL:randomVideoURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        NSError *lvJSON_Error;
        NSDictionary *resultData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&lvJSON_Error];
        if (resultData && [resultData objectForKey:@"GetRandMovieResult"] != nil)
        {
            NSArray *videoBytes = [resultData objectForKey:@"GetRandMovieResult"];
            
            NSData *videoData = [NSData dataFromIntegersArray:videoBytes];
            FileHandler *lvFileHandler = [[FileHandler alloc] init];
            /*NSString *tempVideoURL = */[lvFileHandler saveTempVideoToDisk:videoData completionPath:^(NSString *path) {
                if (path != nil)//successfully created(rewrote) video file in Documents directory
                {
                    if (completionBlock)
                    {
                        completionBlock(@{@"url":path}, nil);
                    }
                }
                else//some error while saving to DocsDirectory
                {
                    if (completionBlock)
                    {
                        completionBlock(nil, nil);
                    }
                }
            }];
            
           
        }
        else
        {
            //some error while downloading
            if (completionBlock) {
                completionBlock(nil, nil);
            }
        }
    }];
    
    [videoDataTask resume];
    
}
#pragma mark - TrendWords (Echo)
-(void) getListOfTrendWordsWithCompletion:(networkCompletionBlock) completionBlock
{

    NSString *token = self.currentUser.token;
    NSString *querryURL = [NSString stringWithFormat:@"%@GetEcho", BasicURL];
    if (token)
    {
        NSDictionary *lvParams = [NSDictionary dictionaryWithObject:token forKey:@"token"];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        AFHTTPRequestOperation *trendWordsOp =
        [manager GET:querryURL
          parameters:lvParams
             success:^(AFHTTPRequestOperation *operation, id responseObject)
        {
            [[[NSOperationQueue alloc] init] addOperationWithBlock:^
             {
                 NSArray *echoesArray = [(NSDictionary *)responseObject objectForKey:@"GetEchoResult"];
                 if (echoesArray && echoesArray.count > 0)
                 {
                     NSArray *echoesObjects = [self convertDictionariesToWordEchoes:echoesArray];
                     [DataSource sharedInstance].echoes = [NSMutableArray arrayWithArray:echoesObjects];
                     
                     if (completionBlock)
                     {
                         [[NSOperationQueue mainQueue] addOperationWithBlock:^
                          {
                              if (echoesObjects)
                                  completionBlock(@{}, nil);
                              else
                                  completionBlock(nil, nil);
                          }];
                     }
                    
                 }
            }];
        }
             failure:^(AFHTTPRequestOperation *operation, NSError *error)
        {
            if (completionBlock)
            {
                NSString *failureString = operation.responseString;
                if (failureString) //we have some message from server
                {
                    NSError *lvError = [NSError errorWithDomain:@"Echo Request Failure" code:100501 userInfo:@{NSLocalizedDescriptionKey:failureString}];
                    completionBlock(nil, lvError);
                }
                else
                {
                    completionBlock(nil, error);
                }
            }
        }];
        [trendWordsOp start];
    }
    else
    {
        if (completionBlock)
        {
            NSError *lvNoTokenError = [NSError errorWithDomain:@"Failed token." code:100500 userInfo:@{NSLocalizedDescriptionKey:@"User token not found."}];
            completionBlock(nil, lvNoTokenError);
        }
    }
}

-(void) getTrendLinkedWordsForWord:(NSString *)searchWord withCompletion:(networkCompletionBlock) completionBlock
{
    NSString *token = self.currentUser.token;
    if (searchWord && searchWord.length > 0 && token && token.length > 0)
    {
        NSString *querryURL = [NSString stringWithFormat:@"%@GetLinkedWords", BasicURL];//, searchWord, token];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        AFHTTPRequestOperation *linkedWordsOp =
        [manager GET:querryURL
          parameters:@{@"word":searchWord, @"token":token}
             success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             
             if (completionBlock)
             {
                 [[[NSOperationQueue alloc] init] addOperationWithBlock:^
                  {
                      NSArray *echoesArray = [(NSDictionary *)responseObject objectForKey:@"GetLinkedWordsResult"];
                      if (echoesArray && echoesArray.count > 0)
                      {
                          [[NSOperationQueue mainQueue] addOperationWithBlock:^
                           {
                               completionBlock(@{searchWord:echoesArray}, nil);
                           }];
                      }
                      else
                          completionBlock(@{}, nil);
                  }];
             }
             
         }
             failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             if (completionBlock)
             {
                 NSString *failureString = operation.responseString;
                 if (failureString) //we have some message from server
                 {
                     NSError *lvError = [NSError errorWithDomain:@"Linked Words Request Failure" code:100503 userInfo:@{NSLocalizedDescriptionKey:failureString}];
                     completionBlock(nil, lvError);
                 }
                 else
                 {
                     completionBlock(nil, error);
                 }
             }
         }];
        [linkedWordsOp start];
    }
    else
    {
        if (completionBlock)
        {
            NSError *lvError = [NSError errorWithDomain:@"GetLinkedWords failure" code:100502 userInfo:@{NSLocalizedDescriptionKey:@"Unknown word or missing user token."}];
            completionBlock(nil, lvError);
        }
    }
}

#pragma mark - test
-(void) testRequestWithParams:(NSDictionary *)params completion:(networkCompletionBlock) completionBlock
{
        NSString *urlString = [NSString stringWithFormat:@"%@EditTest",BasicURL];
//    NSDictionary *toMakeData = @{@"data":@{@"str":@"659565"}};
//    
//    NSError *lvError;
//    id  json = [NSJSONSerialization dataWithJSONObject:toMakeData options:NSJSONWritingPrettyPrinted error:&lvError];
//    if (!lvError)
//    {
//        NSData *jsonData = (NSData *)json;
//        NSString *jsonString = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
//        NSLog(@"STRING: %@", jsonString);
//    }
    
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        AFJSONRequestSerializer *serializer = [AFJSONRequestSerializer serializer];
    
        [serializer setTimeoutInterval:10];
        [serializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [serializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
        manager.requestSerializer = serializer;
    
    
        AFJSONResponseSerializer *jsonSerializer = [AFJSONResponseSerializer serializer];
        [jsonSerializer.acceptableContentTypes setByAddingObjectsFromArray:@[@"text/html", @"appliaction/json"] ];
        manager.responseSerializer = jsonSerializer;
    
        AFHTTPRequestOperation *postEditOp = [manager POST:urlString
                                                parameters: @{@"user":[NSNumber numberWithInteger:4]}
                                                   success:^(AFHTTPRequestOperation *operation, id responseObject)
        {
            if (completionBlock)
            {
                completionBlock(responseObject,nil);
            }
        }
                                                   failure:^(AFHTTPRequestOperation *operation, NSError *error)
        {
            if (error.description)
            {
                //NSLog(@"%@", error.description);
            }
            if (completionBlock)
            {
                completionBlock(nil,error);
            }
        }];
        
        [postEditOp start];
    
}
#pragma mark - Social Networks
#pragma mark Twitter
-(void)tryToRequestTwitterInfoWithResult:(void (^)(NSDictionary *result))requestResultBlock
{
    //show activity to user
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    ACAccountStore *account = [[ACAccountStore alloc] init]; // Creates AccountStore object.
    
    // Asks for the Twitter accounts configured on the device.
    
    ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [account requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error)
     {
         // If we have access to the Twitter accounts configured on the device we will contact the Twitter API.
         if (granted == YES)
         {
             NSArray *arrayOfAccounts = [account accountsWithAccountType:accountType]; // Retrieves an array of Twitter accounts configured on the device.
             
             // If there is a least one account we will contact the Twitter API.
             
             if ([arrayOfAccounts count] > 0)
             {
                 
                 ACAccount *twitterAccount = [arrayOfAccounts firstObject]; // Sets the last account on the device to the twitterAccount variable.
                 
                 NSURL *requestUserInfo = [NSURL URLWithString:@"https://api.twitter.com/1.1/users/show.json"];
                 NSDictionary *requestParameters = [NSDictionary dictionaryWithObject:twitterAccount.username forKey:@"screen_name"];
                 //or@{@"count":@"100", @"include_entities":@"1"}
                 
                 // This is where we are getting the data using SLRequest.
                 //SLRequest *posts = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:requestAPI parameters:  @{@"count":@"1", @"include_entities":@"0"}]; //parameters];
                 SLRequest *userDataRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                                 requestMethod:SLRequestMethodGET
                                                                           URL:requestUserInfo
                                                                    parameters:requestParameters];
                 
                 userDataRequest.account = twitterAccount;
                 
                 
                 [userDataRequest performRequestWithHandler:
                  
                  ^(NSData *response, NSHTTPURLResponse
                    *urlResponse, NSError *error)
                  {
                      if (response)
                      {
                          // The NSJSONSerialization class is then used to parse the data returned and assign it to our array.
                          [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                          
                          NSDictionary *userDict = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:&error];
                          
                          if (userDict.allKeys.count > 0)
                          {
                              //proceed if we have a reason
                              if (requestResultBlock)
                              {
                                  if (userDict[@"errors"])
                                  {
                                      
                                      [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                      dispatch_async(dispatch_get_main_queue(), ^
                                                     {
                                                         
                                                         [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                                         [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Some problems with Twitter. Make sure that your account is active." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil]  show];
                                                     });
                                      return;
                                  }
                                  
                                  
                                  //NSLog(@"\nLogin Controller Twitter Data:\n%@",[userDict description]);
                                  NSString *originalImageURL = [userDict  objectForKey:@"profile_image_url_https"]; //in twitter response
                                  
                                  NSString *userImageUrl =  [ originalImageURL stringByReplacingOccurrencesOfString:@"_normal" withString:@""];
                                  NSString *userScreenName = [userDict objectForKey:@"screen_name"]; //in twitter response
                                  NSString *userAboutMe = userDict[@"description"];
                                  NSString *countryName = [userDict objectForKey:@"location"];
                                  NSString *languageName = [userDict objectForKey:@"lang"];
                                  NSString *firstName = [userDict objectForKey:@"name"];
                                  
                                  
                                  NSDictionary *completionBlockDict = NSDictionaryOfVariableBindings( userImageUrl, userScreenName, userAboutMe, countryName, languageName, firstName);
                                  
                                  //not main queue
                                  requestResultBlock(completionBlockDict);
                              }
                             
                          }
                      }
                      else
                      {
                          //NSLog(@"\nTryToRequest Twitter Info = Error = \n%@", [error description]);
                          if (requestResultBlock)
                          {
                              requestResultBlock(nil);
                          }
                      }
                      
                  }];
             }
             else
             {
                 [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                 dispatch_async(dispatch_get_main_queue(), ^
                                {
                                
                                    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"You have no Twitter account set. Please set up Twitter account in Settings." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil]  show];
                                });
                 if (requestResultBlock)
                 {
                     requestResultBlock(nil);
                 }
             }
         }
         else
         {
             [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
             dispatch_async(dispatch_get_main_queue(), ^
                            {
                                //[self showCustomActivityIndicator:NO];
                                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"You have not granted access to your Twitter account for KARA app." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil]  show];
                            });
             if (requestResultBlock)
             {
                 requestResultBlock(nil);
             }
         }
     }];
}

#pragma mark Facebook
-(void)tryToRequestFacebookInfoWithResult:(void (^)(NSDictionary *))requestResultBlock
{
    //[FBSDKSettings enableLoggingBehavior:FBSDKLoggingBehaviorNetworkRequests];
    
    FBSDKAccessToken *lvCurrentAccessToken = [FBSDKAccessToken currentAccessToken];
    if (lvCurrentAccessToken)
    {
        [self fetchFacebookUserInfoWithCompletion:^(NSDictionary *successResponse, NSError *error) {
            
        }];
    }
    else
    {
        FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
        [login logInWithReadPermissions:@[@"email"] handler:^(FBSDKLoginManagerLoginResult *result, NSError *error)
        {
            if (error)
            {
                // Process error
            }
            else if (result.isCancelled)
            {
                // Handle cancellations
            }
            else
            {
                // If you ask for multiple permissions at once, you
                // should check if specific permissions missing
                if ([result.grantedPermissions containsObject:@"email"])
                {
                    // Do work
                }
            }
        }];
    }
}

-(void) fetchFacebookUserInfoWithCompletion:(networkCompletionBlock)completion
{
    FBSDKAccessToken *lvCurrentAccessToken = [FBSDKAccessToken currentAccessToken];
    NSString *currentUserID = lvCurrentAccessToken.userID;
    FBSDKGraphRequest *lvInfoRequest = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil];
    [lvInfoRequest startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error)
     {
         if (error)
         {
             
         }
         else
         {
//             NSLog(@"\r - FacebookLoginResult: \r%@", ((NSDictionary *)result).description);
         }
     }];
    
    NSString *userImageRequestString = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=square&width=400&height=400", currentUserID];
    NSURLRequest *userImageRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:userImageRequestString]];
    NSOperationQueue *bgImageQueue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:userImageRequest queue:bgImageQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
     {
         if (connectionError)
         {
             
         }
         else
         {
             UIImage *userProfileImage = [UIImage imageWithData:data];
             if (userProfileImage)
             {
                 [ServerRequester sharedRequester].currentUser.photo = data;
             }
         }
     }];
}

#pragma mark - tools
-(NSArray *)messageDictionariesToMessages:(NSArray *)messageDictionaries
{
    NSMutableArray *messageObjects = [NSMutableArray arrayWithCapacity:messageDictionaries.count];
    Contact *lvKara = [[DataSource sharedInstance] getKaraContact];
    User *lvCurrentUser = [[DataSource sharedInstance] getCurrentUser];
    
    
    //temporary store reference to last ranging question
    //Message *lastType9Question;
    for (NSDictionary *dict in messageDictionaries)
    {
        
        Message *message = [[Message alloc] initWithParams:dict];
        //NSLog(@"\r - DateCreated: %@", message.dateCreated);
        if (message.elementId.integerValue == lvKara.elementId.integerValue || (message.creatorId.integerValue == lvKara.contactId.integerValue || message.creatorId.integerValue == lvCurrentUser.userID.integerValue))
        {
            if (message.typeId.integerValue == 0 || message.typeId.integerValue == 4 || message.typeId.integerValue == 10 || message.typeId.integerValue == 12)
            {
                 continue;
            }
            else if (message.typeId.integerValue == 7)
            {
                //NSLog(@"\r - Recieved words ASSOTIATION: %@\n", message.textBody);
                message.textBody = [message.textBody stringByAppendingString:@"?"];
            }
            else if (message.typeId.integerValue == 8)
            {
                //NSLog(@"\r - Recieved words CONNECTION question: %@\n", message.textBody);
                NSMutableString *textToEdit = [message.textBody mutableCopy];
                //WhatInCommon
                [textToEdit replaceOccurrencesOfString:@"," withString:NSLocalizedString(@"spaceANDspace", nil) options:0 range:NSMakeRange(0, textToEdit.length)];
                [textToEdit appendFormat:@". %@", NSLocalizedString(@"WhatInCommon", nil)];
                message.textBody = textToEdit;
               // lastType9Question = message;
            }
            else if (message.typeId.integerValue == 9)
            {
#ifdef DEBUG
                NSLog(@"\r - Recieved words RANGING question: %@\n", message.textBody);
#endif
                NSMutableString *textToEdit = [message.textBody mutableCopy];
                [textToEdit replaceOccurrencesOfString:@"," withString:NSLocalizedString(@"spaceANDspace", nil) options:0 range:NSMakeRange(0, textToEdit.length)];
                [textToEdit appendFormat:@". %@", NSLocalizedString(@"WhatImportant", nil)];
                message.textBody = textToEdit;
                //lastType9Question = message;
            }
            else if (message.typeId.integerValue == 13)
            {
//                NSLog(@"\r - Recieved USER PHOTO CHANGED message: %@", [message toStoredDictionary]);
                continue;
            }
            else if (message.typeId.integerValue == 14)
            {
                NSMutableString *messageText = [message.textBody mutableCopy];
                [messageText replaceOccurrencesOfString:@"," withString:NSLocalizedString(@"dashIs", nil) options:NSCaseInsensitiveSearch range:NSMakeRange(0, messageText.length)];
                [messageText appendString:@"?"];
                message.textBody = messageText;
            }
            else if (message.typeId.integerValue == 11)
            {
                //NSLog(@"\r - Recieved CHANGE MOOD ANIMATION message: %@", message.textBody);
                
                NSInteger emotionCode = message.textBody.integerValue;
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"Change_Mood"
                                                                    object:[ServerRequester sharedRequester]
                                                                  userInfo:@{@"newMood":@(emotionCode)}];
                continue;
            }
        }
        [messageObjects addObject:message];
    }
    return messageObjects;
}

-(NSArray *) convertDictionariesToElements:(NSArray *)elementsDisctionaries
{
    NSMutableArray *elementObjects = [NSMutableArray arrayWithCapacity:elementsDisctionaries.count];
    for (NSDictionary *dict in elementsDisctionaries)
    {
        Element *element = [[Element alloc] initWithInfo:dict];
        [elementObjects addObject:element];
    }
    return elementObjects;
}

-(NSArray *) convertContactsDictionariesToContactObjects:(NSArray *)dictionaries;
{
    NSMutableArray *contactObjects = [@[] mutableCopy];
    NSMutableArray *invalidContacts = [NSMutableArray arrayWithCapacity:1];
    for (NSDictionary *contactDict in dictionaries)
    {
        Contact *lvContact = [[Contact alloc] initWithParameters:contactDict];
        if ([lvContact.loginName isEqualToString:@"K.A.R.A."])
        {
            [contactObjects addObject:lvContact];
        }
        else
        {
            [invalidContacts addObject:lvContact];
        }
    }
    for (Contact *lvInvalidContact in invalidContacts)
    {
        [[ServerRequester sharedRequester] removeContactWithId:lvInvalidContact.contactId comletion:^(NSDictionary *successResponse, NSError *error) {
//            if (successResponse)
//            {
////                NSLog(@"\n%@", successResponse.description);
//            }
//            if (error)
//            {
//                NSLog(@"\n %@", error.localizedDescription);
//            }
        }];
    }
    return contactObjects;
}

-(NSArray *) convertDictionariesToAttaches:(NSArray *)dictArray
{
    NSMutableArray *attaches = [NSMutableArray arrayWithCapacity:dictArray.count];
    
    for (NSDictionary *attachDict in dictArray)
    {
        AttachFile *attachFile = [[AttachFile alloc] initWithInfo:attachDict];
        [attaches addObject:attachFile];
    }
    return attaches;
}

-(NSArray *) convertDictionariesToLanguageObjects:(NSArray *)dictArray
{
    NSMutableArray *languageObjects = [NSMutableArray arrayWithCapacity:dictArray.count];
    for (NSDictionary *languageDict in dictArray)
    {
        LanguageObject *lvLanguage = [[LanguageObject alloc] initWithInfo:languageDict];
        if (lvLanguage)
        {
            [languageObjects addObject:lvLanguage];
        }
    }
    if (languageObjects.count > 0)
    {
        return languageObjects;
    }
    return nil;
}

-(NSArray *) convertDictionariesToCountries:(NSArray *)dictArray
{
    NSMutableArray *countryObjects = [NSMutableArray arrayWithCapacity:dictArray.count];
    for (NSDictionary *countryDict in dictArray)
    {
        CountryObject *lvCountry = [[CountryObject alloc] initWithInfo:countryDict];
        if (lvCountry)
        {
            [countryObjects addObject:lvCountry];
        }
    }
    
    if (countryObjects.count > 0)
    {
        return countryObjects;
    }
    return nil;
}

-(NSArray *) convertDictionariesToWordEchoes:(NSArray *)dictArray
{
    NSInteger count = dictArray.count;
    NSMutableArray *echoesArray = [[NSMutableArray alloc] initWithCapacity:count];
    for (NSDictionary *lvEchoDict in dictArray)
    {
        WordEcho *lvEcho = [[WordEcho alloc] initWithInfo:lvEchoDict];
        if (lvEcho)
        {
            [echoesArray addObject:lvEcho];
        }
    }
    if (echoesArray.count < 1)
    {
        return nil;
    }
    
    if (echoesArray.count < 11)
    {
        return echoesArray;
    }
    
    [echoesArray sortedArrayUsingComparator:^NSComparisonResult(WordEcho *echo1, WordEcho *echo2)
    {
        return [echo1.ratingCount compare:echo2.ratingCount];
    }];
    
    NSArray *firstTenEchoes = [echoesArray subarrayWithRange:NSMakeRange(0, 10)];
    
    NSInteger echoesCount = firstTenEchoes.count;
    if (echoesCount > 0)
    {
        return firstTenEchoes;
    }
    
    return nil;
}

#pragma mark - 
-(NSString *)fixMessageBody:(NSString *)messageBody
{
    NSString *toReturn;
    
    NSRange fixType7Range = [messageBody rangeOfString:@"#07#"];
    if (fixType7Range.location != NSNotFound)
    {
        toReturn = [messageBody stringByReplacingCharactersInRange:fixType7Range withString:@""];
    }
    else
    {
        NSRange fixType8Range = [messageBody rangeOfString:@"#08#"];
        if (fixType8Range.location != NSNotFound)
        {
            toReturn = [messageBody stringByReplacingCharactersInRange:fixType8Range withString:@""];
            if ([toReturn isEqualToString:@"NНOИTЧHЕIГNОG"])
            {
                toReturn = NSLocalizedString(@"NНOИTЧHЕIГNОG", nil);
            }
        }
        else
        {
            NSRange fixType10Range = [messageBody rangeOfString:@"#10#"];
            if (fixType10Range.location != NSNotFound)
            {
                toReturn = [messageBody stringByReplacingCharactersInRange:fixType10Range withString:@""];
            }
        }
    }
    
    return toReturn;
}

-(NSMutableArray *) fixQuestionMessagesIsNewValues:(NSArray *)recievedMessages
{
    if (recievedMessages.count < 1)
    {
        return nil;
    }
    NSMutableArray *toReturn = [NSMutableArray arrayWithArray:recievedMessages];

    for (NSNumber * type in @[@(7), @(8), @(9), @(14)]) // add other question types to filter ou to datasourse`s .pendingQuestions
    {
        NSArray *lastQuestions = [toReturn filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"typeId == %@", type]] ;
        Message *lastMessage = lastQuestions.lastObject;
        if (lastMessage)
        {
            if (!lastMessage.isNew.boolValue)
            {
                lastMessage.isNew = @(YES);
            }
            [[DataSource sharedInstance].pendingQuestions addObject:lastMessage];
//            NSLog(@"%@", [lastMessage toStoredDictionary]);
            [toReturn removeObjectsInArray:lastQuestions];
        }
    }
    if ([DataSource sharedInstance].pendingQuestions.count > 0)
    {
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"LoadedNewMessages" object:[ServerRequester sharedRequester]];
        });
        
    }
    return toReturn;
}

-(BOOL) checkForIsNewQuestionsInMessages
{
    Message *isNewMessage = [[DataSource sharedInstance].messages filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isNew == 1"]].firstObject;
    if (isNewMessage)
    {
        return YES;
    }
    return NO;
}

-(LanguageObject *) checkUserLanguageFromDefaultAndSettings
{
    LanguageObject *lvDefaultLanguage;
    NSDictionary *lvChoosenLanguage = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserLanguage"];
    if (lvChoosenLanguage)
    {
        lvDefaultLanguage = [[LanguageObject alloc] initWithInfo:lvChoosenLanguage];
        if (lvDefaultLanguage.languageName.length > 0 && ![lvDefaultLanguage.languageId isKindOfClass:[NSNull class]])
        {

            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"UserLanguage"];//clear User defaults, we don`t need this info anymore.
        }
        else
        {
            NSString *langID = [[NSLocale preferredLanguages] objectAtIndex:0];
            
            if ([langID isEqualToString:@"ru"])
            {
                lvDefaultLanguage = [[DataSource sharedInstance] languageForDeviceLangID:langID];
            }
            else
            {
                lvDefaultLanguage = [[DataSource sharedInstance] languageForDeviceLangID:@"en"];
            }
        }
    }
    else
    {
        NSString *langID = [[NSLocale preferredLanguages] objectAtIndex:0];
        
        if ([langID isEqualToString:@"ru"])
        {
            lvDefaultLanguage = [[DataSource sharedInstance] languageForDeviceLangID:langID];
        }
        else
        {
            lvDefaultLanguage = [[DataSource sharedInstance] languageForDeviceLangID:@"en"];
        }
       
    }
    
    return lvDefaultLanguage;
}


@end

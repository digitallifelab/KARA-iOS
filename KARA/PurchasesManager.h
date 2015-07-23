//
//  PurchasesManager.h
//  Origami
//
//  Created by CloudCraft on 30.03.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

NSString  * const completeTransactionNotification;

@interface PurchasesManager : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>

@property (nonatomic, strong) NSMutableArray *restoredPurchases;

@property (nonatomic, strong) NSMutableArray *purchasedItems;

+(PurchasesManager *) defaultManager;

-(void) purchaseItemWithId:(NSString *)itemID;
-(void) restorePreviousPurchases;

@end

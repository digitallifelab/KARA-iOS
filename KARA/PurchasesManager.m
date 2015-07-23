//
//  PurchasesManager.m
//  Origami
//
//  Created by CloudCraft on 30.03.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import "PurchasesManager.h"

NSString  * const completeTransactionNotification = @"PurchaseManager_Finished_Notification";

@implementation PurchasesManager

#pragma mark - Public API
+(PurchasesManager *) defaultManager
{
    static PurchasesManager *singletoneInstance = nil;
    if (!singletoneInstance)
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            singletoneInstance = [[PurchasesManager allocWithZone:NULL] init];
        });
    }
    
    
    return singletoneInstance;
}

-(instancetype) init
{
    if (self = [super init])
    {
        self.purchasedItems = [[NSMutableArray alloc] initWithCapacity:0];
        self.restoredPurchases = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return self;
}

-(void) purchaseItemWithId:(NSString *)itemID
{
    NSLog(@"User requests test item");
    
    if([SKPaymentQueue canMakePayments])
    {
        NSLog(@"User can make payments");
        
        SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:itemID]];
        productsRequest.delegate = self;
        [productsRequest start];
        
    }
    else
    {
        NSLog(@"User cannot make payments due to parental controls");
        //this is called the user cannot make payments, most likely due to parental controls
    }
}

-(void) restorePreviousPurchases
{
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}


#pragma mark - private API

-(void) purchase:(SKProduct *)productToPurchase
{
    SKPayment *payment = [SKPayment paymentWithProduct:productToPurchase];
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}



#pragma mark  SKProductsRequestDelegate
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    SKProduct *validProduct = nil;
    NSInteger count = response.products.count;
    
    if(count > 0)
    {
        validProduct = [response.products objectAtIndex:0];
        NSLog(@"Products Available!");
        [self purchase:validProduct];
    }
    else if(!validProduct)
    {
        NSLog(@"No products available");
        //this is called if your product id is not valid, this shouldn't be called unless that happens.
        if (response.invalidProductIdentifiers)
        {
            for (NSString *invalidIdentifier in response.invalidProductIdentifiers)
            {
                NSLog(@"\n - Invalid Product identifier: %@", invalidIdentifier);
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:completeTransactionNotification object:nil userInfo:@{@"status":@(0)}];
        }
    }
}


#pragma mark  SKPaymentTransactionObserver
#pragma mark Restore
- (void) paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    NSLog(@"received restored transactions: %lu", (unsigned long)queue.transactions.count);
    for(SKPaymentTransaction *transaction in queue.transactions)
    {
        if(transaction.transactionState == SKPaymentTransactionStateRestored)
        {
            //called when the user successfully restores a purchase
            NSLog(@"Transaction state -> Restored");
            
            //[self doRemoveAds];
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            break;
        }
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    NSLog(@"Restore attempt failed with error: \n %@", error);
}

#pragma mark Update
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for(SKPaymentTransaction *transaction in transactions)
    {
        switch(transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchasing:
            {
                NSLog(@"Transaction state -> Purchasing");
                //called when the user is in the process of purchasing, do not add any of your own code here.
            }
                break;
            case SKPaymentTransactionStatePurchased:
            {
                //this is called when the user has successfully purchased the package (Cha-Ching!)
                // [self doRemoveAds]; //you can add your code for what you want to happen when the user buys the purchase here, for this tutorial we use removing ads
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                NSLog(@"Transaction state -> Purchased");
                [[NSNotificationCenter defaultCenter] postNotificationName:completeTransactionNotification object:self userInfo:@{@"status":@(1)}];
            }
                break;
            case SKPaymentTransactionStateRestored:
            {    NSLog(@"Transaction state -> Restored");
                //add the same code as you did from SKPaymentTransactionStatePurchased here
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            }
                break;
            case SKPaymentTransactionStateFailed:
            {
                //called when the transaction does not finnish
                if(transaction.error.code != SKErrorPaymentCancelled)
                {
                    NSLog(@"Transaction state -> Cancelled");
                    //the user cancelled the payment ;(
                }
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            }
                break;
            case SKPaymentTransactionStateDeferred:
            {
                NSLog(@"Transaction state -> Deferred");
            }
                break;
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HandlePurchase" object:self];
}

- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions
{
    NSLog(@"PurchasesManager PaymentQueue removedTransactions");
}

-(void) paymentQueue:(SKPaymentQueue *)queue updatedDownloads:(NSArray *)downloads
{
    /*
     SKDownloadStateWaiting,
     SKDownloadStateActive,
     SKDownloadStatePaused,
     SKDownloadStateFinished,
     SKDownloadStateFailed,
     SKDownloadStateCancelled,
     
     */
    
    for (SKDownload *lvDownload in downloads)
    {
        NSString *statusString;
        switch (lvDownload.downloadState)
        {
            case SKDownloadStateActive:
            {
                statusString = @"Download ACTIVE";
            }
                break;
            case SKDownloadStateCancelled:
            {
                statusString = @"Download CANCELLED";
            }
                break;
            case SKDownloadStatePaused:
            {
                statusString = @"Download PAUSED";
            }
                break;
            case SKDownloadStateWaiting:
            {
                statusString = @"Download WAITING";
            }
                break;
            case SKDownloadStateFinished:
            {
                statusString = @"Download FINISHED";
            }
                break;
            case SKDownloadStateFailed:
            {
                statusString = @"Download FAILED";
            }
                break;
            default:
                statusString = @"..Unknown..";
                break;
        }
        
        NSLog(@"\r  -Download identifier: %@ progress: %f%% , status: %@", lvDownload.contentIdentifier, lvDownload.progress *100, statusString);
    }
}




@end

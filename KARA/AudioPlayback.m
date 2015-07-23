//
//  AudioPlayback.m
//  TestChatApp
//
//  Created by CloudCraft on 13.03.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import "AudioPlayback.h"
#import <AVFoundation/AVFoundation.h>

@interface AudioPlayback ()

@property (nonatomic, strong) dispatch_queue_t playerQueue;

@property (nonatomic, strong) AVAudioPlayer *player;

@end



@implementation AudioPlayback

-(instancetype) initWithAudioURL:(NSURL *)fileURL error:(NSError **)error;
{
    if ((self = [super init]))
    {
        NSError *lvError;
        self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:&lvError];
        if (!lvError)
        {
//            [self.player prepareToPlay];
            self.playerQueue = dispatch_queue_create("player_queue", DISPATCH_QUEUE_SERIAL);
        }
    }
    return self;
}
-(void) dealloc
{
    self.playerQueue = nil;
    self.player = nil;
}

-(void) play
{
    dispatch_sync(self.playerQueue, ^
                  {
                      [self.player play];
                  });
    
}

-(void) playIndefinitely
{
//    dispatch_async(self.playerQueue, ^
//                  {
                      self.player.numberOfLoops = -1; //" Set any negative integer value to loop the sound indefinitely until you call the stop method. "
                      [self.player play];
//                  });
}

-(void) stop
{
//    dispatch_async(self.playerQueue, ^
//                  {
                      [self.player stop];
//                  });
    
}

- (void)setVolume:(float)volume duration:(float)duration completion:(void(^)(void))completion
{
    [self fadePlayer:self.player fromVolume:self.player.volume toVolume:volume overTime:duration completion:completion];
    //NSLog(@"to Volume: %f", volume);
}

- (BOOL)isPlaying
{
    return self.player.isPlaying;
}

-(BOOL) switchToNewTrackWithURL:(NSURL *)fileURL error:(NSError **)error
{
    __weak AudioPlayback *weakSelf = self;
    __block NSError *lvError;
    if (self.player.isPlaying)
    {
         [weakSelf.player stop];
         
         weakSelf.player = nil;
        
         weakSelf.player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:&lvError];
    }
    else
    {
        weakSelf.player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:&lvError];
    }
    
    
    if (!lvError)
    {
        [weakSelf.player prepareToPlay];
        return YES;
    }
    else
    {
        *error = lvError;
        return NO;
    }
}

-(BOOL) switchtoNewTrackWithData:(NSData *)fileData error:(NSError **)error
{
    __weak AudioPlayback *weakSelf = self;
    __block NSError *lvError;
    if (self.player.isPlaying)
    {
        [weakSelf.player stop];
        
        weakSelf.player = nil;
        
        weakSelf.player = [[AVAudioPlayer alloc] initWithData:fileData error:&lvError];
    }
    else
    {
        weakSelf.player = [[AVAudioPlayer alloc] initWithData:fileData error:&lvError];
    }
    
    if (!lvError)
    {
        [weakSelf.player prepareToPlay];
        return YES;
    }
    else
    {
        *error = lvError;
        return NO;
    }
}

- (void) fadePlayer:(AVAudioPlayer*)player fromVolume:(float)startVolume toVolume:(float)endVolume overTime:(float)time completion:(void(^)(void))completionBlock
{
    __weak AudioPlayback *weakSelf = self;
    if (time <= 0)
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), self.playerQueue, ^
        {
            weakSelf.player.volume = endVolume;
            //NSLog(@"Set New volume without fading");
            if (completionBlock)
                completionBlock();
        });
    }
    else
    {
        //NSLog(@"Started fading out");
        // Update the volume every 1/100 of a second
        float fadeSteps = time * 10.0;
        
        dispatch_sync(self.playerQueue, ^
                      {
                          player.volume = startVolume;
                      });
        
        
        for (int step = 0; step < fadeSteps; step++)
        {
            double delayInSeconds = step * (time / fadeSteps);
            
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, self.playerQueue, ^(void)
                           {
                               
                               if (step == fadeSteps - 1)
                               {
                                   player.volume = endVolume;
                                   if (completionBlock)
                                       completionBlock();
                               }
                               else
                               {
                                   float fraction = ((float)step / fadeSteps);
                                   
                                   player.volume = startVolume + (endVolume - startVolume) * fraction;
                               }
                               //NSLog(@"Final Volume: %.02f", player.volume);
                           });
        }
        //NSLog(@"Finished Fading Out");
    }
    
}
#pragma mark AudioPlayBackDelegate
- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    //NSLog(@"Audio Player did finish Playing with %@", (flag)?@"Success":@"NoSuccess");
    [self.delegate audioPlaybackLayer:self didFinishPlayingSuccessfully:flag];
}

-(void) audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    //NSLog(@" \r Error decoding audio: %@", error.description);
    [self.delegate audioPlaybackLayer:self decodingErrorOccured:error];
}




@end

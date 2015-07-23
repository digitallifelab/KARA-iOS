//
//  AudioPlayback.h
//  TestChatApp
//
//  Created by CloudCraft on 13.03.15.
//  Copyright (c) 2015 CloudCraft. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AudioPlayback;
@protocol AudioPlayBackDelegate <NSObject>

@optional
- (void) audioPlaybackLayer:(AudioPlayback *)playBackLayer didFinishPlayingSuccessfully:(BOOL)success;
- (void) audioPlaybackLayer:(AudioPlayback *)playBackLayer decodingErrorOccured:(NSError *)error;

@end


@interface AudioPlayback : NSObject

@property (nonatomic, weak) id <AudioPlayBackDelegate> delegate;

- (instancetype) initWithAudioURL:(NSURL *)fileURL error:(NSError **)error;
- (void) play;
- (void) playIndefinitely;
- (void) stop;
- (void) setVolume:(float)volume duration:(float)duration completion:(void(^)(void)) completion;
- (BOOL) isPlaying;
- (BOOL) switchToNewTrackWithURL:(NSURL *)fileURL error:(NSError **)error;
- (BOOL) switchtoNewTrackWithData:(NSData *)fileData error:(NSError **)error;

@end

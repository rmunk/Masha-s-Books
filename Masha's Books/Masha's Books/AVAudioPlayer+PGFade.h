//
//  AVAudioPlayer+PGFade.h
//  Enigma
//
//  Created by Pete Goodliffe on 05/04/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

typedef void (^AVAudioPlayerFadeCompleteBlock)();


@interface AVAudioPlayer (PGFade)

@property (nonatomic,readonly) BOOL  fading;
@property (nonatomic,readonly) float fadeTargetVolume;

- (void) fadeToVolume:(float)volume duration:(NSTimeInterval)duration;
- (void) fadeToVolume:(float)volume duration:(NSTimeInterval)duration completion:(AVAudioPlayerFadeCompleteBlock)completion;

- (void) stopWithFadeDuration:(NSTimeInterval)duration;
- (void) pauseWithFadeDuration:(NSTimeInterval)duration;
- (void) playWithFadeDuration:(NSTimeInterval)duration;

@end

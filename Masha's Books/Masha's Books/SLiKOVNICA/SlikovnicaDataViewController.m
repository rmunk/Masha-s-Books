//
//  SlikovnicaDataViewController.m
//  SLiKOVNICA
//
//  Created by Ranko Munk on 4/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "SlikovnicaDataViewController.h"
#import "AVAudioPlayer+PGFade.h"
//#define HACKINTOSH

@interface SlikovnicaDataViewController () <AVAudioPlayerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *textImage;
@property (strong, nonatomic) AVAudioPlayer *audioPlayerVoiceOver;
@property (strong, nonatomic) AVAudioPlayer *audioPlayerSound;
@end

@implementation SlikovnicaDataViewController
@synthesize page = _page;
@synthesize pageImage = _pageImage;
@synthesize textImage = _textImage;
@synthesize audioPlayerVoiceOver = _audioPlayerVoiceOver;
@synthesize audioPlayerSound = _audioPlayerSound;
@synthesize textVisibility = _textVisibility;
@synthesize voiceOverPlay = _voiceOverPlay;

#ifndef HACKINTOSH
- (AVAudioPlayer *)audioPlayerVoiceOver
{
    if (self.voiceOverPlay)
        return _audioPlayerVoiceOver;
    else
        return nil;
}
#endif

#ifdef HACKINTOSH
- (AVAudioPlayer *)audioPlayerVoiceOver{return nil;}
- (AVAudioPlayer *)audioPlayerSound {return nil;}
#endif

- (NSString *)description
{
    return [NSString stringWithFormat:@"Page %@", self.page.pageNumber];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //    NSLog(@"%@", self.description);
}

- (void)viewDidUnload
{
    [self setPageImage:nil];
    [self setTextImage:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(self.page)
    {
        self.pageImage.image = [[UIImage alloc] initWithData:self.page.image];
        if (self.textVisibility)
            self.textImage.image = [[UIImage alloc] initWithData:self.page.text];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortrait && interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)playAudio
{
    if (self.audioPlayerVoiceOver) {
        [self.audioPlayerVoiceOver play];
    }
    else {
        NSError *error;
        self.audioPlayerVoiceOver = [[AVAudioPlayer alloc] initWithData:self.page.voiceOver error:&error];
        if(error) self.audioPlayerVoiceOver = nil;
        self.audioPlayerVoiceOver.delegate = self;
        [self.audioPlayerVoiceOver play];
    }
    
    if (self.audioPlayerSound) {
        [self.audioPlayerSound play];        
    }
    else {
        NSError *error;
        self.audioPlayerSound = [[AVAudioPlayer alloc] initWithData:self.page.sound error:&error];
        if(error) self.audioPlayerSound = nil;
        self.audioPlayerSound.delegate = self;
        self.audioPlayerSound.volume = 1;
        if (self.page.soundLoop == [NSNumber numberWithInt:1]) 
            self.audioPlayerSound.numberOfLoops = -1;
        [self.audioPlayerSound play];
    }
}

- (void)pauseAudio
{
    [self.audioPlayerVoiceOver pauseWithFadeDuration:0.5];
    [self.audioPlayerSound pauseWithFadeDuration:0.5];
}

- (void)stopAudio
{
    [self.audioPlayerVoiceOver stopWithFadeDuration:0.5];
    [self.audioPlayerSound stopWithFadeDuration:0.5];
}

#pragma mark AVAudioPlayer delegate methods

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
	if (flag == NO)
		NSLog(@"Playback finished unsuccessfully");
    else if(player == self.audioPlayerVoiceOver) 
    {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"pageVoiceOverDidFinishPlaying" object:self];
    }
}

- (void)playerDecodeErrorDidOccur:(AVAudioPlayer *)p error:(NSError *)error
{
	NSLog(@"ERROR IN DECODE: %@\n", error); 
}

@end

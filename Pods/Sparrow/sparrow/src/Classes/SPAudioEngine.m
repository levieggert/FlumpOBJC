//
//  SPAudioEngine.m
//  Sparrow
//
//  Created by Daniel Sperl on 14.11.09.
//  Copyright 2011-2014 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Sparrow/SPAudioEngine.h>

#import <AudioToolbox/AudioToolbox.h> 
#import <OpenAL/al.h>
#import <OpenAL/alc.h>
#import <UIKit/UIKit.h>

// --- notifications -------------------------------------------------------------------------------

NSString *const SPNotificationMasterVolumeChanged       = @"SPNotificationMasterVolumeChanged";
NSString *const SPNotificationAudioInteruptionBegan     = @"SPNotificationAudioInteruptionBegan";
NSString *const SPNotificationAudioInteruptionEnded     = @"SPNotificationAudioInteruptionEnded";

// --- private interaface --------------------------------------------------------------------------

@interface SPAudioEngine ()

+ (BOOL)initAudioSession:(SPAudioSessionCategory)category;
+ (BOOL)initOpenAL;

+ (void)beginInterruption;
+ (void)endInterruption;
+ (void)onAppActivated:(NSNotification *)notification;
+ (void)postNotification:(NSString *)name object:(id)object;

@end


// --- class implementation ------------------------------------------------------------------------

@implementation SPAudioEngine

// --- C functions ---

static void interruptionCallback (void *inUserData, UInt32 interruptionState) 
{   
    if (interruptionState == kAudioSessionBeginInterruption)  
        [SPAudioEngine beginInterruption]; 
    else if (interruptionState == kAudioSessionEndInterruption)
        [SPAudioEngine endInterruption];
} 

// --- static members ---

static ALCdevice  *device  = NULL;
static ALCcontext *context = NULL;
static float masterVolume = 1.0f;
static BOOL interrupted = NO;

#pragma mark Initialization

- (instancetype)init
{
    [NSException raise:NSGenericException format:@"Static class - do not initialize!"];        
    return nil;
}

+ (BOOL)initAudioSession:(SPAudioSessionCategory)category
{
    static BOOL sessionInitialized = NO;
    OSStatus result;

    if (!sessionInitialized)
    {
        result = AudioSessionInitialize(NULL, NULL, interruptionCallback, NULL);
        if (result != kAudioSessionNoError)
        {
            NSLog(@"Could not initialize audio session: %x", (unsigned int)result);
            return NO;
        }
        sessionInitialized = YES;
    }

    UInt32 sessionCategory = category;
    AudioSessionSetProperty(kAudioSessionProperty_AudioCategory,
                            sizeof(sessionCategory), &sessionCategory);

    result = AudioSessionSetActive(YES);
    if (result != kAudioSessionNoError)
    {
        NSLog(@"Could not activate audio session: %x", (unsigned int)result);
        return NO;
    }

    return YES;
}

+ (BOOL)initOpenAL
{
    alGetError(); // reset any errors

    device = alcOpenDevice(NULL);
    if (!device)
    {
        NSLog(@"Could not open default OpenAL device");
        return NO;
    }

    context = alcCreateContext(device, 0);
    if (!context)
    {
        NSLog(@"Could not create OpenAL context for default device");
        return NO;
    }

    BOOL success = alcMakeContextCurrent(context);
    if (!success)
    {
        NSLog(@"Could not set current OpenAL context");
        return NO;
    }

    return YES;
}

#pragma mark Methods

+ (void)start:(SPAudioSessionCategory)category
{
    if (!device)
    {
        if ([SPAudioEngine initAudioSession:category])
            [SPAudioEngine initOpenAL];
        
        // A bug introduced in iOS 4 may lead to 'endInterruption' NOT being called in some
        // situations. Thus, we're resuming the audio session manually via the 'DidBecomeActive'
        // notification. Find more information here: http://goo.gl/mr9KS
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppActivated:)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
    }
}

+ (void)start
{      
    [SPAudioEngine start:SPAudioSessionCategory_SoloAmbientSound];
}

+ (void)stop
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    alcMakeContextCurrent(NULL);
    alcDestroyContext(context);
    alcCloseDevice(device);
    AudioSessionSetActive(NO);
    
    device = NULL;
    context = NULL;
    interrupted = NO;
}

+ (float)masterVolume
{
    return masterVolume;
}

+ (void)setMasterVolume:(float)volume
{       
    masterVolume = volume;
    alListenerf(AL_GAIN, volume);
    [SPAudioEngine postNotification:SPNotificationMasterVolumeChanged object:nil];
}

#pragma mark Notifications

+ (void)beginInterruption
{
    [SPAudioEngine postNotification:SPNotificationAudioInteruptionBegan object:nil];
    alcMakeContextCurrent(NULL);
    AudioSessionSetActive(NO);
    interrupted = YES;
}

+ (void)endInterruption
{
    interrupted = NO;
    AudioSessionSetActive(YES);
    alcMakeContextCurrent(context);
    alcProcessContext(context);
    [SPAudioEngine postNotification:SPNotificationAudioInteruptionEnded object:nil];
}

+ (void)onAppActivated:(NSNotification *)notification
{
    if (interrupted) [self endInterruption];
}

+ (void)postNotification:(NSString *)name object:(id)object
{
    [[NSNotificationCenter defaultCenter] postNotification:
     [NSNotification notificationWithName:name object:object]];
}

@end

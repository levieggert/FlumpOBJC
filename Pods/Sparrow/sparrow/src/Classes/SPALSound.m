//
//  SPALSound.m
//  Sparrow
//
//  Created by Daniel Sperl on 28.05.10.
//  Copyright 2011-2014 Gamua. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#import <Sparrow/SPALSound.h>
#import <Sparrow/SPALSoundChannel.h>
#import <Sparrow/SPAudioEngine.h>

#import <OpenAL/al.h>
#import <OpenAL/alc.h>

@implementation SPALSound
{
    uint _bufferID;
    double _duration;
}

@synthesize duration = _duration;

#pragma mark Initialization

- (instancetype)init
{
    [self release];
    return nil;
}

- (instancetype)initWithData:(const void *)data size:(int)size channels:(int)channels frequency:(int)frequency
          duration:(double)duration
{
    if ((self = [super init]))
    {        
        _duration = duration;
        [SPAudioEngine start];
        
        ALCcontext *const currentContext = alcGetCurrentContext();
        if (!currentContext)
        {
            NSLog(@"Could not get current OpenAL context");
            return nil;
        }        
        
        ALenum errorCode;
        
        alGenBuffers(1, &_bufferID);
        errorCode = alGetError();
        if (errorCode != AL_NO_ERROR)
        {
            NSLog(@"Could not allocate OpenAL buffer (%x)", errorCode);
            return nil;
        }            
        
        int format = (channels > 1) ? AL_FORMAT_STEREO16 : AL_FORMAT_MONO16;
        
        alBufferData(_bufferID, format, data, size, frequency);
        errorCode = alGetError();
        if (errorCode != AL_NO_ERROR)
        {
            NSLog(@"Could not fill OpenAL buffer (%x)", errorCode);
            return nil;
        }
    }
    return self;
}

- (void)dealloc
{
    alDeleteBuffers(1, &_bufferID);
    _bufferID = 0;

    [super dealloc];
}

#pragma mark SPSound

- (SPSoundChannel *)createChannel
{
    return [[[SPALSoundChannel alloc] initWithSound:self] autorelease];
}

@end

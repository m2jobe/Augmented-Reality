// CraftARSDK_Examples is free software. You may use it under the MIT license, which is copied
// below and available at http://opensource.org/licenses/MIT
//
// Copyright (c) 2014 Catchoom Technologies S.L.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of
// this software and associated documentation files (the "Software"), to deal in
// the Software without restriction, including without limitation the rights to use,
// copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the
// Software, and to permit persons to whom the Software is furnished to do so, subject to
// the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
// PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
// FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
// DEALINGS IN THE SOFTWARE.


#import "On-Device_Augmented_Reality.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <CraftARAugmentedRealitySDK/CraftARSDK.h>
#import <CraftARAugmentedRealitySDK/CraftARCollectionManager.h>
#import <CraftARAugmentedRealitySDK/CraftARTracking.h>

@interface OnDeviceAugmentedReality () <CraftARSDKProtocol, CraftARContentEventsProtocol, CraftARTrackingEventsProtocol> {
    CraftARSDK *mSDK;
    CraftARCollectionManager* mCollectionManager;
    CraftAROnDeviceCollection* mARCollection;
    CraftARTracking* mTracking;
     AVAudioPlayer *audioPlayer;
}
@end



@implementation OnDeviceAugmentedReality

#pragma mark view initialization and events

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Get the instance of the SDK and become delegate
    mSDK = [CraftARSDK sharedCraftARSDK];
    mSDK.delegate = self;
    
    // Get the tracking module and become delegate to receive tracking events
    mTracking = [CraftARTracking sharedTracking];
    mTracking.delegate = self;
}

- (void) viewWillAppear:(BOOL) animated {
    [super viewWillAppear:animated];
    // Start the camera capture to be able to perform Single Shot searches
    [mSDK startCaptureWithView:self.videoPreviewView];
}

- (void) viewWillDisappear:(BOOL)animated {
    // stop the capture when the view is disappearing. This releases the camera resources.
    [mSDK stopCapture];
    // Remove all items from the Tracking when leaving the view.
    [mTracking removeAllARItems];
    [super viewWillDisappear:animated];
}

#pragma mark -


#pragma mark On-device AR implementation

- (void) didStartCapture {
    __block OnDeviceAugmentedReality* mySelf = self;
    
    
    // The collection manager allows to manage on-device collections
    mCollectionManager = [CraftARCollectionManager sharedCollectionManager];
    
    // In this case, we downloaded an on-device Bundle
    NSString* bundle = [[NSBundle mainBundle] pathForResource:@"TheMillwinders.The-Millwinders1" ofType:@"zip"];
    
    // We add the on-device bundle to the collection manager
    [mCollectionManager addCollectionFromBundle:bundle withOnProgress:^(float progress) {
        NSLog(@"Progress: %f", progress);
    } andOnSuccess:^(CraftAROnDeviceCollection *collection) {
        mARCollection = collection;
        // Ready to retrieve and Add AR items to the tracking, for now, just do it after 1 second
        //[mySelf performSelector:@selector(startOfflineARTracking) withObject:mySelf afterDelay:1];
        [mySelf startOfflineARTracking];
    } andOnError:^(CraftARError *error) {
        NSLog(@"Error adding bundle %@", error.localizedDescription);
    }];
}

- (void) startOfflineARTracking {    
    // Add the items in a background queue to avoid blocking the main thread
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[mARCollection listItems] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSError* error;
            CraftARItem* arItem = (CraftARItemAR*)[mARCollection getItem:(NSString*)obj andError:&error];
            if (arItem != nil && [arItem isKindOfClass:CraftARItemAR.class]) {
                [mTracking addARItem: (CraftARItemAR*)arItem];
            }
        }];
    });
    
    [mTracking startTrackingWithTimeout: 15.0];
}

- (void) trackingTimeoutOver {
    NSLog(@"TRACKING TIMEOUT OVER!!");
}

#pragma mark -

#pragma mark Receive Tracking and contents events

// Using the CraftARTrackingEventsProtocol and becoming delegate of the CraftARTracking class,
// you can start receiving globally all tracking events produced by the SDK on the items added.

- (void) didStartTrackingItem:(CraftARItemAR *)item {
    NSLog(@"Start tracking: %@", item.name);
    self._scanOverlay.hidden = YES;
}

- (void) didStopTrackingItem:(CraftARItemAR *)item {
    NSLog(@"Stop tracking: %@", item.name);
}


// The CraftARContentEventsProtocol protocol allows to receive events for specific contents
// You can navigate to the parent item of a content using content.parentARItem
- (void) didGetTouchEvent:(CraftARContentTouchEvent)event forContent:(CraftARTrackingContent *)content {
    
         
            
            if([content.contentId  isEqual: @"theregoesmybaby"]) {
                //trouble
                if(audioPlayer.isPlaying) {
                    
                    [audioPlayer stop];
                    
                } else {
                NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:@"theregoesmybaby"
                                                                          ofType:@"mp3"];
                NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
                audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
                audioPlayer.numberOfLoops = -1;
                [audioPlayer play];
                }

                
            }
    
    if([content.contentId  isEqual: @"trouble"]) {
        //trouble
        if(audioPlayer.isPlaying) {
            
            [audioPlayer stop];
            
        } else {
        NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:@"trouble"
                                                                  ofType:@"mp3"];
        NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
        audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
        audioPlayer.numberOfLoops = -1;
        [audioPlayer play];
        
        }
        
    }
    
    
    if([content.contentId  isEqual: @"lovemeso"]) {
        //trouble
        if(audioPlayer.isPlaying) {
            
            [audioPlayer stop];
            
        } else {
        NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:@"lovemeso"
                                                                  ofType:@"mp3"];
        NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
        audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
        audioPlayer.numberOfLoops = -1;
        [audioPlayer play];
        }
        
    }
    
    
    if([content.contentId  isEqual: @"twotimer"]) {
        //trouble
        
        if(audioPlayer.isPlaying) {
        
        [audioPlayer stop];
        
        } else {
        NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:@"twotimingfool"
                                                                  ofType:@"mp3"];
        NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
        audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
        audioPlayer.numberOfLoops = -1;
        [audioPlayer play];
        
        }
    }
    
    
}


#pragma mark -

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

//
//  MoviePlayerDemoTest.m
//  MoviePlayerDemoTest
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import "MoviePlayerDemoTest.h"
#import "WZYYouTubeVideo.h"

@implementation MoviePlayerDemoTest

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testWatchPage
{
    __block BOOL isFinished = NO;
    
    __block WZYYouTubeVideo *video = [[WZYYouTubeVideo alloc] initWithVideoID:@"NjXQcGmffu0"];
        
    [video retriveteDataFromWatchPageWithCompletionHandler:^(NSError *error) {
        STAssertNil(error, @"retriveteDataFromWatchPageWithCompletionHandler");        
        if (!error) {
            STAssertNotNil(video.contentAttributes, @"mediaURLWithQuality:WZYYouTubeVideoQualityLarge");
            NSURL *mediaURL = [video mediaURLWithQuality:WZYYouTubeVideoQualityLarge];
            if (!mediaURL) {
                // debug
                NSDictionary *player_data = [video.contentAttributes objectForKey:@"player_data"];
                STAssertNotNil(player_data, @"video.contentAttributes[player_data]");
                if (player_data) {                    
                    if (player_data) {
                        NSArray *fmt_stream_map = [player_data objectForKey:@"fmt_stream_map"];
                        STAssertNotNil(fmt_stream_map, @"video.contentAttributes[player_data][fmt_stream_map]");
                    }                    
                }
                NSLog(@"video.contentAttributes = %@", video.contentAttributes);
            }
            STAssertNotNil(mediaURL, @"mediaURLWithQuality:WZYYouTubeVideoQualityLarge");
        }
        
        video = nil;
        isFinished = YES;
    }];
    
    while (!isFinished) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
    }
    
}

@end

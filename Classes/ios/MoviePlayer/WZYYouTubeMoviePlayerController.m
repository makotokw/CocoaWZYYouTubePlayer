//
//  WZYYouTubeMoviePlayerController.m
//  WZYYouTubePlayer
//
//  Copyright (c) 2012 makoto_kw. All rights reserved.
//

#import "WZYYouTubeMoviePlayerController.h"
#import "WZYYouTubeVideo.h"

@implementation WZYYouTubeMoviePlayerController
{
    WZYYouTubeVideo *_video;
}

- (id)initWithWatchURL:(NSURL *)watchURL
{
    if (self = [super init]) {
        WZYYouTubeVideo *video = [[WZYYouTubeVideo alloc] initWithWatchURL:watchURL];
        [self playVideo:video completionHandler:nil];
    }
    return self;
}

- (id)initWithVideoID:(NSString *)videoID
{
    if (self = [super init]) {
        WZYYouTubeVideo *video = [[WZYYouTubeVideo alloc] initWithVideoID:videoID];
        [self playVideo:video completionHandler:nil];
    }
    return self;
}

- (id)initWithVideo:(WZYYouTubeVideo *)video
{
    if (self = [super init]) {
        [self playVideo:video completionHandler:nil];
    }
    return self;
}

- (void)playVideo:(WZYYouTubeVideo *)video completionHandler:(WZYYouTubeAsyncBlock)completionHandler
{
    _video = video;
    __weak WZYYouTubeMoviePlayerController *me = self;
    [_video retriveteDataFromWatchPageWithCompletionHandler:^(NSError *error) {
        if (!error) {
            NSURL *mediaURL = [video mediaURLWithQuality:WZYYouTubeVideoQualityLarge];
            me.contentURL = mediaURL;
            [me play];
        }
        if (completionHandler) {
            completionHandler(error);
        }
    }];
}

@end

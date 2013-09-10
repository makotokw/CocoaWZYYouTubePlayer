//
//  WZYouTubeMoviePlayerController.m
//  WZYouTubePlayer
//
//  Copyright (c) 2012-2013 makoto_kw. All rights reserved.
//

#import "WZYouTubeMoviePlayerController.h"
#import "WZYouTubeVideo.h"

@implementation WZYouTubeMoviePlayerController
{
    WZYouTubeVideo *_video;
}

- (id)initWithWatchURL:(NSURL *)watchURL
{
    if (self = [super init]) {
        WZYouTubeVideo *video = [[WZYouTubeVideo alloc] initWithWatchURL:watchURL];
        [self playVideo:video completionHandler:nil];
    }
    return self;
}

- (id)initWithVideoID:(NSString *)videoID
{
    if (self = [super init]) {
        WZYouTubeVideo *video = [[WZYouTubeVideo alloc] initWithVideoID:videoID];
        [self playVideo:video completionHandler:nil];
    }
    return self;
}

- (id)initWithVideo:(WZYouTubeVideo *)video
{
    if (self = [super init]) {
        [self playVideo:video completionHandler:nil];
    }
    return self;
}

- (void)playVideo:(WZYouTubeVideo *)video completionHandler:(WZYouTubeAsyncBlock)completionHandler
{
    _video = video;
    __weak WZYouTubeMoviePlayerController *me = self;
    [_video retriveteDataFromWatchPageWithCompletionHandler:^(NSError *error) {
        if (!error) {
            NSURL *mediaURL = [video mediaURLWithQuality:WZYouTubeVideoQualityLarge];
            me.contentURL = mediaURL;
            [me play];
        }
        if (completionHandler) {
            completionHandler(error);
        }
    }];
}

@end

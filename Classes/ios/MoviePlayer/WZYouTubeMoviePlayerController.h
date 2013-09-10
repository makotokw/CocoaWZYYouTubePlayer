//
//  WZYouTubeMoviePlayerController.h
//  WZYouTubePlayer
//
//  Copyright (c) 2012-2013 makoto_kw. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import "WZYouTubeDefines.h"

@class WZYouTubeVideo;

@interface WZYouTubeMoviePlayerController : MPMoviePlayerController

@property (retain, readonly) WZYouTubeVideo *video;

- (id)initWithWatchURL:(NSURL *)watchURL;
- (id)initWithVideoID:(NSString *)videoID;
- (id)initWithVideo:(WZYouTubeVideo *)video;

- (void)playVideo:(WZYouTubeVideo *)video completionHandler:(WZYouTubeAsyncBlock)completionHandler;

@end

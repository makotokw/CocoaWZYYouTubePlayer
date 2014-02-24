//
//  WZYYouTubeMoviePlayerViewController.h
//  WZYYouTubePlayer
//
//  Copyright (c) 2012 makoto_kw. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import "WZYYouTubeDefines.h"

@class WZYYouTubeVideo;

@interface WZYYouTubeMoviePlayerViewController : MPMoviePlayerViewController

@property (retain, readonly) WZYYouTubeVideo *video;

- (id)initWithWatchURL:(NSURL *)watchURL;
- (id)initWithVideoID:(NSString *)videoID;
- (id)initWithVideo:(WZYYouTubeVideo *)video;

- (void)playVideo:(WZYYouTubeVideo *)video completionHandler:(WZYYouTubeAsyncBlock)completionHandler;

@end

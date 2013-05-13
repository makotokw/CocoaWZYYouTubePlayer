//
//  WZYouTubeMoviePlayerViewController.h
//  WZYouTubePlayer
//
//  Copyright (c) 2012-2013 makoto_kw. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>

@class WZYouTubeVideo;

@interface WZYouTubeMoviePlayerViewController : MPMoviePlayerViewController

@property (retain, readonly) WZYouTubeVideo *video;

- (id)initWithWatchURL:(NSURL *)watchURL;
- (id)initWithVideoID:(NSString *)videoID;
- (id)initWithVideo:(WZYouTubeVideo *)video;

@end

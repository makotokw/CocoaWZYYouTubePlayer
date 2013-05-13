//
//  WZYouTubeVideo.h
//  WZYouTubePlayer
//
//  Copyright (c) 2012-2013 makoto_kw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WZYouTubeDefines.h"

@interface WZYouTubeVideo : NSObject <NSURLConnectionDataDelegate>

@property (retain) NSString *videoID;
@property (retain) NSString *title, *mediaDescription;
@property (assign) NSTimeInterval duration;
@property (retain, readonly) NSURL* watchURL;
@property (retain) NSURL* thumbnailURL;

+ (NSURL *)watchURLWithVideoID:(NSString *)videoID;

- (id)initWithWatchURL:(NSURL *)watchURL;
- (id)initWithVideoID:(NSString *)videoID;
- (void)retriveteDataFromWatchPageWithCompletionHandler:(WZYouTubeAsyncBlock)completionHandler;
- (NSURL *)mediaURLWithQuality:(WZYouTubeVideoQuality)quality;

@end

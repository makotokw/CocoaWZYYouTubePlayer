//
//  WZYYouTubeVideo.h
//  WZYYouTubePlayer
//
//  Copyright (c) 2012 makoto_kw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WZYYouTubeDefines.h"

@interface WZYYouTubeVideo : NSObject <NSURLConnectionDataDelegate>

@property (retain) NSString *videoID;
@property (retain) NSString *title, *mediaDescription;
@property (assign) NSTimeInterval duration;
@property (retain, readonly) NSURL* watchURL;
@property (retain) NSURL* thumbnailURL;
@property (retain, readonly) NSDictionary *contentAttributes;
@property (retain, readonly) NSArray *streamMap;

+ (NSURL *)watchURLWithVideoID:(NSString *)videoID;

- (id)initWithWatchURL:(NSURL *)watchURL;
- (id)initWithVideoID:(NSString *)videoID;
- (void)retriveteDataFromWatchPageWithCompletionHandler:(WZYYouTubeAsyncBlock)completionHandler;
- (NSURL *)mediaURLWithQuality:(WZYYouTubeVideoQuality)quality;

@end

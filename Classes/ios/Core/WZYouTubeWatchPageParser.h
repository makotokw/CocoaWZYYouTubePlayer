//
//  WZYouTubeWatchPageParser.h
//  WZYouTubePlayer
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WZYouTubeVideo;

extern NSString *WZYouTubeWatchPageContentKey;
extern NSString *WZYouTubeWatchPageErrorsKey;
extern NSString *WZYouTubeWatchPageContentVideoTitleKey;
extern NSString *WZYouTubeWatchPageContentVideoLengthKey;
extern NSString *WZYouTubeWatchPageContentVideoThumbnailKey;
extern NSString *WZYouTubeWatchPageContentVideoStreamKey;

@interface WZYouTubeWatchPageParser : NSObject

@property NSString *beforeJsonStatement;
@property NSString *afterJsonStatement;
@property NSMutableDictionary *pathComponents;

+ (WZYouTubeWatchPageParser *)defaultParser;
- (void)parsePageWithData:(NSData *)data copyTo:(WZYouTubeVideo *)video error:(NSError **)theError;

@end

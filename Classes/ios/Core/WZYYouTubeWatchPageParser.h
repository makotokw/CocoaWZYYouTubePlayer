//
//  WZYYouTubeWatchPageParser.h
//  WZYYouTubePlayer
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WZYYouTubeVideo;

extern NSString *WZYYouTubeWatchPageContentKey;
extern NSString *WZYYouTubeWatchPageErrorsKey;
extern NSString *WZYYouTubeWatchPageContentVideoTitleKey;
extern NSString *WZYYouTubeWatchPageContentVideoLengthKey;
extern NSString *WZYYouTubeWatchPageContentVideoThumbnailKey;
extern NSString *WZYYouTubeWatchPageContentVideoStreamKey;

@interface WZYYouTubeWatchPageParser : NSObject

@property NSString *beforeJsonStatement;
@property NSString *afterJsonStatement;
@property NSMutableDictionary *pathComponents;

+ (WZYYouTubeWatchPageParser *)defaultParser;
- (BOOL)parsePageWithData:(NSData *)data copyTo:(WZYYouTubeVideo *)video error:(NSError **)theError;

@end

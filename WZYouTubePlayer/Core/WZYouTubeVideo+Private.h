//
//  WZYouTubeVideo+Private.h
//  WZYouTubePlayer
//
//  Copyright (c) 2012-2013 makoto_kw. All rights reserved.
//

#import "WZYouTubeVideo.h"

@interface WZYouTubeVideo()

{
    id _gdataEntry;
    NSString *_title;
    NSString *_videoID;
    NSString *_mediaDescription;
    NSURL *_thumbnailURL;
    
    NSDictionary *_contentAttributes; // from watchUrl
}

@end

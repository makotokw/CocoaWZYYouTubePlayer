//
//  WZYouTubeDefines.h
//  WZYouTubePlayer
//
//  Copyright (c) 2012-2013 makoto_kw. All rights reserved.
//

extern const NSString *kWZYouTubeVideoErrorDomain;

typedef void (^WZYouTubeAsyncBlock)(NSError *error);

typedef enum : NSUInteger {
    WZYouTubeVideoErrorCodeInvalidSource = 1,
    WZYouTubeVideoErrorCodeNoStreamURL   = 2,
    WZYouTubeVideoErrorCodeNoJSONData    = 3,
} WZYouTubeVideoErrorCode;

typedef enum : NSUInteger {
    WZYouTubeVideoQualitySmall    = 0,
    WZYouTubeVideoQualityMedium   = 1,
    WZYouTubeVideoQualityLarge    = 2,
} WZYouTubeVideoQuality;
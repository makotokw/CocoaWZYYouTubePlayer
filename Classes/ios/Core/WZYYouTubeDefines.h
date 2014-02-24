//
//  WZYYouTubeDefines.h
//  WZYYouTubePlayer
//
//  Copyright (c) 2012 makoto_kw. All rights reserved.
//

extern const NSString *kWZYYouTubeVideoErrorDomain;

typedef void (^WZYYouTubeAsyncBlock)(NSError *error);

typedef enum : NSUInteger {
    WZYYouTubeVideoErrorCodeInvalidSource = 1,
    WZYYouTubeVideoErrorCodeNoStreamURL   = 2,
    WZYYouTubeVideoErrorCodeNoJSONData    = 3,
} WZYYouTubeVideoErrorCode;

typedef enum : NSUInteger {
    WZYYouTubeVideoQualitySmall    = 0,
    WZYYouTubeVideoQualityMedium   = 1,
    WZYYouTubeVideoQualityLarge    = 2,
} WZYYouTubeVideoQuality;
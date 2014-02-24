//
//  WZYYouTubeVideo.m
//  WZYYouTubePlayer
//
//  Copyright (c) 2012 makoto_kw. All rights reserved.
//
//  refered to the LBYouTubeView/LBYouTubeExtractor
//  see LBYouTubeView https://github.com/larcus94/LBYouTubeView
//

#import "WZYYouTubeVideo.h"
#import "WZYYouTubeError.h"
#import "WZYYouTubeWatchPageParser.h"

const NSString *kWZYYouTubeVideoErrorDomain = @"WZYYouTubeVideoErrorDomain";
static NSString *kUserAgent = @"Mozilla/5.0 (iPhone; CPU iPhone OS 5_0 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9A334 Safari/7534.48.3";

@interface WZYYouTubeVideo ()
@property (retain, readwrite) NSDictionary *contentAttributes;
@property (retain, readwrite) NSArray *streamMap;
@end

@implementation WZYYouTubeVideo

@synthesize videoID = _videoID;
@synthesize title = _title, mediaDescription = _mediaDescription;
@synthesize thumbnailURL = _thumbnailURL;
@synthesize contentAttributes = _contentAttributes;
@synthesize streamMap = _streamMap;
@dynamic watchURL;

+ (void)initialize
{
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    kUserAgent = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
}

+ (NSURL *)watchURLWithVideoID:(NSString *)videoID
{
    return [NSURL URLWithString:[NSString stringWithFormat:@"http://www.youtube.com/watch?v=%@", videoID]];
}

+ (NSString *)videoIdWithWatchURL:(NSURL *)watchURL
{
    NSError *error = nil;
    
    NSString *URLString = watchURL.absoluteString ;
    NSRegularExpression *r = [NSRegularExpression regularExpressionWithPattern:@"watch\\?v=([\\w]\\-_+)"
                                                                      options:NSRegularExpressionCaseInsensitive
                                                                        error:&error];
    
    NSTextCheckingResult *match = [r firstMatchInString:URLString options:0 range:NSMakeRange(0, [URLString length])];
    if (match) {
        return [URLString substringWithRange:[match rangeAtIndex:1]];
    }
    return nil;
}

- (id)initWithWatchURL:(NSURL *)watchURL
{
    if (self = [super init]) {
        _videoID = [self.class videoIdWithWatchURL:watchURL];
    }
    return self;
}

- (id)initWithVideoID:(NSString *)videoID
{
    if (self = [super init]) {
        _videoID = videoID;
    }
    return self;
}

- (NSString *)description
{
    return _title;
}

- (NSURL *)watchURL
{
    return [self.class watchURLWithVideoID:_videoID];
}

- (NSURL *)mediaURLWithQuality:(WZYYouTubeVideoQuality)quality
{
    NSURL *mediaURL = nil;
    
    if (_streamMap.count) {
        NSString  *URLString;
        NSString *streamURLKey = @"url";
        switch (quality) {
            case WZYYouTubeVideoQualityLarge:
            {
                URLString = [[_streamMap objectAtIndex:0] objectForKey:streamURLKey];
                break;
            }
                
            case WZYYouTubeVideoQualityMedium:
            {
                NSUInteger index = MIN(_streamMap.count-1, 1);
                URLString = [[_streamMap objectAtIndex:index] objectForKey:streamURLKey];
                break;
            }
                
            default:
            {
                URLString = [[_streamMap lastObject] objectForKey:streamURLKey];
                break;
            }
        }
        
        mediaURL = [NSURL URLWithString:URLString];
    }
    return mediaURL;
}

- (void)retriveteDataFromWatchPageWithCompletionHandler:(WZYYouTubeAsyncBlock)completionHandler
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.watchURL
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    
    [request setValue:kUserAgent forHTTPHeaderField:@"User-Agent"];
    
    
    __weak WZYYouTubeVideo *me = self;
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if (!error) {
                                   NSError *parseError = nil;
                                   [[WZYYouTubeWatchPageParser defaultParser] parsePageWithData:data copyTo:me error:&parseError];
                                   completionHandler(parseError);
                               } else {
                                   completionHandler(error);
                               }
                           }];
}

@end

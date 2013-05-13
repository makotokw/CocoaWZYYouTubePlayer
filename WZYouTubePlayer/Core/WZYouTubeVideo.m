//
//  WZYouTubeVideo.m
//  WZYouTubePlayer
//
//  Copyright (c) 2012-2013 makoto_kw. All rights reserved.
//
//  refered to the LBYouTubeView/LBYouTubeExtractor
//  see LBYouTubeView https://github.com/larcus94/LBYouTubeView
//

#import "WZYouTubeVideo.h"
#import "WZYouTubeVideo+Private.h"
#import "WZYouTubeError.h"

const NSString *kWZYouTubeVideoErrorDomain = @"WZYouTubeVideoErrorDomain";
static NSString *kUserAgent = @"Mozilla/5.0 (iPhone; CPU iPhone OS 5_0 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9A334 Safari/7534.48.3";

@implementation WZYouTubeVideo

@synthesize videoID = _videoID;
@synthesize title = _title, mediaDescription = _mediaDescription;
@synthesize thumbnailURL = _thumbnailURL;
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

- (NSURL *)mediaURLWithQuality:(WZYouTubeVideoQuality)quality
{
    NSURL *mediaURL = nil;
    NSArray *videos = [[_contentAttributes objectForKey:@"video"] objectForKey:@"fmt_stream_map"];

    if (videos.count) {
        NSString  *URLString;
        NSString *streamURLKey = @"url";
        switch (quality) {
            case WZYouTubeVideoQualityLarge:
            {
                URLString = [[videos objectAtIndex:0] objectForKey:streamURLKey];
                break;
            }
                
            case WZYouTubeVideoQualityMedium:
            {
                NSUInteger index = MIN(videos.count-1, 1);
                URLString = [[videos objectAtIndex:index] objectForKey:streamURLKey];
                break;
            }
                
            default:
            {
                URLString = [[videos lastObject] objectForKey:streamURLKey];
                break;
            }
        }
        
        mediaURL = [NSURL URLWithString:URLString];
    }
    return mediaURL;
}

- (void)retriveteDataFromWatchPageWithCompletionHandler:(WZYouTubeAsyncBlock)completionHandler
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.watchURL
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    
    [request setValue:kUserAgent forHTTPHeaderField:@"User-Agent"];
    
    
    __weak WZYouTubeVideo *me = self;
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if (!error) {
                                   NSError *parseError = nil;
                                   [me processWatchUrlPageWithData:data error:&parseError];
                                   completionHandler(parseError);
                               } else {
                                   completionHandler(error);
                               }
                           }];
}

- (void)processWatchUrlPageWithData:(NSData *)data error:(NSError **)theError;
{
    NSError *error = nil;
    NSString* html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    if (html.length > 0) {
        
        NSString *start = nil;
        NSString *startFull = @"ls.setItem('PIGGYBACK_DATA', \")]}'";
        NSString *startShrunk = [startFull stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        if ([html rangeOfString:startFull].location != NSNotFound) {
            start = startFull;
        }
        else if ([html rangeOfString:startShrunk].location != NSNotFound) {
            start = startShrunk;
        } else {
            error = [WZYouTubeError errorWithDomain:(NSString *)kWZYouTubeVideoErrorDomain
                                               code:WZYouTubeVideoErrorCodeNoJSONData
                                           userInfo:[NSDictionary dictionaryWithObject:@"The JSON data could not be found." forKey:NSLocalizedDescriptionKey]];
        }
        
        if (start != nil) {
            
            NSScanner* scanner = [NSScanner scannerWithString:html];
            [scanner scanUpToString:start intoString:nil];
            [scanner scanString:start intoString:nil];
            
            NSString *jsonString = nil;
            [scanner scanUpToString:@"\");" intoString:&jsonString];
            jsonString = [self unescapeString:jsonString];
            
            NSError *jsonError = nil;                        
            NSDictionary* jsonData = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:&jsonError];
            
            if (!jsonError) {
                _contentAttributes = jsonData[@"content"];
                if (_contentAttributes.count == 0) {
                    NSArray *errors = jsonData[@"errors"];
                    NSString *errorMessage = errors[0];
                    if (!errorMessage) {
                        errorMessage = @"The content data could not be found.";
                    }
                    error = [WZYouTubeError errorWithDomain:(NSString *)kWZYouTubeVideoErrorDomain
                                                       code:WZYouTubeVideoErrorCodeNoJSONData
                                                   userInfo:@{NSLocalizedDescriptionKey: errorMessage, @"errors": errors}];
                } else {                    
                    NSDictionary *video = _contentAttributes[@"video"];
                    if (!_title) {
                        _title = video[@"title"];
                    }
                    if (_duration == 0) {
                        NSNumber *lengthSeconds = video[@"length_seconds"];
                        _duration = lengthSeconds.doubleValue;
                    }
                    if (!_thumbnailURL) {
                        NSString *thumbnailForWatch = video[@"thumbnail_for_watch"];
                        if (thumbnailForWatch) {
                            _thumbnailURL = [NSURL URLWithString:thumbnailForWatch];                            
                        }
                    }
                }
            } else {
                error = [WZYouTubeError errorWithDomain:(NSString *)kWZYouTubeVideoErrorDomain
                                                   code:WZYouTubeVideoErrorCodeNoJSONData
                                               userInfo:@{NSLocalizedDescriptionKey: @"The JSON data could not be found."}];
            }
        }


    } else {        
        error = [WZYouTubeError errorWithDomain:(NSString *)kWZYouTubeVideoErrorDomain
                                           code:WZYouTubeVideoErrorCodeInvalidSource
                                       userInfo:@{NSLocalizedDescriptionKey: @"Couldn't download the HTML source code. URL might be invalid."}];
    }
        
    if (theError) {
        *theError = error;
    }
}

// Modified answer from StackOverflow http://stackoverflow.com/questions/2099349/using-objective-c-cocoa-to-unescape-unicode-characters-ie-u1234

-(NSString *)unescapeString:(NSString *)string
{
    // will cause trouble if you have "abc\\\\uvw"
    // \u   --->    \U
    NSString *esc1 = [string stringByReplacingOccurrencesOfString:@"\\u" withString:@"\\U"];
    
    // "    --->    \"
    NSString *esc2 = [esc1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    
    // \\"  --->    \"
    NSString *esc3 = [esc2 stringByReplacingOccurrencesOfString:@"\\\\\"" withString:@"\\\""];
    
    NSString *quoted = [[@"\"" stringByAppendingString:esc3] stringByAppendingString:@"\""];
    NSData *data = [quoted dataUsingEncoding:NSUTF8StringEncoding];
    
    //  NSPropertyListFormat format = 0;
    //  NSString *errorDescr = nil;
    NSString *unesc = [NSPropertyListSerialization propertyListFromData:data mutabilityOption:NSPropertyListImmutable format:NULL errorDescription:NULL];
    
    if ([unesc isKindOfClass:[NSString class]]) {
        // \U   --->    \u
        return [unesc stringByReplacingOccurrencesOfString:@"\\U" withString:@"\\u"];
    }
    return nil;
}

@end

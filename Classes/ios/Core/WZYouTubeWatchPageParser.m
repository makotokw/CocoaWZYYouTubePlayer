//
//  WZYouTubeWatchPageParser.m
//  WZYouTubePlayer
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import "WZYouTubeWatchPageParser.h"
#import "WZYouTubeVideo.h"
#import "WZYouTubeError.h"

NSString *WZYouTubeWatchPageContentKey = @"content";
NSString *WZYouTubeWatchPageErrorsKey = @"errors";
NSString *WZYouTubeWatchPageContentVideoTitleKey = @"content/video/title";
NSString *WZYouTubeWatchPageContentVideoLengthKey = @"content/video/length";
NSString *WZYouTubeWatchPageContentVideoThumbnailKey = @"content/video/thumbnail";
NSString *WZYouTubeWatchPageContentVideoStreamKey = @"content/video/stream";

@interface WZYouTubeVideo (Parser)
@property (retain, readwrite) NSDictionary *contentAttributes;
@property (retain, readwrite) NSDictionary *streamMap;
@end

@implementation WZYouTubeWatchPageParser

@synthesize beforeJsonStatement = _beforeJsonStatement, afterJsonStatement = _afterJsonStatement;
@synthesize pathComponents = _pathComponents;

+ (WZYouTubeWatchPageParser *)defaultParser
{
    static WZYouTubeWatchPageParser *s = nil;
    
    if (!s) {
        s = [[WZYouTubeWatchPageParser alloc] init];
    }
    return s;
}

- (id)init
{
    self = [super init];
    if (self) {
        _beforeJsonStatement = @"var bootstrap_data = \")]}'";
        _afterJsonStatement = @"\";";
        
        _pathComponents = [@{
                           WZYouTubeWatchPageContentKey : @[@"content"],
                           WZYouTubeWatchPageErrorsKey : @[@"errors"],
                           
                           WZYouTubeWatchPageContentVideoTitleKey : @[@"video", @"title"],
                           WZYouTubeWatchPageContentVideoLengthKey : @[@"video", @"length_seconds"],
                           WZYouTubeWatchPageContentVideoThumbnailKey : @[@"video", @"thumbnail_for_watch"],
                           WZYouTubeWatchPageContentVideoStreamKey : @[@"player_data", @"fmt_stream_map"],
                           } mutableCopy];
    }
    return self;
}

- (void)parsePageWithData:(NSData *)data copyTo:(WZYouTubeVideo *)video error:(NSError **)theError
{
    NSError *error = nil;
    NSString* html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    if (html.length > 0) {
        NSString *jsonString = [self extractBootstrapData:html];
        if (jsonString) {
            
            NSError *jsonError = nil;
            NSDictionary* jsonData = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:&jsonError];
            
            if (!jsonError) {
                NSDictionary *contentAttributes = [self objectWithDictionary:jsonData forKey:WZYouTubeWatchPageContentKey];
                if (contentAttributes.count == 0) {
                    NSArray *errors = [self objectWithDictionary:jsonData forKey:WZYouTubeWatchPageErrorsKey];
                    NSString *errorMessage = errors[0];
                    if (!errorMessage) {
                        errorMessage = @"The content data could not be found.";
                    }
                    error = [WZYouTubeError errorWithDomain:(NSString *)kWZYouTubeVideoErrorDomain
                                                       code:WZYouTubeVideoErrorCodeNoJSONData
                                                   userInfo:@{NSLocalizedDescriptionKey: errorMessage, @"errors": errors}];
                } else {
                    if (!video.title) {
                        video.title = [self objectWithDictionary:contentAttributes forKey:WZYouTubeWatchPageContentVideoTitleKey];
                    }
                    if (video.duration == 0) {
                        NSNumber *lengthSeconds = [self objectWithDictionary:contentAttributes forKey:WZYouTubeWatchPageContentVideoLengthKey];
                        video.duration = lengthSeconds.doubleValue;
                    }
                    if (!video.thumbnailURL) {
                        NSString *thumbnailForWatch =  [self objectWithDictionary:contentAttributes forKey:WZYouTubeWatchPageContentVideoThumbnailKey];
                        if (thumbnailForWatch) {
                            video.thumbnailURL = [NSURL URLWithString:thumbnailForWatch];
                        }
                    }                    
                    video.contentAttributes = contentAttributes;
                    video.streamMap = [self objectWithDictionary:contentAttributes forKey:WZYouTubeWatchPageContentVideoStreamKey];
                }

                
            } else {
                error = [WZYouTubeError errorWithDomain:(NSString *)kWZYouTubeVideoErrorDomain
                                                   code:WZYouTubeVideoErrorCodeNoJSONData
                                               userInfo:@{NSLocalizedDescriptionKey: @"The JSON data could not be found."}];
            }
        } else {
            error = [WZYouTubeError errorWithDomain:(NSString *)kWZYouTubeVideoErrorDomain
                                               code:WZYouTubeVideoErrorCodeNoJSONData
                                           userInfo:[NSDictionary dictionaryWithObject:@"The JSON data could not be found." forKey:NSLocalizedDescriptionKey]];
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

- (id)objectWithDictionary:(NSDictionary *)dict forKey:(NSString *)key
{
    NSDictionary *cursor = dict;
    NSArray *pathComponents = _pathComponents[key];
    NSString *lastComponent = pathComponents.lastObject;
    for (NSString *component in pathComponents) {
        if (component != lastComponent) {
            cursor = cursor[component];
        }
    }
    return cursor[lastComponent];
}

- (NSString *)extractBootstrapData:(NSString *)html
{
    NSString *jsonString = nil;
    
    NSString *start = nil;
    NSString *startFull = [_beforeJsonStatement copy];
    NSString *startShrunk = [startFull stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if ([html rangeOfString:startFull].location != NSNotFound) {
        start = startFull;
    }
    else if ([html rangeOfString:startShrunk].location != NSNotFound) {
        start = startShrunk;
    }
    
    if (start) {
        NSScanner* scanner = [NSScanner scannerWithString:html];
        [scanner scanUpToString:start intoString:nil];
        [scanner scanString:start intoString:nil];
        [scanner scanUpToString:_afterJsonStatement intoString:&jsonString];
        jsonString = [self unescapeString:jsonString];
    }
    
    return jsonString;
}

// Modified answer from StackOverflow http://stackoverflow.com/questions/2099349/using-objective-c-cocoa-to-unescape-unicode-characters-ie-u1234

- (NSString *)unescapeString:(NSString *)string
{
    // will cause trouble if you have "abc\\\\uvw"
    // \u to \U
    NSString *esc1 = [string stringByReplacingOccurrencesOfString:@"\\u" withString:@"\\U"];
    // " to \"
    NSString *esc2 = [esc1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    // \\" to \"
    NSString *esc3 = [esc2 stringByReplacingOccurrencesOfString:@"\\\\\"" withString:@"\\\""];
    NSString *quoted = [[@"\"" stringByAppendingString:esc3] stringByAppendingString:@"\""];
    NSData *data = [quoted dataUsingEncoding:NSUTF8StringEncoding];
    
    //  NSPropertyListFormat format = 0;
    //  NSString *errorDescr = nil;
    NSString *unesc = [NSPropertyListSerialization propertyListFromData:data mutabilityOption:NSPropertyListImmutable format:NULL errorDescription:NULL];
    
    if ([unesc isKindOfClass:[NSString class]]) {
        // \U to \u
        return [unesc stringByReplacingOccurrencesOfString:@"\\U" withString:@"\\u"];
    }
    return nil;
}

@end

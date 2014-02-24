//
//  WZYYouTubeWatchPageParser.m
//  WZYYouTubePlayer
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import "WZYYouTubeWatchPageParser.h"
#import "WZYYouTubeVideo.h"
#import "WZYYouTubeError.h"

NSString *WZYYouTubeWatchPageContentKey = @"content";
NSString *WZYYouTubeWatchPageErrorsKey = @"errors";
NSString *WZYYouTubeWatchPageContentVideoTitleKey = @"content/video/title";
NSString *WZYYouTubeWatchPageContentVideoLengthKey = @"content/video/length";
NSString *WZYYouTubeWatchPageContentVideoThumbnailKey = @"content/video/thumbnail";
NSString *WZYYouTubeWatchPageContentVideoStreamKey = @"content/video/stream";

@interface WZYYouTubeVideo (Parser)
@property (retain, readwrite) NSDictionary *contentAttributes;
@property (retain, readwrite) NSDictionary *streamMap;
@end

@implementation WZYYouTubeWatchPageParser

@synthesize beforeJsonStatement = _beforeJsonStatement, afterJsonStatement = _afterJsonStatement;
@synthesize pathComponents = _pathComponents;

+ (WZYYouTubeWatchPageParser *)defaultParser
{
    static WZYYouTubeWatchPageParser *s = nil;
    
    if (!s) {
        s = [[WZYYouTubeWatchPageParser alloc] init];
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
                           WZYYouTubeWatchPageContentKey : @[@"content"],
                           WZYYouTubeWatchPageErrorsKey : @[@"errors"],
                           
                           WZYYouTubeWatchPageContentVideoTitleKey : @[@"video", @"title"],
                           WZYYouTubeWatchPageContentVideoLengthKey : @[@"video", @"length_seconds"],
                           WZYYouTubeWatchPageContentVideoThumbnailKey : @[@"video", @"thumbnail_for_watch"],
                           WZYYouTubeWatchPageContentVideoStreamKey : @[@"player_data", @"fmt_stream_map"],
                           } mutableCopy];
    }
    return self;
}

- (BOOL)parsePageWithData:(NSData *)data copyTo:(WZYYouTubeVideo *)video error:(NSError **)theError
{
    NSError *error = nil;
    NSString* html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    if (html.length > 0) {
        NSString *jsonString = [self extractBootstrapData:html];
        if (jsonString) {
            
            NSError *jsonError = nil;
            NSDictionary* jsonData = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:&jsonError];
            
            if (!jsonError) {
                NSDictionary *contentAttributes = [self objectWithDictionary:jsonData forKey:WZYYouTubeWatchPageContentKey];
                if (contentAttributes.count == 0) {
                    NSArray *errors = [self objectWithDictionary:jsonData forKey:WZYYouTubeWatchPageErrorsKey];
                    NSString *errorMessage = errors[0];
                    if (!errorMessage) {
                        errorMessage = @"The content data could not be found.";
                    }
                    error = [WZYYouTubeError errorWithDomain:(NSString *)kWZYYouTubeVideoErrorDomain
                                                       code:WZYYouTubeVideoErrorCodeNoJSONData
                                                   userInfo:@{NSLocalizedDescriptionKey: errorMessage, @"errors": errors}];
                } else {
                    if (!video.title) {
                        video.title = [self objectWithDictionary:contentAttributes forKey:WZYYouTubeWatchPageContentVideoTitleKey];
                    }
                    if (video.duration == 0) {
                        NSNumber *lengthSeconds = [self objectWithDictionary:contentAttributes forKey:WZYYouTubeWatchPageContentVideoLengthKey];
                        video.duration = lengthSeconds.doubleValue;
                    }
                    if (!video.thumbnailURL) {
                        NSString *thumbnailForWatch =  [self objectWithDictionary:contentAttributes forKey:WZYYouTubeWatchPageContentVideoThumbnailKey];
                        if (thumbnailForWatch) {
                            video.thumbnailURL = [NSURL URLWithString:thumbnailForWatch];
                        }
                    }                    
                    video.contentAttributes = contentAttributes;
                    video.streamMap = [self objectWithDictionary:contentAttributes forKey:WZYYouTubeWatchPageContentVideoStreamKey];
                }

                
            } else {
                error = [WZYYouTubeError errorWithDomain:(NSString *)kWZYYouTubeVideoErrorDomain
                                                   code:WZYYouTubeVideoErrorCodeNoJSONData
                                               userInfo:@{NSLocalizedDescriptionKey: @"The JSON data could not be found."}];
            }
        } else {
            error = [WZYYouTubeError errorWithDomain:(NSString *)kWZYYouTubeVideoErrorDomain
                                               code:WZYYouTubeVideoErrorCodeNoJSONData
                                           userInfo:[NSDictionary dictionaryWithObject:@"The JSON data could not be found." forKey:NSLocalizedDescriptionKey]];
        }
        
        
    } else {
        error = [WZYYouTubeError errorWithDomain:(NSString *)kWZYYouTubeVideoErrorDomain
                                           code:WZYYouTubeVideoErrorCodeInvalidSource
                                       userInfo:@{NSLocalizedDescriptionKey: @"Couldn't download the HTML source code. URL might be invalid."}];
    }
    
    if (theError) {
        *theError = error;
    }
    
    return (error == nil);
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

//
//  WZYYouTubeMoviePlayerViewController.m
//  WZYYouTubePlayer
//
//  Copyright (c) 2012 makoto_kw. All rights reserved.
//

#import "WZYYouTubeMoviePlayerViewController.h"
#import "WZYYouTubeVideo.h"

@interface WZYYouTubeMoviePlayerViewController ()

@end

@implementation WZYYouTubeMoviePlayerViewController
{
    WZYYouTubeVideo *_video;
}

@synthesize video = _video;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)initWithWatchURL:(NSURL *)watchURL
{
    if (self = [super init]) {
        WZYYouTubeVideo *video = [[WZYYouTubeVideo alloc] initWithWatchURL:watchURL];
        [self playVideo:video completionHandler:nil];
    }
    return self;
}

- (id)initWithVideoID:(NSString *)videoID
{
    if (self = [super init]) {
        WZYYouTubeVideo *video = [[WZYYouTubeVideo alloc] initWithVideoID:videoID];
        [self playVideo:video completionHandler:nil];
    }
    return self;
}

- (id)initWithVideo:(WZYYouTubeVideo *)video
{
    if (self = [super init]) {
        [self playVideo:video completionHandler:nil];
    }
    return self;
}

- (void)playVideo:(WZYYouTubeVideo *)video completionHandler:(WZYYouTubeAsyncBlock)completionHandler
{
    _video = video;
    __weak WZYYouTubeMoviePlayerViewController *me = self;
    [_video retriveteDataFromWatchPageWithCompletionHandler:^(NSError *error) {
        if (!error) {
            NSURL *mediaURL = [video mediaURLWithQuality:WZYYouTubeVideoQualityLarge];
            me.moviePlayer.contentURL = mediaURL;
            [me.moviePlayer play];
        }
        if (completionHandler) {
            completionHandler(error);
        }        
    }];
}

@end

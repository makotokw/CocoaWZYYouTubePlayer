//
//  SubViewMoviePlayerViewController.m
//  MoviePlayerDemo
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import "SubViewMoviePlayerViewController.h"

#import "WZYYouTubePlayer.h"
#import "WZYYouTubeMoviePlayer.h"

@interface SubViewMoviePlayerViewController ()

@end

@implementation SubViewMoviePlayerViewController
{
    WZYYouTubeMoviePlayerController* _moviePlayerController;
}

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
    
    WZYYouTubeVideo *video = [[WZYYouTubeVideo alloc] initWithVideoID:@"NjXQcGmffu0"];
    WZYYouTubeMoviePlayerController *controller = [[WZYYouTubeMoviePlayerController alloc] initWithVideo:video];
    controller.view.frame = self.view.bounds;
    controller.view.backgroundColor = [UIColor blackColor];
    controller.view.autoresizingMask = UIViewAutoresizingFlexibleWidth |
    UIViewAutoresizingFlexibleHeight |
    UIViewAutoresizingFlexibleLeftMargin |
    UIViewAutoresizingFlexibleTopMargin |
    UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleBottomMargin;
    
    [self.view addSubview:controller.view];

    // retain
    _moviePlayerController = controller;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate
{
	return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end

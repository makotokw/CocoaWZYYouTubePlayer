//
//  MenuViewController.m
//  MoviePlayerDemo
//
//  Copyright (c) 2013 makoto_kw. All rights reserved.
//

#import "MenuViewController.h"

#import "WZYouTubePlayer.h"
#import "WZYouTubeMoviePlayer.h"

@interface MenuViewController ()

@end

@implementation MenuViewController

{
    NSArray *_items;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _items = @[
              @{
                  @"title": @"MoviePlayer",
                  @"children": @[
                              @{@"title": @"ModalViewController", @"detail": @"presentMoviePlayerViewController"},
                              @{@"title": @"SubView", @"detail": @"addSubView MoviePlayerController.view", @"segue":@"subViewMoviePlayer"}
                              ]
              }
              ];
    
    self.title = @"MoviePlayerDemo";
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

- (NSDictionary *)menuItemWithIndexthPath:(NSIndexPath *)indexPath
{
    return _items[indexPath.section][@"children"][indexPath.row];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _items.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_items[section][@"children"] count];
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    return _items[section][@"title"];
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    NSDictionary *item = [self menuItemWithIndexthPath:indexPath];
    cell.textLabel.text = item[@"title"];
    cell.detailTextLabel.text = item[@"detail"];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *item = [self menuItemWithIndexthPath:indexPath];
    
    if (indexPath.section == 0) {    
        if ([@"ModalViewController" isEqualToString:item[@"title"]]) {
            WZYouTubeMoviePlayerViewController *moviePlayerViewController
            = [[WZYouTubeMoviePlayerViewController alloc] initWithVideoID:@"NjXQcGmffu0"];
            [self presentMoviePlayerViewControllerAnimated:moviePlayerViewController];
        } else {
            [self performSegueWithIdentifier:item[@"segue"] sender:self];
        }
    }
}

@end

//
//  VLCLocalServerFolderListViewController.m
//  VLC for iOS
//
//  Created by Felix Paul Kühne on 10.08.13.
//  Copyright (c) 2013 VideoLAN. All rights reserved.
//
//  Refer to the COPYING file of the official project for license.
//

#import "VLCLocalServerFolderListViewController.h"
#import "MediaServerBasicObjectParser.h"
#import "MediaServer1ItemObject.h"
#import "MediaServer1ContainerObject.h"
#import "MediaServer1Device.h"
#import "VLCLocalNetworkListCell.h"

@interface VLCLocalServerFolderListViewController () <UITableViewDataSource, UITableViewDelegate>
{
    UIBarButtonItem *_backButton;

    MediaServer1Device *_device;
    NSString *_header;
    NSString *_rootID;

    NSMutableArray *_objectList;
}

@end

@implementation VLCLocalServerFolderListViewController

- (void)loadView
{
    _tableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor colorWithWhite:.122 alpha:1.];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    self.view = _tableView;
}

- (id)initWithDevice:(MediaServer1Device*)device header:(NSString*)header andRootID:(NSString*)rootID
{
    self = [super init];

    if (self) {
        _device = device;
        _header = header;
        _rootID = rootID;

        _objectList = [[NSMutableArray alloc] init];
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSMutableString *outResult = [[NSMutableString alloc] init];
    NSMutableString *outNumberReturned = [[NSMutableString alloc] init];
    NSMutableString *outTotalMatches = [[NSMutableString alloc] init];
    NSMutableString *outUpdateID = [[NSMutableString alloc] init];

    [[_device contentDirectory] BrowseWithObjectID:_rootID BrowseFlag:@"BrowseDirectChildren" Filter:@"*" StartingIndex:@"0" RequestedCount:@"0" SortCriteria:@"+dc:title" OutResult:outResult OutNumberReturned:outNumberReturned OutTotalMatches:outTotalMatches OutUpdateID:outUpdateID];

    [_objectList removeAllObjects];
    NSData *didl = [outResult dataUsingEncoding:NSUTF8StringEncoding];
    MediaServerBasicObjectParser *parser = [[MediaServerBasicObjectParser alloc] initWithMediaObjectArray:_objectList itemsOnly:NO];
    [parser parseFromData:didl];

    self.tableView.separatorColor = [UIColor colorWithWhite:.122 alpha:1.];
    self.view.backgroundColor = [UIColor colorWithWhite:.122 alpha:1.];

    self.title = _header;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
        return NO;
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _objectList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"LocalNetworkCellDetail";

    VLCLocalNetworkListCell *cell = (VLCLocalNetworkListCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
        cell = [VLCLocalNetworkListCell cellWithReuseIdentifier:CellIdentifier];

    MediaServer1BasicObject *item = _objectList[indexPath.row];

    if (![item isContainer]) {
        MediaServer1ItemObject *mediaItem = _objectList[indexPath.row];
        [cell setSubtitle:[NSString stringWithFormat:@"%@ - %@", mediaItem.size, mediaItem.duration]];
        [cell setIsDirectory:NO];
    } else
        [cell setIsDirectory:YES];

    [cell setTitle:[item title]];

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MediaServer1BasicObject *item = _objectList[indexPath.row];
    if ([item isContainer]) {
        MediaServer1ContainerObject *container = _objectList[indexPath.row];
        VLCLocalServerFolderListViewController *targetViewController = [[VLCLocalServerFolderListViewController alloc] initWithDevice:_device header:[container title] andRootID:[container objectID]];
        [[self navigationController] pushViewController:targetViewController animated:YES];
    } else {
        MediaServer1ItemObject *item = _objectList[indexPath.row];

        MediaServer1ItemRes *resource = nil;
        NSEnumerator *e = [[item resources] objectEnumerator];
        while((resource = (MediaServer1ItemRes*)[e nextObject])){
            NSLog(@"%@ - %d, %@, %d, %d, %d, %@", [item title], [resource bitrate], [resource duration], [resource nrAudioChannels], [resource size],  [resource durationInSeconds],  [resource protocolInfo] );
            NSLog(@"URI is %@", [item uri]);
        }

        //TODO DO SOMETHING USEFUL!
    }
}

@end
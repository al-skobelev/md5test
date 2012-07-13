//
//  ViewController.m
//  md5test
//
//  Created by Alexander Skobelev on 13/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MainVC.h"
#import "CommonUtils.h"

//============================================================================
@interface MainVC ()

@property (strong, nonatomic) NSMutableArray* files;
- (void) refresh;
- (void) calcMD5ForSelectedRow;
@end

//============================================================================
@implementation MainVC

@synthesize tableView = _tableView;
@synthesize activityIndicator = _activityIndicator;
@synthesize files = _files;

- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
    [self refresh];
}

//----------------------------------------------------------------------------
- (BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


//----------------------------------------------------------------------------
- (void) setupFiles
{
    id fm = [NSFileManager defaultManager];
    NSError* err = nil;
    NSArray* names = [fm contentsOfDirectoryAtPath: user_documents_path()
                                             error: &err];
    
    id arr = NSARRAY(nil);
    for (NSString* fname in names)
    {
        NSString* path = STR_ADDPATH(user_documents_path(), fname);
        NSError* err = nil;
        NSDictionary* attrs = [fm attributesOfItemAtPath: path
                                                   error: &err];

        id info = NSDICT(@"FNAME", fname,
                         @"SIZE", NSUINT (attrs.fileSize));

        [arr addObject: info];
    }
    self.files = arr;
}


//----------------------------------------------------------------------------
- (void) refresh
{
    [self setupFiles];
    [_tableView reloadData];
}

//----------------------------------------------------------------------------
- (void) calcMD5ForSelectedRow
{
    NSIndexPath* ipath = [_tableView indexPathForSelectedRow];

    if (ipath && (ipath.row < _files.count))
    {
        id info = [self.files objectAtIndex: ipath.row];
        NSString* fname = [info objectForKey: @"FNAME"];
        NSString* path = STR_ADDPATH(user_documents_path(), fname);
        uint64_t tm1 = host_time_us();
        NSString* md5 = md5_for_path (path);
        uint64_t tm2 = host_time_us();

        if (md5)
        {
            [info setObject: md5 forKey: @"MD5"];
            [info setObject: NSDOUBLE((double)(tm2 - tm1) / 1e6)
                     forKey: @"MD5TIME"];
        }
        [_tableView reloadRowsAtIndexPaths: NSARRAY(ipath)
                          withRowAnimation: NO];

    }
    
    dispatch_async (dispatch_get_main_queue(), ^{                

        [self.activityIndicator stopAnimating];
        self.view.userInteractionEnabled = YES;
    });
}

//----------------------------------------------------------------------------
- (IBAction) onRefreshBtn: (id) sender 
{
    [self refresh];
}


//----------------------------------------------------------------------------
- (IBAction) onMD5Btn: (id) sender 
{
    
    [self.activityIndicator startAnimating];
    self.activityIndicator.hidden = NO;
    self.view.userInteractionEnabled = NO;
    
    [self performSelectorInBackground: @selector(calcMD5ForSelectedRow)
                           withObject: nil];
}


//----------------------------------------------------------------------------
- (NSInteger) tableView: (UITableView*) tableView
  numberOfRowsInSection: (NSInteger) section
{
    return self.files.count;
}


//----------------------------------------------------------------------------
- (UITableViewCell*) tableView: (UITableView*) tv
         cellForRowAtIndexPath: (NSIndexPath*) indexPath
{
    UITableViewCell* cell = [tv dequeueReusableCellWithIdentifier: @"Cell"];
    if (! cell)
    {
        cell = [[UITableViewCell alloc] 
                   initWithStyle: UITableViewCellStyleSubtitle
                 reuseIdentifier: @"Cell"];
    }

    id info = [self.files objectAtIndex: indexPath.row];
    cell.textLabel.text = [info objectForKey: @"FNAME"];

    size_t size = [[info objectForKey: @"SIZE"] intValue];
    NSString* md5 = [info objectForKey: @"MD5"];
    double md5time = [[info objectForKey: @"MD5TIME"] doubleValue];

    NSString* subtitle = (size ? STRF(@"%dkB", size / 1024) : @"");

    NSString* md5str = (md5 ? STRF(@"%.2lf sec; %@", md5time, md5) : @"md5 not calculated yet");
    if (md5) subtitle = STRF(@"%@; %@", subtitle, md5str);
                        
    cell.detailTextLabel.text = subtitle;
    return cell;
}

//----------------------------------------------------------------------------
- (void) tableView: (UITableView*) tableView
didSelectRowAtIndexPath: (NSIndexPath*) ipath
{
}

- (void)viewDidUnload {
    [self setActivityIndicator:nil];
    [super viewDidUnload];
}
@end

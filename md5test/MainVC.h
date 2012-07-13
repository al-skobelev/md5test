//
//  ViewController.h
//  md5test
//
//  Created by Alexander Skobelev on 13/07/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainVC : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

- (IBAction) onRefreshBtn: (id) sender;
- (IBAction) onMD5Btn: (id) sender;
@end

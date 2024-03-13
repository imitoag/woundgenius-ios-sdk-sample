//
//  ViewController.h
//  SampleObjc
//
//  Created by Eugene Naloiko on 11.03.2024.
//  Copyright (c) 2022 by imito AG, Zurich, Switzerland
//

#import <UIKit/UIKit.h>
#import "SampleObjc-Swift.h"

@interface ViewController : UIViewController <WoundGeniusWrapperDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end


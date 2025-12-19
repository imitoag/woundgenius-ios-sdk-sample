//
//  ViewController.m
//  SampleObjc
//
//  Created by Eugene Naloiko on 11.03.2024.
//

#import "ViewController.h"

@interface ViewController ()

@property (strong, nonatomic) WoundGeniusWrapper *wgWrapper;

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.wgWrapper = [[WoundGeniusWrapper alloc] init];
    self.wgWrapper.delegate = self;
}

- (IBAction)startCapturing:(id)sender {
    NSArray *allFeatures = [self.wgWrapper allFeatures];
    
    for (NSString *feature in allFeatures) {
        NSLog(@"%@ %@", feature, [self.wgWrapper isAvailableWithFeature:feature] ? @"Available" : @"Not available");
    }
    
    if ([self.wgWrapper isAvailableWithFeature:@"photoCapturing"] &&
        [self.wgWrapper isAvailableWithFeature:@"markerMeasurementCapturing"] &&
        [self.wgWrapper isAvailableWithFeature:@"rulerMeasurementCapturing"] &&
        [self.wgWrapper isAvailableWithFeature:@"woundDetection"]) {
        [self.wgWrapper startCapturingWithOver:self];
    } else {
        NSLog(@"%@", @"Please verify the license key in WoundGeniusWrapper.swift - Invalid license or some of the features in this sample are not unlocked by your license.");
    }
}

- (void)newDataCaptured { 
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.wgWrapper numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.wgWrapper numberOfItemsWithSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.imageView.image = [self.wgWrapper imageForSection:[indexPath section] row:[indexPath row]];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    cell.textLabel.text = [self.wgWrapper descriptionForSection:[indexPath section] row:[indexPath row]];
    cell.imageView.transform = CGAffineTransformScale(CGAffineTransformIdentity, .5, .5);

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    [self.wgWrapper showMediaWithSection:[indexPath section] row:[indexPath row] over:self];
}

@end

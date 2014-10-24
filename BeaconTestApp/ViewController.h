//
//  ViewController.h
//  BeaconTestApp
//
//  Created by Earl Hsieh on 2014/7/24.
//  Copyright (c) 2014年 ___FULLUSERNAME___. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"
//#import "BLE.h"

#define ENABLE_UUID_LOCK

@interface ViewController : UITableViewController< UITableViewDataSource,
                                                   UITableViewDelegate> {
    NSMutableArray *myBLEDeviceName;
    NSMutableArray *myBLEDeviceUUID;
    NSMutableArray *myBLEPeripheral;
    BLE *adataBLE;
}

@property (strong, nonatomic) IBOutlet UISegmentedControl *myScanSegmentedCtrl;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnScanState;
@property (strong, nonatomic) IBOutlet UITableView *tbvScan;

@property (strong, nonatomic) AppDelegate *appDelegate;

@property NSInteger tbvCount;

-(IBAction)btnScanController:(id)sender;

@end

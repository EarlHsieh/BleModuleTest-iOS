//
//  ViewController.m
//  BeaconTestApp
//
//  Created by Earl Hsieh on 2014/7/24.
//  Copyright (c) 2014年 ___FULLUSERNAME___. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize tbvCount;
@synthesize myScanSegmentedCtrl;
@synthesize tbvScan;
@synthesize appDelegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    //Share AppDelegate to ViewController, and initial component adataBLE.
    appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    appDelegate.adataBLE = [[BLE alloc] init];

    // Set table view delegate and data source.
    self.tbvScan.delegate = self;
    self.tbvScan.dataSource = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *  NAME
 *      - (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
 *
 *  DESCRIPTION
 *      Return the number of sections in table view.
 *
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

/**
 *  NAME
 *      -(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
 *
 *  DESCRIPTION
 *      Return the number of row in section.
 */
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [appDelegate.adataBLE.adataBLEScanPeripheral count];
}

/**
 *  NAME
 *      - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
 *
 *  DESCRIPTION
 *      Show text to cell in the table view.
 *
 */
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    CBPeripheral *setTbvInfoPeripheral =
                    [appDelegate.adataBLE.adataBLEScanPeripheral objectAtIndex:indexPath.row];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault
                                     reuseIdentifier:cellIdentifier];
    }

    cell.textLabel.text = setTbvInfoPeripheral.name;
    cell.detailTextLabel.text = setTbvInfoPeripheral.identifier.UUIDString;
    return cell;
}

/**
 *  NAME
 *      - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
 *
 *  DESCRIPTION
 *      Select cell to get peripheral and connect to BLE.
 *
 */
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    appDelegate.adataBLE.currentPeripheralCtrl =
            [appDelegate.adataBLE.adataBLEScanPeripheral objectAtIndex:indexPath.row];
    
    self.myScanSegmentedCtrl.selectedSegmentIndex = 0;
    [appDelegate.adataBLE stopScanBLEDevice];
    [self removeBLEInfo];
    [appDelegate.adataBLE.adataCBCentralManager
            connectPeripheral:appDelegate.adataBLE.currentPeripheralCtrl options:nil];
}

/**
 *  NAME
 *      - (void) updateTableView
 *
 *  DESCRIPTION
 *      Update table view.
 *
 */
-(void)updateTableView
{
    [self.tbvScan reloadData];
}

/**
 *  NAME
 *      - (void)removeBLEInfo
 *
 *  DESCRIPTION
 *      Remove BLE scan info and reload table view.
 *
 */
-(void)removeBLEInfo
{
    [appDelegate.adataBLE.adataBLEScanPeripheral removeAllObjects];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self updateTableView];
}

/**
 *  NAME
 *      - (IBAction)btnScanController:(id)sender
 *
 *  DESCRIPTION
 *      Press this button to scan adata lighting device.
 *
 */
-(IBAction)btnScanController:(id)sender
{
    switch (self.myScanSegmentedCtrl.selectedSegmentIndex) {
        case STOP_SCAN:
           [appDelegate.adataBLE stopScanBLEDevice];
            [[NSNotificationCenter defaultCenter] removeObserver:self];
   			NSLog(@"Stop!!");
            break;

        case SCAN_DEVICE:
            [appDelegate.adataBLE stopScanBLEDevice];
            [self removeBLEInfo];
            // Add a oberserver to let UI update TableView itself.
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTableView) name:@"reloadTbv" object:nil];
            [appDelegate.adataBLE startScanBLEDevice];
            NSLog(@"Scaning...");
            break;

        default:
            // shouldn't have this state
            break;
            
    }
}

@end

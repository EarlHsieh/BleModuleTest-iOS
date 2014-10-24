//
//  BLE.h
//  BeaconTestApp
//
//  Created by Earl Hsieh on 2014/10/13.
//  Copyright (c) 2014年 Earl Hsieh. All rights reserved.
//

#ifndef BeaconTestApp_BLE_h
#define BeaconTestApp_BLE_h

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>


#define STOP_SCAN       0
#define SCAN_DEVICE     1

@interface AdataUUIDInfo : NSObject
{
    NSString *uuid;
    CBCharacteristic *characteristic;
}

@property (strong, nonatomic) NSString *uuid;

@property (strong, nonatomic) CBCharacteristic *charateristic;

@end

@interface BLE : NSObject <CBPeripheralManagerDelegate,
                            CBCentralManagerDelegate,
                            CBPeripheralDelegate>
{
    BOOL isScanDevice;
    CBCentralManager *adataCBCentralManager;
    CBPeripheral *currentPeripheralCtrl;
    NSMutableArray *adataBLEScanPeripheral;
    NSMutableArray *adataUUIDPeripheral;
}

@property (strong, nonatomic) CBCentralManager *adataCBCentralManager;

@property (strong, nonatomic) CBPeripheral *currentPeripheralCtrl;

@property (strong, nonatomic) NSMutableArray *adataBLEScanPeripheral;

@property (strong, nonatomic) NSMutableArray *adataUUIDPeripheral;

-(void) stopScanBLEDevice;

-(void) startScanBLEDevice;

-(void) writeDataToUUID:(CBCharacteristic *)characteristic data:(NSData *)data;
@end


#endif

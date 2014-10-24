//
//  BLE.m
//  BeaconTestApp
//
//  Created by Earl Hsieh on 2014/10/13.
//  Copyright (c) 2014年 Earl Hsieh. All rights reserved.
//


#import "BLE.h"

@implementation AdataUUIDInfo

@synthesize uuid;
@synthesize charateristic;

@end

@implementation BLE

@synthesize adataCBCentralManager;
@synthesize currentPeripheralCtrl;
@synthesize adataBLEScanPeripheral;
@synthesize adataUUIDPeripheral;

/**
 *  Initial CBCentralManager and default parameters.
 */
- (id) init {
    self = [super init];
    
    if (self) {
        adataCBCentralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        adataBLEScanPeripheral = [[NSMutableArray alloc] init];
        adataUUIDPeripheral = [[NSMutableArray alloc] init];
        isScanDevice = FALSE;
    }
    
    return self;
}

/**
 *  Show BLE status by debug message
 */
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSString *messtoshow;
    
    switch (central.state) {
            
        case CBCentralManagerStateUnknown:
        {
            messtoshow =
            [NSString stringWithFormat:@"State unknown, update imminent."];
            break;
        }
            
        case CBCentralManagerStateResetting:
        {
            messtoshow =
            [NSString stringWithFormat:@"The connection with the system service was momentarily lost, update imminent."];
            break;
        }
            
        case CBCentralManagerStateUnsupported:
        {
            messtoshow =
            [NSString stringWithFormat:@"The platform doesn't support Bluetooth Low Energy"];
            break;
        }
            
        case CBCentralManagerStateUnauthorized:
        {
            messtoshow =
            [NSString stringWithFormat:@"The app is not authorized to use Bluetooth Low Energy"];
            break;
        }
            
        case CBCentralManagerStatePoweredOff:
        {
            messtoshow =
            [NSString stringWithFormat:@"Bluetooth is currently powered off."];
            break;
        }
            
        case CBCentralManagerStatePoweredOn:
        {
            messtoshow =
            [NSString stringWithFormat:@"Bluetooth is currently powered on and available to use."];
            
            //[adataCBCentralManager scanForPeripheralsWithServices:nil options:nil];
            break;
        }
            
    }
    
    NSLog(@"%@", messtoshow);
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    NSString *message;
    switch (peripheral.state) {
        case CBPeripheralManagerStateUnknown:
            message = [NSString stringWithFormat:@"State is Unknown."];
            break;
        case CBPeripheralManagerStateResetting:
            message = [NSString stringWithFormat:@"State is Restting."];
            break;
        case CBPeripheralManagerStateUnsupported:
            message = [NSString stringWithFormat:@"State is UnSupport."];
            break;
        case CBPeripheralManagerStateUnauthorized:
            message = [NSString stringWithFormat:@"State is Unauthorized."];
            break;
        case CBPeripheralManagerStatePoweredOff:
            message = [NSString stringWithFormat:@"state is Power-Off."];
            break;
        case CBPeripheralManagerStatePoweredOn:
            message = [NSString stringWithFormat:@"state is Power-On."];
            break;
    }
    
    NSLog(@"%@", message);
}

/**
 *  Add device name to cell in the table view after
 *  user press scan button.
 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    if (isScanDevice == true) {
        NSLog(@"%@", [advertisementData description]);
        
        [adataBLEScanPeripheral addObject:peripheral];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadTbv" object:self];
    }
}

/**
 *  Device has been conenected.
 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"Connected device, name: %@, UUID: %@", peripheral.name,
          peripheral.identifier.UUIDString);

    if (adataCBCentralManager) {
        currentPeripheralCtrl.delegate = self;
        [currentPeripheralCtrl discoverServices:nil];
    }
}

/**
 *  Service has been discovered, disrcovery charateristics.
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    for (CBService *service in peripheral.services) {
        NSLog(@"service: %@", service);

        [currentPeripheralCtrl discoverCharacteristics:nil forService:service];
    }
}

/**
 *  Filter charateristic from adata feature UUID.
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    NSString *adataFeatureUUDI = [NSString stringWithFormat:@"7877"];
    NSString *serviceUUID = [NSString stringWithFormat:@"%@", service.UUID];

    if ([serviceUUID isEqualToString:adataFeatureUUDI]) {
        for (CBCharacteristic *characterisctic in service.characteristics) {
            NSLog(@"discoverd charaterisctic: %@", characterisctic);
            NSString *uuid = [NSString stringWithFormat:@"%@", characterisctic.UUID];
            
            AdataUUIDInfo *adataUUIDInfo = [[AdataUUIDInfo alloc] init];
            adataUUIDInfo.uuid = uuid;
            adataUUIDInfo.charateristic = characterisctic;
            [adataUUIDPeripheral addObject:adataUUIDInfo];
        }

        [[NSNotificationCenter defaultCenter] postNotificationName:@"waitingAlertViewCtrl" object:self];
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error
{
    NSString *message = [NSString stringWithFormat:@"%@", RSSI];
    NSLog(@"%@", message);
}

/**
 *  Entry to here if write value has callback!!
 */
- (void)peripheral:(CBPeripheral *) peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"Error writing characteristic value: %@", [error localizedDescription]);
    }
}

/**
 *  Set isScanDevice to false and asked iPhone do not scan Device.
 */
-(void) stopScanBLEDevice
{
    isScanDevice = false;
    [adataCBCentralManager stopScan];
}

/**
 *  Start to scan BLE device, only scan advertising UUID "FEF1"(it's CSR mesh UUID).
 */
-(void) startScanBLEDevice
{
    CBUUID *adataLightingUUID = [CBUUID UUIDWithString:@"FEF1"];

    isScanDevice = true;
    [adataCBCentralManager stopScan];
    [adataCBCentralManager scanForPeripheralsWithServices:@[adataLightingUUID] options:nil];
}

#if 0
-(void) readRSSI
{
    [
}
#endif

/**
 *  Call this function to write value to BLE device.
 */
-(void) writeDataToUUID:(CBCharacteristic *)writeCharacteristic data:(NSData *)data
{
    [currentPeripheralCtrl writeValue:data forCharacteristic:writeCharacteristic type:CBCharacteristicWriteWithResponse];
}

@end
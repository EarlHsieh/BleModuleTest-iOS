//
//  AppDelegate.h
//  BeaconTestApp
//
//  Created by Earl Hsieh on 2014/7/24.
//  Copyright (c) 2014年 ___FULLUSERNAME___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLE.h"

@protocol AppDelegate <NSObject>

@end

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) BLE *adataBLE;

@end

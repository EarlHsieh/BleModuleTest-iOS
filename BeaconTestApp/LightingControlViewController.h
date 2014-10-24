//
//  LightingControlViewController.h
//  BeaconTestApp
//
//  Created by Earl Hsieh on 2014/7/28.
//  Copyright (c) 2014年 Earl Hsieh. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"

@interface LightingControlViewController : UIViewController
{
    UIAlertView *waitingAlert;
    UIImageView *colorPaletteImageView;
    UIImageView *brightImageView;
}

@property (strong, nonatomic) AppDelegate *appDelegate;

@property (strong, nonatomic) UIAlertView *waitingAlert;

@property (strong, nonatomic) UIImageView *colorPaletteImageView;

@property (strong, nonatomic) UIImageView *colorTempImageView;

@property (strong, nonatomic) UIImageView *brightImageView;

@end

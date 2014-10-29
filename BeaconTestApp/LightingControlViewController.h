//
//  LightingControlViewController.h
//  BeaconTestApp
//
//  Created by Earl Hsieh on 2014/7/28.
//  Copyright (c) 2014年 Earl Hsieh. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"

#import "LightingPaletteComponent/LightingPaletteComponent.h"

@interface LightingControlViewController : UIViewController
{
    LightingPaletteComponent *palette;
    UIAlertView *waitingAlert;
    UIImageView *colorWheelImageView;
    UIImageView *colorBrightnessImageView;
    UIImageView *indicateImageView;
    UISlider *colorTempSlider;
    UISlider *colorBrightSlider;
    UISwitch *powerSwitch;
    double updateTime;
    BOOL isOutputRGB;
    BitmapPixel lastRGB;
}

@property (strong, nonatomic) AppDelegate *appDelegate;

@property (strong, nonatomic) LightingPaletteComponent *palette;

@property (strong, nonatomic) UIAlertView *waitingAlert;

@property (strong, nonatomic) UIImageView *colorWheelImageView;

@property (strong, nonatomic) UIImageView *colorTempImageView;

@property (strong, nonatomic) UIImageView *colorBrightnessImageView;

@property (strong, nonatomic) UIImageView *indicateImageView;

@property (strong, nonatomic) UISlider *colorTempSlider;

@property (strong, nonatomic) UISlider *colorBrightSlider;

@property (strong, nonatomic) UISwitch *powerSwitch;

@end

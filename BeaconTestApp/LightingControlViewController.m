//
//  LightingControlViewController.m
//  BeaconTestApp
//
//  Created by Earl Hsieh on 2014/7/28.
//  Copyright (c) 2014年 Earl Hsieh. All rights reserved.
//

#import "LightingControlViewController.h"

#define UUID_ADATA_MAGIC            0xfc06

@interface LightingControlViewController()

@end

@implementation LightingControlViewController

@synthesize appDelegate;
@synthesize palette;
@synthesize waitingAlert;
@synthesize colorBrightnessImageView;
@synthesize colorWheelImageView;
@synthesize colorTempImageView;
@synthesize indicateImageView;
@synthesize colorTempSlider;
@synthesize colorBrightSlider;
@synthesize powerSwitch;

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view, typically from a nib.
    // get globle value and set navigation title.
    appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    self.navigationItem.title =
        [[NSString alloc] initWithFormat:@"%@", appDelegate.adataBLE.currentPeripheralCtrl.name];

    palette = [[LightingPaletteComponent alloc] init];

    colorTempSlider = [[UISlider alloc] init];
    colorBrightSlider = [[UISlider alloc] init];
    [self createWaitingAlert];
    [self createColorWheelImageView];
    [self createColorTempImageView];
    [self createColorBrigtnessImageView];
    [self createSliderAndSwitch];
    isOutputRGB = FALSE;
    isColorWheelTouched = FALSE;
}

- (void)viewWillDisappear:(BOOL)animated
{
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        NSLog(@"Back button has been pressed!!");
    }

    [appDelegate.adataBLE.adataCBCentralManager
            cancelPeripheralConnection:appDelegate.adataBLE.currentPeripheralCtrl];

    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *  NAME
 *      -(void)createWaitingAlert
 *
 *  DESCRIPTION
 *      Create alert view until charateristic has been discovered for adata UUID.
 *
 */
-(void)createWaitingAlert
{
    waitingAlert = [[UIAlertView alloc] initWithTitle:@"PLEASE WAIT" message:@"Device under connecting" delegate:nil cancelButtonTitle:nil otherButtonTitles: nil];
    
    [waitingAlert show];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissWaitingAlert) name:@"waitingAlertViewCtrl" object:nil];
}

/**
 *  NAME
 *      -(void)dismissWaitingAlert
 *
 *  DESCRIPTION
 *      Dismiss alert view, it will trigger with all adata charateristic hasn been discovered.
 *
 */
-(void)dismissWaitingAlert
{
    [waitingAlert dismissWithClickedButtonIndex:0 animated:NO];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self unlockAdataUUIDMagic];
}

/**
 *  NAME
 *      - (CBCharacteristic *)getCharacteristic:(NSString *)uuid
 *
 *  DESCRIPTION
 *      Get service characteristic according to UUID.
 *
 */
- (CBCharacteristic *)getCharacteristic:(NSString *)uuid
{
    for (AdataUUIDInfo *peripheral in appDelegate.adataBLE.adataUUIDPeripheral) {
        if ([peripheral.uuid isEqualToString:uuid]) {
            return peripheral.charateristic;
        }
    }
    
    return nil;
}


/**
 *  NAME
 *      -(void)unlockAdataUUIDMagic
 *
 *  DESCRIPTION
 *      Send 0xFC06 to characteristic UUID 7878 to unlock adata feature.
 *
 */
-(void)unlockAdataUUIDMagic
{
    NSString *uuid = [[NSString alloc] initWithFormat:@"7878"];
    uint magic = ((UUID_ADATA_MAGIC & 0xff) << 8) |
                 ((UUID_ADATA_MAGIC >> 8) & 0xff);
    NSData *magicData = [NSData dataWithBytes:&magic length:sizeof(magic)];
    CBCharacteristic *charateristic = [self getCharacteristic:uuid];

    [appDelegate.adataBLE writeDataToUUID:charateristic data:magicData];
}

/**
 *  NAME
 *      -(void)setPowerStateToBLEDevice:(BOOL)isOn
 *
 *  DESCRIPTION
 *      Send Power state to remote BLE device.
 *
 */
-(void)setPowerStateToBLEDevice:(BOOL)isOn
{
    NSString *uuid = [[NSString alloc] initWithFormat:@"7882"];
    NSLog(@"PowerState: %d", isOn);
    
    UInt32 writeData = isOn;
    NSData *data = [NSData dataWithBytes:&writeData length:sizeof(writeData)];
    CBCharacteristic *charateristic = [self getCharacteristic:uuid];
    
    [appDelegate.adataBLE writeDataToUUID:charateristic data:data];
}


/**
 *  NAME
 *      -(void)setColorToBLEDeviceByRed:(CGFloat)red Green:(CGFloat)green Blue:(CGFloat)blue
 *
 *  DESCRIPTION
 *      Send RGB value to remote BLE device.
 *
 */
-(void)setColorToBLEDeviceByRed:(CGFloat)red Green:(CGFloat)green Blue:(CGFloat)blue
{
    int setRed = red * 255;
    int setGreen = green * 255;
    int setBlue = blue * 255;

    NSString *uuid = [[NSString alloc] initWithFormat:@"7883"];
    NSLog(@"Red: %d, Green: %d, Blue: %d", setRed, setGreen, setBlue);

    UInt32 writeData = (setRed) | (setGreen << 8) | (setBlue << 16);
    NSData *data = [NSData dataWithBytes:&writeData length:sizeof(writeData)];
    CBCharacteristic *charateristic = [self getCharacteristic:uuid];

    [appDelegate.adataBLE writeDataToUUID:charateristic data:data];
}

/**
 *  NAME
 *      -(void)setColorTempToBLEDeviceByColorTemp:(int)colorTemp Level:(int)level
 *
 *  DESCRIPTION
 *      Send Color Temperature value to remote BLE device.
 *
 */
-(void)setColorTempToBLEDeviceByColorTemp:(int)colorTemp Level:(int)level
{
    int setColorTemp = colorTemp * 100;
    NSString *uuid = [[NSString alloc] initWithFormat:@"7884"];
    NSLog(@"Color Temperature: %d, level: %d", setColorTemp, level);

    UInt32 writeData = ((setColorTemp & 0xff) << 8) |
                       ((setColorTemp >> 8) & 0xff) |
                        level;
    NSData *data = [NSData dataWithBytes:&writeData length:sizeof(writeData)];
    CBCharacteristic *charateristic = [self getCharacteristic:uuid];

    [appDelegate.adataBLE writeDataToUUID:charateristic data:data];
}

/**
 *  NAME
 *      -(void)createColorWheelImageView
 *
 *  DESCRIPTION
 *      Create a simple color palette.
 *
 */
-(void)createColorWheelImageView
{
    CGFloat notificationBarHeight = [[UIScreen mainScreen] bounds].size.height -
                                    [[UIScreen mainScreen] applicationFrame].size.height;
    CGFloat navigationHeight = self.navigationController.navigationBar.frame.size.height;

    CGFloat startPointX = notificationBarHeight / 2;
    CGFloat startPointY = (notificationBarHeight * 2) +
                          navigationHeight;
    CGFloat imageWidth = [[UIScreen mainScreen] bounds].size.width - notificationBarHeight;

    CGRect imageFrame = CGRectMake(startPointX, startPointY, imageWidth, imageWidth);

    colorWheelImageView =
            [[UIImageView alloc]initWithImage:[palette createColorWheelImageWithFrame:imageFrame]];
    colorWheelImageView.frame = imageFrame;
    colorWheelImageView.layer.masksToBounds = YES;
    colorWheelImageView.layer.cornerRadius = imageWidth / 2;

    [self.view addSubview:colorWheelImageView];

    CGFloat indecateCenterX = startPointX + (imageWidth / 2);
    CGFloat indecateCenterY = startPointY + (imageWidth / 2);
    [self createIndicateImageViewAtX:indecateCenterX atY:indecateCenterY];
}

/**
 *  NAME
 *      -(void)createColorTempImageView
 *
 *  DESCRIPTION
 *      Create color temperature image view.
 *
 */
-(void)createColorTempImageView
{
    CGFloat notificationBarHeight = [[UIScreen mainScreen] bounds].size.height -
                                    [[UIScreen mainScreen] applicationFrame].size.height;

    CGFloat startPointX = colorWheelImageView.frame.origin.x;
    CGFloat startPointY = colorWheelImageView.frame.origin.y +
                          colorWheelImageView.frame.size.height +
                          notificationBarHeight;
    CGFloat imageWidth = colorWheelImageView.frame.size.width;
    CGFloat imageHeight = colorTempSlider.frame.size.height;

    CGRect imageFrame = CGRectMake(startPointX, startPointY, imageWidth, imageHeight);

    colorTempImageView =
            [[UIImageView alloc]initWithImage:[palette createColorTempImageWithFrame:imageFrame]];
    colorTempImageView.frame = imageFrame;
    
    [self.view addSubview:colorTempImageView];
}

/**
 *  NAME
 *      -(void)createColorBrigtnessImageView
 *
 *  DESCRIPTION
 *      Create color brightness image view.
 *
 */
-(void)createColorBrigtnessImageView
{
    CGFloat notificationBarHeight = [[UIScreen mainScreen] bounds].size.height -
                                    [[UIScreen mainScreen] applicationFrame].size.height;

    CGFloat startPointX = colorTempImageView.frame.origin.x;
    CGFloat startPointY = colorTempImageView.frame.origin.y +
                          colorTempImageView.frame.size.height +
                          notificationBarHeight;
    CGFloat imageWidth = colorTempImageView.frame.size.width;
    CGFloat imageHeight = colorBrightSlider.frame.size.height;

    CGRect imageFrame = CGRectMake(startPointX, startPointY, imageWidth, imageHeight);

    colorBrightnessImageView =
            [[UIImageView alloc]initWithImage:[palette createColorBrightnessImageWithFrame:imageFrame]];
    colorBrightnessImageView.frame = imageFrame;
    
    [self.view addSubview:colorBrightnessImageView];
    [self.view addSubview:colorBrightSlider];
}

/**
 *  NAME
 *      -(void)createIndicateImageViewAtX:(CGFloat)x atY:(CGFloat)y
 *
 *  DESCRIPTION
 *      create indicate image view.
 *
 */
-(void)createIndicateImageViewAtX:(CGFloat)x atY:(CGFloat)y
{
    CGFloat notificationBarHeight = [[UIScreen mainScreen] bounds].size.height -
                                    [[UIScreen mainScreen] applicationFrame].size.height;
    CGFloat startPointX = x - (notificationBarHeight / 2);
    CGFloat startPointY = y - (notificationBarHeight / 2);
    CGFloat imageWidth = notificationBarHeight;
    CGRect imageFrame = CGRectMake(startPointX, startPointY, imageWidth, imageWidth);

    indicateImageView =
            [[UIImageView alloc]initWithImage:[palette createColorIndicateImageWithFrame:imageFrame]];
    indicateImageView.frame = imageFrame;
    
    [self.view addSubview:indicateImageView];
}


/**
 *  NAME
 *      createSliderAndSwitch
 *
 *  DESCRIPTION
 *      Create colorTempSlider, colorBrightSlider, powerSwitch.
 *
 */
-(void)createSliderAndSwitch
{
    CGFloat notificationBarHeight = [[UIScreen mainScreen] bounds].size.height -
                                    [[UIScreen mainScreen] applicationFrame].size.height;
    UIImage *clearTrackerImage = [[UIImage alloc] init];

    //Create color temp slider
    colorTempSlider.frame = colorTempImageView.frame;
    colorTempSlider.minimumValue = COLOR_TEMP_MIN / 100;
    colorTempSlider.maximumValue = COLOR_TEMP_MAX / 100;
    colorTempSlider.value = colorTempSlider.minimumValue;
    [colorTempSlider setMinimumTrackImage:clearTrackerImage forState:UIControlStateNormal];
    [colorTempSlider setMaximumTrackImage:clearTrackerImage forState:UIControlStateNormal];
    [colorTempSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:colorTempSlider];

    //Create color bright slider
    colorBrightSlider.frame = colorBrightnessImageView.frame;
    colorBrightSlider.minimumValue = 0;
    colorBrightSlider.maximumValue = 100;
    colorBrightSlider.value = colorBrightSlider.maximumValue;
    [colorBrightSlider setMinimumTrackImage:clearTrackerImage forState:UIControlStateNormal];
    [colorBrightSlider setMaximumTrackImage:clearTrackerImage forState:UIControlStateNormal];
    [colorBrightSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:colorBrightSlider];

    //Create power switch.
    CGFloat powerSwitchWidth = [[UISwitch alloc] init].frame.size.width;
    CGFloat powerswitchHeight = [[UISwitch alloc] init].frame.size.height;
    CGFloat powerSwitchPointX = colorBrightnessImageView.frame.origin.x +
                                (colorBrightnessImageView.frame.size.width / 2) -
                                (powerSwitchWidth / 2);
    CGFloat powerSwitchPointY = colorBrightnessImageView.frame.origin.y +
                                colorBrightnessImageView.frame.size.height +
                                notificationBarHeight;

    powerSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(powerSwitchPointX,
                                                             powerSwitchPointY,
                                                             powerSwitchWidth,
                                                             powerswitchHeight)];
    [powerSwitch setOn:TRUE];
    [powerSwitch addTarget:self action:@selector(swtichValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:powerSwitch];
}

/**
 *  NAME
 *      -(void)updateIndicatorImageAt:(CGFloat)x atY:(CGFloat)y
 *
 *  DESCRIPTION
 *      remove and re-create indicator image
 *
 */
-(void)updateIndicatorImageAt:(CGFloat)x atY:(CGFloat)y
{
    [indicateImageView removeFromSuperview];
    [self createIndicateImageViewAtX:x atY:y];
}

/**
 *  NAME
 *      -(void)updateBrightnessImage
 *
 *  DESCRIPTION
 *      remove and re-create color brightness image.
 *
 */
-(void)updateBrightnessImage
{
    [colorBrightnessImageView removeFromSuperview];
    [self createColorBrigtnessImageView];
}

/**
 *  NAME
 *      -(void)swtichValueChanged:(id)sender
 *
 *  DESCRIPTION
 *      For button has been touched.
 *
 */
-(void)swtichValueChanged:(id)sender
{
    UISwitch *switchUI = (UISwitch *)sender;

    if (switchUI == powerSwitch) {
        if (switchUI.on) {
            BitmapPixel rgbSettingValue;

            rgbSettingValue = [self getRGBSetValue];
            [self setColorToBLEDeviceByRed:rgbSettingValue.red Green:rgbSettingValue.green Blue:rgbSettingValue.blue];
            [self setPowerStateToBLEDevice:TRUE];
        } else {
            [self setColorToBLEDeviceByRed:0.0 Green:0.0 Blue:0.0];
            [self setPowerStateToBLEDevice:FALSE];
        }
    }
}

/**
 *  NAME
 *      -(void)sliderValueChanged:(id)sender
 *
 *  DESCRIPTION
 *      For slider has been moved.
 *
 */
-(void)sliderValueChanged:(id)sender
{
    UISlider *sliderUI = (UISlider *) sender;
    int colorTemp = floor(colorTempSlider.value);
    int level = floor(colorBrightSlider.value);
    static int preColorTemp;
    static int preLevel;

    if (sliderUI == colorTempSlider) {
        if (preColorTemp != colorTemp) {
            [palette setColorTempByUser:colorTemp];
            [self updateBrightnessImage];
            [self setColorTempToBLEDeviceByColorTemp:colorTemp Level:level];
            isOutputRGB = FALSE;
            preColorTemp = colorTemp;
        }
    } else if (sliderUI == colorBrightSlider) {
        if (isOutputRGB) {
            BitmapPixel rgbSettingValue;
            rgbSettingValue = [self getRGBSetValue];
            [self setColorToBLEDeviceByRed:rgbSettingValue.red Green:rgbSettingValue.green Blue:rgbSettingValue.blue];
        } else {
            if (preLevel != level) {
                [self setColorTempToBLEDeviceByColorTemp:colorTemp Level:level];
                preLevel = level;
            }
        }
    }
}

/**
 *  NAME
 *      -(BOOL)isValidTouchPointByRadius:(CGFloat)radius atX:(CGFloat)x atY:(CGFloat)y
 *
 *  DESCRIPTION
 *      Calculator touch point, return TRUE if user touch in circle shape on color wheel.
 *
 */
-(BOOL)isValidTouchPointByRadius:(CGFloat)radius atX:(CGFloat)x atY:(CGFloat)y
{
    CGFloat pointX = radius - x;
    CGFloat pointY = y - radius;
    CGFloat r_distance = sqrtf(pow(pointX, 2) + pow(pointY, 2));

    if (r_distance > radius) {
        return FALSE;
    }

    return TRUE;
}

/**
 *  NAME
 *      -(BOOL)updateUIWithTouchEvent:(UITouch *)touch
 *
 *  DESCRIPTION
 *      Update indicator and brightness image if user touch in circle shape on color wheel.
 *
 */
-(void)updateUIWithTouchEvent:(UITouch *)touch
{
    CGPoint touchPoint = [touch locationInView:self.view];


    CGPoint colorWheelCenter = CGPointMake((colorWheelImageView.frame.origin.x +
                                            (colorWheelImageView.frame.size.width / 2)),
                                           (colorWheelImageView.frame.origin.y +
                                            (colorWheelImageView.frame.size.width / 2)));
    CGFloat remoteDistance = sqrt(pow(touchPoint.x - colorWheelCenter.x, 2) +
                                  pow(touchPoint.y - colorWheelCenter.y, 2));
    CGFloat radius = colorWheelImageView.frame.size.width / 2;

    if (remoteDistance > radius) {
        CGFloat n = radius / (remoteDistance - radius);
        CGPoint correspondPoint = CGPointMake(((colorWheelCenter.x + (n * touchPoint.x)) / (1 + n)),
                                              ((colorWheelCenter.y + (n * touchPoint.y)) / (1 + n)));

        [palette getColorPixelByRadius:radius
                                   atX:(correspondPoint.x - colorWheelImageView.frame.origin.x)
                                   atY:(correspondPoint.y - colorWheelImageView.frame.origin.y)];

        [self updateIndicatorImageAt:correspondPoint.x atY:correspondPoint.y];
        [self updateBrightnessImage];

        return;
    }

    CGPoint colorWheelPoint = [touch locationInView:colorWheelImageView];

    [palette getColorPixelByRadius:radius atX:colorWheelPoint.x atY:colorWheelPoint.y];
    [self updateIndicatorImageAt:touchPoint.x atY:touchPoint.y];
    [self updateBrightnessImage];
}

/**
 *  NAME
 *      -(BitmapPixel)getRGBSetValue
 *
 *  DESCRIPTION
 *      Convert RGB with color level.
 *
 */
-(BitmapPixel)getRGBSetValue
{
    int level = floor(colorBrightSlider.value);
    ColorConvertFormula *convert = [[ColorConvertFormula alloc] init];
    BitMapHSV getHSVData = [convert RGBToHSVByRed:lastRGB.red Green:lastRGB.green Blue:lastRGB.blue];
    BitmapPixel getRGBData =[convert HSVToRGBByHue:getHSVData.hue Saturation:getHSVData.saturation Value:getHSVData.value * (1 / level)];

    return getRGBData;
}

/**
 *  NAME
 *      -(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
 *
 *  DESCRIPTION
 *      Update color brightness image.
 *
 */
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self.view];

    if ((touchPoint.x >= colorWheelImageView.frame.origin.x) &&
        (touchPoint.x < (colorWheelImageView.frame.origin.x +
                        colorWheelImageView.frame.size.width)) &&
        (touchPoint.y >= colorWheelImageView.frame.origin.y) &&
        (touchPoint.y < (colorWheelImageView.frame.origin.y +
                         colorWheelImageView.frame.size.height))) {
        CGPoint colorWheelPoint = [touch locationInView:colorWheelImageView];
        CGFloat radius = colorWheelImageView.frame.size.width / 2;

        if ([self isValidTouchPointByRadius:radius atX:colorWheelPoint.x atY:colorWheelPoint.y]) {
            // Update Color Palette
            [palette getColorPixelByRadius:radius atX:colorWheelPoint.x atY:colorWheelPoint.y];
            [self updateIndicatorImageAt:touchPoint.x atY:touchPoint.y];
            [self updateBrightnessImage];
            isColorWheelTouched = TRUE;

            // Set value to remote device
            BitmapPixel rgbSettingValue;
            lastRGB = [palette getCurrentRGBAData];
            rgbSettingValue = [self getRGBSetValue];

            [self setColorToBLEDeviceByRed:rgbSettingValue.red Green:rgbSettingValue.green Blue:rgbSettingValue.blue];
            updateTime = [[NSDate date]timeIntervalSince1970];
            isOutputRGB = TRUE;
        }
    }
}

/**
 *  NAME
 *      -(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
 *
 *  DESCRIPTION
 *      1. Modify colorBrightnessImage.
 *      2. Set RGB to remote device 100mS per second.
 *
 */
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];

    if (isColorWheelTouched == TRUE) {
        double currentTime = [[NSDate date]timeIntervalSince1970];
        [self updateUIWithTouchEvent:touch];

        if ((currentTime - updateTime) > 0.100) {
            BitmapPixel rgbSettingValue;
            
            lastRGB = [palette getCurrentRGBAData];
            rgbSettingValue = [self getRGBSetValue];
            
            [self setColorToBLEDeviceByRed:rgbSettingValue.red Green:rgbSettingValue.green Blue:rgbSettingValue.blue];
            
            updateTime = currentTime;
        }
    }
}

/**
 *  NAME
 *      -(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
 *
 *  DESCRIPTION
 *      1. Modify colorBrightnessImage
 *      2. Set RGB to remote device.
 *
 */
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];

    if (isColorWheelTouched == TRUE) {
        [self updateUIWithTouchEvent:touch];

        BitmapPixel rgbSettingValue;
        lastRGB = [palette getCurrentRGBAData];
        rgbSettingValue = [self getRGBSetValue];
        
        [self setColorToBLEDeviceByRed:rgbSettingValue.red Green:rgbSettingValue.green Blue:rgbSettingValue.blue];
        isColorWheelTouched = FALSE;
    }
}


@end

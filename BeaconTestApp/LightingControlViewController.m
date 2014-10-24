//
//  LightingControlViewController.m
//  BeaconTestApp
//
//  Created by Earl Hsieh on 2014/7/28.
//  Copyright (c) 2014年 Earl Hsieh. All rights reserved.
//

#import "LightingControlViewController.h"

//0xfc06
#define UUID_ADATA_MAGIC            0x06fc//0xfc06

@interface LightingControlViewController()

@end

@implementation LightingControlViewController

@synthesize appDelegate;
@synthesize waitingAlert;
@synthesize brightImageView;
@synthesize colorPaletteImageView;
@synthesize colorTempImageView;

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view, typically from a nib.
    // get globle value and set navigation title.
    appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    self.navigationItem.title =
        [[NSString alloc] initWithFormat:@"%@", appDelegate.adataBLE.currentPeripheralCtrl.name];

    [self createWaitingAlert];
    [self createColorPalette];
    [self createColorLevelPalette:0.0 green:0 blue:0];
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
 *  Create alert view until charateristic has been discovered for adata UUID.
 */
-(void) createWaitingAlert
{
    waitingAlert = [[UIAlertView alloc] initWithTitle:@"PLEASE WAIT" message:@"Device under connecting" delegate:nil cancelButtonTitle:nil otherButtonTitles: nil];
    
    [waitingAlert show];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissWaitingAlert) name:@"waitingAlertViewCtrl" object:nil];
}

/**
 *  Dismiss alert view, it will trigger with all adata charateristic hasn been discovered.
 */
-(void) dismissWaitingAlert
{
    [waitingAlert dismissWithClickedButtonIndex:0 animated:NO];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self unlockAdataUUIDMagic];
}

/**
 *  Get service characteristic according to UUID.
 */
- (CBCharacteristic *) getCharacteristic:(NSString *)uuid
{
    for (AdataUUIDInfo *peripheral in appDelegate.adataBLE.adataUUIDPeripheral) {
        if ([peripheral.uuid isEqualToString:uuid]) {
            return peripheral.charateristic;
        }
    }
    
    return nil;
}


/**
 *  Send 0xFC06 to characteristic UUID 7878 to unlock adata feature.
 */
- (void) unlockAdataUUIDMagic
{
    NSString *uuid = [[NSString alloc] initWithFormat:@"7878"];
    uint magic = UUID_ADATA_MAGIC;
    NSData *magicData = [NSData dataWithBytes:&magic length:sizeof(magic)];
    CBCharacteristic *charateristic = [self getCharacteristic:uuid];

    [appDelegate.adataBLE writeDataToUUID:charateristic data:magicData];
}

/**
 *  Send RGB value to remote BLE device.
 */
- (void)setColorToBLEDevice:(int)red setGreen:(int)green setBlue:(int)blue
{
    NSString *uuid = [[NSString alloc] initWithFormat:@"7883"];
    NSLog(@"Red: %d, Green: %d, Blue: %d", red, green, blue);
    UInt32 writeData = (red) | (green << 8) | (blue << 16);
    NSData *data = [NSData dataWithBytes:&writeData length:sizeof(writeData)];
    CBCharacteristic *charateristic = [self getCharacteristic:uuid];
    
    [appDelegate.adataBLE writeDataToUUID:charateristic data:data];
}

/**
 *  Create a simple color palette.
 */
- (void) createColorPalette
{
    //製作rgbr水平漸層的條盤
    CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
    
    CGFloat components[] = {1.0, 0.0, 0.0, 1.0,
                            1.0, 1.0, 0.0, 1.0,
                            0.0, 1.0, 0.0, 1.0,
                            0.0, 1.0, 1.0, 1.0,
                            0.0, 0.0, 1.0, 1.0,
                            1.0, 0.0, 1.0, 1.0,
                            1.0, 0.0, 0.0, 1.0};

    CGFloat locations[] = {0.0, 0.16, 0.33, 0.50, 0.66, 0.82, 1.0};
    size_t count = 7;

    CGGradientRef gradient = CGGradientCreateWithColorComponents(rgb, components, locations, count);
    CGColorSpaceRelease(rgb);

    //設定整個調色盤區域的大小與位置
    colorPaletteImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20.0, 80.0, 280.0, 200.0)];

    UIGraphicsBeginImageContext(colorPaletteImageView.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();

    //漸層繪製保留最後10個像素來製作白色矩形
    CGContextDrawLinearGradient(context, gradient, CGPointMake(0.0, 0.0), CGPointMake(280.0, 0.0), 0);

    //rgbr水平漸層的條盤
    UIImage *paletteImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    //製作白黑垂直漸層的遮罩
    CGFloat GrayComponents[] = {1.0, 1.0, 1.0, 1.0,
                                0.5, 0.5, 0.5, 1.0,
                                0.0, 0.0, 0.0, 1.0};

    CGFloat GrayLocations[] = {1.0, 0.5, 0.0};
    count = 3;

    gradient = CGGradientCreateWithColorComponents(rgb, GrayComponents, GrayLocations, count);
    CGColorSpaceRelease(rgb);

    UIGraphicsBeginImageContext(colorPaletteImageView.frame.size);
    context = UIGraphicsGetCurrentContext();

    //以垂直方式繪製此漸層
    CGContextDrawLinearGradient(context, gradient, CGPointMake(0.0, 0.0), CGPointMake(0.0, 200.0), 0);

    //將兩者合成
    CGContextSetBlendMode(context, kCGBlendModeMultiply);
    CGRect drawRect = CGRectMake(0.0, 0.0, colorPaletteImageView.frame.size.width, colorPaletteImageView.frame.size.height);
    CGContextDrawImage(context, drawRect, paletteImage.CGImage);
    CGContextSaveGState(context);

    //將合成結果顯示於畫面上
    colorPaletteImageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    [self.view addSubview:colorPaletteImageView];
}

-(void) createColorLevelPalette:(float)red green:(float)green blue:(float)blue
{
    CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();

    CGFloat components[] = {red, green, blue, 0.0,
                            red, green, blue, 1.0};
    
    CGFloat locations[] = {0.0, 1.0};
    size_t count = 2;
    
    CGGradientRef gradient = CGGradientCreateWithColorComponents(rgb, components, locations, count);
    CGColorSpaceRelease(rgb);
    
    brightImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 300, 280, 30)];
    UIGraphicsBeginImageContext(brightImageView.frame.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawLinearGradient(context, gradient, CGPointMake(0, 0), CGPointMake(280.0, 0), 0);
    CGContextSaveGState(context);
    
    brightImageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self.view addSubview:brightImageView];
}

//自行定義的函式，取得影像座標上的RGBA值
- (void)getRGBAFromImage:(UIImage *)image atX:(int)xx andY:(int)yy {
    
    CGImageRef imageRef = [image CGImage];
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);

    //從image的data buffer中取得影像，放入格式化後的rawData中
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = malloc(height * width * 4);
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData,
                                                 width,
                                                 height,
                                                 bitsPerComponent,
                                                 bytesPerRow,
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);

    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);

    //將XY座標轉成一維陣列
    int byteIndex = (bytesPerRow * yy) + (bytesPerPixel * xx);

    //取得RGBA位元的資料並轉成0~1的格式
    float red   = (float)(rawData[byteIndex]) / 255;
    float green = (float)rawData[byteIndex + 1] / 255;
    float blue  = (float)rawData[byteIndex + 2] / 255;

    //輸出至colorView上
    NSLog(@"R: %lf, G: %lf, B: %lf", red, green, blue);
    [self setColorToBLEDevice:(255 * red) setGreen:(255 * green) setBlue:( 255 * blue)];
    [self createColorLevelPalette:red green:green blue:blue];

    free(rawData);
}

/**
 *  Get RGB value when image view has been touch.
 */
-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    float x, y;

    //分別針對在一定時間量內所點擊的所有點做運算
    for (UITouch *touch in touches) {

        //取得相對應的座標
        x = [touch locationInView:colorPaletteImageView].x;
        y = [touch locationInView:colorPaletteImageView].y;

        //設定在view的範圍內才呼叫自行定義的函式
        if ((x >= 0) && (x <= colorPaletteImageView.frame.size.width) && (y >= 0) && (y <= self.colorPaletteImageView.frame.size.height)) {
            [self getRGBAFromImage:colorPaletteImageView.image atX:x andY:y];
        }
    }
}

#if 0
-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{

}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{

}
#endif

@end

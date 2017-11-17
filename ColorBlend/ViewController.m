//
//  ViewController.m
//  ColorBlend
//
//  Created by 陈明 on 2017/11/17.
//  Copyright © 2017年 CoCo. All rights reserved.
//

#import "ViewController.h"

typedef enum : NSUInteger {
    BlendTypeClear = 0,
    BlendTypeSrc = 1,
    BlendTypeDst = 2,
    BlendTypeSrcOver = 3,
    BlendTypeDstOver = 4,
    BlendTypeSrcIn = 5,
    BlendTypeDstIn = 6,
    BlendTypeSrcOut = 7,
    BlendTypeDstOut = 8,
    BlendTypeSrcATop = 9,
    BlendTypeDstATop = 10,
    BlendTypeXor = 11,
} BlendType;

typedef enum {
    ALPHA = 0,
    BLUE = 1,
    GREEN = 2,
    RED = 3
} PIXELS;

@interface ViewController ()
@property (nonatomic, assign) BlendType blendType;
@property (weak, nonatomic) IBOutlet UIImageView *imageView1;
@property (weak, nonatomic) IBOutlet UIImageView *imageView2;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIImageView *bkgView;
@property (weak, nonatomic) IBOutlet UIImageView *bkg1View;
@property (weak, nonatomic) IBOutlet UIImageView *bkg2View;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;

@property (nonatomic, strong) UIImage *src;
@property (nonatomic, strong) UIImage *dst;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.bkgView.image = [UIImage imageNamed:@"bkg"];
    self.bkg1View.image = [UIImage imageNamed:@"bkg"];
    self.bkg2View.image = [UIImage imageNamed:@"bkg"];
    self.src = [UIImage imageNamed:@"src"];
    self.dst = [UIImage imageNamed:@"dst"];
    self.imageView1.image = self.src;
    self.imageView2.image = self.dst;
    self.infoLabel.text = @"Clear";
    [self setBlendType:BlendTypeClear];
}

- (void)setBlendType:(BlendType)blendType
{
    _blendType = blendType;
    [self blendSrc:self.src withDst:self.dst];
}

- (IBAction)selectedType:(id)sender {
    BlendType type = (BlendType)((UIButton *)sender).tag;
    [self setBlendType:type];
    self.infoLabel.text = ((UIButton *)sender).titleLabel.text;
}




- (void)blendSrc:(UIImage *)src withDst:(UIImage *)dst
{
    CGSize size = CGSizeMake(340, 340);
    const int width = size.width;
    const int height = size.height;
    uint32_t *srcPixels = [self pixelsWithImage:src size:size];
    uint32_t *dstPixels = [self pixelsWithImage:dst size:size];
    size_t bytesPerRow = width *  sizeof(uint32_t);
    uint32_t *pixels = (uint32_t *) malloc(height * bytesPerRow);
    memset(pixels, 0, width * height * sizeof(uint32_t));
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

    
    for(int y = 0; y < height; y++) {
        for(int x = 0; x < width; x++) {
            uint8_t *srcRGB = (uint8_t *) &srcPixels[y * width + x];
            uint8_t *dstRGB = (uint8_t *) &dstPixels[y * width + x];
            uint8_t *rgbaPixel = (uint8_t *) &pixels[y * width + x];
            switch (_blendType) {
                case BlendTypeClear:
                    Clear(srcRGB, dstRGB, rgbaPixel);
                    break;
                case BlendTypeSrc:
                    Src(srcRGB, dstRGB, rgbaPixel);
                    break;
                case BlendTypeDst:
                    Dst(srcRGB, dstRGB, rgbaPixel);
                    break;
                case BlendTypeSrcOver:
                    SrcOver(srcRGB, dstRGB, rgbaPixel);
                    break;
                case BlendTypeDstOver:
                    DstOver(srcRGB, dstRGB, rgbaPixel);
                    break;
                case BlendTypeSrcOut:
                    SrcOut(srcRGB, dstRGB, rgbaPixel);
                    break;
                case BlendTypeDstOut:
                    DstOut(srcRGB, dstRGB, rgbaPixel);
                    break;
                case BlendTypeSrcIn:
                    SrcIn(srcRGB, dstRGB, rgbaPixel);
                    break;
                case BlendTypeDstIn:
                    DstIn(srcRGB, dstRGB, rgbaPixel);
                    break;
                case BlendTypeSrcATop:
                    SrcATop(srcRGB, dstRGB, rgbaPixel);
                    break;
                case BlendTypeDstATop:
                    DstATop(srcRGB, dstRGB, rgbaPixel);
                    break;
                case BlendTypeXor:
                    Xor(srcRGB, dstRGB, rgbaPixel);
                    break;
                default:
                    break;
            }
        }
    }
    
    CGDataProviderRef dataProvider =CGDataProviderCreateWithData(NULL, pixels, bytesPerRow * height, nil);
    CGImageRef imageRef = CGImageCreate(width, height,8, 32, bytesPerRow, colorSpace,kCGImageAlphaLast |kCGBitmapByteOrder32Little, dataProvider,NULL, true,kCGRenderingIntentDefault);
    CGDataProviderRelease(dataProvider);
    CGColorSpaceRelease(colorSpace);
    free(pixels);
    UIImage *resultUIImage = [UIImage imageWithCGImage:imageRef];
    NSData *imageData = UIImagePNGRepresentation(resultUIImage);
    UIImage *image = [UIImage imageWithData:imageData];
    
    CGImageRef imageRefs = [image CGImage];
    CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRefs) & kCGBitmapAlphaInfoMask;
    if(alphaInfo == kCGImageAlphaPremultipliedLast){
        
    }
    
    self.imageView.image = image;
    CGImageRelease(imageRef);
}

/**
 * Blend
 */

// Cr = Cs * 0 + Cd * 0; A = As * 0 + Ad * 0
void Clear(uint8_t *src, uint8_t * dst, uint8_t *result)
{
    CGFloat Sr = src[RED]/255.0;
    CGFloat Sg = src[GREEN]/255.0;
    CGFloat Sb = src[BLUE]/255.0;
    CGFloat Sa = src[ALPHA]/255.0;
    
    CGFloat Dr = dst[RED]/255.0;
    CGFloat Dg = dst[GREEN]/255.0;
    CGFloat Db = dst[BLUE]/255.0;
    CGFloat Da = dst[ALPHA]/255.0;
    
    CGFloat Ra = Sa * 0 + Da * 0;
    if(Ra == 0){
        Ra = 1;
    }
    
    CGFloat Rr = (Sr * Sa * 0 + Dr * Da * 0)/Ra;
    CGFloat Rg = (Sg * Sa * 0 + Dg * Da * 0)/Ra;
    CGFloat Rb = (Sb * Sa * 0 + Db * Da * 0)/Ra;
    
    result[RED] = Rr * 255;
    result[GREEN] = Rg * 255;
    result[BLUE] = Rb * 255;
    result[ALPHA] = (Sa * 0 + Da * 0) *255;
}

// Cr = Cs * As + Cd * 0; A = As * 1 + Ad * 0
void Src(uint8_t *src, uint8_t * dst, uint8_t *result)
{
    CGFloat Sr = src[RED]/255.0;
    CGFloat Sg = src[GREEN]/255.0;
    CGFloat Sb = src[BLUE]/255.0;
    CGFloat Sa = src[ALPHA]/255.0;
    
    CGFloat Dr = dst[RED]/255.0;
    CGFloat Dg = dst[GREEN]/255.0;
    CGFloat Db = dst[BLUE]/255.0;
    CGFloat Da = dst[ALPHA]/255.0;
    
    
    CGFloat Ra = Sa * 1 + Da * 0;
    if(Sa == 0){
        Sa = 1;
    }
    
    CGFloat Rr = Sr/Sa;
    CGFloat Rg = Sg/Sa;
    CGFloat Rb = Sb/Sa;
    
    
    result[RED] = Rr * 255;
    result[GREEN] = Rg * 255;
    result[BLUE] = Rb * 255;
    result[ALPHA] = Ra *255;
}

// Cr = Cs * 0 + Cd * Ad; A = As * 0 + Ad * 1
void Dst(uint8_t *src, uint8_t * dst, uint8_t *result)
{
    CGFloat Sr = src[RED]/255.0;
    CGFloat Sg = src[GREEN]/255.0;
    CGFloat Sb = src[BLUE]/255.0;
    CGFloat Sa = src[ALPHA]/255.0;
    
    CGFloat Da = dst[ALPHA]/255.0;
    CGFloat Dr = dst[RED]/255.0;
    CGFloat Dg = dst[GREEN]/255.0;
    CGFloat Db = dst[BLUE]/255.0;
    
    CGFloat Ra = Sa * 0 + Da * 1;
    if(Da == 0){
        Da = 1;
    }
    
    CGFloat Rr = Dr/Da;
    CGFloat Rg = Dg/Da;
    CGFloat Rb = Db/Da;

    result[RED] = Rr * 255;
    result[GREEN] = Rg * 255;
    result[BLUE] = Rb * 255;
    result[ALPHA] = Ra * 255;
}

void Dst1(uint8_t *src, uint8_t * dst, uint8_t *result)
{
    CGFloat Sr = src[RED]/255.0;
    CGFloat Sg = src[GREEN]/255.0;
    CGFloat Sb = src[BLUE]/255.0;
    CGFloat Sa = src[ALPHA]/255.0;
    
    CGFloat Dr = dst[RED]/255.0;
    CGFloat Dg = dst[GREEN]/255.0;
    CGFloat Db = dst[BLUE]/255.0;
    CGFloat Da = dst[ALPHA]/255.0;
    
    CGFloat Rr = Dr;
    CGFloat Rg = Dg;
    CGFloat Rb = Db;
    CGFloat Ra = Sa * 0 + Da * 1;

    result[RED] = Rr * 255;
    result[GREEN] = Rg * 255;
    result[BLUE] = Rb * 255;
    result[ALPHA] = Ra * 255;
}

//Cr = Cs + Cd * ( 1 - As ) ;            Ar = As + Ad * ( 1 -  As )
void SrcOver(uint8_t *src, uint8_t * dst, uint8_t *result)
{
    CGFloat Sr = src[RED]/255.0;
    CGFloat Sg = src[GREEN]/255.0;
    CGFloat Sb = src[BLUE]/255.0;
    CGFloat Sa = src[ALPHA]/255.0;

    CGFloat Dr = dst[RED]/255.0;
    CGFloat Dg = dst[GREEN]/255.0;
    CGFloat Db = dst[BLUE]/255.0;
    CGFloat Da = dst[ALPHA]/255.0;

    

    CGFloat Ra = Sa + Da * (1 - Sa);
    
    CGFloat Rr = (Sr  + Dr  * (1-Sa))/Ra;
    CGFloat Rg = (Sg  + Dg  * (1-Sa))/Ra;
    CGFloat Rb = (Sb  + Db  * (1-Sa))/Ra;
    

    result[RED] = Rr * 255;
    result[GREEN] = Rg * 255;
    result[BLUE] = Rb * 255;
    result[ALPHA] = Ra *255;
}

// Cr = Cs * ( 1 - Ad ) + Cd  ;            Ar = As  * ( 1 -  Ad ) + Ad
void DstOver(uint8_t *src, uint8_t * dst, uint8_t *result)
{
    CGFloat Sr = src[RED]/255.0;
    CGFloat Sg = src[GREEN]/255.0;
    CGFloat Sb = src[BLUE]/255.0;
    CGFloat Sa = src[ALPHA]/255.0;
    
    CGFloat Dr = dst[RED]/255.0;
    CGFloat Dg = dst[GREEN]/255.0;
    CGFloat Db = dst[BLUE]/255.0;
    CGFloat Da = dst[ALPHA]/255.0;
    
    CGFloat Ra = Da + Sa * (1 - Da);

    
    CGFloat Rr = (Dr  + Sr  * (1-Da))/Ra;
    CGFloat Rg = (Dg  + Sg  * (1-Da))/Ra;
    CGFloat Rb = (Db  + Sb  * (1-Da))/Ra;
    
    result[RED] = Rr * 255;
    result[GREEN] = Rg * 255;
    result[BLUE] = Rb * 255;
    result[ALPHA] = Ra *255;
}

// Cr = Cs * ( 1 - Ad )   ;            Ar = As  * ( 1 -  Ad )
void SrcOut(uint8_t *src, uint8_t * dst, uint8_t *result)
{
    CGFloat Sr = src[RED]/255.0;
    CGFloat Sg = src[GREEN]/255.0;
    CGFloat Sb = src[BLUE]/255.0;
    CGFloat Sa = src[ALPHA]/255.0;
    

    CGFloat Da = dst[ALPHA]/255.0;
    
    CGFloat Ra = Sa * (1 - Da);

    
    CGFloat Rr = (Sr  * (1 - Da))/Ra;
    CGFloat Rg = (Sg  * (1 - Da))/Ra;
    CGFloat Rb = (Sb  * (1 - Da))/Ra;
    
    result[RED] = Rr * 255;
    result[GREEN] = Rg * 255;
    result[BLUE] = Rb * 255;
    result[ALPHA] = Ra * 255;
}

// Cr = Cd * ( 1 - As ) ;            Ar = Ad * ( 1 -  As )
void DstOut(uint8_t *src, uint8_t * dst, uint8_t *result)
{
    CGFloat Sa = src[ALPHA]/255.0;
    
    CGFloat Dr = dst[RED]/255.0;
    CGFloat Dg = dst[GREEN]/255.0;
    CGFloat Db = dst[BLUE]/255.0;
    CGFloat Da = dst[ALPHA]/255.0;
    
    CGFloat Ra = Da  * (1 - Sa);

    
    CGFloat Rr = (Dr * (1 - Sa))/Ra;
    CGFloat Rg = (Dg * (1 - Sa))/Ra;
    CGFloat Rb = (Db * (1 - Sa))/Ra;
    
    result[RED] = Rr * 255;
    result[GREEN] = Rg * 255;
    result[BLUE] = Rb * 255;
    result[ALPHA] = Ra * 255;
}

//Cs * Ad + Cd * 0 /            Ar = As * Ad
void SrcIn(uint8_t *src, uint8_t * dst, uint8_t *result)
{
    CGFloat Sr = src[RED]/255.0;
    CGFloat Sg = src[GREEN]/255.0;
    CGFloat Sb = src[BLUE]/255.0;
    CGFloat Sa = src[ALPHA]/255.0;
    
    CGFloat Da = dst[ALPHA]/255.0;
    
    CGFloat Ra = Sa * Da;

    
    CGFloat Rr = (Sr * Da )/Ra;
    CGFloat Rg = (Sg * Da )/Ra;
    CGFloat Rb = (Sb * Da )/Ra;
    
    result[RED] = Rr * 255;
    result[GREEN] = Rg * 255;
    result[BLUE] = Rb * 255;
    result[ALPHA] = Ra * 255;
}

//Cs * 0 + Cd * As /            Ar = Ad * As
void DstIn(uint8_t *src, uint8_t * dst, uint8_t *result)
{
    CGFloat Sa = src[ALPHA]/255.0;
    
    CGFloat Dr = dst[RED]/255.0;
    CGFloat Dg = dst[GREEN]/255.0;
    CGFloat Db = dst[BLUE]/255.0;
    CGFloat Da = dst[ALPHA]/255.0;
    
    CGFloat Ra = Da * Sa;

    CGFloat Rr = (Dr * Sa )/Ra;
    CGFloat Rg = (Dg * Sa )/Ra;
    CGFloat Rb = (Db * Sa )/Ra;
    
    result[RED] = Rr * 255;
    result[GREEN] = Rg * 255;
    result[BLUE] = Rb * 255;
    result[ALPHA] = Ra * 255;
}

//Cs*Ad + Cd * (1 - As)    As * Ad + Ad * (1-As)
void SrcATop(uint8_t *src, uint8_t * dst, uint8_t *result)
{
    CGFloat Sr = src[RED]/255.0;
    CGFloat Sg = src[GREEN]/255.0;
    CGFloat Sb = src[BLUE]/255.0;
    CGFloat Sa = src[ALPHA]/255.0;
    
    CGFloat Dr = dst[RED]/255.0;
    CGFloat Dg = dst[GREEN]/255.0;
    CGFloat Db = dst[BLUE]/255.0;
    CGFloat Da = dst[ALPHA]/255.0;
    
    CGFloat Ra = Sa * Da + Da * (1 - Sa);

    
    CGFloat Rr = (Sr * Da + Dr * (1 - Sa) )/Ra;
    CGFloat Rg = (Sg * Da + Dg * (1 - Sa) )/Ra;
    CGFloat Rb = (Sb * Da + Db * (1 - Sa) )/Ra;
    
    result[RED] = Rr * 255;
    result[GREEN] = Rg * 255;
    result[BLUE] = Rb * 255;
    result[ALPHA] = Ra * 255;
}

//Cs * ( 1 - Ad ) + Cd * As       As * (1-Ad) + Ad * As
void DstATop(uint8_t *src, uint8_t * dst, uint8_t *result)
{
    CGFloat Sr = src[RED]/255.0;
    CGFloat Sg = src[GREEN]/255.0;
    CGFloat Sb = src[BLUE]/255.0;
    CGFloat Sa = src[ALPHA]/255.0;
    
    CGFloat Dr = dst[RED]/255.0;
    CGFloat Dg = dst[GREEN]/255.0;
    CGFloat Db = dst[BLUE]/255.0;
    CGFloat Da = dst[ALPHA]/255.0;
    
    CGFloat Ra = Sa * (1-Da) + Da * Sa;

    
    CGFloat Rr = (Sr * (1 - Da) + Dr * Sa)/Ra;
    CGFloat Rg = (Sg * (1 - Da) + Dg * Sa)/Ra;
    CGFloat Rb = (Sb * (1 - Da) + Db * Sa)/Ra;
    
    result[RED] = Rr * 255;
    result[GREEN] = Rg * 255;
    result[BLUE] = Rb * 255;
    result[ALPHA] = Ra * 255;
}

//Cs *(1-Ad)+ Cd *(1-As)        As *(1-Ad)+ Ad *(1-As)
void Xor(uint8_t *src, uint8_t * dst, uint8_t *result)
{
    CGFloat Sr = src[RED]/255.0;
    CGFloat Sg = src[GREEN]/255.0;
    CGFloat Sb = src[BLUE]/255.0;
    CGFloat Sa = src[ALPHA]/255.0;
    
    CGFloat Dr = dst[RED]/255.0;
    CGFloat Dg = dst[GREEN]/255.0;
    CGFloat Db = dst[BLUE]/255.0;
    CGFloat Da = dst[ALPHA]/255.0;
    
    CGFloat Ra = Sa * (1-Da) + Da * (1-Sa);
    
    CGFloat Rr = (Sr * (1 - Da) + Dr * (1 - Sa))/Ra;
    CGFloat Rg = (Sg * (1 - Da) + Dg * (1 - Sa))/Ra;
    CGFloat Rb = (Sb * (1 - Da) + Db * (1 - Sa))/Ra;
    
    result[RED] = Rr * 255;
    result[GREEN] = Rg * 255;
    result[BLUE] = Rb * 255;
    result[ALPHA] = Ra * 255;
}

- (uint32_t *)pixelsWithImage:(UIImage *)image size:(CGSize)size
{
    int width = size.width;
    int height = size.height;
    uint32_t *pixels = (uint32_t *) malloc(width * height * sizeof(uint32_t));
    memset(pixels, 0, width * height * sizeof(uint32_t));
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pixels, width, height, 8, width * sizeof(uint32_t), colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);
    
    CGImageRef imageRef = [image CGImage];
    // 先确定Alpha通道类型 再决定用何种形式来初始化context
//    CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef) & kCGBitmapAlphaInfoMask;
//    if(alphaInfo == kCGImageAlphaPremultipliedLast){
//
//    }
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    return pixels;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end

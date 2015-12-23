//
//  ViewController.m
//  PictureMutipleSelect
//
//  Created by 涂婉丽 on 15/12/8.
//  Copyright (c) 2015年 涂婉丽. All rights reserved.
//

#import "ViewController.h"
#import "CorePhotoPickerVCManager.h"
#define k_width    [UIScreen mainScreen].bounds.size.width
#define k_height   [UIScreen mainScreen].bounds.size.height
#define angle2Radian(angle)  ((angle)/180.0*M_PI)
@interface ViewController ()<UIActionSheetDelegate>
{
    //拍照、相册照片名字
    NSMutableArray *imageNameArr;
    //获取到的所有相片
    NSMutableArray *imageArr;
    //发送图片数组
    NSMutableArray *sendImage;
    BOOL isdelete;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *button =[UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(createPicker) forControlEvents:UIControlEventTouchUpInside];
    
    button.frame = CGRectMake(30, 200, 100, 50);
    [button setTitle:@"照片" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:button];
    UIButton *sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [sendBtn  setTitle:@"发送" forState:UIControlStateNormal];
    [sendBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [sendBtn addTarget:self action:@selector(sendImageAction) forControlEvents:UIControlEventTouchUpInside];
    sendBtn.frame = CGRectMake(200, 200, 100, 50);
    [self.view addSubview:sendBtn];
    [self createData];
}
- (void)createData
{
     isdelete = YES;
    //初始化保存图片名称数组
    imageNameArr = [[NSMutableArray alloc]initWithCapacity:0];
    imageArr = [[NSMutableArray alloc]initWithCapacity:0];
    //相册展示
    UIScrollView *pictuerScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0,k_height-150,self.view.frame.size.width, 150)];
    pictuerScrollView.tag = 511;
    pictuerScrollView.hidden = NO;
    pictuerScrollView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:pictuerScrollView];
}
- (void)createPicker
{
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle: nil                                                                             message: nil                                                                       preferredStyle:UIAlertControllerStyleActionSheet];
    //添加Button
    [alertController addAction: [UIAlertAction actionWithTitle: @"拍照" style: UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        //处理点击拍照
        [self alertActionWithIndex:0];
    }]];
    [alertController addAction: [UIAlertAction actionWithTitle: @"从相册选取" style: UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        //处理点击从相册选取
        [self alertActionWithIndex:1];
    }]];
    [alertController addAction: [UIAlertAction actionWithTitle: @"取消" style: UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController: alertController animated: YES completion: nil];
}
- (void)alertActionWithIndex:(NSInteger)buttonIndex
{
    
    CorePhotoPickerVCMangerType type=0;
    
    
    if(buttonIndex==0) type=CorePhotoPickerVCMangerTypeCamera;
    
    if(buttonIndex==1) type=CorePhotoPickerVCMangerTypeMultiPhoto;
    
    CorePhotoPickerVCManager *manager=[CorePhotoPickerVCManager sharedCorePhotoPickerVCManager];
    
    //设置类型
    manager.pickerVCManagerType=type;
    
    //最多可选3张
    manager.maxSelectedPhotoNumber=5;
    
    //错误处理
    if(manager.unavailableType!=CorePhotoPickerUnavailableTypeNone){
        NSLog(@"设备不可用");
        return;
    }
    
    UIViewController *pickerVC=manager.imagePickerController;
    
    //选取结束
    manager.finishPickingMedia=^(NSArray *medias){
        
        [medias enumerateObjectsUsingBlock:^(CorePhoto *photo, NSUInteger idx, BOOL *stop) {
            NSLog(@"%@",photo.editedImage);
            UIImage *userImage = photo.editedImage;
            [imageArr addObject:userImage];
            [self scrollViewAddPictureAndBooL:YES];

        }];
    };
    
    [self presentViewController:pickerVC animated:YES completion:nil];
    
}

//更新图片
- (void)scrollViewAddPictureAndBooL:(BOOL)isHidden
{
    
    UIScrollView *scrollView = (UIScrollView *)[self.view viewWithTag:511];
    scrollView.hidden = NO;
    int width = 0;
    CGRect frame;
    for (int i = 0; i < imageArr.count; i++) {
        UIImage *tempImg = imageArr[i];
        NSLog(@"%@",NSStringFromCGSize(tempImg.size));
        if (tempImg.size.width > tempImg.size.height) {
            frame = CGRectMake(width, 2, 200, 146);
            width +=202;
        }else{
            frame = CGRectMake(width, 2,107 , 146);
            width +=109;
        }
        UIImageView *photoView = [[UIImageView alloc]initWithFrame:frame];
        photoView.userInteractionEnabled = YES;
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longpressAction)];
        [photoView addGestureRecognizer:longPress];
        [photoView setImage:imageArr[i]];
//        //图片选中按钮
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(photoView.frame.size.width-30, 0, 30, 30);
        button.layer.cornerRadius = 6;
        button.layer.masksToBounds = YES;
        button.tag = 600+i;
        [button setBackgroundImage:[UIImage imageNamed:@"圈-图标.png"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(pitchPhoto:) forControlEvents:UIControlEventTouchUpInside];
        [photoView addSubview:button];
                [scrollView addSubview:photoView];
    }
    scrollView.contentSize = CGSizeMake(width-2, 150);
}
- (void)longpressAction
{
    
    [self isdeleteImg];
}
- (void)isdeleteImg
{
    if (isdelete) {
        [self scrollViewAddPictureAndBooL:NO];
//        isdelete = NO;
    }else{
        [self scrollViewAddPictureAndBooL:YES];
//        isdelete = YES;
    }
}


//图片上的选择按钮点击事件
- (void)pitchPhoto:(UIButton *)button
{//变换背景图，更新选中元数据
    if (button.selected) {
        [button setBackgroundImage:[UIImage imageNamed:@"圈-图标.png"] forState:UIControlStateNormal];
        [self imageWillsend:button.tag-600 remover:YES];
    }else{
        [button setBackgroundImage:[UIImage imageNamed:@"对号-图标.png"] forState:UIControlStateNormal];
        [self imageWillsend:button.tag-600 remover:NO];
    }
    button.selected = !button.selected;
}
//图片添加发送
- (void)imageWillsend:(NSInteger)count remover:(BOOL)isremover
{
    if (isremover) {
        [sendImage removeObjectAtIndex:count];
    }else{
        [sendImage addObject:[imageArr objectAtIndex:count]];
    }
}
- (void)sendImageAction
{

    NSLog(@"点击了发送按钮");
    /*sendImage里面就是要发送的图片，代码类似我的github   https://github.com/tuwanli/PictureHead
     里面的头像上传两种方法，遍历这个数组即可
     */
    
}
//缩放图片
- (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize
{
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width*scaleSize,image.size.height*scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height *scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSLog(@"%@",NSStringFromCGSize(scaledImage.size));
    return scaledImage;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

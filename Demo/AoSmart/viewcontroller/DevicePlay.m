//
//  DevicePlay.m
//  AoSmart
//
//  Created by rakwireless on 16/1/26.
//  Copyright © 2016年 rak. All rights reserved.
//

#import "DevicePlay.h"
#import "CommanParameter.h"
#import "DeviceSettings.h"
#import "MBProgressHUD.h"
#import "WisView.h"
#import "Scanner.h"
#import "GCDAsyncSocket.h"
#import "CommonFunc.h"
#import "UIColor+Hex.h"
#import "remote.h"
#import "DeviceConnectFailed.h"
#import "DeviceData.h"
#import "AudioRecord.h"
#import "sendAudio.h"
#import "DeviceUart.h"
#import "PlayBackFolderList.h"
#import "AlbumObject.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import <Photos/Photos.h>

WisView *_videoView;
int _resolution=1;
NSString *_qualityHD=@"h264";
NSString *_qualityBD=@"h264-1";
NSTimer* CheckVideoPlay = nil;
GCDAsyncSocket* GCDUartSocket = nil;//用于建立TCP socket
static NSTimer* CheckVideoRemoteConnect = nil;//用于定时1秒检查视频通道远程打通状态
static NSTimer* CheckUartRemoteConnect = nil;//用于定时1秒检查TCP 80端口通道远程打通状态
nabto_tunnel_t videoTunnel;
nabto_tunnel_t httpTunnel;
NSString *devicePlayIp;
nabto_tunnel_state_t nabtoConnectStatus;
int nabto_remote_count;
BOOL _isExit;
BOOL _isOpened;
int fps=20;
UINavigationController *_self;
NSString *album_name=@"RAK VIDEO";

@interface DevicePlay ()
{
    NSString *devicePlayId;
    NSString *devicePlayPsk;
    int devicePlayPort;
    int deviceSendPort;
    NSString *devicePlayName;
    BOOL _isRecord;
    BOOL _isOpenVoice;
    BOOL _isTcp;
    int voiceRecordSecond;
    
    NSString *_qualityNow;
    NSString *url ;
    
    AudioRecord* audioRecord;
    NSTimer *voiceRecordTimer;  //用户双向语音录音计时
    
    CGFloat viewW;
    CGFloat viewH;
    NSString *version;
    NSString *videotype;
    NSString *videoscreen;
    BOOL _isLx520;
    AlbumObject *_albumObject;
}
@end

@implementation DevicePlay

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _self=self.navigationController;
    self.view.backgroundColor=[UIColor blackColor];
    viewW=self.view.frame.size.width;
    viewH=self.view.frame.size.height;
    _albumObject=[[AlbumObject alloc]init];
    [_albumObject delegate:self];
    audioRecord = [[AudioRecord alloc]init];
    _isRecord=NO;
    _isExit=NO;
    _isOpened=NO;
    _isOpenVoice=NO;
    _isLx520=YES;
    devicePlayPort=554;
    deviceSendPort=80;
    devicePlayId=[self Get_Parameter:@"play_device_id"];
    devicePlayIp=[self Get_Parameter:@"play_device_ip"];
    devicePlayName=[self Get_Parameter:@"play_device_name"];
    fps=[[self Get_Parameter:@"fps"] intValue];
    version=[self Get_Parameter:@"version"];
    videoscreen=[self Get_Parameter:@"screen"];
    version=version.lowercaseString;
    videotype=[self Get_Parameter:@"videotype"];
    if ([videotype isEqualToString:@"mjpeg"]) {
        _qualityHD=@"mpeg4";
        _qualityBD=@"mpeg4";
    }
    else{
        _qualityHD=@"h264";
        _qualityBD=@"h264-1";
    }
    
    NSLog(@"fps==>%d\n",fps);
    if ([version containsString:@"wifiv"]) {
        _isLx520=NO;//图传模块
    }
    [self viewInit];
    _DevicePlayName.text=devicePlayName;
    CheckVideoPlay = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(CheckVideoPlayTimer) userInfo:nil repeats:YES];
    [self showAllTextDialog:devicePlayIp];
    if ([devicePlayIp compare:@"127.0.0.1"]==NSOrderedSame) {
        [self play_video:_qualityBD];
    }
    else{
        [self play_video:_qualityHD];
    }
}

- (void)setViewNewFrame: (CGFloat)width :(CGFloat)height{
    if (isPortrait) {
        if ([videoscreen compare:@"1"]==NSOrderedSame){
            if (viewW*height/width>viewH) {
                _videoView.frame=CGRectMake(0, 0, viewH*width/height, viewH);
                [_videoView setView1Frame:CGRectMake(0, 0, viewH*width/height, viewH)];
            }
            else{
                _videoView.frame=CGRectMake(0, 0, viewW, viewW*height/width);
                [_videoView setView1Frame:CGRectMake(0, 0, viewW, viewW*height/width)];
            }
        }
        else{
            if (viewW*0.5*height/width>viewH) {
                CGFloat diff=(viewW-2*viewH*width/height)/3;
                [_videoView setView1Frame:CGRectMake(diff, 0, viewH*width/height, viewH)];
                [_videoView setView2Frame:CGRectMake(diff*2+viewH*width/height, 0,  viewH*width/height, viewH)];
            }
            else{
                CGFloat diff=(viewH-(title_size+diff_top+60)-2*viewW*height/width)/3;
                [_videoView setView1Frame:CGRectMake(0, diff+title_size+diff_top, viewW, viewW*height/width)];
                [_videoView setView2Frame:CGRectMake(0, 2*diff+title_size+diff_top+viewW*height/width, viewW, viewW*height/width)];
            }
        }
    }
    else{
        if ([videoscreen compare:@"1"]==NSOrderedSame){
            if (viewW*height/width>viewH) {
                _videoView.frame=CGRectMake(0, 0, viewH*width/height, viewH);
                [_videoView setView1Frame:CGRectMake(0, 0, viewH*width/height, viewH)];
            }
            else{
                _videoView.frame=CGRectMake(0, 0, viewW, viewW*height/width);
                [_videoView setView1Frame:CGRectMake(0, 0, viewW, viewW*height/width)];
            }
        }
        else{
            if (viewW*height*0.5/width>viewH) {
                CGFloat diff=(viewW-2*viewH*width/height)/3;
                [_videoView setView1Frame:CGRectMake(diff, 0, viewH*width/height, viewH)];
                [_videoView setView2Frame:CGRectMake(diff*2+viewH*width/height, 0,  viewH*width/height, viewH)];
            }
            else{
                CGFloat diff=(viewH-0.5*viewW*height/width)/2;
                [_videoView setView1Frame:CGRectMake(0, diff, viewW*0.5, viewW*0.5*height/width)];
                [_videoView setView2Frame:CGRectMake(viewW*0.5, diff, viewW*0.5, viewW*0.5*height/width)];
            }
        }
    }
}
bool isfree=false;
- (void)GetYUVData:(int)width :(int)height
                  :(Byte*)yData :(Byte*)uData :(Byte*)vData
                  :(int)ySize :(int)uSize :(int)vSize//回调获取解码后的YUV数据
{
    //NSLog(@"width=%d,height=%d",width,height);
    
}

- (void)viewInit{
    devicePlayIp=[self Get_Parameter:@"play_device_ip"];
    _videoView.userInteractionEnabled = YES;
    if ([devicePlayIp compare:@"127.0.0.1"]==NSOrderedSame) {
        if ([videoscreen compare:@"1"]==NSOrderedSame) {//单屏
            _videoView = [[WisView alloc] initWithFrame:CGRectMake(0, 0, viewW, viewH)];
        }
        else{//分屏
            _videoView = [[WisView alloc] initWithFrame2:CGRectMake(0, 0, viewW, viewH) :CGRectMake(0, 0, viewW, viewH) :CGRectMake(0, 0, viewW, viewH)];
        }
        [self setViewNewFrame:640 :480];
    }
    else{
        if ([videoscreen compare:@"1"]==NSOrderedSame) {//单屏
            _videoView = [[WisView alloc] initWithFrame:CGRectMake(0, 0, viewW, viewH)];
        }
        else{//分屏
            _videoView = [[WisView alloc] initWithFrame2:CGRectMake(0, 0, viewW, viewH) :CGRectMake(0, 0, viewW, viewH) :CGRectMake(0, 0, viewW, viewH)];
        }
        [self setViewNewFrame:1280 :720];
    }
    
    _videoView.center=self.view.center;
    _videoView.backgroundColor = [UIColor blackColor];
    [_videoView set_log_level:1];
    [_videoView delegate:self];
    [_videoView startGetYUVData:YES];
    [self.view addSubview:_videoView];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchesImage)];
    [_videoView addGestureRecognizer:singleTap];
    
    _TitleView=[[UIView alloc]init];
    _TitleView.frame=CGRectMake(0, 0, viewW,title_size+diff_top);
    [self.view addSubview:_TitleView];
    _DevicePlayBack=[UIButton buttonWithType:UIButtonTypeCustom];
    _DevicePlayBack.frame=CGRectMake(diff_x, diff_top, viewW*0.05, viewW*0.05);
    [_DevicePlayBack setImage:[UIImage imageNamed:@"video_back.png"] forState:UIControlStateNormal];
    [_DevicePlayBack addTarget:nil action:@selector(_DevicePlayBackClick) forControlEvents:UIControlEventTouchUpInside];
    [_TitleView addSubview:_DevicePlayBack];
    
    _DevicePlayName = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, viewW-_DevicePlayBack.frame.size.width-diff_x, viewW*0.06)];
    _DevicePlayName.center=CGPointMake(viewW*0.5,_DevicePlayBack.center.y);
    _DevicePlayName.text = NSLocalizedString(@"video_name", nil);;
    _DevicePlayName.font = [UIFont systemFontOfSize: main_help_size];
    _DevicePlayName.backgroundColor = [UIColor clearColor];
    _DevicePlayName.textColor = [UIColor whiteColor];
    _DevicePlayName.textAlignment = UITextAlignmentCenter;
    _DevicePlayName.lineBreakMode = UILineBreakModeWordWrap;
    _DevicePlayName.numberOfLines = 0;
    [_TitleView addSubview:_DevicePlayName];
    
    
    _DevicePlayPlayback=[UIButton buttonWithType:UIButtonTypeCustom];
    _DevicePlayPlayback.frame=CGRectMake(viewW-diff_x-viewW*0.06, diff_top, viewW*0.06, viewW*0.06);
    [_DevicePlayPlayback setImage:[UIImage imageNamed:@"fullplayer_icon_download.png"] forState:UIControlStateNormal];
    [_DevicePlayPlayback addTarget:nil action:@selector(_DevicePlayPlaybackClick) forControlEvents:UIControlEventTouchUpInside];
    [_TitleView addSubview:_DevicePlayPlayback];
    
    _DevicePlaySdRecord=[UIButton buttonWithType:UIButtonTypeCustom];
    _DevicePlaySdRecord.frame=CGRectMake(_DevicePlayPlayback.frame.origin.x-2*diff_x-viewW*0.06, diff_top, viewW*0.06*84/73, viewW*0.06);
    [_DevicePlaySdRecord setImage:[UIImage imageNamed:@"ico_sdcard.png"] forState:UIControlStateNormal];
    [_DevicePlaySdRecord addTarget:nil action:@selector(_DevicePlaySdRecordClick) forControlEvents:UIControlEventTouchUpInside];
    [_TitleView addSubview:_DevicePlaySdRecord];
    
    CGFloat sizeV = 50;
    CGFloat gapX = 10;
    CGFloat gapY=5;
    CGFloat diffV = (viewW-gapX*2-50*7)/6;
    
    _ControlView=[[UIView alloc]init];
    _ControlView.frame=CGRectMake(0, viewH-sizeV-gapY*2, viewW,sizeV+gapY*2);
    _ControlView.backgroundColor=[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
    [self.view addSubview:_ControlView];
    
    _DevicePlayChangePipe=[UIButton buttonWithType:UIButtonTypeCustom];
    _DevicePlayChangePipe.frame = CGRectMake(gapX, gapY, sizeV,sizeV);
    [_DevicePlayChangePipe setTitle: NSLocalizedString(@"video_auto", nil) forState: UIControlStateNormal];
    _DevicePlayChangePipe.titleLabel.font = [UIFont systemFontOfSize: add_title_size];
    [_DevicePlayChangePipe setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
    [_DevicePlayChangePipe setTitleColor:[UIColor grayColor]forState:UIControlStateHighlighted];
    _DevicePlayChangePipe.contentHorizontalAlignment=UIControlContentHorizontalAlignmentLeft;
    [_DevicePlayChangePipe addTarget:nil action:@selector(_DevicePlayChangePipeClick) forControlEvents:UIControlEventTouchUpInside];
    [_ControlView  addSubview:_DevicePlayChangePipe];
    
    _DevicePlayVoice=[UIButton buttonWithType:UIButtonTypeCustom];
    _DevicePlayVoice.frame=CGRectMake(gapX+sizeV+diffV, gapY, sizeV, sizeV);
    [_DevicePlayVoice setImage:[UIImage imageNamed:@"video_voice_off.png"] forState:UIControlStateNormal];
    [_DevicePlayVoice addTarget:nil action:@selector(_DevicePlayVoiceClick) forControlEvents:UIControlEventTouchUpInside];
    [_ControlView  addSubview:_DevicePlayVoice];
    
    _DevicePlayTakePhoto=[UIButton buttonWithType:UIButtonTypeCustom];
    _DevicePlayTakePhoto.frame=CGRectMake(gapX+sizeV*2+diffV*2, gapY, sizeV, sizeV);
    [_DevicePlayTakePhoto setImage:[UIImage imageNamed:@"video_take_photo.png"] forState:UIControlStateNormal];
    [_DevicePlayTakePhoto addTarget:nil action:@selector(_DevicePlayTakePhotoClick) forControlEvents:UIControlEventTouchUpInside];
    [_ControlView  addSubview:_DevicePlayTakePhoto];
    
    _DevicePlayRecord=[UIButton buttonWithType:UIButtonTypeCustom];
    _DevicePlayRecord.frame=CGRectMake(gapX+sizeV*3+diffV*3, gapY, sizeV, sizeV);
    [_DevicePlayRecord setImage:[UIImage imageNamed:@"video_record.png"] forState:UIControlStateNormal];
    [_DevicePlayRecord addTarget:nil action:@selector(_DevicePlayRecordClick) forControlEvents:UIControlEventTouchUpInside];
    [_ControlView  addSubview:_DevicePlayRecord];
    
    _DevicePlayAudio=[UIButton buttonWithType:UIButtonTypeCustom];
    _DevicePlayAudio.frame=CGRectMake(gapX+sizeV*4+diffV*4, gapY, sizeV, sizeV);
    [_DevicePlayAudio setImage:[UIImage imageNamed:@"video_audio.png"] forState:UIControlStateNormal];
    [_DevicePlayAudio addTarget:self action:@selector(onVoiceRecordButtonClicked) forControlEvents:UIControlEventTouchDown];
    [_DevicePlayAudio addTarget:self action:@selector(onVoiceRecordButtonTouchUp) forControlEvents:UIControlEventTouchUpInside];
    [_DevicePlayAudio addTarget:self action:@selector(onVoiceRecordButtonTouchUp) forControlEvents:UIControlEventTouchUpOutside];
    [_ControlView addSubview:_DevicePlayAudio];
    
    _DevicePlayUart=[UIButton buttonWithType:UIButtonTypeCustom];
    _DevicePlayUart.frame=CGRectMake(gapX+sizeV*5+diffV*5, gapY, sizeV, sizeV);
    [_DevicePlayUart setImage:[UIImage imageNamed:@"video_uart.png"] forState:UIControlStateNormal];
    [_DevicePlayUart addTarget:nil action:@selector(_DevicePlayUartClick) forControlEvents:UIControlEventTouchUpInside];
    [_ControlView addSubview:_DevicePlayUart];
    
    _DevicePlaySettings=[UIButton buttonWithType:UIButtonTypeCustom];
    _DevicePlaySettings.frame=CGRectMake(gapX+sizeV*6+diffV*6, gapY, sizeV, sizeV);
    [_DevicePlaySettings setImage:[UIImage imageNamed:@"video_settings.png"] forState:UIControlStateNormal];
    [_DevicePlaySettings addTarget:nil action:@selector(_DevicePlaySettingsClick) forControlEvents:UIControlEventTouchUpInside];
    [_ControlView  addSubview:_DevicePlaySettings];
    
    
    int _num=3;//520模块
    if (_isLx520==NO) {
        _num=4;//图传模块
    }
    _PipeView=[[UIView alloc]init];
    _PipeView.frame=CGRectMake(0, _ControlView.frame.origin.y-sizeV*_num, sizeV+gapX, sizeV*_num);
    _PipeView.backgroundColor=[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
    [self.view addSubview:_PipeView];
    
    _DevicePlayBD=[UIButton buttonWithType:UIButtonTypeCustom];
    _DevicePlayBD.frame = CGRectMake(gapX*1.25, (_num-1)*sizeV, sizeV,sizeV);
    [_DevicePlayBD setTitle: NSLocalizedString(@"video_BD", nil) forState: UIControlStateNormal];
    _DevicePlayBD.titleLabel.font = [UIFont systemFontOfSize: add_text_size];
    [_DevicePlayBD setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
    [_DevicePlayBD setTitleColor:[UIColor grayColor]forState:UIControlStateHighlighted];
    _DevicePlayBD.contentHorizontalAlignment=UIControlContentHorizontalAlignmentLeft;
    [_DevicePlayBD addTarget:nil action:@selector(_DevicePlayBDClick) forControlEvents:UIControlEventTouchUpInside];
    [_PipeView  addSubview:_DevicePlayBD];
    
    _DevicePlayHD=[UIButton buttonWithType:UIButtonTypeCustom];
    _DevicePlayHD.frame = CGRectMake(gapX*1.25, (_num-2)*sizeV, sizeV,sizeV);
    [_DevicePlayHD setTitle: NSLocalizedString(@"video_HD", nil) forState: UIControlStateNormal];
    _DevicePlayHD.titleLabel.font = [UIFont systemFontOfSize: add_text_size];
    [_DevicePlayHD setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
    [_DevicePlayHD setTitleColor:[UIColor grayColor]forState:UIControlStateHighlighted];
    _DevicePlayHD.contentHorizontalAlignment=UIControlContentHorizontalAlignmentLeft;
    [_DevicePlayHD addTarget:nil action:@selector(_DevicePlayHDClick) forControlEvents:UIControlEventTouchUpInside];
    [_PipeView  addSubview:_DevicePlayHD];
    
    if (_num==4) {
        _DevicePlayVHD=[UIButton buttonWithType:UIButtonTypeCustom];
        _DevicePlayVHD.frame = CGRectMake(gapX*1.25, (_num-3)*sizeV, sizeV,sizeV);
        [_DevicePlayVHD setTitle: NSLocalizedString(@"video_VHD", nil) forState: UIControlStateNormal];
        _DevicePlayVHD.titleLabel.font = [UIFont systemFontOfSize: add_text_size];
        [_DevicePlayVHD setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
        [_DevicePlayVHD setTitleColor:[UIColor grayColor]forState:UIControlStateHighlighted];
        _DevicePlayVHD.contentHorizontalAlignment=UIControlContentHorizontalAlignmentLeft;
        [_DevicePlayVHD addTarget:nil action:@selector(_DevicePlayVHDClick) forControlEvents:UIControlEventTouchUpInside];
        [_PipeView addSubview:_DevicePlayVHD];
    }
    
    _DevicePlayAuto=[UIButton buttonWithType:UIButtonTypeCustom];
    _DevicePlayAuto.frame = CGRectMake(gapX*1.25, 0, sizeV,sizeV);
    [_DevicePlayAuto setTitle: NSLocalizedString(@"video_auto", nil) forState: UIControlStateNormal];
    _DevicePlayAuto.titleLabel.font = [UIFont systemFontOfSize: add_text_size];
    [_DevicePlayAuto setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
    [_DevicePlayAuto setTitleColor:[UIColor grayColor]forState:UIControlStateHighlighted];
    _DevicePlayAuto.contentHorizontalAlignment=UIControlContentHorizontalAlignmentLeft;
    [_DevicePlayAuto addTarget:self action:@selector(_DevicePlayAutoClick) forControlEvents:UIControlEventTouchUpInside];
    [_PipeView  addSubview:_DevicePlayAuto];
    _PipeView.hidden=YES;
    
    _DeviceConnectingView=[[UIView alloc]init];
    _DeviceConnectingView.frame=self.view.frame;
    _DeviceConnectingView.backgroundColor=[UIColor whiteColor];
    //[self.view addSubview:_DeviceConnectingView];
    
    _DeviceConnectingBack=[UIButton buttonWithType:UIButtonTypeCustom];
    _DeviceConnectingBack.frame=CGRectMake(diff_x, diff_top, add_title_size, add_title_size);
    [_DeviceConnectingBack setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [_DeviceConnectingBack addTarget:nil action:@selector(_DeviceConnectingBackClick) forControlEvents:UIControlEventTouchUpInside];
    [_DeviceConnectingView addSubview:_DeviceConnectingBack];
    
    _DeviceConnectingImage =[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, viewW*0.4, viewW*0.4)];
    _DeviceConnectingImage.center=CGPointMake(_DeviceConnectingView.center.x,_DeviceConnectingView.center.y-diff_top);
    NSArray *gifArray = [NSArray arrayWithObjects:
                         [UIImage imageNamed:@"config_device_0.png"],
                         [UIImage imageNamed:@"config_device_1.png"],
                         [UIImage imageNamed:@"config_device.png"],
                         nil];
    _DeviceConnectingImage.animationDuration=1.0;
    _DeviceConnectingImage.animationImages = gifArray; //动画图片数组
    _DeviceConnectingImage.animationRepeatCount = 0;  //动画重复次数
    [_DeviceConnectingImage startAnimating];
    [_DeviceConnectingView addSubview:_DeviceConnectingImage];
    
    _DeviceConnectingText = [[UILabel alloc] initWithFrame:CGRectMake(diff_x, _DeviceConnectingImage.frame.size.height+_DeviceConnectingImage.frame.origin.y+diff_top, viewW-2*diff_x, title_size*2)];
    _DeviceConnectingText.text = NSLocalizedString(@"device_connectting_text", nil);;
    _DeviceConnectingText.font = [UIFont systemFontOfSize: add_title_size];
    _DeviceConnectingText.backgroundColor = [UIColor clearColor];
    _DeviceConnectingText.textColor = [UIColor grayColor];
    _DeviceConnectingText.textAlignment = UITextAlignmentCenter;
    _DeviceConnectingText.lineBreakMode = UILineBreakModeWordWrap;
    _DeviceConnectingText.numberOfLines = 0;
    [_DeviceConnectingView addSubview:_DeviceConnectingText];
    [self.view addSubview:_DeviceConnectingView];
    
    _DevicePlayRecordVoiceView=[[UIView alloc]init];
    _DevicePlayRecordVoiceView.frame=CGRectMake(0, 0, viewW*0.4, viewW*0.4);
    _DevicePlayRecordVoiceView.center=self.view.center;
    _DevicePlayRecordVoiceView.backgroundColor=[UIColor clearColor];
    [self.view addSubview:_DevicePlayRecordVoiceView];
    
    _DevicePlayRecordVoiceImage =[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, viewW*0.4*126/163,viewW*0.4)];
    _DevicePlayRecordVoiceImage.center=CGPointMake(_DevicePlayRecordVoiceView.frame.size.width*0.5, _DevicePlayRecordVoiceView.frame.size.height*0.5);
    _DevicePlayRecordVoiceImage.image=[UIImage imageNamed:@"camera_speak_pre.png"];
    [_DevicePlayRecordVoiceView addSubview:_DevicePlayRecordVoiceImage];
    
    _DevicePlayRecordVoiceText = [[UILabel alloc] initWithFrame:CGRectMake(0,_DevicePlayRecordVoiceView.frame.size.height- title_size-gapY , _DevicePlayRecordVoiceView.frame.size.width, title_size)];
    _DevicePlayRecordVoiceText.text =@"00:00";
    _DevicePlayRecordVoiceText.font = [UIFont systemFontOfSize: add_title_size];
    _DevicePlayRecordVoiceText.backgroundColor = [UIColor clearColor];
    _DevicePlayRecordVoiceText.textColor = [UIColor whiteColor];
    _DevicePlayRecordVoiceText.textAlignment = UITextAlignmentCenter;
    _DevicePlayRecordVoiceText.lineBreakMode = UILineBreakModeWordWrap;
    _DevicePlayRecordVoiceText.numberOfLines = 0;
    [_DevicePlayRecordVoiceView addSubview:_DevicePlayRecordVoiceText];
    _DevicePlayRecordVoiceView.hidden=YES;
    NSString *key=[NSString stringWithFormat:@"Password=%@",devicePlayId];
    devicePlayPsk=[self Get_Parameter:key];
    _parametersConfigDevicePlay=[[ParametersConfig alloc]init:self ip:devicePlayIp password:devicePlayPsk];
    [_parametersConfigDevicePlay getSdRecordStatus:0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setOnResultListener:(int)statusCode :(NSString*)body :(int)type{
    if (type==GET_SD_RECORD_STATUS) {
        if(statusCode==200)
        {
            if([body compare:@"{\"value\": \"0\"}"]==NSOrderedSame)
            {
                isSdRecord=false;
                dispatch_async(dispatch_get_main_queue(),^ {
                    [_DevicePlaySdRecord setImage:[UIImage imageNamed:@"ico_sdcard.png"] forState:UIControlStateNormal];
                });
            }
            else if([body compare:@"{\"value\": \"1\"}"]==NSOrderedSame)
            {
                isSdRecord=true;
                dispatch_async(dispatch_get_main_queue(),^ {
                    [_DevicePlaySdRecord setImage:[UIImage imageNamed:@"ico_sdcarding.png"] forState:UIControlStateNormal];
                });
            }
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(),^ {
                [self showAllTextDialog:@"Get Sd-Record status failed"];
            });
        }
    }
    else if (type==START_SD_RECORD)
    {
        if(statusCode==200)
        {
            if([body compare:@"{\"value\": \"0\"}"]==NSOrderedSame)
            {
                isSdRecord=true;
                [self showAllTextDialog:@"Start Sd-Record success"];
                [_DevicePlaySdRecord setImage:[UIImage imageNamed:@"ico_sdcarding.png"] forState:UIControlStateNormal];
            }
            else if([body compare:@"{\"value\": \"-4\"}"]==NSOrderedSame)
            {
                dispatch_async(dispatch_get_main_queue(),^ {
                    [self showAllTextDialog:@"busy,It is recording now"];
                });
            }
            else if([body compare:@"{\"value\": \"-22\"}"]==NSOrderedSame)
            {
                dispatch_async(dispatch_get_main_queue(),^ {
                    [self showAllTextDialog:@"No sd-card or sd-card is full"];
                });
            }
        }
        else{
            dispatch_async(dispatch_get_main_queue(),^ {
                [self showAllTextDialog:@"Start Sd-Record failed"];
            });
        }
    }
    else if (type==STOP_SD_RECORD) {
        if(statusCode==200)
        {
            if([body compare:@"{\"value\": \"0\"}"]==NSOrderedSame)
            {
                dispatch_async(dispatch_get_main_queue(),^ {
                    isSdRecord=false;
                    [self showAllTextDialog:@"Stop Sd-Record success"];
                    [_DevicePlaySdRecord setImage:[UIImage imageNamed:@"ico_sdcard.png"] forState:UIControlStateNormal];
                    
                });
            }
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(),^ {
                [self showAllTextDialog:@"Stop Sd-Record failed"];
            });
        }
    }
    else if(type==SET_RESOLUTION){
        if (statusCode==200) {
            dispatch_async(dispatch_get_main_queue(),^ {
                [self showAllTextDialog:@"Set resplution success"];
            });
        }
        else{
            dispatch_async(dispatch_get_main_queue(),^ {
                [self showAllTextDialog:@"Set resplution failed"];
            });
        }
    }
}

//Show or Hidden views
-(void)touchesImage{
    if (_ControlView.hidden) {
        _ControlView.hidden=NO;
        _TitleView.hidden=NO;
    }
    else{
        _ControlView.hidden=YES;
        _TitleView.hidden=YES;
    }
    _PipeView.hidden=YES;
}

#pragma mark --Play Video
- (void) play_video :(NSString *)quility{
    _qualityNow=quility;
    if ([devicePlayIp compare:@"127.0.0.1"]==NSOrderedSame) {
       //如果设备不在本地去执行远程连接
        NabtoLibraryInit();
        nabto_remote_count=0;
        int status =Async_ConnectDeviceWithTunnel(&videoTunnel ,devicePlayId ,554 ,REMOTEPORTPLAY);
        NSLog(@"Video status = %d",status);
        CheckVideoRemoteConnect = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(CheckVideoRemoteConnectTimer:) userInfo:nil repeats:YES];//用定时器1秒去查询一次远程通道打通状态。
    }
    else{
        url = [NSString stringWithFormat:@"rtsp://admin:%@@%@:%d/cam1/%@",devicePlayPsk,devicePlayIp,devicePlayPort,quility];
        _isTcp=NO;
        [_videoView play:url useTcp:_isTcp];
        [_videoView sound:_isOpenVoice];
        [_videoView startGetYUVData:YES];
        [_videoView set_record_frame_rate:fps];
        // Path:@"cam1/h264" 为获取720P(1280X720)图像数据，仅限本地走RTSP UDP 传输时可用
        // 如果要获取QVGA(320X240)图像数据则 Path:@"cam1/h264-1" 。
        GCDUartSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];//建立与设备 TCP 80端口连接，用于串口透传数据发送与接收
        //NSError *err;
        deviceSendPort=80;
//        [GCDUartSocket connectToHost:devicePlayIp onPort:deviceSendPort error:&err];
//        if (err != nil)
//        {
//            NSLog(@"error = %@",err);
//        }
//        [GCDUartSocket readDataWithTimeout:-1 tag:0];
    }

    
}
//Remote Connect
- (void)CheckVideoRemoteConnectTimer:(NSTimer *)timer
{
    if (_isExit) {
        return;
    }
    int status = CheckConnectStatus(&videoTunnel);
    if (status > 0) {
        [CheckVideoRemoteConnect invalidate];
        dispatch_async(dispatch_get_main_queue(), ^{
            devicePlayIp=@"127.0.0.1";
            devicePlayPort=REMOTEPORTPLAY;
            url = [NSString stringWithFormat:@"rtsp://admin:%@@%@:%d/cam1/%@",devicePlayPsk,devicePlayIp,devicePlayPort,_qualityNow];
            _isTcp=YES;
            [_videoView play:url useTcp:_isTcp];
            [_videoView sound:_isOpenVoice];
            [_videoView startGetYUVData:YES];
            [_videoView set_record_frame_rate:fps];
            
           int status =Async_ConnectDeviceWithTunnel(&httpTunnel ,devicePlayId ,80 ,REMOTEPORTMAPPING);
            deviceSendPort=REMOTEPORTMAPPING;
            NSLog(@"Uart status = %d",status);
            CheckUartRemoteConnect = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(CheckUartRemoteConnectTimer) userInfo:nil repeats:YES];//用定时器1秒去查询一次远程通道打通状态。
        });
    }
    nabto_remote_count++;
    if (nabto_remote_count>REMOTECONNECTTIMEOUT) {
        [timer invalidate];
        dispatch_async(dispatch_get_main_queue(), ^{
            CloseTunnel(&videoTunnel);
            nabtoConnectStatus = NTCS_CLOSED;
            DeviceConnectFailed *v = [[DeviceConnectFailed alloc] init];
            [self.navigationController pushViewController: v animated:true];
        });
    }
    NSLog(@"%d",nabto_remote_count);
}

-(void)CheckUartRemoteConnectTimer{
    if (_isExit) {
        return;
    }
    int status = CheckConnectStatus(&httpTunnel);
    //NSLog(@"CheckUart status = %d",status);
    if (status > 0) {//大于0说明远程连接通道已经打通，具体判断打通状态类型可参考rak520.h文件接口说明
        [CheckUartRemoteConnect invalidate];
//        GCDUartSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];//Uart
//        NSError *err;
//        [GCDUartSocket connectToHost:devicePlayIp onPort:REMOTEPORTMAPPING error:&err];//这里连接IP地址为远程配置连接时映射的LOCALMAPPINGIP，端口号为远程配置连接时自定义的LOCALMAPPINGPORT
//        //只要是经过远程打通通道的远程设备TCP连接IP都为@"127.0.0.1"，端口号为配置远程连接时自己定义的。
//        if (err != nil)
//        {
//            NSLog(@"%@",err);
//        }
//        [GCDUartSocket readDataWithTimeout:-1 tag:0];
    }
}


#pragma mark --LX520Delegate
- (void)state_changed:(int)state
{
    NSLog(@"state = %d", state);
    switch (state) {
        case 0: //STATE_IDLE
        {
            break;
        }
        case 1: //STATE_PREPARING
        {
            break;
        }
        case 2: //STATE_PLAYING
        {
            _isOpened = YES;
            dispatch_async(dispatch_get_main_queue(),^ {
                _DeviceConnectingView.hidden=YES;

//                DeviceData *_device_Data=[[DeviceData alloc]init];
//                [_device_Data saveDeviceById:devicePlayId :devicePlayName :devicePlayIp :_deviceOffline];
            });
            break;
        }
        case 3: //STATE_STOPPED
        {
            _isOpened = NO;
            NSLog(@"STATE_STOPPED=====");
            break;
        }
            
        default:
            break;
    }
}

- (void)video_info:(NSString *)codecName codecLongName:(NSString *)codecLongName
{
    
}

- (void)audio_info:(NSString *)codecName codecLongName:(NSString *)codecLongName sampleRate:(int)sampleRate channels:(int)channels
{
    
}

//Connecting Back
- (void)_DeviceConnectingBackClick{
    [self.navigationController popViewControllerAnimated:YES];
}

+(void)back{
    _isExit=YES;
    NSLog(@"back");
    if (_isOpened)
    {
        [_videoView startGetYUVData:NO];
        [_videoView sound:NO];
        [_videoView stop];
        NSLog(@"stop play");
    }
    [CheckVideoPlay invalidate];
    CheckVideoPlay = nil;
    if ([devicePlayIp compare:@"127.0.0.1"]==NSOrderedSame) {
        CloseTunnel(&videoTunnel);
        CloseTunnel(&httpTunnel);
//        free(videoTunnel);
//        free(httpTunnel);
        nabtoConnectStatus = NTCS_CLOSED;
    }
    
    [_self popViewControllerAnimated:YES];
}

//Back
- (void)_DevicePlayBackClick{
    [DevicePlay back];
    //[self.navigationController popViewControllerAnimated:YES];
}

//Sd Record
- (void)_DevicePlaySdRecordClick{
    if (isSdRecord) {
        [_parametersConfigDevicePlay stopSdRecord:0];
    }
    else{
        [_parametersConfigDevicePlay startSdRecord:0];
    }
}

bool isSdRecord=false;

//Play back
- (void)_DevicePlayPlaybackClick{
    PlayBackFolderList *v = [[PlayBackFolderList alloc] init];
    [self.navigationController pushViewController: v animated:true];
}

//ChangePipe
- (void)_DevicePlayChangePipeClick{
    if (_PipeView.hidden) {
        _PipeView.hidden=NO;
    }
    else{
        _PipeView.hidden=YES;
    }
}

//Auto
- (void)_DevicePlayAutoClick{
    _PipeView.hidden=YES;
    if (!_isOpened) {
        return;
    }
    if (_isLx520) {
        if ([devicePlayIp compare:@"127.0.0.1"]==NSOrderedSame) {
            if ([_qualityNow compare:_qualityBD]==NSOrderedSame) {
                [self showAllTextDialog:NSLocalizedString(@"video_BD_ok", nil)];
            }
            else{
                [_videoView stop];
                _DeviceConnectingView.hidden=NO;
                [self setViewNewFrame:640 :480];
                _videoView.center=self.view.center;
                url = [NSString stringWithFormat:@"rtsp://admin:%@@%@:%d/cam1/%@",devicePlayPsk,devicePlayIp,devicePlayPort,_qualityBD];
                _qualityNow=_qualityBD;
                [_videoView play:url useTcp:_isTcp];
                [_videoView sound:_isOpenVoice];
                [_videoView startGetYUVData:YES];
                //[_videoView set_record_frame_rate:fps];
            }
        }
        else{
            if ([_qualityNow compare:_qualityHD]==NSOrderedSame) {
                [self showAllTextDialog:NSLocalizedString(@"video_HD_ok", nil)];
            }
            else{
                [_videoView stop];
                _DeviceConnectingView.hidden=NO;
                [self setViewNewFrame:1280 :720];
                _videoView.center=self.view.center;
                url = [NSString stringWithFormat:@"rtsp://admin:%@@%@:%d/cam1/%@",devicePlayPsk,devicePlayIp,devicePlayPort,_qualityHD];
                _qualityNow=_qualityBD;
                [_videoView play:url useTcp:_isTcp];
                [_videoView sound:_isOpenVoice];
                [_videoView startGetYUVData:YES];
                //[_videoView set_record_frame_rate:fps];
            }
        }
        [_DevicePlayChangePipe setTitle: NSLocalizedString(@"video_auto", nil) forState: UIControlStateNormal];
    }
    else{
        _resolution=2;
        [_parametersConfigDevicePlay setResolution:0 :_resolution];
        [_DevicePlayChangePipe setTitle: NSLocalizedString(@"video_auto", nil) forState: UIControlStateNormal];
    }
}


//VHD
- (void)_DevicePlayVHDClick{
    _PipeView.hidden=YES;
    if (!_isOpened) {
        return;
    }
    if (_isLx520) {
        return;
    }
    else{
        if (_resolution==3) {
            [self showAllTextDialog:NSLocalizedString(@"video_VHD_ok", nil)];
        }
        else{
            _resolution=3;
            [_parametersConfigDevicePlay setResolution:0 :_resolution];
            [_DevicePlayChangePipe setTitle: NSLocalizedString(@"video_VHD", nil) forState: UIControlStateNormal];
        }
    }
}

//HD
- (void)_DevicePlayHDClick{
    _PipeView.hidden=YES;
    if (!_isOpened) {
        return;
    }
    if (_isLx520) {
        if ([_qualityNow compare:_qualityHD]==NSOrderedSame) {
            [self showAllTextDialog:NSLocalizedString(@"video_HD_ok", nil)];
        }
        else{
            [_videoView stop];
            _DeviceConnectingView.hidden=NO;
            [self setViewNewFrame:1280 :720];
            _videoView.center=self.view.center;
            url = [NSString stringWithFormat:@"rtsp://admin:%@@%@:%d/cam1/%@",devicePlayPsk,devicePlayIp,devicePlayPort,_qualityHD];
            _qualityNow=_qualityHD;
            [_videoView play:url useTcp:_isTcp];
            [_videoView sound:_isOpenVoice];
            [_videoView startGetYUVData:YES];
            [_DevicePlayChangePipe setTitle: NSLocalizedString(@"video_HD", nil) forState: UIControlStateNormal];
        }
    }
    else{
        if (_resolution==2) {
            [self showAllTextDialog:NSLocalizedString(@"video_HD_ok", nil)];
        }
        else{
            _resolution=2;
            [_parametersConfigDevicePlay setResolution:0 :_resolution];
            [_DevicePlayChangePipe setTitle: NSLocalizedString(@"video_HD", nil) forState: UIControlStateNormal];
        }
    }
    
}

//BD
- (void)_DevicePlayBDClick{
    _PipeView.hidden=YES;
    if (!_isOpened) {
        return;
    }
    if (_isLx520) {
        if ([_qualityNow compare:_qualityBD]==NSOrderedSame) {
            [self showAllTextDialog:NSLocalizedString(@"video_BD_ok", nil)];
        }
        else{
            [_videoView stop];
            [self setViewNewFrame:640 :480];
            _videoView.center=self.view.center;
            url = [NSString stringWithFormat:@"rtsp://admin:%@@%@:%d/cam1/%@",devicePlayPsk,devicePlayIp,devicePlayPort,_qualityBD];
            _qualityNow=_qualityBD;
            [_videoView play:url useTcp:_isTcp];
            [_videoView sound:_isOpenVoice];
            [_videoView startGetYUVData:YES];
            [_DevicePlayChangePipe setTitle: NSLocalizedString(@"video_BD", nil) forState: UIControlStateNormal];
        }
    }
    else{
        if (_resolution==1) {
            [self showAllTextDialog:NSLocalizedString(@"video_BD_ok", nil)];
        }
        else{
            _resolution=1;
            [_parametersConfigDevicePlay setResolution:0 :_resolution];
            [_DevicePlayChangePipe setTitle: NSLocalizedString(@"video_BD", nil) forState: UIControlStateNormal];
        }
    }
}

//Voice
- (void)_DevicePlayVoiceClick{
    _isOpenVoice=!_isOpenVoice;
    [_videoView sound:_isOpenVoice];
    if (_isOpenVoice) {
        [_DevicePlayVoice setImage:[UIImage imageNamed:@"video_voice_on.png"] forState:UIControlStateNormal];
    }
    else{
        [_DevicePlayVoice setImage:[UIImage imageNamed:@"video_voice_off.png"] forState:UIControlStateNormal];
    }
}

//Take Photo
- (void)_DevicePlayTakePhotoClick{
    if (!_isOpened) {
        return;
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [_albumObject createAlbumInPhoneAlbum:album_name];
        [_albumObject getPathForRecord:album_name];
    });
    [self playSound:@"shutter.mp3"];
    [_videoView take_photo];
}

- (void)playSound:(NSString *)sourcePath
{
    //1.获得音效文件的全路径
    NSURL *url=[[NSBundle mainBundle]URLForResource:sourcePath withExtension:nil];
    //2.加载音效文件，创建音效ID（SoundID,一个ID对应一个音效文件）
    SystemSoundID soundID=0;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &soundID);
    //3.播放音效文件
    //下面的两个函数都可以用来播放音效文件，第一个函数伴随有震动效果
    //AudioServicesPlayAlertSound(soundID);
    AudioServicesPlaySystemSound(soundID);
}

- (void)Save_Paths:(NSMutableArray *)Timesamp :(NSString *)key
{
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    [defaults setObject:Timesamp forKey:key];
    [defaults synchronize];
}

- (NSMutableArray *)Get_Paths:(NSString *)key
{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSMutableArray *value=[defaults objectForKey:key];
    return value;
}

- (void)take_photo:(UIImage *)image
{
    [_albumObject saveImageToAlbum:image albumName:album_name];
}

//拍照回调
- (void)saveImageToAlbum:(BOOL)success{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (success) {
            [self showAllTextDialog:NSLocalizedString(@"video_take_photo_text", nil)];
        }
        else{
            [self showAllTextDialog:@"Save photo to album failed"];
        }
    });
}

//拍照回调
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(NSDictionary  *)contextInfo
{
    if (error==nil) {
        [self showAllTextDialog:NSLocalizedString(@"video_take_photo_text", nil)];
    }
}

//Record
- (void)_DevicePlayRecordClick{
    if (!_isOpened) {
        return;
    }
    
    if (_isRecord) {
        _isRecord = NO;
        [self playSound:@"end_record.mp3"];
        [l_recodevideo removeFromSuperview];
        [_videoView end_record];
        NSString *filename=[NSString stringWithFormat:@"%@tmp.mp4", NSTemporaryDirectory()];
        NSURL * FileUrl = [NSURL URLWithString:filename];
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library saveVideo:FileUrl toAlbum:album_name completion:^(NSURL *assetURL, NSError *error) {
            //删除临时文件
            NSError *Err;
            [[NSFileManager defaultManager] removeItemAtPath:filename error:&Err];
            NSLog(@"xxxxtherr=%@", Err);
            
        } failure:^(NSError *error) {
            NSLog(@"error=%@", error);
        }];
        [self showAllTextDialog:NSLocalizedString(@"video_record_text", nil)];
    }
    else{
        _isRecord = YES;
        NSString *filename=[NSString stringWithFormat:@"%@tmp.mp4", NSTemporaryDirectory()];
        [_videoView begin_record2:0 :filename];
        
        VideoRecordTimerTick_s = 0;
        VideoRecordTimerTick_m = 0;
        l_recodevideo = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width -110, _TitleView.frame.size.height+10, 100, 40)];
        l_recodevideo.text = @"REC 00:00";
        //l_recodevideo.font = [UIFont boldSystemFontOfSize:20];
        l_recodevideo.textColor = [UIColor redColor];
        l_recodevideo.adjustsFontSizeToFitWidth = YES;
        l_recodevideo.numberOfLines = 1;
        l_recodevideo.backgroundColor=[UIColor clearColor];
        [self.view addSubview:l_recodevideo];
    }
}

int VideoRecordTimerTick_s = 0;
int VideoRecordTimerTick_m = 0;
-(void)updateVideoRecordTimer{
    if (_isRecord == NO) {
        return;
    }
    VideoRecordTimerTick_s ++;
    if (VideoRecordTimerTick_s > 59) {
        VideoRecordTimerTick_m++;
        VideoRecordTimerTick_s = 0;
    }
    if (VideoRecordTimerTick_m > 59) {
        VideoRecordTimerTick_m = 0;
    }
    l_recodevideo.text = [NSString stringWithFormat:@"REC %.2d:%.2d",VideoRecordTimerTick_m,VideoRecordTimerTick_s];
}
-(void)CheckVideoPlayTimer{
    [self updateVideoRecordTimer];
}


//Audio
- (void)onVoiceRecordButtonClicked
{
    if (!_isOpened) {
        return;
    }
    if (![self openVoiceIndicator]) {
        return;
    }
    
    [_DevicePlayRecordVoiceView setHidden:NO];
    voiceRecordSecond = 0;
    [audioRecord StartRecord];
    voiceRecordTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(voiceRecordTimer) userInfo:nil repeats:YES];
}

- (void)onVoiceRecordButtonTouchUp
{
    if (!_isOpened) {
        return;
    }
    [_DevicePlayRecordVoiceView setHidden:YES];
    [voiceRecordTimer invalidate];
    voiceRecordTimer = nil;
    _DevicePlayRecordVoiceText.text = @"00:00";
    NSData* PCMUData = [audioRecord StopRecord];
    NSLog(@"PCMUData LEN = %lu",(unsigned long)PCMUData.length);
    [sendAudio sendWithIp:devicePlayIp port:deviceSendPort data:PCMUData];
}

BOOL voicePermission=NO;
- (BOOL)openVoiceIndicator{
    voicePermission=NO;
    AVAudioSession *avSession = [AVAudioSession sharedInstance];
    if ([avSession respondsToSelector:@selector(requestRecordPermission:)]) {
        [avSession requestRecordPermission:^(BOOL available) {
            if (available) {
                //completionHandler
                voicePermission=YES;
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"voice_indicator_text", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"voice_indicator_btn", nil)  otherButtonTitles:nil] show];
                });
            }
        }];
    }
    return voicePermission;
}

-(void)voiceRecordTimer{
    voiceRecordSecond ++;
    uint64_t hour = voiceRecordSecond / 3600;
    uint64_t min = (voiceRecordSecond - hour * 3600) / 60;
    uint64_t sec = voiceRecordSecond - hour * 3600 - min * 60;
    if(min < 10)
    {
        if(sec < 10)
            _DevicePlayRecordVoiceText.text = [NSString stringWithFormat:@"0%llu:0%llu", min,sec];
        else
            _DevicePlayRecordVoiceText.text = [NSString stringWithFormat:@"0%llu:%llu", min, sec];
    }
    else
    {
        if(sec < 10)
            _DevicePlayRecordVoiceText.text = [NSString stringWithFormat:@"%llu:0%llu", min, sec];
        else
            _DevicePlayRecordVoiceText.text = [NSString stringWithFormat:@"%llu:%llu", min, sec];
    }
}

//Uart
- (void)_DevicePlayUartClick{
    DeviceUart *v = [[DeviceUart alloc] init];
    [self.navigationController pushViewController: v animated:true];
}

//Settings
- (void)_DevicePlaySettingsClick{
    DeviceSettings *v = [[DeviceSettings alloc] init];
    [self.navigationController pushViewController: v animated:true];
}

//Get Parameter
- (NSString *)Get_Parameter:(NSString *)key
{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSString *value=[defaults objectForKey:key];
    return value;
}

-(void)showAllTextDialog:(NSString *)str{
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.labelText = str;
    HUD.mode = MBProgressHUDModeText;
    [HUD showAnimated:YES whileExecutingBlock:^{
        sleep(1);
    } completionBlock:^{
        [HUD removeFromSuperview];
        //[HUD release];
        //HUD = nil;
    }];
}

//Set StatusBar
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden//for iOS7.0
{
    return YES;
}

bool isPortrait=YES;
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        NSLog(@"Portrait");
        isPortrait=YES;
    }
    else
    {
        isPortrait=NO;
        NSLog(@"Landscape");
    }
    
    viewW=self.view.frame.size.width;
    viewH=self.view.frame.size.height;
    _videoView.frame=self.view.frame;
    if (_isLx520){
        if ([_qualityNow compare:_qualityBD]==NSOrderedSame) {//标清
            [self setViewNewFrame:640 :480];
        }
        else {//高清
            [self setViewNewFrame:1280 :720];
        }
    }
    else{
        if (_resolution==1) {//标清
            [self setViewNewFrame:640 :480];
        }
        else if (_resolution==2) {//高清
            [self setViewNewFrame:1280 :720];
        }
        else if (_resolution==3) {//超清
            [self setViewNewFrame:1920 :1080];
        }
    }
    
    _videoView.center=self.view.center;
    _TitleView.frame=CGRectMake(0, 0, viewW,title_size+diff_top);
    _DevicePlayBack.frame=CGRectMake(diff_x, diff_top, add_title_size, add_title_size);
    _DevicePlayName.frame = CGRectMake(0, 0, viewW-_DevicePlayBack.frame.size.width-diff_x, viewW*0.06);
    _DevicePlayName.center=CGPointMake(viewW*0.5,_DevicePlayBack.center.y);
    _DevicePlayPlayback.frame=CGRectMake(viewW-diff_x-viewW*0.06, diff_top, viewW*0.06, viewW*0.06);
    _DevicePlaySdRecord.frame=CGRectMake(_DevicePlayPlayback.frame.origin.x-2*diff_x-viewW*0.06, diff_top, viewW*0.06*84/73, viewW*0.06);
    
    CGFloat sizeV = 50;
    CGFloat gapX = 10;
    CGFloat gapY=5;
    CGFloat diffV = (viewW-gapX*2-50*7)/6;
    _ControlView.frame=CGRectMake(0, viewH-sizeV-gapY*2, viewW,sizeV+gapY*2);
    _DevicePlayChangePipe.frame = CGRectMake(gapX, gapY, sizeV,sizeV);
    _DevicePlayVoice.frame=CGRectMake(gapX+sizeV+diffV, gapY, sizeV, sizeV);
    _DevicePlayTakePhoto.frame=CGRectMake(gapX+sizeV*2+diffV*2, gapY, sizeV, sizeV);
    _DevicePlayRecord.frame=CGRectMake(gapX+sizeV*3+diffV*3, gapY, sizeV, sizeV);
    _DevicePlayAudio.frame=CGRectMake(gapX+sizeV*4+diffV*4, gapY, sizeV, sizeV);
    _DevicePlayUart.frame=CGRectMake(gapX+sizeV*5+diffV*5, gapY, sizeV, sizeV);
    _DevicePlaySettings.frame=CGRectMake(gapX+sizeV*6+diffV*6, gapY, sizeV, sizeV);
    
    _PipeView.frame=CGRectMake(0, _ControlView.frame.origin.y-sizeV*3, sizeV+gapX, sizeV*3);
    _DevicePlayBD.frame = CGRectMake(gapX*1.25, 2*sizeV, sizeV,sizeV);
    _DevicePlayHD.frame = CGRectMake(gapX*1.25, sizeV, sizeV,sizeV);
    _DevicePlayAuto.frame = CGRectMake(gapX*1.25, 0, sizeV,sizeV);
    
    _DeviceConnectingView.frame=CGRectMake(0, 0, viewW, viewH);
    _DeviceConnectingBack.frame=CGRectMake(diff_x, diff_top, add_title_size, add_title_size);
    _DeviceConnectingImage.frame =CGRectMake(0, 0, viewW*0.4, viewW*0.4);
    _DeviceConnectingImage.center=CGPointMake(_DeviceConnectingView.center.x,_DeviceConnectingView.center.y-diff_top);
    _DeviceConnectingText.frame = CGRectMake(diff_x, _DeviceConnectingImage.frame.size.height+_DeviceConnectingImage.frame.origin.y+diff_top, viewW-2*diff_x, title_size*2);
    
    _DevicePlayRecordVoiceView.frame=CGRectMake(0, 0, viewW*0.4, viewW*0.4);
    _DevicePlayRecordVoiceView.center=CGPointMake(viewW/2, viewH/2);
    _DevicePlayRecordVoiceImage.frame =CGRectMake(0, 0, viewW*0.4*126/163,viewW*0.4);
    _DevicePlayRecordVoiceImage.center=CGPointMake(_DevicePlayRecordVoiceView.frame.size.width*0.5,_DevicePlayRecordVoiceView.frame.size.height*0.5);
    _DevicePlayRecordVoiceText.frame=CGRectMake(0,_DevicePlayRecordVoiceView.frame.size.height- title_size-gapY , _DevicePlayRecordVoiceView.frame.size.width, title_size);
    
    l_recodevideo.frame = CGRectMake(self.view.frame.size.width -110, _TitleView.frame.size.height+10, 100, 40);
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
    
}


@end

//
//  DevicePlay.h
//  AoSmart
//
//  Created by rakwireless on 16/1/26.
//  Copyright © 2016年 rak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParametersConfig.h"

@interface DevicePlay : UIViewController<ParametersConfigDelegate>
{
    UIView *_TitleView;
    UIButton *_DevicePlayBack;
    UILabel  *_DevicePlayName;
    UIButton *_DevicePlaySdRecord;
    UIButton *_DevicePlayPlayback;
    
    UIView *_ControlView;
    UIButton  *_DevicePlayChangePipe;
    UIButton  *_DevicePlayVoice;
    UIButton  *_DevicePlayTakePhoto;
    UIButton  *_DevicePlayRecord;
    UIButton  *_DevicePlayAudio;
    UIButton  *_DevicePlayUart;
    UIButton  *_DevicePlaySettings;
    
    UIView *_PipeView;
    UIButton  *_DevicePlayAuto;
    UIButton  *_DevicePlayVHD;
    UIButton  *_DevicePlayHD;
    UIButton  *_DevicePlayBD;
    
    UIView *_DeviceConnectingView;
    UIButton *_DeviceConnectingBack;
    UIImageView *_DeviceConnectingImage;
    UILabel *_DeviceConnectingText;
    
    UILabel *l_recodevideo;
    
    UIView *_DevicePlayRecordVoiceView;
    UIImageView *_DevicePlayRecordVoiceImage;
    UILabel *_DevicePlayRecordVoiceText;
}
+(void)back;

@property (retain, nonatomic) ParametersConfig* parametersConfigDevicePlay;
@end

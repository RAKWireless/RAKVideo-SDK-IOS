//
//  ParametersConfig.m
//  AoSmart
//
//  Created by rakwireless on 2017/4/14.
//  Copyright © 2017年 rak. All rights reserved.
//

#import "ParametersConfig.h"
#import "HttpRequest.h"

@implementation ParametersConfig
{
    NSString *_ip;
    NSString *_password;
    NSString *_username;
    NSString *_url;
    NSString *_body;
    int _type;
}

/**
 * Init
 */
-(id) init:(id<ParametersConfigDelegate>)delegate ip:(NSString*)ip password:(NSString*)password{
    self = [super init];
    _ip=ip;
    _password=password;
    _username=@"admin";
    
    if (self){
        self.delegate= delegate;//[delegate retain];
    }
    return  self;
}

/**
 * Set Username
 */
- (void)setUsername:(NSString*)username{
    _username=username;
}

/**
 * Set Password
 */
- (void)setPassword:(NSString*)password{
    _password=password;
}

- (void)get{
    NSThread* httpThread = [[NSThread alloc] initWithTarget:self
                                                   selector:@selector(getUrl)
                                                     object:nil];
    [httpThread start];
}

- (void)getUrl{
    NSString *way=@"GET";
    if (_body==nil) {
        way=@"GET";
    }
    else{
        way=@"POST";
    }
    HttpRequest* http_request = [HttpRequest HTTPRequestWithUrl:_url andData:_body andMethod:way andUserName:_username andPassword:_password];
    if ([_delegate respondsToSelector:@selector(setOnResultListener: : :)]) {
        [_delegate setOnResultListener:http_request.StatusCode :http_request.ResponseString :_type];
    }
}

/**
 * Description: Update Username And Password.
 * Return:
 * 			{"value": "0"} -- success.
 * 			other means failed.
 */
- (void)updateUsernameAndPassword:(NSString*)newUsername :(NSString*)newPassword{
    _type=UPDATE_USERNAME_PASSWORD;
    _body=nil;
    _url=[NSString stringWithFormat:@"http://%@/param.cgi?action=update&group=login&username=%@&password=%@",_ip,newUsername,newPassword];
    [self get];
}

/**
 * Description: Get Username And Password.
 * Return: Username and password of module.
 */
- (void)getUsernameAndPassword{
    _type=GET_USERNAME_PASSWORD;
    _body=nil;
    _url=[NSString stringWithFormat:@"http://%@/param.cgi?action=list&group=login",_ip];
    [self get];
}

/**
 * Description: Get SSID List.
 * Return: SSID List from module.
 */
- (void)getSsidList{
    _type=GET_SSID_LIST;
    _body=nil;
    _url=[NSString stringWithFormat:@"http://%@/server.command?command=get_wifilist",_ip];
    [self get];
}

/**
 * Description: Join Wifi, used to APConfig.
 */
- (void)joinWifi:(NSString*)ssid :(NSString*)password{
    _type=JOIN_WIFI;
    _body=nil;
    _url=[NSString stringWithFormat:@"http://%@/param.cgi?action=update&group=wifi&sta_ssid=%@&sta_auth_key=%@",_ip,ssid,password];
    [self get];
}

/**
 * Description: Get Version of module.
 * Return: Version of module.
 */
- (void)getVersion{
    _type=GET_VERSION;
    _body=nil;
    _url=[NSString stringWithFormat:@"http://%@/server.command?command=get_version",_ip];
    [self get];
}

/**
 * Description: Set Resolution of module.
 * Parameters:
 * 				type: 0--Local video resolution	1--Remote video resolution
 * 				resolution: 0--QVGA(320X240)	1--VGA(640X480)		2--720P(1280X720)	3--1080P(1920X1080)
 * 	Return:
 * 				{"value": "0"} -- success
 * 				other means failed
 */
- (void)setResolution:(int)type :(int)resolution{
    _type=SET_RESOLUTION;
    _body=nil;
    _url=[NSString stringWithFormat:@"http://%@/server.command?command=set_resol&type=h264&pipe=%d&value=%d",_ip,type,resolution];
    [self get];
}

/**
 * Description: Get Resolution of module.
 * Parameters:
 * 				type: 0--Local video resolution	1--Remote video resolution
 * Return:
 * 			{"value": "0"} --QVGA(320X240)
 * 			{"value": "1"} --VGA(640X480)
 * 			{"value": "2"} --720P(1280X720)
 * 			{"value": "3"} --1080P(1920X1080)
 */
- (void)getResolution:(int)type{
    _type=GET_RESOLUTION;
    _body=nil;
    _url=[NSString stringWithFormat:@"http://%@/server.command?command=get_resol&type=h264&pipe=%d",_ip,type];
    [self get];
}

/**
 * Description: Set FPS of module.
 * Parameters:
 * 				type: 0--Local video resolution	1--Remote video resolution
 * 				fps: The FPS of module you want to set (range: 1~30)
 * Return:
 * 			{"value": "0"} -- success.
 * 			other means failed.
 */
- (void)setFps:(int)type :(NSString*)fps{
    _type=SET_FPS;
    _body=nil;
    _url=[NSString stringWithFormat:@"http://%@/server.command?command=set_max_fps&type=h264&pipe=%d&value=%@",_ip,type,fps];
    [self get];
}

/**
 * Description: Get FPS of module.
 * Parameters:
 * 				type: 0--Local video resolution	1--Remote video resolution
 * Return as:
 * 			{"value": "10"} -- 10 is the FPS of module.
 */
- (void)getFps:(int)type{
    _type=GET_FPS;
    _body=nil;
    _url=[NSString stringWithFormat:@"http://%@/server.command?command=get_max_fps&type=h264&pipe=%d",_ip,type];
    [self get];
}

/**
 * Description: Set quality of module.
 * Parameters:
 * 				type: 0--Local video resolution	1--Remote video resolution
 * 				quality: The quality of module you want to set (range: 0~139)
 * Return:
 * 			{"value": "0"} -- success.
 * 			other means failed.
 */
- (void)setQuality:(int)type :(NSString*)quality{
    _type=SET_QUALITY;
    _body=nil;
    _url=[NSString stringWithFormat:@"http://%@/server.command?command=set_enc_quality&type=h264&pipe=%d&value=%@",_ip,type,quality];
    [self get];
}

/**
 * Description: Get quality of module.
 * Parameters:
 * 				type: 0--Local video resolution	1--Remote video resolution
 * Return as:
 * 				{"value": "0"} -- Auto quality.
 * 		  or:
 * 				{"value": "100"} -- 100 is the quality of module.
 */
- (void)getQuality:(int)type{
    _type=GET_QUALITY;
    _body=nil;
    _url=[NSString stringWithFormat:@"http://%@/server.command?command=get_enc_quality&type=h264&pipe=%d",_ip,type];
    [self get];
}

/**
 * Description: Set GOP of module.
 * Parameters:
 * 				Only for remote video resolution
 * 				gop: The GOP of module you want to set (range: 0~100)
 * Return:
 * 			{"value": "0"} -- success.
 * 			other means failed.
 */
- (void)setGOP:(NSString*)gop{
    _type=SET_GOP;
    _body=nil;
    _url=[NSString stringWithFormat:@"http://%@/server.command?command=set_enc_gop&type=h264&pipe=1&value=%@",_ip,gop];
    [self get];
}

/**
 * Description: Get GOP of module.
 * Parameters:
 * 				Only for remote video resolution
 * Return as:
 * 				{"value": "0"} -- Auto GOP.
 * 		  or:
 * 				{"value": "100"} -- 100 is the GOP of module.
 */
- (void)getGOP{
    _type=GET_GOP;
    _body=nil;
    _url=[NSString stringWithFormat:@"http://%@/server.command?command=get_enc_gop&type=h264&pipe=1",_ip];
    [self get];
}

/**
 * Description: Start record video to SD-Card.
 * Parameters:
 * 				type: 0--Local video resolution	1--Remote video resolution
 * Return:
 * 				{"value": "0"} -- success.
 * 				{"value": "-4"} -- busy, it is recording now.
 * 				{"value": "-22"} -- SD card storage space is not enough.
 * 				other means error.
 */
- (void)startSdRecord:(int)type{
    _type=START_SD_RECORD;
    _body=nil;
    _url=[NSString stringWithFormat:@"http://%@/server.command?command=start_record_pipe&type=h264&pipe=%d",_ip,type];
    [self get];
}

/**
 * Description: Stop record video to SD-Card.
 * Parameters:
 * 				type: 0--Local video resolution	1--Remote video resolution
 * Return:
 * 				{"value": "0"} -- success.
 * 				other means error.
 */
- (void)stopSdRecord:(int)type{
    _type=STOP_SD_RECORD;
    _body=nil;
    _url=[NSString stringWithFormat:@"http://%@/server.command?command=stop_record&type=h264&pipe=%d",_ip,type];
    [self get];
}

/**
 * Description: Get SD-Card Record Status.
 * 				type: 0--Local video resolution	1--Remote video resolution
 * Return:
 * 				{"value": "0"} -- free.
 * 				{"value": "1"} -- busy, it is recording now.
 */
- (void)getSdRecordStatus:(int)type{
    _type=GET_SD_RECORD_STATUS;
    _body=nil;
    _url=[NSString stringWithFormat:@"http://%@/server.command?command=is_pipe_record&type=h264&pipe=%d",_ip,type];
    [self get];
}

/**
 * Description: Set RTC of module, used to SD-Card record time.
 * Parameters:
 * 				date: set date
 * 				hour: set hour
 * 				minute: set minute
 * 				second: set second
 * 				timezone: set timezone, as GMT-8:00
 * Return:
 * 				{"value": "0"} -- success.
 * 				other means error.
 */
- (void)setModuleRtcTime:(NSString*)date :(int)hour
                        :(int)minute :(int)second :(NSString*)timezone{
    _type=SET_MODULE_RTC_TIME;
    _body=nil;
    _url=[NSString stringWithFormat:@"http://%@/SkyEye/ctrlServerConfig.ncgi?doAction=write&Date=%@&Hour=%d&Minute=%d&Second=%d&SetNow=0&TimeZone=GMT%@",_ip,date,hour,minute,second,timezone];
    [self get];
}

/**
 * Description: Get video folder list form SD-Card.
 * Return:
 * 				Video folder list of SD-Card.
 */
- (void)getVideoFolderList{
    _type=GET_VIDEO_FOLDER_LIST;
    _body=nil;
    _url=[NSString stringWithFormat:@"http://%@/param.cgi?action=list&group=videodir&fmt=link&pipe=0&type=0",_ip];
    [self get];
}

/**
 * Description: Get video list form SD-Card.
 * Parameters:
 * 				folder: Video folder name of SD-Card.
 * Return:
 * 				Video list of video folder in SD-Card.
 */
- (void)getVideoList:(NSString*)folder{
    _type=GET_VIDEO_LIST;
    _body=nil;
    _url=[NSString stringWithFormat:@"http://%@/param.cgi?action=list&group=file&fmt=link&pipe=0&type=0&folder=%@",_ip,folder];
    [self get];
}

/**
 * Description: Get signal of module.
 * Return as:
 * 			{"ssid":"TP_LINK","signal_level":"-60"}
 */
- (void)get_Signal{
    _type=GET_SIGNAL;
    _body=nil;
    _url=[NSString stringWithFormat:@"http://%@/server.command?command=get_signal_level",_ip];
    [self get];
}



@end

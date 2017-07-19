//
//  ParametersConfig.h
//  AoSmart
//
//  Created by rakwireless on 2017/4/14.
//  Copyright © 2017年 rak. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ParametersConfigDelegate <NSObject>
-(void)setOnResultListener:(int)statusCode :(NSString*)body :(int)type;
@end

@interface ParametersConfig : NSObject
@property(nonatomic,weak) id <ParametersConfigDelegate> delegate;
-(id) init:(id<ParametersConfigDelegate>)delegate ip:(NSString*)ip password:(NSString*)password;
- (void)setUsername:(NSString*)username;
- (void)setPassword:(NSString*)password;

typedef enum {
    UPDATE_USERNAME_PASSWORD,
    GET_USERNAME_PASSWORD,
    GET_SSID_LIST,
    JOIN_WIFI,
    GET_VERSION,
    SET_RESOLUTION,
    GET_RESOLUTION,
    SET_FPS,
    GET_FPS,
    SET_QUALITY,
    GET_QUALITY,
    SET_GOP,
    GET_GOP,
    START_SD_RECORD,
    STOP_SD_RECORD,
    GET_SD_RECORD_STATUS,
    SET_MODULE_RTC_TIME,
    GET_VIDEO_FOLDER_LIST,
    GET_VIDEO_LIST,
    GET_SIGNAL
} RequestType;

- (void)updateUsernameAndPassword:(NSString*)newUsername :(NSString*)newPassword;
- (void)getUsernameAndPassword;
- (void)getSsidList;
- (void)joinWifi:(NSString*)ssid :(NSString*)password;
- (void)getVersion;
- (void)setResolution:(int)type :(int)resolution;
- (void)getResolution:(int)type;
- (void)setFps:(int)type :(NSString*)fps;
- (void)getFps:(int)type;
- (void)setQuality:(int)type :(NSString*)quality;
- (void)getQuality:(int)type;
- (void)setGOP:(NSString*)gop;
- (void)getGOP;
- (void)startSdRecord:(int)type;
- (void)stopSdRecord:(int)type;
- (void)getSdRecordStatus:(int)type;
- (void)setModuleRtcTime:(NSString*)date :(int)hour
                        :(int)minute :(int)second :(NSString*)timezone;
- (void)getVideoFolderList;
- (void)getVideoList:(NSString*)folder;
- (void)get_Signal;
@end

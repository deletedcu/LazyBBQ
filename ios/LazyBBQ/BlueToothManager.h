//
//  BlueToothManager.h
//  BBQ
//
//  Created by Richard on 14/12/10.
//  Copyright (c) 2014年 Chutong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CustomENUM.h"
#import <CoreGraphics/CoreGraphics.h>

@interface BBQInfo : NSObject

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, assign) NSInteger channelOne;
@property (nonatomic, assign) NSInteger channelTwo;
@property (nonatomic, assign) NSInteger channelThree;
@property (nonatomic, assign) NSInteger channelFour;
@property (nonatomic, assign) NSInteger setOne;
@property (nonatomic, assign) NSInteger setTwo;
@property (nonatomic, assign) NSInteger setThree;
@property (nonatomic, assign) NSInteger setFour;

- (id)initWithData:(NSData *)data;
@end

@interface ChannelInfo : NSObject

@property (nonatomic, assign) ChannelType type;             //类型

@property (nonatomic, assign) BOOL enable;                  //是否有数据

@property (nonatomic, assign) NSInteger maxValue;           //最高温度
@property (nonatomic, assign) NSInteger alarmValue;         //设置警报温度
@property (nonatomic, assign) NSInteger alarmFsValue;        //设置警报温度F
@property (nonatomic, assign) NSInteger value;              //当前温度

@property (nonatomic, strong) NSString *meat;               //肉类名称

@property (nonatomic, assign) NSInteger durtaion;           //时长
@property (nonatomic, strong) NSDate *alarmDate;            //设置警报日期

@property (nonatomic, strong) NSDate *startDate;            //开始时间
@property (nonatomic, strong) NSMutableArray *calculateArray;
@property (nonatomic, strong) NSDate *endDate;

/**
 *  @brief 达到制定温度，剩余时间秒数
 无法计算时间时，返回-1。
 */
@property (nonatomic, assign) NSInteger restTime;

@property (nonatomic, assign) NSInteger deviceSetValue;
@end

@interface BlueToothManager : NSObject

/**
 *  实时数据
 */
@property (nonatomic, strong) BBQInfo *info;

/**
 *  @brief  当前蓝牙是否有连接
 */
@property (nonatomic, assign) BOOL connect;

/**
 *  @brief  从蓝牙传回的温度数据，通道1数据
 */
@property (nonatomic, strong) NSMutableArray *listChannelOne;
@property (nonatomic, strong) NSMutableArray *listChannelTwo;
@property (nonatomic, strong) NSMutableArray *listChannelThree;
@property (nonatomic, strong) NSMutableArray *listChannelFour;


/**
 *  @brief  上次接收数据时间
 */
@property (nonatomic, strong) NSDate *lastDate;

@property (nonatomic, strong) ChannelInfo *channelOne;
@property (nonatomic, strong) ChannelInfo *channelTwo;
@property (nonatomic, strong) ChannelInfo *channelThree;
@property (nonatomic, strong) ChannelInfo *channelFour;


+ (BlueToothManager *)shareManager;

- (void)setChannel:(ChannelType)type value:(int)value;
@end

//
//  CustomENUM.h
//  SecondHand
//
//  Created by Richard Shen on 14-2-19.
//  Copyright (c) 2014年 Dianchu. All rights reserved.
//

#import <Foundation/Foundation.h>


//通道类型
typedef NS_ENUM(NSInteger, ChannelType)
{
    ChannelOne = 0,
    ChannelTwo = 1,
    ChannelThree = 2,
    ChannelFour = 3,
};

//烧烤设备的状态
typedef NS_ENUM(NSUInteger, BBQDeviceState)
{
    BBQDeviceStateOn = 1,                           //打开
    BBQDeviceStateOff = 0                           //关闭
};


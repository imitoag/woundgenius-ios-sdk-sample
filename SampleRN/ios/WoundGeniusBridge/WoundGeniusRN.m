//
//  WoundGeniusRN.m
//  SampleRN
//
//  Created by Eugene Naloiko on 07.08.2024.
//  Copyright (c) 2022 by imito AG, Zurich, Switzerland
//

#import <Foundation/Foundation.h>

#import "React/RCTBridgeModule.h"
#import "React/RCTEventEmitter.h"

@interface RCT_EXTERN_MODULE(WoundGeniusRN,RCTEventEmitter)

RCT_EXTERN_METHOD(increment:(RCTResponseSenderBlock)callback)
RCT_EXTERN_METHOD(decrement:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(startCapturing)

@end

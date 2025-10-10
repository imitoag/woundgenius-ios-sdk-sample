//
//  RCTNativeLocalStorage.m
//  TurboModuleExample
//
//  Created by Eugene Naloiko on 03.10.2025.
//

#import "RCTNativeLocalStorage.h"
#import "RCTDefaultReactNativeFactoryDelegate.h"
#import "WoundGeniusRN-Swift.h"

static NSString *const RCTNativeLocalStorageKey = @"local-storage";

@interface RCTNativeLocalStorage()
@property (strong, nonatomic) NSUserDefaults *localStorage;
@property (nonatomic, strong) WoundGeniusRN *woundGenius;
@end

@implementation RCTNativeLocalStorage

- (id) init {
  if (self = [super init]) {
    _localStorage = [[NSUserDefaults alloc] initWithSuiteName:RCTNativeLocalStorageKey];
    _woundGenius = [[WoundGeniusRN alloc] init];
  }
  return self;
}

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:(const facebook::react::ObjCTurboModule::InitParams &)params {
  return std::make_shared<facebook::react::NativeLocalStorageSpecJSI>(params);
}

- (NSString * _Nullable)getItem:(NSString *)key {
  return [self.localStorage stringForKey:key];
}

- (void)setItem:(NSString *)value
          key:(NSString *)key {
  [self.localStorage setObject:value forKey:key];
}

- (void)removeItem:(NSString *)key {
  [self.localStorage removeObjectForKey:key];
}

- (void)clear {
  NSDictionary *keys = [self.localStorage dictionaryRepresentation];
  for (NSString *key in keys) {
    [self removeItem:key];
  }
}

- (void)startCapturing:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject
{
  [self.woundGenius startCapturingWithResolve:resolve reject:reject];
}

- (void)startCapturing {
}

+ (NSString *)moduleName
{
  return @"NativeLocalStorage";
}

@end

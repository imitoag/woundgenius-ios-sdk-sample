//
//  main.m
//  SampleObjc
//
//  Created by Eugene Naloiko on 11.03.2024.
//  Copyright (c) 2022 by imito AG, Zurich, Switzerland
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

int main(int argc, char * argv[]) {
    NSString * appDelegateClassName;
    @autoreleasepool {
        // Setup code that might create autoreleased objects goes here.
        appDelegateClassName = NSStringFromClass([AppDelegate class]);
    }
    return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}

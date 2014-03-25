//
//  AppDelegate.m
//  iBeacon
//
//  Created by Hirohisa Kawasaki on 2014/03/24.
//  Copyright (c) 2014年 Hirohisa Kawasaki. All rights reserved.
//

#import "AppDelegate.h"
#import "NATViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = [[NATViewController alloc] init];
    [self.window makeKeyAndVisible];
    return YES;
}

@end

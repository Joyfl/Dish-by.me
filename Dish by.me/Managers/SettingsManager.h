//
//  SettingsManager.h
//  Dish by.me
//
//  Created by 전수열 on 12. 9. 24..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SettingsManager : NSObject
{
	NSMutableDictionary *_settings;
}

+ (SettingsManager *)manager;

- (id)getSettingForKey:(id)key;
- (void)setSetting:(id)data forKey:(id)key;
- (void)clearSettingForKey:(id)key;
- (BOOL)flush;

@end
//
//  ParseCrashReporting.h
//  Parse
//
//  Created by Nikita Lutsenko on 8/6/14.
//  Copyright (c) 2014 Parse Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 The `ParseCrashReporting` class is responsible for enabling crash reporting in your application.
*/
@interface ParseCrashReporting : NSObject

/*
 @name Crash Reporting
 */

/*!
 Enables crash reporting for your app.
 This must be called before you set Application ID and Client Key on Parse.
 */
+ (void)enable;

/*!
 Indicates whether crash reporting is currently enabled.
 @return `YES` if crash reporting is enabled, `NO` - otherwise.
 */
+ (BOOL)isCrashReportingEnabled;

@end

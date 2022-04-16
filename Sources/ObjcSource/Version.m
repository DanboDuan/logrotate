// Copyright (c) 2022 Bob
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

#import "Version.h"

@implementation Version

+ (NSString *)currentVersion {
#ifdef TOOL_VERSION
    return @TOOL_VERSION;
#endif
    return @"1.0.0";
}

@end

//
//  UtilTools.m
//  boxin
//
//  Created by guduzhonglao on 10/15/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

#import "UtilTools.h"
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#import <sys/utsname.h>

@implementation UtilTools

+ (NSString *) macaddress
{
   
  int         mib[6];
  size_t       len;
  char        *buf;
  unsigned char    *ptr;
  struct if_msghdr  *ifm;
  struct sockaddr_dl *sdl;
   
  mib[0] = CTL_NET;
  mib[1] = AF_ROUTE;
  mib[2] = 0;
  mib[3] = AF_LINK;
  mib[4] = NET_RT_IFLIST;
   
  if ((mib[5] = if_nametoindex("en0")) == 0) {
    printf("Error: if_nametoindex error/n");
    return NULL;
  }
   
  if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
    printf("Error: sysctl, take 1/n");
    return NULL;
  }
   
  if ((buf = malloc(len)) == NULL) {
    printf("Could not allocate memory. error!/n");
    return NULL;
  }
   
  if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
    printf("Error: sysctl, take 2");
    return NULL;
  }
   
  ifm = (struct if_msghdr *)buf;
  sdl = (struct sockaddr_dl *)(ifm + 1);
  ptr = (unsigned char *)LLADDR(sdl);
  NSString *outstring = [NSString stringWithFormat:@"%02x:%02x:%02x:%02x:%02x:%02x", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
   
//  NSString *outstring = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
   
  NSLog(@"outString:%@", outstring);
   
  free(buf);
   
  return [outstring uppercaseString];
}

+ (NSString *)deviceModel {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceModel = [NSString stringWithCString:systemInfo.machine
                                               encoding:NSUTF8StringEncoding];

    // 模拟器
    if ([deviceModel isEqualToString:@"i386"])         return @"Simulator";
    if ([deviceModel isEqualToString:@"x86_64"])       return @"Simulator";

    // iPhone 系列
    if ([deviceModel isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([deviceModel isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([deviceModel isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([deviceModel isEqualToString:@"iPhone3,1"])    return @"iPhone 4 (GSM)";
    if ([deviceModel isEqualToString:@"iPhone3,2"])    return @"Verizon iPhone 4";
    if ([deviceModel isEqualToString:@"iPhone3,3"])    return @"iPhone 4 (CDMA/Verizon/Sprint)";
    if ([deviceModel isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([deviceModel isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([deviceModel isEqualToString:@"iPhone5,2"])    return @"iPhone 5";
    if ([deviceModel isEqualToString:@"iPhone5,3"])    return @"iPhone 5C";
    if ([deviceModel isEqualToString:@"iPhone5,4"])    return @"iPhone 5C";
    if ([deviceModel isEqualToString:@"iPhone6,1"])    return @"iPhone 5S";
    if ([deviceModel isEqualToString:@"iPhone6,2"])    return @"iPhone 5S";
    if ([deviceModel isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([deviceModel isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([deviceModel isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([deviceModel isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    if ([deviceModel isEqualToString:@"iPhone8,4"])    return @"iPhone SE";
    if ([deviceModel isEqualToString:@"iPhone9,1"])    return @"iPhone 7";
    if ([deviceModel isEqualToString:@"iPhone9,3"])    return @"iPhone 7";
    if ([deviceModel isEqualToString:@"iPhone9,2"])    return @"iPhone 7 Plus";
    if ([deviceModel isEqualToString:@"iPhone9,4"])    return @"iPhone 7 Plus";
    if ([deviceModel isEqualToString:@"iPhone10,1"])    return @"iPhone 8";
    if ([deviceModel isEqualToString:@"iPhone10,4"])    return @"iPhone 8";
    if ([deviceModel isEqualToString:@"iPhone10,2"])    return @"iPhone 8 Plus";
    if ([deviceModel isEqualToString:@"iPhone10,5"])    return @"iPhone 8 Plus";
    if ([deviceModel isEqualToString:@"iPhone10,3"])    return @"iPhone X";
    if ([deviceModel isEqualToString:@"iPhone10,6"])    return @"iPhone X";
    if ([deviceModel isEqualToString:@"iPhone11,2"])   return @"iPhone XS";
       if ([deviceModel isEqualToString:@"iPhone11,4"])   return @"iPhone XS Max";
       if ([deviceModel isEqualToString:@"iPhone11,6"])   return @"iPhone XS Max";
       if ([deviceModel isEqualToString:@"iPhone11,8"])   return @"iPhone XR";
       if ([deviceModel isEqualToString:@"iPhone12,1"])   return @"iPhone 11";
       if ([deviceModel isEqualToString:@"iPhone12,3"])   return @"iPhone 11 Pro";
       if ([deviceModel isEqualToString:@"iPhone12,5"])   return @"iPhone 11 Pro Max";
       
    return @"iPhone";
}

@end

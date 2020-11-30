//
//  DESTest.h
//  boxin
//
//  Created by guduzhonglao on 7/4/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DESTest : NSObject

- (NSString *)decryptUseDES:(NSString *)cipherText key:(NSString *)key;
-(NSString *) encryptUseDES2:(NSString *)plainText key:(NSString *)key;

@end

NS_ASSUME_NONNULL_END

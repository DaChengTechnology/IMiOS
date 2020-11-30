//
//  UserModel.h
//  boxin
//
//  Created by Sea on 2019/8/1.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UserModel : NSObject
@property(nonatomic,strong)NSString * userID;
@property(nonatomic,strong)NSString * userName;
@property(nonatomic,strong)NSString * userImg;
@property(nonatomic,strong)NSString * userIDCard;

@end

NS_ASSUME_NONNULL_END

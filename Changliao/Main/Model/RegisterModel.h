//
//  RegisterModel.h
//  boxin
//
//  Created by Sea on 2019/7/19.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RegisterDataModel : NSObject
@property (nonatomic,strong) NSString *password;
@property (nonatomic,strong) NSString *nickname;
@property (nonatomic,strong) NSString *token;
@property (nonatomic,strong) NSString *username;
@end
@interface RegisterModel : NSObject
@property (nonatomic,strong) RegisterDataModel *data;
@property (nonatomic,strong) NSString *code;
@property (nonatomic,strong) NSString *message;
@end

NS_ASSUME_NONNULL_END

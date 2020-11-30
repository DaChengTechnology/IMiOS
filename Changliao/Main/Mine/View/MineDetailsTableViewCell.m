//
//  MineDetailsTableViewCell.m
//  boxin
//
//  Created by Stn on 2019/8/5.
//  Copyright © 2019 guduzhonglao. All rights reserved.
//

#import "MineDetailsTableViewCell.h"
#import "Public.h"
@implementation MineDetailsTableViewCell
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIView * backView=[[UIView alloc]init];
        backView.backgroundColor=ColorWhite;
        [self.contentView addSubview:backView];
        [backView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.mas_offset(0);
            make.left.mas_offset(kSCRATIO(10));
            make.right.mas_offset(kSCRATIO(-10));
        }];
        ViewRadius(backView, kSCRATIO(5));
        self.titImg=[[UIImageView alloc]init];
        [backView addSubview:self.titImg];
        [self.titImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.contentView.mas_centerY);
            make.left.mas_offset(kSCRATIO(11));
            make.width.mas_offset(kSCRATIO(13));
            make.height.mas_offset(kSCRATIO(14));
        }];
        self.tiLab=[[UILabel alloc]init];
        self.tiLab.font=kFONT(15);
        self.tiLab.textColor=kColorFromRGBHex(0x222222);
        [backView addSubview:self.tiLab];
        [self.tiLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.titImg.mas_centerY);
            make.left.mas_equalTo(self.titImg.mas_right).offset(kSCRATIO(9));
            make.width.mas_equalTo(100);
        }];
        self.rightimg=[[UIImageView alloc]init];
        self.rightimg.image=[UIImage imageNamed:@"rightClick"];
        [backView addSubview:self.rightimg];
        [self.rightimg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.tiLab.mas_centerY);
            make.right.mas_offset(kSCRATIO(-14));
            make.width.mas_offset(kSCRATIO(8));
            make.height.mas_offset(kSCRATIO(13));
        }];
    }
    return self;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

//
//  SongTableViewCell.h
//  14-09-04-MusicPlayer
//
//  Created by 许启强 on 14-9-4.
//  Copyright (c) 2014年 nyqiqiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SongTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lab_name;
@property (weak, nonatomic) IBOutlet UILabel *lab_number;
@property (weak, nonatomic) IBOutlet UIButton *btn_status;
@property (weak, nonatomic) IBOutlet UIButton *btn_more;


@end

//
//  homeViewController.h
//  14-09-04-MusicPlayer
//
//  Created by 许启强 on 14-9-4.
//  Copyright (c) 2014年 nyqiqiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface homeViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,AVAudioPlayerDelegate,UIActionSheetDelegate>


@property  UILabel * lab_title;
@property  UILabel * lab_time;
@property  UIProgressView *process;
@property  UIButton *btn_pre;
@property  UIButton *btn_pause;
@property  UIButton *btn_next;
@property  UITableView *tab;
@property  UISlider *slider;
@property  UILabel *lab_lyc;

@property  NSIndexPath *previousindex;
@property  NSIndexPath *currentindex;
@property  AVAudioPlayer *player;

@property  NSMutableArray* musicname;
@property  NSTimer *mytimer;
@property  NSMutableArray *musictime;
@property  NSMutableArray *lyrics;
@property  NSMutableArray *t;
@end
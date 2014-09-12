//
//  lyricViewController.h
//  Music_Player
//
//  Created by 许启强 on 14-9-11.
//  Copyright (c) 2014年 nyqiqiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface lyricViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property UITableView *tab;

@property NSMutableArray *lyrics;
@property NSMutableArray *musictime;
@property NSString *musicname;
@property BOOL gestureback;
@property NSTimer *mytimer;

@property AVAudioPlayer *player;

@end

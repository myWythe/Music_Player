//
//  lyricViewController.m
//  Music_Player
//
//  Created by 许启强 on 14-9-11.
//  Copyright (c) 2014年 nyqiqiang. All rights reserved.
//

#import "lyricViewController.h"

@interface lyricViewController ()

@end

@implementation lyricViewController

@synthesize musictime = _musictime , lyrics = _lyrics,player = _player , musicname = _musicname;

static int lyricrow = 0;

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_lyrics count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellidentifier = @"cellidentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellidentifier];
    
    //if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellidentifier];
    //}
    
    cell.textLabel.text = [_lyrics objectAtIndex:indexPath.row];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    
    if (indexPath.row == lyricrow) {
        
        cell.textLabel.textColor = [UIColor colorWithRed:102/256.0 green:102/256.0 blue:153/256.0 alpha:1];

    } else {
        cell.textLabel.textColor = [UIColor colorWithRed:102/256.0 green:102/256.0 blue:153/256.0 alpha:0.5];
    }
    
    
    
    [cell setBackgroundColor:[UIColor cyanColor]];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    return cell;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)updatelyric
{
    //conver time
    int m1 = _player.currentTime / 60;
    int s1 = ((int) _player.currentTime) % 60;
    int m2 = _player.duration / 60;
    int s2 = ((int) _player.duration) % 60;
    
    //get the current time and total time
    //_lab_time.text = [NSString stringWithFormat:@"%.2d:%.2d/%.2d:%.2d",m1,s1,m2,s2];
    
    //[_slider setValue:currenttime animated:YES];
    
    //get the current time
    NSString *time = [NSString stringWithFormat:@"%.2d:%.2d",m1,s1];
    //compare to make sure if there lyric to display
    if ([_lyrics count]) {
        
        //check time to make sure whether it's time to diplay lyric
        
        for (int i =0 ; i < [_musictime count] ; i ++) {
            
            NSString *item = [_musictime objectAtIndex:i];
            //get the time that is going to match
            NSString *match = [item substringWithRange:NSMakeRange(0, 5)];
            //match the time
            if ([time isEqualToString:match]) {
                //_lab_lyc.text = [_lyrics objectAtIndex:[_musictime indexOfObject:item]];
                lyricrow = i;
                [_tab reloadData];
                NSIndexPath *indexpath = [NSIndexPath indexPathForRow:lyricrow inSection:0];
                [_tab selectRowAtIndexPath:indexpath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
                break;
            }
        }
    }
    
    _tab.separatorStyle = UITableViewCellSeparatorStyleNone;
    //_tab.backgroundView.alpha = 0.5;
    //else
       // _lab_lyc.text = @"暂无歌词";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //self.navigationController.navigationBar.backgroundColor = [UIColor blackColor];
    //self.navigationController.navigationBar.alpha = 1;
    self.view.backgroundColor = [UIColor colorWithRed:102/256.0 green:102/256.0 blue:153/256.0 alpha:1];
    
    UIImage *artImageInMp3;
    NSURL *fileUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:_musicname ofType:@"mp3"]];
    AVURLAsset *avURLAsset = [AVURLAsset URLAssetWithURL:fileUrl options:nil];
    for (NSString *format in [avURLAsset availableMetadataFormats]) {
        for (AVMetadataItem *metadataItem in [avURLAsset metadataForFormat:format]) {
            if ([metadataItem.commonKey isEqualToString:@"artwork"]) {
                artImageInMp3 = [UIImage imageWithData:[(NSDictionary*)metadataItem.value objectForKey:@"data"]];
                NSLog(@"artImageInMp3 %@",artImageInMp3);
                break;
            }
        }
    }
   // [_tab setBackgroundView:[[UIImageView alloc]initWithImage:artImageInMp3]];
    //_tab.backgroundView.contentMode = UIViewContentModeScaleAspectFit;
    NSTimer *mytimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updatelyric) userInfo:nil repeats:YES];
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillDisappear:(BOOL)animated
{
    _player     = nil;
    _musicname  = nil;
    _musictime  = nil;
    _lyrics     = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

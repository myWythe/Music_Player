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

@synthesize musictime = _musictime , lyrics = _lyrics,player = _player , musicname = _musicname , gestureback = _gestureback , mytimer = _mytimer;

static int lyricrow = 0;

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_lyrics count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellidentifier = @"cellidentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellidentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellidentifier];
    }
    
    cell.textLabel.text = [_lyrics objectAtIndex:indexPath.row];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    
    //if cell is the lyric that is showing,then give it a different color
    if (indexPath.row == lyricrow) {
        
        cell.textLabel.textColor = [UIColor redColor];

    } else {
        cell.textLabel.textColor = [UIColor colorWithRed:0 green:51/256.0 blue:102/256.0 alpha:1];
    }
    
    [cell setBackgroundColor:[UIColor colorWithRed:250/256.0 green:255/256.0 blue:255/256.0 alpha:1]];
    
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
    //convert time
    int m1 = _player.currentTime / 60;
    int s1 = ((int) _player.currentTime) % 60;

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
                lyricrow = i;
                [_tab reloadData];
                NSIndexPath *indexpath = [NSIndexPath indexPathForRow:lyricrow inSection:0];
                [_tab selectRowAtIndexPath:indexpath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
                break;
            }
        }
    }
    
    _tab.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _gestureback = NO;
    
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
    if ([_lyrics count]) {
        _tab = [[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStylePlain];
        _tab.delegate =self;
        _tab.dataSource = self;
        [self.view addSubview:_tab];
        
        _mytimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updatelyric) userInfo:nil repeats:YES];
        
        UISwipeGestureRecognizer *gesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(jump:)];
        gesture.direction = UISwipeGestureRecognizerDirectionDown;
        [_tab addGestureRecognizer:gesture];
        _tab.userInteractionEnabled =YES;
    }
    else
    {
        [self.view setBackgroundColor:[UIColor colorWithRed:250/256.0 green:255/256.0 blue:255/256.0 alpha:1]];
        [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"lyric.jpg"]]];
        
        UILabel *lab_lyric = [[UILabel alloc]initWithFrame:CGRectMake(80, 300, 160, 30)];
        lab_lyric.text = @"暂无歌词";
        
        [self.view addSubview:lab_lyric];
    }
}

//use gesture to go back
- (void)jump:(id)sender
{
    _gestureback = YES;
    [UIView animateWithDuration:1.0f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:self.navigationController.view cache:NO];
                     }
                     completion:^(BOOL finished) {
                         
                     }];
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
    if (!_gestureback) {
        [UIView animateWithDuration:0.8f
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.navigationController.view cache:NO];
                         }
                         completion:^(BOOL finished) {
                         }];
    }
    _player     = nil;
    _musicname  = nil;
    _musictime  = nil;
    _lyrics     = nil;
    lyricrow    = 0;
    _mytimer    = nil;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

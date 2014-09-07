//
//  homeViewController.m
//  14-09-04-MusicPlayer
//
//  Created by 许启强 on 14-9-4.
//  Copyright (c) 2014年 nyqiqiang. All rights reserved.
//

#import "homeViewController.h"
#import "SongTableViewCell.h"
//#import "LZXLrcItem.h"
@interface homeViewController ()

@end

@implementation homeViewController

@synthesize lab_title = _lab_title , slider = _slider , lab_time = _lab_time , lab_lyc = _lab_lyc , btn_pre = _btn_pre , btn_pause = _btn_pause , btn_next = _btn_next;
@synthesize musicname = _musicname , previousindex = _previousindex, currentindex = _currentindex , mytimer = _mytimer , musictime = _musictime , lyrics = _lyrics , t = _t;;

//return the song numbre
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_musicname count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellidentifier = @"cellidentifier";
    
    SongTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellidentifier];
    
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"SongTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    cell.lab_number.text = [NSString stringWithFormat:@"%d",indexPath.row + 1];
    [cell.lab_number setFont:[UIFont fontWithName:@"Arial" size:10]];
    
    //get song name ftom musicname array
    cell.lab_name.text = [_musicname objectAtIndex:indexPath.row];
    [cell.lab_name setTextColor:[UIColor colorWithRed:0 green:51/256.0 blue:102/256.0 alpha:1]];
    
    //add action for button
    [cell.btn_status addTarget:self action:@selector(play_or_pause_Onclick:) forControlEvents:UIControlEventTouchUpInside];
    cell.btn_status.hidden = YES;
    
    //button more
    cell.btn_more.tag = indexPath.row;
    [cell.btn_more addTarget:self action:@selector(btn_more_Onlick:) forControlEvents:UIControlEventTouchUpInside];
    
    //set cell property
    cell.selectionStyle = UITableViewCellAccessoryNone;
    [cell setBackgroundColor:[UIColor colorWithRed:250/256.0 green:255/256.0 blue:255/256.0 alpha:1]];
    
    return cell;
}

//slelect action,once select a row,play the song
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //set the song title
    _lab_title.text = [_musicname objectAtIndex:indexPath.row];
    
    //once choose a song,parse the lyric set a timer,and it will call a theord every 1 second
    [self parselyric];
    _mytimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(display) userInfo:nil repeats:YES];
    
    //get the resouce path for specific song,and the aloc the player use this path
    NSURL *path = [[NSURL alloc]initFileURLWithPath:[[NSBundle mainBundle]pathForResource:[_musicname objectAtIndex:indexPath.row] ofType:@"mp3"]];
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:path error:nil];
    _player.delegate = self;
    
    //play the song
    [_player play];
    
    //show the pause image for this row
    SongTableViewCell *currentcell =(SongTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    [currentcell.btn_status setBackgroundImage:[UIImage imageNamed:@"pause.tiff"] forState:UIControlStateNormal];
    currentcell.btn_status.hidden = NO;
    
    //set then button in center of the view to pause
    [_btn_pause setBackgroundImage:[UIImage imageNamed:@"pause.tiff"] forState:UIControlStateNormal];
    
    //hide the pause button in last song's cell
    ((SongTableViewCell *)[tableView cellForRowAtIndexPath:_previousindex]).btn_status.hidden = YES;
    
    //set this indexpath to current indexpath,and set the current to previous indexpath
    _currentindex = indexPath;
    _previousindex = _currentindex;
    
    //新加的代码，实现标题滚动，没有提交
    [UIView animateWithDuration:3.0
                          delay:0
                        options:UIViewAnimationOptionRepeat //动画重复的主开关
     |UIViewAnimationOptionAutoreverse //动画重复自动反向，需要和上面这个一起用
     |UIViewAnimationOptionCurveLinear //动画的时间曲线，滚动字幕线性比较合理
                     animations:^{
                         if (_lab_title.frame.origin.x == 0) {
                         _lab_title.transform =
                             CGAffineTransformMakeTranslation(-50, 0);
                         }
                         if (_lab_title.frame.origin.x == -50) {
                             _lab_title.transform =
                             CGAffineTransformMakeTranslation(50, 0);
                         }
                     }
                     completion:^(BOOL finished) {
                         
                     }
     ];
    
}

//when a song has complete playing,change to next song atomly
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    //get the index in musicname using the now playing song name
    int index = [_musicname indexOfObject:_lab_title.text];
    
    //only if now playing song isn't the last one then we can jump to next song
    if (index < [_musicname count]-1) {
        
        //hide the pause button in now playing song
        SongTableViewCell *currentcell = (SongTableViewCell *)[_tab cellForRowAtIndexPath:_currentindex];
        currentcell.btn_status.hidden = YES;
        
        //get the song name that is going to play
        NSString *name = [_musicname objectAtIndex:index + 1];
        
        //update the playing song name
        _lab_title.text = name;
        
        //parse the lyric
        [self parselyric];
        
        //play the song
        NSURL *path = [[NSURL alloc]initFileURLWithPath:[[NSBundle mainBundle]pathForResource:name ofType:@"mp3"]];
        _player = [[AVAudioPlayer alloc] initWithContentsOfURL:path error:nil];
        _player.delegate = self;
        [_player play];
        
        //update the current indexpath and show the pause button with index
        _currentindex = [NSIndexPath indexPathForRow:index + 1 inSection:0];
        [((SongTableViewCell *)[_tab cellForRowAtIndexPath:_currentindex]).btn_status setBackgroundImage:[UIImage imageNamed:@"pause.tiff"] forState:UIControlStateNormal];
        ((SongTableViewCell *)[_tab cellForRowAtIndexPath:_currentindex]).btn_status.hidden = NO;
        
        //set the cuurent indexpath to previous
        _previousindex = _currentindex;
    }
    else
        [_mytimer setFireDate:[NSDate distantFuture]];
}

static int n = 0;

//click at index
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //if choose delete
    if (buttonIndex == 0) {
        NSString *name = [_musicname objectAtIndex:n];
        NSString *path = [NSString stringWithFormat:@"%@/%@.mp3",[[NSBundle mainBundle]resourcePath],name];
        [[NSFileManager defaultManager]removeItemAtPath:path error:nil];
        [_musicname removeObjectAtIndex:n];
        [_tab reloadData];
    }
}

//action for button more
-(void)btn_more_Onlick:(UIButton *)btn
{
    n = btn.tag;
    UIActionSheet *action = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"cancel" destructiveButtonTitle:@"delete" otherButtonTitles: nil];
    [action showInView:self.view];
}

//action for button previous
-(void)previous_Onclick
{
    if ([_player isPlaying]) {
        //get the index in musicname using the now playing song name
        int index = [_musicname indexOfObject:_lab_title.text];
        
        //if the index is bigger than 0,then go to the previous song
        if (index>0) {
            
            //hide the pause button in now playing song
            SongTableViewCell *currentcell = (SongTableViewCell *)[_tab cellForRowAtIndexPath:_currentindex];
            currentcell.btn_status.hidden = YES;
            
            //get the song name and path that is going to play
            NSString *name = [_musicname objectAtIndex:index - 1];
            
            //update the playing song name
            _lab_title.text = name;         NSURL *path = [[NSURL alloc]initFileURLWithPath:[[NSBundle mainBundle]pathForResource:name ofType:@"mp3"]];
            
            //parse the lyric
            [self parselyric];
            
            //play the song
            _player = [[AVAudioPlayer alloc] initWithContentsOfURL:path error:nil];
            _player.delegate = self;
            [_player play];
            
            //update the current indexpath and show the pause button with index
            _currentindex = [NSIndexPath indexPathForRow:index - 1 inSection:0];
            [((SongTableViewCell *)[_tab cellForRowAtIndexPath:_currentindex]).btn_status setBackgroundImage:[UIImage imageNamed:@"pause.tiff"] forState:UIControlStateNormal];
            ((SongTableViewCell *)[_tab cellForRowAtIndexPath:_currentindex]).btn_status.hidden = NO;
            
            //set the cuurent indexpath to previous
            _previousindex = _currentindex;
        }
    }
}

//action for button next
-(void)next_Onclick
{
    if ([_player isPlaying]) {
        
        //get the index in musicname using the now playing song name
        int index = [_musicname indexOfObject:_lab_title.text];
        
        //only if now playing song isn't the last one then we can jump to next song
        if (index < [_musicname count]-1) {
            
            //hide the pause button in now playing song
            SongTableViewCell *currentcell = (SongTableViewCell *)[_tab cellForRowAtIndexPath:_currentindex];
            currentcell.btn_status.hidden = YES;
            
            //get the song name and path that is going to play
            NSString *name = [_musicname objectAtIndex:index + 1];
            
            //update the playing song name
            _lab_title.text = name;
            
            //parse the lyric
            [self parselyric];
            
            //play the song
            NSURL *path = [[NSURL alloc]initFileURLWithPath:[[NSBundle mainBundle]pathForResource:name ofType:@"mp3"]];
            _player = [[AVAudioPlayer alloc] initWithContentsOfURL:path error:nil];
            _player.delegate = self;
            [_player play];
            
            //update the current indexpath and show the pause button with index
            _currentindex = [NSIndexPath indexPathForRow:index + 1 inSection:0];
            [((SongTableViewCell *)[_tab cellForRowAtIndexPath:_currentindex]).btn_status setBackgroundImage:[UIImage imageNamed:@"pause.tiff"] forState:UIControlStateNormal];
            ((SongTableViewCell *)[_tab cellForRowAtIndexPath:_currentindex]).btn_status.hidden = NO;
            
            //set the cuurent indexpath to previous
            _previousindex = _currentindex;
        }
    }
}

//action for button play or pause
-(void)play_or_pause_Onclick:(UIButton *)btn
{
    if ([[btn currentBackgroundImage] isEqual:[UIImage imageNamed:@"play.tiff"]]) {
        
        //change the button in cell to pause
        [((SongTableViewCell *)[_tab cellForRowAtIndexPath:_currentindex]).btn_status setBackgroundImage:[UIImage imageNamed:@"pause.tiff"] forState:UIControlStateNormal];
        //change the button in view to pause
        [_btn_pause setBackgroundImage:[UIImage imageNamed:@"pause.tiff"] forState:UIControlStateNormal];
        [_player play];
        
        //start the timer
        [_mytimer setFireDate:[NSDate distantPast]];
    } else {
        
        //change the button in cell to play
        [((SongTableViewCell *)[_tab cellForRowAtIndexPath:_currentindex]).btn_status setBackgroundImage:[UIImage imageNamed:@"play.tiff"] forState:UIControlStateNormal];
        //change the button in view to play
        [_btn_pause setBackgroundImage:[UIImage imageNamed:@"play.tiff"] forState:UIControlStateNormal];
        [_player pause];
        
        //stop the timer
        [_mytimer setFireDate:[NSDate distantFuture]];
    }
    
}



//when touch up,updata the music time and start the timer
-(void)looseslider
{
    if ([_player isPlaying]) {
        [_mytimer setFireDate:[NSDate distantPast]];
        _player.currentTime = _slider.value * _player.duration;
    }
}

//control the music time by draging the slider
-(void)dragslider
{
    int count = 0;
    //stop the timer when stop draging
    [_mytimer setFireDate:[NSDate distantFuture]];
    
    float time = _slider.value * _player.duration;
    
    //updata the lyric when draging
    for (int i = 0; i < [_t count]; i++) {
        if (time < [[_t objectAtIndex:i] integerValue]) {
            if (i == 0) {
                count = 0;
            }
            else
            {
                count = i - 1;
                _lab_lyc.text = [_lyrics objectAtIndex:count - 1];
            }
            break;
        }
    }
    
    //convert time
    int m1 = time / 60;
    int s1 = ((int)time) % 60;
    int m2 = _player.duration / 60;
    int s2 = ((int) _player.duration) % 60;
    
    //show the current time and total time
    _lab_time.text = [NSString stringWithFormat:@"%.2d:%.2d/%.2d:%.2d",m1,s1,m2,s2];
    
}

-(void)parselyric
{
    NSString *path = [[NSBundle mainBundle]pathForResource:_lab_title.text ofType:@"lrc"];
    
    //if lyric file exits
    if ([path length]) {
        
        //get the lyric string
        NSString *lyc = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        
        //init
        _musictime = [[NSMutableArray alloc]init];
        _lyrics = [[NSMutableArray alloc]init];
        _t = [[NSMutableArray alloc]init];
        
        NSArray *arr = [lyc componentsSeparatedByString:@"\n"];
        
        for (NSString *item in arr) {
            
            //if item is not empty
            if ([item length]) {
                
                NSRange startrange = [item rangeOfString:@"["];
                NSLog(@"%d%d",startrange.length,startrange.location);
                NSRange stoprange = [item rangeOfString:@"]"];
                
                NSString *content = [item substringWithRange:NSMakeRange(startrange.location+1, stoprange.location-startrange.location-1)];
                
                NSLog(@"%d",[item length]);
                
                //the music time format is mm.ss.xx such as 00:03.84
                if ([content length] == 8) {
                    NSString *minute = [content substringWithRange:NSMakeRange(0, 2)];
                    NSString *second = [content substringWithRange:NSMakeRange(3, 2)];
                    NSString *mm = [content substringWithRange:NSMakeRange(6, 2)];
                    
                    NSString *time = [NSString stringWithFormat:@"%@:%@.%@",minute,second,mm];
                    NSNumber *total =[NSNumber numberWithInteger:[minute integerValue] * 60 + [second integerValue]];
                    [_t addObject:total];
                    
                    NSString *lyric = [item substringFromIndex:10];
                    
                    [_musictime addObject:time];
                    [_lyrics addObject:lyric];
                }
            }
        }
    }
    else
        _lyrics = nil;
}

//display time and lyric
-(void)display
{
    //get the percent that the song has been played
    float currenttime = _player.currentTime / _player.duration;
    
    //conver time
    int m1 = _player.currentTime / 60;
    int s1 = ((int) _player.currentTime) % 60;
    int m2 = _player.duration / 60;
    int s2 = ((int) _player.duration) % 60;
    
    //get the current time and total time
    _lab_time.text = [NSString stringWithFormat:@"%.2d:%.2d/%.2d:%.2d",m1,s1,m2,s2];
    
    [_slider setValue:currenttime animated:YES];
    
    //get the current time
    NSString *time = [NSString stringWithFormat:@"%.2d:%.2d",m1,s1];
    
    //compare to make sure if there lyric to display
    if ([_lyrics count]) {
        
        //check time to make sure whether it's time to diplay lyric
        
        for (NSString *item in _musictime) {
            
            //get the time that is going to match
            NSString *match = [item substringWithRange:NSMakeRange(0, 5)];
            //match the time
            if ([time isEqualToString:match]) {
                _lab_lyc.text = [_lyrics objectAtIndex:[_musictime indexOfObject:item]];
                break;
            }
        }
    }
    else
        _lab_lyc.text = @"暂无歌词";
}

//scan the project and get the music name
-(void)getMusicName
{
    _musicname = [[NSMutableArray alloc]init];
    
    //get the paths for mp3 file
    NSArray *paths = [NSBundle pathsForResourcesOfType:@"mp3" inDirectory:[[NSBundle mainBundle]resourcePath]];
    
    for (NSString *item in paths) {
        
        //path resource directiory lengh
        int length = [[[NSBundle mainBundle]resourcePath]length];
        
        //the complete path -path resource directiory lengh(length) - .mp3(4) = music name
        NSString *name = [item substringWithRange:NSMakeRange(length + 1,[item length] - length - 5)];
        //add the name ro music name
        [_musicname addObject:name];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    //尝试读取mp3文件中的专辑图片
    NSURL *fileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:@"安和桥" ofType:@"mp3"]];
    AudioFileTypeID fileTypeHint = kAudioFileMP3Type;
    
    AudioFileID fileID = nil;
    OSStatus err = noErr;
    
    err = AudioFileOpenURL((__bridge CFURLRef)fileURL, kAudioFileReadPermission, 0, &fileID);
    
    UInt32 id3DataSize = 0;
    err = AudioFileGetPropertyInfo(fileID, kAudioFilePropertyID3Tag, &id3DataSize, NULL);
    NSDictionary *piDict = nil;
    UInt32 piDataSize = sizeof(piDict);
    err = AudioFileGetProperty(fileID, kAudioFilePropertyInfoDictionary, &piDataSize, &piDict);
    CFDataRef AlbumPic = nil;
    UInt32 picDataSize = sizeof(picDataSize);
    err = AudioFileGetProperty(fileID, kAudioFilePropertyAlbumArtwork, &picDataSize, &AlbumPic);
    NSError *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:err userInfo:nil];
    NSLog(@"Error: %@", [error description]);
    NSData *imgdata = (__bridge NSData *)AlbumPic;
    
    [super viewDidLoad];
    
    //scan and get the song name
    [self getMusicName];
    
    //create imgview to contain title , slider buttons etc..
    UIImageView *img_container = [[UIImageView alloc]initWithFrame:CGRectMake(0, 60, 320, 250)];
    //img_container.image = [UIImage imageWithData:imgdata];
    img_container.image = [UIImage imageNamed:@"background.jpeg"];
    img_container.userInteractionEnabled = YES;
    
    //create and set title label
    _lab_title = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, 320, 20)];
    //[_lab_title setBackgroundColor:[UIColor redColor]];
    _lab_title.textAlignment = NSTextAlignmentCenter;
    [_lab_title setTextColor:[UIColor colorWithRed:102/256.0 green:102/256.0 blue:153/256.0 alpha:1]];
    
    //create slider to show the music process
    _slider = [[UISlider alloc]initWithFrame:CGRectMake(60, 70, 200, 5)];
    [_slider setThumbImage:[UIImage imageNamed:@"5mmcircle.png"] forState:UIControlStateNormal];
    [_slider addTarget:self action:@selector(looseslider) forControlEvents:UIControlEventTouchUpInside];
    [_slider addTarget:self action:@selector(dragslider) forControlEvents:UIControlEventValueChanged];
    
    //create and set time label
    _lab_time = [[UILabel alloc]initWithFrame:CGRectMake(200, 80, 50, 20)];
    _lab_time.adjustsFontSizeToFitWidth = YES;
    
    //create lyric label
    _lab_lyc = [[UILabel alloc]initWithFrame:CGRectMake(0, 100, 320, 30)];
    [_lab_lyc setTextColor:[UIColor colorWithRed:102/256.0 green:102/256.0 blue:153/256.0 alpha:1]];
    _lab_lyc.textAlignment = NSTextAlignmentCenter;
    _lab_lyc.adjustsFontSizeToFitWidth = YES;
    
    //prevoius song button
    _btn_pre = [UIButton buttonWithType:UIButtonTypeSystem];
    [_btn_pre addTarget:self action:@selector(previous_Onclick) forControlEvents:UIControlEventTouchUpInside];
    [_btn_pre setTitle:@"previous" forState:UIControlStateNormal];
    _btn_pre.frame = CGRectMake(20, 140, 80, 30);
    
    //pause or play button
    _btn_pause = [UIButton buttonWithType:UIButtonTypeSystem];
    [_btn_pause addTarget:self action:@selector(play_or_pause_Onclick:) forControlEvents:UIControlEventTouchUpInside];
    _btn_pause.frame = CGRectMake(150, 140, 30, 30);
    
    //next song button
    _btn_next = [UIButton buttonWithType:UIButtonTypeSystem];
    [_btn_next setTitle:@"next" forState:UIControlStateNormal];
    [_btn_next addTarget:self action:@selector(next_Onclick) forControlEvents:UIControlEventTouchUpInside];
    _btn_next.frame = CGRectMake(230, 140, 80, 30);
    
    //create table view
    _tab = [[UITableView alloc]initWithFrame:CGRectMake(0, 250, 320, 300) style:UITableViewStylePlain];
    _tab.delegate = self;
    _tab.dataSource = self;
    
    
    [img_container addSubview:_lab_title];
    [img_container addSubview:_lab_time];
    [img_container addSubview:_slider];
    [img_container addSubview:_lab_lyc];
    [img_container addSubview:_btn_pre];
    [img_container addSubview:_btn_pause];
    [img_container addSubview:_btn_next];
    
    [self.view addSubview:img_container];
    
    [self.view addSubview:_tab];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

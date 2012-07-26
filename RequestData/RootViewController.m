//
//  RootViewController.m
//  funMatch_iPad
//
//  Created by Dean on 12-7-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"
#import "CryptionUseSysLib.h"
#import "ZipArchive.h"

@implementation RootViewController

@synthesize netWorkButton = _netWorkButton;
@synthesize cryptButton = _cryptButton;
@synthesize unzipButton = _unzipButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/
- (void)viewDidLoad{
  UIView *contentView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];//新建视图 
  
  contentView.backgroundColor = [UIColor whiteColor]; 
  
  self.view = contentView; 
  
  
  //create netwrok button
  self.netWorkButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  self.netWorkButton.frame = CGRectMake(110.0f, 200.0f, 200.0f, 107.0f);
  [self.netWorkButton setTitle:@"test network" forState:UIControlStateNormal];
  [self.netWorkButton addTarget:self
                  action:@selector(netButtonIsPressed:) 
        forControlEvents:UIControlEventTouchDown];
  [self.view addSubview:self.netWorkButton];
  
  
  //create crypt button;
  self.cryptButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  self.cryptButton.frame = CGRectMake(110.0f, 407.0f, 200.0f, 107.0f);
  [self.cryptButton setTitle:@"test cryption" forState:UIControlStateNormal];
  [self.cryptButton addTarget:self
                         action:@selector(cryptButtonIsPressed:) 
               forControlEvents:UIControlEventTouchDown];
  [self.view addSubview:self.cryptButton];
  
  //create crypt button;
  self.unzipButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  self.unzipButton.frame = CGRectMake(110.0f, 607.0f, 200.0f, 107.0f);
  [self.unzipButton setTitle:@"test unzip" forState:UIControlStateNormal];
  [self.unzipButton addTarget:self
                       action:@selector(unzipButtonIsPressed:) 
             forControlEvents:UIControlEventTouchDown];
  [self.view addSubview:self.unzipButton];

  [contentView release]; 
  
  
  
}

- (void)unzipButtonIsPressed:(id)sender{
  //zip
  /*
  ZipArchive* zip = [[ZipArchive alloc] init];
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *documentpath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
  NSString* l_zipfile = [documentpath stringByAppendingString:@"/test.zip"] ;
  
  NSString* image1 = [documentpath stringByAppendingString:@"/image1.jpg"] ;
  NSString* image2 = [documentpath stringByAppendingString:@"/image2.jpg"] ;       
  
  BOOL ret = [zip CreateZipFile2:l_zipfile];
  ret = [zip addFileToZip:image1 newname:@"image1.jpg"];
  ret = [zip addFileToZip:image2 newname:@"image2.jpg"];
  if( ![zip CloseZipFile2] )
  {
    l_zipfile = @"";
  }
  [zip release];*/
  
  
  
  //unzip.,..
  ZipArchive* zip = [[ZipArchive alloc] init];
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *documentpath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
  BOOL ret;
  NSLog(@"%@",documentpath);
  NSString* l_zipfile = [documentpath stringByAppendingString:@"/test.zip"] ;
  NSString* unzipto = [documentpath stringByAppendingString:@"/test.pdf"] ;
  if( [zip UnzipOpenFile:l_zipfile Password:@"123456"] )
  {
    ret = [zip UnzipFileTo:unzipto overWrite:YES];
    [zip UnzipCloseFile];
  }
  [zip release];
  if (ret == YES) {
    NSLog(@"unzip successfull");
  }
  else{
    NSLog(@"unzip failed!");
  }

}

- (void)cryptButtonIsPressed:(id)sender{
  
  NSString *str = [NSString stringWithFormat:@"hello world,my name is weiy... i'm a hortor software worker... good good study and day day up."];  
  NSString *key = [NSString stringWithFormat:@"my password"];
  NSData *dKey = [NSData dataWithBytes:[key UTF8String]
                                length:[key length]];
  NSData *dStr = [NSData dataWithBytes:[str UTF8String] 
                                length:[str length]];
  
  NSLog(@"before encrypt:%@",str);
  
  //test aes encryption;
  NSData* strAfterEncrypt = [CryptionUseSysLib doCipherUseAesMethod:dStr
                                key:dKey
                            context:kCCEncrypt];
  NSLog(@"after Aes encrypt:%@",strAfterEncrypt);
  
  NSData* strAfterDecrypt = [CryptionUseSysLib doCipherUseAesMethod:strAfterEncrypt
                                                                key:dKey
                                                            context:kCCDecrypt];
  NSLog(@"after Aes decrypt:%@",[[[NSString alloc] initWithData:strAfterDecrypt encoding:NSUTF8StringEncoding] autorelease]);
  
  //test des encryption;
  NSLog(@"before encrypt:%@",dStr);
  strAfterEncrypt = [CryptionUseSysLib doCipherUseDesMethod:dStr
                                                        key:dKey
                                                    context:kCCEncrypt];
  NSLog(@"after des encrypt:%@",strAfterEncrypt);
  
  strAfterDecrypt = [CryptionUseSysLib doCipherUseDesMethod:strAfterEncrypt
                                                        key:dKey
                                                    context:kCCDecrypt];
  NSLog(@"after des decrypt:%@\n",[[[NSString alloc] initWithData:strAfterDecrypt encoding:NSUTF8StringEncoding] autorelease]);
  
  //test 3des encryption;
  NSLog(@"before encrypt:%@",dStr);
  strAfterEncrypt = [CryptionUseSysLib doCipherUse3DesMethod:dStr
                                                        key:dKey
                                                    context:kCCEncrypt];
  NSLog(@"after 3des encrypt:%@",strAfterEncrypt);
  
  strAfterDecrypt = [CryptionUseSysLib doCipherUse3DesMethod:strAfterEncrypt
                                                        key:dKey
                                                    context:kCCDecrypt];
  NSLog(@"after 3des decrypt:%@\n",[[[NSString alloc] initWithData:strAfterDecrypt encoding:NSUTF8StringEncoding] autorelease]);
  
  //test cast encryption;
  NSLog(@"before encrypt:%@",dStr);
  strAfterEncrypt = [CryptionUseSysLib doCipherUseCastMethod:dStr
                                                         key:dKey
                                                     context:kCCEncrypt];
  NSLog(@"after Cast encrypt:%@",strAfterEncrypt);
  
  strAfterDecrypt = [CryptionUseSysLib doCipherUseCastMethod:strAfterEncrypt
                                                         key:dKey
                                                     context:kCCDecrypt];
  NSLog(@"after Cast decrypt:%@\n",[[[NSString alloc] initWithData:strAfterDecrypt encoding:NSUTF8StringEncoding] autorelease]);
  
}


- (void)queryError{
  NSLog(@"query error!");
}

- (void)netButtonIsPressed:(id)sender{

  
}


   
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end

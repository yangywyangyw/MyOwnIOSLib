/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "UIImageView+WebCache.h"
#import "SDImageCache.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIImageView (WebCache)


-(BOOL)jugeURLhasCache:(NSString *)urlstring
{
    NSURL  *url = [NSURL URLWithString:urlstring];
    SDImageCache *cache =[SDImageCache sharedImageCache];
   // DLog(@"count : %d",[cache.memCache allKeys].count);
    UIImage *image = [cache imageFromKey:[url absoluteString]];//判断key得到图片

    
    if(image)
    {
        self.image=image;
        return YES;
    }
    else
    {
        return NO;
    }
}



- (void)setImageWithURL:(NSString *)url withBackground:(BOOL)station
{
     [self setImageWithURL:url placeholderImage:nil withBackground:station];

}

- (void)setImageWithURL:(NSString *)url placeholderImage:(UIImage *)placeholder  withBackground:(BOOL)station
{
    if(![self jugeURLhasCache:url])
    {
        for(UIView *view in self.subviews)
        {
            if([view isKindOfClass:[UIActivityIndicatorView class]])
            {
                [self setImageWithURL:url placeholderImage:placeholder options:0];
                return;
            }
        }
        if(url!=nil) {
            
            if(station){
                UIView *backView = [[UIView alloc] initWithFrame:CGRectMake((self.bounds.size.width - 50)/2, (self.bounds.size.height - 40)/2, 50, 40)];
                backView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8f];
                backView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
                backView.layer.cornerRadius = 10.f;
                backView.tag = 998;
                [self addSubview:backView];
                
                UIActivityIndicatorView *activityIndicatorView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
                
                activityIndicatorView.frame = CGRectMake((self.bounds.size.width - activityIndicatorView.bounds.size.width) /2, (self.bounds.size.height - activityIndicatorView.bounds.size.height) /2, activityIndicatorView.bounds.size.width,activityIndicatorView.bounds.size.height);
                
                activityIndicatorView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
                
                activityIndicatorView.tag =999;
                [activityIndicatorView startAnimating];
                [self addSubview:activityIndicatorView];
                [backView release];

            }
            else {
                UIActivityIndicatorView *activityIndicatorView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
                
                activityIndicatorView.frame = CGRectMake((self.bounds.size.width - activityIndicatorView.bounds.size.width) /2, (self.bounds.size.height - activityIndicatorView.bounds.size.height) /2, activityIndicatorView.bounds.size.width,activityIndicatorView.bounds.size.height);
                
                activityIndicatorView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
                
                activityIndicatorView.tag =999;
                [activityIndicatorView startAnimating];
                [self addSubview:activityIndicatorView];

            }
            
        }
        [self setImageWithURL:url placeholderImage:placeholder options:0];
    }
    
}


- (void)setImageWithURL:(NSString *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options
{
    SDWebImageManager *manager = [SDWebImageManager sharedManager];

    // Remove in progress downloader from queue
    [manager cancelForDelegate:self];

    self.image = placeholder;

    if (url)
    {
//        NSLog(@"图片链接：%@",url);
        [manager downloadWithURL:[NSURL URLWithString:url] delegate:self options:options];
    }
}

- (void)cancelCurrentImageLoad
{
    UIView *backView = [self viewWithTag:998];
    if(backView){
        [backView removeFromSuperview];
    }
    
    UIView *view=[self viewWithTag:999];
    [view removeFromSuperview];
    [[SDWebImageManager sharedManager] cancelForDelegate:self];
}

- (void)webImageManager:(SDWebImageManager *)imageManager didFinishWithImage:(UIImage *)image withURL:(NSURL *)URL
{
    DLog(@"imagePath: %@",[URL absoluteString]);
    self.image = image;
    
    UIView *backView = [self viewWithTag:998];
    if(backView){
        [backView removeFromSuperview];
    }
    
    
    UIView *view=[self viewWithTag:999];
    [view removeFromSuperview];
}

-(void)webImageManager:(SDWebImageManager *)imageManager didFailWithError:(NSError *)error withURL:(NSURL *)URL
{
    UIView *backView = [self viewWithTag:998];
    if(backView){
        [backView removeFromSuperview];
    }
    
    UIView *view=[self viewWithTag:999];
    [view removeFromSuperview];

}

@end

/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "SDWebImageCompat.h"

@class SDWebImageDownloader;

@protocol SDWebImageDownloaderDelegate <NSObject>

@optional

- (void)imageDownloaderDidFinish:(SDWebImageDownloader *)downloader withURL:(NSURL *)URL ;
- (void)imageDownloader:(SDWebImageDownloader *)downloader didFinishWithImage:(UIImage *)image withURL:(NSURL *)URL;
- (void)imageDownloader:(SDWebImageDownloader *)downloader didFailWithError:(NSError *)error withURL:(NSURL *)URL;

@end

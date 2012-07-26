/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

@class SDWebImageManager;
@class UIImage;

@protocol SDWebImageManagerDelegate <NSObject>

@optional

- (void)webImageManager:(SDWebImageManager *)imageManager didFinishWithImage:(UIImage *)image withURL:(NSURL *)URL;
- (void)webImageManager:(SDWebImageManager *)imageManager didFailWithError:(NSError *)error withURL:(NSURL *)URL;

@end

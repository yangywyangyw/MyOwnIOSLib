/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "SDWebImageManager.h"
#import "SDImageCache.h"
#import "SDWebImageDownloader.h"

static SDWebImageManager *instance;

@implementation SDWebImageManager

- (id)init
{
    if ((self = [super init]))
    {
        downloadDelegates = [[NSMutableArray alloc] init];
        downloaders = [[NSMutableArray alloc] init];
        cacheDelegates = [[NSMutableArray alloc] init];
        cacheURLs = [[NSMutableArray alloc] init];
        downloaderForURL = [[NSMutableDictionary alloc] init];
        failedURLs = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [downloadDelegates release], downloadDelegates = nil;
    [downloaders release], downloaders = nil;
    [cacheDelegates release], cacheDelegates = nil;
    [cacheURLs release], cacheURLs = nil;
    [downloaderForURL release], downloaderForURL = nil;
    [failedURLs release], failedURLs = nil;
    [super dealloc];
}


+ (id)sharedManager
{
    if (instance == nil)
    {
        instance = [[SDWebImageManager alloc] init];
    }

    return instance;
}

/**
 * @deprecated
 */
- (UIImage *)imageWithURL:(NSURL *)url
{
    return [[SDImageCache sharedImageCache] imageFromKey:[url absoluteString]];
}

/**
 * @deprecated
 */
- (void)downloadWithURL:(NSURL *)url delegate:(id<SDWebImageManagerDelegate>)delegate retryFailed:(BOOL)retryFailed
{
    [self downloadWithURL:url delegate:delegate options:(retryFailed ? SDWebImageRetryFailed : 0)];
}

/**
 * @deprecated
 */
- (void)downloadWithURL:(NSURL *)url delegate:(id<SDWebImageManagerDelegate>)delegate retryFailed:(BOOL)retryFailed lowPriority:(BOOL)lowPriority
{
    SDWebImageOptions options = 0;
    if (retryFailed) options |= SDWebImageRetryFailed;
    if (lowPriority) options |= SDWebImageLowPriority;
    [self downloadWithURL:url delegate:delegate options:options];
}

- (void)downloadWithURL:(NSURL *)url delegate:(id<SDWebImageManagerDelegate>)delegate
{
    [self downloadWithURL:url delegate:delegate options:0];
}

- (void)downloadWithURL:(NSURL *)url delegate:(id<SDWebImageManagerDelegate>)delegate options:(SDWebImageOptions)options
{
    // Very common mistake is to send the URL using NSString object instead of NSURL. For some strange reason, XCode won't
    // throw any warning for this type mismatch. Here we failsafe this error by allowing URLs to be passed as NSString.
    if ([url isKindOfClass:NSString.class])
    {
        url = [NSURL URLWithString:(NSString *)url];
    }

    if (!url || !delegate || (!(options & SDWebImageRetryFailed) && [failedURLs containsObject:url]))
    {
        return;
    }

    // Check the on-disk cache async so we don't block the main thread
    [cacheDelegates addObject:delegate];
    [cacheURLs addObject:url];
    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:delegate, @"delegate", url, @"url", [NSNumber numberWithInt:options], @"options", nil]; //把委托体，url和options信息传过去
    [[SDImageCache sharedImageCache] queryDiskCacheForKey:[url absoluteString] delegate:self userInfo:info];
}

- (void)cancelForDelegate:(id<SDWebImageManagerDelegate>)delegate
{
    NSUInteger idx;
    while ((idx = [cacheDelegates indexOfObjectIdenticalTo:delegate]) != NSNotFound) //查询缓存委托数组和缓存链接数组里面有没有该对象，有就移除
    {
        [cacheDelegates removeObjectAtIndex:idx];
        [cacheURLs removeObjectAtIndex:idx];
    }

    while ((idx = [downloadDelegates indexOfObjectIdenticalTo:delegate]) != NSNotFound) //查询正在下载的数组和下载委托数组里面有没有该对象，有就移除
    {
        SDWebImageDownloader *downloader = [[downloaders objectAtIndex:idx] retain];

        [downloadDelegates removeObjectAtIndex:idx];
        [downloaders removeObjectAtIndex:idx];

        if (![downloaders containsObject:downloader])         //如果该委托不在委托数组里面，取消该委托
        {
            // No more delegate are waiting for this download, cancel it
            [downloader cancel];
            [downloaderForURL removeObjectForKey:downloader.url];
        }

        [downloader release];
    }
}

#pragma mark SDImageCacheDelegate

- (NSUInteger)indexOfDelegate:(id<SDWebImageManagerDelegate>)delegate waitingForURL:(NSURL *)url
{
    // Do a linear search, simple (even if inefficient)
    NSUInteger idx;
    for (idx = 0; idx < [cacheDelegates count]; idx++)
    {
        if ([cacheDelegates objectAtIndex:idx] == delegate && [[cacheURLs objectAtIndex:idx] isEqual:url])
        {
            return idx;
        }
    }
    return NSNotFound;
}

- (void)imageCache:(SDImageCache *)imageCache didFindImage:(UIImage *)image forKey:(NSString *)key userInfo:(NSDictionary *)info    //从缓存中拿到图片
{
    NSURL *url = [info objectForKey:@"url"];
    id<SDWebImageManagerDelegate> delegate = [info objectForKey:@"delegate"];

    NSUInteger idx = [self indexOfDelegate:delegate waitingForURL:url];
    if (idx == NSNotFound)
    {
        // Request has since been canceled
        return;
    }

    DLog(@"cacheInfo: %@",info);
    if (delegate && [delegate respondsToSelector:@selector(webImageManager:didFinishWithImage:withURL:)])  //把从缓存里面拿到的图片传回去
    {
        //[delegate performSelector:@selector(webImageManager:didFinishWithImage:) withObject:self withObject:image];
        [delegate webImageManager:self didFinishWithImage:image withURL:url];
    }

    [cacheDelegates removeObjectAtIndex:idx]; //从缓存里面把委托和url移除
    [cacheURLs removeObjectAtIndex:idx];
}

- (void)imageCache:(SDImageCache *)imageCache didNotFindImageForKey:(NSString *)key userInfo:(NSDictionary *)info  //处理rul字符串丢失或为空的情况
{
    NSURL *url = [info objectForKey:@"url"];
    id<SDWebImageManagerDelegate> delegate = [info objectForKey:@"delegate"];
    SDWebImageOptions options = [[info objectForKey:@"options"] intValue];

    NSUInteger idx = [self indexOfDelegate:delegate waitingForURL:url];
    if (idx == NSNotFound)
    {
        // Request has since been canceled
        return;
    }

    [cacheDelegates removeObjectAtIndex:idx];
    [cacheURLs removeObjectAtIndex:idx];

    // Share the same downloader for identical URLs so we don't download the same URL several times   //共用相同的请求url的相同下载体，防止相同的url去下载多次
    SDWebImageDownloader *downloader = [downloaderForURL objectForKey:url];

    if (!downloader)
    {
        downloader = [SDWebImageDownloader downloaderWithURL:url delegate:self userInfo:info lowPriority:(options & SDWebImageLowPriority)]; //用相关信息重新生成一个下载体，并开始执行任务
        [downloaderForURL setObject:downloader forKey:url];  //以url为关键字把下载体加入到字典
    }
    else
    {
        // Reuse shared downloader  //重用共用的下载体
        downloader.userInfo = info;
        downloader.lowPriority = (options & SDWebImageLowPriority);  //设置它的优先级
    }

    [downloadDelegates addObject:delegate]; //把下载委托加入到下载委托数组中
    [downloaders addObject:downloader]; //把创建的下载体加入到下载体数组里面
}

#pragma mark SDWebImageDownloaderDelegate

- (void)imageDownloader:(SDWebImageDownloader *)downloader didFinishWithImage:(UIImage *)image withURL:(NSURL *)URL
{
    [downloader retain];
    SDWebImageOptions options = [[downloader.userInfo objectForKey:@"options"] intValue];

    // Notify all the downloadDelegates with this downloader
    for (NSInteger idx = (NSInteger)[downloaders count] - 1; idx >= 0; idx--)
    {
        NSUInteger uidx = (NSUInteger)idx;
        SDWebImageDownloader *aDownloader = [downloaders objectAtIndex:uidx];
        if (aDownloader == downloader)
        {
            id<SDWebImageManagerDelegate> delegate = [[[downloadDelegates objectAtIndex:uidx] retain] autorelease];

            if (image)
            {
                if (delegate && [delegate respondsToSelector:@selector(webImageManager:didFinishWithImage:withURL:)])
                {
                   // [delegate performSelector:@selector(webImageManager:didFinishWithImage:withConnection:) withObject:self withObject:image];
                    [delegate webImageManager:self didFinishWithImage:image withURL:URL];
                }
            }
            else
            {
                if (delegate && [delegate respondsToSelector:@selector(webImageManager:didFailWithError:withURL:)])
                {
                   // [delegate performSelector:@selector(webImageManager:didFailWithError:withConnection:) withObject:self withObject:nil];
                    [delegate webImageManager:self didFailWithError:nil withURL:URL];
                }
            }

            [downloaders removeObjectAtIndex:uidx];
            [downloadDelegates removeObjectAtIndex:uidx];
        }
    }

    if (image)
    {
        // Store the image in the cache
        [[SDImageCache sharedImageCache] storeImage:image
                                          imageData:downloader.imageData
                                             forKey:[downloader.url absoluteString]
                                             toDisk:!(options & SDWebImageCacheMemoryOnly)];
    }
    else if (!(options & SDWebImageRetryFailed))
    {
        // The image can't be downloaded from this URL, mark the URL as failed so we won't try and fail again and again
        // (do this only if SDWebImageRetryFailed isn't activated)
        [failedURLs addObject:downloader.url];
    }


    // Release the downloader
    [downloaderForURL removeObjectForKey:downloader.url];
    [downloader release];
}

- (void)imageDownloader:(SDWebImageDownloader *)downloader didFailWithError:(NSError *)error withURL:(NSURL *)URL
{
    [downloader retain];

    // Notify all the downloadDelegates with this downloader
    for (NSInteger idx = (NSInteger)[downloaders count] - 1; idx >= 0; idx--)
    {
        NSUInteger uidx = (NSUInteger)idx;
        SDWebImageDownloader *aDownloader = [downloaders objectAtIndex:uidx];
        if (aDownloader == downloader)
        {
            id<SDWebImageManagerDelegate> delegate = [[[downloadDelegates objectAtIndex:uidx] retain] autorelease];

            if (delegate && [delegate respondsToSelector:@selector(webImageManager:didFailWithError:withURL:)])
            {
                //[delegate performSelector:@selector(webImageManager:didFailWithError:) withObject:self withObject:error];
                [delegate webImageManager:self didFailWithError:error withURL:URL];
            }

            [downloaders removeObjectAtIndex:uidx];
            [downloadDelegates removeObjectAtIndex:uidx];
        }
    }

    // Release the downloader
    [downloaderForURL removeObjectForKey:downloader.url];
    [downloader release];
}

@end

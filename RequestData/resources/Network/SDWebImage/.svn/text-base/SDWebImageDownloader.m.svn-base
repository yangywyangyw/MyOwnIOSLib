/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "SDWebImageDownloader.h"

#ifdef ENABLE_SDWEBIMAGE_DECODER
#import "SDWebImageDecoder.h"
@interface SDWebImageDownloader (ImageDecoder) <SDWebImageDecoderDelegate>
@end
#endif

NSString *const SDWebImageDownloadStartNotification = @"SDWebImageDownloadStartNotification";
NSString *const SDWebImageDownloadStopNotification = @"SDWebImageDownloadStopNotification";

@interface SDWebImageDownloader ()
@property (nonatomic, retain) NSURLConnection *connection;
@end

@implementation SDWebImageDownloader
@synthesize url, delegate, connection, imageData, userInfo, lowPriority;

#pragma mark Public Methods

+ (id)downloaderWithURL:(NSURL *)url delegate:(id<SDWebImageDownloaderDelegate>)delegate
{
    return [self downloaderWithURL:url delegate:delegate userInfo:nil];
}

+ (id)downloaderWithURL:(NSURL *)url delegate:(id<SDWebImageDownloaderDelegate>)delegate userInfo:(id)userInfo
{

    return [self downloaderWithURL:url delegate:delegate userInfo:userInfo lowPriority:NO];
}

+ (id)downloaderWithURL:(NSURL *)url delegate:(id<SDWebImageDownloaderDelegate>)delegate userInfo:(id)userInfo lowPriority:(BOOL)lowPriority   //用相关信息创建一个新的下载体，并开始下载；
{
    // Bind SDNetworkActivityIndicator if available (download it here: http://github.com/rs/SDNetworkActivityIndicator )
    // To use it, just add #import "SDNetworkActivityIndicator.h" in addition to the SDWebImage import
//    if (NSClassFromString(@"SDNetworkActivityIndicator"))
//    {
//        id activityIndicator = [NSClassFromString(@"SDNetworkActivityIndicator") performSelector:NSSelectorFromString(@"sharedActivityIndicator")];
//        [[NSNotificationCenter defaultCenter] addObserver:activityIndicator
//                                                 selector:NSSelectorFromString(@"startActivity")
//                                                     name:SDWebImageDownloadStartNotification object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:activityIndicator
//                                                 selector:NSSelectorFromString(@"stopActivity")
//                                                     name:SDWebImageDownloadStopNotification object:nil];
//    }

    SDWebImageDownloader *downloader = [[[SDWebImageDownloader alloc] init] autorelease];
    downloader.url = url;
    downloader.delegate = delegate;
    downloader.userInfo = userInfo;
    downloader.lowPriority = lowPriority;
    [downloader performSelectorOnMainThread:@selector(start) withObject:nil waitUntilDone:YES];
    return downloader;
}

+ (void)setMaxConcurrentDownloads:(NSUInteger)max
{
    // NOOP
}

- (void)start
{
    // In order to prevent from potential duplicate caching (NSURLCache + SDImageCache) we disable the cache for image requests
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:15];
    self.connection = [[[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO] autorelease];
    // If not in low priority mode, ensure we aren't blocked by UI manipulations (default runloop mode for NSURLConnection is NSEventTrackingRunLoopMode)
    if (!lowPriority)
    {
        [connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
    [connection start];
    [request release];

    if (connection)
    {
        self.imageData = [NSMutableData data];
        [[NSNotificationCenter defaultCenter] postNotificationName:SDWebImageDownloadStartNotification object:nil];
    }
    else
    {
        if (delegate && [delegate respondsToSelector:@selector(imageDownloader:didFailWithError:withURL:)])
        {
            //[delegate performSelector:@selector(imageDownloader:didFailWithError:withConnection:) withObject:self withObject:nil];
            [delegate imageDownloader:self didFailWithError:nil withURL:url];
        }
    }
}

- (void)cancel
{
    if (connection)
    {
        [connection cancel];
        self.connection = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:SDWebImageDownloadStopNotification object:nil];
    }
}

#pragma mark NSURLConnection (delegate)

- (void)connection:(NSURLConnection *)aConnection didReceiveData:(NSData *)data
{
    [imageData appendData:data];
}

#pragma GCC diagnostic ignored "-Wundeclared-selector"
- (void)connectionDidFinishLoading:(NSURLConnection *)aConnection
{
    self.connection = nil;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SDWebImageDownloadStopNotification object:nil];

    if (delegate && [delegate respondsToSelector:@selector(imageDownloaderDidFinish:withURL:)])
    {
        [delegate performSelector:@selector(imageDownloaderDidFinish:withURL:) withObject:self withObject:url];
    }

    if (delegate && [delegate respondsToSelector:@selector(imageDownloader:didFinishWithImage:withURL:)])
    {
        UIImage *image = [[UIImage alloc] initWithData:imageData];

#ifdef ENABLE_SDWEBIMAGE_DECODER
        [[SDWebImageDecoder sharedImageDecoder] decodeImage:image withDelegate:self userInfo:nil];
#else
       // [delegate performSelector:@selector(imageDownloader:didFinishWithImage:) withObject:self withObject:image withObject:aConnection];
        [delegate imageDownloader:self didFinishWithImage:image withURL:url];
#endif
        [image release];
    }
}

- (void)connection:(NSURLConnection *)aconnection didFailWithError:(NSError *)error
{
    [[NSNotificationCenter defaultCenter] postNotificationName:SDWebImageDownloadStopNotification object:nil];

    if (delegate && [delegate respondsToSelector:@selector(imageDownloader:didFailWithError: withURL:)])
    {
       // [delegate performSelector:@selector(imageDownloader:didFailWithError:) withObject:self withObject:error];
        [delegate imageDownloader:self didFailWithError:error withURL:url];
    }
    
    self.connection = nil;
    self.imageData = nil;
}

#pragma mark SDWebImageDecoderDelegate

#ifdef ENABLE_SDWEBIMAGE_DECODER
- (void)imageDecoder:(SDWebImageDecoder *)decoder didFinishDecodingImage:(UIImage *)image userInfo:(NSDictionary *)userInfo
{
    if(delegate && [delegate respondsToSelector:@selector(imageDownloader:didFinishWithImage: withURL:)])
    {
       //  [delegate performSelector:@selector(imageDownloader:didFinishWithImage:) withObject:self withObject:image];
        [delegate imageDownloader:self didFinishWithImage:image withURL:url];
    }
   
}
#endif

#pragma mark NSObject

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [url release], url = nil;
    [connection release], connection = nil;
    [imageData release], imageData = nil;
    [userInfo release], userInfo = nil;
    [super dealloc];
}


@end

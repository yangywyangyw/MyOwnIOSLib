//
//  ASIHTTPRequestConfig.h
//  Part of ASIHTTPRequest -> http://allseeing-i.com/ASIHTTPRequest
//
//  Created by Ben Copsey on 14/12/2009.
//  Copyright 2009 All-Seeing Interactive. All rights reserved.
//


// ======
// Debug output configuration options
// ======
//打印request的生命周期的所有信息，开始，结束上载，结束下载。
// When set to 1 ASIHTTPRequests will print information about what a request is doing
#ifndef DEBUG_REQUEST_STATUS
	#define DEBUG_REQUEST_STATUS 0
#endif
//打印出ASIFormDataRequest将发送的整个request体。使用ASIFormDataRequest时，这一项很有用。
// When set to 1, ASIFormDataRequests will print information about the request body to the console
#ifndef DEBUG_FORM_DATA_REQUEST
	#define DEBUG_FORM_DATA_REQUEST 0
#endif

//打印request使用了多少流量（大致），如果request的流量被控制，打印如何被控制。当与DEBUG_REQUEST_STATUS结合使用时，这一项可以用来调试“超时”，你可以看到request停止发送或接收数据的时间点。
// When set to 1, ASIHTTPRequests will print information about bandwidth throttling to the console
#ifndef DEBUG_THROTTLING
	#define DEBUG_THROTTLING 0
#endif

//打印request如何重用持久连接的信息，如果你看到这样的信息：
//Request attempted to use connection #1, but it has been closed – will retry with a new connection
//这说明你设置的persistentConnectionTimeoutSeconds 太大了。
// When set to 1, ASIHTTPRequests will print information about persistent connections to the console
#ifndef DEBUG_PERSISTENT_CONNECTIONS
	#define DEBUG_PERSISTENT_CONNECTIONS 0
#endif

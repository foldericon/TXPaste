/*
 ===============================================================================
 Copyright (c) 2013-2014, Tobias Pollmann (foldericon)
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 * Neither the name of the <organization> nor the
 names of its contributors may be used to endorse or promote products
 derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
 DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 ===============================================================================
*/


#import "TXPasteHelper.h"

#define _requestUserAgent @"Textual/1.0 (+http://www.codeux.com/textual)"

@implementation TXPasteHelper

@synthesize receivedData, url, completionBlock;

- init {
    if ((self = [super init])) {
		
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
}


- (void)setDelegate:(id)val
{
    delegate = val;
}

- (id)delegate
{
    return delegate;
}

- (void)get:(NSURL *)theurl {
	
    self.url = theurl;
	receivedData = [[NSMutableData alloc] init];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]
							 initWithURL:self.url
							 cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
							 timeoutInterval: 30
							 ];

    if(self.postString) {
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:[self.postString dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [request setValue:_requestUserAgent forHTTPHeaderField:@"User-Agent"];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    
    [connection scheduleInRunLoop:[NSRunLoop mainRunLoop]
                          forMode:NSDefaultRunLoopMode];
    [connection start];

}


#pragma mark NSURLConnection delegate methods
- (NSURLRequest *)connection:(NSURLConnection *)connection
			 willSendRequest:(NSURLRequest *)request
			redirectResponse:(NSURLResponse *)redirectResponse {
    return request;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response {

    self.finalURL = response.URL;
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if([self completionBlock])
        [self completionBlock]([NSError errorWithDomain:@"TXPaste" code:error.code userInfo:error.userInfo]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if([self completionBlock])
        [self completionBlock]([NSError errorWithDomain:@"TXPaste" code:100 userInfo:nil]);
}

@end
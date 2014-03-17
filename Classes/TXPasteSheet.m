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


#import "TXPasteSheet.h"

@implementation TXPasteSheet

- (id)init
{
	if ((self = [super init])) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [NSBundle loadNibNamed:@"PasteSheet" owner:self];
        });
    }
	return self;
}

-(void)start
{
    NSRect rect = NSMakeRect(self.sheet.frame.origin.x, self.sheet.frame.origin.y, 775, 375);
    [self.sheet setFrame:rect display:YES];
	[NSApp beginSheet:self.sheet
	   modalForWindow:self.window
		modalDelegate:self
	   didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:)
		  contextInfo:nil];
     [self.window makeKeyAndOrderFront:self.sheet];
}

- (void)sheetDidEnd:(NSWindow *)sender returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    [self.sheet close];
}

- (IBAction)close:(id)sender
{
    [NSApp endSheet:self.sheet];
}

- (void)windowDidBecomeKey:(NSNotification *)notification
{
    dispatch_sync(dispatch_get_main_queue(), ^{
        [self.webView setMainFrameURL:[NSString stringWithFormat:@"file://%@/Library/Application Support/Textual IRC/Extensions/TXPaste.bundle/Contents/Resources/html/index.html", NSHomeDirectory()]];
    });
}

-(void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame
{
    NSURL *url = [NSURL URLWithString:sender.mainFrameURL];
    if([url.pathComponents count] < 2) return;
    if([[url.pathComponents objectAtIndex:1] isEqualToString:@"paste"]) {
        [self close:nil];
        [self.plugin pasteURL:[url absoluteString]];
        [self.webView setMainFrameURL:@"https://ghostbin.com/"];        
    }
}

@end

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
#import "NoodleLineNumberView.h"

@implementation TXPasteSheet

- (id)init
{
	if ((self = [super init])) {
        [NSBundle loadNibNamed:@"PasteSheet" owner:self];
    }
	return self;
}

-(void)start
{
    NSRect rect = NSMakeRect(self.sheet.frame.origin.x, self.sheet.frame.origin.y, self.pasteSheetWidth, self.pasteSheetHeight);
    [self.sheet setFrame:rect display:YES];
    self.window = self.masterController.mainWindow;
    NoodleLineNumberView *lineNumbersView = [[NoodleLineNumberView alloc] initWithScrollView:scrollView];
    [scrollView setVerticalRulerView:lineNumbersView];
    [scrollView setHasHorizontalRuler:NO];
    [scrollView setHasVerticalRuler:YES];
    [scrollView setRulersVisible:YES];
    for (NSDictionary *dict in self.languages) {
        [self.langBox addItemWithObjectValue:[dict objectForKey:@"name"]];
    }
    [self.langBox setDelegate:self];
    [self.pasteText setDelegate:self];
    [self.pasteText setFont:[NSFont userFixedPitchFontOfSize:[NSFont systemFontSize]]];
    NSColor *color = [NSColor colorWithCalibratedRed:0.09 green:0.09 blue:0.09 alpha:1.0];
    if([TPCPreferences invertSidebarColors]) {
        [lineNumbersView setBackgroundColor:color];
        [self.pasteText setBackgroundColor:color];
        [self.pasteText setTextColor:[NSColor whiteColor]];
        [self.pasteText setInsertionPointColor:[NSColor whiteColor]];
    } else {
        [lineNumbersView setBackgroundColor:[NSColor whiteColor]];
        [self.pasteText setBackgroundColor:[NSColor whiteColor]];
        [self.pasteText setTextColor:color];
        [self.pasteText setInsertionPointColor:color];
    }
	[NSApp beginSheet:self.sheet
	   modalForWindow:self.window
		modalDelegate:self
	   didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:)
		  contextInfo:nil];
    [self.window makeKeyAndOrderFront:self.sheet];
    [self.sheet makeFirstResponder:self.langBox];
    [self.sheet makeFirstResponder:self.pasteText];
}

- (void)sheetDidEnd:(NSWindow *)sender returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    [self setWindowSizeWidth:(int)self.sheet.frame.size.width height:(int)self.sheet.frame.size.height];
    [self.sheet close];
}

- (IBAction)close:(id)sender
{
    [NSApp endSheet:self.sheet];
}

- (IBAction)paste:(id)sender {
    NSString *langid;
    for (NSDictionary *dict in self.languages) {
        if ([[dict objectForKey:@"name"] isEqualToString:self.langBox.stringValue]) {
            langid = [dict objectForKey:@"id"];
            break;
        }
    }
    NSString *expire;
    switch (self.expiration.selectedTag) {
        case (1):
            expire = @"-1";
            break;
        case (2):
            expire = @"10m";
            break;
        case (3):
            expire = @"1h";
            break;
        case (4):
            expire = @"1d";
            break;
    }
    NSString *postString = [NSString stringWithFormat:@"lang=%@&text=%@&expire=%@", langid, self.pasteText.string, expire];
    [TXPaste paste:postString];
    [NSApp endSheet:self.sheet];
}

- (void)setWindowSizeWidth:(NSInteger)width height:(NSInteger)height
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[self preferences]];
    [dict setObject:[NSNumber numberWithInteger:width] forKey:TXPasteSheetWidthKey];
    [dict setObject:[NSNumber numberWithInteger:height] forKey:TXPasteSheetHeightKey];
    [self setPreferences:dict];
}

#pragma mark -
#pragma mark Delegate Methods

- (void)controlTextDidChange:(NSNotification *)notification
{
    if([notification object] == self.langBox)
    {
        NSString *str = [self.langBox stringValue];
        NSAssertReturn(str.length > 0);
        BOOL found = NO;
        for (NSDictionary *dict in self.languages) {
            if ([[[dict objectForKey:@"name"] lowercaseString] hasPrefix:str.lowercaseString]) {
                found = YES;
                break;
            }
        }
        if(found == NO) {
            str = [str substringToIndex:[str length]-1];
            [self.langBox setStringValue:str];
        }
    }
}

- (void)controlTextDidEndEditing:(NSNotification *)notification
{
    NSString *str = [self.langBox stringValue];
    for (NSDictionary *dict in self.languages) {
        if ([[[dict objectForKey:@"name"] lowercaseString] hasPrefix:str.lowercaseString]) {
            [self.langBox setStringValue:[dict objectForKey:@"name"]];
            break;
        }
    }
}

@end

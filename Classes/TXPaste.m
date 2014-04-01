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


#import "TXPaste.h"
#import "TXPasteSheet.h"

#define _langURL @"https://ghostbin.com/languages.json"

@implementation TXPaste

#pragma mark -
#pragma mark Plugin API

- (void)pluginLoadedIntoMemory:(IRCWorld *)world
{
    TXPasteHelper *helper = [[TXPasteHelper alloc] init];
    [helper setDelegate:self];
    __block NSError *e;
    __block NSMutableArray *langs = [[NSMutableArray alloc] init];
    [helper setCompletionBlock:^(NSError *error) {
        if(error.code == 100) {
            NSArray *ary = [NSJSONSerialization JSONObjectWithData:helper.receivedData options:0 error:&e];
            for (NSDictionary *dict in ary) {
                for (NSDictionary *dict2 in [dict objectForKey:@"languages"]) {
                    [langs addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                      [dict2 objectForKey:@"id"], @"id",
                                      [dict2 objectForKey:@"name"], @"name",
                                      nil]];
                }
            }
        }
        if (langs.count > 0) {
            self.languages = langs;
        }
    }];
    [helper get:[NSURL URLWithString:_langURL]];
}

- (NSArray *)pluginSupportsUserInputCommands
{
    return @[@"paste"];
}

- (void)messageSentByUser:(IRCClient *)client
				  message:(NSString *)messageString
				  command:(NSString *)commandString
{
    if([commandString isNotEqualTo:@"PASTE"])
        return;
    TXPasteSheet *pasteSheet = [[TXPasteSheet alloc] init];
    pasteSheet.plugin = self;
    pasteSheet.window = self.masterController.mainWindow;

    for (NSDictionary *dict in self.languages) {
        [pasteSheet.langBox addItemWithObjectValue:[dict objectForKey:@"name"]];
    }
    
    [pasteSheet start];
    
}

- (void)pasteURL:(NSString *)url
{
    IRCClient *client = self.worldController.selectedClient;
    IRCChannel *channel = self.worldController.selectedChannel;
    [client sendCommand:[NSString stringWithFormat:@"MSG %@ %@", channel.name, url]];
}

@end

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
#import "TXPasteHelper.h"
#import "TXPasteSheet.h"

#define _langURL @"https://paste.directory/api/language/list"
#define _pasteURL @"https://paste.directory/api/post"

@implementation TXPaste

NSMutableArray *languages;

#pragma mark -
#pragma mark Plugin API

- (void)pluginLoadedIntoMemory:(IRCWorld *)world
{
    TXPasteHelper *helper = [[TXPasteHelper alloc] init];
    [helper setDelegate:self];
    __block NSError *e;
    languages = [[NSMutableArray alloc] init];
    [helper setCompletionBlock:^(NSError *error) {
        if(error.code == 100) {
            NSArray *ary = [NSJSONSerialization JSONObjectWithData:helper.receivedData options:0 error:&e];
            for (NSDictionary *dict in ary) {
                [languages addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                      [dict objectForKey:@"API"], @"id",
                                      [dict objectForKey:@"name"], @"name",
                                      nil]];
            }
        } else {
            IRCClient *client = self.masterController.masterController.mainWindow.selectedClient;
            [client printDebugInformation:[NSString stringWithFormat:@"TXPaste: Unable to fetch list of languages (%@)", error.userInfo]];
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
    if([messageString length] > 1) {
        NSString *postString = [NSString stringWithFormat:@"lang=%@&data=%@&expires=%ld&redirect=1", self.language, messageString, self.expiration];
        [TXPaste paste:postString];
    } else {
        TXPasteSheet *pasteSheet = [[TXPasteSheet alloc] init];
        pasteSheet.languages = languages;
        [pasteSheet start];
    }
    
}

+ (void)paste:(NSString *)postString
{
    TXPasteHelper *helper = [[TXPasteHelper alloc] init];
    [helper setDelegate:self];
    [helper setPostString:postString];
    [helper setCompletionBlock:^(NSError *error) {
        IRCClient *client = self.masterController.masterController.mainWindow.selectedClient;
        IRCChannel *channel = self.masterController.masterController.mainWindow.selectedChannel;
        if (error.code == 100){
            [client sendCommand:[NSString stringWithFormat:@"MSG %@ %@", channel.name, helper.finalURL.absoluteString]];
        } else {
            [client printDebugInformation:[NSString stringWithFormat:@"TXPaste: Unable to paste (%@)", error.userInfo]];
        }
    }];
    [helper get:[NSURL URLWithString:_pasteURL]];
}

@end

//
//  TXPastePrefs.m
//  TXPaste
//
//  Created by Toby P on 06/04/14.
//
//

#import "TXPastePrefs.h"

NSString *TXPasteSheetWidthKey = @"TXPasteSheetWidth";
NSString *TXPasteSheetHeightKey = @"TXPasteSheetHeight";

@implementation TXPastePrefs

- (NSDictionary *)preferences
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self preferencesPath]])
    {
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"778", TXPasteSheetWidthKey,
                              @"350", TXPasteSheetHeightKey,
                              nil];
        [self setPreferences:dict];
    }
    
    return [NSDictionary dictionaryWithContentsOfFile:[self preferencesPath]];
}

- (void)setPreferences:(NSDictionary *)dictionary
{
    [dictionary writeToFile:[self preferencesPath] atomically:YES];
}

- (NSString *)preferencesPath
{
    return [[NSString stringWithFormat:@"%@/Library/Preferences/%@.plist", NSHomeDirectory(), [[NSBundle bundleForClass:[self class]] bundleIdentifier]] stringByExpandingTildeInPath];
}

- (NSInteger)pasteSheetWidth
{
    return [[self.preferences objectForKey:TXPasteSheetWidthKey] integerValue];
}

- (NSInteger)pasteSheetHeight
{
    return [[self.preferences objectForKey:TXPasteSheetHeightKey] integerValue];
}
@end

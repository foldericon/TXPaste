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
NSString *TXPasteExpirationKey = @"TXPasteExpiration";
NSString *TXPasteLanguageKey = @"TXPasteLanguage";
NSString *TXPasteLastCachedDateKey = @"TXPasteLastCachedDate";
NSString *TXPasteCachedLanguagesKey = @"TXPasteCachedLanguages";

@implementation TXPastePrefs

- (NSDictionary *)preferences
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self preferencesPath]])
    {
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"778", TXPasteSheetWidthKey,
                              @"350", TXPasteSheetHeightKey,
                              @"0", TXPasteExpirationKey,
                              @"text", TXPasteLanguageKey,
                              @"0", TXPasteLastCachedDateKey,
                              [NSArray array], TXPasteCachedLanguagesKey,
                              nil];
        [self setPreferences:dict];
    }

    NSPropertyListFormat format;
    NSError *error;
    id plist = [NSPropertyListSerialization propertyListWithData:[NSData dataWithContentsOfFile:self.preferencesPath]
                                                         options:NSPropertyListImmutable
                                                          format:&format
                                                           error:&error]; 
    return plist;
}

- (void)setPreferences:(NSDictionary *)dictionary
{
    NSData *serializedData;
    NSString *error;
    serializedData = [NSPropertyListSerialization dataFromPropertyList:dictionary
                                                                format:NSPropertyListBinaryFormat_v1_0
                                                      errorDescription:&error];
    if (serializedData)
        [serializedData writeToFile:[self preferencesPath] atomically:YES];
    else
        NSLog(@"Error: %@", error);
}

- (NSString *)preferencesPath
{
    return [[NSString stringWithFormat:@"%@/Library/Preferences/%@.plist", NSHomeDirectory(), [[NSBundle bundleForClass:[self class]] bundleIdentifier]] stringByExpandingTildeInPath];
}

- (NSString *)language
{
    return [self.preferences objectForKey:TXPasteLanguageKey];
}

- (NSInteger)expiration
{
    return [[self.preferences objectForKey:TXPasteExpirationKey] integerValue];
}

- (NSInteger)pasteSheetWidth
{
    return [[self.preferences objectForKey:TXPasteSheetWidthKey] integerValue];
}

- (NSInteger)pasteSheetHeight
{
    return [[self.preferences objectForKey:TXPasteSheetHeightKey] integerValue];
}

- (NSInteger)lastCachedDate
{
    return [[self.preferences objectForKey:TXPasteLastCachedDateKey] integerValue];
}

- (NSArray *)cachedLanguages
{
    return [self.preferences objectForKey:TXPasteCachedLanguagesKey];
}
@end

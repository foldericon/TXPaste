//
//  TXPastePrefs.h
//  TXPaste
//
//  Created by Toby P on 06/04/14.
//
//

#import <Foundation/Foundation.h>

extern NSString *TXPasteSheetWidthKey;
extern NSString *TXPasteSheetHeightKey;
extern NSString *TXPasteExpirationKey;
extern NSString *TXPasteLanguageKey;
extern NSString *TXPasteLastCachedDateKey;
extern NSString *TXPasteCachedLanguagesKey;

@interface TXPastePrefs : NSObject

@property (assign) NSDictionary *preferences;
@property (readonly) NSString *preferencesPath;
@property (readonly) NSString *language;
@property (readonly) NSInteger expiration;
@property (readonly) NSInteger pasteSheetWidth;
@property (readonly) NSInteger pasteSheetHeight;
@property (readonly) NSInteger lastCachedDate;
@property (readonly) NSArray *cachedLanguages;

@end

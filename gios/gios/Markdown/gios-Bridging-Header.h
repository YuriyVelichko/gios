//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#import <Foundation/Foundation.h>


@interface MarkdownBridge : NSObject

- (NSString*) convertToHTML: (NSString*) data ;

@end
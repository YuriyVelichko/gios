//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#import "MMMarkdown.h"
#import "gios-Bridging-Header.h"

@implementation MarkdownBridge : NSObject

- (NSString*) convertToHTML : (NSString*) data {
    
    NSError  *error;
    NSString *htmlString = [MMMarkdown HTMLStringWithMarkdown:data error:&error];
    
    return htmlString;
}

@end
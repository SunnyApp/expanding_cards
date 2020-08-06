#import "ExpandingCardsPlugin.h"
#if __has_include(<expanding_cards/expanding_cards-Swift.h>)
#import <expanding_cards/expanding_cards-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "expanding_cards-Swift.h"
#endif

@implementation ExpandingCardsPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftExpandingCardsPlugin registerWithRegistrar:registrar];
}
@end

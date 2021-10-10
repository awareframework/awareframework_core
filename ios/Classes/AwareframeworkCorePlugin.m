#import "AwareframeworkCorePlugin.h"
#if __has_include(<awareframework_core/awareframework_core-Swift.h>)
#import <awareframework_core/awareframework_core-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "awareframework_core-Swift.h"
#endif

@implementation AwareframeworkCorePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAwareframeworkCorePlugin registerWithRegistrar:registrar];
}
@end

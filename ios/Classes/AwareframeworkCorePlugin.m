#import "AwareframeworkCorePlugin.h"
#import <awareframework_core/awareframework_core-Swift.h>

@implementation AwareframeworkCorePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAwareframeworkCorePlugin registerWithRegistrar:registrar];
}
@end

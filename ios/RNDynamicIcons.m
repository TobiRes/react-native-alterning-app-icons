
#import "React/RCTLog.h"

#import "RNDynamicIcons.h"

@implementation RNDynamicIcons

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(switchAppIcon:(NSString *)iconName)
{
     if ([[UIApplication sharedApplication] respondsToSelector:@selector(supportsAlternateIcons)] &&
         [[UIApplication sharedApplication] supportsAlternateIcons])
     {
         NSMutableString *selectorString = [[NSMutableString alloc] initWithCapacity:40];
         [selectorString appendString:@"_setAlternate"];
         [selectorString appendString:@"IconName:"];
         [selectorString appendString:@"completionHandler:"];

         SEL selector = NSSelectorFromString(selectorString);
         IMP imp = [[UIApplication sharedApplication] methodForSelector:selector];
         void (*func)(id, SEL, id, id) = (void *)imp;
         if (func)
         {
             func([UIApplication sharedApplication], selector, iconName, ^(NSError * _Nullable error) {
                 if (error != nil) {
                   RCTLog(@"%@", [error description]);
                 }
             });
         }
     }
}

RCT_REMAP_METHOD(dynamicAppIconSupported, resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
  bool supported = [[UIApplication sharedApplication] supportsAlternateIcons];
  resolve(@(supported));
}

RCT_EXPORT_METHOD(getIconName:(RCTResponseSenderBlock) callback ){
    NSString *name = @"default";
    NSDictionary *results;

    if( SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.3") ){
        if( [[UIApplication sharedApplication] supportsAlternateIcons ] ){
            name = [[UIApplication sharedApplication] alternateIconName];
            if( name == nil ){
                name = @"default";
            }
        }
    }

    results = @{
                @"iconName":name
                };
    callback(@[results]);
}

@end

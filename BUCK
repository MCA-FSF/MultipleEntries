
# build target
# //:buckdemo_bundle

apple_resource(
  name = 'buckdemo_resource',
  files = glob(['*.png']),
  dirs = [],
)

apple_bundle(
  name = 'buckdemo_bundle',
  binary = ':buckdemo_binary',
  extension = 'app',
  info_plist = 'Info.plist',
)

apple_binary(
    name = 'buckdemo_binary',
    deps = [
        ':buckdemo_resource',
        '//Reachability:Reachability',
    ],
    preprocessor_flags = ['-fobjc-arc'],
    headers = glob([
      '*.h',
    ]),
    srcs = glob([
      '*.m',
    ]),
    frameworks = [
        '$SDKROOT/System/Library/Frameworks/Foundation.framework',
        '$SDKROOT/System/Library/Frameworks/UIKit.framework',
        '$SDKROOT/System/Library/Frameworks/SystemConfiguration.framework',
    ],
    libraries = [
        '$SDKROOT/usr/lib/libobjc.dylib',
    ],
)
apple_package(
  name = 'buckdemo_package',
  bundle = ':buckdemo_bundle',
)

# Streak game iOS SDK

This lightweight and open-source SDK implements a best-practices PrePlay Streak game integration.

## Overview

  This code repository will help you to integrate a PrePlay Streak game into your iOS application.
  To use it, you must have an `app id` provided by PrePlay. If you don't have one, please get in touch with us at contact@preplaysports.com

  The main goal of this repository is to simplify your life with the integration of a PrePlay Streak game.
  
  So, to make it easy, this SDK contains an example view controller used to host a WebView pointing to the streak game.

  We also support deeplinking to open your app directly to a specific page of the game.

  If you have any issues, feel free to open an issue / pull request.

  The code is located at https://github.com/preplay/streak-ios-sdk

## Getting Started

  - Integrate a webview as in the example (in SecondViewController)
  - Customize the preplay app id
    Assuming it is $preplay_app_id in this example, change this 3 constants:
```
kURLScheme = @"streak-$preplay_app_id";
kHost = @"$preplay_app_id.streakit.preplaysports.com";
kStagingHost = @"$preplay_app_id.streakit-staging.preplaysports.com";
```
- Add the "loading" and "error" screens in the app bundle, as in the example
    If a user is not able to reach our website (due to a network error for example), you can specify your own error page.
    To do this, add a directory called "streak" and a file "error.html" into your "assets" folder. This file will be auto-loaded by the SDK if an error occurs.
    You can customize those as you wish. Currently they are empty web pages with a centered background image, which can be an animated gif (e.g. a loading spinners).

And that's it for the basic usage.

### Deep-linking

The Streak game can also contain a deep-link in order to open a specific page from a website, a push notification etc.

- Add the openURL scheme in Info.plist
  - It should be set to streak-$preplay_app_id
- Integrate the deeplinking code in the AppDelegate as in the example

### Sharing ###

The Streak game has a social sharing feature. For the best user experience, we use the native sharing support.
The sample view controller demonstrates the code involved to support it, which consists of:
  - Setting the proper custom HTTP headers. They signal the server that proper code support is present for the native sharing.
  - Use the `webView:shouldStartLoadWithRequest:navigationType:` method to observe the sharing feature trigger from the web app.


## Test the functionalities
### Deep Linking
  You can test the deep linking by opening Safari and putting in the address bar the following url:

    streak-$preplay_app_id://terms
  
  Upon hitting enter, the system will present you with a confirmation dialog, asking if you want to use your app to open this URL.
  If you answer "yes", and the integration is done properly, the Streak game webview should be presented.
  The webview will briefly show the loading screen, then the terms of service screen. 

### Sharing ###
  You can use the `darts` preplay app id, launch your app and trigger the sharing on one of the questions of the *Darts* sample activity.

 
### Change Log

#### 0.1 (2014-11-04)
- Initial release

## License

* [MIT](http://opensource.org/licenses/MIT)

## Contributing

Please fork this repository and contribute back using
[pull requests](https://github.com/preplay/streak-ios-sdk/pulls).

Any contributions, large or small, major features, bug fixes, additional
language translations, unit/integration tests are welcomed and appreciated
but will be thoroughly reviewed and discussed.

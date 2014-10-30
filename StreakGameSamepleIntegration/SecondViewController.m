//
//  SecondViewController.m
//  StreakGameSamepleIntegration
//
//  Created by Mathieu Ravaux on 21/10/2014.
//  Copyright (c) 2014 PrePlay. All rights reserved.
//

#import "SecondViewController.h"

static NSString* const kURLScheme = @"streak-darts";
static NSString* const kHost = @"darts.streakit.preplaysports.com";
static NSString* const kStagingHost = @"darts.streakit-staging.preplaysports.com";
//static NSString* const kHost = @"http://knicks.192.168.1.32.xip.io:9292";

@interface SecondViewController ()

@property(nonatomic, strong) UIWebView *webview;
@property(nonatomic, strong) NSURL *nextUrlToLoad;
@property(nonatomic) BOOL initialLoad;

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupWebView];
    
    [self showLocalContent:@"loading"];
    self.initialLoad = true;
}


- (void)setupWebView {
    UIWebView *webview = [[UIWebView alloc] initWithFrame:self.view.bounds];
    webview.delegate = self;
    [webview setAutoresizingMask:UIViewAutoresizingFlexibleHeight |UIViewAutoresizingFlexibleWidth];
    self.webview = webview;
    [self.view addSubview:webview];
}

- (NSString*)staticHtmlForScreen:(NSString *) path {
    NSString *file = [[NSBundle bundleForClass:self.class] pathForResource:path ofType:@"html"];
    NSError *error = nil;
    NSString *html = [NSString stringWithContentsOfFile:file usedEncoding:nil error:&error];
    if (error != nil) {
        NSLog(@"[Streak] Couldn't load loading screen from main bundle at %@.html: %@", path, error.localizedDescription);
    }
    return html;
}

- (void)showLocalContent:(NSString *) path {
    NSString* html = [self staticHtmlForScreen:path];
    if (html) {
        [self.webview loadHTMLString:html baseURL:[NSURL URLWithString:@"http://localhost/"]];
    }
}


- (void)navigateToStreakapp:(NSURL *)url {
    NSURL *requested = url ?: self.nextUrlToLoad;
    NSURL *resolved;
    
    if ([[requested scheme] isEqualToString:(NSString*)kURLScheme]) {
        NSString *curHost = [requested.host isEqualToString:@"staging"] ? kStagingHost : kHost;
        NSString *path = [requested path];
        if ([requested.path isEqualToString:@""] && ![requested.host isEqualToString:@"staging"]) {
            path = [@"/" stringByAppendingString:requested.host];
        }
        resolved = [[NSURL alloc] initWithScheme:@"http" host:curHost path:path];
    } else {
        // No deep-linking
        resolved = [[NSURL alloc] initWithScheme:@"http" host:kHost path:@"/"];
    }
    
    NSLog(@"fn=navigateToStreakapp(%@) nextUrlToLoad=%@ resolved=%@", url, [self.nextUrlToLoad absoluteString], [resolved absoluteString]);

    
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:resolved];

    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    [req setValue:info[(NSString *)kCFBundleIdentifierKey] forHTTPHeaderField:@"X-Streak-Embedded-In-App"];
    [req setValue:info[(NSString *)kCFBundleVersionKey] forHTTPHeaderField:@"X-Streak-Embedded-In-Build"];
    [req setValue:info[@"CFBundleShortVersionString"] forHTTPHeaderField:@"X-Streak-Embedded-In-Version"];
    NSString *platform = [[UIDevice currentDevice].systemName stringByAppendingString:[UIDevice currentDevice].systemVersion];
    [req setValue:platform  forHTTPHeaderField:@"X-Streak-Platform"];

    self.nextUrlToLoad = nil;
    [self.webview loadRequest:req];
}

- (void)navigateTo:(NSURL*)url {
    NSLog(@"fn=navigateTo url=%@", url);
    if (self.isViewLoaded) {
        [self navigateToStreakapp:url];
    }
    else {
        self.nextUrlToLoad = url;
    }
}


- (void)shareWithUrl:(NSString *)url andCopy:(NSString *)copy {
    NSURL *typedUrl = [NSURL URLWithString:url];
    NSArray *sharingItems = @[typedUrl, copy];

    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:sharingItems applicationActivities:nil];
    activityController.excludedActivityTypes = @[UIActivityTypeAssignToContact, UIActivityTypePrint, UIActivityTypeMail, UIActivityTypeMessage,
                                                 UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypeAddToReadingList];
    [self presentViewController:activityController animated:YES completion:nil];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView
shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType {
    NSLog(@"fn=shouldStartLoadWithRequest url=%@", request.URL);
    NSString *scheme = [[request URL] scheme];
    if ([@"streaksdk" isEqualToString:scheme]) {
        NSString *action = [[[request URL] host] stringByReplacingOccurrencesOfString:@".it" withString:@""];
        
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        for (NSString *param in [[[request URL] query] componentsSeparatedByString:@"&"]) {
            NSArray *elts = [param componentsSeparatedByString:@"="];
            if([elts count] < 2) continue;
            NSString *name = [elts objectAtIndex:0];
            NSString *value = [elts objectAtIndex:1];
            value = [value stringByReplacingOccurrencesOfString:@"+" withString:@" "];
            value = [value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [params setObject:value forKey: name];
        }

        if ([@"share" isEqualToString:action]) {
            [self shareWithUrl:params[@"url"] andCopy:params[@"copy"]];
        }
        
        return false;
    }
    return true;
}


- (void)webViewDidStartLoad:(UIWebView *)webView {
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if (self.initialLoad) {
        if ([self isOnLocalScreen]) {
            [self navigateToStreakapp:nil];
        } else {
            self.initialLoad = false;
        }
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"fn=didFailLoadWithError error=%@", error);
    if (self.initialLoad) {
        [self showLocalContent:@"error"];
        self.initialLoad = false;
    }
}

- (BOOL) isOnLocalScreen {
    NSURL* url = self.webview.request.mainDocumentURL;
    if (url) {
        return [url.host isEqualToString:@"localhost"];
    }
    return false;
}

@end

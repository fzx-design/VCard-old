//
//  WeiboClient.m
//  PushboxHD
//
//  Created by Xie Hasky on 11-7-23.
//  Copyright 2011年 同济大学. All rights reserved.
//

#import "WeiboClient.h"
#import "JSON.h"
#import "NSString+URLEncoding.h"

#define kUserDefaultKeyTokenResponseString @"kUserDefaultKeyTokenResponseString"

static NSString* const AppKey = @"1965726745";
static NSString* const AppSecret = @"55377ca138fa49b63b7767778ca1fb5a";
static NSString* const APIDomain = @"api.t.sina.com.cn";

static NSString* OAuthTokenKey = nil;
static NSString* OAuthTokenSecret = nil;

static NSString *UserID = nil;

typedef enum {
    HTTPMethodPost,
    HTTPMethodGet,
} HTTPMethod;

@interface WeiboClient()

@property (nonatomic, assign, getter=isAuthRequired) BOOL authRequired;
@property (nonatomic, assign, getter=isSecureConnection) BOOL secureConnection;
@property (nonatomic, retain) NSMutableDictionary *params;
@property (nonatomic, copy) NSString *path;
@property (nonatomic, retain) OAuthHTTPRequest *request;
@property (nonatomic, assign) HTTPMethod httpMethod;
@property (nonatomic, assign, getter=isSynchronized) BOOL synchronized;

+ (void)setTokenWithHTTPResponseString:(NSString *)responseString;
- (void)buildURL;
- (void)sendRequest;

@end

@implementation WeiboClient

@synthesize authRequired = _authRequired;
@synthesize secureConnection = _secureConnection;
@synthesize params = _params;
@synthesize request = _request;
@synthesize path = _path;
@synthesize httpMethod = _httpMethod;
@synthesize synchronized = _synchronized;

@synthesize responseJSONObject = _responseJSONObject;
@synthesize completionBlock = _completionBlock;
@synthesize responseStatusCode = _responseStatusCode;
@synthesize hasError = _hasError;
@synthesize errorDesc = _errorDesc;

+ (void)setTokenWithHTTPResponseString:(NSString *)responseString
{
    NSArray *pairs = [responseString componentsSeparatedByString:@"&"];
    
    for (NSString *pair in pairs) {
        NSArray *elements = [pair componentsSeparatedByString:@"="];
        if ([[elements objectAtIndex:0] isEqualToString:@"oauth_token"]) {
            OAuthTokenKey = [[elements objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        } else if ([[elements objectAtIndex:0] isEqualToString:@"oauth_token_secret"]) {
            OAuthTokenSecret = [[elements objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        } else if ([[elements objectAtIndex:0] isEqualToString:@"user_id"]) {
            UserID = [elements objectAtIndex:1];
        }
    }
}

+ (id)client
{
    //autorelease intentially ommited here
    return [[WeiboClient alloc] init];
}

- (id)init
{
    self = [super init];
    
    _params = [[NSMutableDictionary alloc] initWithCapacity:10];
    _secureConnection = NO;
    _authRequired = YES;
    _hasError = NO;
    _responseStatusCode = 0;
    _synchronized = NO;
    
    _request = [[OAuthHTTPRequest alloc] initWithURL:nil];
    _request.consumerKey = AppKey;
    _request.consumerSecret = AppSecret;
    _request.oauthTokenKey = OAuthTokenKey;
    _request.oauthTokenSecret = OAuthTokenSecret;
    _request.delegate = self;
    
    return self;
}

- (void)dealloc
{
    NSLog(@"WeiboClient dealloc");
    [_responseJSONObject release];
    [_params release];
    [_request release];
    [_completionBlock release];
    [_path release];
    [_errorDesc release];
    [super dealloc];
}

#pragma mark delegates

- (void)reportCompletion
{
    if (_completionBlock) {
        _completionBlock(self);
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSLog(@"Request Finished");
    NSLog(@"Response raw string:\n%@", [request responseString]);
    
    switch (request.responseStatusCode) {
        case 401: // Not Authorized: either you need to provide authentication credentials, or the credentials provided aren't valid.
            self.hasError = YES;
            self.errorDesc = NSLocalizedString(@"ERROR_AUTH_FAILED", nil);
            goto report_completion;
            
        case 304: // Not Modified: there was no new data to return.
            self.hasError = YES;
            self.errorDesc = NSLocalizedString(@"ERROR_NO_NEW_DATA", nil);
            goto report_completion;
            
        case 400: // Bad Request: your request is invalid, and we'll return an error message that tells you why. This is the status code returned if you've exceeded the rate limit
        case 200: // OK: everything went awesome.
        case 403: // Forbidden: we understand your request, but are refusing to fulfill it.  An accompanying error message should explain why
            break;
            
        case 404: // Not Found: either you're requesting an invalid URI or the resource in question doesn't exist (ex: no such user). 
        case 500: // Internal Server Error: we did something wrong.  Please post to the group about it and the Weibo team will investigate.
        case 502: // Bad Gateway: returned if Weibo is down or being upgraded.
        case 503: // Service Unavailable: the Weibo servers are up, but are overloaded with requests.  Try again later.
        default:
        {
            self.hasError = YES;
            self.errorDesc = [NSHTTPURLResponse localizedStringForStatusCode:request.responseStatusCode];
            goto report_completion;
        }
    }
    
    self.responseJSONObject = [request.responseString JSONValue];
    
    if ([self.responseJSONObject isKindOfClass:[NSDictionary class]]) {
        NSDictionary* dic = (NSDictionary*)self.responseJSONObject;
        NSString* errorCodeString = [dic objectForKey:@"error_code"];
        
        if (errorCodeString) {
            self.hasError = YES;
            self.responseStatusCode = [errorCodeString intValue];
            self.errorDesc = [dic objectForKey:@"error"];
            NSLog(@"Server responsed error code: %d\n\
                  desc: %@\n\
                  url: %@\n", self.responseStatusCode, self.errorDesc, request.url);
        }
    }
    
report_completion:
    [self reportCompletion];
    
    [self autorelease];
}

//failed due to network connection or other issues
- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSLog(@"Request Failed");
    NSLog(@"%@", _request.error);
    
    self.hasError = YES;
    self.errorDesc = @""; //to do
    
    //same block called when failed
    [self reportCompletion];
    
    [self autorelease];
}

#pragma mark URL-generation

- (NSString *)queryString
{
    NSMutableString *str = [NSMutableString stringWithCapacity:0];
    
    NSArray *names = [_params allKeys];
    for (int i = 0; i < [names count]; i++) {
        if (i > 0) {
            [str appendString:@"&"];
        }
        NSString *name = [names objectAtIndex:i];
        [str appendString:[NSString stringWithFormat:@"%@=%@", [name URLEncodedString], 
                           [[self.params objectForKey:name] URLEncodedString]]];
    }
    
    return str;
}

- (void)buildURL
{
    NSString* url = [NSString stringWithFormat:@"%@://%@/%@", 
                          self.secureConnection ? @"https" : @"http", 
                          APIDomain, self.path];
    
    if (self.httpMethod == HTTPMethodGet) {
        url = [NSString stringWithFormat:@"%@?%@", url, [self queryString]];
    }

    NSURL *finalURL = [NSURL URLWithString:url];
    
    NSLog(@"requestURL: %@", finalURL);
    
    [_request setURL:finalURL];
}

- (void)sendRequest
{
    if ([_request url]) {
        return;
    }
    
    if (self.secureConnection) {
        [self.request setValidatesSecureCertificate:NO];
    }
    
    [self buildURL];
    
    self.request.requestParams = self.params;
    
    if (self.httpMethod == HTTPMethodPost) {
        self.request.requestMethod = @"POST";
        NSString *postBody = [self queryString];
        NSMutableData *postData = [[NSMutableData alloc] initWithData:[postBody dataUsingEncoding:NSUTF8StringEncoding]];
        [self.request setPostBody:postData];
    }
    
    if (self.authRequired) {
        [self.request generateOAuthHeader];
    }

    if (self.isSynchronized) {
        [_request startSynchronous];
    }
    else {
        [_request startAsynchronous];
    }
}

#pragma mark APIs

+ (BOOL)authorized
{
    if (UserID != nil) {
        return YES;
    }
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *tokenResponseString = [ud objectForKey:kUserDefaultKeyTokenResponseString];
    if (tokenResponseString) {
        [self.class setTokenWithHTTPResponseString:tokenResponseString];
    }
    
    return UserID != nil;
}

+ (void)signout
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:nil forKey:kUserDefaultKeyTokenResponseString];
    [ud synchronize];
    
    OAuthTokenKey = nil;
    OAuthTokenSecret = nil;
    UserID = nil;
}

- (void)authWithUsername:(NSString *)username password:(NSString *)password autosave:(BOOL)autosave
{
    self.path = @"oauth/access_token";
    self.httpMethod = HTTPMethodPost;
    self.synchronized = YES; //
    self.request.delegate = nil;
    
    [self.params setObject:username forKey:@"x_auth_username"];
    [self.params setObject:password forKey:@"x_auth_password"];
    [self.params setObject:@"client_auth" forKey:@"x_auth_mode"];
    
    self.request.extraOAuthParams = self.params;
    
    [self sendRequest];
    
    if (!self.request.error) {
        [self.class setTokenWithHTTPResponseString:self.request.responseString];
        
        NSLog(@"auth response string: %@", self.request.responseString);
        
        if (UserID) {
            if (autosave) {
                NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
                [ud setObject:_request.responseString
                       forKey:kUserDefaultKeyTokenResponseString];
                [ud synchronize];
            }
        }
        
        [self reportCompletion];
    }
    else {
        NSLog(@"connection failed");
    }
    
    [self autorelease];
}


@end


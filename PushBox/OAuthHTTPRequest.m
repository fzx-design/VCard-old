//
//  OAuthHTTPRequest.m
//  PushboxHD
//
//  Created by Xie Hasky on 11-7-23.
//  Copyright 2011年 同济大学. All rights reserved.
//

#import "OAuthHTTPRequest.h"
#import <CommonCrypto/CommonHMAC.h>
#import "NSString+URLEncoding.h"
#import "OARequestParameter.h"
#import "Base64Transcoder.h"

@implementation OAuthHTTPRequest

@synthesize authNeeded = _authNeeded;
@synthesize consumerKey = _consumerKey;
@synthesize consumerSecret = _consumerSecret;
@synthesize oauthTokenKey = _oauthTokenKey;
@synthesize oauthTokenSecret = _oauthTokenSecret;
@synthesize extraOAuthParams = _extraOAuthParams;
@synthesize requestParams = _requestParams;
@synthesize nonce = _nonce;
@synthesize timestamp = _timestamp;

- (void)generateNonce
{
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    NSMakeCollectable(theUUID);
    _nonce = (NSString *)string;
}

- (void)generateTimestamp
{
    self.timestamp = [NSString stringWithFormat:@"%d", time(NULL)];
}

- (id)initWithURL:(NSURL *)newURL
{
    self = [super initWithURL:newURL];
    
    [self generateNonce];
    [self generateTimestamp];
    
    return self;
}

- (NSString *)signatureProviderName
{
    return @"HMAC-SHA1";
}

- (NSString *)signClearText:(NSString *)text withSecret:(NSString *)secret 
{
    NSData *secretData = [secret dataUsingEncoding:NSUTF8StringEncoding];
    NSData *clearTextData = [text dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char result[20];
	CCHmac(kCCHmacAlgSHA1, [secretData bytes], [secretData length], [clearTextData bytes], [clearTextData length], result);
    
    //Base64 Encoding
    
    char base64Result[32];
    size_t theResultLength = 32;
    Base64EncodeData(result, 20, base64Result, &theResultLength);
    NSData *theData = [NSData dataWithBytes:base64Result length:theResultLength];
    
    NSString *base64EncodedResult = [[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding];
    
    return [base64EncodedResult autorelease];
}

- (NSString *)signatureBaseString
{
    NSMutableArray *parameterPairs = [NSMutableArray array];
    
	[parameterPairs addObject:[[OARequestParameter requestParameterWithName:@"oauth_consumer_key" 
                                                                      value:self.consumerKey] URLEncodedNameValuePair]];
	[parameterPairs addObject:[[OARequestParameter requestParameterWithName:@"oauth_signature_method" 
                                                                      value:[self signatureProviderName]] URLEncodedNameValuePair]];
	[parameterPairs addObject:[[OARequestParameter requestParameterWithName:@"oauth_timestamp" 
                                                                      value:self.timestamp] URLEncodedNameValuePair]];
	[parameterPairs addObject:[[OARequestParameter requestParameterWithName:@"oauth_nonce" 
                                                                      value:self.nonce] URLEncodedNameValuePair]];
	[parameterPairs addObject:[[OARequestParameter requestParameterWithName:@"oauth_version" 
                                                                      value:@"1.0"] URLEncodedNameValuePair]];
    
    if (self.oauthTokenKey && ![self.oauthTokenKey isEqualToString:@""]) {
        [parameterPairs addObject:[[OARequestParameter requestParameterWithName:@"oauth_token" 
                                                                          value:self.oauthTokenKey] URLEncodedNameValuePair]];
    }
    
    [[self.requestParams allKeys] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *key = obj;
        [parameterPairs addObject:[[OARequestParameter requestParameterWithName:key
                                                                          value:[self.requestParams objectForKey:key]] URLEncodedNameValuePair]];
    }];
    
    NSArray *sortedPairs = [parameterPairs sortedArrayUsingSelector:@selector(compare:)];
    NSString *normalizedRequestParameters = [sortedPairs componentsJoinedByString:@"&"];
    
    NSArray *parts = [[self.url absoluteString] componentsSeparatedByString:@"?"];
    NSString *urlStringWithoutQuery = [parts objectAtIndex:0];
    
    NSString *ret = [NSString stringWithFormat:@"%@&%@&%@",
					 self.requestMethod,
					 [urlStringWithoutQuery URLEncodedString],
					 [normalizedRequestParameters URLEncodedString]];
	
	return ret;
}

- (void)generateOAuthHeader 
{
	NSString *signClearText = [self signatureBaseString];
	NSString *secret = [NSString stringWithFormat:@"%@&%@",
						[self.consumerSecret URLEncodedString],
						[self.oauthTokenSecret URLEncodedString]];
    NSString *signature = [self signClearText:signClearText withSecret:secret];
    
    NSString *oauthToken;
    if ([self.oauthTokenKey isEqualToString:@""])
        oauthToken = @"";
    else
        oauthToken = [NSString stringWithFormat:@"oauth_token=\"%@\", ", [self.oauthTokenKey URLEncodedString]];
	
	NSMutableString *extraParameters = [NSMutableString string];
	
	for(NSString *parameterName in [[self.extraOAuthParams allKeys] sortedArrayUsingSelector:@selector(compare:)])
	{
		[extraParameters appendFormat:@", %@=\"%@\"", [parameterName URLEncodedString], 
         [[self.extraOAuthParams objectForKey:parameterName] URLEncodedString]];
	}	
    
    NSString *oauthHeader = [NSString stringWithFormat:@"OAuth oauth_consumer_key=\"%@\", %@oauth_signature_method=\"%@\", oauth_signature=\"%@\", oauth_timestamp=\"%@\", oauth_nonce=\"%@\", oauth_version=\"1.0\"%@",
                             [self.consumerKey URLEncodedString],
                             oauthToken,
                             [[self signatureProviderName] URLEncodedString],
                             [signature URLEncodedString],
                             self.timestamp,
                             self.nonce,
							 extraParameters];
    
    [self addRequestHeader:@"Authorization" value:oauthHeader];
}

- (void)dealloc
{
    [_consumerKey release];
    [_consumerSecret release];
    [_oauthTokenKey release];
    [_oauthTokenSecret release];
    [_extraOAuthParams release];
    [_requestParams release];
    [_nonce release];
    [_timestamp release];
    [super dealloc];
}

@end

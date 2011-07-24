//
//  OAuthHTTPRequest.h
//  PushboxHD
//
//  Created by Xie Hasky on 11-7-23.
//  Copyright 2011年 同济大学. All rights reserved.
//

#import "ASIFormDataRequest.h"

@interface OAuthHTTPRequest : ASIFormDataRequest {
    BOOL _authNeeded;
    
    NSString *_consumerKey;
    NSString *_consumerSecret;
    
    NSString *_oauthTokenKey;
    NSString *_oauthTokenSecret;
    
    NSDictionary *_extraOAuthParams;
    NSDictionary *_requestParams;
    
    NSString *_nonce;
    NSString *_timestamp;
}

@property(nonatomic, assign, getter=isAuthNeeded) BOOL authNeeded;
@property(nonatomic, copy) NSString* consumerKey;
@property(nonatomic, copy) NSString* consumerSecret;
@property(nonatomic, copy) NSString* oauthTokenKey;
@property(nonatomic, copy) NSString* oauthTokenSecret;
@property(nonatomic, retain) NSDictionary* extraOAuthParams;
@property(nonatomic, retain) NSDictionary* requestParams;
@property(nonatomic, copy) NSString* nonce;
@property(nonatomic, copy) NSString* timestamp;

- (void)generateOAuthHeader;

@end

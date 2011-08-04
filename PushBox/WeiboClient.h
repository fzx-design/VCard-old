//
//  WeiboClient.h
//  PushboxHD
//
//  Created by Xie Hasky on 11-7-23.
//  Copyright 2011年 同济大学. All rights reserved.
//

#import "OAuthHTTPRequest.h"

@class WeiboClient;
@class User;

typedef void (^WCCompletionBlock)(WeiboClient *client);

@interface WeiboClient : NSObject <ASIHTTPRequestDelegate> {
    BOOL _hasError;
    NSString* _errorDesc;
    int _responseStatusCode;
    id _responseJSONObject;
    WCCompletionBlock _completionBlock;
}

@property (nonatomic, assign) BOOL hasError;
@property (nonatomic, copy) NSString* errorDesc;

// Status code generated by server side application
@property (nonatomic, assign) int responseStatusCode;

// NSDictionary or NSArray
@property (nonatomic, retain) id responseJSONObject;

- (void)setCompletionBlock:(void (^)(WeiboClient* client))completionBlock;
- (WCCompletionBlock)completionBlock;

// return an autoreleased object, while gets released after one of following calls complete
+ (id)client;

// return true if user already logged in
+ (BOOL)authorized;
+ (User *)currentUserInManagedObjectContext:(NSManagedObjectContext *)context;
+ (void)clearUser;
+ (void)signout;

- (void)authWithUsername:(NSString *)username password:(NSString *)password autosave:(BOOL)autosave;

- (void)getFriendsTimelineSinceID:(NSString *)sinceID 
                    withMaximumID:(NSString *)maxID 
                   startingAtPage:(int)page 
                            count:(int)count
                          feature:(int)feature;

- (void)getUserTimeline:(NSString *)userID 
				SinceID:(NSString *)sinceID 
		  withMaximumID:(NSString *)maxID 
		 startingAtPage:(int)page 
				  count:(int)count
                feature:(int)feature;

- (void)getCommentsOfStatus:(NSString *)statusID
                       page:(int)page
                      count:(int)count;

- (void)getCommentsAndRepostsCount:(NSArray *)statusIDs;

- (void)getUser:(NSString *)userID;

- (void)getFriendsOfUser:(NSString *)userID cursor:(int)cursor count:(int)count;
- (void)getFollowersOfUser:(NSString *)userID cursor:(int)cursor count:(int)count;

- (void)follow:(NSString *)userID;
- (void)unfollow:(NSString *)userID;

- (void)favorite:(NSString *)statusID;
- (void)unFavorite:(NSString *)statusID;

- (void)post:(NSString *)text;
- (void)post:(NSString *)text withImage:(UIImage *)image;
- (void)repost:(NSString *)statusID 
          text:(NSString *)text 
 commentStatus:(BOOL)commentStatus 
 commentOrigin:(BOOL)commentOrigin;

- (void)comment:(NSString *)statusID 
            cid:(NSString *)cid 
           text:(NSString *)text
  commentOrigin:(BOOL)commentOrigin;

- (void)destroyStatus:(NSString *)statusID;

- (void)getFavoritesByPage:(int)page;

- (void)getRelationshipWithUser:(NSString *)userID;



@end

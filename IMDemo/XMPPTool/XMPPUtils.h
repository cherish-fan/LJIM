//
//  XMPPUtils.h
//  IMDemo
//
//  Created by 梁建 on 14/12/1.
//  Copyright (c) 2014年 梁建. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
@protocol xmppConnectDelegate <NSObject>

@optional
/**
 *  认证通过
 */
- (void)didAuthenticate;
/**
 *  认证失败
 *
 *  @param error 认证失败的错误信息
 */
- (void)didNotAuthenticate:(NSXMLElement *)error;
/**
 *  注册时与xmpp服务器的连接
 */
- (void)anonymousConnected;
/**
 *  注册成功
 */
- (void)registerSuccess;
/**
 *  注册失败
 *
 *  @param error 注册失败的错误信息
 */
- (void)registerFailed:(NSXMLElement *)error;

@end



@protocol xmppMessageDelegate <NSObject>
@optional
/**
 *  接收到新消息
 *
 *  @param messageContent 接收到的消息字典
 */
-(void)newMessageReceived:(NSDictionary *)messageContent;

@end

@protocol xmppFriendsDelegate <NSObject>

-(void)friendsList:(NSDictionary *)dict;
-(void)removeFriens;

@end

@interface XMPPUtils : NSObject<UIApplicationDelegate>
{
    /**
     *  实体扩展模块
     */
    XMPPCapabilities *_xmppCapabilities;
    /**
     *  数据存储模块
     */
    XMPPCapabilitiesCoreDataStorage *_xmppCapabilitiesCoreDataStorage;//数据存储模块
    
    FMDatabase* _db;
    NSString* _userIdOld;
    
    
}
@property (nonatomic,readonly)XMPPStream *xmppStream;
@property (nonatomic,strong) XMPPRoster *xmppRoster;
@property (nonatomic,strong) XMPPRosterCoreDataStorage *xmppRosterDataStorage;
@property (nonatomic,strong) XMPPMessageArchivingCoreDataStorage *xmppMessageArchivingCoreDataStorage;
@property (nonatomic, strong)XMPPMessageArchiving *xmppMessageArchivingModule;
@property (nonatomic,strong) XMPPvCardCoreDataStorage *xmppvCardStorage;
@property (nonatomic,strong) XMPPvCardTempModule *xmppvCardTempModule;
@property (nonatomic,strong) XMPPRoomCoreDataStorage *xmppRoomCoreDataStorage;
@property (nonatomic,strong) XMPPMUC *xmppMUC;
@property (nonatomic,strong) XMPPReconnect *xmppReconnect;

@property (nonatomic,strong) NSMutableSet *rooms;
@property(strong,nonatomic,readonly)XMPPMessageArchiving *xmppMessageArchiving;
@property (nonatomic,weak) id<xmppConnectDelegate> connectDelegate;
@property (nonatomic,weak) id<xmppMessageDelegate> messageDelegate;
@property (nonatomic,weak) id<xmppFriendsDelegate> friendsDelegate;
/**
 *  获得本类的单例对象
 *
 *  @return 返回本类的单例对象
 */
+ (XMPPUtils *) sharedInstance;
/**
 *  初始化xmpp流
 */

-(void)setupStream;
/**
 *  用户上线
 */
-(void)goOnline;
/**
 *  用户下线
 */
-(void)goOffline;
/**
 *  连接到服务器
 *
 *  @return 返回bool值是否连接服务器连接成功
 */

-(BOOL)connect;

/**
 *  匿名连接至服务器
 */
- (void)anonymousConnect;
/**
 *  断开连接
 */
-(void)disconnect;

/**
 *  断开连接
 *
 *  @param userName 用户名
 *  @param pass     用户密码
 */
-(void)enrollWithUserName:(NSString *)userName andPassword:(NSString *)pass;
/**
 *  获取好友列表
 */
- (void)queryRoster;
/**
 *  添加好友
 *
 *  @param userName 添加好友的用户名
 */
-(void)addFriend:(NSString *)userName;
/**
 *  删除好友
 *
 *  @param userName 要删除的用户名
 */
-(void)delFriend:(NSString *)userName;
/**
 *  添加群组
 *
 *  @param room 要添加的房间
 */
-(void)addRoom:(XMPPRoom *)room;
/**
 *  是否已经存在房间
 *
 *  @param roomJID 房间的roomJID
 *
 *  @return 是否存在房间
 */
-(BOOL)isExistRoom:(XMPPJID *)roomJID;
/**
 *  获得已经存在的房间
 *
 *  @param roomJID 房间JID
 *
 *  @return 返回已经存在的XMPPRoom对象
 */
-(XMPPRoom *)getExistRoom:(XMPPJID *)roomJID;
/**
 *  获取数据库的用户信息
 *
 *  @param userId 用户的userID
 *
 *  @return 返回数据用户对话列表的数据库对象
 */
- (FMDatabase*)openUserDb:(NSString*)userId;


@end

//
//  Copyright (c) 2021 Open Whisper Systems. All rights reserved.
//

#import "AppSetup.h"
#import "Environment.h"
#import "OWSProfileManager.h"
#import "VersionMigrations.h"
#import <SignalMessaging/SignalMessaging-Swift.h>
#import <SignalMetadataKit/SignalMetadataKit-Swift.h>
#import <SignalServiceKit/OWS2FAManager.h>
#import <SignalServiceKit/OWSBackgroundTask.h>
#import <SignalServiceKit/OWSDisappearingMessagesJob.h>
#import <SignalServiceKit/OWSIdentityManager.h>
#import <SignalServiceKit/OWSMessageManager.h>
#import <SignalServiceKit/OWSOutgoingReceiptManager.h>
#import <SignalServiceKit/OWSReceiptManager.h>
#import <SignalServiceKit/SSKEnvironment.h>
#import <SignalServiceKit/SignalServiceKit-Swift.h>

NS_ASSUME_NONNULL_BEGIN

@implementation AppSetup

+ (void)setupEnvironmentWithPaymentsEvents:(id<PaymentsEvents>)paymentsEvents
                          mobileCoinHelper:(id<MobileCoinHelper>)mobileCoinHelper
                          webSocketFactory:(id<WebSocketFactory>)webSocketFactory
                 appSpecificSingletonBlock:(dispatch_block_t)appSpecificSingletonBlock
                       migrationCompletion:(void (^)(NSError *_Nullable error))migrationCompletion
{
    OWSAssertDebug(appSpecificSingletonBlock);
    OWSAssertDebug(migrationCompletion);

    [self suppressUnsatisfiableConstraintLogging];

    __block OWSBackgroundTask *_Nullable backgroundTask =
        [OWSBackgroundTask backgroundTaskWithLabelStr:__PRETTY_FUNCTION__];

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Order matters here.
        //
        // All of these "singletons" should have any dependencies used in their
        // initializers injected.
        [[OWSBackgroundTaskManager shared] observeNotifications];

        StorageCoordinator *storageCoordinator = [StorageCoordinator new];
        SDSDatabaseStorage *databaseStorage = storageCoordinator.databaseStorage;

        // AFNetworking (via CFNetworking) spools it's attachments to NSTemporaryDirectory().
        // If you receive a media message while the device is locked, the download will fail if the temporary directory
        // is NSFileProtectionComplete
        BOOL success;
        NSString *temporaryDirectory = NSTemporaryDirectory();
        success = [OWSFileSystem ensureDirectoryExists:temporaryDirectory];
        OWSAssert(success);
        success = [OWSFileSystem protectFileOrFolderAtPath:temporaryDirectory
                                        fileProtectionType:NSFileProtectionCompleteUntilFirstUserAuthentication];
        OWSAssert(success);

        OWSPreferences *preferences = [OWSPreferences new];

        NetworkManager *networkManager = [NetworkManager new];
        OWSContactsManager *contactsManager = [OWSContactsManager new];
        OWSLinkPreviewManager *linkPreviewManager = [OWSLinkPreviewManager new];
        MessageSender *messageSender = [MessageSender new];
        MessageSenderJobQueue *messageSenderJobQueue = [MessageSenderJobQueue new];
        id<PendingReceiptRecorder> pendingReceiptRecorder = [MessageRequestPendingReceipts new];
        OWSProfileManager *profileManager = [[OWSProfileManager alloc] initWithDatabaseStorage:databaseStorage];
        OWSMessageManager *messageManager = [OWSMessageManager new];
        BlockingManager *blockingManager = [BlockingManager new];
        OWSIdentityManager *identityManager = [[OWSIdentityManager alloc] initWithDatabaseStorage:databaseStorage];
        id<RemoteConfigManager> remoteConfigManager = [ServiceRemoteConfigManager new];
        SSKSessionStore *sessionStore = [SSKSessionStore new];
        SSKSignedPreKeyStore *signedPreKeyStore = [SSKSignedPreKeyStore new];
        SSKPreKeyStore *preKeyStore = [SSKPreKeyStore new];
        id<OWSUDManager> udManager = [OWSUDManagerImpl new];
        OWSMessageDecrypter *messageDecrypter = [OWSMessageDecrypter new];
        GroupsV2MessageProcessor *groupsV2MessageProcessor = [GroupsV2MessageProcessor new];
        SocketManager *socketManager = [[SocketManager alloc] init];
        TSAccountManager *tsAccountManager = [TSAccountManager new];
        OWS2FAManager *ows2FAManager = [OWS2FAManager new];
        OWSDisappearingMessagesJob *disappearingMessagesJob = [OWSDisappearingMessagesJob new];
        OWSReceiptManager *receiptManager = [OWSReceiptManager new];
        OWSOutgoingReceiptManager *outgoingReceiptManager = [OWSOutgoingReceiptManager new];
        id<SyncManagerProtocol> syncManager = (id<SyncManagerProtocol>)[[OWSSyncManager alloc] initDefault];
        id<SSKReachabilityManager> reachabilityManager = [SSKReachabilityManagerImpl new];
        id<OWSTypingIndicators> typingIndicators = [[OWSTypingIndicatorsImpl alloc] init];
        OWSAttachmentDownloads *attachmentDownloads = [[OWSAttachmentDownloads alloc] init];
        StickerManager *stickerManager = [[StickerManager alloc] init];
        SignalServiceAddressCache *signalServiceAddressCache = [SignalServiceAddressCache new];
        AccountServiceClient *accountServiceClient = [AccountServiceClient new];
        OWSStorageServiceManager *storageServiceManager = OWSStorageServiceManager.shared;
        SSKPreferences *sskPreferences = [SSKPreferences new];
        id<GroupsV2> groupsV2 = [GroupsV2Impl new];
        id<GroupV2Updates> groupV2Updates = [[GroupV2UpdatesImpl alloc] init];
        SenderKeyStore *senderKeyStore = [[SenderKeyStore alloc] init];

        OWSIncomingContactSyncJobQueue *incomingContactSyncJobQueue = [OWSIncomingContactSyncJobQueue new];
        OWSIncomingGroupSyncJobQueue *incomingGroupSyncJobQueue = [OWSIncomingGroupSyncJobQueue new];
        LaunchJobs *launchJobs = [LaunchJobs new];
        OWSSounds *sounds = [OWSSounds new];
        id<OWSProximityMonitoringManager> proximityMonitoringManager = [OWSProximityMonitoringManagerImpl new];
        MessageFetcherJob *messageFetcherJob = [MessageFetcherJob new];
        BulkProfileFetch *bulkProfileFetch = [BulkProfileFetch new];
        BulkUUIDLookup *bulkUUIDLookup = [BulkUUIDLookup new];
        id<VersionedProfiles> versionedProfiles = [VersionedProfilesImpl new];
        ModelReadCaches *modelReadCaches = [ModelReadCaches new];
        EarlyMessageManager *earlyMessageManager = [EarlyMessageManager new];
        OWSMessagePipelineSupervisor *messagePipelineSupervisor =
            [OWSMessagePipelineSupervisor createStandardSupervisor];
        AppExpiry *appExpiry = [AppExpiry new];
        BroadcastMediaMessageJobQueue *broadcastMediaMessageJobQueue = [BroadcastMediaMessageJobQueue new];
        MessageProcessor *messageProcessor = [MessageProcessor new];
        OWSOrphanDataCleaner *orphanDataCleaner = [OWSOrphanDataCleaner new];
        id<PaymentsHelper> paymentsHelper = [PaymentsHelperImpl new];
        id<PaymentsCurrencies> paymentsCurrencies = [PaymentsCurrenciesImpl new];
        SpamChallengeResolver *spamChallengeResolver = [SpamChallengeResolver new];
        AvatarBuilder *avatarBuilder = [AvatarBuilder new];
        PhoneNumberUtil *phoneNumberUtil = [PhoneNumberUtil new];
        
        [Environment setShared:[[Environment alloc] initWithIncomingContactSyncJobQueue:incomingContactSyncJobQueue
                                                              incomingGroupSyncJobQueue:incomingGroupSyncJobQueue
                                                                             launchJobs:launchJobs
                                                                            preferences:preferences
                                                             proximityMonitoringManager:proximityMonitoringManager
                                                                                 sounds:sounds
                                                          broadcastMediaMessageJobQueue:broadcastMediaMessageJobQueue
                                                                      orphanDataCleaner:orphanDataCleaner
                                                                          avatarBuilder:avatarBuilder]];

        [SSKEnvironment setShared:[[SSKEnvironment alloc] initWithContactsManager:contactsManager
                                                               linkPreviewManager:linkPreviewManager
                                                                    messageSender:messageSender
                                                            messageSenderJobQueue:messageSenderJobQueue
                                                           pendingReceiptRecorder:pendingReceiptRecorder
                                                                   profileManager:profileManager
                                                                   networkManager:networkManager
                                                                   messageManager:messageManager
                                                                  blockingManager:blockingManager
                                                                  identityManager:identityManager
                                                              remoteConfigManager:remoteConfigManager
                                                                     sessionStore:sessionStore
                                                                signedPreKeyStore:signedPreKeyStore
                                                                      preKeyStore:preKeyStore
                                                                        udManager:udManager
                                                                 messageDecrypter:messageDecrypter
                                                         groupsV2MessageProcessor:groupsV2MessageProcessor
                                                                    socketManager:socketManager
                                                                 tsAccountManager:tsAccountManager
                                                                    ows2FAManager:ows2FAManager
                                                          disappearingMessagesJob:disappearingMessagesJob
                                                                   receiptManager:receiptManager
                                                           outgoingReceiptManager:outgoingReceiptManager
                                                              reachabilityManager:reachabilityManager
                                                                      syncManager:syncManager
                                                                 typingIndicators:typingIndicators
                                                              attachmentDownloads:attachmentDownloads
                                                                   stickerManager:stickerManager
                                                                  databaseStorage:databaseStorage
                                                        signalServiceAddressCache:signalServiceAddressCache
                                                             accountServiceClient:accountServiceClient
                                                            storageServiceManager:storageServiceManager
                                                               storageCoordinator:storageCoordinator
                                                                   sskPreferences:sskPreferences
                                                                         groupsV2:groupsV2
                                                                   groupV2Updates:groupV2Updates
                                                                messageFetcherJob:messageFetcherJob
                                                                 bulkProfileFetch:bulkProfileFetch
                                                                   bulkUUIDLookup:bulkUUIDLookup
                                                                versionedProfiles:versionedProfiles
                                                                  modelReadCaches:modelReadCaches
                                                              earlyMessageManager:earlyMessageManager
                                                        messagePipelineSupervisor:messagePipelineSupervisor
                                                                        appExpiry:appExpiry
                                                                 messageProcessor:messageProcessor
                                                                   paymentsHelper:paymentsHelper
                                                               paymentsCurrencies:paymentsCurrencies
                                                                   paymentsEvents:paymentsEvents
                                                                 mobileCoinHelper:mobileCoinHelper
                                                            spamChallengeResolver:spamChallengeResolver
                                                                   senderKeyStore:senderKeyStore
                                                                  phoneNumberUtil:phoneNumberUtil
                                                                 webSocketFactory:webSocketFactory]];

        appSpecificSingletonBlock();

        OWSAssertDebug(SSKEnvironment.shared.isComplete);

        // Register renamed classes.
        [NSKeyedUnarchiver setClass:[OWSUserProfile class] forClassName:[OWSUserProfile collection]];
        [NSKeyedUnarchiver setClass:[ExperienceUpgrade class] forClassName:[ExperienceUpgrade collection]];
        [NSKeyedUnarchiver setClass:[ExperienceUpgrade class] forClassName:@"Signal.ExperienceUpgrade"];
        [NSKeyedUnarchiver setClass:[OWSGroupInfoRequestMessage class] forClassName:@"OWSSyncGroupsRequestMessage"];
        [NSKeyedUnarchiver setClass:[TSGroupModelV2 class] forClassName:@"TSGroupModelV2"];

        // Prevent device from sleeping during migrations.
        // This protects long migrations (e.g. the YDB-to-GRDB migration)
        // from the iOS 13 background crash.
        //
        // We can use any object.
        NSObject *sleepBlockObject = [NSObject new];
        [DeviceSleepManager.shared addBlockWithBlockObject:sleepBlockObject];

        dispatch_block_t completionBlock = ^{
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                if (AppSetup.shouldTruncateGrdbWal) {
                    // Try to truncate GRDB WAL before any readers or writers are
                    // active.
                    NSError *_Nullable error;
                    [databaseStorage.grdbStorage syncTruncatingCheckpointAndReturnError:&error];
                    if (error != nil) {
                        OWSFailDebug(@"Failed to truncate database: %@", error);

                        dispatch_async(dispatch_get_main_queue(), ^{ migrationCompletion(error); });
                    }
                }

                dispatch_async(dispatch_get_main_queue(), ^{
                    [storageCoordinator markStorageSetupAsComplete];

                    // Don't start database migrations until storage is ready.
                    [VersionMigrations performUpdateCheckWithCompletion:^() {
                        OWSAssertIsOnMainThread();

                        [DeviceSleepManager.shared removeBlockWithBlockObject:sleepBlockObject];

                        [SSKEnvironment.shared warmCaches];
                        migrationCompletion(nil);

                        OWSAssertDebug(backgroundTask);
                        backgroundTask = nil;
                    }];
                });
            });
        };

        completionBlock();
    });
}

+ (void)suppressUnsatisfiableConstraintLogging
{
    [[NSUserDefaults standardUserDefaults] setValue:@(SSKDebugFlags.internalLogging)
                                             forKey:@"_UIConstraintBasedLayoutLogUnsatisfiable"];
}

+ (BOOL)shouldTruncateGrdbWal
{
    if (!CurrentAppContext().isMainApp) {
        return NO;
    }
    if (CurrentAppContext().mainApplicationStateOnLaunch == UIApplicationStateBackground) {
        return NO;
    }
    return YES;
}

@end

NS_ASSUME_NONNULL_END

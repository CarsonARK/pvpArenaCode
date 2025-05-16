//
//  DataManager.h
//  PVPArena
//
//  Created by Carson Mobile on 6/15/24.
//

#ifndef DataManager_h
#define DataManager_h

struct PlayerData {
    //All of these from ClientGetPlayerAdministratorData
    std::string PlayerName;
    uint64_t PlayerID;
    bool isOnline;
    double OfflineTime;
    
    //All of these from DirectMessage data
    int Level;
    Vector3 CurrentLocation;
    bool isAccepting1v1Requests;
    
    //have players download their own ELO rating every kill & when they login, and so then they can post it in chat?
    float ELORating;
    int Kills;
    int Deaths;
    
    //If Time Added goes above 10, Remove from list
    std::chrono::steady_clock::time_point timeAdded;
};

// Times to post player data:
// Right after going into an arena, after teleporting to safe zone, after respawning, when spawning kit

// Other times data needs to be outgoing:
// when you get a kill, when you make a shop purchase, every 2 seconds to post player information,
// amber redeem token,
class OutgoingData {
public:
    static OutgoingData& getInstance(){
        static OutgoingData instance;
        return instance;
    }
    
    void SendServerMessage(std::string MessageString);
    void PostMyPlayerData();
    void RedeemSupportCode(std::string SupportCode);
    void ReportKill(uint64_t MurdererID, uint64_t VictimID, std::string MurdererName, std::string VicitmName);
    void PurchaseShopItem(std::string Item);
    void SyncShopPurchases();
    void DownloadShopPurchases();
    void RequestPlayerStats();
    
    
    
    
    
    // ServerChat ArenaData:DuelData:DuelAccept:<DuelID>:<Timestamp>:<DuelSenderPlayerID>:<DuelAccepterPlayerID>:<DuelAccepterTribeID>:<ArenaID>
    void AcceptDuelRequest(std::string DuelID, uint64_t DuelSenderPlayerID, uint64_t DuelAccepterPlayerID, uint64_t DuelAccepterTribeID, std::string ArenaID);
    void DeclineDuelRequest(std::string DuelID, std::string Reason);
    void CancelDuelRequest(std::string DuelID, std::string Reason, uint64_t RecipientPlayerID, uint64_t MyPlayerID);
    void SendDuelFinished(uint64_t MyPlayerID, uint64_t EnemyPlayerID, std::string ArenaName);
    void InitiateDuelRequest(std::string DuelIdentifier, long long TimestampMS, uint64_t SenderPlayerID, uint64_t SenderTribeID, std::string SenderPlayerName, int SenderLevel, float SenderELO, uint64_t toPlayerID, std::string ArenaType, uint8_t kitType, std::string CustomMessage, long long ExpirationMS);
                           // ArenaData:DuelData:DuelCanceled:<DuelID>:<Reason>:<RecipientPlayerID>:<YourPlayerID>
    
    // void 1v1Request
};

class IncomingData {
public:
    static IncomingData& getInstance(){
        static IncomingData instance;
        return instance;
    }
    
    bool HandleIncomingData (std::string IncomingString);
    void HandleIncomingPlayerListData (NSArray* Parts);
    
    void HandleIncomingDuelCompleted (NSArray* Parts);
    void HandleIncomingDuelAccepted(NSArray* Parts);
    void HandleIncomingDuelInitiated(NSArray* Parts);
    void HandleIncomingDuelDeclined(NSArray* Parts);
    void HandleIncomingDuelCanceled(NSArray* Parts);
    
    void SendClientMessage(std::string Message);
    
    /*
     ServerChat ArenaData:DuelData:DuelAccept:<DuelID>:<Timestamp>:<DuelSenderPlayerID>:<DuelAccepterPlayerID>:<DuelAccepterTribeID>:<ArenaID>
     ServerChat ArenaData:DuelData:DuelInitiate:<DuelID>:<Timestamp>:<SenderPlayerID>:<SenderTribeID>:<SenderPlayerName>:<SenderLevel>:<SenderELO>:<RecievingPlayerID>:<ArenaType>:<KitType>:<CustomMessage>:<ExpirationTime>
     ArenaData:DuelData:DuelDecline:<DuelID>:<Reason>
     ArenaData:DuelData:DuelCanceled:<DuelID>:<Reason>:<RecipientPlayerID>:<YourPlayerID>
     */
};

class PlayerList {
public:
    static PlayerList& getInstance(){
        static PlayerList instance;
        return instance;
    }
    
    //Call this about every 2 seconds. If a player's timer is above x seconds, then remove them from the list.
    void RemovalCheck();
    PlayerData& DataForID(uint64_t PlayerID);
    void DrawGuiTemp();
    
    void DrawListTemp(std::vector<PlayerData>& data);
    
    std::vector<PlayerData> GetPlayersInArena(std::string ArenaName);
    std::vector<PlayerData> GetPlayersInSafeZone();
    std::vector<PlayerData> GetValid1v1Players();
    
    
    
    std::vector<PlayerData> Players;
    static const int64_t REMOVAL_TIME = 5;
    
};


class PlayerStats {
public:
    
    static PlayerStats& getInstance(){
        static PlayerStats instance;
        return instance;
    }
    
    
    void Initialize();
    void Update();
    void DownloadStats();
    
    uint64_t GetPlayerID();
    uint64_t GetTribeID();
    int GetPlayerLevel();
    std::string GetPlayerName();
    
    //Timer
    std::chrono::steady_clock::time_point lastDownloadedStats;
    static const int64_t DOWNLOAD_COOLDOWN = 30;
    
    float ELO;
    int Kills;
    int Deaths;
    int CurrentKillStreak;

};

#endif /* DataManager_h */

//
//  ArenaManager.h
//  PVPArena
//
//  Created by Carson Mobile on 6/15/24.
//
#ifndef ArenaManager_h
#define ArenaManager_h



class Arena {
public:
    
    
    
    //Make Sure to spawn the arena while facing 0, 90, 180, or 360 degree angle, or else the bounds wont work properly.
    Vector3 BoundsNegativeCorner;
    Vector3 BoundsPositiveCorner;
    
    //Set the spawn Height above any potential meshes to avoid players being spawned in the mesh.
    float SpawnHeight;
    
    //These are the bounds that players can spawn in, they should be smaller than the teleportation bounds
    Vector3 SpawnNegativeCorner;
    Vector3 SpawnPositiveCorner;
    
    //Each arena needs an onEnter (so you can like for example clear inventory & get Fabi kit
    std::function<void()> onEntrance;
    std::string ArenaName;
    bool SpawnGrapplesOnKill;
    bool autoSpawnKit; 
    
    bool isPlayerInsideArena();
    void RandomTeleport();
    void Initialize(Vector3 inBoundsNegativeCorner,
                    Vector3 inBoundsPositiveCorner,
                    float inSpawnHeight,
                    Vector3 inSpawnNegativeCorner,
                    Vector3 inSpawnPositiveCorner,
                    std::string inArenaName,
                    bool inSpawnGrapplesOnKill,
                    bool inAutoSpawnKit,
                    std::function<void()> inonEntrance
                    );
    void DrawBounds(); //Draw the Bounds on the screen
    bool isLocationInsideArena(Vector3 Location);
};

enum EKitType : uint8_t {
    EKitType_Mele = 0, //Pan, Tek, Bola, Grapples, Sword, Tek Armor, beer, antidote
    EKitType_Rockets = 1, //80 Rockets, 8 Launchers, 4 Tek Sets, Consumables, 5 beer, 5 antidotes
    EKitType_Standard = 2, //15 Bolas, 15 Grapples, Comp, Fabi, 2 tek sets, consumables,
    EKitType_Aids = 3, //Pan, 40 Bolas, 40 Grapples, Frog Feet, 2 Tek Sets, Aerial Symbiote, Comp, Fabi, cutlass, shocking darts
    EKitType_CompoundBow = 4, //Comp, 200 metal arrows, 2 Riot Sets, consumables
    EKitType_FabSniper = 5, //4 fabis, 2 tek sets, attachments, bullets, consumables
    EKitType_AssaultRifle = 6, //Assault rifle & one set of tek & consumables
    EKitType_Shotgun = 7, //fab shotgun and prim flak and consumables
    EKitType_Club = 8, //Flak, Sword, Club, Consumables
    EKitType_Darts = 9, //Shocking Tranq Darts, Prim Flak, Sword, 4 longnecks, Consumables
    EKitType_MAX = 10
};

/*
 Additional:
    2 Spawning Locations

 Might want like a CurrentDuel class? not sure
 */
class DuelArena : public Arena {
public:
    bool ActiveFight;
    
    uint64_t myPlayerID;
    uint64_t myTribeID;
    
    uint64_t enemyPlayerID;
    uint64_t enemyTribeID;
    
    bool didIInitiate;

    EKitType currentKitType;
    
    Vector3 InitatorSpawnLocation;
    Vector3 AccepterSpawnLocation;
    
    bool isArgyDuel;
    
    void InitializeArena(Vector3 inInitatorSpawnLocation, Vector3 inAccepterSpawnLocation);
    bool isDuelArenaAvailable();
    void SetArenaOccupied();
    void SetArenaOpen();
    void StartFight(uint64_t inmyPlayerID, uint64_t inmyTribeID, uint64_t inenemyPlayerID, uint64_t inenemyTribeID, bool indidIInitiate, EKitType incurrentKitType);
    
    //Send the message to the server that the arena is open. Only the winnner of the fight sends this.
    void EndFight();
    
    //Every 1.5 seconds, kills any players that arent you or your opponent who might be alive in arena
    void RemoveOtherPlayers();
    
    void OnEnterArena();
};


class DefaultKits {
public:
    
    static DefaultKits& getInstance() {
        static DefaultKits instance;
        return instance;
    }
    //Base Components
    void SpawnFlakSet(int numSets = 1);
    void SpawnRiotSet(int numSets = 1);
    void SpawnTekSet(int numSets = 1);
    void SpawnPan();
    void SpawnClub();
    void SpawnSword();
    void SpawnCutlass();
    void SpawnCrossbow();
    void SpawnGrapples(int Ammount = 1);
    void SpawnBolas(int Ammount = 1);
    void SpawnLauncherAndRockets(int LauncherCount = 1);
    void SpawnBeer();
    void SpawnSniper(int Ammount = 1);
    void SpawnSniperAmmo(int Stacks = 1);
    void SpawnComp();
    void SpawnMetalArrows(int Stacks = 1);
    void SpawnSniperAttachments(int numSets = 1);
    void SpawnLongneck(int Amount = 1);
    void SpawnShockingTranqs(int Stacks = 1);
    void SpawnShotgun();
    void SpawnShotgunAmmo(int Stacks = 1);
    void SpawnAR(int Stacks = 1);
    void SpawnARB(int Stacks = 1);
    void SpawnHoloScope(int Stacks = 1);
    void SpawnArketypes(int Stacks = 1);
    

    
    
    //Defaults
    void SpawnDefaultConsumables();
    void SpawnDefaultArmor();
    
    //Arena Kits
    void SpawnCompKit();
    void SpawnFabiKit();
    void SpawnRocketKit();
    void SpawnGrapplesKit();
    void SpawnMeleKit();
    
    void SpawnKitOfType(EKitType type); 
};

class ArenaManager {
public:
    static ArenaManager& getInstance() {
        static ArenaManager instance;
        return instance;
    }
    
    void InitializeArenas();
    bool isPlayerInsideArena(std::string ArenaName);
    bool isPlayerInsideAnArena();
    void EnterArena(std::string ArenaName);
    Arena& GetCurrentFFAArena();
    DuelArena& GetCurrentDuelArena();
    Arena& ArenaForString(std::string ArenaName);
    
    bool isPlayerInsideDuelArena();
    bool isPlayerInsideFFAArena();
    
    //any player in argy arena is in both a duel arena and the argy arena
    bool isPlayerInsideArgyArena();
    
    void InitializeDuelAreans();
    std::string GetAvailableDuelArena(std::string ArenaType);
    DuelArena& DuelArenaForString(std::string arenaName);
    
    
    
    //All Kits, Comp, Fabi
    std::vector<Arena> FFA_Arenas;
    
    //1v1 Kits (Starting: Rockets, Fabi, All (also spawn player some bolas and grapples), Comp, Regular Kit, Mele Bob
    
    //each vector contains an array of a certain type of Duel Arena
    std::vector< std::vector<DuelArena> > Duel_Arenas;
    
};

/*
 1v1 Arena ID
 
 Duel_Doed_0
 Duel_Doed_1
 Duel_Doed_2
 
 */



/*
 Outside the map, away from killzones, you spawn on the ground. This gives you time to equip your kit
 
 West of the Map
 Latitude is Y Axis
 Longtiude is X Axis
 Latitude is
 Longtiude: -25 (-6455504) to Longitude: (-72) (-1017451)
 Latitude is 154 (830767) to about 90 (332446)
 Z is -45860
 
 Minimum Z is -100 000
 Maximum Z is 0
 
 SafeZone::getInstance().RandomTeleport();
 */
class SafeZone {
public:
    static SafeZone& getInstance() {
        static SafeZone instance;
        return instance;
    }
    
    //Set the spawn Height above any potential meshes to avoid players being spawned in the mesh.
    float SpawnHeight;
    
    //These are the bounds that players can spawn in, they should be smaller than the teleportation bounds
    Vector3 SpawnNegativeCorner;
    Vector3 SpawnPositiveCorner;
    
    void Initialize();
    void RandomTeleport();
    bool isPlayerInsideSafeZone();
    bool isLocationInsideSafeZone(Vector3 Location);
    
    
    void ApplyPVPCooldown();
    bool canReturnToSafeZone();
    void ReturnToSafeZone();
    int GetSafeZoneSecondsRemaining();
    
    //FunctionCalls::getInstance().SendAnnouncement("")
    
    std::chrono::steady_clock::time_point lastHit;
    static const int64_t TELEPORTATION_COOLDOWN = 60;
};

#endif /* ArenaManager_h */

//ServerChat ArenaData:DuelData:DuelInitiate:<DuelID>:<Timestamp>:<SenderPlayerID>:<SenderPlayerName>:<SenderLevel>:<SenderELO>:<RecievingPlayerID>:<ArenaType>:<KitType>:<CustomMessage>:<ExpirationTime>
class DuelRequest {
public:
    std::string DuelID;
    EKitType kitType;
    std::string ArenaType;
    uint64_t ChallengerPlayerID;
    std::string ChallengerPlayerName;
    int ChallengerLevel;
    float ChallengerELO;
    std::chrono::steady_clock::time_point timeSent;
    std::chrono::steady_clock::time_point timeExpires;
    std::string CustomMessage;
    
    bool CheckExpired();
    int GetTimeRemaining();
    
};

class OutgoingDuel {
public:
    bool isValid;
    std::string DuelID;
    std::string toPlayerName;
    std::string CustomMessage;
    uint64_t toPlayerID;
    EKitType kitType;
    std::string ArenaType;
    std::chrono::steady_clock::time_point timeSent;
    std::chrono::steady_clock::time_point timeExpires;
    
    OutgoingDuel(){
        isValid = false;
    }
};

/*
 Format:
    NSString* PlayerID
        NSString* PlayerName
        bool isIngored;
*/
class IgnoredPlayer {
public:
    
    uint64_t PlayerID;
    std::string PlayerName;
    bool isIgnored;
    
    IgnoredPlayer(uint64_t inPlayerID, std::string inPlayerName, bool inIsIgnored) : PlayerID(inPlayerID), PlayerName(inPlayerName), isIgnored(inIsIgnored) {}
    
    void SaveToPlist();
    void RemoveFromPlist();
    
    static NSString* GetSavePath();
    
};

class DuelManager {
public:
    
    static DuelManager& getInstance(){
        static DuelManager instance;
        return instance;
    }
    
    //Every about 1.5 Seconds
    void CheckForExpiration();
    
    // ServerChat ArenaData:DuelData:DuelInitiate:<DuelID>:<Timestamp>:<SenderPlayerID>:<SenderTribeID>:<SenderPlayerName>:<SenderLevel>:<SenderELO>:<RecievingPlayerID>:<ArenaType>:<KitType>:<CustomMessage>:<ExpirationTime>
    void CreateIncomingRequest(std::string DuelID, std::chrono::steady_clock::time_point TimeSent, uint64_t SenderPlayerID, uint64_t SenderTribeID, std::string SenderPlayerName, int SenderLevel, float SenderELO, EKitType KitType, std::string ArenaType, std::string CustomMessage, std::chrono::steady_clock::time_point TimeExpires);
    void CheckForDoubleDuel(uint64_t SenderID);
    
    bool hasDuelRequest(std::string requestID);
    bool hasDuelRequestFromPlayer(uint64_t playerID);
    
    //This means the person who challenged you canceled the duel, no need to send any server messages
    void cancelDuelRequest(std::string requestID, std::string Reason = " ");
    void cancelDuelRequestFromPlayer(uint64_t playerID, std::string Reason = " ");
    
    DuelRequest& getForID(std::string requestID);
    void DeclineDuelRequest(std::string requestID);
    void AcceptDuelRequest(std::string requestID);
    
    
    
    void SaveIgnoredPlayersList();
    void LoadIgnoredPlayersList();
    void IgnorePlayer(uint64_t PlayerID, std::string PlayerName);
    void unIgnorePlayer(uint64_t PlayerID);
    IgnoredPlayer& getForPlayerID(uint64_t PlayerID);
    bool isPlayerIgnored(uint64_t playerID);
    
    /*
     class OutgoingDuel {
     public:
         bool isValid;
         std::string DuelID;
         std::string toPlayerName;
         std::string CustomMessage;
         uint64_t toPlayerID;
         EKitType kitType;
         std::chrono::steady_clock::time_point timeSent;
         std::chrono::steady_clock::time_point timeExpires;
     };
     */
    void SendDuelRequest(std::string toPlayerName, std::string CustomMessage, uint64_t toPlayerID, EKitType kitType, std::string ArenaType, int RequestDuration);
    
    std::vector<IgnoredPlayer> IgnoredPlayers;
    std::vector<DuelRequest> IncomingRequests;
    OutgoingDuel sentDuel;
    
    void CheckShouldCancelOutgoingDuel();
    void CancelOutgoingDuelRequest();
    
};

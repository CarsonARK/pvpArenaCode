//
//  Hooks.m
//  ArkTestingDylib
//
//  Created by Carson Mobile on 11/29/23.
//

#import <Foundation/Foundation.h>
#include "../Includes.h"

void HookRegistration::RegisterForObject(UObject *Actor, uint64_t VTableAddress, uint64_t HookFunction){
    if(Actor->IsValid()){
        UObject* ActorVTable = (UObject*)Actor->VTable;
        if(ActorVTable->IsValid()){
            if(Read<uint64_t>((uint64_t)ActorVTable + VTableAddress) == HookFunction) return;
            
            MyFunction = HookFunction;
            HookAddress = (uint64_t)ActorVTable + VTableAddress;
            OriginalGameFunction = *(uint64_t*)(HookAddress);
            
            *(uint64_t*)(HookAddress) = MyFunction;
        }
    }
}
void HookRegistration::Register(){
    if(HookAddress && MyFunction){
        *(uint64_t*)(HookAddress) = MyFunction;
    }
}
void HookRegistration::Unregister(){
    if(HookAddress && OriginalGameFunction){
        *(uint64_t*)(HookAddress) = OriginalGameFunction;
    }
}
bool HookRegistration::isHooked(){
    return (HookAddress && OriginalGameFunction && MyFunction);
}




/*
 void ServerRequestMultiLevelUp(struct UPrimalCharacterStatusComponent* forStatusComp, struct TArray<int> LevelUpValues);
 void ServerRequestLevelUp(struct UPrimalCharacterStatusComponent* forStatusComp, enum class EPrimalCharacterStatusValue ValueType);
 
 // Object Name: Enum ShooterGame.EPrimalCharacterStatusValue
 enum class EPrimalCharacterStatusValue : uint8 {
     Health = 0,
     Stamina = 1,
     Torpidity = 2,
     Oxygen = 3,
     Food = 4,
     Water = 5,
     Temperature = 6,
     Weight = 7,
     MeleeDamageMultiplier = 8,
     SpeedMultiplier = 9,
     TemperatureFortitude = 10,
     CraftingSpeedMultiplier = 11,
     MAX = 12,
     EPrimalCharacterStatusValue_MAX = 13
 };
 
 ServerCraftItem
 */


static void ControllerProcessEvent(APlayerController* Controller, UFunction* CalledFunction, void* Params){
    std::string FunctionName = CalledFunction->GetObjectName();
    if(FunctionName == "ReceiveTick"){
        
        KeyboardManager::getInstance().UpdateGame();
        //Automaticaly Go Into Admin instead of needing a button press
        if(!MenuLoop::getInstance().isAdmin){
            FunctionCalls::getInstance().ActivateAdmin(MenuLoop::getInstance().ServerAdminPassword);
        }
        
        //If the player is outside the Safe Zone, Outside the Arena, and loaded into the server
        //This will teleport them into the safe zone.
        if(!ArenaManager::getInstance().isPlayerInsideAnArena() && !SafeZone::getInstance().isPlayerInsideSafeZone() && QuickOffsets::isServerLoaded()){
            SafeZone::getInstance().RandomTeleport();
        }
        
        //Execute the Function Queue
        FunctionQueue::GetI().ExecuteQueue();
    }
    else if(FunctionName == "ClientNotifyAdmin"){
        MenuLoop::getInstance().isAdmin = YES;
        return;
    }
    
    //Handle When you kill another player for ELO
    else if(FunctionName == "ClientNotifyPlayerKill" || FunctionName == "ClientNotifyDinoKill"){
        
        AShooterCharacter* MyPawn = Read<AShooterCharacter*>((uint64_t)Params);
        AShooterCharacter* VictimPawn = Read<AShooterCharacter*>((uint64_t)Params + 0x8);
        
        if(VictimPawn->isA_Safe(StaticClass::ShooterCharacter()) && (MyPawn->isA_Safe(StaticClass::ShooterCharacter()) || MyPawn->isA_Safe(StaticClass::PrimalDinoCharacter()))){
            
            
            //Don't want people farming kills outside the arena
            
            if(ArenaManager::getInstance().isPlayerInsideArgyArena()){
                APrimalDinoCharacter* MountedDino = QuickOffsets::GetMountedDino();
                if(MountedDino->isA_Safe(StaticClass::PrimalDinoCharacter())){
                    
                    //Kill the dino you are riding when you kill the other player
                    Controller->ServerMultiUse(MountedDino, 124, -1, 1, 1);
                    Controller->ServerMultiUse(MountedDino, 189, -1, 1, 1);
                }
            }
            
            if(ArenaManager::getInstance().isPlayerInsideFFAArena()){
                Utils::getInstance().HealAll();
                Utils::getInstance().GiveKillExp(33);
                Utils::getInstance().GiveAmber(5);
                
                if(Variables.grappleRewards && ArenaManager::getInstance().GetCurrentFFAArena().SpawnGrapplesOnKill){
                    int CrossbowSpawnAmmount = 2 - Utils::getInstance().GetInventoryItemQuantity("PrimalItem_WeaponCrossbow_C");
                    int GrapplingHookSpawnAmmount = 6 - Utils::getInstance().GetInventoryItemQuantity("PrimalItemAmmo_GrapplingHook_C");
                    int BolaSpawnAmmount = 6 - Utils::getInstance().GetInventoryItemQuantity("PrimalItem_WeaponBola_C");
                    
                    Utils::getInstance().HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Weapons/PrimalItemAmmo_GrapplingHook.PrimalItemAmmo_GrapplingHook_C'", GrapplingHookSpawnAmmount, 1);
                    Utils::getInstance().HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Weapons/PrimalItem_WeaponBola.PrimalItem_WeaponBola_C'", BolaSpawnAmmount, 1);
                    Utils::getInstance().HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Weapons/PrimalItem_WeaponCrossbow.PrimalItem_WeaponCrossbow_C'", CrossbowSpawnAmmount, 1);
                }
            }
            else if(ArenaManager::getInstance().isPlayerInsideDuelArena())
            {
                ArenaManager::getInstance().GetCurrentDuelArena().EndFight();
                Utils::getInstance().GiveKillExp(33);
                Utils::getInstance().GiveAmber(5);
            }
            
            
            //Get the data
            uint64_t EnemyPlayerID = VictimPawn->GetLinkedPlayerDataID();
            uint64_t MyPlayerID = QuickOffsets::GetShooterCharacter()->GetLinkedPlayerDataID();
            std::string EnemyPlayerName = VictimPawn->GetPlayerName()->iosToString();
            std::string MyPlayerName = QuickOffsets::GetShooterCharacter()->GetPlayerName()->iosToString();
            
            //Report it to the server
            OutgoingData::getInstance().ReportKill(MyPlayerID, EnemyPlayerID, MyPlayerName, EnemyPlayerName);
            
            //Now Send the Death Announcement
            std::string deathMessage = string_format("%s was killed by %s", EnemyPlayerName.c_str(), MyPlayerName.c_str());
            
            //Convert the std::string into a wide string
            std::wstring WdeathMessage = std::wstring_convert<std::codecvt_utf8_utf16<wchar_t>>().from_bytes(deathMessage);
            
            //Convert wString to FString
            FString DeathMessageFString = FString(WdeathMessage.c_str());
            
            Controller->ServerSendAnnouncement(DeathMessageFString, 1);

        }
    }
    
    //No Free Gifts
    else if(FunctionName == "ReceiveBonusGift"){
        return;
    }
    else if(FunctionName == "ServerPlayerGiftTimeout"){
        return;
    }
    
    //No Primal Pass
    else if(FunctionName == "ServerEnterPromoCode"){
        std::string PromoString = ((FString*)Params)->iosToString();
        Utils::getInstance().ShowError(StringToNSString(PromoString));
        return;
    }
    
    //No placing structures or anything
    else if(FunctionName == "ServerRequestPlaceStructure"){
        return;
    }
    
    //Removes a ban from doing stuff
    else if(FunctionName == "ServerSendBadPlayer"){
        return;
    }
    //Don't want people somehow managing to pickup any notes.
    else if(FunctionName == "ServerUnlockPerMapExplorerNote"){
        return;
    }
    else if(FunctionName == "ServerChatLogin"){
        OutgoingData::getInstance().PostMyPlayerData();
        //Send Server Data 
        
        //Utils::getInstance().ShowError(@"I should probably send character data right about now.");
    }
    
    
    
    //uncomment these to disable ingame Purchases, if it becomes an issue.
    // They are currently commented because as I am going to use TEK armor, I don't want people to be able to buy element :)
    /*
    else if(FunctionName == "ServerCreatePremiumItem"){
        return;
    }
    else if(FunctionName == "PerformAmberPurchase"){
        return;
    }
     */
    
    //Stops people from getting into Admin by themselves
    else if(FunctionName == "CheckCheatsPassword"){
        return;
    }
    else if(FunctionName == "ServerMultiUse")
    {
        
        /*
         Multiuse ->
            800 = Invite to Tribe
            890 = Invite to Alliance
            880 = Join Alliance
            802 = Accept Invite
            100 = Pickup Item & Mount Dino
         */
        auto p = (ServerMultiUse_Params*)Params;
        
        //since 100 is pickup item cache and mount dino, and we want to be able to mount dino, only cancel 100 for non dinos
        if(p->UseIndex == 800 || p->UseIndex == 802 || (p->UseIndex == 100 && !p->ForObject->isA_Safe(StaticClass::PrimalDinoCharacter()))) return;
    }
    else if(FunctionName == "ClientReceiveChatMessage"){
        
        EChatMessageType messageType = Read<EChatMessageType>((uint64_t)Params + 0x0d);
        
        //Hide Kill Messages
        if(messageType == Announcement && !Variables.showKillMessages){
            return;
        }
        //Hide Notifications like Giving EXP and Healing and shit
        else if (messageType == Notification){
            return;
        }
    }
    
    // PC
    //3168:     void ClientServerChatMessage(const class FString& MessageText, const struct FLinearColor& MessageColor, bool bIsBold);
    
    else if(FunctionName == "ClientServerChatDirectMessage"){
        FString Message = Read<FString>((uint64_t)Params);
        if(Message.Num() > 5){
            std::string MessageString = Message.iosToString();
            if(IncomingData::getInstance().HandleIncomingData(MessageString)){
                return;
            }
        }
    }
    
    
    /*
     Stop player from viewing remote inventory while in a Duel Arena to stop them looting shit
     
     ServerRequestRemoteDropAllItems
     ServerDropFromRemoteInventory
     ServerDropFromRemoteInventoryQuantity
     ServerActorViewRemoteInventory
     ServerTransferFromRemoteInventory
     ServerTransferToRemoteInventory
     ServerTransferAllToRemoteInventory
     ServerTransferAllFromRemoteInventory
     
     */
    else if(FunctionName == "ServerTransferAllFromRemoteInventory"){
        if(ArenaManager::getInstance().isPlayerInsideDuelArena()){
            return;
        }
    }
    else if(FunctionName == "ServerTransferFromRemoteInventory"){
        if(ArenaManager::getInstance().isPlayerInsideDuelArena()){
            return;
        }
    }
    else if(FunctionName == "ServerActorViewRemoteInventory"){
        if(ArenaManager::getInstance().isPlayerInsideDuelArena()){
            return;
        }
    }
    else if(FunctionName == "ServerTransferAllStacks"){
        if(ArenaManager::getInstance().isPlayerInsideDuelArena()){
            return;
        }
    }
    
    else if(FunctionName == "ServerTeleportToPlayerLocation"){
        return;
    }
    else if(FunctionName == "ServerSendAnnouncement"){
        return;
    }
    else if(FunctionName == "ServerBanTribe"){
        return;
    }
    else if(FunctionName == "ServerBanPlayer"){
        return;
    }
    else if(FunctionName == "ServerAdminMutePlayer"){
        return;
    }
    else if(FunctionName == "ServerAdminManConsoleCommand"){
        return;
    }
    else if(FunctionName == "ServerKickPlayer"){
        return;
    }
    else if(FunctionName == "ServerGodConsoleCommand"){
        return;
    }
    else if(FunctionName == "ServerGodConsoleCommandThree"){
        return;
    }
    else if(FunctionName == "ServerGodConsoleCommandTwo"){
        return;
    }
    else if(FunctionName == "ServerCraftItem"){
        return;
    }
    //void ServerSendChatMessage(enum class EChatChannel ChatChannel, enum class EChatMessageType messageType, struct FString ChatMessage, struct FServerText ServerText);
    else if(FunctionName == "ServerSendChatMessage"){
        
        auto p = (ServerSendChatMessage_Params*)Params;
        if(p->ChatMessage.Num() > 40){
            std::string MessageString = p->ChatMessage.iosToString();
            std::vector<std::string> strings = splitString(MessageString, 40);
            
            for(std::string& currString : strings){
                Controller->SendChatMessage(p->ChatChannel, p->messageType, currString);
            }
            return;
        }
        //Controller->SendChatMessage(p->ChatChannel, p->messageType, p->ChatMessage.iosToString());
        
        /*int messageLength = p->ChatMessage.Num();
        if(messageLength > 40){
            std::string ChatMessageString = p->ChatMessage.iosToString();
            int Partitions = (messageLength + 39 / 40);
            for(int i = 0; i < Partitions; ++i){
                int start = i * 40;
                int length = std::min(40, messageLength - start);
                std::string newString = ChatMessageString.substr(start, length);
                std::wstring WChatString = std::wstring_convert<std::codecvt_utf8_utf16<wchar_t>>().from_bytes(newString);
                FString ChatFString = FString(WChatString.c_str());
                p->ChatMessage = ChatFString;
                reinterpret_cast<void(__fastcall*)(AController*, UFunction*, void*)>(reinterpret_cast<void*>(GameHooks::ControllerHook.GetOriginalFunctionAddress()))(Controller, CalledFunction, Params);
            }
            return;
        }*/
    }
    //ServerTransferAllStacks

    

    reinterpret_cast<void(__fastcall*)(AController*, UFunction*, void*)>(reinterpret_cast<void*>(GameHooks::ControllerHook.GetOriginalFunctionAddress()))(Controller, CalledFunction, Params);
}
/*
 i made this new feature that will automatically split messages to make typing in chat easier
 Chat Length:
 abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz
 abcdefghijklmnopqrstuvwxyzabcdefghijklmn
 
    Length: 40
 
 Chat Filter:
 
 */
/**
 Functions To Hook:
 
 SPC:
 void ClientNotifyAdmin(bool bWithAdmin, bool bShowAdminManager);
 void ClientNotifyPlayerKill(struct AActor* PlayerPawn, struct APawn* VictimPawn);
 
 ShooterPlayerController:

 void ServerKickPlayer(int64_t LinkedID);
 void ServerGodConsoleCommand(enum class EGameCheat cheatType, float ExtraData, float ExtraDataTwo, float ExtraDataThree);
 void ServerGodConsoleCommandThree(enum class EGiveItem ItemToGive, bool MaxStack);
 void ServerEnterPromoCode(struct FString promoCode, bool forSinglePlayer, uint32_t deviceToken);
 void ServerGodConsoleCommandTwo(enum class EGameCheat cheatType, struct APrimalCharacter* aimedChar);
 
 ShooterPlayerState:
 ServerGetPlayerAdministratorData
 void ServerGetPlayerConnectedData(struct FString withNameFilter);
 void ServerGetPlayerBannedData();
 void ServerGetNextPlayerConnectedData(int FromIndex);
 void ServerGetAllPlayerNamesAndLocations();
 void ServerGetAlivePlayerConnectedData();
 
 Controller:
 ServerRequestPlaceStructure (Cancel Completely)
 ServerCreatePremiumItem (Cancel)
 PerformAmberPurchase (Cancel)
 
 To become Admin:
 void CheckCheatsPassword(struct FString pass);
 
 To Spawn Items:
 
 To Teleport:
 
 
 
 
 */

/*
 Spawn Hook
 Teleport Randomly Outside the Map Bounds
 Movment Speed Hook
 if not in arena, then make speed like 0.05
 */
/*
 UObject* Character = gameUtils.GetMyCharacter();
 if(utils.isValidAdress(Character)){
     UObject* VTable = utils.Read<UObject*>(Character);
     if(utils.isValidAdress(VTable)){
         utils.Write<long>(VTable + 0xea8, (long)Hook_PlaySpawnIntro);
     }
 }
 
 UObject* Movement = utils.Read<UObject*>(gameUtils.GetMyCharacter() + 0x640);
 if(utils.isValidAdress(Movement)){
     UObject* VTable = utils.Read<UObject*>(Movement);
     if(utils.isValidAdress(VTable)){
         utils.Write<long>(VTable + 0xa90, (long)Hook_ReplicateMoveToServer);
     }
 }
 */

static void CharacterProcessEvent(AShooterCharacter* Character, UFunction* CalledFunction, void* Params){
    std::string FunctionName = CalledFunction->GetObjectName();

    if(FunctionName == "PlayHitEffectPoint")
    {
        AActor* WeakActor = ReadWeakPointer<AActor*>((uint64_t)Params + 0x9c);
        AShooterCharacter* MyCharacter = QuickOffsets::GetShooterCharacter();
        if(WeakActor == MyCharacter){
            SafeZone::getInstance().ApplyPVPCooldown();
        }
    }
    
    reinterpret_cast<void(__fastcall*)(AShooterCharacter*, UFunction*, void*)>(reinterpret_cast<void*>(GameHooks::CharacterHook.GetOriginalFunctionAddress()))(Character, CalledFunction, Params);
}


/*
 
 FAliveNameAndLocation -> name, Tribe name, Team, PlayerID, Location (not sure about online status)
    Receiving It:
        void ClientGetAllPlayerNamesAndLocations(struct TArray<struct FAliveNameAndLocation> list);
        
    
 FAdminPlayerDataInfo -> has name, ID, is admin, online, offline timer (potentitally have it so that if someone is offline for too long, say offline for over an hour, they are killed
     Receiving It:
         void ClientGetPlayerConnectedData(struct TArray<struct FAdminPlayerDataInfo> list, int TotalConnectedPlayers);
         or
         void ClientGetPlayerAdministratorData(struct TArray<struct FAdminPlayerDataInfo> list);
 
 Server:
     ServerGetPlayerAdministratorData
     ServerGetAllPlayerNamesAndLocations
     ServerGetAlivePlayerConnectedData
 
 //void ServerGetPlayerAdministratorData();-> ClientGetPlayerAdministratorData
 //void ServerGetAllPlayerNamesAndLocations(); -> Only works if you EnableSpectator call it then disableSpectator ig. That makes you die.
 //void ServerGetAlivePlayerConnectedData(); -> PlayerList (but hook didn't get called)
 */


struct FAliveNameAndLocation {
    // Fields
    FString PlayerName; // Offset: 0x00 // Size: 0x10
    FString TribeName; // Offset: 0x10 // Size: 0x10
    uint32_t TargetingTeam; // Offset: 0x20 // Size: 0x04
    char pad_0x24[0x4]; // Offset: 0x24 // Size: 0x04
    uint64_t PlayerId; // Offset: 0x28 // Size: 0x08
    Vector3 Location; // Offset: 0x30 // Size: 0x0c
    char pad_0x3C[0x4]; // Offset: 0x3c // Size: 0x04
};
/*
 Alternative Ideas For Player List:
    1. Construct baisc list from
 */

// Size: 0x48 // Inherited bytes: 0x00


/*
 Functions that might be useful for official
 
 ClientPursuitComplete
 Hook the primal code shit for amber
 
 
 UStoreEntry_Item? Try to modify the amber shop ammounts and $ ammounts to my shop, and then when u click them it goes to my website
 
 
 Arketypes: if you put a turret into a vase, then you are given an eerie turret on completion.
 1. Send a server notificaiton to urself, when u get it back...
 void ClientRemoveActorItem(struct UPrimalInventoryComponent* forInventory, struct FItemNetID itemID, bool ShowHUDNotification);?
 void ClientInsertActorItem(struct UPrimalInventoryComponent* forInventory, struct FItemNetInfo itemInfo, struct FItemNetID InsertAfterItemID);
 void ClientAddActorItem(struct UPrimalInventoryComponent* forInventory, struct FItemNetInfo itemInfo, bool bEquipItem, bool ShowHUDNotification);
 */
static void PlayerStateProcessEvent(AShooterPlayerState* State, UFunction* CalledFunction, void* Params){
    std::string FunctionName = CalledFunction->GetObjectName();
    
    //Called from ServerGetAllPlayerNamesAndLocations
    //Only works in Spectator mode
    //As of yet unsure if this could be useful or not.
    //It does get the correct coordinates 
    if(FunctionName == "ClientGetAllPlayerNamesAndLocations")
    {
        TArray<FAliveNameAndLocation> Locations = Read<TArray<FAliveNameAndLocation>>((uint64_t)Params);
        for(int i = 0 ; i < Locations.Num(); ++i){
            FAliveNameAndLocation& current = Locations[i];
            if(current.PlayerId == 618446022){
                Utils::getInstance().ShowError([NSString stringWithFormat:@"X: %f \n Y: %f \n Z: %f", current.Location.X, current.Location.Y ,current.Location.Z]);
            }
        }
        //Utils::getInstance().ShowError(@"ClientGetAllPlayerNamesAndLocations");
    }
    
    /*
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
     };
     */
    
    reinterpret_cast<void(__fastcall*)(AShooterPlayerState*, UFunction*, void*)>(reinterpret_cast<void*>(GameHooks::StateHook.GetOriginalFunctionAddress()))(State, CalledFunction, Params);
}

static void (*ReplicateMoveToServer)(UMovementComponent* ShooterMovementComponent, float DeltaTime, Vector3& NewAcceleration) = (void(*)(UMovementComponent*, float, Vector3&))getOffset(0x264a048);



static void ReplicateMoveToServerHook(UMovementComponent* comp , float DeltaTime, Vector3& NewAcceleration){
    
    //Anti Speed Hack
    //Need Timestamp Verification though to make sure the game isnt sped up & to make sure timezone is automatic
    static long long lastTimeMS = std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::system_clock::now().time_since_epoch()).count();
    long long currentTimeMS = std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::system_clock::now().time_since_epoch()).count();
    float DT = 1.1 * (float)(currentTimeMS - lastTimeMS) / 1000;
    
    lastTimeMS = currentTimeMS;
    
    
    if(DeltaTime > DT){
        DeltaTime = DT;
    }
    
    //Utils::getInstance().ShowError([NSString stringWithFormat:@"my DT: %f \n other DT %f", DT, DeltaTime]);
    //DeltaTime *= (PVPSpeedZero && SpeedZeroSwitch.isOn) ? 0 : LocalSpeed;
    return ReplicateMoveToServer(comp, DeltaTime, NewAcceleration);
}
//long long currentTimeMS = std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::system_clock::now().time_since_epoch()).count();

namespace GameHooks {
    void RegisterHooks(){
        //Attempting to hook here too, to see if it crashes.
        if(QuickOffsets::isServerLoaded()){
            //SpawnHook.RegisterForObject(QuickOffsets::GetMyCharacter(), 0xea8, (uint64_t)Hook_PlaySpawnIntro);
            if(QuickOffsets::GetMovementComponent()->isA_Safe(StaticClass::MovementComponent()))
                SpeedHook.RegisterForObject(QuickOffsets::GetMovementComponent(), GameOffsets::VTable_To_Move, (uint64_t)ReplicateMoveToServerHook);
            
            //if(!ControllerHook.isHooked()){
            ControllerHook.RegisterForObject(QuickOffsets::GetPlayerController(), GameOffsets::VTable_To_PE, (uint64_t)ControllerProcessEvent);
            
            if(QuickOffsets::GetShooterCharacter()->isA_Safe(StaticClass::ShooterCharacter()))
                CharacterHook.RegisterForObject(QuickOffsets::GetShooterCharacter(), GameOffsets::VTable_To_PE, (uint64_t)CharacterProcessEvent);
            
            
            //This is for receiving player info from the server
            if(QuickOffsets::GetPlayerState()->isA_Safe(StaticClass::ShooterPlayerState()))
                StateHook.RegisterForObject(QuickOffsets::GetPlayerState(), GameOffsets::VTable_To_PE, (uint64_t)PlayerStateProcessEvent);
            //}
            //if(!CharacterHook.isHooked()){
                //StateHook.RegisterForObject(QuickOffsets::GetPlayerState(), GameOffsets::VTable_To_PE, (uint64_t)PlayerStateProcessEvent);
            //}
            //if(!WeaponHook.isHooked()){
                
            //}
        }
        
        //GetLocalPlayerController even when the server is not Loaded
        return;
    }
}



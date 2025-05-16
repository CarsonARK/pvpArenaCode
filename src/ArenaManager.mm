//
//  ArenaManager.m
//  PVPArenaDylib
//
//  Created by Carson Mobile on 6/15/24.
//

#import <Foundation/Foundation.h>
#include "../Includes.h"


//Checks if the player is within the bounds of the arena
bool Arena::isPlayerInsideArena(){

    AShooterCharacter* MyCharacter = QuickOffsets::GetShooterCharacter();
    if(MyCharacter->isA_Safe(StaticClass::ShooterCharacter())){
        
        //Current Player Location
        Vector3 PlayerLocation = MyCharacter->GetActorLocation();
        
        //Checks if is within bounds
        if(PlayerLocation.X > BoundsNegativeCorner.X && PlayerLocation.Y > BoundsNegativeCorner.Y && PlayerLocation.Z > BoundsNegativeCorner.Z){
            if(PlayerLocation.X < BoundsPositiveCorner.X && PlayerLocation.Y < BoundsPositiveCorner.Y && PlayerLocation.Z < BoundsPositiveCorner.Z){
                return true;
            }
        }
    }
    return false;
}

bool Arena::isLocationInsideArena(Vector3 Location){
    //Checks if is within bounds
    if(Location.X > BoundsNegativeCorner.X && Location.Y > BoundsNegativeCorner.Y && Location.Z > BoundsNegativeCorner.Z){
        if(Location.X < BoundsPositiveCorner.X && Location.Y < BoundsPositiveCorner.Y && Location.Z < BoundsPositiveCorner.Z){
            return true;
        }
    }
    
    return false;
}

void Arena::RandomTeleport(){
    //Reset the PVP Cooldown
    SafeZone::getInstance().ApplyPVPCooldown();
    
    // Create a random engine
    std::default_random_engine generator(std::random_device{}());

    // Define the uniform distributions
    std::uniform_real_distribution<float> distributionX(SpawnNegativeCorner.X, SpawnPositiveCorner.X);
    std::uniform_real_distribution<float> distributionY(SpawnNegativeCorner.Y, SpawnPositiveCorner.Y);

    Vector3 SpawnLocation = {distributionX(generator), distributionY(generator), SpawnHeight};
    
    //First, spawn the player at the top of the Arena, and freeze the player, so that the arena renders in.
    FunctionCalls::getInstance().CheatCommand(string_format("SPI %.0f %.0f %.0f 0", SpawnLocation.X, SpawnLocation.Y, SpawnLocation.Z));
    //FunctionCalls::
    
    //Set Location Locally As Well to make it look smoother
    APlayerController* MyController = QuickOffsets::GetPlayerController();
    if(MyController->isA_Safe(StaticClass::ShooterPlayerController())){
        MyController->ClientSetLocation(SpawnLocation, FRotator());
    }
    
    //Invulnerable timer on entering an arena
    FunctionCalls::getInstance().CheatCommand("SetGodMode 1");
    
    //Updates your player data for the whole server
    OutgoingData::getInstance().PostMyPlayerData();
    
    //if an arena has auto spawn kit enabled, and the user has it enabled in their options
    if(autoSpawnKit){
        Utils::getInstance().ClearInventory(true, true, true);
        QuickKit::getInstance().SpawnKit(true);
        
        timer(4){
            Utils::getInstance().AutoArmor(true);
            Utils::getInstance().AutoUseConsumables(true);
        });
    }
    
    onEntrance();
    
    timer(5){
        FunctionCalls::getInstance().CheatCommand("SetGodMode 0");
    });
}


//debug to see boundaries of the arena
void Arena::DrawBounds(){
    AShooterCharacter* MyCharacter = QuickOffsets::GetShooterCharacter();
    if(MyCharacter->isA_Safe(StaticClass::ShooterCharacter())){
        
        //Current Player Location
        Vector3 PlayerLocation = MyCharacter->GetActorLocation();
        
        bool isInsideX = PlayerLocation.X > BoundsNegativeCorner.X && PlayerLocation.X < BoundsPositiveCorner.X;
        bool isInsideY = PlayerLocation.Y > BoundsNegativeCorner.Y && PlayerLocation.Y < BoundsPositiveCorner.Y;
        bool isInsideZ = PlayerLocation.Z > BoundsNegativeCorner.Z && PlayerLocation.Z < BoundsPositiveCorner.Z;
        
        ImGui::GetBackgroundDrawList()->AddText(ImGui::GetFont(), 20, ImVec2(SCREEN_WIDTH/2, SCREEN_HEIGHT/5), Colors::Green.toU32(), string_format("%d %d %d", isInsideX, isInsideY, isInsideZ).c_str());
        
        ImGui::GetBackgroundDrawList()->AddText(ImGui::GetFont(), 20, ImVec2(SCREEN_WIDTH/2, SCREEN_HEIGHT/2), Colors::Green.toU32(), string_format("X: %.0f Y:  %.0f Z: %.0f", PlayerLocation.X, PlayerLocation.Y, PlayerLocation.Z).c_str());
    }
    else {
        ImGui::GetBackgroundDrawList()->AddText(ImGui::GetFont(), 20, ImVec2(SCREEN_WIDTH/2, SCREEN_HEIGHT/2), Colors::Green.toU32(), string_format("lol no").c_str());
        //ImGui::GetBackgroundDrawList()->AddText(ImGui::GetFont(), FontSize, ImVec2(vec2.x + 1, vec2.y + 1), BlackColor, str);
        
    }
}


//Initialize the Bounds of the Arena and the Killstreaks
void Arena::Initialize(Vector3 inBoundsNegativeCorner, Vector3 inBoundsPositiveCorner, float inSpawnHeight, Vector3 inSpawnNegativeCorner, Vector3 inSpawnPositiveCorner, std::string inArenaName, bool inSpawnGrapplesOnKill, bool inAutoSpawnKit, std::function<void()> inonEntrance){
    
    BoundsNegativeCorner = inBoundsNegativeCorner;
    BoundsPositiveCorner = inBoundsPositiveCorner;
    SpawnHeight = inSpawnHeight;
    SpawnNegativeCorner =  inSpawnNegativeCorner;
    SpawnPositiveCorner =  inSpawnPositiveCorner;
    ArenaName = inArenaName;
    SpawnGrapplesOnKill = inSpawnGrapplesOnKill;
    onEntrance = inonEntrance;
    autoSpawnKit = inAutoSpawnKit;
}


/*
 Begin Duel Arena Class
 */

/*
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
     
     void InitializeArena(Vector3 inInitatorSpawnLocation, Vector3 inAccepterSpawnLocation);
     bool isDuelArenaAvailable();
     void SetArenaOccupied();
     void SetArenaOpen();
     void StartFight(uint64_t inmyPlayerID, uint64_t inmyTribeID, uint64_t inenemyPlayerID, uint64_t inenemyTribeID, bool indidIInitiate, EKitType incurrentKitType);
     void EndFight();
 };
 
 
 ArenaData:DuelData:DuelAccept:Doed_1718600030871:1718600038080:123442642:618446022:1286075291:Duel_Doed_2
 */
void DuelArena::OnEnterArena(){
    Vector3 TeleportLocation = didIInitiate ? InitatorSpawnLocation : AccepterSpawnLocation;
    float SpawnYaw = didIInitiate ? 270 : 90;
    
    //Utils::getInstance().ShowError([NSString stringWithFormat:@"Arena: %@ TPLoc:\n X: %.0f \n Y: %.0f \n Z: %.0f", StringToNSString(ArenaName), TeleportLocation.X, TeleportLocation.Y, TeleportLocation.Z]);
    //Teleport Server Side
    FunctionCalls::getInstance().CheatCommand(string_format("SPI %f %f %f %f", TeleportLocation.X, TeleportLocation.Y, TeleportLocation.Z + 800, SpawnYaw));
    
    //Teleport Client Side
    APlayerController* MyController = QuickOffsets::GetPlayerController();
    if(MyController->isA_Safe(StaticClass::ShooterPlayerController())){
        MyController->ClientSetLocation(TeleportLocation, {SpawnYaw,0,0});
    }
    
    //Clear Inventory
    Utils::getInstance().ClearInventory(true, true, true);
    
    //Spawn Kit
    DefaultKits::getInstance().SpawnKitOfType(currentKitType);
    
    if(isArgyDuel)
    {
        FunctionCalls::getInstance().CheatCommand("GMSummon \"Argent_Character_BP_C\" 120");
        Utils::getInstance().HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Armor/Collars/PrimalItemArmor_GoldenChain.PrimalItemArmor_GoldenChain_C'", 1, 1);
        Utils::getInstance().HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Armor/Saddles/PrimalItemArmor_ArgentavisSaddle.PrimalItemArmor_ArgentavisSaddle_C'", 1, 1);
    }
}
void DuelArena::InitializeArena(Vector3 inInitatorSpawnLocation, Vector3 inAccepterSpawnLocation){
    ActiveFight = false;
    myPlayerID = 0;
    myTribeID = 0;
    enemyPlayerID = 0;
    enemyTribeID = 0;
    didIInitiate = false;
    isArgyDuel = false;
    currentKitType = EKitType_MAX;
    InitatorSpawnLocation = inInitatorSpawnLocation;
    AccepterSpawnLocation = inAccepterSpawnLocation;
}

bool DuelArena::isDuelArenaAvailable(){
    //Check if there are any "Active" Fights
    if(ActiveFight) return false;
    
    //Loop Through online players, and see if any are inside
    for(PlayerData& currentPlayer : PlayerList::getInstance().Players){
        if(isLocationInsideArena(currentPlayer.CurrentLocation)) return false;
    }
    
    return true;
}

void DuelArena::SetArenaOccupied(){
    ActiveFight = true;
}
void DuelArena::SetArenaOpen(){
    ActiveFight = false;
}
/*
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
 */

void DuelArena::StartFight(uint64_t inmyPlayerID, uint64_t inmyTribeID, uint64_t inenemyPlayerID, uint64_t inenemyTribeID, bool indidIInitiate, EKitType incurrentKitType){
    myPlayerID = inmyPlayerID;
    myTribeID = inmyTribeID;
    enemyPlayerID = inenemyPlayerID;
    enemyTribeID = inenemyTribeID;
    
    didIInitiate = indidIInitiate;
    currentKitType = incurrentKitType;
    ActiveFight = true;
    
    //start 1v1 arena spawn in sequence
    //onEntrance();
    OnEnterArena();
}
void DuelArena::EndFight(){
    //Send Server Chat Message with the info about the fight ending
    OutgoingData::getInstance().SendDuelFinished(myPlayerID, enemyPlayerID, ArenaName);
    
    ActiveFight = false;
    myPlayerID = 0;
    myTribeID = 0;
    enemyPlayerID = 0;
    enemyTribeID = 0;
    didIInitiate = false;
    currentKitType = EKitType_MAX;
    
    SafeZone::getInstance().RandomTeleport();
    
    SetArenaOpen();
    
    
}

/*
 Arena Teleport Sequence (have the PlayerId of both players (make it clear who sent the challenge) , the kit type, and the arena ID)
     Challenger spawns in one spot, other guy spawns in the other spot
  
     1. Teleport - Done
     2. Clear Inventory
     3. Spawn the Kit
     4. Auto Equip Armor, Grapples, Attachments, Auto Use Consumables (Assuming all these options are enabled whatever)
     4. Automatically kill any players in the arena who aren't you or your opponent (incase someone is logged off in an arena somehow)
  
     - Thats about in for the spawnin seqeuence, but when it comes time for dino 1v1s it will be longer.
  
     During the Duel:
     have the kill player whatever (if you are in a duel arena) popup with a message saying you won the duel against <opponent name>
     have the kill go to the server
     send a won duel server message letting everyone know the arena is now clear
     teleport to safe zone
 
 FunctionCalls::getInstance().CheatCommand(string_format("SPI %.0f %.0f %.0f 0", SpawnLocation.X, SpawnLocation.Y, SpawnLocation.Z));
 //FunctionCalls::
 
 //Set Location Locally As Well to make it look smoother
 APlayerController* MyController = QuickOffsets::GetPlayerController();
 if(MyController->isA_Safe(StaticClass::ShooterPlayerController())){
     MyController->ClientSetLocation(SpawnLocation, FRotator());
 }
 
 //Invulnerable timer on entering an arena
 FunctionCalls::getInstance().CheatCommand("SetGodMode 1");
 
 //Updates your player data for the whole server
 OutgoingData::getInstance().PostMyPlayerData();
 
 //if an arena has auto spawn kit enabled, and the user has it enabled in their options
 if(autoSpawnKit && Variables.AutoSpawnKit){
     Utils::getInstance().ClearInventory(true, true, true);
     QuickKit::getInstance().SpawnKit(true);
     
     timer(4){
         Utils::getInstance().AutoArmor(true);
         Utils::getInstance().AutoUseConsumables(true);
     });
 }
 
 onEntrance();
 
 timer(5){
     FunctionCalls::getInstance().CheatCommand("SetGodMode 0");
 });
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
 
 
 */

void SafeZone::Initialize(){
    SpawnNegativeCorner = {-1017451, 332446, -90000};
    SpawnPositiveCorner = {-645550, 830767, 0};
    SpawnHeight = -45860;
    
    lastHit = std::chrono::steady_clock::now();
}

void SafeZone::RandomTeleport(){
    // Create a random engine
    std::default_random_engine generator(std::random_device{}());

    // Define the uniform distributions
    std::uniform_real_distribution<float> distributionX(SpawnNegativeCorner.X, SpawnPositiveCorner.X);
    std::uniform_real_distribution<float> distributionY(SpawnNegativeCorner.Y, SpawnPositiveCorner.Y);

    Vector3 SpawnLocation = {distributionX(generator), distributionY(generator), SpawnHeight};
    
    FunctionCalls::getInstance().CheatCommand(string_format("SPI %.0f %.0f %.0f 0", SpawnLocation.X, SpawnLocation.Y, SpawnLocation.Z));
    
    //Set Location Locally As Well to make it look smoother
    APlayerController* MyController = QuickOffsets::GetPlayerController();
    if(MyController->isA_Safe(StaticClass::ShooterPlayerController())){
        MyController->ClientSetLocation(SpawnLocation, FRotator());
    }
    
}

bool SafeZone::isPlayerInsideSafeZone(){

    AShooterCharacter* MyCharacter = QuickOffsets::GetShooterCharacter();
    if(MyCharacter->isA_Safe(StaticClass::ShooterCharacter())){
        
        //Current Player Location
        Vector3 PlayerLocation = MyCharacter->GetActorLocation();
        
        //Checks if is within bounds
        if(PlayerLocation.X > SpawnNegativeCorner.X && PlayerLocation.Y > SpawnNegativeCorner.Y && PlayerLocation.Z > SpawnNegativeCorner.Z){
            if(PlayerLocation.X < SpawnPositiveCorner.X && PlayerLocation.Y < SpawnPositiveCorner.Y && PlayerLocation.Z < SpawnPositiveCorner.Z){
                return true;
            }
        }
    }
    return false;
}

bool SafeZone::isLocationInsideSafeZone(Vector3 Location){
    if(Location.X > SpawnNegativeCorner.X && Location.Y > SpawnNegativeCorner.Y && Location.Z > SpawnNegativeCorner.Z){
        if(Location.X < SpawnPositiveCorner.X && Location.Y < SpawnPositiveCorner.Y && Location.Z < SpawnPositiveCorner.Z){
            return true;
        }
    }
    return false;
}

//resets the timer for teleporting to safe zone
void SafeZone::ApplyPVPCooldown(){
    lastHit = std::chrono::steady_clock::now();
}

//check if you can return to the safe zone
bool SafeZone::canReturnToSafeZone(){
    AShooterCharacter* MyCharacter = QuickOffsets::GetShooterCharacter();
    if(MyCharacter->isA_Safe(StaticClass::ShooterCharacter())){
        //Gets the current time
        auto now = std::chrono::steady_clock::now();
        auto elapsed = std::chrono::duration_cast<std::chrono::seconds>(now - lastHit).count();
        
        //is the time since you were last damaged more than the tp cooldown
        bool timeCheck = elapsed >= TELEPORTATION_COOLDOWN;
        if(timeCheck){
            float MaxHealth = MyCharacter->GetReplicatedMaxHealth();
            float CurrentHealth = MyCharacter->GetReplicatedCurrentHealth();
            float CurrentTorpor = MyCharacter->GetReplicatedCurrentTorpor();
            
            //If you basically are at 0 torpor and full health
            if(CurrentTorpor < 2 && CurrentHealth + 10 >= MaxHealth){
                return true;
            }
        }
    }
    return false;
}

int SafeZone::GetSafeZoneSecondsRemaining(){
    auto now = std::chrono::steady_clock::now();
    auto elapsed = std::chrono::duration_cast<std::chrono::seconds>(now - lastHit).count();
    
    //is the time since you were last damaged more than the tp cooldown
    return (int)(TELEPORTATION_COOLDOWN - elapsed);
}

void SafeZone::ReturnToSafeZone(){
    if(canReturnToSafeZone()){
        AShooterCharacter* MyCharacter = QuickOffsets::GetShooterCharacter();
        if(MyCharacter->isA_Safe(StaticClass::ShooterCharacter())){
            
            OutgoingData::getInstance().PostMyPlayerData();
            
            std::string CharacterName = MyCharacter->GetPlayerName()->iosToString();
            FunctionCalls::getInstance().SendAnnouncement(string_format("%s returned to the Safe Zone", CharacterName.c_str()));
            RandomTeleport();
        }
    }
}

/*
 Default Kits
 
 class DefaultKits {
     static DefaultKits& getInstance() {
         static DefaultKits instance;
         return instance;
     }
     
     //Defaults
     void SpawnDefaultConsumables();
     void SpawnDefaultArmor();
     
     //Arena Kits
     void SpawnCompKit();
     void SpawnFabiKit();
     void SpawnRocketKit();
     void SpawnGrapplesKit();
     void SpawnMeleKit();
 };

 
 
 */
void DefaultKits::SpawnFlakSet(int numSets){
    Utils::getInstance().HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Armor/Metal/PrimalItemArmor_MetalHelmet.PrimalItemArmor_MetalHelmet_C'", numSets, 1);
    Utils::getInstance().HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Armor/Metal/PrimalItemArmor_MetalShirt.PrimalItemArmor_MetalShirt_C'", numSets, 1);
    Utils::getInstance().HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Armor/Metal/PrimalItemArmor_MetalPants.PrimalItemArmor_MetalPants_C'", numSets, 1);
    Utils::getInstance().HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Armor/Metal/PrimalItemArmor_MetalGloves.PrimalItemArmor_MetalGloves_C'", numSets, 1);
    Utils::getInstance().HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Armor/Metal/PrimalItemArmor_MetalBoots.PrimalItemArmor_MetalBoots_C'", numSets, 1);
}
void DefaultKits::SpawnRiotSet(int numSets){
    Utils::getInstance().HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Armor/Riot/PrimalItemArmor_RiotBoots.PrimalItemArmor_RiotBoots_C'", numSets, 1);
    Utils::getInstance().HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Armor/Riot/PrimalItemArmor_RiotGloves.PrimalItemArmor_RiotGloves_C'", numSets, 1);
    Utils::getInstance().HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Armor/Riot/PrimalItemArmor_RiotHelmet.PrimalItemArmor_RiotHelmet_C'", numSets, 1);
    Utils::getInstance().HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Armor/Riot/PrimalItemArmor_RiotPants.PrimalItemArmor_RiotPants_C'", numSets, 1);
    Utils::getInstance().HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Armor/Riot/PrimalItemArmor_RiotShirt.PrimalItemArmor_RiotShirt_C'", numSets, 1);
}
void DefaultKits::SpawnTekSet(int numSets){
    Utils::getInstance().HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Armor/TEK/PrimalItemArmor_TekBoots.PrimalItemArmor_TekBoots_C'", numSets, 1);
    Utils::getInstance().HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Armor/TEK/PrimalItemArmor_TekGloves.PrimalItemArmor_TekGloves_C'", numSets, 1);
    Utils::getInstance().HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Armor/TEK/PrimalItemArmor_TekHelmet.PrimalItemArmor_TekHelmet_C'", numSets, 1);
    Utils::getInstance().HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Armor/TEK/PrimalItemArmor_TekPants.PrimalItemArmor_TekPants_C'", numSets, 1);
    Utils::getInstance().HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Armor/TEK/PrimalItemArmor_TekShirt.PrimalItemArmor_TekShirt_C'", numSets, 1);
}
void DefaultKits::SpawnPan(){
    Utils::getInstance().HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Weapons/PrimalItem_WeaponIronSkillet.PrimalItem_WeaponIronSkillet_C'", 1, 1);
}
void DefaultKits::SpawnClub(){
    Utils::getInstance().HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Weapons/PrimalItem_WeaponStoneClub.PrimalItem_WeaponStoneClub_C'", 1, 1);
}
void DefaultKits::SpawnSword(){
    Utils::getInstance().HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Weapons/PrimalItem_WeaponSword.PrimalItem_WeaponSword_C'", 1, 1);
}
void DefaultKits::SpawnCutlass(){
    Utils::getInstance().HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Weapons/PrimalItem_WeaponCutlass.PrimalItem_WeaponCutlass_C'", 1, 1);
}
void DefaultKits::SpawnCrossbow(){
    Utils::getInstance().HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Weapons/PrimalItem_WeaponCrossbow.PrimalItem_WeaponCrossbow_C'", 1, 1);
}
void DefaultKits::SpawnGrapples(int Ammount){
    Utils::getInstance().HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Weapons/PrimalItemAmmo_GrapplingHook.PrimalItemAmmo_GrapplingHook_C'", Ammount, 1);
}
void DefaultKits::SpawnBolas(int Ammount){
    Utils::getInstance().HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Weapons/PrimalItem_WeaponBola.PrimalItem_WeaponBola_C'", Ammount, 1);
}
void DefaultKits::SpawnLauncherAndRockets(int LauncherCount){
    Utils::getInstance().HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Weapons/PrimalItem_WeaponRocketLauncher.PrimalItem_WeaponRocketLauncher_C'", LauncherCount, 1);
    Utils::getInstance().HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Weapons/PrimalItemAmmo_Rocket.PrimalItemAmmo_Rocket_C'", LauncherCount, 10);
}
void DefaultKits::SpawnBeer(){
    Utils::getInstance().HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Consumables/PrimalItemConsumable_BeerJar.PrimalItemConsumable_BeerJar_C'", 1, 1);
    Utils::getInstance().HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Consumables/BaseBPs/PrimalItemConsumable_CureLow.PrimalItemConsumable_CureLow_C'", 1, 1);
}
void DefaultKits::SpawnSniper(int Ammount){
    Utils::getInstance().HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Weapons/PrimalItem_WeaponMachinedSniper.PrimalItem_WeaponMachinedSniper_C'", Ammount, 1);
}
void DefaultKits::SpawnSniperAmmo(int Stacks){
    Utils::getInstance().HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Weapons/PrimalItemAmmo_AdvancedSniperBullet.PrimalItemAmmo_AdvancedSniperBullet_C'", Stacks, 50);
}
void DefaultKits::SpawnComp(){
    Utils::getInstance().HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Weapons/PrimalItem_WeaponCompoundBow.PrimalItem_WeaponCompoundBow_C'", 1, 1);
}
void DefaultKits::SpawnMetalArrows(int Stacks){
    Utils::getInstance().HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Weapons/PrimalItemAmmo_CompoundBowArrow.PrimalItemAmmo_CompoundBowArrow_C'", Stacks, 50);
}
void DefaultKits::SpawnSniperAttachments(int numSets){
    Utils::getInstance().HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/WeaponAttachments/PrimalItemWeaponAttachment_Laser.PrimalItemWeaponAttachment_Laser_C'", numSets, 1);
    Utils::getInstance().HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/WeaponAttachments/PrimalItemWeaponAttachment_Silencer.PrimalItemWeaponAttachment_Silencer_C'", numSets, 1);
}
void DefaultKits::SpawnLongneck(int Amount){
    Utils::getInstance().HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Weapons/PrimalItem_WeaponOneShotRifle.PrimalItem_WeaponOneShotRifle_C'", Amount, 1);
}
void DefaultKits::SpawnShockingTranqs(int Stacks){
    Utils::getInstance().HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Weapons/PrimalItemAmmo_RefinedTranqDart.PrimalItemAmmo_RefinedTranqDart_C'", Stacks, 50);
}
void DefaultKits::SpawnShotgun(){
    Utils::getInstance().HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Weapons/PrimalItem_WeaponMachinedShotgun.PrimalItem_WeaponMachinedShotgun_C'", 1, 1);
}
void DefaultKits::SpawnShotgunAmmo(int Stacks){
    Utils::getInstance().HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Weapons/PrimalItemAmmo_SimpleShotgunBullet.PrimalItemAmmo_SimpleShotgunBullet_C'", Stacks, 50);
}
void DefaultKits::SpawnAR(int Stacks){
    Utils::getInstance().HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Weapons/PrimalItem_WeaponRifle.PrimalItem_WeaponRifle_C'", Stacks, 1);
}
void DefaultKits::SpawnARB(int Stacks){
    Utils::getInstance().HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Weapons/PrimalItemAmmo_AdvancedRifleBullet.PrimalItemAmmo_AdvancedRifleBullet_C'", Stacks, 50);
}
void DefaultKits::SpawnHoloScope(int Stacks){
    Utils::getInstance().HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/WeaponAttachments/PrimalItemWeaponAttachment_HoloScope.PrimalItemWeaponAttachment_HoloScope_C'", Stacks, 1);
}
void DefaultKits::SpawnArketypes(int Stacks){
    Utils::getInstance().HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Armor/ARKetypes/PrimalItemArmor_FrogFeet.PrimalItemArmor_FrogFeet_C'", Stacks, 1);
    Utils::getInstance().HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Misc/Special/PrimalItem_DragonFlyWings.PrimalItem_DragonFlyWings_C'", Stacks, 1);
}

void DefaultKits::SpawnDefaultConsumables(){
    Utils::getInstance().SpawnConsumables();
}
void DefaultKits::SpawnDefaultArmor(){
    Utils::getInstance().SpawnTekArmor();
}
void DefaultKits::SpawnCompKit(){
    Utils::getInstance().ClearInventory(true, true, true);
    Utils::getInstance().SpawnRiotArmor();
    SpawnDefaultConsumables();
    Utils::getInstance().SpawnComp();
    Utils::getInstance().SpawnComp();
    
    timer(3){
        Utils::getInstance().AutoArmor(true);
        Utils::getInstance().AutoUseConsumables(true);
    });
}
void DefaultKits::SpawnFabiKit(){
    Utils::getInstance().ClearInventory(true, true, true);
    Utils::getInstance().SpawnTekArmor();
    SpawnDefaultConsumables();
    Utils::getInstance().SpawnFabi();
    Utils::getInstance().SpawnFabi();
    
    timer(4){
        Utils::getInstance().AutoArmor(true);
        Utils::getInstance().AutoUseConsumables(true);
    });
}

/*
 enum EKitType : uint8_t {
     EKitType_Mele = 0, //Pan, Tek, Bola, Grapples, Sword, Tek Armor, beer, antidote
     EKitType_Rockets = 1, //80 Rockets, 8 Launchers, 4 Tek Sets, Consumables, 5 beer, 5 antidotes
     EKitType_Grapples = 2, //30 Grapples, 15 Bolas, Comp, Fabi, 3 Tek Suits, Consumables
     EKitType_Standard = 3, //15 Bolas, 15 Grapples, Comp, Fabi, 2 tek sets, consumables,
     EKitType_Aids = 4, //Pan, 40 Bolas, 40 Grapples, Frog Feet, 2 Tek Sets, Aerial Symbiote, Comp, Fabi, cutlass, shocking darts
     EKitType_CompoundBow = 5, //Comp, 200 metal arrows, 2 Riot Sets, consumables
     EKitType_FabSniper = 6, //4 fabis, 2 tek sets, attachments, bullets, consumables
     EKitType_AssaultRifle = 7, //Assault rifle & one set of tek & consumables
     EKitType_Shotgun = 7, //fab shotgun and prim flak and consumables
     EKitType_Club = 8, //Flak, Sword, Club, Consumables
     EKitType_Darts = 9, //Shocking Tranq Darts, Prim Flak, Sword, 4 longnecks, Consumables
     EKitType_MAX = 10
 };
 */
void DefaultKits::SpawnKitOfType(EKitType type){
    if(type == EKitType_MAX) return;
    
    Utils::getInstance().SpawnConsumables();
    
    switch(type){
        case EKitType_Mele:{
            
            SpawnPan();
            SpawnTekSet(2);
            SpawnBolas(15);
            SpawnGrapples(15);
            SpawnCrossbow();
            SpawnBeer();
            SpawnSword();

            break;
        }
        case EKitType_Rockets:{
            SpawnLauncherAndRockets(8);
            SpawnBeer();
            SpawnArketypes(4);
            SpawnTekSet(3);
            break;
        }
        case EKitType_Standard:{
            SpawnSniper(2);
            SpawnSniperAttachments(2);
            SpawnSniperAmmo(3);
            SpawnCrossbow();
            SpawnGrapples(15);
            SpawnBolas(15);
            SpawnComp();
            SpawnMetalArrows(8);
            SpawnTekSet(2);
            break;
        }
        //Pan, 40 Bolas, 40 Grapples, Frog Feet, 2 Tek Sets, Aerial Symbiote, Comp, Fabi, cutlass, shocking darts
        case EKitType_Aids:{
            SpawnPan();
            SpawnBolas(40);
            SpawnBeer();
            SpawnCrossbow();
            SpawnGrapples(40);
            SpawnArketypes(2);
            SpawnTekSet(2);
            SpawnComp();
            SpawnMetalArrows(4);
            SpawnSniper(2);
            SpawnSniperAttachments();
            SpawnSniperAmmo(3);
            SpawnCutlass();
            SpawnLongneck(2);
            SpawnShockingTranqs(3);
            break;
        }
        //Comp, 200 metal arrows, 2 Riot Sets, consumables
        case EKitType_CompoundBow:{
            SpawnRiotSet(2);
            SpawnComp();
            SpawnMetalArrows(4);
            break;
        }
        //4 fabis, 2 tek sets, attachments, bullets, consumables
        case EKitType_FabSniper:{
            SpawnSniper(4);
            SpawnSniperAmmo(6);
            SpawnSniperAttachments(2);
            SpawnTekSet(2);
            break;
        }
        //Assault rifle & one set of tek & consumables
        case EKitType_AssaultRifle:{
            SpawnFlakSet(3);
            SpawnAR(2);
            SpawnARB(10);
            break;
        }
        //fab shotgun and prim flak and consumables
        case EKitType_Shotgun:{
            SpawnShotgun();
            SpawnHoloScope();
            SpawnShotgunAmmo(4);
            SpawnFlakSet(2);
            break;
        }
        //Flak, Sword, Club, Consumables
        case EKitType_Club:{
            SpawnFlakSet(2);
            SpawnClub();
            SpawnSword();
            break;
        }
        //Shocking Tranq Darts, Prim Flak, Sword, 4 longnecks, Consumables
        case EKitType_Darts:{
            SpawnFlakSet(2);
            SpawnLongneck(4);
            SpawnShockingTranqs(4);
            SpawnSword();
            break;
        }
            
        default:
            break;
    }
    
    timer(3.5){
        Utils::getInstance().AutoArmor(true);
        Utils::getInstance().AutoUseConsumables(true);
        
        if(ArenaManager::getInstance().isPlayerInsideArgyArena()){
            FunctionQueue::GetI().AddTask([]{
                QuickOffsets::GetShooterCharacter()->ServerCallStay();
            });
            timer(0.1){
                FunctionQueue::GetI().AddTask([]{
                    QuickOffsets::GetShooterCharacter()->ServerCallPassive();
                });
            });
        }
    });
    
    return;
}

/*
 
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
    Arena& GetCurrentArena();
 

     //All Kits, Comp, Fabi
     std::vector<Arena> FFA_Arenas;
 
 */
bool ArenaManager::isPlayerInsideDuelArena(){
    for(std::vector<DuelArena>& arenas : Duel_Arenas){
        for(DuelArena& arena : arenas){
            if(arena.isPlayerInsideArena()) return true;
        }
    }
    return false;
}
bool ArenaManager::isPlayerInsideArgyArena(){
    for(std::vector<DuelArena>& arenas : Duel_Arenas){
        for(DuelArena& arena : arenas){
            if(arena.isPlayerInsideArena()){
                return arena.isArgyDuel;
            }
        }
    }
    return false;
}
bool ArenaManager::isPlayerInsideFFAArena(){
    for(Arena& currentArena : FFA_Arenas){
        if(currentArena.isPlayerInsideArena()) return true;
    }
    return false;
}
bool ArenaManager::isPlayerInsideAnArena(){
    //Check FFA Arenas
    for(Arena& currentArena : FFA_Arenas){
        if(currentArena.isPlayerInsideArena()) return true;
    }
    
    //Check Duel Arenas
    for(std::vector<DuelArena>& arenas : Duel_Arenas){
        for(DuelArena& arena : arenas){
            if(arena.isPlayerInsideArena()) return true;
        }
    }
    return false;
}
bool ArenaManager::isPlayerInsideArena(std::string ArenaName){
    
    //Check FFA Arenas
    for(Arena& currentArena : FFA_Arenas){
        if(currentArena.ArenaName == ArenaName){
            return currentArena.isPlayerInsideArena();
        }
    }
    //Check Duel Arenas
    
    return false;
}
void ArenaManager::EnterArena(std::string ArenaName){
    for(Arena& currentArena : FFA_Arenas){
        if(currentArena.ArenaName == ArenaName){
            currentArena.RandomTeleport();
        }
    }
}
Arena& ArenaManager::GetCurrentFFAArena(){
    for(Arena& currentArena : FFA_Arenas){
        if(currentArena.isPlayerInsideArena()){
            return currentArena;
        }
    }
    
    //This should Never Happen, Always Check if a player is inside an arena first
    return FFA_Arenas[0];
}
DuelArena& ArenaManager::GetCurrentDuelArena(){
    for(std::vector<DuelArena>& arenas : Duel_Arenas){
        for(DuelArena& arena : arenas){
            if(arena.isPlayerInsideArena()) return arena;
        }
    }
    return Duel_Arenas[0][0];
}
Arena& ArenaManager::ArenaForString(std::string ArenaName){
    for(Arena& currentArena : FFA_Arenas){
        if(currentArena.ArenaName == ArenaName){
            return currentArena;
        }
    }
    return FFA_Arenas[0];
}
void ArenaManager::InitializeArenas(){
    Arena FFA_Doed_AllKits;
    Arena FFA_Doed_CompoundBow;
    Arena FFA_Doed_Sniper;
    /*
     spi 255500 912000 -40000 0
     BoundsNegativeCorner = {247500, 904000, -47000};
     BoundsPositiveCorner = {263500, 920000, -30000};
     SpawnHeight = -37000;
     SpawnNegativeCorner =  {250500, 907000, -37000};
     SpawnPositiveCorner =  {260500, 917000, -37000};
     */
    FFA_Doed_AllKits.Initialize(
                                {247500, 904000, -47000}, //Bounds Negative Corner
                                {263500, 920000, -30000}, //Bounds Positive Corner
                                -37000,            //Spawn Height
                                {250500, 907000, -37000},  //Spawn Negative Corner
                                {260500, 917000, -37000},  //Spawn Positive Corner
                                "FFA_Doed1",
                                true,
                                true,
                                [](){ //No Action since this is the default one
                        
    });
    FFA_Arenas.push_back(FFA_Doed_AllKits);
    
    /*
     
     spi 305500 912000 -40000 0
     BoundsNegativeCorner = {297500, 904000, -47000};
     BoundsPositiveCorner = {313500, 920000, -30000};
     SpawnHeight = -37000;
     SpawnNegativeCorner =  {300500, 907000, -37000};
     SpawnPositiveCorner =  {310500, 917000, -37000};
     */
    
    FFA_Doed_CompoundBow.Initialize(
                                {297500, 904000, -47000}, //Bounds Negative Corner
                                {313500, 920000, -30000}, //Bounds Positive Corner
                                -37000,            //Spawn Height
                                {300500, 907000, -37000},  //Spawn Negative Corner
                                {310500, 917000, -37000},  //Spawn Positive Corner
                                "FFA_Doed_Comp1",
                                false,
                                false,
                                [](){
        DefaultKits::getInstance().SpawnCompKit();
    });
    FFA_Arenas.push_back(FFA_Doed_CompoundBow);
    
    
    /*
     spi 355500 912000 -40000 0
     BoundsNegativeCorner = {347500, 904000, -47000};
     BoundsPositiveCorner = {363500, 920000, -30000};
     SpawnHeight = -37000;
     SpawnNegativeCorner =  {350500, 907000, -37000};
     SpawnPositiveCorner =  {360500, 917000, -37000};
     */
    
    FFA_Doed_Sniper.Initialize(
                                {347500, 904000, -47000}, //Bounds Negative Corner
                                {363500, 920000, -30000}, //Bounds Positive Corner
                                -37000,            //Spawn Height
                                {350500, 907000, -37000},  //Spawn Negative Corner
                                {360500, 917000, -37000},  //Spawn Positive Corner
                                "FFA_Doed_Fabi1",
                                false,
                                false,
                                [](){
        DefaultKits::getInstance().SpawnFabiKit();
    });
    FFA_Arenas.push_back(FFA_Doed_Sniper);
    // []() {
    //std::cout << "Executing custom action inside Purchase." << std::endl;
//});
    
    //Now Initialize the Duel Arenas
    InitializeDuelAreans();
}

/*
 let's start with basics:
    2 Doed
 and
    2 Noctis
 
 to initialize these arena we only need the 2 spawn locations and the bounds
 
 start with the spi x y -40000 0
 
 for all:
 BoundsNegativeCorner = {x - 8000, y - 8000, -47000};
 BoundsPositiveCorner = {x + 8000, y + 8000, -30000};
 
 
 after that we need the 2 Spawn Offsets (will be different for every arena)
 
 I'll have the arenas along the north oast and going north (- Lat , 0 Long)
 
 
 Latitude is Y Axis
 Longtiude is X Axis
 
 incriment arenas by -Y , by 50,0000
 incriment from one arena to another by +X, by 50,000
 
 
 starting Location:
 spi -700000 -700000 -40000 0 (Doed1)
 spi -700000 -750000 -40000 0 (Doed2)
 spi -700000 -800000 -40000 0 (Doed3)
 spi -700000 -850000 -40000 0 (Doed4)
 spi -700000 -900000 -40000 0 (Doed5)
 
 coords of that are -38.4 -34.2
 
 SpawnLocation Player 1:  spi -700000 -695000 -39300 270
 SpawnLocation Player 2:  spi -700000 -705000 -39300 90
 Doed Spawn Location Player 1: X Y+5000 Z+700 270
 Doed Spawn Location Player 2: X Y-5000 Z+700 90
 
 Duel_Noctis_i
 spi -650000 -700000 -40000 0 (Noctis1)
 spi -650000 -750000 -40000 0 (Noctis1)
 spi -650000 -800000 -40000 0 (Noctis1)
 spi -650000 -850000 -40000 0 (Noctis1)
 spi -650000 -900000 -40000 0 (Noctis1)
 
 SpawnLocation Player 1: X Y+5000 Z+700 270
 SpawnLocation Player 2: X Y+5000 Z+700 270
 
 -600000 -705000 -39300 90
 
 Duel_Gorilla_i
 
 spi -600000 -700000 -40000 0
 spi -600000 -750000 -40000 0
 spi -600000 -800000 -40000 0
 spi -600000 -850000 -40000 0
 spi -600000 -900000 -40000 0
 
 SpawnLocation Player 1: X Y+5000 Z+700 270
 SpawnLocation Player 2: X Y+5000 Z+700 270
 
 
 Duel_Argentustus_i
 
 spi -550000 -700000 -40000 0
 spi -550000 -750000 -40000 0
 spi -550000 -800000 -40000 0
 spi -550000 -850000 -40000 0
 spi -550000 -900000 -40000 0
 
 SpawnLocation Player1: +4000 +2000 +700
 SpawnLocation Player2: -1500 -4500 +700
 
 
 Duel_Spider_i
 
 spi -500000 -700000 -40000 0
 spi -500000 -750000 -40000 0
 spi -500000 -800000 -40000 0
 spi -500000 -850000 -40000 0
 spi -500000 -900000 -40000 0
 
 SpawnLocation Player 1: X Y+5000 Z+700 270
 SpawnLocation Player 2: X Y+5000 Z+700 270
 
 Duel_Chali_i
 
 spi -450000 -700000 -40000 0
 spi -450000 -750000 -40000 0
 spi -450000 -800000 -40000 0
 spi -450000 -850000 -40000 0
 spi -450000 -900000 -40000 0
 
 SpawnLocation Player 1: X Y+5000 Z+700 270
 SpawnLocation Player 2: X Y+5000 Z+700 270
 
 
 Duel_Cnidaria_i
 
 spi -400000 -700000 -40000 0
 spi -400000 -750000 -40000 0
 spi -400000 -800000 -40000 0
 spi -400000 -850000 -40000 0
 spi -400000 -900000 -40000 0
 
 SpawnLocation Player 1: X Y+5000 Z+700 270
 SpawnLocation Player 2: X Y+5000 Z+700 270
 
 
 Duel_Dodo_i
 
 spi -350000 -700000 -40000 0
 spi -350000 -750000 -40000 0
 spi -350000 -800000 -40000 0
 spi -350000 -850000 -40000 0
 spi -350000 -900000 -40000 0
 
 SpawnLocation Player 1: X Y+5000 Z+700 270
 SpawnLocation Player 2: X Y+5000 Z+700 270
 
 Duel_Beetle_i
 
 spi -300000 -700000 -40000 0
 spi -300000 -750000 -40000 0
 spi -300000 -800000 -40000 0
 spi -300000 -850000 -40000 0
 spi -300000 -900000 -40000 0
 
 SpawnLocation Player 1: X Y+5000 Z+700 270
 SpawnLocation Player 2: X Y+5000 Z+700 270
 
 Duel_Frog_i
 
 spi -250000 -700000 -40000 0
 spi -250000 -750000 -40000 0
 spi -250000 -800000 -40000 0
 spi -250000 -850000 -40000 0
 spi -250000 -900000 -40000 0
 
 SpawnLocation Player 1: X Y+5000 Z+700 270
 SpawnLocation Player 2: X Y+5000 Z+700 270
 
 */
void ArenaManager::InitializeDuelAreans(){
    std::vector<DuelArena> DoedArenas;
    std::vector<DuelArena> NoctisArenas;
    
    std::vector<DuelArena> GorillaArenas;
    std::vector<DuelArena> ArgentustusArenas;
    std::vector<DuelArena> SpiderArenas;
    std::vector<DuelArena> ChaliArenas;
    std::vector<DuelArena> CnidariaArenas;
    std::vector<DuelArena> DodoArenas;
    std::vector<DuelArena> BeetleArenas;
    std::vector<DuelArena> FrogArenas;
    
    //Initialize Doed Arenas
    Vector3 DoedBaseCoordinates = Vector3(-700000, -700000, -40000);
    for(int i = 0 ; i <= 6 ; i++){
        
        Vector3 CurrentBaseCoordinates = DoedBaseCoordinates;
        CurrentBaseCoordinates.Y -= 50000 * i;
        
        DuelArena CurrentDoedArena;
        CurrentDoedArena.Initialize(
                                    {CurrentBaseCoordinates.X - 80000, CurrentBaseCoordinates.Y - 8000, -47000}, //Bounds Negative Corner
                                    {CurrentBaseCoordinates.X + 80000, CurrentBaseCoordinates.Y + 8000, -30000}, //Bounds Positive Corner
                                    0,            //Spawn Height
                                    {0,0,0},  //Spawn Negative Corner
                                    {0,0,0},  //Spawn Positive Corner
                                    string_format("Duel_Doed_%d", i),
                                    false,
                                    false,
                                    [](){
            //DefaultKits::getInstance().SpawnCompKit();
        });
        
        CurrentDoedArena.InitializeArena({CurrentBaseCoordinates.X, CurrentBaseCoordinates.Y + 5000, CurrentBaseCoordinates.Z + 700}, //Player1 (initiator)
                                         {CurrentBaseCoordinates.X, CurrentBaseCoordinates.Y - 5000, CurrentBaseCoordinates.Z + 700}); //Player2 (initiator)
        
        DoedArenas.push_back(CurrentDoedArena);
    }
    
    Duel_Arenas.push_back(DoedArenas);
    
    //Initialize Noctis Arenas
    Vector3 NoctisBaseCoordinates = Vector3(-650000, -700000, -40000);
    for(int i = 0 ; i <= 6 ; i++){
        
        Vector3 CurrentBaseCoordinates = NoctisBaseCoordinates;
        CurrentBaseCoordinates.Y -= 50000 * i;
        
        DuelArena CurrentNoctisArena;
        CurrentNoctisArena.Initialize(
                                    {CurrentBaseCoordinates.X - 80000, CurrentBaseCoordinates.Y - 8000, -47000}, //Bounds Negative Corner
                                    {CurrentBaseCoordinates.X + 80000, CurrentBaseCoordinates.Y + 8000, -30000}, //Bounds Positive Corner
                                    0,            //Spawn Height
                                    {0,0,0},  //Spawn Negative Corner
                                    {0,0,0},  //Spawn Positive Corner
                                    string_format("Duel_Noctis_%d", i),
                                    false,
                                    false,
                                    [](){
            //DefaultKits::getInstance().SpawnCompKit();
        });
        
        CurrentNoctisArena.InitializeArena({CurrentBaseCoordinates.X, CurrentBaseCoordinates.Y + 5000, CurrentBaseCoordinates.Z + 700}, //Player1 (initiator)
                                         {CurrentBaseCoordinates.X, CurrentBaseCoordinates.Y - 5000, CurrentBaseCoordinates.Z + 700}); //Player2 (initiator)
        
        NoctisArenas.push_back(CurrentNoctisArena);
    }
    
    Duel_Arenas.push_back(NoctisArenas);
    
    
    //Initialize Gorilla Arenas
    Vector3 GorillaBaseCoordinates = Vector3(-600000, -700000, -40000);
    for(int i = 0 ; i <= 6 ; i++){
        
        Vector3 CurrentBaseCoordinates = GorillaBaseCoordinates;
        CurrentBaseCoordinates.Y -= 50000 * i;
        
        DuelArena CurrentGorillaArena;
        CurrentGorillaArena.Initialize(
                                    {CurrentBaseCoordinates.X - 80000, CurrentBaseCoordinates.Y - 8000, -47000}, //Bounds Negative Corner
                                    {CurrentBaseCoordinates.X + 80000, CurrentBaseCoordinates.Y + 8000, -30000}, //Bounds Positive Corner
                                    0,            //Spawn Height
                                    {0,0,0},  //Spawn Negative Corner
                                    {0,0,0},  //Spawn Positive Corner
                                    string_format("Duel_Gorilla_%d", i),
                                    false,
                                    false,
                                    [](){
            //DefaultKits::getInstance().SpawnCompKit();
        });
        
        CurrentGorillaArena.InitializeArena({CurrentBaseCoordinates.X, CurrentBaseCoordinates.Y + 5000, CurrentBaseCoordinates.Z + 700}, //Player1 (initiator)
                                         {CurrentBaseCoordinates.X, CurrentBaseCoordinates.Y - 5000, CurrentBaseCoordinates.Z + 700}); //Player2 (initiator)
        
        GorillaArenas.push_back(CurrentGorillaArena);
    }
    
    Duel_Arenas.push_back(GorillaArenas);
    
    
    //Initialize Argentusus Arenas
    Vector3 ArgentustusBaseCoordinates = Vector3(-550000, -700000, -40000);
    for(int i = 0 ; i <= 6 ; i++){
        
        Vector3 CurrentBaseCoordinates = ArgentustusBaseCoordinates;
        CurrentBaseCoordinates.Y -= 50000 * i;
        
        DuelArena CurrentArgentususArena;
        CurrentArgentususArena.Initialize(
                                    {CurrentBaseCoordinates.X - 80000, CurrentBaseCoordinates.Y - 8000, -47000}, //Bounds Negative Corner
                                    {CurrentBaseCoordinates.X + 80000, CurrentBaseCoordinates.Y + 8000, -30000}, //Bounds Positive Corner
                                    0,            //Spawn Height
                                    {0,0,0},  //Spawn Negative Corner
                                    {0,0,0},  //Spawn Positive Corner
                                    string_format("Duel_Argentustus_%d", i),
                                    false,
                                    false,
                                    [](){});
        
        CurrentArgentususArena.InitializeArena({CurrentBaseCoordinates.X + 4000, CurrentBaseCoordinates.Y + 2000, CurrentBaseCoordinates.Z + 700}, //Player1 (initiator)
                                         {CurrentBaseCoordinates.X - 1500, CurrentBaseCoordinates.Y - 4500, CurrentBaseCoordinates.Z + 700}); //Player2 (initiator)
        
        ArgentustusArenas.push_back(CurrentArgentususArena);
    }
    
    Duel_Arenas.push_back(ArgentustusArenas);
    
    
    //Initialize Spider Arenas
    Vector3 SpiderBaseCoordinates = Vector3(-500000, -700000, -40000);
    for(int i = 0 ; i <= 6 ; i++){
        
        Vector3 CurrentBaseCoordinates = SpiderBaseCoordinates;
        CurrentBaseCoordinates.Y -= 50000 * i;
        
        DuelArena CurrentSpiderArena;
        CurrentSpiderArena.Initialize(
                                    {CurrentBaseCoordinates.X - 80000, CurrentBaseCoordinates.Y - 8000, -47000}, //Bounds Negative Corner
                                    {CurrentBaseCoordinates.X + 80000, CurrentBaseCoordinates.Y + 8000, -30000}, //Bounds Positive Corner
                                    0,            //Spawn Height
                                    {0,0,0},  //Spawn Negative Corner
                                    {0,0,0},  //Spawn Positive Corner
                                    string_format("Duel_Spider_%d", i),
                                    false,
                                    false,
                                    [](){});
        
        CurrentSpiderArena.InitializeArena({CurrentBaseCoordinates.X, CurrentBaseCoordinates.Y + 5000, CurrentBaseCoordinates.Z + 700}, //Player1 (initiator)
                                         {CurrentBaseCoordinates.X, CurrentBaseCoordinates.Y - 5000, CurrentBaseCoordinates.Z + 700}); //Player2 (initiator)
        
        SpiderArenas.push_back(CurrentSpiderArena);
    }
    
    Duel_Arenas.push_back(SpiderArenas);
    
    
    //Initialize Chali Arenas
    Vector3 ChaliBaseCoordinates = Vector3(-450000, -700000, -40000);
    for(int i = 0 ; i <= 6 ; i++){
        
        Vector3 CurrentBaseCoordinates = ChaliBaseCoordinates;
        CurrentBaseCoordinates.Y -= 50000 * i;
        
        DuelArena CurrentChaliArena;
        CurrentChaliArena.Initialize(
                                    {CurrentBaseCoordinates.X - 80000, CurrentBaseCoordinates.Y - 8000, -47000}, //Bounds Negative Corner
                                    {CurrentBaseCoordinates.X + 80000, CurrentBaseCoordinates.Y + 8000, -30000}, //Bounds Positive Corner
                                    0,            //Spawn Height
                                    {0,0,0},  //Spawn Negative Corner
                                    {0,0,0},  //Spawn Positive Corner
                                    string_format("Duel_Chali_%d", i),
                                    false,
                                    false,
                                    [](){});
        
        CurrentChaliArena.InitializeArena({CurrentBaseCoordinates.X, CurrentBaseCoordinates.Y + 5000, CurrentBaseCoordinates.Z + 700}, //Player1 (initiator)
                                         {CurrentBaseCoordinates.X, CurrentBaseCoordinates.Y - 5000, CurrentBaseCoordinates.Z + 700}); //Player2 (initiator)
        
        ChaliArenas.push_back(CurrentChaliArena);
    }
    
    Duel_Arenas.push_back(ChaliArenas);
    
    
    //Initialize Cnidaria Arenas
    Vector3 CnidariaBaseCoordinates = Vector3(-400000, -700000, -40000);
    for(int i = 0 ; i <= 6 ; i++){
        
        Vector3 CurrentBaseCoordinates = CnidariaBaseCoordinates;
        CurrentBaseCoordinates.Y -= 50000 * i;
        
        DuelArena CurrentCnidariaArena;
        CurrentCnidariaArena.Initialize(
                                    {CurrentBaseCoordinates.X - 80000, CurrentBaseCoordinates.Y - 8000, -47000}, //Bounds Negative Corner
                                    {CurrentBaseCoordinates.X + 80000, CurrentBaseCoordinates.Y + 8000, -30000}, //Bounds Positive Corner
                                    0,            //Spawn Height
                                    {0,0,0},  //Spawn Negative Corner
                                    {0,0,0},  //Spawn Positive Corner
                                    string_format("Duel_Cnidaria_%d", i),
                                    false,
                                    false,
                                    [](){});
        
        CurrentCnidariaArena.InitializeArena({CurrentBaseCoordinates.X, CurrentBaseCoordinates.Y + 5000, CurrentBaseCoordinates.Z + 700}, //Player1 (initiator)
                                         {CurrentBaseCoordinates.X, CurrentBaseCoordinates.Y - 5000, CurrentBaseCoordinates.Z + 700}); //Player2 (initiator)
        
        CnidariaArenas.push_back(CurrentCnidariaArena);
    }
    
    Duel_Arenas.push_back(CnidariaArenas);
    
    
    //Initialize Dodo Arenas
    Vector3 DodoBaseCoordinates = Vector3(-350000, -700000, -40000);
    for(int i = 0 ; i <= 6 ; i++){
        
        Vector3 CurrentBaseCoordinates = DodoBaseCoordinates;
        CurrentBaseCoordinates.Y -= 50000 * i;
        
        DuelArena CurrentDodoArena;
        CurrentDodoArena.Initialize(
                                    {CurrentBaseCoordinates.X - 80000, CurrentBaseCoordinates.Y - 8000, -47000}, //Bounds Negative Corner
                                    {CurrentBaseCoordinates.X + 80000, CurrentBaseCoordinates.Y + 8000, -30000}, //Bounds Positive Corner
                                    0,            //Spawn Height
                                    {0,0,0},  //Spawn Negative Corner
                                    {0,0,0},  //Spawn Positive Corner
                                    string_format("Duel_Dodo_%d", i),
                                    false,
                                    false,
                                    [](){});
        
        CurrentDodoArena.InitializeArena({CurrentBaseCoordinates.X, CurrentBaseCoordinates.Y + 5000, CurrentBaseCoordinates.Z + 700}, //Player1 (initiator)
                                         {CurrentBaseCoordinates.X, CurrentBaseCoordinates.Y - 5000, CurrentBaseCoordinates.Z + 700}); //Player2 (initiator)
        
        DodoArenas.push_back(CurrentDodoArena);
    }
    
    Duel_Arenas.push_back(DodoArenas);
    
    //Initialize Beetle Arenas
    Vector3 BeetleBaseCoordinates = Vector3(-300000, -700000, -40000);
    for(int i = 0 ; i <= 6 ; i++){
        
        Vector3 CurrentBaseCoordinates = BeetleBaseCoordinates;
        CurrentBaseCoordinates.Y -= 50000 * i;
        
        DuelArena CurrentBeetleArena;
        CurrentBeetleArena.Initialize(
                                    {CurrentBaseCoordinates.X - 80000, CurrentBaseCoordinates.Y - 8000, -47000}, //Bounds Negative Corner
                                    {CurrentBaseCoordinates.X + 80000, CurrentBaseCoordinates.Y + 8000, -30000}, //Bounds Positive Corner
                                    0,            //Spawn Height
                                    {0,0,0},  //Spawn Negative Corner
                                    {0,0,0},  //Spawn Positive Corner
                                    string_format("Duel_Beetle_%d", i),
                                    false,
                                    false,
                                    [](){});
        
        CurrentBeetleArena.InitializeArena({CurrentBaseCoordinates.X, CurrentBaseCoordinates.Y + 5000, CurrentBaseCoordinates.Z + 700}, //Player1 (initiator)
                                         {CurrentBaseCoordinates.X, CurrentBaseCoordinates.Y - 5000, CurrentBaseCoordinates.Z + 700}); //Player2 (initiator)
        
        BeetleArenas.push_back(CurrentBeetleArena);
    }
    
    Duel_Arenas.push_back(BeetleArenas);
    
    //Initialize Frog Arenas
    Vector3 FrogBaseCoordinates = Vector3(-250000, -700000, -40000);
    for(int i = 0 ; i <= 6 ; i++){
        
        Vector3 CurrentBaseCoordinates = FrogBaseCoordinates;
        CurrentBaseCoordinates.Y -= 50000 * i;
        
        DuelArena CurrentFrogArena;
        CurrentFrogArena.Initialize(
                                    {CurrentBaseCoordinates.X - 80000, CurrentBaseCoordinates.Y - 8000, -47000}, //Bounds Negative Corner
                                    {CurrentBaseCoordinates.X + 80000, CurrentBaseCoordinates.Y + 8000, -30000}, //Bounds Positive Corner
                                    0,            //Spawn Height
                                    {0,0,0},  //Spawn Negative Corner
                                    {0,0,0},  //Spawn Positive Corner
                                    string_format("Duel_Frog_%d", i),
                                    false,
                                    false,
                                    [](){});
        
        CurrentFrogArena.InitializeArena({CurrentBaseCoordinates.X, CurrentBaseCoordinates.Y + 5000, CurrentBaseCoordinates.Z + 700}, //Player1 (initiator)
                                         {CurrentBaseCoordinates.X, CurrentBaseCoordinates.Y - 5000, CurrentBaseCoordinates.Z + 700}); //Player2 (initiator)
        
        FrogArenas.push_back(CurrentFrogArena);
    }
    
    Duel_Arenas.push_back(FrogArenas);
    

    
    std::vector<DuelArena> ArgyArenas;
    
    //Argy Arena 0: Green Ob Arena
    //176522 86528 5677
    //203475 113465
    
    //Positive: 230000 130000 20000
    //Negative: 150000 70000 -30000
    //Duel_Argy_%d
    
    //Spawn Coordinates:
    // Player 1: 197030 108997 -11519
    // Player 2: 178004 92114 -11688
    
    //.isArgyDuel = true;
    
    DuelArena ArgyArena1;
    ArgyArena1.Initialize({150000,70000,-30000}, {230000,130000,20000}, 0, {0,0,0}, {0,0,0}, "Duel_Argy_0", false, false, [](){});
    ArgyArena1.InitializeArena({197030, 108997, -11519}, {178004,92114,-11688});
    ArgyArena1.isArgyDuel = true;
    
    ArgyArenas.push_back(ArgyArena1);
    
    //Argy Arena 1: 60/30
    // -198194 51489
    // -225357 78637
    // Positive: -185000 90000 20000
    // Negative: -240000 40000 -30000
    // Player 1: -223406 76246 -5766
    // Player 2: -201993 54191 -9495
    DuelArena ArgyArena2;
    ArgyArena2.Initialize({-240000,40000,-30000}, {-185000,90000,20000}, 0, {0,0,0}, {0,0,0}, "Duel_Argy_1", false, false, [](){});
    ArgyArena2.InitializeArena({-223406, 76246, -5766}, {-201993,54191,-9495});
    ArgyArena2.isArgyDuel = true;
    
    ArgyArenas.push_back(ArgyArena2);
    
    //Argy Arena 2 North of Obsi
    //55714 -170454 -5000 (North of obsi)
    // 42236 -183924
    // 69189 -156988
    // Positive: 80000 -150000 20000
    // Negative: 30000 -190000 -30000
    // Player 1: 66018 -159368 3800
    // Player 2: 44430 -174240 1202
    DuelArena ArgyArena3;
    ArgyArena3.Initialize({30000,-190000,-30000}, {80000,-150000,20000}, 0, {0,0,0}, {0,0,0}, "Duel_Argy_2", false, false, [](){});
    ArgyArena3.InitializeArena({66018, -159368, 3800}, {44430,-174240,1202});
    ArgyArena3.isArgyDuel = true;
    
    ArgyArenas.push_back(ArgyArena3);
    
    //Argy Arena 3 between volc obsi
    //7224 -89047 -7139
    // -6358 -75476
    // 20804 -102623
    // Positive: 25000 -60000 20000
    // Negative: -15000 -115000 -30000
    // Player 1: 15767 -98107 915
    // Player 2: -3543 -78016 -386
    
    DuelArena ArgyArena4;
    ArgyArena4.Initialize({-15000,-115000,-30000}, {25000,-60000,20000}, 0, {0,0,0}, {0,0,0}, "Duel_Argy_3", false, false, [](){});
    ArgyArena4.InitializeArena({15767, -98107, 915}, {-3543,-78016,-386});
    ArgyArena4.isArgyDuel = true;
    
    ArgyArenas.push_back(ArgyArena4);
    
    //Argy arena 4 in redwoods
    // -54910, 80399, -5562
    // -41434 66928
    // -68387 93864
    // Positive: -30000 100000 20000
    // Negative: -75000 60000 -30000
    // Player 1: -56953 90424 -503
    // Player 2: -43277 69494 835
    
    DuelArena ArgyArena5;
    ArgyArena5.Initialize({-75000,60000,-30000}, {-30000,100000,20000}, 0, {0,0,0}, {0,0,0}, "Duel_Argy_4", false, false, [](){});
    ArgyArena5.InitializeArena({-56953, 90424, -503}, {-43277,69494,835});
    ArgyArena5.isArgyDuel = true;
    
    ArgyArenas.push_back(ArgyArena5);
    
    Duel_Arenas.push_back(ArgyArenas);
    
    
}

std::string ArenaManager::GetAvailableDuelArena(std::string ArenaType){
    for(std::vector<DuelArena>& arenas : Duel_Arenas){
        if(arenas.size() > 0){
            if(contains(arenas[0].ArenaName, ArenaType)){
                for(DuelArena& arena : arenas){
                    if(arena.isDuelArenaAvailable()){
                        return arena.ArenaName;
                    }
                }
            }
        }
    }
    return "None Available";
}
DuelArena& ArenaManager::DuelArenaForString(std::string arenaName){
    for(std::vector<DuelArena>& arenas : Duel_Arenas){
        for(DuelArena& arena : arenas){
            if(arena.ArenaName == arenaName){
                return arena;
            }
        }
    }
    
    return Duel_Arenas[0][0];
}



/*
 
 ServerChat ArenaData:DuelData:DuelAccept:<DuelID>:<Timestamp>:<DuelSenderPlayerID>:<DuelAccepterPlayerID>:<DuelAccepterTribeID>:<ArenaID>
 ServerChat ArenaData:DuelData:DuelInitiate:<DuelID>:<Timestamp>:<SenderPlayerID>:<SenderTribeID>:<SenderPlayerName>:<SenderLevel>:<SenderELO>:<RecievingPlayerID>:<ArenaType>:<KitType>:<CustomMessage>:<ExpirationTime>
 ArenaData:DuelData:DuelDecline:<DuelID>:<Reason>
 ArenaData:DuelData:DuelCanceled:<DuelID>:<Reason>:<RecipientPlayerID>:<YourPlayerID>
 
 FUTURE:
    Auto Chat Translate using the ServerChat shit! (For my ipa server I'll make in the future, too)
 
 1v1 Arenas:
    
 Maybe make a private chat to playerIDs or something, with translate enabled?
 
    Find a way to send ingame notifications / popups
 
    How to initiate ->
 ServerChat ArenaData:DuelData:DuelInitiate:<DuelID>:<Timestamp>:<SenderPlayerID>:<SenderTribeID>:<SenderPlayerName>:<SenderLevel>:<SenderELO>:<RecievingPlayerID>:<ArenaType>:<KitType>:<CustomMessage>:<ExpirationTime>
    If a player sends an invite, it will CANCEL any previous invites they sent
    DuelID will be something like DUEL_Timestamp
    
    so basically all clients when they receive this DuelInitiate will
        1. Check if they are the ReceivingPlayerID
        2. If they are not, Check if the sender player ID has sent them any duel invites, if they have, cancel those.
 
        3. if they ARE the receiving player ID then
            1. Cancel any duel requests from that player
            2. Check if they have "Ignored" that player (make an ignored player list, with PlayerID and Name that gets saved to files)
                - If they have the played ignored, Decline it automatically for the reason "<PlayerName> ignored your duel invites"
            3. Check if they have 1v1 duels enabled (the option yk, if not, deny it for the reason "<PlayerName> has duels disabled"
            4. Check if you (the receiver) are currently in safe zone, if not, or at a time when you join an arena, deny it for "<PlayerName> is currently in <ArenaName>"
            5. After all of that, add the duel with all the information to a vector of duel requests you have, and display them in your menu.
                - Have a checkbox for "Show Duel Requests Automatically" - which will make the popup show
            6. In your menu, for the duel requests, you can click "Accept"  "Deny" or "Ignore Future Requests"
                - Ignore Future Requests will ignore all future requests from that player ID
                - In the duel requests, when you click on one the right side of the screen will show the duel information
                - Deny will deny it for "<PlayerName> has denied your duel request"
            7. Duels should automatically expire after 60 seconds, when you enter an arena, when you send a duel request to a different player
 
    Accepting a Duel Logic:
 ServerChat ArenaData:DuelData:DuelAccept:<DuelID>:<Timestamp>:<DuelSenderPlayerID>:<DuelAccepterPlayerID>:<DuelAccepterTribeID>:<ArenaID>
 
 
 
        1. STARING The Acceptence Sequence
        2. When you click accept on a duel, you need to do one major thing: Find an empty arena of the designated type
        3. Find the array of the 1v1 arenas of the type you are trying to queue into, and go in order checking for empty ones.
            - If one is empty, then that will be the one you use
            - HOW to check if one is Empty:
                - Have a list of Arenas In Use which you basically udpate every time a duel is accepted, and remove that arena ID when one is won.
                - The other way to check it is to go through the player list and see if any of the online players are in the bounds of the arena
            - When you find the empty one, continue
        4. Send a chat with the empty arena ID (like the string of the arena name)
        5. After that, you should start the TeleportToArena(arena ID, bool challenger, KitType kit)
            - the Challenger is the one who sent the duel request -> They will have a set spawn on one side of the arena
            - The Accepter (challenger = false) will have a set spawn on the other side of the arena
        6. (Client Side) Deny all the other duel requests
 
 
    When other people receive the acceptance
 
    1. Check if it was YOUR duel that was accepted. If it was cancel any outgoing duels you might have sent after that,
        if you canceled the duel and it didn't go to the other player that you canceled it yet, too bad.
 
    Begin the Duel Initiation Sequence.
 
    2. If you are not the intended recipient, put the arena ID the duel will be taking place on the used arenas list,
        if you have sent any duel requests to either player, cancel them client side for reason "Player has joined another duel"
 
 
 
 ServerChat ArenaData:DuelData:DuelInitiate:<DuelID>:<Timestamp>:<SenderPlayerID>:<SenderPlayerName>:<SenderLevel>:<SenderELO>:<RecievingPlayerID>:<ArenaType>:<KitType>:<CustomMessage>:<ExpirationTime>
    
Arena Teleport Sequence (have the PlayerId of both players (make it clear who sent the challenge) , the kit type, and the arena ID)
    Challenger spawns in one spot, other guy spawns in the other spot
 
    1. Teleport
    2. Clear Inventory
    3. Spawn the Kit
    4. Auto Equip Armor, Grapples, Attachments, Auto Use Consumables (Assuming all these options are enabled whatever)
    4. Automatically kill any players in the arena who aren't you or your opponent (incase someone is logged off in an arena somehow)
 
    - Thats about in for the spawnin seqeuence, but when it comes time for dino 1v1s it will be longer.
 
    During the Duel:
    have the kill player whatever (if you are in a duel arena) popup with a message saying you won the duel against <opponent name>
    have the kill go to the server
    send a won duel server message letting everyone know the arena is now clear
    teleport to safe zone
 
 DuelCompleted Message
    ServerChat ArenaData:DuelData:DuelCompleted:<WinnerPlayerID>:<LosingPlayerID>:<ArenaID>
 
 
 Duel Declined:
    ArenaData:DuelData:DuelDecline:<DuelID>:<Reason>
    
 Duel Canceled by sending player:
    ArenaData:DuelData:DuelCanceled:<DuelID>:<Reason>:<RecipientPlayerID>:<YourPlayerID>
 
    how to receive a duel cancel:
        if it was a duel sent to you that was canceled, remove it from your pending duels list and have a message if required or whatever
        if it was a duel sent to someone else, doesn't matter lol
 
 Menu:
    Create Duel:
        when you go to this section (maybe just make 1v1s a seperate tab)
        there will be a list of every player who you can challenge to a duel, showing Player Name, Player ID, and then a large "Duel player" Button
        When you click DuelPlayer it will save the player object thing whatever and go to another menu with a "Back" button and at the bottom a "Send Duel Invite" Button
        if at any point the player becomes unable to be dueled, have the button become disabled and have it say "Player is busy in <ArenaID>"
        
        Chooseable things:
            1. Kit Type
            2. Arena Type
            3. Duel Message
        Have like a combo menu for Kit Type and Arena type with text above them explaining both
        For DuelMessage just have like a button where you can input it (don't bother with the whole textfield ting)
        default message should just be like "Come Duel Me"
        
 
    Incoming Duels:
        Display: Player that sent you the request, Arena type, Kit type
        Accept, Decline, Ignore.
        - Processes:
            - Check if the duel is over 60 seconds old, if it is, cancel it
 
        - You can have multiple Incoming duels just not 2 by the same person. You can only accept 1, and when you do you will decline the others
 
    Outgoing Duels:
        
 
 
 
 
 
    
 
    How to Respond
 
    Decline:
        ArenaData:DuelData:DuelDecline:<DuelID>:<Reason>
 
    Accept:
    
 ArenaData:PlayerData:<PlayerID>:<Level>:<CurrentLocation>:<isAccepting1v1Requests>:<ELORating>:<Kills>:<Deaths>:<PlayerName>]
 
 
 1v1 Arenas Logic
 
 */

bool DuelRequest::CheckExpired(){
    if(timeExpires < std::chrono::steady_clock::now()){
        return true;
    }
    return false;
}
int DuelRequest::GetTimeRemaining(){
    auto now = std::chrono::steady_clock::now();
    auto elapsed = std::chrono::duration_cast<std::chrono::seconds>(timeExpires - now).count();
    return (int)elapsed;
}


void DuelManager::CheckForExpiration(){
    //Should Remove Any Expired Duel Requests
    IncomingRequests.erase(std::remove_if(IncomingRequests.begin(), IncomingRequests.end(),
            [this](DuelRequest& currentRequest) {
                return currentRequest.CheckExpired();
            }), IncomingRequests.end());
    
    //Should I cancel my outgoing duel
    CheckShouldCancelOutgoingDuel();
}

void DuelManager::CreateIncomingRequest(std::string DuelID, std::chrono::steady_clock::time_point TimeSent, uint64_t SenderPlayerID, uint64_t SenderTribeID, std::string SenderPlayerName, int SenderLevel, float SenderELO, EKitType KitType, std::string ArenaType, std::string CustomMessage, std::chrono::steady_clock::time_point TimeExpires)
{
    CheckForDoubleDuel(SenderPlayerID);
    
    if(isPlayerIgnored(SenderPlayerID)){
        OutgoingData::getInstance().DeclineDuelRequest(DuelID, string_format("%s has Ignored you. ", PlayerStats::getInstance().GetPlayerName().c_str()));
        return;
    }
    
    if(!Variables.Accepting1v1s){
        OutgoingData::getInstance().DeclineDuelRequest(DuelID, string_format("%s has 1v1s Disabled. ", PlayerStats::getInstance().GetPlayerName().c_str()));
        return;
    }
    
    if(ArenaManager::getInstance().isPlayerInsideAnArena()){
        OutgoingData::getInstance().DeclineDuelRequest(DuelID, string_format("%s is Inside an Arena. ", PlayerStats::getInstance().GetPlayerName().c_str()));
        return;
    }
    
    if(TimeSent > TimeExpires){
        Utils::getInstance().ShowError(@"Expired");
        return;
    }
    
    DuelRequest newRequest;
    newRequest.DuelID = DuelID;
    newRequest.kitType = KitType;
    newRequest.ArenaType = ArenaType;
    newRequest.ChallengerPlayerID = SenderPlayerID;
    newRequest.ChallengerPlayerName = SenderPlayerName;
    newRequest.ChallengerLevel = SenderLevel;
    newRequest.ChallengerELO = SenderELO;
    newRequest.timeExpires = TimeExpires;
    newRequest.timeSent = TimeSent;
    newRequest.CustomMessage = CustomMessage;
    
    IncomingData::getInstance().SendClientMessage(string_format("%s sent you a duel request!", SenderPlayerName.c_str()));
    if(CustomMessage.length() > 0 && CustomMessage.length() < 80){
        IncomingData::getInstance().SendClientMessage(CustomMessage);
    }
    
    IncomingRequests.push_back(newRequest);
}

void DuelManager::CheckForDoubleDuel(uint64_t SenderID){
    //Checks for any incoming duels from that sender ID, if there are, delete them.
    IncomingRequests.erase(std::remove_if(IncomingRequests.begin(), IncomingRequests.end(),
            [this, SenderID](DuelRequest& currentRequest) {
                if(currentRequest.ChallengerPlayerID == SenderID){
                    OutgoingData::getInstance().DeclineDuelRequest(currentRequest.DuelID, string_format("You sent a new Duel Request"));
                    return true;
                }
                return false;
            }), IncomingRequests.end());
}

bool DuelManager::hasDuelRequest(std::string requestID){
    for(DuelRequest& currentRequest : IncomingRequests){
        if(currentRequest.DuelID == requestID){
            return true;
        }
    }
    return false;
}
bool DuelManager::hasDuelRequestFromPlayer(uint64_t playerID){
    for(DuelRequest& currentRequest : IncomingRequests){
        if(currentRequest.ChallengerPlayerID == playerID){
            return true;
        }
    }
    return false;
}
void DuelManager::cancelDuelRequest(std::string requestID, std::string Reason){
    IncomingRequests.erase(std::remove_if(IncomingRequests.begin(), IncomingRequests.end(),
            [this, requestID, Reason](DuelRequest& currentRequest) {
                if(currentRequest.DuelID == requestID){
                    IncomingData::getInstance().SendClientMessage(string_format("Duel %s was canceled by %s Reaason: %s", requestID.c_str(), currentRequest.ChallengerPlayerName.c_str(), Reason.c_str()));
                    return true;
                }
                return false;
            }), IncomingRequests.end());
}
void DuelManager::cancelDuelRequestFromPlayer(uint64_t playerID, std::string Reason){
    IncomingRequests.erase(std::remove_if(IncomingRequests.begin(), IncomingRequests.end(),
            [this, playerID, Reason](DuelRequest& currentRequest) {
                if(currentRequest.ChallengerPlayerID == playerID){
                    IncomingData::getInstance().SendClientMessage(string_format("Duel %s was canceled by %s Reason: %s", currentRequest.DuelID.c_str(), currentRequest.ChallengerPlayerName.c_str(), Reason.c_str()));
                    return true;
                }
                return false;
            }), IncomingRequests.end());
}
//on click in menu
void DuelManager::DeclineDuelRequest(std::string requestID){
    if(hasDuelRequest(requestID)){
        DuelRequest& request = getForID(requestID);
        
        //first, send the message to the server that i decline the request
        OutgoingData::getInstance().DeclineDuelRequest(requestID, string_format("%s rejected your duel request.", PlayerStats::getInstance().GetPlayerName().c_str()));
        
        //next, remove it from my incoming requests request menu
        IncomingRequests.erase(std::remove_if(IncomingRequests.begin(), IncomingRequests.end(),
                [this, requestID](DuelRequest& currentRequest) {
                    if(currentRequest.DuelID == requestID){
                        return true;
                    }
                    return false;
                }), IncomingRequests.end());
    }
}

void DuelManager::AcceptDuelRequest(std::string requestID){
    if(hasDuelRequest(requestID)){
        DuelRequest& request = getForID(requestID);
        
        //First, find an available arena. For now, we will just assume it succeded, I might change this later if I remember.
        //Arena Type will be something like "Duel_Doed"
        std::string AvailableArena = ArenaManager::getInstance().GetAvailableDuelArena(request.ArenaType);
        
        //Second, tell the server I accepted the duel request
        //void OutgoingData::AcceptDuelRequest(std::string DuelID, uint64_t DuelSenderPlayerID, uint64_t DuelAccepterPlayerID, uint64_t DuelAccepterTribeID, std::string ArenaID){
        OutgoingData::getInstance().AcceptDuelRequest(requestID, request.ChallengerPlayerID, PlayerStats::getInstance().GetPlayerID(), PlayerStats::getInstance().GetTribeID(), AvailableArena.c_str());
        
        //Next, start the client side joining actions
        DuelArena& arena = ArenaManager::getInstance().DuelArenaForString(AvailableArena);
        
        //like a dumbass I didn't set up any way to get the accepting player the enemy tribe ID. lol
        arena.StartFight(PlayerStats::getInstance().GetPlayerID(), PlayerStats::getInstance().GetTribeID(), request.ChallengerPlayerID, 0, false, request.kitType);
        
        //Finally, remove the duel request from my list
        IncomingRequests.erase(std::remove_if(IncomingRequests.begin(), IncomingRequests.end(),
                [this, requestID](DuelRequest& currentRequest) {
                    if(currentRequest.DuelID == requestID){
                        return true;
                    }
                    return false;
                }), IncomingRequests.end());
    }
}

//std::vector<DuelRequest> IncomingRequests;
DuelRequest& DuelManager::getForID(std::string requestID){
    for(DuelRequest& request : IncomingRequests){
        if(request.DuelID == requestID) return request;
    }
    return IncomingRequests[0];
}
//void AcceptDuelRequest(DuelRequest& request);







void IgnoredPlayer::RemoveFromPlist(){
    NSString* IgnorePath = GetSavePath();
    NSMutableDictionary *IgnoredPlayerData = [[NSMutableDictionary alloc] initWithContentsOfFile:IgnorePath];
    if (!IgnoredPlayerData) {
        // If there's no data, there's nothing to remove
        return;
    }

    // Remove the player data for the given PlayerID
    [IgnoredPlayerData removeObjectForKey:@(PlayerID)];

    // Save the updated dictionary back to the plist file
    [IgnoredPlayerData writeToFile:IgnorePath atomically:YES];
}
void IgnoredPlayer::SaveToPlist(){
    if(!isIgnored){
        RemoveFromPlist();
    }
    NSString* IgnorePath = GetSavePath();
    NSMutableDictionary *IgnoredPlayerData = [[NSMutableDictionary alloc] initWithContentsOfFile:IgnorePath];
    if (!IgnoredPlayerData) {
        IgnoredPlayerData = [[NSMutableDictionary alloc] init];
    }

    // Create a dictionary to hold the player data
    NSMutableDictionary *PlayerData = [[NSMutableDictionary alloc] init];
    [PlayerData setObject:@(isIgnored) forKey:@"IsIgnored"];
    [PlayerData setObject:StringToNSString(PlayerName) forKey:@"PlayerName"];

    // Save the player data dictionary to the main dictionary with PlayerID as the key
    [IgnoredPlayerData setObject:PlayerData forKey:@(PlayerID)];

    [IgnoredPlayerData writeToFile:IgnorePath atomically:YES];
}

NSString* IgnoredPlayer::GetSavePath(){
    // Path to the Plist
    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"IgnoredPlayers.plist"];
    
    //Create the Plist if it doesn't already exist
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSDictionary *initialData = @{};
        [initialData writeToFile:filePath atomically:YES];
    }
    
    return filePath;
}





bool DuelManager::isPlayerIgnored(uint64_t playerID){
    //std::vector<IgnoredPlayer> IgnoredPlayers;
    for(IgnoredPlayer& current : IgnoredPlayers){
        if(current.PlayerID == playerID)
            return current.isIgnored;
    }
    
    return false;
}
IgnoredPlayer& DuelManager::getForPlayerID(uint64_t PlayerID)
{
    for(IgnoredPlayer& current : IgnoredPlayers){
        if(current.PlayerID == PlayerID)
            return current;
    }
    
    static IgnoredPlayer noResult = IgnoredPlayer(0, "no name", false);
    return noResult;
}


void DuelManager::SaveIgnoredPlayersList(){
    for(IgnoredPlayer& current : IgnoredPlayers){
        current.SaveToPlist();
    }
}
void DuelManager::LoadIgnoredPlayersList(){
    IgnoredPlayers.clear();
    NSString* IgnoredPlayersPath = IgnoredPlayer::GetSavePath();
    NSDictionary *IgnoredPlayersData = [[NSDictionary alloc] initWithContentsOfFile:IgnoredPlayersPath];

    if (IgnoredPlayersData) {
        for (NSNumber *key in IgnoredPlayersData) {
            NSDictionary *PlayerData = [IgnoredPlayersData objectForKey:key];
            if (PlayerData) {
                NSNumber *IsIgnoredValue = [PlayerData objectForKey:@"IsIgnored"];
                NSString *PlayerNameValue = [PlayerData objectForKey:@"PlayerName"];
                if (IsIgnoredValue && PlayerNameValue) {
                    NSInteger playerID = [key integerValue];
                    bool isIgnored = [IsIgnoredValue boolValue];
                    NSString *playerName = PlayerNameValue;
                    
                    IgnoredPlayer newPlayer = IgnoredPlayer(playerID, [playerName UTF8String], isIgnored);
                    IgnoredPlayers.push_back(newPlayer);
                }
            }
        }
    }
}
void DuelManager::IgnorePlayer(uint64_t PlayerID, std::string PlayerName){
    //save as Key = PlayerID,
    if(isPlayerIgnored(PlayerID)){
        getForPlayerID(PlayerID).PlayerName = PlayerName;
    }
    
    IgnoredPlayer newIgnoredPlayer = IgnoredPlayer(PlayerID, PlayerName, true);
    IgnoredPlayers.push_back(newIgnoredPlayer);
    
    
    
    SaveIgnoredPlayersList();
}
void DuelManager::unIgnorePlayer(uint64_t PlayerID){
    if(isPlayerIgnored(PlayerID)){
        
        //set the player to no longer ignored
        getForPlayerID(PlayerID).isIgnored = false;
        
        //now removed any not ignored players from the plist
        IgnoredPlayers.erase(std::remove_if(IgnoredPlayers.begin(), IgnoredPlayers.end(),
                [this, PlayerID](IgnoredPlayer& currentPlayer) {
                    if(currentPlayer.isIgnored == false){
                        currentPlayer.SaveToPlist();
                        return true;
                    }
                    return false;
                }), IgnoredPlayers.end());
        
        //Now save the list to plist
        SaveIgnoredPlayersList();
        
    }
    else {
        IncomingData::getInstance().SendClientMessage("ERR: Player is not ignored.");
    }
}



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

// ServerChat ArenaData:DuelData:DuelInitiate:<DuelID>:<Timestamp>:<SenderPlayerID>:<SenderTribeID>:<SenderPlayerName>:<SenderLevel>:<SenderELO>:<RecievingPlayerID>:<ArenaType>:<KitType>:<CustomMessage>:<ExpirationTime>
void DuelManager::SendDuelRequest(std::string toPlayerName, std::string CustomMessage, uint64_t toPlayerID, EKitType kitType, std::string ArenaType, int RequestDuration){
    long long currentTimeMS = std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::system_clock::now().time_since_epoch()).count();
    
    std::string DuelIdentifier = string_format("%s_%lld", ArenaType.c_str(), currentTimeMS);
    auto Timestamp = std::chrono::steady_clock::now();
    auto ExpirationTime = Timestamp + std::chrono::seconds(RequestDuration);
    
    long long TimestampMS = currentTimeMS;
    long long ExpirationMS = currentTimeMS + RequestDuration * 1000; //std::chrono::duration_cast<std::chrono::milliseconds>(ExpirationTime.time_since_epoch()).count();
    
    uint64_t SenderPlayerID = PlayerStats::getInstance().GetPlayerID();
    uint64_t SenderTribeID = PlayerStats::getInstance().GetTribeID();
    std::string SenderPlayerName = PlayerStats::getInstance().GetPlayerName();
    int SenderLevel = PlayerStats::getInstance().GetPlayerLevel();
    float SenderELO = PlayerStats::getInstance().ELO;
    if(CustomMessage.length() < 2){
        CustomMessage = "Come Fight Me!";
    }
    
    
    //Send the Duel Request
    OutgoingData::getInstance().InitiateDuelRequest(DuelIdentifier, TimestampMS, SenderPlayerID, SenderTribeID, SenderPlayerName, SenderLevel, SenderELO, toPlayerID, ArenaType, kitType, CustomMessage, ExpirationMS);
    
    //Now I need to add the request to my outgoing duels
    OutgoingDuel currentDuelRequest;
    currentDuelRequest.isValid = true;
    currentDuelRequest.DuelID = DuelIdentifier;
    currentDuelRequest.toPlayerName = toPlayerName;
    currentDuelRequest.CustomMessage = CustomMessage;
    currentDuelRequest.toPlayerID = toPlayerID;
    currentDuelRequest.kitType = kitType;
    currentDuelRequest.timeSent = Timestamp;
    currentDuelRequest.timeExpires = ExpirationTime;
    
    sentDuel = currentDuelRequest;
}

void DuelManager::CheckShouldCancelOutgoingDuel(){
    if(sentDuel.isValid){
        if(sentDuel.timeExpires <  std::chrono::steady_clock::now()){
            sentDuel.isValid = false;
            IncomingData::getInstance().SendClientMessage("Your Duel request Expired");
        }
        
        if(!SafeZone::getInstance().isPlayerInsideSafeZone()){
            sentDuel.isValid = false;
            IncomingData::getInstance().SendClientMessage("You left the save zone so your duel was canceled");
            OutgoingData::getInstance().CancelDuelRequest(sentDuel.DuelID, "player joined an arena", sentDuel.toPlayerID, PlayerStats::getInstance().GetPlayerID());
        }
        
    }
}

void DuelManager::CancelOutgoingDuelRequest(){
    if(sentDuel.isValid){
        sentDuel.isValid = false;
        OutgoingData::getInstance().CancelDuelRequest(sentDuel.DuelID, string_format("%s canceled their duel request.", PlayerStats::getInstance().GetPlayerName().c_str()), sentDuel.toPlayerID, PlayerStats::getInstance().GetPlayerID());
    }
    
}

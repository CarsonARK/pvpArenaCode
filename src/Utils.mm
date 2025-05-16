//
//  Utils.m
//  PVPArenaDylib
//
//  Created by Carson Mobile on 6/10/24.
//

#import <Foundation/Foundation.h>
#include "../Includes.h"

//Send an Encrypted Request, to prevent it being repeated too often make it so that it times out after 1 second.
//IMPL: Send Encrypted the Victim ID, Murdere ID, Both player names, and the Unix Timestamp.
//Server Side:
   //Verify the timestamp isn't more than a second old
   //If either the Victim or the Murdere is not in the database, add them with a base ELO of 1,000
   //Add One Kill to the Murderer, and One Death to the victim
   //Do the ELO Calulation, and change each player's ELO accordingly.
   //Update the database for the player ID with the name every time incase someone changes their name


//Database: PlayerID - Player Name - ELO - Highest Killstreak - Current Killstreak - Kills - Deaths - ShopPremiumsShit

//FUTURE - Add Killstreaks.
//NOTE: Killstreaks will only apply if the player you killed is within a certain ELO range of you,
//like if they are more than 400 points below you the killstreak wont apply.
//this restriction is to attempt to prevent alt farming

//In the database for each player have "Successive Kills". When a player dies, that gets reset to 0. Also have a "Maximum Kill Streak" Counter
//Each kill a player gets will increase it, with certain rewards
//At 2 Kills, the player can redeem Element
//At 5 Kills, the player can redeem shock darts and pan
//At 8 Kills, the player can redeem a Tek Rifle & Element & Tek Shield
//At 10 Kills, the player can redeem a Theri (Find a way to max out the EXP)


//Basically in report kills the response to the client will be YOUR current killstrek, and there will be a killstreak array and you just set it to true at that one


/*
 Current Bugs: Recieved Duels aren't expiring
 
 
 
 FUTURE FOR LEGIT OFFICIAL:
    FOV
    Crosshair

    
    
    if the server is up for a long time then there can be a buy moratorium for 1 hour thing for tame stat glitching
 
    Free ways of getting amber:
        - Every 15 minute get 5 amber
        - Break Enemy Turret = 1 amber (if it's possible to figure this out)
        - Complete dodo pro hunt pursuit -> 200 Amber
        - Complete last photography pursuit -> 100 Amber
        - Complete Trophy Room -> 40 Amber
        - Complete Grand Vooyage -> 5 Amber
        - Complete Tame Quetz -> 50 Amber
        - Kill Enemy Player -> 2 Amber
 
    "Arketype Shop"
    Pan -> 50 Amber (only can be purchased in your own ORP Range)
    
 
    (obviously yea people can farm shit like this but so what)
        
 
    
    Disable Alliances (Small Tribes)
    Patch Meshing (nobuild & linecheck)
    Patch invisible
    Chat Translate with ServerChat
    Automatic amber purchases
 
    Free Transfer tickets -> It really sucks not being able to transfer.
 
    Disable Primal Drop -> Sure it can be convenient but it can also really fuck up the game balance
    
    Custom Amber Shop - buy bone skins and shit
 
    Turn Auto into Eerie -> When you look at an auto placed in your tribe, you can press a button which demos
        the auto and gives u an eerie only if the demolish is successful (this is the form of arketypes, no pans lol)
 
    Online Amber -> Every time the server saves, every online player gets 5 amber
 
    StarterKit -> once per player ID per server -> Just like flak kit & tools
 
    Make transfer dupe harder for people who do have crash -> Hide Server Save Timer & Make Server Saving... not show up in chat.
    Try to think of other ways to make it harder
 
    -> cap bear traps & fence foundations & pipes per area
 
    Custom Loot Drops / Purchase Packages?
    No box mammoth (reduce cap)
    Disable sittong on any mounted turret
    Offline Raid Protection
        - instead Have ORP beacon be a small metal sign , and free, write the timestamp on the sign, verify timestamp with website, maybe try to rename the sign crafting shit to ORP becaon would be funny
        - Buy "ORP Beacon" for 3,000 amber (Just a tribute terminal, then GiveToMe), can only place if no enemy structures within 200m,
        enemys can't place within 50m of ORP Beacon, only can do things with ORP becaon if actor array is less than certain ammount (to prevent abuse),
        When ORP tribe offline for a certain timeframe, have any enemy within 200M get slowed 50%. Have all online players actively keep a running list of ORP
        beacons which gets updated every 5 seconds. Disable all allies and shit. Have ORP beacons show on global ESP. Only one ORP beacon within 200m of eachother
        (when place beacon make sure player on server for 30 seconds+ & less than 5k? structures nearby and no enemy structures nearby)
        - Need to find some way to prevent people from placing this in ghost mode or putting in enemy range somehow idk still alot to figure out.\
 
 
    Add a menu where you can ingame without going back to menu go between servers (including arena, arena should be part of the official ipa)
    basically server chat login is when u remove the server login password, and then set the server login password before traveling to another server ingame
    will make shit easier.
 
    Add auto chat translations with ServerChat!
    
 FUTURE:
    Add ways to create multiple kits, and change the kit shit to sliders
    save the kits however you want
    import and export individual kits
    set one kit as the "Default" Kit
    Set a kit for comp only, and fab only
    Have a section where you can create custom private 1v1 kits with basically every item imaginable, save them,
    and then choose one in the 1v1 menu, and send that kit to your opponent.
    
 TODO:
    When you get knocked out -> Start a 30 second timer, if you are still knocked out by the end you can suicide
    Make a way to share / export kits and import / download them built into the app.
    Make it so when a new player joins the arena you are currently in you get a popup at the top of your screen like
        "x player has joined your Arena" (look at the join server messages, will be similar)
 
 
 Functions to look at rn:
 PlayerController:
 void ClientMessage(struct FString S, struct FName Type, float MsgLifeTime);
 void ClientShowDeathReason(struct FString DeathReason);
 void ClientServerNotificationSingle(struct FString MessageText, struct FLinearColor MessageColor, float DisplayScale, float DisplayTime, struct UTexture2D* MessageIcon, struct USoundBase* SoundToPlay, int MessageTypeID); // Offset: 0x1010d33b4 // Return & Params: Num(7) Size(0x3c)
 void ClientServerNotification(struct FString MessageText, struct FLinearColor MessageColor, float DisplayScale, float DisplayTime, struct UTexture2D* MessageIcon, struct USoundBase* SoundToPlay); // Offset: 0x1010d2f2c // Return & Params: Num(6) Size(0x38)
 void ClientNotifyTorpidityIncrease();
 void ClientNotifySummonedDino(struct APrimalDinoCharacter* DinoClass);
 
 void ClientClearOldBeacons(); //just useful to remove dead beacon
 
 void NotifyPlayerJoined(struct FString ThePlayerName); //This might show the onscreen notification whatever
 
 

 And then have 1v1 Challenges with specific kits with options for every Arena, have 8 of each of the arenas available.
    Can line them up along the north outside of the map with predefined coordinates
 
 
 1v1: have 8 of each arena available, get all the coords and shit yk how it is. There will be 2 starting locations, one for each player.
 One location will be taken by the person who issues the challenge, the other will be taken by the one who recieves the challenge.
 In the 1v1 arena you should automatically kill any Unconsious / Logged Out PlayerID cus yk those shouldn't be in there.
 When one person kills the other, have the winner just automatically tpd out and shit & report the win.
 
 DuelArena shoud be a child of Arena, and ArgyDuel arena or something like that should be similar.
 
 for this keep track of the other person player ID & other person tribe ID, and automatically kill & Dino or player that shouldn't be there.
 
 Argy:
 1. Need to spawn it at Level 200 or sum (This should be the easy part), or even let the player's choose the level
 2. Need to level the argy to max exp without player getting leveled at all
 . Level Distribution: 200% movement speed, rest mele (cus bitch i dont feel like healing them)
 . Argy kits WONT include mele weapons
 . Auto Equip Gold Collar onto argy
    - Check if the argy has a collar equipped
    - If not, Equip it
 . All this needs to take place in less than a second and automatically
 . Arena will be large and the players will spawn on opposite sides
 
 During the arena if you see any players or argys who arent in a participating player or tribe ID then kill them automatically
 
        
    
 For flyer 1v1s have big boss arena areas along the East Coast
 
 
 Server will have to end up being like 50 slots, and have to grow discord alot.
 Maybe do like invite rewards of ingame amber or something at a certain point.
 Have an shop where people can buy ingame amber and have certain premiums as paid only.
    Basically, in stripe they will put in their email, and a code will be sent to them which can be redeemed
    ingame to unlock a shop item or give amber or something like that
 
    
    

 Potentially Allow Purchasing things with amber -> Remove the amber by crushing the dust then dropping the dust
 For example: have an amber shop where you can buy
 - 10x Shocking Darts for 20 amber
 - 1x Pan for 100 Amber
 - 1x Therizino for 200 Amber
 - 1x Rocket Launcher 10x Rockets for 50 Amber
 - Berry Juice? Wyvern Milk?
 
 - Rekit In Arena for 60 Amber
 - Another Idea:
    When you buy amber items they get added to your kit
    - Encrypted "Shop" Plist.
        - Basically just Encrypted the boolean value by the Item name and Player ID and save it as like Premiums<PlayerID>.plist
        - have a premiums database where people can "Upload" and "Downoad" premiums for player ID
        - Make an Auto Equip Graft (where you can select which one)
        - Make an Auto Equip Skins (where you can select which ones for each piece)
            - If you switch armor, the skin switches too.
                - This way of doing things is good because it means any skin can be a "premium" skin
 
        - Every time you buy a premium, start a 5 second timer to sync premiums with my server.
        - In the shop, have it so that you can't buy an item multiple times
        
        - for buying "personal" premiums, since I can't really authenticate it normally,
            have it say like serverchat AnticheatArenaData:BuyingPremium:<PlayerID>:<PremiumString> and then when i recieve
            that then i add it. Need to keep in mind buying large quantity items may cause issues, so buy like carno pheramones % 55.
 
        - another thing to buy could be like weapon color changing with hacks.
    - similar to the Kit stuff.
 
 
 Functions:
 
    Cancel:
 
    MultiUse (pickup item) -> This is so that I can drop dust & shit without anyone being able to grab it
    ServerUnlockPerMapExplorerNote
 
    For Equipping stuff:
    
 ServerRequestInventoryUseItemWithItem

 Dust / Buffs?:
 ServerRequestInventoryUseItem
 
 Drop:
 ServerRemovePawnItem
 
 
 have multiple arenas, and each arena has a list of all the players inside the bounds of the arena,
 and then you can choose which one to teleport too
 
 maybe make like an "Arena List" "isInAnArena"
 
 maybe different arenas for different kits too


    
 
 Test how to spawn a dino without it crashing the server!
    - Thoughts: Try all summon methods, maybe one just wont crash
    - Maybe spawn them outside the map
    - 
 
 
 FUTURE:
    Make weird names impossible?
 
    1v1 matchmaking

    Challenge other player in safe zone to 1v1:
        Choose from kits like Comp, Fabi, or default -> For these you can choose which arena to fight in
        or select like "Argy 1v1" which is in a 6x6x6 boss arena cube (yea i gotta do the math for that)
 
    Basically use the admin manager to check online players then get the location of all of them
    have locations for like 4 of each type of arena
    have a funciton to see what type of arena you are in and which one of the 4
    when you kill a player have it check if ur in ffa arena then do the ffa arena stuff or if ur in the
    1v1 arena and then have a custom message for that one, clear the arena & kys
    
    to challenge a player maybe send a direct message (if that's possible, still havn't tested it really)
    message should be like ArenaID, ArenaNumber, Kit Type, and the player challenging you.
 
    When you get a 1v1 invite you can accept it or deny it, if accept you direct message the player back some sort of acceptance
 
    to challenge a player to a 1v1 there should be a menu which shows all online players in safe zone, then you can click one and
    click challenge, then choose a gamemode, then choose an arena
 
    
        


 Make people lower level

 
 REMOVE Skins Button.
 Have Amber for killing people which can be used to buy skins
 For other Skins, have them be recieved after a certain number of kills or after a certain ELO
 
 
 
 Current Testing:
 
    HUD Notifications
 find Ghidra impl at NotifyPayerJoined_Impl
 void AddHUDNotification(struct FString NotificationString, struct FColor NotificationColor, struct UMaterialInterface* NotificationMaterial, struct UTexture2D* NotificationTexture, float DisplayTime, float DisplayScale, bool bIsSingleton, struct USoundBase* SoundToPlay, int MessageTypeID, enum class EHudNotificationType NotificationType, struct UPrimalItem* ItemClass, struct FString ItemName, int ItemQuantity, float ItemQuantityFloat, bool ignoreRedundant); // Offset: 0x10109ce08 // Return & Params: Num(15) Size(0x69)
 */

/*
 Where is server password Saved:
    Try Gworld + 958? -> This is the current map I'm on
 
    ShooterGameInstance + 93*0x8
 
 
 check FCharacterRelevanceCheck
 TMap<struct FString, struct FString>
 struct UPrimalLocalProfile* PrimalLocalProfile;
 
 struct UPrimalWordFilter* MainWordList; // Offset: 0x128 // Size: 0x20
     struct UPrimalWordFilter* MainNameWordList; // Offset: 0x148 // Size: 0x20
     struct TArray<struct FString> IllegalChatSequences; // Offset: 0x168 // Size: 0x10
     struct UPrimalWordFilter* ChineseWordList; /
 */


struct TMapCopy {
    char oldBytes[0x50];
};


static void (*ClientTravel)(UEngine* Engine, UWorld* World, const wchar_t* ServerIP, int TravelType) = (void(*)(UEngine*, UWorld*, const wchar_t*, int))getOffset(0x2b9dc88);
static void (*SetServerLoginPassword)(ULocalPlayer* ShooterLocalPlayer, FString* EnteredPassword, FString* ForIP, AShooterPlayerController_Menu* Menu) = (void(*)(ULocalPlayer*, FString*, FString*, AShooterPlayerController_Menu*))getOffset(0xb1efe8);

//Joins an Ark Mobile Server Given the correct IP and Password
//Password should be the Server Password, and the IP should be the server IP & Port formatted like IP:Port (eg 
void FunctionCalls::JoinServer(std::string ServerIP, std::string ServerPassword){
    
    MenuLoop::getInstance().isAdmin = false;
    
    if(MenuLoop::getInstance().hasLoggedIn){
        Utils::getInstance().ShowError(@"Please Relog. For now, you can only log in once per session.");
        return;
    }
    
    //Convert std::string to wString
    std::wstring WServerIP = std::wstring_convert<std::codecvt_utf8_utf16<wchar_t>>().from_bytes(ServerIP);
    std::wstring WServerPassword = std::wstring_convert<std::codecvt_utf8_utf16<wchar_t>>().from_bytes(ServerPassword);
    
    //Convert wString to FString
    FString ServerIPFString = FString(WServerIP.c_str());
    FString ServerPasswordFString = FString(WServerPassword.c_str());
    
    //Since I made the QuickOffsets namespace extremely memory safe, these do not work from the menu
    //ULocalPlayer* LocalPlayer = QuickOffsets::GetLocalPlayer();
    //AShooterPlayerController_Menu* Menu = (AShooterPlayerController_Menu*)QuickOffsets::GetPlayerController();
    
    //So instead we read them in a way which could cause null derefrence, but it is unlikely to crash.
    ULocalPlayer* LocalPlayer = UWorld::GetWorld()->GetOwningGameInstance()->GetLocalPlayers()[0];
    AShooterPlayerController_Menu* Menu = (AShooterPlayerController_Menu*)LocalPlayer->GetPlayerController();
    
    
    
    if(LocalPlayer->isA_Safe(StaticClass::LocalPlayer()) && Menu->isA_Safe(StaticClass::ShooterPlayerController_Menu())){

        //this changes the game write path 
        static long GGameIni = 0x42ff668;
        Write<FString>(getGameBase() + GGameIni, FString(L""));
        
        //Set the login password for the IP
        SetServerLoginPassword(LocalPlayer, &ServerPasswordFString, &ServerIPFString, Menu);
        

        
        UEngine* Engine = UEngine::GetEngine();
        UWorld* World = UWorld::GetWorld();
        
        if(Engine->isA_Safe(StaticClass::Engine()) && World->isA_Safe(StaticClass::World())){
            
            //Since the Password is set for the IP, we can now travel to it.
            ClientTravel(Engine, World, WServerIP.c_str(), 0);
            MenuLoop::getInstance().hasLoggedIn = true;
            
        } else {
            Utils::getInstance().ShowError(@"Could Not Travel");
        }
    }
    else {
        Utils::getInstance().ShowError(@"Could Not Login");
    }
}
/*
 To work on right now:
 1. Remove Chat Filter
 2. Make long chat messages go onto multiple lines
Future:
 Translate incoming chat messages using ServerChat
 Make a discord tribe log bot
 ORP with signs
 amber for pursuits
 try to make arketypes work on ipa
 
 */
// 1. Spawn Dino
// 2. Spawn Gold Chain
// 3. Max Level Dino
// 4. Spawn Dino Saddle
// 5. Auto Equip Saddle
// 6. Kill Off any unclaimed dinos / unconscious players
// 7. After arena is finished, unclaim all dinos you own. 
// void ServerGodConsoleCommandTwo(enum class EGameCheat cheatType, struct APrimalCharacter* aimedChar);
//
//Enter in the server admin password and activate admin for the player
//All Admin Utilities will be disabled for the player ingame,
//but this will allow us to run admin commands for the player programatically
void FunctionCalls::ActivateAdmin(std::string Password){
    
    FunctionQueue::GetI().AddTask([Password](){

        //Convert std::string to wString
        std::wstring WAdminPassword = std::wstring_convert<std::codecvt_utf8_utf16<wchar_t>>().from_bytes(Password);
        
        //Convert wString to FString
        FString ServerAdminPassword = FString(WAdminPassword.c_str());
        
        APlayerController* MyController = QuickOffsets::GetPlayerController();
        if(MyController->isA_Safe(StaticClass::ShooterPlayerController())){
            
            //For some reason, the password must be entered twice
            MyController->CheckCheatsPassword(ServerAdminPassword);
            MyController->CheckCheatsPassword(ServerAdminPassword);
        }
    });
}

void FunctionCalls::CheatCommand(std::string Command){
    FunctionQueue::GetI().AddTask([Command](){
    
        //Convert std::string to wString
        std::wstring WCommand = std::wstring_convert<std::codecvt_utf8_utf16<wchar_t>>().from_bytes(Command);
        
        //Convert wString to FString
        FString CheatCommand = FString(WCommand.c_str());
        
        APlayerController* MyController = QuickOffsets::GetPlayerController();
        if(MyController->isA_Safe(StaticClass::ShooterPlayerController())){
            MyController->ServerCheat(CheatCommand);
            
        }
    });
}

void FunctionCalls::Suicide(){
    FunctionQueue::GetI().AddTask([](){
        APlayerController* MyController = QuickOffsets::GetPlayerController();
        if(MyController->isA_Safe(StaticClass::ShooterPlayerController())){
            MyController->ServerSuicide();
        }
    });
    
}

/*
 
 //Now Send the Death Announcement
 std::string deathMessage = string_format("%s was killed by %s", EnemyPlayerName.c_str(), MyPlayerName.c_str());
 
 //Convert the std::string into a wide string
 std::wstring WdeathMessage = std::wstring_convert<std::codecvt_utf8_utf16<wchar_t>>().from_bytes(deathMessage);
 
 //Convert wString to FString
 FString DeathMessageFString = FString(WdeathMessage.c_str());
 
 Controller->ServerSendAnnouncement(DeathMessageFString, 1);
 void SendAnnouncement(std::string AnnouncementMessage);
 */
void FunctionCalls::SendAnnouncement(std::string AnnouncementMessage){
    FunctionQueue::GetI().AddTask([AnnouncementMessage](){
    
        std::wstring WAnnouncementMessage = std::wstring_convert<std::codecvt_utf8_utf16<wchar_t>>().from_bytes(AnnouncementMessage);
        FString Announcement = FString(WAnnouncementMessage.c_str());
        
        APlayerController* MyController = QuickOffsets::GetPlayerController();
        if(MyController->isA_Safe(StaticClass::ShooterPlayerController())){
            MyController->ServerSendAnnouncement(Announcement, 1);
            
        }
    });
}

//Temporary Implimentation is just Leave Me Alone
// In future, choose a random spot outside the border
// teleport player there
// so they don't see other players & dinos dont kill them


/*
 Outside Map Bounds:
 Negative:
    X
    Y
 Positive:
    X
    Y
 
 Spawn Height
 */

void Utils::HelperSpawnItem(std::string ItemBlueprintString, int numStacks, int ammount){
    for(int i = 0; i < numStacks; i++){
        i = i % 250;
        FunctionCalls::getInstance().CheatCommand(string_format("Admincheat GiveSlotItem \"%s\" %d %d", ItemBlueprintString.c_str(), i+20, ammount));
    }
}
/*
 Item - Quantity
 Med Brews - 100
 Stam Brews - 100
 Focal Chille - 1
 

 
 Fab Snipers - 2
 Sniper Ammo - 150
 
 
 
 
 
 */

/*
 Consumables:
    Med Brews - 100
    Stam Brews - 100
    Focal Chille - 1
    Stimulant - 50
    Parachute - 10
    Legday, Feast, Thick Skin
 */
void Utils::SpawnConsumables(){
    HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Consumables/PrimalItemConsumable_HealSoup.PrimalItemConsumable_HealSoup_C'", 1, 100);
    HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Consumables/PrimalItemConsumable_StaminaSoup.PrimalItemConsumable_StaminaSoup_C'", 1, 100);
    HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Consumables/PrimalItemConsumable_Soup_FocalChili.PrimalItemConsumable_Soup_FocalChili_C'", 1, 1);
    HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Consumables/PrimalItemConsumable_Stimulant.PrimalItemConsumable_Stimulant_C'", 1, 50);
    HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Consumables/PrimalItemConsumable_Soup_ShadowSteak.PrimalItemConsumable_Soup_ShadowSteak_C'", 1, 15);
    HelperSpawnItem("Blueprint'/Game/PrimalEarth/Test/PrimalItemConsumable_LegDay.PrimalItemConsumable_LegDay_C'", 1, 1);
    HelperSpawnItem("Blueprint'/Game/PrimalEarth/Test/PrimalItemConsumable_Feast.PrimalItemConsumable_Feast_C'", 1, 1);
    HelperSpawnItem("Blueprint'/Game/PrimalEarth/Test/PrimalItemConsumable_ThickSkin.PrimalItemConsumable_ThickSkin_C'", 1, 1);
    HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Consumables/BaseBPs/PrimalItemConsumableBuff_Parachute.PrimalItemConsumableBuff_Parachute_C'", 1, 10);
}
/*
 Comp:
    1 Comp Bow
    100 Metal Arrows
 */
void Utils::SpawnComp(){
    HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Weapons/PrimalItem_WeaponCompoundBow.PrimalItem_WeaponCompoundBow_C'", 1, 1);
    HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Weapons/PrimalItemAmmo_CompoundBowArrow.PrimalItemAmmo_CompoundBowArrow_C'", 2, 50);
}
/*
 Fab:
    1 Fab Sniper
    70 Advanced Ammo
 */
void Utils::SpawnFabi(){
    HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Weapons/PrimalItem_WeaponMachinedSniper.PrimalItem_WeaponMachinedSniper_C'", 2, 1);
    HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Weapons/PrimalItemAmmo_AdvancedSniperBullet.PrimalItemAmmo_AdvancedSniperBullet_C'", 4, 35);
    HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/WeaponAttachments/PrimalItemWeaponAttachment_Silencer.PrimalItemWeaponAttachment_Silencer_C'", 1, 1);
    HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/WeaponAttachments/PrimalItemWeaponAttachment_Laser.PrimalItemWeaponAttachment_Laser_C'", 1, 1);
}
/*
 Assault Rifle:
     1x Assault Rifle
     300x Assault Rifle Ammo
 */
void Utils::SpawnAssaultRifle(){
    HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Weapons/PrimalItem_WeaponRifle.PrimalItem_WeaponRifle_C'", 1, 1);
    HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Weapons/PrimalItemAmmo_AdvancedRifleBullet.PrimalItemAmmo_AdvancedRifleBullet_C'", 6, 50);
}
/*
 Shotgun:
    1x Shotgun
    200x Shotgun Shells
 */
void Utils::SpawnShotgun(){
    HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Weapons/PrimalItem_WeaponMachinedShotgun.PrimalItem_WeaponMachinedShotgun_C'", 1, 1);
    HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Weapons/PrimalItemAmmo_SimpleShotgunBullet.PrimalItemAmmo_SimpleShotgunBullet_C'", 4, 50);
}
/*
 Longneck:
    2 Longneck
    100 Simple Bullets
    30 Regular Tranq Darts
    1 Scope
 */
void Utils::SpawnLongneck(){
    HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Weapons/PrimalItem_WeaponOneShotRifle.PrimalItem_WeaponOneShotRifle_C'", 1, 2);
    HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Weapons/PrimalItemAmmo_SimpleRifleBullet.PrimalItemAmmo_SimpleRifleBullet_C'", 2, 50);
    HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Weapons/PrimalItemAmmo_TranqDart.PrimalItemAmmo_TranqDart_C'", 1, 30);
    HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/WeaponAttachments/PrimalItemWeaponAttachment_Scope.PrimalItemWeaponAttachment_Scope_C'", 1, 1);
}
/*
 Mele:
    1 Prim Club
    1 Prim Sword
 */
void Utils::SpawnMele(){
    HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Weapons/PrimalItem_WeaponStoneClub.PrimalItem_WeaponStoneClub_C'", 1, 1);
    HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Weapons/PrimalItem_WeaponSword.PrimalItem_WeaponSword_C'", 1, 1);
}
/*
 Arketype Warrior:
    2 Aerial Symbiote
    2 Frog Feet
    2 Eerie Pistol
 */
void Utils::SpawnArketypes(){
    HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Misc/Special/PrimalItem_DragonFlyWings.PrimalItem_DragonFlyWings_C'", 2, 1);
    HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Armor/ARKetypes/PrimalItemArmor_FrogFeet.PrimalItemArmor_FrogFeet_C'", 2, 1);
    HelperSpawnItem("Blueprint'/Game/Mobile/Pursuits/Caves/TributeRewards/PrimalItem_WeaponSuperGun.PrimalItem_WeaponSuperGun_C'", 2, 1);
}
/*
 TEK Armor:
    2 Sets of prim TEK
 */
void Utils::SpawnTekArmor(){
    
    HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Armor/TEK/PrimalItemArmor_TekBoots.PrimalItemArmor_TekBoots_C'", 2, 1);
    HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Armor/TEK/PrimalItemArmor_TekGloves.PrimalItemArmor_TekGloves_C'", 2, 1);
    HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Armor/TEK/PrimalItemArmor_TekHelmet.PrimalItemArmor_TekHelmet_C'", 2, 1);
    HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Armor/TEK/PrimalItemArmor_TekPants.PrimalItemArmor_TekPants_C'", 2, 1);
    HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Armor/TEK/PrimalItemArmor_TekShirt.PrimalItemArmor_TekShirt_C'", 2, 1);
}
/*
 Riot Armor:
    2 Sets of Riot
 */
void Utils::SpawnRiotArmor(){
    HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Armor/Riot/PrimalItemArmor_RiotBoots.PrimalItemArmor_RiotBoots_C'", 2, 1);
    HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Armor/Riot/PrimalItemArmor_RiotGloves.PrimalItemArmor_RiotGloves_C'", 2, 1);
    HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Armor/Riot/PrimalItemArmor_RiotHelmet.PrimalItemArmor_RiotHelmet_C'", 2, 1);
    HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Armor/Riot/PrimalItemArmor_RiotPants.PrimalItemArmor_RiotPants_C'", 2, 1);
    HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Armor/Riot/PrimalItemArmor_RiotShirt.PrimalItemArmor_RiotShirt_C'", 2, 1);
}
/*
 Weight:
    500 Black Pearls
 */
void Utils::SpawnWeight(){
    HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Resources/PrimalItemResource_BlackPearl.PrimalItemResource_BlackPearl_C'", 1, 500);
}
/*
 SKINS:
    All Important Skins / Grafts
 */
void Utils::SpawnCostumes(){
    HelperSpawnItem("Blueprint'/Game/Mobile/SkinGrafts/PrimalItem_ImplantGraft_Yahweh.PrimalItem_ImplantGraft_Yahweh_C'", 1, 1);
    HelperSpawnItem("Blueprint'/Game/Mobile/SkinGrafts/PrimalItem_ImplantGraft_Eerie.PrimalItem_ImplantGraft_Eerie_C'", 1, 1);
    HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Armor/Leather/PrimalItemSkin_BirthdayPants.PrimalItemSkin_BirthdayPants_C'", 1, 1);
    HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Armor/Leather/PrimalItemSkin_BirthdayShirt.PrimalItemSkin_BirthdayShirt_C'", 1, 1);
    HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Armor/Leather/PrimalItemSkin_DinoWitchHat.PrimalItemSkin_DinoWitchHat_C'", 1, 1);
    HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Armor/Leather/PrimalItem_Skin_Account_DevKitMaster.PrimalItem_Skin_Account_DevKitMaster_C'", 1, 1);
    HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Armor/Leather/PrimalItem_Skin_Account_GameTester.PrimalItem_Skin_Account_GameTester_C'", 1, 1);
    HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Armor/Leather/PrimalItem_Skin_Account_WildcardAdmin.PrimalItem_Skin_Account_WildcardAdmin_C'", 1, 1);
    HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Armor/Skin/PrimalItemSkin_BetaHat.PrimalItemSkin_BetaHat_C'", 1, 1);
    HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Armor/Skin/PrimalItemSkin_ManticoreBoots.PrimalItemSkin_ManticoreBoots_C'", 1, 1);
    HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Armor/Skin/PrimalItemSkin_ManticoreGloves.PrimalItemSkin_ManticoreGloves_C'", 1, 1);
    HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Armor/Skin/PrimalItemSkin_ManticoreHelmet.PrimalItemSkin_ManticoreHelmet_C'", 1, 1);
    HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Armor/Skin/PrimalItemSkin_ManticorePants.PrimalItemSkin_ManticorePants_C'", 1, 1);
    HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Armor/Skin/PrimalItemSkin_ManticoreShield.PrimalItemSkin_ManticoreShield_C'", 1, 1);
    HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Armor/Skin/PrimalItemSkin_ManticoreShirt.PrimalItemSkin_ManticoreShirt_C'", 1, 1);
    HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Armor/Skin/PrimalItemSkin_RazerHat.PrimalItemSkin_RazerHat_C'", 1, 1);
    HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Armor/Skin/PrimalItemSkin_SpinnerHat.PrimalItemSkin_SpinnerHat_C'", 1, 1);
    HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Armor/Skin/PrimalItemSkin_WitchHat.PrimalItemSkin_WitchHat_C'", 1, 1);
    HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Armor/Leather/PrimalItemSkin_FishClub.PrimalItemSkin_FishClub_C'", 1, 1);
    HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Armor/Leather/PrimalItemSkin_CandyClub.PrimalItemSkin_CandyClub_C'", 1, 1);
}

/*
 Spawns Most Dyes so you can color your weapons
 */
void Utils::SpawnDyes(){
    HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/PrimalItemDye_ActuallyMagenta.PrimalItemDye_ActuallyMagenta_C'", 1, 1);
    HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/PrimalItemDye_Black.PrimalItemDye_Black_C'", 1, 1);
    HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/PrimalItemDye_Blue.PrimalItemDye_Blue_C'", 1, 1);
    HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/PrimalItemDye_Cyan.PrimalItemDye_Cyan_C'", 1, 1);
    HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/PrimalItemDye_Forest.PrimalItemDye_Forest_C'", 1, 1);
    HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/PrimalItemDye_Green.PrimalItemDye_Green_C'", 1, 1);
    HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/PrimalItemDye_Navy.PrimalItemDye_Navy_C'", 1, 1);
    HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/PrimalItemDye_Olive.PrimalItemDye_Olive_C'", 1, 1);
    HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/PrimalItemDye_Orange.PrimalItemDye_Orange_C'", 1, 1);
    HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/PrimalItemDye_Pink.PrimalItemDye_Pink_C'", 1, 1);
    HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/PrimalItemDye_Purple.PrimalItemDye_Purple_C'", 1, 1);
    HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/PrimalItemDye_Red.PrimalItemDye_Red_C'", 1, 1);
    HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/PrimalItemDye_Royalty.PrimalItemDye_Royalty_C'", 1, 1);
    HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/PrimalItemDye_Sky.PrimalItemDye_Sky_C'", 1, 1);
    HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/PrimalItemDye_White.PrimalItemDye_White_C'", 1, 1);
    HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/PrimalItemDye_Yellow.PrimalItemDye_Yellow_C'", 1, 1);
    HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/PrimalItemDye_Slate.PrimalItemDye_Slate_C'", 1, 1);
    HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/PrimalItemDye_Sky.PrimalItemDye_Sky_C'", 1, 1);
}
/*
 Spawns a mindwipe tonic to reapply your levelup points
 */
void Utils::SpawnMindwipe(){
    HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Consumables/BaseBPs/PrimalItemConsumableRespecSoup.PrimalItemConsumableRespecSoup_C'", 1, 1);
}
/*
 Spawns Appearance Change & Rename Tickets
 */
void Utils::SpawnTickets(){
    HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Consumables/PrimalItem_RenameTicket.PrimalItem_RenameTicket_C'", 1, 1);
    HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Consumables/PrimalItem_AppearanceChangeTicket.PrimalItem_AppearanceChangeTicket_C'", 1, 1);
}
/*
 Clear Inventory:
    Runs the clear inventory Command
 */
void Utils::ClearInventory(bool bClearInventory, bool bClearSlotItems, bool bClearEquippedItems){
    AShooterCharacter* ShooterCharacter = QuickOffsets::GetShooterCharacter();
    if(ShooterCharacter->IsA(StaticClass::ShooterCharacter())){
        FunctionCalls::getInstance().CheatCommand(string_format("ClearPlayerInventory %ld %d %d %d", ShooterCharacter->GetLinkedPlayerDataID(), bClearInventory, bClearSlotItems, bClearEquippedItems));
    }
}

//Heals the Player to full, inteded to be called every kill.
//void ServerGodConsoleCommand(enum class EGameCheat cheatType, float ExtraData, float ExtraDataTwo, float ExtraDataThree);
void Utils::HealAll(){
    FunctionQueue::GetI().AddTask([](){
        APlayerController* MyController = QuickOffsets::GetPlayerController();
        if(MyController->isA_Safe(StaticClass::ShooterPlayerController())){
            MyController->ServerGodConsoleCommand(3, 0, 0, 0);
        }
    });
}

void Utils::GiveKillExp(float ExpAmmount){
    AShooterCharacter* ShooterCharacter = QuickOffsets::GetShooterCharacter();
    if(ShooterCharacter->IsA(StaticClass::ShooterCharacter())){
        FunctionCalls::getInstance().CheatCommand(string_format("GiveExpToPlayer %ld %.0f 0 1", ShooterCharacter->GetLinkedPlayerDataID(), ExpAmmount));
    }
}
void Utils::GiveAmber(int AmberAmmount){
    HelperSpawnItem("Blueprint'/Game/PrimalEarth/CoreBlueprints/Resources/PrimalItemResource_DinoAmber.PrimalItemResource_DinoAmber_C'", 1, AmberAmmount);
}



void Utils::HandleFOV(){
    UShooterGameUserSettings* GameUserSettings = QuickOffsets::GetGameUserSettings();
    if(GameUserSettings->IsValid()){
        GameUserSettings->GetFOVMultiplier() = Variables.FOV;
    }
}
void Utils::HandleTimeOfDay(){
    AMatineeActor* DaytimeMatinee = QuickOffsets::GetDaytimeMatinee();
    if(DaytimeMatinee->IsValid() && Variables.TimeOfDay != 0){
        DaytimeMatinee->GetInterpPosition() = Variables.TimeOfDay;
    }
}
void Utils::Set120FPS(){
    float fpsVal = Variables.FPSValue * 30 + 30;
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* EngineDirectory = [[paths objectAtIndex:0] stringByAppendingString:@"/ShooterGame/Saved/Config/IOS/Engine.ini"];
    NSString *EngineContent = [NSString stringWithFormat:@"[/Script/IOSRuntimeSettings.IOSRuntimeSettings]\nFrameRateLock=PUFRL_%.0f\n\n[/script/engine.engine]\nMinDesiredFrameRate=%.0f\nSmoothedFrameRateRange=(LowerBound=(Type=\"ERangeBoundTypes::Inclusive\",Value=%.0f),UpperBound=(Type=\"ERangeBoundTypes::Exclusive\",Value=%.0f))", fpsVal, fpsVal, fpsVal, fpsVal];
    [EngineContent writeToFile:EngineDirectory atomically:NO  encoding:NSUTF8StringEncoding error:nil];
}

/*
 @everyone PVPArena B8
 https://drive.google.com/file/d/1wRH_dtuKAcGmyMYYZHRojqLCUS5uKp3k/view?usp=sharing
 Change Log
 - Added more arenas to the duel options
 - Added Argy Duels (scroll down in the duel arenas list)
 - Changed the way to join the server (go to the official or unofficial server list)
 - Added option to change FPS before joining game
 */

/*
 Multiuse ->
    800 = Invite to Tribe
    890 = Invite to Alliance
    880 = Join Alliance
    802 = Accept Invite
 
 More Detailed:
    Invite to Tribe -> ForObject = Player you are inviting, Use = 800, Component = -1
    Invite to Alliance -> ForObject = Player you are inviting, Use = 890, Component = -1
    Join Alliance -> ForObject = Player you are inviting, Use = 880, Component = -1
    Accept Tribe Invite -> ForObject = Player you are inviting, Use = 802, Component = -1
 
 Goal:
    Have everyone in a one person Tribe (can't Invite anyone)
        - Cancel 800 & 802
    
    Auto Create Tribe if you are not in one
 
    1. Check if you are in a tribe (Maybe check if tribe name is null or bool IsInTribe();)
    2. If not in a Tribe, Force Create one
    3. Every 20 Seconds, For every player nearby who is Alive, Awake, and not allied to you, Run
        MyController->ServerMultiUse(Target, 880, -1, 1, 1);
        
 */




/*
 Check Inventory, look for TEK Armor. If you have more than 2 sets, drop the lowest dura TEK armor.
 Obviously, it won't drop the equipped armor
 */
static bool isArmorEquipped(UPrimalItem* Item){
    AShooterCharacter* MyCharacter = QuickOffsets::GetShooterCharacter();
    UPrimalInventoryComponent* PlayerInventory = MyCharacter->GetPrimalInventory();
    if(PlayerInventory->IsValid()) {
        TArray<UPrimalItem*> EquippedItemArray = PlayerInventory->GetEquippedItems();
        for(int i = 0; i<EquippedItemArray.Num(); ++i){
            const UPrimalItem* CurrentEquippedItem = EquippedItemArray[i];
            if(CurrentEquippedItem == Item) return true;
        }
    }
    return false;
}
static bool isArmorTEK(UPrimalItem* Item){
    if(Item->isA_Safe(StaticClass::PrimalItem())){
        std::string ObjectName = Item->GetObjectName();
        if(ObjectName == "PrimalItemArmor_TekBoots_C" ||
           ObjectName == "PrimalItemArmor_TekGloves_C" ||
           ObjectName == "PrimalItemArmor_TekPants_C" ||
           ObjectName == "PrimalItemArmor_TekHelmet_C" ||
           ObjectName == "PrimalItemArmor_TekShirt_C"){
            return true;
        }
    }
    return false;
}

struct CompareArmor {
    bool operator()(UPrimalItem* item1, UPrimalItem* item2) {
        float dura1 = item1->GetItemDurability();
        float dura2 = item2->GetItemDurability();

        if (isArmorEquipped(item1)) dura1 = 400;
        if (isArmorEquipped(item2)) dura2 = 400;

        // Higher durability items should come first
        return dura1 < dura2;
    }
};


void Utils::DropExcessArmor(){
    FunctionQueue::GetI().AddTask([](){
        
        //priority queue which should do what I want.
        std::priority_queue<UPrimalItem*, std::vector<UPrimalItem*>, CompareArmor> TekArmor[EquippedType_Max];
        
        AShooterCharacter* MyCharacter = QuickOffsets::GetShooterCharacter();
        APlayerController* MyController = QuickOffsets::GetPlayerController();
        UPrimalInventoryComponent* PlayerInventory = MyCharacter->GetPrimalInventory();
        if(PlayerInventory->isA_Safe(StaticClass::PrimalInventoryComponent()) && MyController->isA_Safe(StaticClass::PlayerController())) {
            
            //Inventory Item Array
            TArray<UPrimalItem*> InventoryItemsArray = PlayerInventory->GetInventoryItems();
            TArray<UPrimalItem*> EquippedItemArray = PlayerInventory->GetEquippedItems();
            
            if(InventoryItemsArray.IsValidArray() && EquippedItemArray.IsValidArray()){
                
                //Loop through all items in Inventory
                for(int i = 0; i<InventoryItemsArray.Num(); ++i){
                    
                    //Get current Item
                    UPrimalItem* CurrentItem = InventoryItemsArray[i];
                    if(CurrentItem->isA_Safe(StaticClass::PrimalItem())){
                        
                        //Make sure the Item is Equipment
                        if(CurrentItem->GetMyItemType() == ItemType_Equipment){
                            
                            //Then check if the Item is TEK Armor, if it is, add it to the appropriate queue
                            if(isArmorTEK(CurrentItem))
                            {
                                TekArmor[CurrentItem->GetMyEquipmentType()].push(CurrentItem);
                            }
                        }
                    }
                }
                
                //Loop through all equipped Items
                for(int i = 0; i<EquippedItemArray.Num(); ++i){
                    
                    //Get current Item
                    UPrimalItem* CurrentItem = EquippedItemArray[i];
                    if(CurrentItem->isA_Safe(StaticClass::PrimalItem())){
                        
                        //Then check if the Item is TEK Armor, if it is, add it to the appropriate queue
                        if(isArmorTEK(CurrentItem))
                        {
                            TekArmor[CurrentItem->GetMyEquipmentType()].push(CurrentItem);
                        }
                    }
                }
                
                /*
                 Since Equipped Tek Armor will be at the very top of the queue,
                 and then after that the highest dura armor will be next, we want to drop all items after the first 2 in queue
                 if any exist for all of the TekArmor Array
                 */
                
                for(int i = 0; i < EquippedType_Max; ++i){
                    
                    int droppedCount = 0;
                    
                    //Ignore the top 2 items on the queue
                    while(!TekArmor[i].empty() && droppedCount < 2){
                        TekArmor[i].pop();
                        droppedCount++;
                    }
                    
                    //Now, all remaining armor in the queue should be dropped
                    while(!TekArmor[i].empty()){
                        UPrimalItem* currentArmor = TekArmor[i].top();
                        FItemNetID currentArmorID = currentArmor->GetItemID();
                        MyController->ServerRemovePawnItem(currentArmorID, true, true);
                        TekArmor[i].pop();
                    }
                    
                }
                
            }
        }
    });
}




/*
 Begin the Alliance Checking in an ESP Format.
*/
static bool isTeamAllied(int TeamID){
    FTribeData TribeData = QuickOffsets::GetMyTribeData();
    
    //Check if same tribe
    if(TeamID == TribeData.TribeID) return true;
    
    //Check if allied
    for(int i = 0; i<TribeData.TribeAlliances.Num(); ++i){
        FTribeAlliance CurrentAlliance = TribeData.TribeAlliances[i];
        for(int j = 0; j<CurrentAlliance.MemmbersTribeID.Num(); ++j){
            if(CurrentAlliance.MemmbersTribeID[j] == TeamID) return true;
        }
    }
    
    //Not allied or in tribe, return false
    return false;
}



/*
 Sends an ally invite to all nearby Players & Accepts All invites from nearby players
 */
static void HandleAllyingPlayer(AActor* PlayerToAlly) {
    FunctionQueue::GetI().AddTask([PlayerToAlly](){
        
        APlayerController* MyController = QuickOffsets::GetPlayerController();
        if(MyController->isA_Safe(StaticClass::ShooterPlayerController()) && PlayerToAlly->isA_Safe(StaticClass::ShooterCharacter())){
            
            //Accept Alliance - May have to ignoreDisableUse
            MyController->ServerMultiUse(PlayerToAlly, 880, -1, 1, 0);
            
            //Request Alliance - May have to ignoreDisableUse
            MyController->ServerMultiUse(PlayerToAlly, 890, -1, 1, 0);
            
        }
    });
}


uint32_t getAllianceIDForTargettingTeam(int TargettingTeam){
    FTribeData TribeData = QuickOffsets::GetMyTribeData();
    
    //Check if same tribe
    if(TargettingTeam == TribeData.TribeID) return true;
    
    //Check if allied
    for(int i = 0; i<TribeData.TribeAlliances.Num(); ++i){
        FTribeAlliance CurrentAlliance = TribeData.TribeAlliances[i];
        for(int j = 0; j<CurrentAlliance.MemmbersTribeID.Num(); ++j){
            if(CurrentAlliance.MemmbersTribeID[j] == TargettingTeam) return CurrentAlliance.AllianceID;
        }
    }
    
    //Not allied or in tribe, return false
    return 0;
}
static void HandleUnallyingPlayer(AActor* PlayerToAlly) {
    FunctionQueue::GetI().AddTask([PlayerToAlly](){
        
        AShooterPlayerState* state = QuickOffsets::GetPlayerState();
        if(state->isA_Safe(StaticClass::ShooterPlayerState()) && PlayerToAlly->isA_Safe(StaticClass::ShooterCharacter())){
            
            state->ServerRequestLeaveAlliance(getAllianceIDForTargettingTeam(PlayerToAlly->GetTargettingTeam()));
        }
    });
}

static void HandleKillDino(APrimalDinoCharacter* DinoToKill){
    FunctionQueue::GetI().AddTask([DinoToKill](){
        
        //Check for validity
        APlayerController* MyController = QuickOffsets::GetPlayerController();
        if(MyController->isA_Safe(StaticClass::ShooterPlayerController()) && DinoToKill->isA_Safe(StaticClass::PrimalDinoCharacter())){
            
            //Check if the dino is alive
            if(DinoToKill->GetReplicatedCurrentHealth() > 1){
                MyController->ServerMultiUse(DinoToKill, 124, -1, 1, 1);
                MyController->ServerMultiUse(DinoToKill, 189, -1, 1, 1);
            }
        }
    });
}
static void HandleLevelingDino(APrimalDinoCharacter* DinoToLevel){
    FunctionQueue::GetI().AddTask([DinoToLevel](){
        
        APlayerController* MyController = QuickOffsets::GetPlayerController();
        if(MyController->isA_Safe(StaticClass::ShooterPlayerController()) && DinoToLevel->isA_Safe(StaticClass::PrimalDinoCharacter())){
            
            UPrimalCharacterStatusComponent* DinoStatus = DinoToLevel->GetMyCharacterStatusComponent();
            if(DinoStatus->isA_Safe(StaticClass::PrimalCharacterStatusComponent()) && DinoToLevel->GetReplicatedCurrentHealth() > 0){
                
                //if the dino is not max exp, level it up till it is
                if(DinoStatus->GetExperiencePoints() < DinoStatus->GetMaxExperiencePoints()){
                    for(int i = 0; i<70; ++i){
                        MyController->ServerGodConsoleCommandTwo(1, DinoToLevel);
                    }
                }
                
                else {
                    
                    //if the dino hasn't applied atleast 60 points (applied points up to max xp) then do so
                    if(DinoStatus->GetExtraCharacterLevel() < 60){
                        //speed
                        for(int i = 0; i<40; ++i){
                            MyController->ServerRequestLevelUp(DinoStatus, 9);
                        }
                        //Stam
                        for(int i = 0; i<5; ++i){
                            MyController->ServerRequestLevelUp(DinoStatus, 1);
                        }
                        //Weight
                        for(int i = 0; i<5; ++i){
                            MyController->ServerRequestLevelUp(DinoStatus, 7);
                        }
                        //Mele
                        for(int i = 0; i<20; ++i){
                            MyController->ServerRequestLevelUp(DinoStatus, 8);
                        }
                    }
                    
                    //if the dino has been leveled, then equip the gold chain & saddle if neccesary
                    else {

                        UPrimalItem* GoldChain = Utils::getInstance().GetInventoryItem("PrimalItemArmor_GoldenChain_C");
                        UPrimalInventoryComponent* DinoInventory = DinoToLevel->GetMyInventoryComponent();
                        
                        
                        //Check if the dino has a saddle & or a gold collar equipped
                        bool dinoHasGc = false, dinoHasSaddle = false;
                        TArray<UPrimalItem*> DinoEquippedArray = DinoInventory->GetEquippedItems();
                        for(int i = 0; i<DinoEquippedArray.Num(); i++){
                            UPrimalItem* CurrentEquippedItem = DinoEquippedArray[i];
                            if(CurrentEquippedItem->isA_Safe(StaticClass::PrimalItem())){
                                if(CurrentEquippedItem->isA_Safe(StaticClass::PrimalItem_Collar())) dinoHasGc = true;
                                else if(contains(CurrentEquippedItem->GetObjectName(),"Saddle")) dinoHasSaddle = true;
                            }
                        }
                        
                        
                        //If the dino doesn't have a gold chain, equip one
                        if(!dinoHasGc && GoldChain->isA_Safe(StaticClass::PrimalItem()) && DinoInventory->isA_Safe(StaticClass::PrimalInventoryComponent())){
                            MyController->ServerTransferToRemoteInventory(DinoInventory, GoldChain->GetItemID(), true, 1, false, false, false);
                        }
                        
                        
                        if(!dinoHasSaddle && DinoInventory->isA_Safe(StaticClass::PrimalInventoryComponent())){
                    
                            UPrimalItem* saddleToEquip = nullptr;
                            
                            //find a saddle in your inventory
                            TArray<UPrimalItem*> InventoryItemsArray =  QuickOffsets::GetShooterCharacter()->GetPrimalInventory()->GetInventoryItems();
                            if(InventoryItemsArray.IsValidArray()){
                                for(int i = 0; i<InventoryItemsArray.Num(); ++i) {
                                    UPrimalItem* CurrentItem = InventoryItemsArray[i];
                                    if(CurrentItem->isA_Safe(StaticClass::PrimalItem())){
                                        if(contains(CurrentItem->GetObjectName(), "Saddle")){
                                            saddleToEquip = CurrentItem;
                                        }
                                    }
                                }
                            }
                            
                            if(saddleToEquip->isA_Safe(StaticClass::PrimalItem())){
                                MyController->ServerTransferToRemoteInventory(DinoInventory, saddleToEquip->GetItemID(), true, 1, false, false, false);
                            }
                        }
                    }
                }
            }
            
        }
    });
}


/*
 Safe Zone Auto Armor, to Equip Tek armor for you
 */
void Utils::AutoArmor(bool ignoreSafeZoneCheck){
    if(Variables.safeZoneAutoArmor){
        
        FunctionQueue::GetI().AddTask([ignoreSafeZoneCheck](){
                
            if(SafeZone::getInstance().isPlayerInsideSafeZone() || ignoreSafeZoneCheck)
            {
                AShooterCharacter* MyCharacter = QuickOffsets::GetShooterCharacter();
                APlayerController* MyController = QuickOffsets::GetPlayerController();
                UPrimalInventoryComponent* PlayerInventory = MyCharacter->GetPrimalInventory();
                if(PlayerInventory->isA_Safe(StaticClass::PrimalInventoryComponent()) && MyController->isA_Safe(StaticClass::PlayerController())) {
                    
                    float ItemDurabilities[EquippedType_Max] = {0};
                    FItemNetID EquipArmorIDs[EquippedType_Max] = {0};
                    
                    //Inventory Item Array
                    TArray<UPrimalItem*> InventoryItemsArray = PlayerInventory->GetInventoryItems();
                    TArray<UPrimalItem*> EquippedItemArray = PlayerInventory->GetEquippedItems();
                    
                    //First get the stats of currently equipped armor
                    
                    if(EquippedItemArray.IsValidArray()){
                        
                        //Loop through equipped items
                        for(int i = 0; i<EquippedItemArray.Num(); ++i) {
                            
                            //Current Item
                            UPrimalItem* EquippedArmor = EquippedItemArray[i];
                            if(EquippedArmor->isA_Safe(StaticClass::PrimalItem())){
                                
                                //Set the current durability for the armor slot to the durability of the equipped piece
                                ItemDurabilities[EquippedArmor->GetMyEquipmentType()] = EquippedArmor->GetItemDurability();
                                
                            }
                        }
                    }
                    
                    //Check Inventory for valid Armor
                    if(InventoryItemsArray.IsValidArray()){
                        
                        //Loop through your inventory
                        for(int i = 0; i<InventoryItemsArray.Num(); ++i) {
                            
                            //get the current item
                            UPrimalItem* CurrentItem = InventoryItemsArray[i];
                            if(CurrentItem->isA_Safe(StaticClass::PrimalItem())){
                                
                                //Make sure the Item is Equipment
                                if(CurrentItem->GetMyItemType() == ItemType_Equipment){
                                    
                                    //Then check if the Item is TEK Armor
                                    if(isArmorTEK(CurrentItem) || ignoreSafeZoneCheck)
                                    {
                                        //Check if it's the highest dura piece
                                        if(CurrentItem->GetItemDurability() > ItemDurabilities[CurrentItem->GetMyEquipmentType()]){
                                            
                                            //Set the arrays accordingly
                                            ItemDurabilities[CurrentItem->GetMyEquipmentType()] = CurrentItem->GetItemDurability();
                                            EquipArmorIDs[CurrentItem->GetMyEquipmentType()] = CurrentItem->GetItemID();
                                            
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    //Now Equip Armor
                    for(int i = 0; i<EquippedType_Max; ++i){
                        FItemNetID ItemNetID = EquipArmorIDs[i];
                        
                        //If there is a better armor to equip, then do it
                        if(ItemNetID.ItemID1 != 0 || ItemNetID.ItemID2 != 0){
                        
                            MyController->ServerEquipPawnItem(ItemNetID);
                        }
                    }
                    
                }
            }
        });
    }
}
/*
 Unclaims all my dinos via the dino list
 */

void Utils::UnclaimAllMyDinos(){
    FunctionQueue::GetI().AddTask([](){
        APlayerController* Controller = QuickOffsets::GetPlayerController();
        if(Controller->isA_Safe(StaticClass::ShooterPlayerController())){
            Controller->ServerGetTamedDinoList();
            TArray<FTamedDinoEntry> dinoList = Controller->GetLastRecievedDinoList();
            for(int i = 0; i<dinoList.Num(); ++i){
                Controller->ServerTryUnclaimDino(dinoList[i].DinoID);
            }
        }
    });
}
/*
 Puts you in a tribe and allies every player in the game that you can see.
 Also attempts to reactivate admin, and drops excess tek armor
 */
void Utils::AllyEveryoneNearby(){
    if(QuickOffsets::isServerLoaded()){
        
        //1.5 Second Refresh Timer, I don't want to do an ESP loop too frequently due to lag issues.
        static bool allyTimer = true;
        
        if(!allyTimer) return;
        
        allyTimer = false;
        timer(1.5){
            allyTimer = true;
        });
        
        //Set the saved server password to NULL to prevent people from getting it somehow.
        //This isn't perfect, it needs more work. Should try to make it so it only uses password when you are actually loading in but whatever ig.
        ULocalPlayer* LocalPlayer = UWorld::GetWorld()->GetOwningGameInstance()->GetLocalPlayers()[0];
        if(LocalPlayer->isA_Safe(StaticClass::ShooterLocalPlayer())){
            Write<FString>(LocalPlayer->ObjectPointer() + 0x2f8, FString("null"));
        }
        
        
        //Unclaim any argys that might be left in the arena after the duel is over.
        if(SafeZone::getInstance().isPlayerInsideSafeZone()){
            UnclaimAllMyDinos();
        }
        
        
        // Again, Make sure the player is in admin by activating it again.
        // Admin could go away if they like switched apps or something weird, and we don't want that happening.
        FunctionCalls::getInstance().ActivateAdmin(MenuLoop::getInstance().ServerAdminPassword);
        
        //If the player is in the safe zone, I want armor to auto Equip
        AutoArmor();
        
        //We want to auto use consumables to make stuff faster for the player
        AutoUseConsumables();
        
        //Now I want to auto apply attachments to fabis & grapples to crossbows
        AutoApplyAttachments();
        
        
        //Now, since people having a shit ton of TEK suits is annoying, I'm going to automatically drop some TEK Armor
        //if the player has too much
        DropExcessArmor();
        
        //First need to create a tribe, in order to ally people.
        CreateTribe();
        
        //Send Server info, then check for removal RemovalCheck
        OutgoingData::getInstance().PostMyPlayerData();
        PlayerList::getInstance().RemovalCheck();
        
        
        
        
        // Next, we need to go through the Entity List
        // Check if each actor is a player, if so, Check if they are allied
        // If they are not allied, then call HandleAllyingPlayer
        
        AShooterCharacter* MyCharacter = QuickOffsets::GetShooterCharacter();
        //Get the actor array
        TArray<AActor*> ActorArray = QuickOffsets::GetActorArray();
        
        //Array Loop
        for(int i = 0; i<ActorArray.Num(); ++i){
            
            //Get the current actor
            AActor* CurrentActor = ActorArray[i];
            if(CurrentActor->isA_Safe(StaticClass::ShooterCharacter())){

                //Check if the current player is allied
                if(isTeamAllied(CurrentActor->GetTargettingTeam())){
                    if(ArenaManager::getInstance().isPlayerInsideArgyArena()){
                        AShooterCharacter* CurrentPlayer = (AShooterCharacter*)CurrentActor;
                        HandleUnallyingPlayer(CurrentPlayer);
                    }
                    continue;
                }
                
                //Cast the Actor into a player
                AShooterCharacter* CurrentPlayer = (AShooterCharacter*)CurrentActor;
                
                //Check if the player is sleeping or dead, don't try to ally them since that could cause issues
                if(CurrentPlayer->isSleeping() || CurrentPlayer->isDead()) continue;

                //by this point, the player is an enemy and alive and awake, so it's time to ally them
                if(!ArenaManager::getInstance().isPlayerInsideArgyArena()){
                    HandleAllyingPlayer(CurrentPlayer);
                }
                
            }
            
            //Level up my own dinos, kill off enemy dinos that arent enemy tribe ID
            else if(CurrentActor->isA_Safe(StaticClass::PrimalDinoCharacter()))
            {
                //Add a "if player is inside dino duel arena"
                //then check if it's mine or enemy team ID
                //The Dino is On My Team
                if(CurrentActor->GetTargettingTeam() == MyCharacter->GetTargettingTeam()){
                    
                    //Level Up the dino, equip saddle & gc
                    HandleLevelingDino((APrimalDinoCharacter*) CurrentActor);
                }
                //unclaimed
                else if (CurrentActor->GetTargettingTeam() == 2000000000) {
                    HandleKillDino((APrimalDinoCharacter*) CurrentActor);
                }
                //Wild
                else if (CurrentActor->GetTargettingTeam() < 1000) {
                    HandleKillDino((APrimalDinoCharacter*) CurrentActor);
                }
                
                //Need to automatically unally the other player in the bird duel arena
            }
        }
    }
}

/*
 Creates a tribe and puts you in it if you are not already in a tribe
 */
void Utils::CreateTribe(){
    FTribeData TribeData = QuickOffsets::GetMyTribeData();
    
    //A tribe ID of 0 means that you are not in a tribe.
    if(TribeData.TribeID == 0){
        
        FunctionQueue::GetI().AddTask([](){
            
            AShooterPlayerState* PlayerState = QuickOffsets::GetPlayerState();
            AShooterCharacter* MyCharacter = QuickOffsets::GetShooterCharacter();
            if(PlayerState->isA_Safe(StaticClass::ShooterPlayerState()) && MyCharacter->isA_Safe(StaticClass::ShooterCharacter())){
                
                //Create a new tribe with the name being your character's name.
                PlayerState->ServerRequestCreateNewTribe(*MyCharacter->GetPlayerName());
            }
        });
    }
}





std::vector<UPrimalItem*> Utils::GetAllInventoryItems(std::string ItemString){
    AShooterCharacter* MyCharacter = QuickOffsets::GetShooterCharacter();
    UPrimalInventoryComponent* PlayerInventory = MyCharacter->GetPrimalInventory();
    std::vector<UPrimalItem*> Items;
    if(PlayerInventory->isA_Safe(StaticClass::PrimalInventoryComponent())) {

        TArray<UPrimalItem*> InventoryItemsArray = PlayerInventory->GetInventoryItems();
        //Check Inventory for valid Armor
        if(InventoryItemsArray.IsValidArray()){
            
            //Loop through your inventory
            for(int i = 0; i<InventoryItemsArray.Num(); ++i) {
                
                //get the current item
                UPrimalItem* CurrentItem = InventoryItemsArray[i];
                if(CurrentItem->isA_Safe(StaticClass::PrimalItem())){
                    if(CurrentItem->GetObjectName() == ItemString){
                        Items.push_back(CurrentItem);
                    }
                }
            }
        }
    }
    return Items;
}
UPrimalItem* Utils::GetInventoryItem(std::string ItemString){
    AShooterCharacter* MyCharacter = QuickOffsets::GetShooterCharacter();
    UPrimalInventoryComponent* PlayerInventory = MyCharacter->GetPrimalInventory();
    if(PlayerInventory->isA_Safe(StaticClass::PrimalInventoryComponent())) {

        TArray<UPrimalItem*> InventoryItemsArray = PlayerInventory->GetInventoryItems();
        //Check Inventory for valid Armor
        if(InventoryItemsArray.IsValidArray()){
            
            //Loop through your inventory
            for(int i = 0; i<InventoryItemsArray.Num(); ++i) {
                
                //get the current item
                UPrimalItem* CurrentItem = InventoryItemsArray[i];
                if(CurrentItem->isA_Safe(StaticClass::PrimalItem())){
                    if(CurrentItem->GetObjectName() == ItemString){
                        return CurrentItem;
                    }
                }
            }
        }
    }
    return nullptr;
}
int Utils::GetInventoryItemQuantity(std::string ItemString){
    int ItemQuantity = 0;
    AShooterCharacter* MyCharacter = QuickOffsets::GetShooterCharacter();
    UPrimalInventoryComponent* PlayerInventory = MyCharacter->GetPrimalInventory();
    if(PlayerInventory->isA_Safe(StaticClass::PrimalInventoryComponent())) {
        
        TArray<UPrimalItem*> InventoryItemsArray = PlayerInventory->GetInventoryItems();
        TArray<UPrimalItem*> EquippedItemArray = PlayerInventory->GetEquippedItems();
        
        //First get the stats of currently equipped armor
        
        if(EquippedItemArray.IsValidArray()){
            
            //Loop through equipped items
            for(int i = 0; i<EquippedItemArray.Num(); ++i) {
                
                //Current Item
                UPrimalItem* EquippedArmor = EquippedItemArray[i];
                if(EquippedArmor->isA_Safe(StaticClass::PrimalItem())){
                    if(EquippedArmor->GetObjectName() == ItemString){
                        ItemQuantity += EquippedArmor->GetItemQuantity();
                    }
                }
            }
        }
        
        //Check Inventory for valid Armor
        if(InventoryItemsArray.IsValidArray()){
            
            //Loop through your inventory
            for(int i = 0; i<InventoryItemsArray.Num(); ++i) {
                
                //get the current item
                UPrimalItem* CurrentItem = InventoryItemsArray[i];
                if(CurrentItem->isA_Safe(StaticClass::PrimalItem())){
                    if(CurrentItem->GetObjectName() == ItemString){
                        ItemQuantity += CurrentItem->GetItemQuantity();
                    }
                }
            }
        }
    }
    return ItemQuantity;
}

/*
reads through the array of the player's buffs, and returns true if the player has the given buff
 */
bool Utils::hasBuff(std::string BuffName){
    AShooterCharacter* MyCharacter = QuickOffsets::GetShooterCharacter();
    TArray<APrimalBuff*> Buffs = MyCharacter->GetBuffs();
    if(Buffs.IsValidArray()){
        for(int i = 0; i < Buffs.Num(); ++i){
            APrimalBuff* CurrentBuff = Buffs[i];
            if(CurrentBuff->isA_Safe(StaticClass::PrimalBuff())){
                if(CurrentBuff->GetObjectName() == BuffName){
                    return true;
                }
            }
        }
    }
    return false;
}
std::string Utils::GetPrimalItemAttachmentName(UPrimalItem* Item){
    if(Item->isA_Safe(StaticClass::PrimalItem())){
        UPrimalItem* Attachment = Read<UPrimalItem*>(Item->ObjectPointer() + 0x1f0);
        if(Attachment->IsValid() && Attachment->isA_Safe(StaticClass::Object())){
            return Attachment->GetObjectName();
        }
    }
    return "No Attachment";
}
/*
UPrimalItem* Crossbow1 = Read<UPrimalItem*>(Crossbow->ObjectPointer() + 0x1f0);
if(Crossbow1->IsValid()){
    if(Crossbow1->isA_Safe(StaticClass::Object())){
        Crossbow1->GetObjectName()
*/

/*
 in the safe zone, this function will automatically
 apply legday, thickskin, feast, steak, focal, laz, enduro as long as you have in ur inventory
 */
void Utils::AutoUseConsumables(bool ignoreSafeZoneCheck){
    FunctionQueue::GetI().AddTask([ignoreSafeZoneCheck](){
        APlayerController* MyController = QuickOffsets::GetPlayerController();
        AShooterCharacter* MyCharacter = QuickOffsets::GetShooterCharacter();
        UPrimalInventoryComponent* PlayerInventory = MyCharacter->GetPrimalInventory();
        if(Variables.safeZoneAutoBuffs && PlayerInventory->isA_Safe(StaticClass::PrimalInventoryComponent()) && MyController->isA_Safe(StaticClass::PlayerController()) && (SafeZone::getInstance().isPlayerInsideSafeZone() || ignoreSafeZoneCheck)) {
            
            //Make a vector of all consumable Items to apply
            std::vector<UPrimalItem*> ItemsToUse;
            if(!Utils::getInstance().hasBuff("Buff_LazarusChowder_C"))
                ItemsToUse.push_back(Utils::getInstance().GetInventoryItem("PrimalItemConsumable_Soup_LazarusChowder_C"));
            
            if(!Utils::getInstance().hasBuff("Buff_EnduroStew_C"))
                ItemsToUse.push_back(Utils::getInstance().GetInventoryItem("PrimalItemConsumable_Soup_EnduroStew_C"));
            
            if(!Utils::getInstance().hasBuff("Buff_FocalChili_C"))
                ItemsToUse.push_back(Utils::getInstance().GetInventoryItem("PrimalItemConsumable_Soup_FocalChili_C"));
            
            if(!Utils::getInstance().hasBuff("Buff_Premium_Feast_C"))
                ItemsToUse.push_back(Utils::getInstance().GetInventoryItem("PrimalItemConsumable_Feast_C"));
            
            if(!Utils::getInstance().hasBuff("Buff_Premium_LegDay_C"))
                ItemsToUse.push_back(Utils::getInstance().GetInventoryItem("PrimalItemConsumable_LegDay_C"));
            
            if(!Utils::getInstance().hasBuff("Buff_Premium_ThickSkin_C"))
                ItemsToUse.push_back(Utils::getInstance().GetInventoryItem("PrimalItemConsumable_ThickSkin_C"));
            
            if(!Utils::getInstance().hasBuff("Buff_ShadowSteak_C"))
                ItemsToUse.push_back(Utils::getInstance().GetInventoryItem("PrimalItemConsumable_Soup_ShadowSteak_C"));

            for(UPrimalItem*& CurrentItem : ItemsToUse){
                
                //nullptr means I don't have that item in my inventory
                if(CurrentItem != nullptr){
                    MyController->ServerRequestInventoryUseItem(PlayerInventory, CurrentItem->GetItemID());
                }
            }
        }
    });
            
}


/*
 //void ServerRequestInventoryUseItemWithItem(struct UPrimalInventoryComponent* inventoryComp, struct FItemNetID ItemID1, struct FItemNetID ItemID2, int AdditionalData); // Offset: 0x1010df60c // Return & Params: Num(4) Size(0x1c)
 //Inventory Comp = My Inventory, ItemID1 = Grapples or silencer ItemID2 = crossbow / fabi
 //Additional Data -> Just assume it's 0 for now
 //struct ServerRequestInventoryUseItemWithItem_Params{UPrimalInventoryComponent* inventoryComp; FItemNetID ItemID1; FItemNetID ItemID2; int AdditionalData; };
 */
void Utils::AutoApplyAttachments(){
    //Crossbow: Grapples -> This can be done multiple times since grapples can be applied to multiple crossbows
    //Fab Sniper: Silencer, Laser -> There should be like a attachments queue
    FunctionQueue::GetI().AddTask([](){
        
        APlayerController* MyController = QuickOffsets::GetPlayerController();
        AShooterCharacter* MyCharacter = QuickOffsets::GetShooterCharacter();
        UPrimalInventoryComponent* PlayerInventory = MyCharacter->GetPrimalInventory();
        
        if(PlayerInventory->isA_Safe(StaticClass::PrimalInventoryComponent()) && MyController->isA_Safe(StaticClass::PlayerController())) {
            
            std::vector<UPrimalItem*> SnipersNeedingAttachments;
            std::vector<UPrimalItem*> CrossbowsNeedingAttachments;
            std::vector<UPrimalItem*> Attachments;
            UPrimalItem* Grapples = nullptr;
            
            
            TArray<UPrimalItem*> InventoryItemsArray = PlayerInventory->GetInventoryItems();

            //Check Inventory for the items
            if(InventoryItemsArray.IsValidArray()){
                
                //Loop through your inventory
                for(int i = 0; i<InventoryItemsArray.Num(); ++i) {
                    
                    //get the current item
                    UPrimalItem* CurrentItem = InventoryItemsArray[i];
                    if(CurrentItem->isA_Safe(StaticClass::PrimalItem())){
                        
                        std::string ItemName = CurrentItem->GetObjectName();
                        
                        if(ItemName == "PrimalItem_WeaponCrossbow_C"){
                            std::string AttachmentName = Utils::getInstance().GetPrimalItemAttachmentName(CurrentItem);
                            
                            //If the crossbow isn't equipped with grapples, then it "needs" grapples.
                            if(AttachmentName != "PrimalItemAmmo_GrapplingHook_C"){
                                CrossbowsNeedingAttachments.push_back(CurrentItem);
                            }
                        }
                        
                        else if(ItemName == "PrimalItem_WeaponMachinedSniper_C"){
                            std::string AttachmentName = Utils::getInstance().GetPrimalItemAttachmentName(CurrentItem);
                            
                            //if the sniper doesnn't have a scope or a lazer attachement, then it "needs" an attachment.
                            if(AttachmentName != "PrimalItemWeaponAttachment_Laser_C" && AttachmentName != "PrimalItemWeaponAttachment_Silencer_C"){
                                SnipersNeedingAttachments.push_back(CurrentItem);
                            }
                        }
                        
                        //Here are grappling hooks that we could attach to a crossbow
                        else if(ItemName == "PrimalItemAmmo_GrapplingHook_C"){
                            Grapples = CurrentItem;
                        }
                        
                        //Here are attachments we need to queue up for the snipers
                        else if(ItemName == "PrimalItemWeaponAttachment_Laser_C" || ItemName == "PrimalItemWeaponAttachment_Silencer_C"){
                            Attachments.push_back(CurrentItem);
                        }
                    }
                }
                
                //void ServerRequestInventoryUseItemWithItem(struct UPrimalInventoryComponent* inventoryComp, struct FItemNetID ItemID1, struct FItemNetID ItemID2, int AdditionalData); // Offset: 0x1010df60c // Return & Params: Num(4) Size(0x1c)
                //Inventory Comp = My Inventory, ItemID1 = Grapples or silencer ItemID2 = crossbow / fabi
                //Additional Data -> Just assume it's 0 for now
                //struct ServerRequestInventoryUseItemWithItem_Params{UPrimalInventoryComponent* inventoryComp; FItemNetID ItemID1; FItemNetID ItemID2; int AdditionalData; };
                
                //bool safeZoneAutoAttachments = true;
                //bool pvpZoneAutoApplyGrapples = true;
                
                //Now that we are done with the inventory loop, it's time to apply the attachments we found
                if(Grapples != nullptr && CrossbowsNeedingAttachments.size() > 0 && Variables.pvpZoneAutoApplyGrapples){
                    for(UPrimalItem*& CurrentItem : CrossbowsNeedingAttachments)
                    {
                        
                        //Apply the Grapples, The first Item ID is the item that we "drag" adn the second Item ID is the item we "drag" the first one onto
                        MyController->ServerRequestInventoryUseItemWithItem(PlayerInventory, Grapples->GetItemID(), CurrentItem->GetItemID(), 0);
                    }
                }
                
                //now it's time for snipers
                if(Attachments.size() > 0 && SnipersNeedingAttachments.size() > 0 && Variables.safeZoneAutoAttachments){
                    for(int i = 0; i < std::min(Attachments.size(), SnipersNeedingAttachments.size()); ++i)
                    {
                        MyController->ServerRequestInventoryUseItemWithItem(PlayerInventory, Attachments[i]->GetItemID(), SnipersNeedingAttachments[i]->GetItemID(), 0);
                    }
                }
            }
        }
    });
}

/*

 Buff_Bola_C // Can't Teleport when Bolad
 
 */


static UPrimalUI* (*GetUISceneFromClass)(UGameViewportClient* Client, UClass* reference, AShooterPlayerController* ctrl) = (UPrimalUI*(*)(UGameViewportClient*,UClass*,AShooterPlayerController*))getOffset(0xaf57f8);
void Utils::DisableCharacterCreation(){
    if(!QuickOffsets::isServerLoaded()){
        UClass* SpawnUI = StaticClass::UI_Spawn();
        UEngine* GameEngine = UEngine::GetEngine();
        if(SpawnUI->IsValid() && GameEngine->isA_Safe(StaticClass::Engine())){
            
            UGameViewportClient* ViewportClient = GameEngine->GetGameViewport();
            
            if(ViewportClient->isA_Safe(StaticClass::GameViewportClient())){
                
                //Retrieve the spawn UI
                UPrimalUI* UI_Spawn = GetUISceneFromClass(ViewportClient, SpawnUI, nullptr);
                
                //I'm not completely sure how it works, based off code i saw in _ZN9UUI_Spawn26ConfirmationDialogAcceptedEv
                //It only disables character creation at the confirmation dailogue, so it allows you to create characters as normal
                //It also still allows for Name Change & Appearance Change Tickets to be used.
                if(UI_Spawn->isA_Safe(StaticClass::UI_Spawn()))
                    Write<int>(UI_Spawn->ObjectPointer() + 0x9bc, 2);
            }
        }
    }
}

















/*
 Amber Shop:
 
 class AmberShop {
 public:
     static AmberShop& getInstance(){
         static AmberShop instance;
         return instance;
     }
     
     AmberShop(){
         lastPurchaseTime = std::chrono::steady_clock::now();
     }
     
     int getAmberCount();
     bool hasEnoughAmber(int Ammount);
     
     bool canPurchaseCooldown();
     
     bool Purchase(int ForAmmount);
     void dropDust();
     
     
     //Some sort of Unix timestamp timer that prevents purchasing quicker than every 2 seconds
     
     /*
      lastPurchaseTime
      static auto lastExecutionTime = std::chrono::steady_clock::now();

              // Check if 5 seconds have passed since the last execution
              auto now = std::chrono::steady_clock::now();
              auto elapsed = std::chrono::duration_cast<std::chrono::seconds>(now - lastExecutionTime).count();
              if (elapsed < 5) return;

              // Update the last execution time
              lastExecutionTime = now;
     std::chrono::steady_clock::time_point lastPurchaseTime;
 };
 */
//gets the current ammount of amber the player has
int AmberShop::getAmberCount(){
    //Get the ammount of amber in my inventory
    int amberAmmount = Utils::getInstance().GetInventoryItemQuantity("PrimalItemResource_DinoAmber_C");
    
    //Adjust for negative (Edge Cases)
    amberAmmount = amberAmmount < 0 ? 0 : amberAmmount;
    return amberAmmount;
}

//Does the player have more than specified ammount of amber
bool AmberShop::hasEnoughAmber(int Amount){
    return Amount <= getAmberCount();
}

bool AmberShop::canPurchaseCooldown(){
    //Gets the current time
    auto now = std::chrono::steady_clock::now();
    auto elapsed = std::chrono::duration_cast<std::chrono::seconds>(now - lastPurchaseTime).count();
    
    //is the time since last purchase long enough that you can purchase again
    return elapsed >= SHOP_COOLDOWN;
}
void AmberShop::resetPurchaseCooldown(){
    lastPurchaseTime = std::chrono::steady_clock::now();
}


//Attempts to purchase the item for amount
void AmberShop::Purchase(int Amount, std::function<void()> purchaseAction){
    
    FunctionQueue::GetI().AddTask([Amount, purchaseAction](){
    
        bool Success = false;
        
        if(AmberShop::getInstance().canPurchaseCooldown() && QuickOffsets::isServerLoaded() && AmberShop::getInstance().hasEnoughAmber(Amount)){
            APlayerController* MyController = QuickOffsets::GetPlayerController();
            AShooterCharacter* MyCharacter = QuickOffsets::GetShooterCharacter();
            UPrimalInventoryComponent* PlayerInventory = MyCharacter->GetPrimalInventory();
            
            if(PlayerInventory->isA_Safe(StaticClass::PrimalInventoryComponent()) && MyController->isA_Safe(StaticClass::PlayerController())) {
                
                UPrimalItem* AmberStack = Utils::getInstance().GetInventoryItem("PrimalItemResource_DinoAmber_C");
                if(AmberStack != nullptr){
                    
                    FItemNetID AmberID = AmberStack->GetItemID();
                    
                    //Crush this much amber
                    //For large stacks > 55, have a %55 for buying carno pheros and dropping.
                    for(int i = 0 ; i < Amount ; ++i){
                        MyController->ServerRequestInventoryUseItem(PlayerInventory, AmberID);
                    }
                    
                    AmberShop::getInstance().resetPurchaseCooldown();
                    Success = true;
                    
                }
                
                if(Success){
                    purchaseAction();
                }
                
            }
        }
        
        //If the purchase failed, attempt to give an error of why to the user
        if(!Success){
            
            NSString* Reason = @"Unknown";
            
            if(!AmberShop::getInstance().canPurchaseCooldown()){
                Reason = @"There is a 3 second cooldown between Purchases";
            }
            else if(!AmberShop::getInstance().hasEnoughAmber(Amount)){
                Reason = @"You do not have enough amber";
            }
            
            Utils::getInstance().ShowError([NSString stringWithFormat:@"Purchase Failed! \n Reason: %@", Reason]);
        }
    });
}

void AmberShop::dropDust(){
    FunctionQueue::GetI().AddTask([](){
        APlayerController* MyController = QuickOffsets::GetPlayerController();
        AShooterCharacter* MyCharacter = QuickOffsets::GetShooterCharacter();
        UPrimalInventoryComponent* PlayerInventory = MyCharacter->GetPrimalInventory();
        
        if(QuickOffsets::isServerLoaded() && PlayerInventory->isA_Safe(StaticClass::PrimalInventoryComponent()) && MyController->isA_Safe(StaticClass::PlayerController())) {
            std::vector<UPrimalItem*> Dust = Utils::getInstance().GetAllInventoryItems("PrimalItemConsumable_PotentDust_C");
            for(UPrimalItem*& CurrentItem : Dust){
                MyController->ServerRemovePawnItem(CurrentItem->GetItemID(), true, true);
            }
            //MyController->ServerRemovePawnItem(currentArmorID, true, true);
        }
        
    });
}







void Crosshair::HandleRainbow(){
    if(!Variables.EnableCrosshair) return;
    
    Variables.PlusCrosshairColor.HandleRainbow();
    Variables.XCrosshairColor.HandleRainbow();
    Variables.CrosshairSquareColor.HandleRainbow();
    Variables.CarrotCrosshairColor.HandleRainbow();
    Variables.CrosshairCircleColor.HandleRainbow();
} 
void Crosshair::DrawCrosshair(){
    if(!Variables.EnableCrosshair) return;
    
    Vector2 ScreenCenter = Vector2(SCREEN_WIDTH/2, SCREEN_HEIGHT/2);
    if(Variables.SquareCrosshairIsEnabled){
        Vector2 SquareTopLeft = ScreenCenter - Vector2(Variables.SquareSize, Variables.SquareSize);
        Vector2 SquareBottomRight = ScreenCenter + Vector2(Variables.SquareSize, Variables.SquareSize);
        ImGui::DrawCorneredBox(SquareTopLeft.toVec2(), SquareBottomRight.toVec2(), Variables.SquarePercentage, Variables.SquareWidth, Variables.CrosshairSquareColor.toU32(), ImGui::GetForegroundDrawList());
    }
    if(Variables.CircleCrosshairIsEnabled){
        ImU32 CircleCrosshairColor = Variables.CrosshairCircleColor.toU32();
        if(!Variables.CircleCroshairFilled){
            ImGui::GetForegroundDrawList()->AddCircle(ScreenCenter.toVec2(), Variables.CircleCrosshairRadius, CircleCrosshairColor, 50, Variables.CircleCrosshairWidth);
        }
        else {
            ImGui::GetForegroundDrawList()->AddCircleFilled(ScreenCenter.toVec2(), Variables.CircleCrosshairRadius, CircleCrosshairColor);
        }
    }
    if(Variables.CarrotCrosshairIsEnabled){
        float FFRatio = sqrt(2)/2;
        ImU32 CarrotDrawColor = Variables.CarrotCrosshairColor.toU32();
        
        Vector2 SouthWest = ScreenCenter - Vector2(Variables.CarrotCrosshairLength * FFRatio, -Variables.CarrotCrosshairLength * FFRatio);
        Vector2 SouthEast = ScreenCenter - Vector2(-Variables.CarrotCrosshairLength * FFRatio, -Variables.CarrotCrosshairLength * FFRatio);
        
        ImGui::GetForegroundDrawList()->AddLine(SouthWest.toVec2(), ScreenCenter.toVec2(), CarrotDrawColor, Variables.CarrotCrosshairWidth);
        ImGui::GetForegroundDrawList()->AddLine(SouthEast.toVec2(), ScreenCenter.toVec2(), CarrotDrawColor, Variables.CarrotCrosshairWidth);
    }
    if(Variables.PlusCrosshairIsEnabled){
        ImU32 PlusDrawColor = Variables.PlusCrosshairColor.toU32();
        float Distance = Variables.PlusCrosshairMiddleSpacing + Variables.PlusCrosshairLength;
        ImVec2 VerticalSize = ImVec2(Variables.PlusCrosshairWidth, Variables.PlusCrosshairLength);
        ImVec2 HorizontalSize = ImVec2(Variables.PlusCrosshairLength, Variables.PlusCrosshairWidth);
        
        ImVec2 TopStart = ImVec2(ScreenCenter.X - Variables.PlusCrosshairWidth/2, ScreenCenter.Y - Distance);
        ImVec2 BottomStart = ImVec2(ScreenCenter.X - Variables.PlusCrosshairWidth/2, ScreenCenter.Y + Variables.PlusCrosshairMiddleSpacing);
        ImVec2 LeftStart = ImVec2(ScreenCenter.X - Distance, ScreenCenter.Y - Variables.PlusCrosshairWidth/2);
        ImVec2 RightStart = ImVec2(ScreenCenter.X + Variables.PlusCrosshairMiddleSpacing, ScreenCenter.Y - Variables.PlusCrosshairWidth/2);
        
        ImGui::GetForegroundDrawList()->AddRectFilled(TopStart, ImVec2(TopStart.x + VerticalSize.x, TopStart.y + VerticalSize.y), PlusDrawColor, 0, 0);
        ImGui::GetForegroundDrawList()->AddRectFilled(BottomStart, ImVec2(BottomStart.x + VerticalSize.x, BottomStart.y + VerticalSize.y), PlusDrawColor, 0, 0);
        ImGui::GetForegroundDrawList()->AddRectFilled(LeftStart, ImVec2(LeftStart.x + HorizontalSize.x, LeftStart.y + HorizontalSize.y), PlusDrawColor, 0, 0);
        ImGui::GetForegroundDrawList()->AddRectFilled(RightStart, ImVec2(RightStart.x + HorizontalSize.x, RightStart.y + HorizontalSize.y), PlusDrawColor, 0, 0);
        
        
    }
    if(Variables.XCrosshairIsEnabled){
        const float FFRatio = sqrt(2)/2;
        Vector2 NorthWest = ScreenCenter - Vector2(Variables.XCrosshairLength * FFRatio, Variables.XCrosshairLength * FFRatio);
        Vector2 NorthWestCenter = ScreenCenter - Vector2(Variables.XCrosshairMiddleSpacing * FFRatio, Variables.XCrosshairMiddleSpacing * FFRatio);
        Vector2 SouthEast = ScreenCenter - Vector2(-Variables.XCrosshairLength * FFRatio, -Variables.XCrosshairLength * FFRatio);
        Vector2 SouthEastCenter = ScreenCenter - Vector2(-Variables.XCrosshairMiddleSpacing * FFRatio, -Variables.XCrosshairMiddleSpacing * FFRatio);
        Vector2 NorthEast = ScreenCenter - Vector2(-Variables.XCrosshairLength * FFRatio, Variables.XCrosshairLength * FFRatio);
        Vector2 NorthEastCenter = ScreenCenter - Vector2(-Variables.XCrosshairMiddleSpacing * FFRatio, Variables.XCrosshairMiddleSpacing * FFRatio);
        Vector2 SouthWest = ScreenCenter - Vector2(Variables.XCrosshairLength * FFRatio, -Variables.XCrosshairLength * FFRatio);
        Vector2 SouthWestCenter = ScreenCenter - Vector2(Variables.XCrosshairMiddleSpacing * FFRatio, -Variables.XCrosshairMiddleSpacing * FFRatio);
        
        ImU32 XCrosshairColor = Variables.XCrosshairColor.toU32();
        
        ImGui::GetForegroundDrawList()->AddLine(NorthWest.toVec2(), NorthWestCenter.toVec2(), XCrosshairColor, Variables.XCrosshairWidth);
        ImGui::GetForegroundDrawList()->AddLine(SouthEast.toVec2(), SouthEastCenter.toVec2(), XCrosshairColor, Variables.XCrosshairWidth);
        ImGui::GetForegroundDrawList()->AddLine(NorthEast.toVec2(), NorthEastCenter.toVec2(), XCrosshairColor, Variables.XCrosshairWidth);
        ImGui::GetForegroundDrawList()->AddLine(SouthWest.toVec2(), SouthWestCenter.toVec2(), XCrosshairColor, Variables.XCrosshairWidth);
    }
}
void Crosshair::HandleGameCrosshair(){
    AShooterGameState* GameState = QuickOffsets::GetGameState();
    
    if(GameState->IsValid()){
        if(GameState->isA_Safe(StaticClass::ShooterGameState())){
            GameState->GetbServerCrosshair() = !Variables.EnableCrosshair;
        }
    }
}





/*
 Begin Quick Kit Spawning
 */

// For this function, I'm assuming all the proper checks have already been done
// Might have an issue when spawning more than 250 Items at a time
void KitItem::Spawn(){
    
    
    //This will only be for Items which can in fact stack this high
    if(CurrentAmmount > 1000){
        Utils::getInstance().HelperSpawnItem(ItemString, 1, CurrentAmmount);
    }
    //Large Quantity Spawn
    if(CurrentAmmount > 20){
        int Remaining = CurrentAmmount % 20;
        int SpawnTimes = CurrentAmmount / 20;
        
        Utils::getInstance().HelperSpawnItem(ItemString, SpawnTimes, 20);
        Utils::getInstance().HelperSpawnItem(ItemString, Remaining, 1);
    }
    //Normal Quantity Spawn
    else {
        Utils::getInstance().HelperSpawnItem(ItemString, CurrentAmmount, 1);
    }
    
}

/*
 Saves the spawn ammount of the item to the plist
 */
void KitItem::SaveToDict(){
    NSString* KitPath = QuickKit::getInstance().GetSavePath();
    NSMutableDictionary *KitData = [[NSMutableDictionary alloc] initWithContentsOfFile:KitPath];
    if(!KitData){
        KitData = [[NSMutableDictionary alloc] init];
    }

    [KitData setObject:@(CurrentAmmount) forKey:StringToNSString(DisplayName)];
    [KitData writeToFile:KitPath atomically:YES];

}

/*
 Loads the spawn ammount of the item from the dict
 */
void KitItem::LoadFromDict(){
    NSString* KitPath = QuickKit::getInstance().GetSavePath();
    NSDictionary *KitData = [[NSDictionary alloc] initWithContentsOfFile:KitPath];
    if(KitData){
        NSNumber *SpawnAmmount = [KitData objectForKey:StringToNSString(this->DisplayName)];
        if (SpawnAmmount) {
            this->CurrentAmmount = (int)[SpawnAmmount integerValue];
            this->CurrentAmmount = this->CurrentAmmount > this->MaxAmmount ? this->MaxAmmount : this->CurrentAmmount;
        }
    }
}


void KitItem::Incriment(int howMuch){
    CurrentAmmount += howMuch;
    CurrentAmmount = CurrentAmmount > MaxAmmount ? MaxAmmount : CurrentAmmount;
    CurrentAmmount = CurrentAmmount < 0 ? 0 : CurrentAmmount;
}
/*
 Draws the row in ImGui
 */

void KitItem::DrawRow(){
    float Width = ImGui::GetContentRegionAvailWidth();
    ImGui::Text("%s", DisplayName.c_str());
    
    ImGui::SameLine(Width/4);
    
    std::string firstID = string_format("%s one", DisplayName.c_str());
    std::string secondID = string_format("%s two", DisplayName.c_str());
    std::string thirdID = string_format("%s three", DisplayName.c_str());
    std::string fourthID = string_format("%s four", DisplayName.c_str());
    

    ImGui::PushID(firstID.c_str());
    if(ImGui::Button("-5", ImVec2(30, 0))){
        Incriment(-5);
    }
    ImGui::PopID();
    
    ImGui::SameLine();
    
    
    ImGui::PushID(secondID.c_str());
    if(ImGui::Button("-1", ImVec2(30, 0))){
        Incriment(-1);
    }
    ImGui::PopID();
    ImGui::SameLine();
    
    ImGui::PushID(thirdID.c_str());
    if(ImGui::Button("+1", ImVec2(30, 0))){
        Incriment(1);
    }
    ImGui::PopID();
    ImGui::SameLine();
    
    ImGui::PushID(fourthID.c_str());
    if(ImGui::Button("+5", ImVec2(30, 0))){
        Incriment(5);
    }
    ImGui::PopID();
    
    ImGui::SameLine(Width*2/3);
    ImGui::Text("Current: %4d / %4d", CurrentAmmount, MaxAmmount);
}

NSString* QuickKit::GetSavePath(){
    
    // Path to the Plist
    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"kit.plist"];
    
    //Create the Plist if it doesn't already exist./Users/carsonmobile/Desktop/XCTests/PVPArena/PVPArenaDylib/src/Utils.mm
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSDictionary *initialData = @{};
        [initialData writeToFile:filePath atomically:YES];
    }
    
    return filePath;
}
/*
 Initialize the kit vector with the default values.
 */
void QuickKit::Initialize(){
    kit.clear();
    kit.push_back(KitItem("Fabricated Sniper", 1, 5, "Blueprint'/Game/PrimalEarth/CoreBlueprints/Weapons/PrimalItem_WeaponMachinedSniper.PrimalItem_WeaponMachinedSniper_C'"));
    kit.push_back(KitItem("Compound Bow", 1, 2, "Blueprint'/Game/PrimalEarth/CoreBlueprints/Weapons/PrimalItem_WeaponCompoundBow.PrimalItem_WeaponCompoundBow_C'"));
    kit.push_back(KitItem("Assault Rifle", 0, 3, "Blueprint'/Game/PrimalEarth/CoreBlueprints/Weapons/PrimalItem_WeaponRifle.PrimalItem_WeaponRifle_C'"));
    kit.push_back(KitItem("Fabricated Pistol", 0, 3, "Blueprint'/Game/PrimalEarth/CoreBlueprints/Weapons/PrimalItem_WeaponMachinedPistol.PrimalItem_WeaponMachinedPistol_C'"));
    kit.push_back(KitItem("Shotgun", 0, 3, "Blueprint'/Game/PrimalEarth/CoreBlueprints/Weapons/PrimalItem_WeaponMachinedShotgun.PrimalItem_WeaponMachinedShotgun_C'"));
    kit.push_back(KitItem("Simple Pistol", 0, 1, "Blueprint'/Game/PrimalEarth/CoreBlueprints/Weapons/PrimalItem_WeaponGun.PrimalItem_WeaponGun_C'"));
    kit.push_back(KitItem("Longneck", 0, 1, "Blueprint'/Game/PrimalEarth/CoreBlueprints/Weapons/PrimalItem_WeaponOneShotRifle.PrimalItem_WeaponOneShotRifle_C'"));
    kit.push_back(KitItem("Club", 1, 3, "Blueprint'/Game/PrimalEarth/CoreBlueprints/Weapons/PrimalItem_WeaponStoneClub.PrimalItem_WeaponStoneClub_C'"));
    kit.push_back(KitItem("Sword", 0, 2, "Blueprint'/Game/PrimalEarth/CoreBlueprints/Weapons/PrimalItem_WeaponSword.PrimalItem_WeaponSword_C'"));
    kit.push_back(KitItem("Cutlas", 0, 10, "Blueprint'/Game/PrimalEarth/CoreBlueprints/Weapons/PrimalItem_WeaponCutlass.PrimalItem_WeaponCutlass_C'"));
    kit.push_back(KitItem("Pike", 0, 2, "Blueprint'/Game/PrimalEarth/CoreBlueprints/Weapons/PrimalItem_WeaponPike.PrimalItem_WeaponPike_C'"));
    kit.push_back(KitItem("Eerie Pistol", 0, 1, "Blueprint'/Game/Mobile/Pursuits/Caves/TributeRewards/PrimalItem_WeaponSuperGun.PrimalItem_WeaponSuperGun_C'"));
    kit.push_back(KitItem("Electric Prod", 0, 20, "Blueprint'/Game/PrimalEarth/CoreBlueprints/Weapons/PrimalItem_WeaponProd.PrimalItem_WeaponProd_C'"));
    //Rockets are currently disabled due to being fucking broken
    //kit.push_back(KitItem("Rocket Launcher", 0, 4, "Blueprint'/Game/PrimalEarth/CoreBlueprints/Weapons/PrimalItem_WeaponRocketLauncher.PrimalItem_WeaponRocketLauncher_C'"));
    
    //Consumables
    kit.push_back(KitItem("Med Brews", 50, 100, "Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Consumables/PrimalItemConsumable_HealSoup.PrimalItemConsumable_HealSoup_C'"));
    kit.push_back(KitItem("Stam Brews", 50, 100, "Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Consumables/PrimalItemConsumable_StaminaSoup.PrimalItemConsumable_StaminaSoup_C'"));
    kit.push_back(KitItem("Focal Chille", 1, 10, "Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Consumables/PrimalItemConsumable_Soup_FocalChili.PrimalItemConsumable_Soup_FocalChili_C'"));
    kit.push_back(KitItem("Enduro Stew", 1, 10, "Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Consumables/PrimalItemConsumable_Soup_EnduroStew.PrimalItemConsumable_Soup_EnduroStew_C'"));
    kit.push_back(KitItem("Lazarus Chowder", 1, 10, "Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Consumables/PrimalItemConsumable_Soup_LazarusChowder.PrimalItemConsumable_Soup_LazarusChowder_C'"));
    kit.push_back(KitItem("Stimulant", 50, 100, "Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Consumables/PrimalItemConsumable_Stimulant.PrimalItemConsumable_Stimulant_C'"));
    kit.push_back(KitItem("Parachute", 10, 20, "Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Consumables/BaseBPs/PrimalItemConsumableBuff_Parachute.PrimalItemConsumableBuff_Parachute_C'"));
    kit.push_back(KitItem("Legday", 1, 10, "Blueprint'/Game/PrimalEarth/Test/PrimalItemConsumable_LegDay.PrimalItemConsumable_LegDay_C'"));
    kit.push_back(KitItem("Feast", 1, 10, "Blueprint'/Game/PrimalEarth/Test/PrimalItemConsumable_Feast.PrimalItemConsumable_Feast_C'"));
    kit.push_back(KitItem("Thick Skin", 1, 10, "Blueprint'/Game/PrimalEarth/Test/PrimalItemConsumable_ThickSkin.PrimalItemConsumable_ThickSkin_C'"));
    kit.push_back(KitItem("Shadow Steak", 20, 100, "Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Consumables/PrimalItemConsumable_Soup_ShadowSteak.PrimalItemConsumable_Soup_ShadowSteak_C'"));
    kit.push_back(KitItem("Beer", 0, 20, "Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Consumables/PrimalItemConsumable_BeerJar.PrimalItemConsumable_BeerJar_C'"));
    kit.push_back(KitItem("Antidote", 0, 20, "Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Consumables/BaseBPs/PrimalItemConsumable_CureLow.PrimalItemConsumable_CureLow_C'"));
    kit.push_back(KitItem("Battle Tartare", 0, 20, "Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Consumables/PrimalItemConsumable_Soup_BattleTartare.PrimalItemConsumable_Soup_BattleTartare_C'"));
    //Ammo
    kit.push_back(KitItem("Metal Arrows", 100, 500, "Blueprint'/Game/PrimalEarth/CoreBlueprints/Weapons/PrimalItemAmmo_CompoundBowArrow.PrimalItemAmmo_CompoundBowArrow_C'"));
    kit.push_back(KitItem("Advanced Sniper Bullets", 70, 350, "Blueprint'/Game/PrimalEarth/CoreBlueprints/Weapons/PrimalItemAmmo_AdvancedSniperBullet.PrimalItemAmmo_AdvancedSniperBullet_C'"));
    kit.push_back(KitItem("Toxicant Arrows", 0, 200, "Blueprint'/Game/PrimalEarth/CoreBlueprints/Weapons/PrimalItemAmmo_ArrowToxin.PrimalItemAmmo_ArrowToxin_C'"));
    kit.push_back(KitItem("Advanced Rifle Bullet", 0, 1000, "Blueprint'/Game/PrimalEarth/CoreBlueprints/Weapons/PrimalItemAmmo_AdvancedRifleBullet.PrimalItemAmmo_AdvancedRifleBullet_C'"));
    kit.push_back(KitItem("Advaned Bullet", 0, 500, "Blueprint'/Game/PrimalEarth/CoreBlueprints/Weapons/PrimalItemAmmo_AdvancedBullet.PrimalItemAmmo_AdvancedBullet_C'"));
    kit.push_back(KitItem("Shotgun Shell", 0, 300, "Blueprint'/Game/PrimalEarth/CoreBlueprints/Weapons/PrimalItemAmmo_SimpleShotgunBullet.PrimalItemAmmo_SimpleShotgunBullet_C'"));
    kit.push_back(KitItem("Simple Bullet", 0, 400, "Blueprint'/Game/PrimalEarth/CoreBlueprints/Weapons/PrimalItemAmmo_SimpleBullet.PrimalItemAmmo_SimpleBullet_C'"));
    kit.push_back(KitItem("Simple Rifle Ammo", 0, 200, "Blueprint'/Game/PrimalEarth/CoreBlueprints/Weapons/PrimalItemAmmo_SimpleRifleBullet.PrimalItemAmmo_SimpleRifleBullet_C'"));
    kit.push_back(KitItem("Tranq Dart", 0, 100, "Blueprint'/Game/PrimalEarth/CoreBlueprints/Weapons/PrimalItemAmmo_TranqDart.PrimalItemAmmo_TranqDart_C'"));
    //Rockets are currently disabled due to being fucking broken
    //kit.push_back(KitItem("Rockets", 0, 50, "Blueprint'/Game/PrimalEarth/CoreBlueprints/Weapons/PrimalItemAmmo_Rocket.PrimalItemAmmo_Rocket_C'"));
    
    //Weight
    kit.push_back(KitItem("Black Pearl", 0, 5000, "Blueprint'/Game/PrimalEarth/CoreBlueprints/Resources/PrimalItemResource_BlackPearl.PrimalItemResource_BlackPearl_C'"));
    
    //TEK Armor
    kit.push_back(KitItem("TEK Helmet", 2, 2, "Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Armor/TEK/PrimalItemArmor_TekHelmet.PrimalItemArmor_TekHelmet_C'"));
    kit.push_back(KitItem("TEK Chestplate", 2, 2, "Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Armor/TEK/PrimalItemArmor_TekShirt.PrimalItemArmor_TekShirt_C'"));
    kit.push_back(KitItem("TEK Leggings", 2, 2, "Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Armor/TEK/PrimalItemArmor_TekPants.PrimalItemArmor_TekPants_C'"));
    kit.push_back(KitItem("TEK Gauntlets", 2, 2,"Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Armor/TEK/PrimalItemArmor_TekGloves.PrimalItemArmor_TekGloves_C'"));
    kit.push_back(KitItem("TEK Boots", 2, 2, "Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Armor/TEK/PrimalItemArmor_TekBoots.PrimalItemArmor_TekBoots_C'"));
    
    //Riot Armor
    kit.push_back(KitItem("Riot Helmet", 0, 5, "Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Armor/Riot/PrimalItemArmor_RiotHelmet.PrimalItemArmor_RiotHelmet_C'"));
    kit.push_back(KitItem("Riot Chestplate", 0, 5, "Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Armor/Riot/PrimalItemArmor_RiotShirt.PrimalItemArmor_RiotShirt_C'"));
    kit.push_back(KitItem("Riot Leggings", 0, 5, "Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Armor/Riot/PrimalItemArmor_RiotPants.PrimalItemArmor_RiotPants_C'"));
    kit.push_back(KitItem("Riot Gauntlets", 0, 5, "Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Armor/Riot/PrimalItemArmor_RiotGloves.PrimalItemArmor_RiotGloves_C'"));
    kit.push_back(KitItem("Riot Boots", 0, 5, "Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Armor/Riot/PrimalItemArmor_RiotBoots.PrimalItemArmor_RiotBoots_C'"));
    
    //Other Arketypes
    kit.push_back(KitItem("Frog Feet", 0, 5, "Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Armor/ARKetypes/PrimalItemArmor_FrogFeet.PrimalItemArmor_FrogFeet_C'"));
    kit.push_back(KitItem("Aerial Symbiote", 0, 5, "Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/Misc/Special/PrimalItem_DragonFlyWings.PrimalItem_DragonFlyWings_C'"));
    
    //Attachments
    kit.push_back(KitItem("Silener", 1, 5, "Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/WeaponAttachments/PrimalItemWeaponAttachment_Silencer.PrimalItemWeaponAttachment_Silencer_C'"));
    kit.push_back(KitItem("Scope", 0, 5, "Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/WeaponAttachments/PrimalItemWeaponAttachment_Scope.PrimalItemWeaponAttachment_Scope_C'"));
    kit.push_back(KitItem("Laser Pointer", 0, 5, "Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/WeaponAttachments/PrimalItemWeaponAttachment_Laser.PrimalItemWeaponAttachment_Laser_C'"));
    kit.push_back(KitItem("Holographic Scope", 0, 5, "Blueprint'/Game/PrimalEarth/CoreBlueprints/Items/WeaponAttachments/PrimalItemWeaponAttachment_HoloScope.PrimalItemWeaponAttachment_HoloScope_C'"));
    
    PagesCount = (int)((kit.size() - 1) / ItemsPerPage) + 1;
    CurrentPage = 1;
}

void QuickKit::LoadKitItems(){
    for(KitItem& currentItem : kit){
        currentItem.LoadFromDict();
    }
}

void QuickKit::SpawnKit(bool forceSpawn){
    if(QuickOffsets::isServerLoaded() && ((!ArenaManager::getInstance().isPlayerInsideAnArena() && SafeZone::getInstance().isPlayerInsideSafeZone()) || forceSpawn)){
        
        //First, Clear Inventory of all Current Items
        Utils::getInstance().ClearInventory();
        
        //Then, Spawn the kit
        for(KitItem& currentItem : kit){
            currentItem.Spawn();
        }
    }
}

void QuickKit::SaveKitItems(){
    for(KitItem& currentItem : kit){
        currentItem.SaveToDict();
    }
}

void QuickKit::NextPage(){
    CurrentPage++;
    CurrentPage = CurrentPage > PagesCount ? PagesCount : CurrentPage;
}
void QuickKit::PreviousPage(){
    CurrentPage--;
    CurrentPage = CurrentPage < 1 ? 1 : CurrentPage;
}

/*
 Draws the kit page in the menu
 */
void QuickKit::MenuDrawPage(){
    ImGui::SetWindowFontScale(1.2);
    
    
    float Width = ImGui::GetContentRegionAvailWidth();
    ImGui::NewLine();
    ImGui::SameLine(Width/2 - ImGui::CalcTextSize("Kit Items List:").x);
    
    ImGui::Text("Kit Items List:");
    ImGui::Separator();
    
    
    int startingIndex = (CurrentPage - 1) * ItemsPerPage;
    int endingIndex = CurrentPage * ItemsPerPage;
    endingIndex = endingIndex > (int)kit.size() ? (int)kit.size() : endingIndex;
    
    for(int i = startingIndex; i<endingIndex; ++i){
        kit[i].DrawRow();
        ImGui::Spacing();
    }
    
    ImGui::Spacing();
    ImGui::Spacing();
    ImGui::Spacing();
    ImGui::Spacing();
    
    ImGui::SameLine(Width/5);
    

    if(ImGui::Button("Previous", ImVec2(Width/5 - 20, 0))){
        PreviousPage();
    }

    ImGui::SameLine(2*Width/5);
    
    ImGui::Text("Page: (%d/%d)", CurrentPage, PagesCount);
    ImGui::SameLine(3*Width/5);
    
    
    //ImGui::PushItemWidth(Width/5 - 20);
    if(ImGui::Button("Next", ImVec2(Width/5 - 20, 0))){
        NextPage();
    }
 
    
    
    ImGui::SetWindowFontScale(0.9);
}
/*
 int CurrentPage = 1;
 int PagesCount = 0;
 int ItemsPerPage = 9;
 
 void MenuDrawPage();
 void NextPage();
 void PreviousPage();
 */




/*
 
 Spawning Argy Arenas:
 
 static std::vector<Vector3> BossArenaLocations;
 static void TimerSpawnArenas(int times){
     if(times == BossArenaLocations.size()) return;
     timer(2){
         
         FunctionCalls::getInstance().CheatCommand(string_format("spi %f %f %f", BossArenaLocations[times].X,BossArenaLocations[times].Y,BossArenaLocations[times].Z));
         FunctionCalls::getInstance().CheatCommand("SpawnActor \"Blueprint'/Game/Mobile/Dungeon/BossArena/BossArena.BossArena_C'\" 0 0 200");
         
         TimerSpawnArenas(times+1);
     });
 }

 static void SpawnArgy(){
     //Spawn argy above me so that it's force tamed and level 150
     //FunctionCalls::getInstance().CheatCommand("GMSummon \"Argent_Character_BP_C\" 150");
     
     //first: 190000, 100000, -17000}; (Green Obi south)
     //second: -211775 65066 -9385 (60/30)
     //third: 55714 -170454 -5000 (North of obsi)
     //Fourth: 7224 -89047 -7139
     //Fifth: -54910 80399 -5562
     FunctionCalls::getInstance().CheatCommand("ghost");
     FunctionCalls::getInstance().CheatCommand("SetGodMode 1");
     Vector3 Center = {-54910, 80399, -5562};
     
     //Spawn Walls 1
     for(int i = 0; i < 7; ++i){
         float ZAxis = Center.Z + 4000 * i;
         BossArenaLocations.push_back(Vector3(Center.X - 10000, Center.Y - 20000, ZAxis));
         BossArenaLocations.push_back(Vector3(Center.X , Center.Y - 20000, ZAxis));
         BossArenaLocations.push_back(Vector3(Center.X + 10000, Center.Y - 20000, ZAxis));
     }
     
     //Spawn Walls 2
     for(int i = 0; i < 7; ++i){
         float ZAxis = Center.Z + 4000 * i;
         BossArenaLocations.push_back(Vector3(Center.X - 10000, Center.Y + 20000, ZAxis));
         BossArenaLocations.push_back(Vector3(Center.X , Center.Y + 20000, ZAxis));
         BossArenaLocations.push_back(Vector3(Center.X + 10000, Center.Y + 20000, ZAxis));
     }
     
     //Spawn Walls 3
     for(int i = 0; i < 7; ++i){
         float ZAxis = Center.Z + 4000 * i;
         BossArenaLocations.push_back(Vector3(Center.X - 20000, Center.Y - 10000, ZAxis));
         BossArenaLocations.push_back(Vector3(Center.X - 20000, Center.Y, ZAxis));
         BossArenaLocations.push_back(Vector3(Center.X - 20000, Center.Y + 10000, ZAxis));
     }
     
     //Spawn Walls 4
     for(int i = 0; i < 7; ++i){
         float ZAxis = Center.Z + 4000 * i;
         BossArenaLocations.push_back(Vector3(Center.X + 20000, Center.Y - 10000, ZAxis));
         BossArenaLocations.push_back(Vector3(Center.X + 20000, Center.Y, ZAxis));
         BossArenaLocations.push_back(Vector3(Center.X + 20000, Center.Y + 10000, ZAxis));
     }
     
     for(int i = -1; i<= 1; ++i){
         for(int j = -1; j<=1; ++j){
             BossArenaLocations.push_back(Vector3(Center.X + i * 10000, Center.Y + j * 10000, Center.Z + 27000));
         }
     }
     
     TimerSpawnArenas(0);
     for(int i = 0; i<BossArenaLocations.size(); ++i){
         
     }
     
     //Roof
     
 }
 */

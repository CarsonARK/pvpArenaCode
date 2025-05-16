//
//  MenuLoops.m
//  PVPArenaDylib
//
//  Created by Carson Mobile on 6/10/24.
//

#import <Foundation/Foundation.h>
#include "../Includes.h"

/*
 1. Crosshair
 4. Anticheat
 */
void MenuLoop::InitializeGame(){
    ServerIP = ENCRYPT("95.156.198.77:20500");
    ServerPassword = ENCRYPT("carsonpassword8");
    ServerAdminPassword = ENCRYPT("ok");
    
    
    //Initialize the Arena
    ArenaManager::getInstance().InitializeArenas();
    SafeZone::getInstance().Initialize();
    Utils::getInstance().Set120FPS();
    Anticheat::getInstance().Startup();
    
    //Setup the Quick Kit feature.
    QuickKit::getInstance().Initialize();
    QuickKit::getInstance().LoadKitItems();
    
    //Initialize Amber Shop
    AmberShop::getInstance().Init();
    
    DuelManager::getInstance().LoadIgnoredPlayersList();
}
void MenuLoop::Update(){
    //Register the Process Event Hooks every Frame, So if an object changes the hook will nearly instantly hook the new object.
    GameHooks::RegisterHooks();

    Utils::getInstance().AllyEveryoneNearby();
    Utils::getInstance().DisableCharacterCreation();
    Utils::getInstance().HandleTimeOfDay();
    Utils::getInstance().HandleFOV();
    Crosshair::getInstance().DrawCrosshair();
    Crosshair::getInstance().HandleRainbow();
    Crosshair::getInstance().HandleGameCrosshair();
    Anticheat::getInstance().Update();
    
    
    //Check for expired incoming duel requests
    DuelManager::getInstance().CheckForExpiration();
    
    
    //Update the menu languages
    SetLanguage((ECurrentLanguage)Variables.Language);
    
}
/*
 CHANGE LOGS:
 
 PVPArenaB5 https://drive.google.com/file/d/16H1-YrKAhnX_5pdJGypxn18gMEHjW1bb/view?usp=sharing
 Change Log
- Capped bolas & grapples from kills at 6
- Automatically apply grapples to crossbow
- Automatically Attach silencer / laser to fabi
- New Arena
- 7 seconds of invulnerability on joining the arena
- Automatically consume buffs in safe zone
- Added option to teleport from arena to safe zone after 60 seconds of not getting hit
- Removed ability to pickup bags from the ground
- Changed Icon
 
 
 PVPArenaB6
 Change Log
 -
 */

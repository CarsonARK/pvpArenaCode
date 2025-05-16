//
//  DataManager.m
//  PVPArenaDylib
//
//  Created by Carson Mobile on 6/15/24.
//

#import <Foundation/Foundation.h>
#include "../Includes.h"


static std::string removeColons(std::string input) {
    std::string result = input; // Copy the input string
    
    if(result.length() > 0)
        result.erase(std::remove(result.begin(), result.end(), ':'), result.end());
    
    return result;
}
static std::vector<std::string> split(const std::string& s, char delimiter) {
    std::vector<std::string> tokens;
    std::string token;
    std::istringstream tokenStream(s);
    while (std::getline(tokenStream, token, delimiter)) {
        tokens.push_back(token);
    }
    return tokens;
}

//ArenaData:PlayerData:<PlayerID>:<Level>:<CurrentLocation>:<isAccepting1v1Requests>:<ELORating>:<Kills>:<Deaths>:<PlayerName>
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
 
 IncomingString formatted like
 ArenaData:PlayerData:<PlayerID>:<Level>:<CurrentLocation>:<isAccepting1v1Requests>:<ELORating>:<Kills>:<Deaths>:<PlayerName>
 
 
 ServerChat ArenaData:PlayerData:stuffandthings
 */


//returns true if it's arena data, which we don't want the client to see.
bool IncomingData::HandleIncomingData(std::string IncomingString){
    NSString* IncomingData = StringToNSString(IncomingString);
    
    if([IncomingData containsString:@"ArenaData"]){
        NSArray* parts = [IncomingData componentsSeparatedByString:@":"];
        if([[parts[1] stringValue] isEqualToString:@"PlayerData"]){
            HandleIncomingPlayerListData(parts);
        }
        
        //All Data Related to a Duel
        if([[parts[1] stringValue] isEqualToString:@"DuelData"]){
            
            [UIPasteboard generalPasteboard].string = IncomingData;
            
            if([[parts[2] stringValue] isEqualToString:@"DuelCompleted"]){
                HandleIncomingDuelCompleted(parts);
            }
            else if([[parts[2] stringValue] isEqualToString:@"DuelAccept"]){
                HandleIncomingDuelAccepted(parts);
            }
            else if([[parts[2] stringValue] isEqualToString:@"DuelInitiate"]){
                HandleIncomingDuelInitiated(parts);
            }
            else if([[parts[2] stringValue] isEqualToString:@"DuelDecline"]){
                HandleIncomingDuelDeclined(parts);
            }
            else if([[parts[2] stringValue] isEqualToString:@"DuelCanceled"]){
                HandleIncomingDuelCanceled(parts);
            }
        }
            
            
            
        return true;
    }
    
    return false;
}

//Makes it here correctly.

//ArenaData:PlayerData:<PlayerID>:<Level>:<CurrentLocation>:<isAccepting1v1Requests>:<ELORating>:<Kills>:<Deaths>:<PlayerName>
void IncomingData::HandleIncomingPlayerListData(NSArray* Parts){
    PlayerData& CurrentPlayer = PlayerList::getInstance().DataForID([Parts[2] longLongValue]);
    CurrentPlayer.timeAdded = std::chrono::steady_clock::now();
    CurrentPlayer.isOnline = YES;
    CurrentPlayer.OfflineTime = 0;
    CurrentPlayer.Level = [Parts[3] intValue];
    NSArray *locationParts = [Parts[4] componentsSeparatedByString:@","];
    if (locationParts.count == 3) {
        CurrentPlayer.CurrentLocation = { [locationParts[0] floatValue], [locationParts[1] floatValue], [locationParts[2] floatValue] };
    }
    CurrentPlayer.isAccepting1v1Requests = [Parts[5] boolValue];
    CurrentPlayer.ELORating = [Parts[6] floatValue];
    CurrentPlayer.Kills = [Parts[7] intValue];
    CurrentPlayer.Deaths = [Parts[8] intValue];
    CurrentPlayer.PlayerName = [Parts[9] UTF8String];
}
//                0     1           2               3               4               5
//ServerChat ArenaData:DuelData:DuelCompleted:<WinnerPlayerID>:<LosingPlayerID>:<ArenaID>
void IncomingData::HandleIncomingDuelCompleted (NSArray* Parts){
    std::string ArenaID = [Parts[5] UTF8String];
    ArenaManager::getInstance().DuelArenaForString(ArenaID).SetArenaOpen();
}

//              0        1          2          3        4               5                   6                       7               8
//ServerChat ArenaData:DuelData:DuelAccept:<DuelID>:<Timestamp>:<DuelSenderPlayerID>:<DuelAccepterPlayerID>:<DuelAccepterTribeID>:<ArenaID>
/*
 This means I sent a duel request to someone, and they accepted my request
 This makes me the DuelSender
 */
void IncomingData::HandleIncomingDuelAccepted(NSArray* Parts){
    //ArenaManager DuelArenaForString
    //This means i sent the duel request
    if([Parts[5] longLongValue] == PlayerStats::getInstance().GetPlayerID())
    {
        //Cancel My Outgoing Duel Request on my screen
        DuelManager::getInstance().sentDuel.isValid = false;
        DuelArena& duelArena = ArenaManager::getInstance().DuelArenaForString([Parts[8] UTF8String]);
        duelArena.StartFight([Parts[5] longLongValue], PlayerStats::getInstance().GetTribeID(), [Parts[6] longLongValue], [Parts[7] longLongValue], true, DuelManager::getInstance().sentDuel.kitType);
    }
    else {
        ArenaManager::getInstance().DuelArenaForString([Parts[8] UTF8String]).SetArenaOccupied();
    }
}

//request from ipad:
// ArenaData:DuelData:DuelInitiate:Doed_1718599181313:1718599181313:618446022:1286075291:Reliable Assista..:100:0:123442642:Doed:2:Come Fight Me!:545483436
//Oh, Also expiration time seems to be wrong.
//              ArenaData:DuelData:DuelInitiate:Doed_1718597218610:1718597218610:123442642:1414100686:PlainGopher3925:65:0:618446022:Doed:2:Come Fight Me!:518153376
//              0           1          2         3        4             5               6               7                   8           9               10              11          12          13              14
// ServerChat ArenaData:DuelData:DuelInitiate:<DuelID>:<Timestamp>:<SenderPlayerID>:<SenderTribeID>:<SenderPlayerName>:<SenderLevel>:<SenderELO>:<RecievingPlayerID>:<ArenaType>:<KitType>:<CustomMessage>:<ExpirationTime>
void IncomingData::HandleIncomingDuelInitiated(NSArray* Parts){
    
    //return;
    //The request is going to me, i should handle it.
    //Utils::getInstance().ShowError([NSString stringWithFormat:@"Parts Size: %d", Parts.count]);
    //uint64_t PlayerID = PlayerStats::getInstance().GetPlayerID(); //123442642?
    //uint64_t RecievingPlayerID = [Parts[10] longLongValue]; //618446022?
    
    //[Parts[10] unsignedLongValue]; seems to crash me, no idea why as of yet.
    
    //Utils::getInstance().ShowError([NSString stringWithFormat:@"PlayerID: %ld", PlayerID]);
    //return;
    
    if([Parts[10] longLongValue] == PlayerStats::getInstance().GetPlayerID()){
        std::string DuelID = [Parts[3] UTF8String];
        auto TimeSent = std::chrono::steady_clock::time_point(std::chrono::milliseconds([Parts[4] longLongValue]));
        auto TimeExpires = std::chrono::steady_clock::time_point(std::chrono::milliseconds([Parts[14] longLongValue]));
        uint64_t SenderPlayerID = [Parts[5] longLongValue];
        uint64_t SenderTribeID = [Parts[6] longLongValue];
        std::string SenderPlayerName = [Parts[7] UTF8String];
        int SenderLevel = [Parts[8] intValue];
        float SenderELO = [Parts[9] floatValue];
        std::string ArenaType = [Parts[11] UTF8String];
        EKitType arenaKitType = (EKitType)[Parts[12] intValue];
        std::string CustomMessage = [Parts[13] UTF8String];
        
        DuelManager::getInstance().CreateIncomingRequest(DuelID, TimeSent, SenderPlayerID, SenderTribeID, SenderPlayerName, SenderLevel, SenderELO, arenaKitType, ArenaType, CustomMessage, TimeExpires);
    }
    else {
        DuelManager::getInstance().CheckForDoubleDuel([Parts[5] longLongValue]);
    }
}
//  0         1           2         3       4
//ArenaData:DuelData:DuelDecline:<DuelID>:<Reason>
//SendServerMessage(string_format("ArenaData:DuelData:DuelDecline:%s:%s", DuelID.c_str(), Reason.c_str()));
/*
 This means you were the one who sent the duel request, and the other person declined it
 */
void IncomingData::HandleIncomingDuelDeclined(NSArray* Parts){
    if(DuelManager::getInstance().sentDuel.isValid){
        
        //if the duel that was cancled was the duel I sent to someone
        if(DuelManager::getInstance().sentDuel.DuelID == [Parts[3] UTF8String])
        {
            DuelManager::getInstance().sentDuel.isValid = false;
            SendClientMessage(string_format("Your Duel Request was declined. Reason: %s", [Parts[4] UTF8String]));
        }
        
    }
}
// ArenaData:DuelData:DuelCanceled:<DuelID>:<Reason>:<RecipientPlayerID>:<YourPlayerID>
/*      0       1       2               3       4           5                   6
 Duel Cancled means the person who sent the duel invite has decided to retract it
 */
void IncomingData::HandleIncomingDuelCanceled(NSArray* Parts){
    
    //This means the duel cancle was aimed at me, since I am the recipient
    if([Parts[5] longLongValue] == PlayerStats::getInstance().GetPlayerID())
    {
        DuelManager::getInstance().cancelDuelRequest([Parts[3] UTF8String]);
        DuelManager::getInstance().cancelDuelRequestFromPlayer([Parts[6] longLongValue]);
        //SendClientMessage(string_format(""))
    }
    //if(DuelManager::isPlayerIgnored(<#uint64_t playerID#>))
}
void IncomingData::SendClientMessage(std::string Message){
    FunctionQueue::GetI().AddTask([Message](){
    
        //Convert std::string to wString
        std::wstring WMessage = std::wstring_convert<std::codecvt_utf8_utf16<wchar_t>>().from_bytes(Message);
        
        //Convert wString to FString
        FString ClientMessage = FString(WMessage.c_str());
        
        APlayerController* MyContoller = QuickOffsets::GetPlayerController();
        if(MyContoller->isA_Safe(StaticClass::ShooterPlayerController())){
            MyContoller->ClientServerChatDirectMessage(ClientMessage);
        }
    });
}

/*
 ServerChat ArenaData:DuelData:DuelAccept:<DuelID>:<Timestamp>:<DuelSenderPlayerID>:<DuelAccepterPlayerID>:<DuelAccepterTribeID>:<ArenaID>
 ServerChat ArenaData:DuelData:DuelInitiate:<DuelID>:<Timestamp>:<SenderPlayerID>:<SenderTribeID>:<SenderPlayerName>:<SenderLevel>:<SenderELO>:<RecievingPlayerID>:<ArenaType>:<KitType>:<CustomMessage>:<ExpirationTime>
 ArenaData:DuelData:DuelDecline:<DuelID>:<Reason>
 ArenaData:DuelData:DuelCanceled:<DuelID>:<Reason>:<RecipientPlayerID>:<YourPlayerID>
 */






void OutgoingData::SendServerMessage(std::string MessageString){
    FunctionCalls::getInstance().CheatCommand(string_format("ServerChat %s", MessageString.c_str()));
}


void OutgoingData::PostMyPlayerData(){
    AShooterCharacter* MyCharacter = QuickOffsets::GetShooterCharacter();
    if(MyCharacter->isA_Safe(StaticClass::ShooterCharacter()))
    {
        std::string PlayerName = MyCharacter->GetPlayerName()->iosToString();
        uint64_t PlayerID = MyCharacter->GetLinkedPlayerDataID();
        int Level = MyCharacter->GetMyCharacterStatusComponent()->GetBaseCharacterLevel() + MyCharacter->GetMyCharacterStatusComponent()->GetExtraCharacterLevel();
        Vector3 Location = MyCharacter->GetActorLocation();
        
        std::string ChatString = string_format("ArenaData:PlayerData:%ld:%d:%f,%f,%f:%d:0:0:0:%s", PlayerID, Level, Location.X, Location.Y, Location.Z, Variables.Accepting1v1s, removeColons(PlayerName).c_str());
        SendServerMessage(ChatString);
    }
    /*
     //ArenaData:PlayerData:<PlayerID>:<Level>:<CurrentLocation>:<isAccepting1v1Requests>:<ELORating>:<Kills>:<Deaths>:<PlayerName>
     ServerChat ArenaData:PlayerData:111111:99:355500,912000,-40000:1:0:0:0:tempname
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
      */
}


void OutgoingData::ReportKill(uint64_t MurdererID, uint64_t VictimID, std::string MurdererName, std::string VicitmName){
    
}


void OutgoingData::SendDuelFinished(uint64_t MyPlayerID, uint64_t EnemyPlayerID, std::string ArenaName){
    //ServerChat ArenaData:DuelData:DuelCompleted:<WinnerPlayerID>:<LosingPlayerID>:<ArenaID>
    SendServerMessage(string_format("ArenaData:DuelData:DuelCompleted:%ld:%ld:%s", MyPlayerID, EnemyPlayerID, removeColons(ArenaName).c_str()));
}

// ServerChat ArenaData:DuelData:DuelAccept:<DuelID>:<Timestamp>:<DuelSenderPlayerID>:<DuelAccepterPlayerID>:<DuelAccepterTribeID>:<ArenaID>
void OutgoingData::AcceptDuelRequest(std::string DuelID, uint64_t DuelSenderPlayerID, uint64_t DuelAccepterPlayerID, uint64_t DuelAccepterTribeID, std::string ArenaID){
    long long currentTimeMS = std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::system_clock::now().time_since_epoch()).count();
    
    SendServerMessage(string_format("ArenaData:DuelData:DuelAccept:%s:%lld:%ld:%ld:%ld:%s", removeColons(DuelID).c_str(), currentTimeMS, DuelSenderPlayerID, DuelAccepterPlayerID, DuelAccepterTribeID, removeColons(ArenaID).c_str()));
}
void OutgoingData::DeclineDuelRequest(std::string DuelID, std::string Reason){
    SendServerMessage(string_format("ArenaData:DuelData:DuelDecline:%s:%s", removeColons(DuelID).c_str(), removeColons(Reason).c_str()));
    /*
     ArenaData:DuelData:DuelDecline:<DuelID>:<Reason>
     */
}
void OutgoingData::CancelDuelRequest(std::string DuelID, std::string Reason, uint64_t RecipientPlayerID, uint64_t MyPlayerID){
    SendServerMessage(string_format("ArenaData:DuelData:DuelCanceled:%s:%s:%lld:%lld", removeColons(DuelID).c_str(), removeColons(Reason).c_str(), RecipientPlayerID, MyPlayerID));
}
void OutgoingData::InitiateDuelRequest(std::string DuelIdentifier, long long TimestampMS, uint64_t SenderPlayerID, uint64_t SenderTribeID, std::string SenderPlayerName, int SenderLevel, float SenderELO, uint64_t toPlayerID, std::string ArenaType, uint8_t kitType, std::string CustomMessage, long long ExpirationMS){
    string DuelInitiateString = string_format("ArenaData:DuelData:DuelInitiate:%s:%lld:%ld:%ld:%s:%d:%.0f:%lld:%s:%d:%s:%lld", removeColons(DuelIdentifier).c_str(), TimestampMS, SenderPlayerID, SenderTribeID, removeColons(SenderPlayerName).c_str(), SenderLevel, SenderELO, toPlayerID, removeColons(ArenaType).c_str(), kitType, removeColons(CustomMessage).c_str(), ExpirationMS);
    SendServerMessage(DuelInitiateString);
}

                       // ArenaData:DuelData:DuelCanceled:<DuelID>:<Reason>:<RecipientPlayerID>:<YourPlayerID>

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
     
     //If Time Added goes above 10, Remove from list
     std::chrono::steady_clock::time_point timeAdded;
 };
 */
void PlayerList::RemovalCheck(){
    auto now = std::chrono::steady_clock::now();
    
    //Removes any players from the list who havn't been updated for more than the removal time.
    Players.erase(std::remove_if(Players.begin(), Players.end(),
            [now, this](const PlayerData& currentPlayer) {
                auto elapsed = std::chrono::duration_cast<std::chrono::seconds>(now - currentPlayer.timeAdded).count();
                return elapsed >= REMOVAL_TIME;
            }), Players.end());
    
    /*
    for(PlayerData& currentPlayer : Players){
        
        
        auto elapsed = std::chrono::duration_cast<std::chrono::seconds>(now - currentPlayer.timeAdded).count();

        if(elapsed >= REMOVAL_TIME){
            //Remove Player From List
        }
    } */
}
PlayerData& PlayerList::DataForID(uint64_t PlayerID){
    //Check if the player is already in the player list, if they are, return.
    for(PlayerData& currentPlayer : Players){
        if(currentPlayer.PlayerID == PlayerID)
            return currentPlayer;
    }
    
    PlayerData newPlayer;
    newPlayer.PlayerID = PlayerID;
    
    Players.push_back(newPlayer);
    return Players.back();
}

void PlayerList::DrawGuiTemp(){
    ImGui::Text("Player List: ");
    for(PlayerData& currentPlayer : Players){
        ImGui::Text("Player: %s ID: %llu Loc: %.0f , %.0f , %.0f", currentPlayer.PlayerName.c_str(), currentPlayer.PlayerID, currentPlayer.CurrentLocation.X, currentPlayer.CurrentLocation.Y, currentPlayer.CurrentLocation.Z);
    }
}
void PlayerList::DrawListTemp(std::vector<PlayerData>& data){
    ImGui::Text("Players In Arena: %lu \n Player List: ", data.size());
    for(PlayerData& currentPlayer : data){
        ImGui::Text("Player: %s ", currentPlayer.PlayerName.c_str());
    }
}

std::vector<PlayerData> PlayerList::GetPlayersInArena(std::string ArenaName){
    Arena& theArena = ArenaManager::getInstance().ArenaForString(ArenaName);
    std::vector<PlayerData> playersInArena;
    for(PlayerData& currentPlayer : Players){
        if(theArena.isLocationInsideArena(currentPlayer.CurrentLocation)){
            playersInArena.push_back(currentPlayer);
        }
    }
    return playersInArena;
}
std::vector<PlayerData> PlayerList::GetPlayersInSafeZone(){
    std::vector<PlayerData> playersInSafeZone;
    for(PlayerData& currentPlayer : Players){
        
        if(currentPlayer.PlayerID == PlayerStats::getInstance().GetPlayerID()) continue;
        
        if(SafeZone::getInstance().isLocationInsideSafeZone(currentPlayer.CurrentLocation)){
            playersInSafeZone.push_back(currentPlayer);
        }
    }
    return playersInSafeZone;
}
std::vector<PlayerData> PlayerList::GetValid1v1Players(){
    std::vector<PlayerData> playersInSafeZone;
    for(PlayerData& currentPlayer : Players){
        if(currentPlayer.PlayerID == PlayerStats::getInstance().GetPlayerID()) continue;
        //currentPlayer.isAccepting1v1Requests
        if( SafeZone::getInstance().isLocationInsideSafeZone(currentPlayer.CurrentLocation)){
            playersInSafeZone.push_back(currentPlayer);
        }
    }
    return playersInSafeZone;
}


uint64_t PlayerStats::GetPlayerID(){
    AShooterCharacter* MyCharacter = QuickOffsets::GetShooterCharacter();
    if(MyCharacter->isA_Safe(StaticClass::ShooterCharacter()))
    {
        uint64_t PlayerID = MyCharacter->GetLinkedPlayerDataID();
        return PlayerID;
    }
    return 0;
}
uint64_t PlayerStats::GetTribeID(){
    FTribeData TribeData = QuickOffsets::GetMyTribeData();
    return (uint64_t)TribeData.TribeID;
}
int PlayerStats::GetPlayerLevel(){
    AShooterCharacter* MyCharacter = QuickOffsets::GetShooterCharacter();
    UPrimalCharacterStatusComponent* MyStatusComponent = MyCharacter->GetMyCharacterStatusComponent();
    if(MyStatusComponent->isA_Safe(StaticClass::PrimalCharacterStatusComponent()))
    {
        return MyStatusComponent->GetBaseCharacterLevel() + MyStatusComponent->GetExtraCharacterLevel();
    }
    return 0;
}
/*
 FTribeData TribeData = QuickOffsets::GetMyTribeData();
 
 //A tribe ID of 0 means that you are not in a tribe.
 if(TribeData.TribeID == 0
 */

std::string PlayerStats::GetPlayerName(){
    AShooterCharacter* MyCharacter = QuickOffsets::GetShooterCharacter();
    if(MyCharacter->isA_Safe(StaticClass::ShooterCharacter()))
    {
        return MyCharacter->GetPlayerName()->iosToString();
    }
    return "GetNameFailed";
}

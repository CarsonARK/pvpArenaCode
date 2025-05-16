//
//  Utils.h
//  PVPArena
//
//  Created by Carson Mobile on 6/10/24.
//

#ifndef Utils_h
#define Utils_h







class FunctionCalls {
public:
    static FunctionCalls& getInstance() {
        static FunctionCalls instance;
        return instance;
    }
    
    void CheatCommand(std::string Command);
    void TeleportRandom();
    void Suicide();
    void ActivateAdmin(std::string Password);
    void JoinServer(std::string ServerIP, std::string ServerPassword);
    void SendAnnouncement(std::string AnnouncementMessage);
};



class Utils{
public:
    static Utils& getInstance(){
        static Utils instance;
        return instance;
    }
    void ShowError(NSString* ErrorMessage){
        timer(0){
            UIAlertController *ServerInfoAlert = [UIAlertController alertControllerWithTitle:ErrorMessage message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *Enter = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            }];
            [ServerInfoAlert addAction:Enter];
            [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:ServerInfoAlert animated:YES completion:nil];
        });
    }
    
    void Set120FPS();
    void HandleFOV();
    void HandleTimeOfDay();
    void HelperSpawnItem(std::string ItemBlueprintString, int numStacks, int ammount);
    
    void SpawnConsumables();
    void SpawnComp();
    void SpawnFabi();
    void SpawnAssaultRifle();
    void SpawnShotgun();
    void SpawnLongneck();
    void SpawnMele();
    void SpawnArketypes();
    void SpawnTekArmor();
    void SpawnRiotArmor();
    void SpawnWeight();
    void SpawnCostumes();
    void ClearInventory(bool bClearInventory = true, bool bClearSlotItems = true, bool bClearEquippedItems = false);
    
    
    void SpawnDyes();
    void SpawnMindwipe();
    void SpawnTickets();
    
    void HealAll();
    void GiveKillExp(float ExpAmmount);
    void GiveAmber(int AmberAmmount);
    
    void AutoArmor(bool ignoreSafeZoneCheck = false);
    void DropExcessArmor();
    void DisableCharacterCreation();
    void CreateTribe();
    void AllyEveryoneNearby();
    void UnclaimAllMyDinos();
    
    void AutoUseConsumables(bool ignoreSafeZoneCheck = false);
    void AutoApplyAttachments();
    
    std::vector<UPrimalItem*> GetAllInventoryItems(std::string ItemString);
    UPrimalItem* GetInventoryItem(std::string ItemString);
    int GetInventoryItemQuantity(std::string ItemString);
    bool hasBuff(std::string BuffName);
    std::string GetPrimalItemAttachmentName(UPrimalItem* Item);
    

     //Buff_Bola_C // Can't Teleport when Bolad
    
    /*
     Mindwipe Button
     Appearanace & Name Change Ticket, but disable creating new survivors.
     */
    
};


// "Purchase" Items by crushing amber into dust
// Drop the Dust -> Unable to pickup dropped items -> Unusable.
class AmberShop {
public:
    static AmberShop& getInstance(){
        static AmberShop instance;
        return instance;
    }
    
    AmberShop(){
        lastPurchaseTime = std::chrono::steady_clock::now();
    }
    
    void Init(){}
    
    int getAmberCount();
    bool hasEnoughAmber(int Amount);
    
    bool canPurchaseCooldown();
    void resetPurchaseCooldown();
    
    void Purchase(int Amount, std::function<void()> purchaseAction);
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
     
     Purchase(amount, []() {
             std::cout << "Executing custom action inside Purchase." << std::endl;
         });
     
     dropDust
     
     */
    std::chrono::steady_clock::time_point lastPurchaseTime;
    static const int64_t SHOP_COOLDOWN = 3;
};

class Crosshair {
public:
    static Crosshair& getInstance(){
        static Crosshair instance;
        return instance;
    }
    void DrawCrosshair();
    void HandleRainbow();
    void HandleGameCrosshair();
};

/*
 What Needs to Save:
    Ammount of items in the kit
 
    Kit Item:
     Ammount of Items to spawn,
     Max Ammount of Items,
     Item Spawn String,
     Item display name
 
What to show in ImGui:
    A tab for "Custom Kit"
    10 items display at a time, with next page and previous page with in the middle like (x/x) page
    Each Row should have at the start like the display string, then a +1 +5 -5 -1 Current: Max:
    
    
 When menu is loaded:
    1. call QuickKit initialize
    2. call Quick Kit Load Kit Items
 
 Have a button on the quick kit page Save Changes and Revert (which just calls Load Kit Items)
 
 
 */

class KitItem {
public:
    
    KitItem(std::string inDisplayName, int inCurrentAmmount, int inMaxAmmount, std::string inItemString) : DisplayName(inDisplayName), CurrentAmmount(inCurrentAmmount), MaxAmmount(inMaxAmmount), ItemString(inItemString) {}
    
    int MaxAmmount;
    int CurrentAmmount;
    std::string DisplayName;
    std::string ItemString;
    
    void Spawn();
    void LoadFromDict();
    void SaveToDict();
    void DrawRow();
    
    void Incriment(int howMuch);
};




class QuickKit {
public:
    static QuickKit& getInstance(){
        static QuickKit instance;
        return instance;
    }
    //Initializes the Kit, adds all the items to the vector
    void Initialize();
    
    //Saves the kit
    void SaveKitItems();
    
    // Saved as a dictionary, so to load have the ForKey be the Display Name
    void LoadKitItems();
    
    //Spawns the whole kit into your inventory
    void SpawnKit(bool forceSpawn = false);
    
    //gets the path of the dict file
    NSString* GetSavePath();
    
    //all kit items
    std::vector<KitItem> kit;
    
    int CurrentPage = 1;
    int PagesCount = 0;
    int ItemsPerPage = 9;
    
    
    //for drawing the ImGui Page
    void MenuDrawPage();
    void NextPage();
    void PreviousPage();
    
};


#endif /* Utils_h */

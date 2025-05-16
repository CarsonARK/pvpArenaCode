//
//  AdBot.m
//  ArkAdBotDylib
//
//  Created by Carson Mobile on 7/16/24.
//

#import <Foundation/Foundation.h>
#include "../Includes.h"

#import <objc/runtime.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIInteraction.h>
#import <UIKit/UIPointerRegion.h>
#import <UIKit/UIPointerStyle.h>
#include <algorithm>
#include <PTFakeTouch/PTFakeTouch.h>

//#include <PTFakeTouch/Ui

//Note, must turn on enable game controller input

long long getCurrentTimeMS(){
   return std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::system_clock::now().time_since_epoch()).count();
}

static float clampFloat(float value, float minVal, float maxVal) {
    if (value < minVal) return minVal;
    if (value > maxVal) return maxVal;
    return value;
}

std::vector<std::string>& keyPressesQ(){
    static std::vector<std::string> kpq;
    return kpq;
}

//swizzle function
static void SwizzleMethod(Class myClass, SEL originalSelector, SEL swizzledSelector) {
    Method originalMethod = class_getInstanceMethod(myClass, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(myClass, swizzledSelector);

    BOOL didAddMethod = class_addMethod(myClass,
                                        originalSelector,
                                        method_getImplementation(swizzledMethod),
                                        method_getTypeEncoding(swizzledMethod));

    if (didAddMethod) {
        class_replaceMethod(myClass,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

#import <objc/runtime.h>

/*
@implementation UIPointerLockState (CustomLock)

// New method to replace the original isLocked method
- (BOOL)custom_isLocked {
    // Custom logic to determine the locked state
    // For example, you could always return YES
    return YES;
}

// Method Swizzling
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class cls = [self class];

        SEL originalSelector = @selector(isLocked);
        SEL swizzledSelector = @selector(custom_isLocked);

        Method originalMethod = class_getInstanceMethod(cls, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(cls, swizzledSelector);

        BOOL didAddMethod = class_addMethod(cls,
                                            originalSelector,
                                            method_getImplementation(swizzledMethod),
                                            method_getTypeEncoding(swizzledMethod));

        if (didAddMethod) {
            class_replaceMethod(cls,
                                swizzledSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

@end
*/



// Original implementation placeholder
//static BOOL (*original_didFinishLaunchingWithOptions)(id, SEL, UIApplication *, NSDictionary *);




/**
 Hook UI View Controller method to get an array of all key commands, then  return my custom array of key commands.
 This should allow me to have custom binds for all of the keys.
 */
@implementation UIViewController (hook)

- (BOOL)prefersPointerLocked {
    return Variables.prefersPointerLocked;
    //[self setNeedsUpdateOfPrefersPointerLocked];
    //return YES; // or NO, depending on whether you want to lock the pointer
}
- (void)pressesCancelled:(NSSet<UIPress *> *)presses withEvent:(UIPressesEvent *)event {
    [super pressesCancelled:presses withEvent:event];
}
- (NSArray<UIKeyCommand *> *)keyCommands {
    return @[];
}


+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method originalMethod = class_getInstanceMethod(self, @selector(viewDidLoad));
        Method swizzledMethod = class_getInstanceMethod(self, @selector(swizzled_viewDidLoad));
        
        method_exchangeImplementations(originalMethod, swizzledMethod);
    });
}

- (void)swizzled_viewDidLoad {
    [self swizzled_viewDidLoad];
    [self.view addPointerInteraction];
}
@end







void ShowError(NSString * ErrorMessage){
    timer(0){
        UIAlertController *ServerInfoAlert = [UIAlertController alertControllerWithTitle:ErrorMessage message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *Enter = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        }];
        [ServerInfoAlert addAction:Enter];
        [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:ServerInfoAlert animated:YES completion:nil];
    });
}



bool& KeyboardManager::getKeyDown(UIKeyboardHIDUsage inKey){
    if(keyMap.find(inKey) == keyMap.end()){
        keyMap[inKey] = false;
    }
    return keyMap[inKey];
}


void KeyboardManager::HandleKeyPressed(UIKeyboardHIDUsage inKey){
    getKeyDown(inKey) = true;
}
void KeyboardManager::HandleKeyReleased(UIKeyboardHIDUsage inKey){
    getKeyDown(inKey) = false;
}


/*
//handles the key press
void HandleKey(NSString* key);

//get the key for the given input
key& getKey(std::string keyPress);

//Implimentation every 200 MS, un presses/ unholds keys
void refreshKeys();


std::map<std::string, key> keyMap;
 */

/*
 Attempt to add pointer tracking.
 */

/*
 Actions:
 
 Move Forward
 Move Backwards
 Move Left
 Move Right
 Move Up
 Move Down
 Jump
 Crouch
 Prone
 Shoot / Mele

 Open Inventory
 Whistle Commands
 Send Chat Message
 Run
 Toggle Run
 Reload
 Drag Body
 Use
 
 
 
 Aim-Down Sights/ Alt 1 (if i have a scope weapon,

 Alt 2
 
 */
//MultiTapAction

/*
 
 */

static void WhistleGoTo(){
    
    APlayerCameraManager* CM = QuickOffsets::GetPlayerCameraManager();
    AShooterCharacter* MySC = QuickOffsets::GetShooterCharacter();
    Vector3 Endpoint;
    
    if(!(CM->isA_Safe(StaticClass::PlayerCameraManager())) || !(MySC->isA_Safe(StaticClass::ShooterCharacter())))
        return;
    
    UWorld* World = UWorld::GetWorld();
    Vector3 CameraLoc = CM->GetCameraLocation();
    FRotator Viewpoint = CM->GetAimRotation();
    float MaxDistance = 50000.0f;
    float Precision = 100.0f;
    Vector3 Direction = KismetMathLibrary::GetMathLibrary()->GetForwardVector(Viewpoint);
    float MinDistance = Precision;
    float CurrentDistance = MaxDistance;
    /*
     49000
     bHit = true -> bHit means visible, so increase distance
     */
    bool hitSomething = false;
    while (CurrentDistance - MinDistance > Precision)
    {
        Vector3 EndLocation = CameraLoc + Direction * CurrentDistance;
        bool bHit = QuickOffsets::GetPlayerController()->LineOfSightTo(EndLocation);
        
        //if we hit the land, reduce the distance by half
        if (!bHit)
        {
            hitSomething = true;
            // If we hit something, reduce the distance to search closer
            CurrentDistance = std::max(MinDistance, CurrentDistance / 2);
        }
        else
        {
            // If no hit, increase the distance to search farther
            MinDistance = CurrentDistance;
            CurrentDistance = std::min(MaxDistance, CurrentDistance * 2);
        }
    }
    
    if(hitSomething){
        Endpoint = CameraLoc + Direction * CurrentDistance;
        MySC->ServerCallMoveTo(Endpoint);
    }
    //Endpoint = StartLocation + Direction * MinDistance;
    //return hitSomething;
        
}


static void (*SetRunning)(ACharacter* Pawn, bool Running) = (void(*)(ACharacter* , bool))getOffset(0x7b6aec); //007b6aec
//static void (*MoveRight)(AShooterCharacter* Controller, float val) = (void(*)(AShooterCharacter*,float))getOffset(0xa4ff30);
//static void (*MoveForward)(AShooterCharacter* Controller, float val) = (void(*)(AShooterCharacter*,float))getOffset(0xa4ff84);
static void (*MoveRight)(ACharacter* Controller, float val) = (void(*)(ACharacter*,float))getOffset(0x7b1a08);
static void (*MoveForward)(ACharacter* Controller, float val) = (void(*)(ACharacter*,float))getOffset(0x7b162c);
static void (*MoveUp)(ACharacter* Controller, float val) = (void(*)(ACharacter*,float))getOffset(0x7b1b08);

static void (*Dino_MoveRight)(ACharacter* Controller, float val) = (void(*)(ACharacter*,float))getOffset(0x818e00);
static void (*Dino_MoveForward)(ACharacter* Controller, float val) = (void(*)(ACharacter*,float))getOffset(0x818c84);
static void (*Dino_MoveUp)(ACharacter* Controller, float val) = (void(*)(ACharacter*,float))getOffset(0x818f4c);
//0818e00
//02a9f000
static void (*MobileJump)(APlayerController* Controller, int val) = (void(*)(APlayerController*,int))getOffset(0xb5dfb0);
static void (*HandleCrouchCycle)(AShooterCharacter* Character) = (void(*)(AShooterCharacter*))getOffset(0xa2baa4);
static void (*GrapHookStartSecondaryAction)(AShooterWeapon* Weapon) = (void(*)(AShooterWeapon*))getOffset(0x009e1208);
static void (*GrapHookStopSecondaryAction)(AShooterWeapon* Weapon) = (void(*)(AShooterWeapon*))getOffset(0x9e12e8);
static void (*SetTargetting)(AShooterCharacter* Character, bool targetting) = (void(*)(AShooterCharacter*,bool))getOffset(0xa2a960);

static void (*GrapHookStartFire)(AShooterWeapon* Weapon) = (void(*)(AShooterWeapon*))getOffset(0x9e1068);
static void (*GrapHookStopFire)(AShooterWeapon* Weapon) = (void(*)(AShooterWeapon*))getOffset(0x9e1188);

static void (*StartArkGamepadFaceButtonRight)(APlayerController* ctrl) = (void(*)(APlayerController*))getOffset(0xb42a24);
static void (*EndArkGamepadFaceButtonRight)(APlayerController* ctrl) = (void(*)(APlayerController*))getOffset(0xb42b28);

static void (*EndArkGamepadDpadUp)(APlayerController* ctrl) = (void(*)(APlayerController*))getOffset(0x00b42f54);
static void (*EndArkGamepadDpadDown)(APlayerController* ctrl) = (void(*)(APlayerController*))getOffset(0xb43110);
//00b42f54
static void (*ShowMapMarkers)(APlayerController* ctrl) = (void(*)(APlayerController*))getOffset(0xb45590);

static void (*OnUseRelease)(APlayerController* ctrl, bool bidk, bool bidk2) = (void(*)(APlayerController*, bool, bool))getOffset(0x0b4960c);
static void (*onUsePress)(APlayerController* ctrl, bool bidk, bool bidk2) = (void(*)(APlayerController*, bool, bool))getOffset(0x0b46fa4);
//onUseRelease 0b4960c
//onUsePress 0b46fa4

enum EPlayerActionIndex : uint8_t {
    EPlayerActionIndex_None = 0,
    EPlayerActionIndex_WhistleFollow = 1,
    EPlayerActionIndex_WhistleFollowOne = 2,
    EPlayerActionIndex_WhistleStop = 3,
    EPlayerActionIndex_WhistleStopOne = 4,
    EPlayerActionIndex_WhistleAggressive = 5,
    EPlayerActionIndex_WhistleNeutral = 6,
    EPlayerActionIndex_WhistlePassive = 7,
    EPlayerActionIndex_WhistleAttackTarget = 8,
    EPlayerActionIndex_WhistleSpecialUnbury = 9,
    EPlayerActionIndex_WhistleSpecialTwo = 10,
    EPlayerActionIndex_ShowInventory = 11,
    EPlayerActionIndex_ShowCraftables = 12,
    EPlayerActionIndex_ShowTribeManager = 13,
    EPlayerActionIndex_Poop = 14,
    EPlayerActionIndex_ShowEmoteSelection = 15,
    EPlayerActionIndex_Emote_Salute = 16,
    EPlayerActionIndex_Emote_Sorry = 17,
    EPlayerActionIndex_Emote_Thank = 18,
    EPlayerActionIndex_Emote_Wave = 19,
    EPlayerActionIndex_Emote_Laugh = 20,
    EPlayerActionIndex_Emote_Yes = 21,
    EPlayerActionIndex_Emote_No = 22,
    EPlayerActionIndex_Emote_Taunt = 23,
    EPlayerActionIndex_Emote_Cheer = 24,
    EPlayerActionIndex_Emote_FriendlyLowerHands = 25,
    EPlayerActionIndex_Emote_MAX = 26,
    EPlayerActionIndex_MAX = 27
};
static void (*TriggerPlayerAction)(APlayerController* PC, EPlayerActionIndex idx) = (void(*)(APlayerController*, EPlayerActionIndex))getOffset(0xb5a280);
//EPlayerActionIndex

//TopLeftButtonPressed
//0775ce0
//TopLeftButtonReleased
//775ddc
//b42a24

//0b455c0

//0a2a960
//009e1068 grappling hook start fire
//009e1188 stop fire

//9e1068
enum MultiTapAction : uint8_t {
    MTA_None = 0,
    MTA_Whistle = 1,
    MTA_OrbitCam = 2,
    MTA_ChangeView = 3,
    MTA_JumpOrAltAttack1 = 4,
    MTA_ViewInventory = 5,
    MTA_PickUpCreature = 6,
    MTA_HotBar1 = 7,
    MTA_HotBar2 = 8,
    MTA_HotBar3 = 9,
    MTA_HotBar4 = 10,
    MTA_HotBar5 = 11,
    MTA_HotBar6 = 12,
    MTA_HotBar7 = 13,
    MTA_HotBar8 = 14,
    MTA_HotBar9 = 15,
    MTA_HotBar10 = 16,
    MTA_Poop = 17,
    MTA_ReloadOrAltAttack2 = 18,
    MTA_ZoomCamera = 19,
    MTA_CrouchCycle = 20,
    MTA_CrashOnPurpose = 21,
    MTA_Max = 22
};

static void (*DoMultiTouchAction)(APlayerController* Controller, int Action) = (void(*)(APlayerController*, int))getOffset(0xb5dbd0);
static void (*OnReleaseItemSlot)(APlayerController* Controller, int Slot) = (void(*)(APlayerController*, int))getOffset(0xb4ad04);

static void (*DoNormalAttack)(APlayerController* Controller, int something, int something2) = (void(*)(APlayerController*, int, int))getOffset(0xb621dc);
//b621dc
//DoMultiTouchAction(AShooterPlayerController* controller, int Action);  0b5dbd0

//0b43b74
static void (*StartGamepadRightFire)(APlayerController* ctrl) = (void(*)(APlayerController*))getOffset(0x0b43ab4);
static void (*StopGamepadRightFire)(APlayerController* ctrl) = (void(*)(APlayerController*))getOffset(0x0b43b74);
void KeyboardManager::SetFps(){
    /*
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* EngineDirectory = [[paths objectAtIndex:0] stringByAppendingString:@"/ShooterGame/Saved/Config/IOS/Engine.ini"];
    NSString *EngineContent = [NSString stringWithFormat:@"[/Script/IOSRuntimeSettings.IOSRuntimeSettings]\nFrameRateLock=PUFRL_120\n\n[/script/engine.engine]\nMinDesiredFrameRate=120\nSmoothedFrameRateRange=(LowerBound=(Type=\"ERangeBoundTypes::Inclusive\",Value=120),UpperBound=(Type=\"ERangeBoundTypes::Exclusive\",Value=120))"];
    [EngineContent writeToFile:EngineDirectory atomically:NO  encoding:NSUTF8StringEncoding error:nil];
     */
}

/*
 else {
     //[PTFakeMetaTouch ]
     //[faketouch ]
     NSInteger pointId = [PTFakeMetaTouch fakeTouchId:[PTFakeMetaTouch getAvailablePointId] AtPoint:CGPointMake(Variables.CursorX,Variables.CursorY) withTouchPhase:UITouchPhaseBegan];
     [PTFakeMetaTouch fakeTouchId:pointId AtPoint:CGPointMake(Variables.CursorX,Variables.CursorY) withTouchPhase:UITouchPhaseEnded];
 */

void KeyboardManager::AdjustAimDelta(float DeltaX, float DeltaY){
    if(QuickOffsets::isServerLoaded() && Variables.prefersPointerLocked){
        APlayerController* PlayerController = QuickOffsets::GetPlayerController();
        AShooterCharacter* MySC = QuickOffsets::GetShooterCharacter();
        
        if(!MySC->isA_Safe(StaticClass::ShooterCharacter())) return;
        
        
        FRotator ControlRotation = PlayerController->GetControlRotation();
        
        float MultFactor = 0.1;
        if(MySC->IsTargeting()){
            MultFactor /= 2.5;
        }
        
        
        ControlRotation.Yaw = MultFactor * Variables.HorizontalSens * DeltaX + ControlRotation.Yaw;
        ControlRotation.Pitch =  MultFactor * Variables.VerticalSens * DeltaY + ControlRotation.Pitch;
        
        ControlRotation.Pitch = clampFloat(ControlRotation.Pitch, -90, 90);
        
        PlayerController->SetControlRotation(ControlRotation);
    }
    
    
}
void KeyboardManager::AdjustAim(float ScrollX, float ScrollY){
    if(QuickOffsets::isServerLoaded() && Variables.prefersPointerLocked){
        APlayerController* PlayerController = QuickOffsets::GetPlayerController();
        FRotator ControlRotation = PlayerController->GetControlRotation();
        
        static Vector2 LastAimRotation = Vector2(5000, 5000);;
        
        Vector2 CurrentAimRotation = Vector2(ScrollX, ScrollY);
        
        //so basically if you drag your mouse fast your aim wont move
        //I can probably do something better if i wanted, like once you hit either edge of the screen
        //ur aim freezes until u drag the opposite direction then back
        ControlRotation.Yaw = -1 * Variables.HorizontalSens * (CurrentAimRotation.X - LastAimRotation.X) + ControlRotation.Yaw;
        ControlRotation.Pitch = -1 * Variables.VerticalSens * (LastAimRotation.Y - CurrentAimRotation.Y) + ControlRotation.Pitch;
        
        ControlRotation.Pitch = clampFloat(ControlRotation.Pitch, -90, 90);
        
        //PlayerController->GetControlRotation() = ControlRotation;
        PlayerController->SetControlRotation(ControlRotation);
        //LastAimRotation = CurrentAimRotation;
    }
}


/*
 
 User needs to turn off "Full Keyboard Access" for everything to work
 
 
 enum class MultiTapAction : uint8 {
     MTA_None = 0,
     MTA_Whistle = 1,
     MTA_OrbitCam = 2,
     MTA_ChangeView = 3,
     MTA_JumpOrAltAttack1 = 4,
     MTA_ViewInventory = 5,
     MTA_PickUpCreature = 6,
     MTA_HotBar1 = 7,
     MTA_HotBar2 = 8,
     MTA_HotBar3 = 9,
     MTA_HotBar4 = 10,
     MTA_HotBar5 = 11,
     MTA_HotBar6 = 12,
     MTA_HotBar7 = 13,
     MTA_HotBar8 = 14,
     MTA_HotBar9 = 15,
     MTA_HotBar10 = 16,
     MTA_Poop = 17,
     MTA_ReloadOrAltAttack2 = 18,
     MTA_ZoomCamera = 19,
     MTA_CrouchCycle = 20,
     MTA_CrashOnPurpose = 21,
     MTA_Max = 22
 };
 
 
 need:
 Movement, Access Inventory, Aim Down Sights / Attachment, Toggle Run, Attack, Send Chat Message, drag body, use, individual whistle commands,
 
 
 /*
 Game User Settings.ini:    
 mobileMoveRegionTapAction=18
 mobileLookRegionTapAction=4
 
 MobileSwipeDownOnMoveRegion
 
 void _ZN24AShooterPlayerController18DoMultiTouchActionE11TouchRegion(long *param_1,int param_2)
DoMultiTouchActionE11TouchRegion(long *param_1,int param_2)
 DoMultiTouchAction(AShooterPlayerController* controller, int Action);  0b5dbd0
 
 
 */

/*
 FlipPlacement
 void SnapPointCycle();
 
 OnMobileMultipurposeButton -> maybe just have a keyboard for this
    - Attachment, Reload, Grapple, move snap points, C4 Detonate, Transpoder Detonate
 
 
 **DoNormalAttack** -> StartFire
 DoNormalAttack -> Shoot Button
 
 Right Click -> Detonate, reel grapple, scope,
 
 E -> Gather
 
 M -> void ToggleMap(); or ServerShowMap
 DoNormalAttack
 
 pickup dropped items
 pickup rocks
 ballista
 place structure
 flip placement
 rotate snap point
 door
 elevator
 DoMobileRotationPlacement
 */

/*
 land and attack
 
 // Object Name: Function ShooterGame.PrimalDinoCharacter.ServerInterruptLanding
 // Flags: [Net|NetReliableNative|Event|Public|NetServer]
 void ServerInterruptLanding(); // Offset: 0x100e28c44 // Return & Params: Num(0) Size(0x0)

 // Object Name: Function ShooterGame.PrimalDinoCharacter.ServerFinishedLanding
 // Flags: [Net|NetReliableNative|Event|Public|NetServer]
 void ServerFinishedLanding(); // Offset: 0x100e28c28 // Return & Params: Num(0) Size(0x0)
 
 */


bool KeyboardManager::isKeyDown(UIKeyboardHIDUsage KeyName){
    return getKeyDown(KeyName);
}


void KeyboardManager::UpdateAim(){
    if(QuickOffsets::isServerLoaded()){
        
        
        APlayerController* PlayerController = QuickOffsets::GetPlayerController();
        FRotator ControlRotation = PlayerController->GetControlRotation();
        
        static Vector2 LastAimRotation;
        
        Vector2 CurrentAimRotation = Vector2(Variables.CursorX, Variables.CursorY);
        
        //so basically if you drag your mouse fast your aim wont move
        //I can probably do something better if i wanted, like once you hit either edge of the screen
        //ur aim freezes until u drag the opposite direction then back
        if(abs(CurrentAimRotation.X - LastAimRotation.X) < Variables.MaxSpeed){
            ControlRotation.Yaw = Variables.HorizontalSens * (CurrentAimRotation.X - LastAimRotation.X) + ControlRotation.Yaw;
            ControlRotation.Pitch = Variables.VerticalSens * (LastAimRotation.Y - CurrentAimRotation.Y) + ControlRotation.Pitch;
            
            ControlRotation.Pitch = clampFloat(ControlRotation.Pitch, -90, 90);
            
            //PlayerController->GetControlRotation() = ControlRotation;
            PlayerController->SetControlRotation(ControlRotation);
        }
        LastAimRotation = CurrentAimRotation;
    }
}
//Once i finish Movement, put it here.
void KeyboardManager::UpdateMovement(){
    
}


/*
 // Object Name: Function Engine.Character.Jump
     // Flags: [Native|Public|BlueprintCallable]
     void Jump(); // Offset: 0x102d15470 // Return & Params: Num(0) Size(0x0)
 
 
 EPlayerActionIndex
 EPrimalSubmenuType
 
 */
/*
 E
 Activates the default action of an object, such as opening a door, climbing a ladder, or opening a storage box's inventory.
 
 E
 GetTargettingObject
 
 Ladder:
    if(onLadder -> dismount ladder)
    else MountLadder
 PoweredStructure (gen turret)
    -> turn on / off
 MountedStructure (ballista/rt/whatever)
    -> Mount / Dismount
 Dino
    -> mount
 storage box
    -> open inventory
 Door / Door frame
    -> open / close
 Dropped Item Bag
    -> open
 Amber
    -> pickup
 
 Mounted On Dino -> Dismount
 Mounted on Ballista -> Dismoount
 
 Unconscious Body -> Open Inventory
 

 
 
 I
 1. if any menus open, close them all
 2. Open player inventory to normal page
 
 
 F
 1. Access target inventory
 2. if on dino, access dino inventory
 3. Throw shoulder mount
 
 R
 reload
 if twice, toggle attachment
 
 
 V
 close all things
 show craftables
 */
//GCKeyCode
static void WhistleToggle(bool* Toggle, GCKeyCode Key, std::function<void()> task, std::function<void()> completionTask = [](){}){
    if([[[GCKeyboard coalescedKeyboard] keyboardInput] buttonForKeyCode:Key].isPressed){
        if(*Toggle)
            task();
        *Toggle = false;
    }
    else {
        if(!*Toggle && completionTask)
            completionTask();
            //task();
        *Toggle = true;
        //PC->OnOnScreenButtonReleased(Slot);
    }
}
static void simulateDragFromPoint(CGPoint startPoint, CGPoint endPoint, bool* canExecute) {
    *canExecute = false;
    // Ensure the start and end points are valid.
    if (CGPointEqualToPoint(startPoint, endPoint)) {
        NSLog(@"Start and end points are the same.");
        return;
    }
    
    // Define the number of steps for the drag simulation.
    NSInteger numberOfSteps = 2;
    
    // Calculate the step size in both x and y directions.
    CGFloat xStep = (endPoint.x - startPoint.x) / numberOfSteps;
    CGFloat yStep = (endPoint.y - startPoint.y) / numberOfSteps;
    
    // Simulate the touch start.
    NSInteger touchId = [PTFakeMetaTouch fakeTouchId:0 AtPoint:startPoint withTouchPhase:UITouchPhaseBegan];
    
    // Simulate the touch movement in steps.
    for (NSInteger i = 1; i <= numberOfSteps; i++) {
        CGPoint currentPoint = CGPointMake(startPoint.x + xStep * i, startPoint.y + yStep * i);
        [PTFakeMetaTouch fakeTouchId:touchId AtPoint:currentPoint withTouchPhase:UITouchPhaseMoved];
        [NSThread sleepForTimeInterval:0.00001];
        //usleep(10);
    }
    [PTFakeMetaTouch fakeTouchId:touchId AtPoint:endPoint withTouchPhase:UITouchPhaseEnded];
    //timer(0.05){
        *canExecute = true;
    //});
}

void KeyboardManager::HandleScroll(float x, float y){
    if(y != 0) return;
    if(x == 0) return;
    
    if(Variables.prefersPointerLocked){
        //scroll up
        if(x > 0){
            if(QuickOffsets::GetShooterCharacter()->isA_Safe(StaticClass::ShooterCharacter())){
                QuickOffsets::GetShooterCharacter()->SetCameraMode(true);
            }
        }
        //scroll down
        else if (x < 0){
            if(QuickOffsets::GetShooterCharacter()->isA_Safe(StaticClass::ShooterCharacter())){
                QuickOffsets::GetShooterCharacter()->SetCameraMode(false);
            }
        }
    }
    else {
        //if i allow scroll nonstop, then
        static bool canExecute = true;
        /*
        NSInteger pointId = [PTFakeMetaTouch fakeTouchId:[PTFakeMetaTouch getAvailablePointId] AtPoint:CGPointMake(Variables.CursorX,Variables.CursorY) withTouchPhase:UITouchPhaseBegan];
        [PTFakeMetaTouch fakeTouchId:pointId AtPoint:CGPointMake(Variables.CursorX,Variables.CursorY) withTouchPhase:UITouchPhaseEnded];
         */
        
        if(canExecute){
            Vector2 CursorPos = {Variables.CursorX, Variables.CursorY};
            float DragInterval = 0;
            float ScrollAmmount = 133;
            if(x>0) DragInterval = ScrollAmmount;
            if(x<0) DragInterval = -ScrollAmmount;
            CGPoint StartPoint = CGPointMake(Variables.CursorX, Variables.CursorY);
            CGPoint EndPoint = CGPointMake(Variables.CursorX, Variables.CursorY + DragInterval);
            simulateDragFromPoint(StartPoint, EndPoint, &canExecute);
           // timer(0){
           //     [mainView tapAtPoint:StartPoint];
           //     //[mainView dragFromPoint:StartPoint toPoint:EndPoint];
           // });
            //dragFromPoint
            //[mainView dr]
            //[PTFakeMetaTouch fakeTouchId:0 AtPoint:StartPoint withTouchPhase:UITouchPhaseMoved];
            //[mainView ]
            //[PTFakeMetaTouch ]
           // [mainView dragFromPoint:StartPoint toPoint:EndPoint];
           // [mainView dragfrom]
            //[PTFakeMetaTouch dragFromPoint:StartPoint toPoint:EndPoint view:mainView];
            //[]
            
            
            //simulateDragFromPoint(StartPoint, EndPoint, &canExecute);
            //NSInteger pointId = [PTFakeMetaTouch fakeTouchId:[PTFakeMetaTouch getAvailablePointId] AtPoint:CGPointMake(CursorPos.X,CursorPos.Y) withTouchPhase:UITouchPhaseBegan];
            //for(int i = 0; i<20; ++i){
            //    NSInteger pointId = [PTFakeMetaTouch fakeTouchId:[PTFakeMetaTouch getAvailablePointId] AtPoint:CGPointMake(CursorPos.X,CursorPos.Y) withTouchPhase:UITouchPhaseBegan];
            //    CursorPos.Y+=i;
             //   [PTFakeMetaTouch fakeTouchId:pointId AtPoint:CGPointMake(CursorPos.X,CursorPos.Y) withTouchPhase:UITouchPhaseMoved];
             //   [PTFakeMetaTouch fakeTouchId:pointId AtPoint:CGPointMake(CursorPos.X,CursorPos.Y) withTouchPhase:UITouchPhaseEnded];
            //}
            //timer(0){
            //    NSInteger pointId = [PTFakeMetaTouch fakeTouchId:[PTFakeMetaTouch getAvailablePointId] AtPoint:CGPointMake(CursorPos.X,CursorPos.Y+1) withTouchPhase:UITouchPhaseBegan];
            //    [PTFakeMetaTouch fakeTouchId:pointId AtPoint:CGPointMake(CursorPos.X,CursorPos.Y + 2) withTouchPhase:UITouchPhaseMoved];
            //    [PTFakeMetaTouch fakeTouchId:pointId AtPoint:CGPointMake(CursorPos.X,CursorPos.Y + 3) withTouchPhase:UITouchPhaseEnded];
            //});
            //canExecute = false;
        }
    }
}

/*
 Left Mouse = 0
 Middle Mouse = 2
 Right Mouse = 1
 
 if(keyMap.find(inKey) == keyMap.end()){
     keyMap[inKey] = false;
 }
 return keyMap[inKey];
}


void KeyboardManager::HandleKeyPressed(UIKeyboardHIDUsage inKey){
 getKeyDown(inKey) = true;
}
void KeyboardManager::HandleKeyReleased(UIKeyboardHIDUsage inKey){
 getKeyDown(inKey) = false;
}
 
 */


bool KeyboardManager::isMouseDown(int mouseInt){
    if(mouseMap.find(mouseInt) == mouseMap.end()){
        mouseMap[mouseInt] = false;
    }
    return mouseMap[mouseInt];
}
void KeyboardManager::HandleMouseButton(int button, bool pressed){
    if(mouseMap.find(button) == mouseMap.end()){
        mouseMap[button] = pressed;
    }
    mouseMap[button] = pressed;
}

void KeyboardManager::UpdateGame(){
    if(!QuickOffsets::isServerLoaded()){
        return;
    }
    
    if(Variables.prefersPointerLocked){
        if(QuickOffsets::isRidingDino()){
            UpdateDinoMovement();
            UpdateDinoActions();
        }
        else {
            UpdatePlayerActions();
            UpdateCharacterMovement();
        }
        UpdateMiscActions();
    }
    
    //Inventory Actions
    else {
        UpdateInventoryActions();
    }
    //UpdateAim();
    //UpdateKeys();
}


//W, A, S, D, Left Shift, Right Shift, Space, X, C
void KeyboardManager::UpdateCharacterMovement(){
    
    if(![GCKeyboard coalescedKeyboard]) return;
    if(![[GCKeyboard coalescedKeyboard] keyboardInput]) return;
    ACharacter* MyCharacter = QuickOffsets::GetMyCharacter();
    AShooterCharacter* MySC = QuickOffsets::GetShooterCharacter();
    APlayerController* PC = QuickOffsets::GetPlayerController();
    
    if(!MyCharacter->isA_Safe(StaticClass::Character()) || !(MySC->isA_Safe(StaticClass::ShooterCharacter())) || !(PC->isA_Safe(StaticClass::PlayerController()))){
        return;
    }

    Vector2 MovementDirection;
    if(KeybindManager::getInstance().isDefaultKeyPressed(GCKeyCodeKeyW)){
        MovementDirection.X += 1;
    }
    if(KeybindManager::getInstance().isDefaultKeyPressed(GCKeyCodeKeyA)){
        MovementDirection.Y -= 1;
    }
    if(KeybindManager::getInstance().isDefaultKeyPressed(GCKeyCodeKeyS)){
        MovementDirection.X -= 1;
    }
    if(KeybindManager::getInstance().isDefaultKeyPressed(GCKeyCodeKeyD)){
        MovementDirection.Y += 1;
    }
    /*
    if([[[GCKeyboard coalescedKeyboard] keyboardInput] buttonForKeyCode:GCKeyCodeKeyW].isPressed){
        MovementDirection.X += 1;
    }
    if([[[GCKeyboard coalescedKeyboard] keyboardInput] buttonForKeyCode:GCKeyCodeKeyA].isPressed){
        MovementDirection.Y -= 1;
    }
    if([[[GCKeyboard coalescedKeyboard] keyboardInput] buttonForKeyCode:GCKeyCodeKeyS].isPressed){
        MovementDirection.X -= 1;
    }
    if([[[GCKeyboard coalescedKeyboard] keyboardInput] buttonForKeyCode:GCKeyCodeKeyD].isPressed){
        MovementDirection.Y += 1;
    }
     */
    //[[[GCKeyboard coalescedKeyboard] keyboardInput] buttonForKeyCode:GCKeyCodeKeyA].isPressed;
    /*
    if(isKeyDown(UIKeyboardHIDUsageKeyboardW)){
        MovementDirection.X += 1;
    }
    if(isKeyDown(UIKeyboardHIDUsageKeyboardA)){
        MovementDirection.Y -= 1;
    }
    if(isKeyDown(UIKeyboardHIDUsageKeyboardS)){
        MovementDirection.X -= 1;
    }
    if(isKeyDown(UIKeyboardHIDUsageKeyboardD)){
        MovementDirection.Y += 1;
    }
     */
    
    if(MyCharacter->isA_Safe(StaticClass::ShooterCharacter())){
        //setting these allows the player to make diagonal movements
        Write<uint8_t>(MyCharacter->ObjectPointer() + 0x615, 0);
        Write<uint8_t>(PC->ObjectPointer() + 0xc30, 0);
        
        MoveRight(MyCharacter, MovementDirection.Y);
        MoveForward(MyCharacter, MovementDirection.X);
        
        //If my character is flying or underwater, move up
        if([[[GCKeyboard coalescedKeyboard] keyboardInput] buttonForKeyCode:GCKeyCodeSpacebar].isPressed)
            MoveUp(MyCharacter, 1);
        
        if([[[GCKeyboard coalescedKeyboard] keyboardInput] buttonForKeyCode:GCKeyCodeKeyC].isPressed || [[[GCKeyboard coalescedKeyboard] keyboardInput] buttonForKeyCode:GCKeyCodeKeyX].isPressed)
            MoveUp(MyCharacter, -1);
        
        Write<uint8_t>(MyCharacter->ObjectPointer() + 0x615, 1);
    }
    
    //AutoSprint -> when the user presses Right Shift, it toggles autosprint on or off
    static bool AutosprintSwitch = true;
    if([[[GCKeyboard coalescedKeyboard] keyboardInput] buttonForKeyCode:GCKeyCodeRightShift].isPressed){
        if(AutosprintSwitch)
            Variables.AutoSprint = !Variables.AutoSprint;
        AutosprintSwitch = false;
    }
    else
        AutosprintSwitch = true;
    
    //Manual Sprint
    static bool runningSwitch = false;
    if([[[GCKeyboard coalescedKeyboard] keyboardInput] buttonForKeyCode:GCKeyCodeLeftShift].isPressed || Variables.AutoSprint){
        SetRunning(MyCharacter, true);
        runningSwitch = true;
    } else if(runningSwitch) {
        runningSwitch = false;
        SetRunning(MyCharacter, false);
    }
    
    static bool SpaceSwitch = true;
    if([[[GCKeyboard coalescedKeyboard] keyboardInput] buttonForKeyCode:GCKeyCodeSpacebar].isPressed&& MyCharacter->isA_Safe(StaticClass::Character())){
        static long long LastUncrouchedTime = getCurrentTimeMS();
        
        if(MyCharacter->bIsCrouched()){
            MyCharacter->UnCrouch(true);
            LastUncrouchedTime = getCurrentTimeMS();
        }
        
        if(MyCharacter->bIsProne()){
            MyCharacter->UnProne(true);
            LastUncrouchedTime = getCurrentTimeMS();
        }

        if(getCurrentTimeMS() - LastUncrouchedTime > 200)
            MyCharacter->Jump();
    }
    else {
        SpaceSwitch = true;
    }
    
    //Crouch
    static bool CrouchSwitch = true;
    if([[[GCKeyboard coalescedKeyboard] keyboardInput] buttonForKeyCode:GCKeyCodeKeyC].isPressed){
        if(CrouchSwitch){
            
            if(MyCharacter->bIsCrouched()){
                MyCharacter->UnCrouch(true);
            } else {
                
                //unprone, then crouch
                if(MyCharacter->bIsProne()){
                    MyCharacter->UnProne(true);
                }
                
                MySC->ServerDetachGrapHookCable(0,0);
                MyCharacter->Crouch(true);
            }
            CrouchSwitch = false;
        }
    }
    else
        CrouchSwitch = true;
    
    static bool ProneSwitch = true;
    if([[[GCKeyboard coalescedKeyboard] keyboardInput] buttonForKeyCode:GCKeyCodeKeyX].isPressed){
        if(ProneSwitch){
            if(MyCharacter->bIsProne()){
                MyCharacter->UnProne(true);
            } else {
                
                //uncrouch, then prone
                if(MyCharacter->bIsCrouched()){
                    MyCharacter->UnCrouch(true);
                }
                
                MyCharacter->Prone(true);
            }
            ProneSwitch = false;
        }
    }
    else
        ProneSwitch = true;
}
//W, A, S, D, Left Shift, Right Shift, Space, X, C, Right Click
void KeyboardManager::UpdateDinoMovement(){
    if(![GCKeyboard coalescedKeyboard]) return;
    if(![[GCKeyboard coalescedKeyboard] keyboardInput]) return;
    
    APrimalDinoCharacter* Dino = QuickOffsets::GetMountedDino();
    APlayerController* PC = QuickOffsets::GetPlayerController();
    
    
    if(!(Dino->isA_Safe(StaticClass::PrimalDinoCharacter())) || !(PC->isA_Safe(StaticClass::PlayerController()))){
        return;
    }

    Vector2 MovementDirection;
    if([[[GCKeyboard coalescedKeyboard] keyboardInput] buttonForKeyCode:GCKeyCodeKeyW].isPressed){
        MovementDirection.X += 1;
    }
    if([[[GCKeyboard coalescedKeyboard] keyboardInput] buttonForKeyCode:GCKeyCodeKeyA].isPressed){
        MovementDirection.Y -= 1;
    }
    if([[[GCKeyboard coalescedKeyboard] keyboardInput] buttonForKeyCode:GCKeyCodeKeyS].isPressed){
        MovementDirection.X -= 1;
    }
    if([[[GCKeyboard coalescedKeyboard] keyboardInput] buttonForKeyCode:GCKeyCodeKeyD].isPressed){
        MovementDirection.Y += 1;
    }
    
    static bool movementAlternate = false;
    movementAlternate = !movementAlternate;
    if(Dino->isA_Safe(StaticClass::PrimalDinoCharacter())){
        
        Write<uint8_t>(Dino->ObjectPointer() + 0x615, 0);
        Write<uint8_t>(PC->ObjectPointer() + 0xc30, 0);
        
        Dino_MoveRight(Dino, MovementDirection.Y);
        Dino_MoveForward(Dino, MovementDirection.X);
        
    
        if([[[GCKeyboard coalescedKeyboard] keyboardInput] buttonForKeyCode:GCKeyCodeSpacebar].isPressed){
            Dino_MoveUp(Dino, 1);
        }
        if([[[GCKeyboard coalescedKeyboard] keyboardInput] buttonForKeyCode:GCKeyCodeKeyC].isPressed || [[[GCKeyboard coalescedKeyboard] keyboardInput] buttonForKeyCode:GCKeyCodeKeyX].isPressed){
            Dino_MoveUp(Dino, -1);
        }
        Write<uint8_t>(Dino->ObjectPointer() + 0x615, 1);
    }
    
    static bool AutosprintSwitch = true;
    if([[[GCKeyboard coalescedKeyboard] keyboardInput] buttonForKeyCode:GCKeyCodeRightShift].isPressed){
        if(AutosprintSwitch){
            AutosprintSwitch = false;
            Variables.AutoSprint = !Variables.AutoSprint;
        }
    }
    else {
        AutosprintSwitch = true;
    }
    
    /*
     Manual Sprint
     */
    static bool runningSwitch = false;
    if([[[GCKeyboard coalescedKeyboard] keyboardInput] buttonForKeyCode:GCKeyCodeLeftShift].isPressed|| Variables.AutoSprint){
        SetRunning(Dino, true);
        runningSwitch = true;
    } else if(runningSwitch) {
        runningSwitch = false;
        SetRunning(Dino, false);
    }
    
    
    /*
     Jump, Move Up, Launch
     */
    static bool SpaceSwitch = true;
    if([[[GCKeyboard coalescedKeyboard] keyboardInput] buttonForKeyCode:GCKeyCodeSpacebar].isPressed){
        if(Dino->isA_Safe(StaticClass::Character())){
            
            bool canJump = true;
            if(Dino->CanFly() || Dino->bIsFlying()){
                canJump = false;
                if(SpaceSwitch){
                    Dino->ServerRequestToggleFlight();
                    SpaceSwitch = false;
                }
            }
            

            if(canJump)
                Dino->Jump();
        }
    }
    else {
        SpaceSwitch = true;
    }
    
    if([[[GCKeyboard coalescedKeyboard] keyboardInput] buttonForKeyCode:GCKeyCodeKeyX].isPressed){
        APrimalDinoCharacter* Dino = QuickOffsets::GetMountedDino();
        if(Dino->isA_Safe(StaticClass::PrimalDinoCharacter())){
            Dino->ServerRequestBraking(true);
        }
    }
    
    static bool CSwitch = true;
    if([[[GCKeyboard coalescedKeyboard] keyboardInput] buttonForKeyCode:GCKeyCodeKeyC].isPressed){
        if(CSwitch)
            Dino->ServerRequestAttack(2);
        CSwitch = false;
    } else
        CSwitch = true;
    
    
    if(isMouseDown(1)){
        APrimalDinoCharacter* Dino = QuickOffsets::GetMountedDino();
        if(Dino->isA_Safe(StaticClass::PrimalDinoCharacter())){
            Dino->ServerRequestAttack(1);
        }
    }
}
void KeyboardManager::UpdateDinoActions(){
    if(![GCKeyboard coalescedKeyboard]) return;
    if(![[GCKeyboard coalescedKeyboard] keyboardInput]) return;
    
    AShooterCharacter* MySC = QuickOffsets::GetShooterCharacter();
    APlayerController* PC = QuickOffsets::GetPlayerController();
    APrimalDinoCharacter* Dino = QuickOffsets::GetMountedDino();
    if(!MySC->isA_Safe(StaticClass::ShooterCharacter())) return;
    
    
    static bool FToggle, RToggle;
    WhistleToggle(&FToggle, GCKeyCodeKeyF,[PC, Dino](){
         if(Dino->isA_Safe(StaticClass::Actor())){
             UPrimalInventoryComponent* inventory = nullptr;
             if(Dino->isA_Safe(StaticClass::PrimalDinoCharacter())){
                 inventory = Dino->GetMyInventoryComponent();
             }
             
             if(inventory->isA_Safe(StaticClass::PrimalInventoryComponent())){
                 AShooterHUD* HUD = (AShooterHUD*)QuickOffsets::GetHUD();
                 if(HUD->isA_Safe(StaticClass::ShooterHUD())){
                     HUD->ShowInventory(inventory, 0, 0);
                 }
             }
             
             
         }
    });
    WhistleToggle(&RToggle, GCKeyCodeKeyR,[PC](){
        DoMultiTouchAction(PC, MTA_PickUpCreature);
    });
    
    //static void (*DoMultiTouchAction)(APlayerController* Controller, int Action) = (void(*)(APlayerController*, int))getOffset(0xb5dbd0);

}

//Weapon, E, F, left / right click, reload, accessory, q, g
void KeyboardManager::UpdatePlayerActions(){
    if(![GCKeyboard coalescedKeyboard]) return;
    if(![[GCKeyboard coalescedKeyboard] keyboardInput]) return;
    
    AShooterCharacter* MySC = QuickOffsets::GetShooterCharacter();
    APlayerController* PC = QuickOffsets::GetPlayerController();
    
    if(!MySC->isA_Safe(StaticClass::ShooterCharacter())) return;
    
    AShooterWeapon* MyWeapon = MySC->GetShooterWeapon();
    if(MyWeapon->isA_Safe(StaticClass::ShooterWeapon())){
        static bool Reeling = false;
        static bool Targetting = false;
        
        //Handle Right Click.
        if(isMouseDown(1)){
            if(MyWeapon->isA_Safe(StaticClass::ShooterWeapon_Placer())){
                MyWeapon->ServerDetonateExplosives();
            }
            else if(MyWeapon->isA_Safe(StaticClass::ShooterWeapon_Instant()) || MyWeapon->isA_Safe(StaticClass::ShooterWeapon_Projectile())){
                if(MyWeapon->GetObjectName() == "WeapCrossbow_GrapplingHook_C"){
                    //Grappled
                    if(Read<long>(MySC->ObjectPointer() + 0x1650) != 0){
                        GrapHookStartSecondaryAction(MyWeapon);
                        Reeling = true;
                    }
                    else {
                        SetTargetting(MySC, !MySC->IsTargeting());
                    }
                }
                else {
                    if(!Targetting){
                        SetTargetting(MySC, !MySC->IsTargeting());
                        Targetting = true;
                    }
                }
            }
        }
        else {
            if(MyWeapon->GetObjectName() == "WeapCrossbow_GrapplingHook_C"){
                if(Reeling){
                    GrapHookStopSecondaryAction(MyWeapon);
                    Reeling = false;
                }
            }
            
            if(Targetting){
                Targetting = false;
            }
        }
    }
    
    
    //Reload
    //Toggle Attachment
    //Reload
    
    /*
     CONTROLS:

     Multipurpose:
         1: Left Arrow
         2: Up Arrow
         3: Right arrow
         4: Down Arrow
        Dpad Up: [
        Dpad Down: ]
        
     Inventory:
        Close Inventory: esc
        Equip Item to Hotbar Slot: SHIFT + (0-9)
        Remove Item From Hotbar: CONTROL + (0-9)
        Drop Item: o
        Equip Item: e
        Transfer Stack: T
        Transfer One: CTRL + T
        Transfer Half: Shift + T
        Transfer All: OPTION + T
     
     DINO:
        Move: W A S D
        Mount/Dismount: E
        Open Inventory: F
        Airbrake: X
        Alt 1: Right Click
        Alt 2: C
     
     Hotbar:
        1-9
     
     Player:
     
     Move: W,A,S,D
     Move Up (flying): Spacebar
     Jump: Spacebar
     Move Down(Flying/Swimming): C, X
     Open Inventory: I
     Open Target Inventory: F
     Crouch: C
     Prone: X
     Sprint: L/R shift
     Open Map: M
     Reload: R
     Toggle Accesory: Rx2 , N
     
     
     Structure:
        Rotate Snap Point: Q
        Flip: E
     
     Whistle Commands:
        Whistle Selector: '
        Follow All: J
        Follow One: t
        Stop All: U
        Stop One: V
        Aggressive: \
        AttackTarget: .
        Neutral: -
        Passive: ;
        Moveto: ,
     
     */

    
    if(MyWeapon->isA_Safe(StaticClass::ShooterWeapon()))
    {
        static long long ReloadTimer = 0;
        static bool ReloadSwitch = true;
        if([[[GCKeyboard coalescedKeyboard] keyboardInput] buttonForKeyCode:GCKeyCodeKeyR].isPressed){
            if(ReloadSwitch && getCurrentTimeMS() - ReloadTimer < 400){
                MyWeapon->ServerToggleAccessory();
                ReloadTimer = 0;
            }
            else if(ReloadSwitch)
                MyWeapon->ServerStartReload();
            ReloadSwitch = false;
        }
        else {
            if(!ReloadSwitch){
                ReloadTimer = getCurrentTimeMS();
            }
            ReloadSwitch = true;
        }
        
        
        //N is the accessory button
        static bool AttachmentSwitch = true;
        if([[[GCKeyboard coalescedKeyboard] keyboardInput] buttonForKeyCode:GCKeyCodeKeyN].isPressed){
            if(AttachmentSwitch)
                MyWeapon->ServerToggleAccessory();
            AttachmentSwitch = false;
        }
        else {
            AttachmentSwitch = true;
        }
    }
    
    AActor* TargettedActor = nullptr;
    UObject* TargettingObject = Read<UObject*>(PC->ObjectPointer() + 0xc48);
    if(TargettingObject->isA_Safe(StaticClass::TargetingObject())){
        TargettedActor = ReadWeakPointer<AActor*>(TargettingObject->ObjectPointer() + 0xf0);
    }
    
    /*
     F to open inventory
     */
    
    
    static bool FToggle;
    WhistleToggle(&FToggle, GCKeyCodeKeyF,[PC, TargettedActor](){
         if(TargettedActor->isA_Safe(StaticClass::Actor())){
             UPrimalInventoryComponent* inventory = nullptr;
             if(TargettedActor->isA_Safe(StaticClass::ShooterCharacter())){
                 inventory = ((AShooterCharacter*)TargettedActor)->GetMyInventoryComponent();
             } else if(TargettedActor->isA_Safe(StaticClass::PrimalStructureItemContainer())){
                 inventory = ((APrimalStructure*)TargettedActor)->GetMyInventoryComponent();
                 //GetMyInventoryComponent
             } else if(TargettedActor->isA_Safe(StaticClass::PrimalDinoCharacter())){
                 inventory = ((APrimalDinoCharacter*)TargettedActor)->GetMyInventoryComponent();
             }
             
             if(inventory->isA_Safe(StaticClass::PrimalInventoryComponent())){
                 AShooterHUD* HUD = (AShooterHUD*)QuickOffsets::GetHUD();
                 if(HUD->isA_Safe(StaticClass::ShooterHUD())){
                     HUD->ShowInventory(inventory, 0, 0);
                 }
             }
             
             
         }
         //Target
         //TriggerPlayerAction(PC, EPlayerActionIndex_ShowInventory);
     });
     
        /*
         
         
      F:
      structure (container):
      struct APrimalStructureItemContainer : APrimalStructure {
          // Fields
          struct UPrimalInventoryComponent* MyInventoryComponent; // Offset: 0xbe8 // Size: 0x08
      dino:
      
      player:
      
      
      KeyboardF
      struct UUI_Inventory* ShowInventory(struct UPrimalInventoryComponent* inventoryComp, int specificPage, int hitBodyIndex); // Offset: 0x10109d4d4 // Return & Params: Num(4) Size(0x18)

      
      
      ShowInventory = 11,
      ShowCraftables = 12,
      ShowTribeManager = 13,
      */
     
    /*
    if(isKeyDown(UIKeyboardHIDUsageKeyboardF)){
        
    }
     */
    /*
     TLB_Left = 0,
     TLB_Middle = 1,
     TLB_Right = 2,
     TLB_Extra = 3,
     TLB_Num = 4
     */
    
    /*
     Extra Actions like Demolish, show UI Panel, etc
     */
}

/*
 static bool Switch0 = true;
 if(isKeyDown(UIKeyboardHIDUsageKeyboard0)){
     if(Switch0)
         PC->OnOnScreenButtonClicked(0);
     Switch0 = false;
 }
 else {
     Switch0 = true;
     PC->OnOnScreenButtonReleased(0);
 }
 */
static void ManageHotbar(bool* bSwitch, GCKeyCode key, int Slot, APlayerController* PC){
    
    //GCKeyCode
    if([[[GCKeyboard coalescedKeyboard] keyboardInput] buttonForKeyCode:key].isPressed){
        if(*bSwitch)
            PC->OnOnScreenButtonClicked(Slot);
        *bSwitch = false;
    }
    else {
        *bSwitch = true;
        PC->OnOnScreenButtonReleased(Slot);
    }
}



//Hotbar 1-10, Whistle, Open / Close Inventory / craftables / map, Show Tribe Manager, Mouse Actions
void KeyboardManager::UpdateMiscActions(){
    if(![GCKeyboard coalescedKeyboard]) return;
    if(![[GCKeyboard coalescedKeyboard] keyboardInput]) return;
    
    ACharacter* MyCharacter = QuickOffsets::GetMyCharacter();
    AShooterCharacter* MySC = QuickOffsets::GetShooterCharacter();
    APlayerController* PC = QuickOffsets::GetPlayerController();
    APrimalDinoCharacter* Dino = QuickOffsets::GetMountedDino();
    
    if(!MyCharacter->isA_Safe(StaticClass::PrimalCharacter())) return;
    if(!MySC->isA_Safe(StaticClass::ShooterCharacter())) return;
    if(!PC->isA_Safe(StaticClass::PlayerController())) return;
    
    if(PC->IsValid()){
        static bool Hotbar0, Hotbar1, Hotbar2, Hotbar3, Hotbar4, Hotbar5, Hotbar6, Hotbar7, Hotbar8, Hotbar9;
        ManageHotbar(&Hotbar0, GCKeyCodeZero, 0, PC);
        ManageHotbar(&Hotbar1, GCKeyCodeOne, 1, PC);
        ManageHotbar(&Hotbar2, GCKeyCodeTwo, 2, PC);
        ManageHotbar(&Hotbar3, GCKeyCodeThree, 3, PC);
        ManageHotbar(&Hotbar4, GCKeyCodeFour, 4, PC);
        ManageHotbar(&Hotbar5, GCKeyCodeFive, 5, PC);
        ManageHotbar(&Hotbar6, GCKeyCodeSix, 6, PC);
        ManageHotbar(&Hotbar7, GCKeyCodeSeven, 7, PC);
        ManageHotbar(&Hotbar8, GCKeyCodeEight, 8, PC);
        ManageHotbar(&Hotbar9, GCKeyCodeNine, 9, PC);
    }
    
    UPlayerHUDUI* myHUD = QuickOffsets::GetPlayerHUDUI();
    if(myHUD->isA_Safe(StaticClass::PlayerHUDUI())){
        static bool mapSwitch = true;
        if([[[GCKeyboard coalescedKeyboard] keyboardInput] buttonForKeyCode:GCKeyCodeKeyM].isPressed){
            if(mapSwitch)
                myHUD->ToggleMap();
            mapSwitch = false;
        }
        else {
            if(!mapSwitch)
                MySC->ServerGiveFists();
            mapSwitch = true;
        }
    }
    
    static bool Markers = true;
    if([[[GCKeyboard coalescedKeyboard] keyboardInput] buttonForKeyCode:GCKeyCodeKeyP].isPressed){
        if(Markers)
            ShowMapMarkers(PC);
        Markers = false;
    } else
        Markers = true;
    /*
     ShowMapMarkers
     */
    UPlayerHUDUI* myHUDUI = QuickOffsets::GetPlayerHUDUI();
    if(myHUDUI->isA_Safe(StaticClass::PlayerHUDUI())){
        static bool pressed = false;
        if(isMouseDown(0)){
            if(!pressed)
                StartGamepadRightFire(PC);
            
            pressed = true;
        }
        else {
            if(pressed)
                StopGamepadRightFire(PC);
            pressed = false;
        }
    }
    
    
    //use [ and ] for dpad up and dpad down
    static bool DpadUp, DpadDown;
    if([[[GCKeyboard coalescedKeyboard] keyboardInput] buttonForKeyCode:GCKeyCodeOpenBracket].isPressed){
        DpadUp = true;
    } else {
        if(DpadUp)
            EndArkGamepadDpadUp(PC);
        DpadUp = false;
    }
    //]
    if([[[GCKeyboard coalescedKeyboard] keyboardInput] buttonForKeyCode:GCKeyCodeCloseBracket].isPressed){
        DpadDown = true;
    } else {
        if(DpadDown)
            EndArkGamepadDpadDown(PC);
        DpadDown = false;
    }
    
    //do the x,y,b,a actions
    static bool UpArr, DownArr, LeftArr, RightArr;
    UPlayerHUDUI* HudUI = QuickOffsets::GetPlayerHUDUI();
    if(HudUI->isA_Safe(StaticClass::PlayerHUDUI())){
        if([[[GCKeyboard coalescedKeyboard] keyboardInput] buttonForKeyCode:GCKeyCodeUpArrow].isPressed){
            if(!UpArr)
                HudUI->TopLeftButtonPressed(TLB_Middle);
            UpArr = true;
        } else {
            if(UpArr){
                HudUI->TopLeftButtonClicked(TLB_Middle);
                HudUI->TopLeftButtonReleased(TLB_Middle);
            }
            UpArr = false;
        }
        
        if([[[GCKeyboard coalescedKeyboard] keyboardInput] buttonForKeyCode:GCKeyCodeDownArrow].isPressed){
            if(!DownArr)
                HudUI->TopLeftButtonPressed(TLB_Extra);
            DownArr = true;
        } else {
            if(DownArr){
                HudUI->TopLeftButtonClicked(TLB_Extra);
                HudUI->TopLeftButtonReleased(TLB_Extra);
            }
            DownArr = false;
        }
        if([[[GCKeyboard coalescedKeyboard] keyboardInput] buttonForKeyCode:GCKeyCodeLeftArrow].isPressed){
            if(!LeftArr)
                HudUI->TopLeftButtonPressed(TLB_Left);
            LeftArr = true;
        } else {
            if(LeftArr){
                HudUI->TopLeftButtonClicked(TLB_Left);
                HudUI->TopLeftButtonReleased(TLB_Left);
            }
            LeftArr = false;
        }
        if([[[GCKeyboard coalescedKeyboard] keyboardInput] buttonForKeyCode:GCKeyCodeRightArrow].isPressed){
            if(!RightArr)
                HudUI->TopLeftButtonPressed(TLB_Right);
            RightArr = true;
        } else {
            if(RightArr){
                HudUI->TopLeftButtonClicked(TLB_Right);
                HudUI->TopLeftButtonReleased(TLB_Right);
            }
            RightArr = false;
        }
    }
    
    

    
    /*
     Whistle Commands
     */
    /*
     Whistle Menu '
     Follow All J
     Follow One T
     Stop All U
     Stop One V
     Agressive: \
     Attack Target: .
     Neutral: -
     Passive: ;
     Moveto: ,
     
     */
    static bool FollowToggle, WhisleMenuToggle, FollowOneToggle, StopAllToggle, StopOneToggle, AgressiveToggle, AttackTargetToggle, NeutralToggle, PassiveToggle, MoveToToggle;
    
    //FunctionQueue::GetI().AddTask([](){
    if(MySC->isA_Safe(StaticClass::ShooterCharacter()) && HudUI->isA_Safe(StaticClass::PlayerHUDUI())){
        WhistleToggle(&FollowToggle, GCKeyCodeKeyJ,[PC](){
            TriggerPlayerAction(PC, EPlayerActionIndex_WhistleFollow);
        });
        WhistleToggle(&WhisleMenuToggle, GCKeyCodeQuote,[HudUI](){
            HudUI->EnableMenu(Type_Whistle, true, nullptr, true);
        });
        WhistleToggle(&FollowOneToggle, GCKeyCodeKeyT,[PC](){
            TriggerPlayerAction(PC, EPlayerActionIndex_WhistleFollowOne);
        });
        WhistleToggle(&StopAllToggle, GCKeyCodeKeyU,[PC](){
            TriggerPlayerAction(PC, EPlayerActionIndex_WhistleStop );
        });
        WhistleToggle(&StopOneToggle, GCKeyCodeKeyV,[PC](){
            TriggerPlayerAction(PC, EPlayerActionIndex_WhistleStopOne);
        });
        WhistleToggle(&AgressiveToggle, GCKeyCodeBackslash,[MySC](){
            MySC->ServerCallSetAggressive();
            //TriggerPlayerAction(PC, EPlayerActionIndex_WhistleAggressive);
        });
        WhistleToggle(&AttackTargetToggle, GCKeyCodePeriod,[PC](){
            TriggerPlayerAction(PC, EPlayerActionIndex_WhistleAttackTarget );
        });
        WhistleToggle(&NeutralToggle, GCKeyCodeHyphen,[PC](){
            TriggerPlayerAction(PC, EPlayerActionIndex_WhistleFollow);
        });
        WhistleToggle(&PassiveToggle, GCKeyCodeSemicolon,[PC](){
            TriggerPlayerAction(PC, EPlayerActionIndex_WhistlePassive );
        });
        WhistleToggle(&MoveToToggle, GCKeyCodeComma,[PC](){
            WhistleGoTo();
        });
        
        static bool EToggle;
        WhistleToggle(&EToggle, GCKeyCodeKeyE,[PC](){
            onUsePress(PC, 1, 0);
        },
        [PC](){
            OnUseRelease(PC, 1, 1);
        });
        
        static bool InventoryToggle, CraftablesToggle, TribeManagerToggle, OpenTargetToggle;
        
        WhistleToggle(&InventoryToggle, GCKeyCodeKeyI,[PC](){
            //Disable All Menus
            TriggerPlayerAction(PC, EPlayerActionIndex_ShowInventory);
        });
        
        //this doesnt work.
        WhistleToggle(&CraftablesToggle, GCKeyCodeKeyV,[PC](){
            TriggerPlayerAction(PC, EPlayerActionIndex_ShowCraftables);
        });
        WhistleToggle(&TribeManagerToggle, GCKeyCodeKeyK,[PC](){
            TriggerPlayerAction(PC, EPlayerActionIndex_ShowTribeManager);
        });
    }
    
    UObject* Placer = Read<UObject*>(QuickOffsets::GetPlayerController()->ObjectPointer() + 0xc50);
    if(Placer->isA_Safe(StaticClass::PrimalStructurePlacer())){
        static bool CycleSwitch;
        WhistleToggle(&CycleSwitch, GCKeyCodeKeyQ,[MySC](){
            MySC->SnapPointCycle();
        });
    }
}






/*
 static void InternalReviveDinosaur(){
     UObject* ShooterCharacter = gameUtils.GetMyShooterCharacter();
     if(utils.isValidAdress(ShooterCharacter)){
         UObject* ShooterHUD = gameUtils.GetShooterHUD();
         UObject* CurrentOpenedInventory = utils.Read<UObject*>(ShooterHUD + 0xf38);
         
         
         UObject* Something = utils.Read<UObject*>(CurrentOpenedInventory + 0xc80);
         UObject* SomethingTwo = utils.Read<UObject*>(CurrentOpenedInventory + 0xc70);
         UObject* Selected = 0;

         if(utils.isValidAdress(Something)){
             Selected = InternalGameFunctions::GetSelectedDataObject(Something);
         }
         if(!utils.isValidAdress(Selected) && utils.isValidAdress(SomethingTwo)){
             Selected = InternalGameFunctions::GetSelectedDataObject(SomethingTwo);
         }
         
         if(!utils.isValidAdress(Selected)) return;
         
         int DinoID = utils.Read<int>(Selected + 0xae0);
         functions.ProcessEventCall(ShooterCharacter, L"ServerResurrectDino", &DinoID);
     }
 }
 
 UUIInventory:
    bool bIsRemoteInventory; // Offset: 0xc18 // Size: 0x01
 */
//006ed0e0

static UPrimalItem* (*GetSelectedDataObject)(UObject* UDataListPanel) = (UPrimalItem*(*)(UObject*))getOffset(0x006ed0e0);
//if in inventory
void KeyboardManager::UpdateMenuActions(){
    if(![GCKeyboard coalescedKeyboard]) return;
    if(![[GCKeyboard coalescedKeyboard] keyboardInput]) return;
    
    UObject* OpenedMenu = nullptr;
    if(QuickOffsets::isServerLoaded()){
        UPlayerHUDUI* HudUI = QuickOffsets::GetPlayerHUDUI();
        if(HudUI->isA_Safe(StaticClass::PlayerHUDUI())){
            for(int i = 0 ; i<Type_EPrimalSubmenuType_MAX; ++i){
                UObject* MenuType = Read<UObject*>(HudUI->ObjectPointer() + 0x650 + i * 0x8);
                if(MenuType->isA_Safe(StaticClass::Widget())){
                    OpenedMenu = MenuType;
                }
            }
            
            AShooterHUD* HUD = (AShooterHUD*)QuickOffsets::GetHUD();
            for(int i = 0xf38; i<=0xf70; i = i+8){
                //if(i == 0xf50) continue;
                UObject* CurrentOpenedUI = Read<UObject*>(HUD->ObjectPointer() + i);
                if(CurrentOpenedUI->IsValid()){
                    OpenedMenu = CurrentOpenedUI;
                }
            }
        }
    }

    
    static bool EscapeSwitch;
    if([[[GCKeyboard coalescedKeyboard] keyboardInput] buttonForKeyCode:GCKeyCodeTab].isPressed){
        if(EscapeSwitch){
            if(OpenedMenu->isA_Safe(StaticClass::PrimalUI())){
                //ShowError(StringToNSString(OpenedMenu->GetFullName()));
                ((UPrimalUI*)OpenedMenu)->CloseWithAnimation();
            }
        }
        EscapeSwitch = false;
    } else {
        EscapeSwitch = true;
    }
    
}

static UPrimalItem* GetItemForSlot(int ItemSlot){
    AShooterCharacter* MyCharacter = QuickOffsets::GetShooterCharacter();
    UPrimalInventoryComponent* PlayerInventory = MyCharacter->GetPrimalInventory();
    if(PlayerInventory->IsValid()) {
        TArray<UPrimalItem*> EquippedItemArray = PlayerInventory->GetInventoryItems();
        for(int i = 0; i<EquippedItemArray.Num(); ++i){
            UPrimalItem* CurrentEquippedItem = EquippedItemArray[i];
            if(Read<int>(CurrentEquippedItem->ObjectPointer() + 0x1dc) == ItemSlot){
                return CurrentEquippedItem;
            }
        }
    }
    return nullptr;
}
void KeyboardManager::UpdateInventoryActions(){
    if(![GCKeyboard coalescedKeyboard]) return;
    if(![[GCKeyboard coalescedKeyboard] keyboardInput]) return;
    //First, update general menu actions like closing menu with escape
    UpdateMenuActions();
    //1. Check if inventory
    //struct UUI_Inventory* CurrentOpenedInventory; // Offset: 0xf38 // Size: 0x08
    AShooterHUD* HUD = (AShooterHUD*)QuickOffsets::GetHUD();
    UUI_Inventory* CurrentOpenedInventory = Read<UUI_Inventory*>(HUD->ObjectPointer() + 0xf38);
    APlayerController* MyController = QuickOffsets::GetPlayerController();
    
    if(!MyController->IsValid()) return;
    if(!CurrentOpenedInventory->IsValid()) return;
    
    UObject* RemoteInventoryDataPanel = Read<UObject*>(CurrentOpenedInventory->ObjectPointer() + 0xc80);
    UObject* LocalInventoryDataPanel = Read<UObject*>(CurrentOpenedInventory->ObjectPointer() + 0xc70);
    UObject* LastSelectedDataList = ReadWeakPointer<UObject*>(CurrentOpenedInventory->ObjectPointer() + 0xc68);
    
    /*
    static bool RSwitch;
    if(isKeyDown(UIKeyboardHIDUsageKeyboardR)){
        if(RSwitch){
            if(LastSelectedDataList->IsValid()){
                UPrimalItem* tempItem = GetSelectedDataObject(LastSelectedDataList);
                if(tempItem->IsValid())
                    ShowError(StringToNSString(tempItem->GetFullName()));
            }
        }
            
        RSwitch = false;
    }
    else
        RSwitch = true;
     */
    /*
     struct TWeakObjectPtr<struct UDataListPanel> LastSelectedDataList; // Offset: 0xc68 // Size: 0x08
     char pad_0xC70[0x4e0]; // Offset: 0xc70 // Size: 0x4e0
     */
    UPrimalItem* RemoteInventoryViewingItem = nullptr;
    UPrimalItem* LocalInventoryViewingItem = nullptr;
    UPrimalItem* InventoryViewingItem = nullptr;
    
    
    
    if(RemoteInventoryDataPanel->IsValid()){
        RemoteInventoryViewingItem = GetSelectedDataObject(RemoteInventoryDataPanel);
    }
    
    if(LocalInventoryDataPanel->IsValid()){
        LocalInventoryViewingItem = GetSelectedDataObject(LocalInventoryDataPanel);
    }
    
    
    if(LastSelectedDataList->IsValid()){
        UPrimalItem* tempItem = GetSelectedDataObject(LastSelectedDataList);
        if(tempItem != nullptr){
            InventoryViewingItem = tempItem;
        }
    }
    
    //InventoryViewingItem
    //if(RemoteInventoryViewingItem->IsValid()) InventoryViewingItem = RemoteInventoryViewingItem;
    //if(LocalInventoryViewingItem->IsValid()) InventoryViewingItem = LocalInventoryViewingItem;
    
    static bool once = true;
    
    
    UPrimalInventoryComponent* ViewingInventoryComponent = CurrentOpenedInventory->GetViewingInventoryComp();
    UPrimalInventoryComponent* LocalInventoryComponent = CurrentOpenedInventory->GetLocalInventoryComp();
    
    bool isViewingRemoteInventory = false;
    bool isViewingItem = false;
    bool isViewingItemInRemoteInventory = false;
    
    if(RemoteInventoryViewingItem->IsValid()) isViewingItemInRemoteInventory = true;
    if(InventoryViewingItem->IsValid()) isViewingItem = true;
    if(ViewingInventoryComponent->IsValid()) isViewingRemoteInventory = true;
    
    
    UPrimalInventoryComponent* ItemInventory = nullptr;
    if(isViewingItem){
        ItemInventory = LocalInventoryComponent;
        if(isViewingItemInRemoteInventory)
            ItemInventory = ViewingInventoryComponent;
    }
    
    static bool DropItemSwitch, SplitStackSwitch, TransferStackSwitch, TransferHalfStackSwitch, TransferItemSwitch, TransferFiveItemSwitch, EquipItemSwitch;
    static bool DropTouchSwitch, SplitStackTouchSwitch, TransferStackTouchSwitch, TransferHalfStackTouchSwitch, TransferItemTouchSwitch, TransferFiveItemTouchSwitch, EquipItemTouchSwitch;
    //
    if(isViewingRemoteInventory){
        
    }
    /*
     SplitStackSwitch,
     TransferStackSwitch,
     TransferHalfStackSwitch,
     TransferItemSwitch,
     TransferFiveItemSwitch,
     */
    
    /*
    if(isKeyDown(UIKeyboardHIDUsageKeyboardEscape)){
        if(EscapeSwitch){
            CurrentOpenedInventory->CloseWithAnimation();
        }
        EscapeSwitch = false;
    } else {
        EscapeSwitch = true;
    }
     */
    
    /*
     NOTE: ItemInventory->ServerRemoveItemFromSlot(InventoryViewingItem->GetItemID()); appears to remove item from a hotbar spot
            Need a way to get hotbar  items / see when im on a hotbar item
     */
    if([[[GCKeyboard coalescedKeyboard] keyboardInput] buttonForKeyCode:GCKeyCodeKeyO].isPressed){
        if(DropItemSwitch){
            if(InventoryViewingItem->IsValid() && ItemInventory->IsValid()){
                //ServerDropFromRemoteInventory
                if(isViewingItemInRemoteInventory)
                    MyController->ServerDropFromRemoteInventory(ItemInventory, InventoryViewingItem->GetItemID());
                else
                    MyController->ServerRemovePawnItem(InventoryViewingItem->GetItemID(), true, true);
                
                DropItemSwitch = false;
            }
            else {
                //if no item is selected, i want to click.
                if(DropTouchSwitch){
                    NSInteger pointId = [PTFakeMetaTouch fakeTouchId:[PTFakeMetaTouch getAvailablePointId] AtPoint:CGPointMake(Variables.CursorX,Variables.CursorY) withTouchPhase:UITouchPhaseBegan];
                    [PTFakeMetaTouch fakeTouchId:pointId AtPoint:CGPointMake(Variables.CursorX,Variables.CursorY) withTouchPhase:UITouchPhaseEnded];
                    DropTouchSwitch = false;
                }
            }
        }
        
    }
    else {
        DropItemSwitch = true;
        DropTouchSwitch = true;
    }
    
    /*
     // Object Name: Function ShooterGame.ShooterPlayerController.ServerEquipToRemoteInventory
         // Flags: [Net|NetReliableNative|Event|Public|NetServer]
         void ServerEquipToRemoteInventory(struct UPrimalInventoryComponent* inventoryComp, struct FItemNetID itemID); // Offset: 0x1010dd2c4 // Return & Params: Num(2) Size(0x10)

         // Object Name: Function ShooterGame.ShooterPlayerController.ServerEquipPawnItem
         // Flags: [Net|NetReliableNative|Event|Public|NetServer]
         void ServerEquipPawnItem(struct FItemNetID itemID);
     
     void ServerRepairItem(struct UPrimalInventoryComponent* inventoryComp, struct FItemNetID itemID);
     */
    
    //Equip if armor, if other item, use
    /*
     Equip / Repair
     */
    if([[[GCKeyboard coalescedKeyboard] keyboardInput] buttonForKeyCode:GCKeyCodeKeyE].isPressed){
        if(EquipItemSwitch){
            if(InventoryViewingItem->IsValid() && ItemInventory->IsValid()){
                if(InventoryViewingItem->GetMyItemType() == ItemType_Equipment){
                    bool isEquipped = Read<uint8_t>(InventoryViewingItem->ObjectPointer() + 0x50) >> 4 & 1;
                    if(isViewingItemInRemoteInventory){
                        MyController->ServerRepairItem(ItemInventory, InventoryViewingItem->GetItemID());
                    }
                    else {
                        if(isEquipped)
                            MyController->ServerUnEquipPawnItem(InventoryViewingItem->GetItemID());
                        else
                            MyController->ServerEquipPawnItem(InventoryViewingItem->GetItemID());
                    }
                }
                else if(InventoryViewingItem->GetMyItemType() == ItemType_MiscConsumable || InventoryViewingItem->GetMyItemType() == ItemType_Resource) {
                    MyController->ServerRequestInventoryUseItem(ItemInventory, InventoryViewingItem->GetItemID());
                }
                else if(InventoryViewingItem->GetMyItemType() == ItemType_Weapon) {
                    CurrentOpenedInventory->CloseWithAnimation();
                    MyController->ServerRequestInventoryUseItem(ItemInventory, InventoryViewingItem->GetItemID());
                }
                EquipItemSwitch = false;
            }
            else {
                //if no item is selected, i want to click.
                if(EquipItemTouchSwitch){
                    NSInteger pointId = [PTFakeMetaTouch fakeTouchId:[PTFakeMetaTouch getAvailablePointId] AtPoint:CGPointMake(Variables.CursorX,Variables.CursorY) withTouchPhase:UITouchPhaseBegan];
                    [PTFakeMetaTouch fakeTouchId:pointId AtPoint:CGPointMake(Variables.CursorX,Variables.CursorY) withTouchPhase:UITouchPhaseEnded];
                    EquipItemTouchSwitch = false;
                }
            }
        }
        
    }
    else {
        EquipItemSwitch = true;
        EquipItemTouchSwitch = true;
    }
    /*
     enum class TutorialEventType : uint8 {
         TET_None = 0,
         TET_Mount = 1,
         TET_Dismount = 2,
         TET_Sprint = 3,
         TET_Jump = 4,
         TET_Walk = 5,
         TET_LeftWheel = 6,
         TET_RightWheel = 7,
         TET_RepeatGather = 8,
         TET_OpenInventory = 9,
         TET_PickUpCreature = 10,
         TET_FlyerFly = 11,
         TET_FlyerLand = 12,
         TET_DinoDoesAltAttackNotJump = 13,
         TET_GrapplingHookClimb = 14,
         TET_GrapplingHookRappel = 15,
         TET_StructureDecay = 16,
         TET_BowAndArrow = 17,
         TET_Spear = 18,
         TET_LookAround = 19,
         TET_TransferItems = 20,
         TET_HotBar = 21,
         TET_MountedTurretFire = 22,
         TET_OrbitCam = 23,
         TET_OpenUnconsciousDinoInventory = 24,
         TET_OpenDeadPlayerInventory = 25,
         TET_OpenDeadDinoInventoryWithItems = 26,
         TET_SingleTapMount = 27,
         TET_MultiTapActions = 28,
         TET_Blueprint = 127,
         TET_MAX = 128
     };
     */
    /*
     SplitStackSwitch,
     TransferStackSwitch,
     TransferHalfStackSwitch,
     TransferItemSwitch,
     TransferFiveItemSwitch,
     */
    if([[[GCKeyboard coalescedKeyboard] keyboardInput] buttonForKeyCode:GCKeyCodeKeyT].isPressed){
        if(TransferItemSwitch){
            if(InventoryViewingItem->IsValid() && ItemInventory->IsValid()){
                //TransferStack
                bool shouldTakeAll = false;
                int MoveQuantity = InventoryViewingItem->GetItemQuantity();
                if([[[GCKeyboard coalescedKeyboard] keyboardInput] buttonForKeyCode:GCKeyCodeLeftShift].isPressed || [[[GCKeyboard coalescedKeyboard] keyboardInput] buttonForKeyCode:GCKeyCodeRightShift].isPressed){
                    //TransferHalf
                    MoveQuantity /= 2;
                }
                if([[[GCKeyboard coalescedKeyboard] keyboardInput] buttonForKeyCode:GCKeyCodeLeftControl].isPressed || [[[GCKeyboard coalescedKeyboard] keyboardInput] buttonForKeyCode:GCKeyCodeRightControl].isPressed){
                    //TransferOne
                    MoveQuantity = 1;
                }
                if([[[GCKeyboard coalescedKeyboard] keyboardInput] buttonForKeyCode:GCKeyCodeLeftAlt].isPressed || [[[GCKeyboard coalescedKeyboard] keyboardInput] buttonForKeyCode:GCKeyCodeRightAlt].isPressed){
                    shouldTakeAll = true;
                }
                //if options is pressed, do take / transfer all of stack
                
                if(isViewingRemoteInventory){
                    if(isViewingItemInRemoteInventory){
                        //ServerTransferFromRemoteInventory
                        if(shouldTakeAll)
                            MyController->ServerTransferAllStacks(ViewingInventoryComponent, LocalInventoryComponent, Read<UObject*>(InventoryViewingItem->ObjectPointer() + 0x10));
                        else
                            MyController->ServerTransferFromRemoteInventory(ViewingInventoryComponent, InventoryViewingItem->GetItemID(), MoveQuantity, 300, false, true, 0, true, false);
                    }
                    else {
                        // void ServerRequestInventoryUseItemWithItem(UPrimalInventoryComponent* inventoryComp, FItemNetID ItemID1, FItemNetID ItemID2, int AdditionalData){
                        if(shouldTakeAll)
                            MyController->ServerTransferAllStacks(LocalInventoryComponent, ViewingInventoryComponent, Read<UObject*>(InventoryViewingItem->ObjectPointer() + 0x10));
                        else
                            MyController->ServerTransferToRemoteInventory(ViewingInventoryComponent, InventoryViewingItem->GetItemID(), false, MoveQuantity, false, true, false);
                    }
                }
                TransferItemSwitch = false;
            }
            else {
                //if no item is selected, i want to click.
                if(TransferItemTouchSwitch){
                    NSInteger pointId = [PTFakeMetaTouch fakeTouchId:[PTFakeMetaTouch getAvailablePointId] AtPoint:CGPointMake(Variables.CursorX,Variables.CursorY) withTouchPhase:UITouchPhaseBegan];
                    [PTFakeMetaTouch fakeTouchId:pointId AtPoint:CGPointMake(Variables.CursorX,Variables.CursorY) withTouchPhase:UITouchPhaseEnded];
                    TransferItemTouchSwitch = false;
                }
            }
        }
        
    }
    else {
        TransferItemSwitch = true;
        TransferItemTouchSwitch = true;
    }
    
    /*
     static void WhistleToggle(bool* Toggle, UIKeyboardHIDUsage Key, std::function<void()> task, std::function<void()> completionTask = [](){}){
         if(KeyboardManager::getInstance().isKeyDown(Key)){
             if(*Toggle)
                 task();
             *Toggle = false;
         }
         else {
             if(!*Toggle && completionTask)
                 completionTask();
                 //task();
             *Toggle = true;
             //PC->OnOnScreenButtonReleased(Slot);
         }
     }
     */
    
    //Equip an item to a certain spot of your inventory
    static bool Hb0, Hb1, Hb2, Hb3, Hb4, Hb5, Hb6, Hb7, Hb8, Hb9;
    if([[[GCKeyboard coalescedKeyboard] keyboardInput] buttonForKeyCode:GCKeyCodeLeftShift].isPressed || [[[GCKeyboard coalescedKeyboard] keyboardInput] buttonForKeyCode:GCKeyCodeRightShift].isPressed){
        if(LocalInventoryComponent->IsValid()){
            WhistleToggle(&Hb1, GCKeyCodeOne, [](){
                NSInteger pointId = [PTFakeMetaTouch fakeTouchId:[PTFakeMetaTouch getAvailablePointId] AtPoint:CGPointMake(Variables.CursorX,Variables.CursorY) withTouchPhase:UITouchPhaseBegan];
                [PTFakeMetaTouch fakeTouchId:pointId AtPoint:CGPointMake(Variables.CursorX,Variables.CursorY) withTouchPhase:UITouchPhaseEnded];
            }, [LocalInventoryViewingItem, LocalInventoryComponent](){
                if(LocalInventoryViewingItem->IsValid())
                    LocalInventoryComponent->ServerAddItemToSlot(LocalInventoryViewingItem->GetItemID(), 1);
            });
            WhistleToggle(&Hb2, GCKeyCodeTwo, [](){
                NSInteger pointId = [PTFakeMetaTouch fakeTouchId:[PTFakeMetaTouch getAvailablePointId] AtPoint:CGPointMake(Variables.CursorX,Variables.CursorY) withTouchPhase:UITouchPhaseBegan];
                [PTFakeMetaTouch fakeTouchId:pointId AtPoint:CGPointMake(Variables.CursorX,Variables.CursorY) withTouchPhase:UITouchPhaseEnded];
            }, [LocalInventoryViewingItem, LocalInventoryComponent](){
                if(LocalInventoryViewingItem->IsValid())
                    LocalInventoryComponent->ServerAddItemToSlot(LocalInventoryViewingItem->GetItemID(), 2);
            });
            WhistleToggle(&Hb3, GCKeyCodeThree, [](){
                NSInteger pointId = [PTFakeMetaTouch fakeTouchId:[PTFakeMetaTouch getAvailablePointId] AtPoint:CGPointMake(Variables.CursorX,Variables.CursorY) withTouchPhase:UITouchPhaseBegan];
                [PTFakeMetaTouch fakeTouchId:pointId AtPoint:CGPointMake(Variables.CursorX,Variables.CursorY) withTouchPhase:UITouchPhaseEnded];
            }, [LocalInventoryViewingItem, LocalInventoryComponent](){
                if(LocalInventoryViewingItem->IsValid())
                    LocalInventoryComponent->ServerAddItemToSlot(LocalInventoryViewingItem->GetItemID(), 3);
            });
            WhistleToggle(&Hb4, GCKeyCodeFour, [](){
                NSInteger pointId = [PTFakeMetaTouch fakeTouchId:[PTFakeMetaTouch getAvailablePointId] AtPoint:CGPointMake(Variables.CursorX,Variables.CursorY) withTouchPhase:UITouchPhaseBegan];
                [PTFakeMetaTouch fakeTouchId:pointId AtPoint:CGPointMake(Variables.CursorX,Variables.CursorY) withTouchPhase:UITouchPhaseEnded];
            }, [LocalInventoryViewingItem, LocalInventoryComponent](){
                if(LocalInventoryViewingItem->IsValid())
                    LocalInventoryComponent->ServerAddItemToSlot(LocalInventoryViewingItem->GetItemID(), 4);
            });
            WhistleToggle(&Hb5, GCKeyCodeFive, [](){
                NSInteger pointId = [PTFakeMetaTouch fakeTouchId:[PTFakeMetaTouch getAvailablePointId] AtPoint:CGPointMake(Variables.CursorX,Variables.CursorY) withTouchPhase:UITouchPhaseBegan];
                [PTFakeMetaTouch fakeTouchId:pointId AtPoint:CGPointMake(Variables.CursorX,Variables.CursorY) withTouchPhase:UITouchPhaseEnded];
            }, [LocalInventoryViewingItem, LocalInventoryComponent](){
                if(LocalInventoryViewingItem->IsValid())
                    LocalInventoryComponent->ServerAddItemToSlot(LocalInventoryViewingItem->GetItemID(), 5);
            });
            
            WhistleToggle(&Hb6, GCKeyCodeSix, [](){
                NSInteger pointId = [PTFakeMetaTouch fakeTouchId:[PTFakeMetaTouch getAvailablePointId] AtPoint:CGPointMake(Variables.CursorX,Variables.CursorY) withTouchPhase:UITouchPhaseBegan];
                [PTFakeMetaTouch fakeTouchId:pointId AtPoint:CGPointMake(Variables.CursorX,Variables.CursorY) withTouchPhase:UITouchPhaseEnded];
            }, [LocalInventoryViewingItem, LocalInventoryComponent](){
                if(LocalInventoryViewingItem->IsValid())
                    LocalInventoryComponent->ServerAddItemToSlot(LocalInventoryViewingItem->GetItemID(), 6);
            });
            
            WhistleToggle(&Hb7, GCKeyCodeSeven, [](){
                NSInteger pointId = [PTFakeMetaTouch fakeTouchId:[PTFakeMetaTouch getAvailablePointId] AtPoint:CGPointMake(Variables.CursorX,Variables.CursorY) withTouchPhase:UITouchPhaseBegan];
                [PTFakeMetaTouch fakeTouchId:pointId AtPoint:CGPointMake(Variables.CursorX,Variables.CursorY) withTouchPhase:UITouchPhaseEnded];
            }, [LocalInventoryViewingItem, LocalInventoryComponent](){
                if(LocalInventoryViewingItem->IsValid())
                    LocalInventoryComponent->ServerAddItemToSlot(LocalInventoryViewingItem->GetItemID(), 7);
            });
            
            WhistleToggle(&Hb8, GCKeyCodeEight, [](){
                NSInteger pointId = [PTFakeMetaTouch fakeTouchId:[PTFakeMetaTouch getAvailablePointId] AtPoint:CGPointMake(Variables.CursorX,Variables.CursorY) withTouchPhase:UITouchPhaseBegan];
                [PTFakeMetaTouch fakeTouchId:pointId AtPoint:CGPointMake(Variables.CursorX,Variables.CursorY) withTouchPhase:UITouchPhaseEnded];
            }, [LocalInventoryViewingItem, LocalInventoryComponent](){
                if(LocalInventoryViewingItem->IsValid())
                    LocalInventoryComponent->ServerAddItemToSlot(LocalInventoryViewingItem->GetItemID(), 8);
            });
            
            WhistleToggle(&Hb9, GCKeyCodeNine, [](){
                NSInteger pointId = [PTFakeMetaTouch fakeTouchId:[PTFakeMetaTouch getAvailablePointId] AtPoint:CGPointMake(Variables.CursorX,Variables.CursorY) withTouchPhase:UITouchPhaseBegan];
                [PTFakeMetaTouch fakeTouchId:pointId AtPoint:CGPointMake(Variables.CursorX,Variables.CursorY) withTouchPhase:UITouchPhaseEnded];
            }, [LocalInventoryViewingItem, LocalInventoryComponent](){
                if(LocalInventoryViewingItem->IsValid())
                    LocalInventoryComponent->ServerAddItemToSlot(LocalInventoryViewingItem->GetItemID(), 9);
            });

        }
    }
    if([[[GCKeyboard coalescedKeyboard] keyboardInput] buttonForKeyCode:GCKeyCodeLeftControl].isPressed || [[[GCKeyboard coalescedKeyboard] keyboardInput] buttonForKeyCode:GCKeyCodeRightControl].isPressed){
        if(LocalInventoryComponent->IsValid()){
            WhistleToggle(&Hb1, GCKeyCodeOne, [LocalInventoryViewingItem, LocalInventoryComponent](){
                UPrimalItem* item = GetItemForSlot(1);
                if(item->IsValid())
                    LocalInventoryComponent->ServerRemoveItemFromSlot(item->GetItemID());
            });
            WhistleToggle(&Hb2, GCKeyCodeTwo, [LocalInventoryViewingItem, LocalInventoryComponent](){
                UPrimalItem* item = GetItemForSlot(2);
                if(item->IsValid())
                    LocalInventoryComponent->ServerRemoveItemFromSlot(item->GetItemID());
            });
            WhistleToggle(&Hb3, GCKeyCodeThree, [LocalInventoryViewingItem, LocalInventoryComponent](){
                UPrimalItem* item = GetItemForSlot(3);
                if(item->IsValid())
                    LocalInventoryComponent->ServerRemoveItemFromSlot(item->GetItemID());
            });
            WhistleToggle(&Hb4, GCKeyCodeFour, [LocalInventoryViewingItem, LocalInventoryComponent](){
                UPrimalItem* item = GetItemForSlot(4);
                if(item->IsValid())
                    LocalInventoryComponent->ServerRemoveItemFromSlot(item->GetItemID());
            });
            WhistleToggle(&Hb5, GCKeyCodeFive, [LocalInventoryViewingItem, LocalInventoryComponent](){
                UPrimalItem* item = GetItemForSlot(5);
                if(item->IsValid())
                    LocalInventoryComponent->ServerRemoveItemFromSlot(item->GetItemID());
            });
            WhistleToggle(&Hb6, GCKeyCodeSix, [LocalInventoryViewingItem, LocalInventoryComponent](){
                UPrimalItem* item = GetItemForSlot(6);
                if(item->IsValid())
                    LocalInventoryComponent->ServerRemoveItemFromSlot(item->GetItemID());
            });
            WhistleToggle(&Hb7, GCKeyCodeSeven, [LocalInventoryViewingItem, LocalInventoryComponent](){
                UPrimalItem* item = GetItemForSlot(7);
                if(item->IsValid())
                    LocalInventoryComponent->ServerRemoveItemFromSlot(item->GetItemID());
            });
            WhistleToggle(&Hb8, GCKeyCodeEight, [LocalInventoryViewingItem, LocalInventoryComponent](){
                UPrimalItem* item = GetItemForSlot(8);
                if(item->IsValid())
                    LocalInventoryComponent->ServerRemoveItemFromSlot(item->GetItemID());
            });
            WhistleToggle(&Hb9, GCKeyCodeNine, [LocalInventoryViewingItem, LocalInventoryComponent](){
                UPrimalItem* item = GetItemForSlot(9);
                if(item->IsValid())
                    LocalInventoryComponent->ServerRemoveItemFromSlot(item->GetItemID());
            });
        }
    }
    /*
     UIKeyboardHIDUsageKeypad1
     */
    
    
    
    
    /*
     MyInventory = DataListPanelTwo
     OpenedInventory = DataListPanelOne
     
     Selected is primal item
     
     My Player Inventory =  SC -> struct UPrimalInventoryComponent* MyInventoryComponent; // Offset: 0x1070 // Size: 0x08
     
     
     struct UPrimalInventoryComponent* GetViewingInventoryComp(); // UUIInventory WeakPointer(0xc1c)
     struct UPrimalInventoryComponent* GetLocalInventoryComp(); //
     */
    
    /*
     // Object Name: Function EngramDataListWidget.EngramDataListWidget_C.GetSelectedDataObject
     // Flags: [Event|Public|HasOutParms|BlueprintCallable|BlueprintEvent]
     struct UObject* GetSelectedDataObject(); // Offset: 0x1015492c4 // Return & Params: Num(1) Size(0x8)
     */
                    
}

    
/*
TODO
 switch to GCKeyboard
 Attempt to impliment a fix keyboard shit sometimes not loading
 Switch the HOOK to tick or something, so as to not fuck with other loaded hacks (or else there will be a hook writing battle)
 Generalize as many things as possible
 Attempt to get MonkeyDev debugging working on ark
 Attempt to make ark be able to stay active in background longer
 Obfuscator
 Attempt to impliment ideas from notes
 make keyboard more modular so it can just be added into shit
 Sig Scan
 After I'm done with keyboard, go back to working on revamp cheat
 
 - Ingame Waypoints
 - "Pull" Resources (wouldn't this be cool!)
 - "Auto Search" for item in vault // "Auto Get Kit" searches all nearby structures for the items u want
 - Auto Craft -> Select an item in your inventory or in a structure, auto pull & craft
 - Auto Repair (bPullResources)
 - If all that works, look at -> auto craft bullets, (GP, etc)
 - Auto Forges (Distribute fuel and raw metal, bTakeSmelted)
 - try to move when full weight, maybe continually popcorn and pickup items
 - Auto pickup rocks / shrubs? -> like pressing E yk
 - ESP Show generator/outlet Range, Turret Placement Range, Turret Shoot Range
 - Auto Passive Tame
 - Popcorn all from enemy structures
 - Auto Loot Dams
 - Collect Poop / Paste
 - Collect Snails
 - Pickup nearby dropped item caches
 - Shot Lines
 - More menu customization
 - Improve Menu
 - Save/Export Menu Settings
 - Save/Export Game Settings
 - Change InI
 
 - Look into running dylib from files -> I think they need to be codesigned, so probably don't do this
    https://github.com/nongshifu/iOS-Dylib
 
 
 - Update Dialogue
 - Autoclicker
 - HUD
 
 
 - Breeding Mode
    - Automatic Cuddle
    - Automatically Feed Nearby Dinos
    - Option to whistle all walk dinos
    - Imprint ESP (See which dinos need imprint, and what they need)
    - Auto Feed hungry babies
    - try to show base stats of dinos
    - show baby base stats
    - Egg timers
    - Auto Claim Babies
 
 
 - Probably not worth doing
 Eventaully the goal should be to upload a .framework as the update file on my webserver, and everyone auto updates when they launch the app.
 - Easier to add new features
 - I might have to dynamically codesign it inside my ipa lmao -> look into this!
 - either that, or it might not be possible
 
 
 Change colors of tribe log / names / chat / whatever
 Ideas:
    - longer tribe log, auto farm / build bots, longer chat
 
 
 MLKit for translations!
 https://github.com/googlesamples/mlkit/blob/master/ios/quickstarts/translate/TranslateExampleObjC/ViewController.m
 
 !!iOS 18 Offers Real Time Translations!! -> or try to use google MLKit
-Might need to update XCode again :(
 
 try to Optimize everything possible
 
 look back at dynamically loading a dylib from files so you can maybe update without updating an ipa
 
 if(isInGame, Not in any menu, no textfields active)
 1. UpdateAim
 
 if(isInGame, Not in any menu, no textfields active, RidingDino)
 if(RidingDino){
    DinoMovement
    DinoActions (F / E / Etc)
 }
 if(isInGame, Not in any menu, no textfields active)
 {
 PlayerMovement
 PlayerActions
 }
 if(isInGame, not in any menu, notextfields active, dino or player)
 {
    Misc Actions (Whistle and stuff)
 }
 
 if(isInInventory // or in any menu)){
    //
    allow cursor movement, allow cursor to click
 }
 if(not in game)
    allow cursor movement, allow cursor to click
 */

/*
 Move Direction:
 
 ManageMoveRegion
 
 
 _ZN12UPlayerHUDUI13GetSwipeDeltaE11TouchRegion -> For Region 0
 
 Region 0 : UPlayerHUDUI + 0x7b0
 
 
 GetWipeDelta Read<float>(Read<long>(Read<long>(UPlayerHUDUI + 0x7b0) + 0x4b8));
 
 GCMouse *connectedMouse = GCMouse.current;
 if (connectedMouse) {
     GCMouseInput *mouseInput = connectedMouse.mouseInput;
     if (mouseInput) {
         mouseInput.mouseMovedHandler = ^(GCMouseInput *mouse, float deltaX, float deltaY) {
             exit(0);
         };
     }
 }
 */
/*
- (BOOL)isAnyTextFieldActiveInView:(UIView *)view {
    // Check if the provided view is a UITextField and is the first responder
    if ([view isKindOfClass:[UITextField class]] && [view isFirstResponder]) {
        return YES;
    }
    
    // Recursively check all subviews
    for (UIView *subview in view.subviews) {
        if ([self isAnyTextFieldActiveInView:subview]) {
            return YES;
        }
    }
    
    // If no active UITextField is found
    return NO;
} */
static bool isAnyTextFieldActiveInView(UIView* view){
    if ([view isKindOfClass:[UITextField class]] && [view isFirstResponder]) {
        return YES;
    }
    
    for (UIView *subview in view.subviews) {
        if (isAnyTextFieldActiveInView(subview)) {
            return YES;
        }
    }
    return NO;
}
static BOOL isKeyboardShowing = NO;
bool KeyboardManager::shouldShowPointer(){
    if(Variables.menuisOpen){
        return true;
    }
    //if(isAnyTextFieldActiveInView([UIApplication sharedApplication].windows[0].rootViewController.view)){
    //    return true;
    //}
    if(isKeyboardShowing){
        return true;
    }
    /*
     if(isInGame, Not in any menu, no textfields active, RidingDino)
     */
    //if a textfield is active
    if(QuickOffsets::isServerLoaded()){
        UPlayerHUDUI* HudUI = QuickOffsets::GetPlayerHUDUI();
        if(HudUI->isA_Safe(StaticClass::PlayerHUDUI())){
            for(int i = 0 ; i<Type_EPrimalSubmenuType_MAX; ++i){
                UObject* MenuType = Read<UObject*>(HudUI->ObjectPointer() + 0x650 + i * 0x8);
                if(MenuType->isA_Safe(StaticClass::Widget())){
                    //Variables.str = MenuType->GetFullName();
                    return true;
                }
            }
            
            AShooterHUD* HUD = (AShooterHUD*)QuickOffsets::GetHUD();
            for(int i = 0xf38; i<=0xf70; i = i+8){
                UObject* CurrentOpenedUI = Read<UObject*>(HUD->ObjectPointer() + i);
                if(CurrentOpenedUI->IsValid()){
                    //Variables.str = CurrentOpenedUI->GetFullName();
                    return true;
                }
            }
            /*
             struct UUI_Inventory* CurrentOpenedInventory; // Offset: 0xf38 // Size: 0x08
                 struct UUI_TribeManager* CurrentOpenedTribeManager; // Offset: 0xf40 // Size: 0x08
                 struct UUI_SurvivorProfile* CurrentOpenedSurvivorProfile; // Offset: 0xf48 // Size: 0x08
                 struct UUI_Notification* CurrentOpenedControlsHelp; // Offset: 0xf50 // Size: 0x08
                 struct UUI_AdminMangment* currentOpenedAdminManager; // Offset: 0xf58 // Size: 0x08
                 struct UUI_ServerTransfer* CurrentOpenedServerTransferUI; // Offset: 0xf60 // Size: 0x08
                 struct UUI_Ancestry* CurrentOpenedAncestryUI; // Offset: 0xf68 // Size: 0x08
                 struct UUI_AppearanceChange* CurrentOpenedAppearanceChangeUI; // Offset: 0xf70 // Size: 0x08
             */
            
            //Now i need to check if inventory is open
            //GetMenuIfActive
        }
        return false;
    }
    
    return true;
}

void KeyboardManager::RegisterMouse(){
    GCKeyboard *keyboard = [GCKeyboard coalescedKeyboard];
    if(keyboard && KeybindManager::getInstance().isInput){
        keyboard.keyboardInput.keyChangedHandler = ^(GCKeyboardInput *keyboard, GCControllerButtonInput *key, GCKeyCode keyCode, BOOL pressed) {
            if(KeybindManager::getInstance().isInput && pressed){
                KeybindManager::getInstance().HandleKeyInput(keyCode);
            }
        };
    }
    
    float fpsVal = 120;
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* EngineDirectory = [[paths objectAtIndex:0] stringByAppendingString:@"/ShooterGame/Saved/Config/IOS/Engine.ini"];
    NSString *EngineContent = [NSString stringWithFormat:@"[/Script/IOSRuntimeSettings.IOSRuntimeSettings]\nFrameRateLock=PUFRL_%.0f\n\n[/script/engine.engine]\nMinDesiredFrameRate=%.0f\nSmoothedFrameRateRange=(LowerBound=(Type=\"ERangeBoundTypes::Inclusive\",Value=%.0f),UpperBound=(Type=\"ERangeBoundTypes::Exclusive\",Value=%.0f))", fpsVal, fpsVal, fpsVal, fpsVal];
    [EngineContent writeToFile:EngineDirectory atomically:NO  encoding:NSUTF8StringEncoding error:nil];
    
    
    Variables.prefersPointerLocked = !KeyboardManager::getInstance().shouldShowPointer();
    //Update wether or not to show the cursor
    [[UIApplication sharedApplication].windows[0].rootViewController setNeedsUpdateOfPrefersPointerLocked];
    
    
    static bool UpdateMenuState = true;
    if([[[GCKeyboard coalescedKeyboard] keyboardInput] buttonForKeyCode:GCKeyCodeGraveAccentAndTilde].isPressed){
        if(UpdateMenuState)
            [ImGuiDrawView showChange:![ImGuiDrawView isMenuShowing]];
            /*
             + (void)showChange:(BOOL)open;
             + (BOOL)isMenuShowing;
             */
            //Variables.menuisOpen = !Variables.menuisOpen;
        UpdateMenuState = false;
    } else {
        UpdateMenuState = true;
    }
}




/*
 [[NSNotificationCenter defaultCenter] addObserver:self
                                              selector:@selector(keyboardWillShow:)
                                                  name:UIKeyboardWillShowNotification
                                                object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self
                                              selector:@selector(keyboardWillHide:)
                                                  name:UIKeyboardWillHideNotification
                                                object:nil];
 */

@interface KeyboardShowing : NSObject
@end

@implementation KeyboardShowing



+ (void)load {
    // Add observers for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

+ (void)keyboardWillShow:(NSNotification *)notification {
    isKeyboardShowing = YES;
}

+ (void)keyboardWillHide:(NSNotification *)notification {
    isKeyboardShowing = NO;
}

@end

/*
 how to save/Load -> Dictonary -> Key -> Bind
 
 
 */

void Keybind::ResetDefault(){
    KeybindManager::getInstance().isInput = false;
    bindKey = GCKeyCodePower;
}
void Keybind::SetInput(){
    KeybindManager::getInstance().isInput = true;
    KeybindManager::getInstance().currentInput = *this;
}
void Keybind::Display(){
    
    ImGui::SetWindowFontScale(1.2);

    
    
    float Width = ImGui::GetContentRegionAvailWidth();
    
    
    GCKeyCode activeCode = bindKey == GCKeyCodePower ? defaultKey : bindKey;
    ImGui::Text("%s",ActionName.c_str());
    
    
    int NumSet = 0;
    for(Keybind& currentBind :  KeybindManager::getInstance().binds){
        GCKeyCode currentBindActiveKey = currentBind.bindKey == GCKeyCodePower ? currentBind.defaultKey : currentBind.bindKey;
        if(currentBindActiveKey == activeCode){
            //if(currentBind.defaultKey == activeCode)
            NumSet++;
        }
    }
    
    //Check
    //activeCode
    
    if(NumSet == 2){
        ImGui::PushStyleColor(ImGuiCol_Text, IM_COL32(0, 255, 255, 255));
    }
    if(NumSet > 2){
        ImGui::PushStyleColor(ImGuiCol_Text, IM_COL32(255, 0, 0, 255));
    }
    
    ImGui::SameLine(Width/3);
    ImGui::Text("%s", KeybindManager::getBindName(activeCode).c_str());
    
    if (NumSet > 1) {
        ImGui::PopStyleColor(); // Revert text color to previous state
    }
    
    
    ImGui::SameLine(2*Width/3);
    
    std::string displayString = string_format("%s kkkk", ActionName.c_str());
    std::string displayString2 = string_format("%s wwww", ActionName.c_str());

    ImGui::PushID(displayString.c_str());
    if(ImGui::Button("Input", ImVec2(50, 0))){
        SetInput();
    }
    ImGui::PopID();
    
    ImGui::SameLine();
    
    ImGui::PushID(displayString2.c_str());
    if(ImGui::Button("Reset", ImVec2(50, 0))){
        ResetDefault();
    }
    ImGui::PopID();
    
    ImGui::SetWindowFontScale(0.9);
}


std::map<GCKeyCode, std::string> keybindMap;
static void InitializeKeyNames(){
    keybindMap[GCKeyCodeKeyA] = "A";
    keybindMap[GCKeyCodeKeyB] = "B";
    keybindMap[GCKeyCodeKeyC] = "C";
    keybindMap[GCKeyCodeKeyD] = "D";
    keybindMap[GCKeyCodeKeyE] = "E";
    keybindMap[GCKeyCodeKeyF] = "F";
    keybindMap[GCKeyCodeKeyG] = "G";
    keybindMap[GCKeyCodeKeyH] = "H";
    keybindMap[GCKeyCodeKeyI] = "I";
    keybindMap[GCKeyCodeKeyJ] = "J";
    keybindMap[GCKeyCodeKeyK] = "K";
    keybindMap[GCKeyCodeKeyL] = "L";
    keybindMap[GCKeyCodeKeyM] = "M";
    keybindMap[GCKeyCodeKeyN] = "N";
    keybindMap[GCKeyCodeKeyO] = "O";
    keybindMap[GCKeyCodeKeyP] = "P";
    keybindMap[GCKeyCodeKeyQ] = "Q";
    keybindMap[GCKeyCodeKeyR] = "R";
    keybindMap[GCKeyCodeKeyS] = "S";
    keybindMap[GCKeyCodeKeyT] = "T";
    keybindMap[GCKeyCodeKeyU] = "U";
    keybindMap[GCKeyCodeKeyV] = "V";
    keybindMap[GCKeyCodeKeyW] = "W";
    keybindMap[GCKeyCodeKeyX] = "X";
    keybindMap[GCKeyCodeKeyY] = "Y";
    keybindMap[GCKeyCodeKeyZ] = "Z";
    
    keybindMap[GCKeyCodeOne] = "1";
    keybindMap[GCKeyCodeTwo] = "2";
    keybindMap[GCKeyCodeThree] = "3";
    keybindMap[GCKeyCodeFour] = "4";
    keybindMap[GCKeyCodeFive] = "5";
    keybindMap[GCKeyCodeSix] = "6";
    keybindMap[GCKeyCodeSeven] = "7";
    keybindMap[GCKeyCodeEight] = "8";
    keybindMap[GCKeyCodeNine] = "9";
    keybindMap[GCKeyCodeZero] = "0";
    
    keybindMap[GCKeyCodeReturnOrEnter] = "Return/Enter";
    keybindMap[GCKeyCodeEscape] = "Escape (Not Reccomended)";
    keybindMap[GCKeyCodeDeleteOrBackspace] = "Delete/Backspace";
    keybindMap[GCKeyCodeTab] = "Tab";
    keybindMap[GCKeyCodeSpacebar] = "Spacebar";
    keybindMap[GCKeyCodeHyphen] = "-";
    keybindMap[GCKeyCodeEqualSign] = "=";
    keybindMap[GCKeyCodeOpenBracket] = "[";
    keybindMap[GCKeyCodeCloseBracket] = "]";
    keybindMap[GCKeyCodeBackslash] = "\\";
    keybindMap[GCKeyCodeNonUSPound] = "Non-US #/_";
    keybindMap[GCKeyCodeSemicolon] = ";";
    keybindMap[GCKeyCodeQuote] = "'";
    keybindMap[GCKeyCodeGraveAccentAndTilde] = "`";
    keybindMap[GCKeyCodeComma] = ",";
    keybindMap[GCKeyCodePeriod] = ".";
    keybindMap[GCKeyCodeSlash] = "/";
    
    keybindMap[GCKeyCodeCapsLock] = "Caps Lock";
    
    // Function keys
    keybindMap[GCKeyCodeF1] = "F1";
    keybindMap[GCKeyCodeF2] = "F2";
    keybindMap[GCKeyCodeF3] = "F3";
    keybindMap[GCKeyCodeF4] = "F4";
    keybindMap[GCKeyCodeF5] = "F5";
    keybindMap[GCKeyCodeF6] = "F6";
    keybindMap[GCKeyCodeF7] = "F7";
    keybindMap[GCKeyCodeF8] = "F8";
    keybindMap[GCKeyCodeF9] = "F9";
    keybindMap[GCKeyCodeF10] = "F10";
    keybindMap[GCKeyCodeF11] = "F11";
    keybindMap[GCKeyCodeF12] = "F12";
    keybindMap[GCKeyCodeF13] = "F13";
    keybindMap[GCKeyCodeF14] = "F14";
    keybindMap[GCKeyCodeF15] = "F15";
    keybindMap[GCKeyCodeF16] = "F16";
    keybindMap[GCKeyCodeF17] = "F17";
    keybindMap[GCKeyCodeF18] = "F18";
    keybindMap[GCKeyCodeF19] = "F19";
    keybindMap[GCKeyCodeF20] = "F20";
    
    keybindMap[GCKeyCodePrintScreen] = "Print Screen";
    keybindMap[GCKeyCodeScrollLock] = "Scroll Lock";
    keybindMap[GCKeyCodePause] = "Pause";
    keybindMap[GCKeyCodeInsert] = "Insert";
    keybindMap[GCKeyCodeHome] = "Home";
    keybindMap[GCKeyCodePageUp] = "Page Up";
    keybindMap[GCKeyCodeDeleteForward] = "Delete Forward";
    keybindMap[GCKeyCodeEnd] = "End";
    keybindMap[GCKeyCodePageDown] = "Page Down";
    keybindMap[GCKeyCodeRightArrow] = "Right Arrow";
    keybindMap[GCKeyCodeLeftArrow] = "Left Arrow";
    keybindMap[GCKeyCodeDownArrow] = "Down Arrow";
    keybindMap[GCKeyCodeUpArrow] = "Up Arrow";
    
    // Keypad keys
    keybindMap[GCKeyCodeKeypadNumLock] = "Keypad NumLock/Clear";
    keybindMap[GCKeyCodeKeypadSlash] = "Keypad /";
    keybindMap[GCKeyCodeKeypadAsterisk] = "Keypad *";
    keybindMap[GCKeyCodeKeypadHyphen] = "Keypad -";
    keybindMap[GCKeyCodeKeypadPlus] = "Keypad +";
    keybindMap[GCKeyCodeKeypadEnter] = "Keypad Enter";
    keybindMap[GCKeyCodeKeypad1] = "Keypad 1/End";
    keybindMap[GCKeyCodeKeypad2] = "Keypad 2/Down Arrow";
    keybindMap[GCKeyCodeKeypad3] = "Keypad 3/Page Down";
    keybindMap[GCKeyCodeKeypad4] = "Keypad 4/Left Arrow";
    keybindMap[GCKeyCodeKeypad5] = "Keypad 5";
    keybindMap[GCKeyCodeKeypad6] = "Keypad 6/Right Arrow";
    keybindMap[GCKeyCodeKeypad7] = "Keypad 7/Home";
    keybindMap[GCKeyCodeKeypad8] = "Keypad 8/Up Arrow";
    keybindMap[GCKeyCodeKeypad9] = "Keypad 9/Page Up";
    keybindMap[GCKeyCodeKeypad0] = "Keypad 0/Insert";
    keybindMap[GCKeyCodeKeypadPeriod] = "Keypad ./Delete";
    keybindMap[GCKeyCodeKeypadEqualSign] = "Keypad =";
    keybindMap[GCKeyCodeNonUSBackslash] = "Non-US \\ or |";
    
    keybindMap[GCKeyCodeApplication] = "Application";
    keybindMap[GCKeyCodePower] = "Not Bound";
    
    keybindMap[GCKeyCodeInternational1] = "International 1";
    keybindMap[GCKeyCodeInternational2] = "International 2";
    keybindMap[GCKeyCodeInternational3] = "International 3";
    keybindMap[GCKeyCodeInternational4] = "International 4";
    keybindMap[GCKeyCodeInternational5] = "International 5";
    keybindMap[GCKeyCodeInternational6] = "International 6";
    keybindMap[GCKeyCodeInternational7] = "International 7";
    keybindMap[GCKeyCodeInternational8] = "International 8";
    keybindMap[GCKeyCodeInternational9] = "International 9";
    
    keybindMap[GCKeyCodeLANG1] = "LANG1 (Kana/Hangul)";
    keybindMap[GCKeyCodeLANG2] = "LANG2 (Alphanumeric/Hanja)";
    keybindMap[GCKeyCodeLANG3] = "LANG3 (Katakana)";
    keybindMap[GCKeyCodeLANG4] = "LANG4 (Hiragana)";
    keybindMap[GCKeyCodeLANG5] = "LANG5 (Zenkaku/Hankaku)";
    keybindMap[GCKeyCodeLANG6] = "LANG6";
    keybindMap[GCKeyCodeLANG7] = "LANG7";
    keybindMap[GCKeyCodeLANG8] = "LANG8";
    keybindMap[GCKeyCodeLANG9] = "LANG9";
    
    keybindMap[GCKeyCodeLeftControl] = "Left Control";
    keybindMap[GCKeyCodeLeftShift] = "Left Shift";
    keybindMap[GCKeyCodeLeftAlt] = "Left Alt";
    keybindMap[GCKeyCodeLeftGUI] = "Left GUI";
    keybindMap[GCKeyCodeRightControl] = "Right Control";
    keybindMap[GCKeyCodeRightShift] = "Right Shift";
    keybindMap[GCKeyCodeRightAlt] = "Right Alt";
    keybindMap[GCKeyCodeRightGUI] = "Right GUI";
}
void KeybindManager::Initialize() {
    InitializeKeyNames();
    binds.clear();
    binds.push_back(Keybind("MultiPurpose1", GCKeyCodeLeftArrow));
    binds.push_back(Keybind("MultiPurpose2", GCKeyCodeUpArrow));
    binds.push_back(Keybind("MultiPurpose3", GCKeyCodeRightArrow));
    binds.push_back(Keybind("MultiPurpose4", GCKeyCodeDownArrow));
    binds.push_back(Keybind("DpadUp", GCKeyCodeOpenBracket));
    binds.push_back(Keybind("DpadDown", GCKeyCodeCloseBracket));
    binds.push_back(Keybind("Close Menu", GCKeyCodeTab));
    binds.push_back(Keybind("Toggle Keybind Menu", GCKeyCodeGraveAccentAndTilde));
    binds.push_back(Keybind("0", GCKeyCodeZero));
    binds.push_back(Keybind("1", GCKeyCodeOne));
    binds.push_back(Keybind("2", GCKeyCodeTwo));
    binds.push_back(Keybind("3", GCKeyCodeThree));
    binds.push_back(Keybind("4", GCKeyCodeFour));
    binds.push_back(Keybind("5", GCKeyCodeFive));
    binds.push_back(Keybind("6", GCKeyCodeSix));
    binds.push_back(Keybind("7", GCKeyCodeSeven));
    binds.push_back(Keybind("8", GCKeyCodeEight));
    binds.push_back(Keybind("9", GCKeyCodeNine));
    binds.push_back(Keybind("Drop Item", GCKeyCodeKeyO));
    binds.push_back(Keybind("Equip Item", GCKeyCodeKeyE));
    binds.push_back(Keybind("Transfer Stack", GCKeyCodeKeyT));
    binds.push_back(Keybind("Transfer All", GCKeyCodeLeftAlt));
    binds.push_back(Keybind("Move Forward", GCKeyCodeKeyW));
    binds.push_back(Keybind("Move Backwards", GCKeyCodeKeyS));
    binds.push_back(Keybind("Move Left", GCKeyCodeKeyA));
    binds.push_back(Keybind("Move Right", GCKeyCodeKeyD));
    binds.push_back(Keybind("Run Toggle", GCKeyCodeLeftShift));
    binds.push_back(Keybind("Autosprint Toggle", GCKeyCodeRightShift));
    binds.push_back(Keybind("Use Key", GCKeyCodeKeyE));
    binds.push_back(Keybind("Open Target Inventory", GCKeyCodeKeyF));
    binds.push_back(Keybind("Prone / Airbrake", GCKeyCodeKeyX));
    binds.push_back(Keybind("Crouch / Alt2", GCKeyCodeKeyC));
    binds.push_back(Keybind("Move Up / Jump", GCKeyCodeSpacebar));
    binds.push_back(Keybind("Open Inventory", GCKeyCodeKeyI));
    binds.push_back(Keybind("Reload", GCKeyCodeKeyR));
    binds.push_back(Keybind("Toggle Accesory", GCKeyCodeKeyN));
    binds.push_back(Keybind("Rotate Snap Point", GCKeyCodeKeyQ));
    binds.push_back(Keybind("Whistle Selection", GCKeyCodeQuote));
    binds.push_back(Keybind("Follow All", GCKeyCodeKeyJ));
    binds.push_back(Keybind("Follow One", GCKeyCodeKeyT));
    binds.push_back(Keybind("Stop All", GCKeyCodeKeyU));
    binds.push_back(Keybind("Stop One", GCKeyCodeKeyV));
    binds.push_back(Keybind("Aggressive", GCKeyCodeBackslash));
    binds.push_back(Keybind("Attack Target", GCKeyCodePeriod));
    binds.push_back(Keybind("Neutral", GCKeyCodeHyphen));
    binds.push_back(Keybind("Passive", GCKeyCodeSemicolon));
    binds.push_back(Keybind("MoveTo", GCKeyCodeComma));
    
    LoadAll();
    //binds.push_back(Keybind("W", GCKeyCodeKeyW));
}
void KeybindManager::SaveAll(){
    NSString* KitPath = GetSavePath();
    NSMutableDictionary *KitData = [[NSMutableDictionary alloc] initWithContentsOfFile:KitPath];
    if(!KitData){
        KitData = [[NSMutableDictionary alloc] init];
    }
    
    for(Keybind& currentBind : binds){
        [KitData setObject:@(currentBind.bindKey) forKey:StringToNSString(currentBind.ActionName)];
    }
    
    [KitData writeToFile:KitPath atomically:YES];
}
void KeybindManager::LoadAll(){
    NSString* KitPath = GetSavePath();
    NSDictionary *KitData = [[NSDictionary alloc] initWithContentsOfFile:KitPath];
    if(KitData){
        for(Keybind& currentBind : binds){
            NSNumber *BindName = [KitData objectForKey:StringToNSString(currentBind.ActionName)];
            if (BindName) {
                currentBind.bindKey = (GCKeyCode)[BindName integerValue];
            }
        }
    }
}
std::string KeybindManager::getBindName(GCKeyCode forKey){
    
    if(keybindMap.find(forKey) == keybindMap.end()){
        keybindMap[forKey] = "nil";
    }
    return keybindMap[forKey];
    /*
     if(keyMap.find(inKey) == keyMap.end()){
         keyMap[inKey] = false;
     }
     return keyMap[inKey];
     */
}
NSString* KeybindManager::GetSavePath(){
    // Path to the Plist
    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"keybinds.plist"];
    
    //Create the Plist if it doesn't already exist./Users/carsonmobile/Desktop/XCTests/PVPArena/PVPArenaDylib/src/Utils.mm
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSDictionary *initialData = @{};
        [initialData writeToFile:filePath atomically:YES];
    }
    
    return filePath;
}
bool KeybindManager::isInputtingKey(){
    return isInput;
}
void KeybindManager::HandleKeyInput(GCKeyCode key){
    if(isInput){
        for(Keybind& currentBind : binds){
            if(currentBind.ActionName == currentInput.ActionName){
                currentBind.bindKey = key;
                isInput = false;
                SaveAll();
                return;
            }
        }
        ShowError(@"not found");
    }
    ShowError(@"not input");
}
bool KeybindManager::isKeyPressed(std::string ActionName){
    for(Keybind& currentBind : binds){
        if(currentBind.ActionName == ActionName){
            if(currentBind.bindKey == GCKeyCodePower){
                return [[[GCKeyboard coalescedKeyboard] keyboardInput] buttonForKeyCode:currentBind.defaultKey].isPressed;
            }
            return [[[GCKeyboard coalescedKeyboard] keyboardInput] buttonForKeyCode:currentBind.bindKey].isPressed;
        }
    }
    ShowError(@"iskeypressed not found");
    return false;
}
bool KeybindManager::isDefaultKeyPressed(GCKeyCode defaultKey){
    for(Keybind& currentBind : binds){
        if(currentBind.defaultKey == defaultKey){
            if(currentBind.bindKey == GCKeyCodePower){
                return [[[GCKeyboard coalescedKeyboard] keyboardInput] buttonForKeyCode:currentBind.defaultKey].isPressed;
            }
            return [[[GCKeyboard coalescedKeyboard] keyboardInput] buttonForKeyCode:currentBind.bindKey].isPressed;
        }
    }
    ShowError(@"iskeypressed not found");
    return false;
}

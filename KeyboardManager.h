//
//  AdBot.h
//  ArkAdBot
//
//  Created by Carson Mobile on 7/16/24.
//

#ifndef AdBot_h
#define AdBot_h

#include <string>
#include <queue>
#include <map>
#import <GameKit/GameKit.h>

void ShowError(NSString * ErrorMessage);

@interface UIPointerLockState (CustomLock)
@end
@interface UIViewController (hook)
@end

@interface UIResponder (hook)
@end

long long getCurrentTimeMS(); 


class KeyboardManager {
public:
    static KeyboardManager& getInstance() {
        static KeyboardManager instance; // The single instance
        return instance;
    }
    
    void SetFps();
    
    void AdjustAimDelta(float DeltaX, float DeltaY);
    void AdjustAim(float ScrollX, float ScrollY);
    
    //handles the key press
    void HandleKeyPressed(UIKeyboardHIDUsage inKey);
    void HandleKeyReleased(UIKeyboardHIDUsage inKey);
    
    bool& getKeyDown(UIKeyboardHIDUsage inKey);
    bool isKeyDown(UIKeyboardHIDUsage KeyName);
    
    void UpdateKeys();
    void UpdateAim();
    void UpdateMovement();
    void UpdateGame();
    
    void RegisterMouse();
    void HandleScroll(float x, float y);
    void HandleMouseButton(int button, bool pressed);
    
    std::map<UIKeyboardHIDUsage, bool> keyMap;
    std::map<int, bool> mouseMap;
    
    bool isMouseDown(int mouseInt);
    
    
    void UpdateCharacterMovement();
    void UpdateDinoMovement();
    void UpdateDinoActions();
    void UpdatePlayerActions();
    void UpdateMiscActions();
    void UpdateMenuActions();
    void UpdateInventoryActions();
    
    bool shouldShowPointer();
};


std::vector<std::string>& keyPressesQ();


/*
 Keybinds:
 
 have a std::vector of actionBindings, like
 wAction
 aAction
 
 in the keycode changed handler have it change the action
 when you get is pressed check the action keys
 
 
 need to be able to get the string for the keycode
 need a default key
 
 class KeybindManager{
 }
 class Keybind {
 public:
    std::string ActionName;
    GCKeyCode default;
    GCKeyCode bind;

    std::string getBindName(GCKeyCode forKey)
    void ResetDefault;
    
 
    void Save
    void Load
    
 }
 */

class Keybind{
public:
    std::string ActionName;
    GCKeyCode defaultKey;
    GCKeyCode bindKey;
    
    Keybind(std::string InActionName, GCKeyCode InDefaultKey, GCKeyCode InBindKey){
        ActionName = InActionName;
        defaultKey = InDefaultKey;
        bindKey = InBindKey;
    }
    Keybind(std::string InActionName, GCKeyCode InDefaultKey){
        ActionName = InActionName;
        defaultKey = InDefaultKey;
        
        //Power = not bound
        bindKey = GCKeyCodePower;
    }
    Keybind(){
        ActionName = "none";
        defaultKey = GCKeyCodePower;
        bindKey = GCKeyCodePower;
    }
    void ResetDefault();
    void SetInput();
    void Display();
};

class KeybindManager{
public:
    static KeybindManager& getInstance() {
        static KeybindManager instance; // The single instance
        return instance;
    }
    void Initialize();
    void SaveAll();
    void LoadAll();
    NSString* GetSavePath();
    bool isKeyPressed(std::string ActionName);
    bool isDefaultKeyPressed(GCKeyCode defaultKey);
    static std::string getBindName(GCKeyCode forKey);
    
    bool isInputtingKey();
    void HandleKeyInput(GCKeyCode key);
    
    bool isInput;
    std::vector<Keybind> binds;
    Keybind currentInput;
};
#endif

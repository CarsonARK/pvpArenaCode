//
//  GameLoop.h
//  PVPArena
//
//  Created by Carson Mobile on 6/10/24.
//

#ifndef GameLoop_h
#define GameLoop_h




//This is called from Controller Update
class GameLoop {
};

//This is called from ImGui
class MenuLoop {
public:
    static MenuLoop& getInstance() {
        static MenuLoop instance;
        return instance;
    }
    
    //Server IP, Password, Admin, Arena Bounds, Teleport Location
    void InitializeGame();
    
    void Update();
    
    std::string ServerIP;
    std::string ServerPassword;
    std::string ServerAdminPassword;
    
    bool isAdmin;
    bool hasLoggedIn;
};


#endif /* GameLoop_h */

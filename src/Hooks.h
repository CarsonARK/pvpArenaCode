//
//  Hooks.h
//  ArkTesting
//
//  Created by Carson Mobile on 11/29/23.
//

#ifndef Hooks_h
#define Hooks_h

#include <cstdint>
#include <queue>

class HookRegistration{
    
public:
    HookRegistration() : HookAddress(0), OriginalGameFunction(0), MyFunction(0){}
    HookRegistration(uint64_t HookAddr, uint64_t OrigionalFunction) : HookAddress(HookAddr), OriginalGameFunction(OrigionalFunction){}
    void Register();
    void Unregister();
    void RegisterForObject(UObject* Actor, uint64_t VTableAddress, uint64_t HookFunction);
    bool isHooked();
    uint64_t GetOriginalFunctionAddress(){ return OriginalGameFunction; }
    
    static uint64_t& GetProcessEventAddres(){
        static uint64_t Addr = 0;
        return Addr;
    }
    
private:
    uint64_t HookAddress;
    uint64_t OriginalGameFunction;
    uint64_t MyFunction;
};

class FunctionQueue {
public:
    static FunctionQueue& GetI(){
        static FunctionQueue instance;
        return instance;
    }
    void ExecuteQueue(){
        while (!tasks.empty()) {
            std::function<void()> task = tasks.front();
            task();
            tasks.pop();
        }
    }
    void AddTask(std::function<void()> task){
        tasks.push(task);
    }
private:
    std::queue<std::function<void()>> tasks;
};
namespace GameHooks {
    static HookRegistration SpeedHook;
    static HookRegistration ControllerHook;
    static HookRegistration CharacterHook;
    static HookRegistration WeaponHook;
    static HookRegistration StateHook;
    static HookRegistration SpawnHook;

    void RegisterHooks();
}


/*
 queue.AddTask([]() {
    std::cout << "Task 2 executed" << std::endl;
});
 taskQueue.push([data]() {
    std::cout << "Task executed with captured data: " << data << std::endl;
 });
 */



#endif /* Hooks_h */

//Unreal Engine 4.17~4.19

//Simple function call using process event made for Ark Survival Evolved Mobile

//void __thiscall FName::FName(FName *this,wchar_t *param_1,EFindName param_2)
long FNameFuncOffset = 0x0140e0ec;

//long __thiscall UObject::FindFunctionChecked(UObject *this,FName param_1)
long FindFunctionCheckedOffset = 0x0154a6a4;

//void __thiscall UObject::ProcessEvent(UObject *this,UFunction *param_1,void *param_2)
long ProcessEventOffset = 0x024b57ec;

static void ProcessEvent(long Object, wchar_t* FunctionName, void* params){
    
    long BaseAdress = (long)_dyld_get_image_header(0);

    const auto FNameFunction = reinterpret_cast<void*>(BaseAdress + FNameFuncOffset);
    const auto FindFunctionCheckedFunction = reinterpret_cast<long*>(BaseAdress + FindFunctionCheckedOffset);
    const auto ProcessEventFunction = reinterpret_cast<void*>(BaseAdress + ProcessEventOffset);

    if(FNameFunction && FindFunctionCheckedFunction && ProcessEventFunction){

        long FuncFName;
        
        //Construct FName
        reinterpret_cast<void(*)(long, wchar_t*, int)>(FNameFunction)((long)&FuncFName, FunctionName, 1);

        //Find Function
        long FunctionAdress = reinterpret_cast<long(__fastcall*)(long, long)>(FindFunctionCheckedFunction)(Object, FuncFName);

        //Process Event
        reinterpret_cast<void(*)(long, long, long)>(ProcessEventFunction)(Object, FunctionAdress, (long)params);
    }

    return;
}


// Calling using the function hardcoded address, example from a sdk dump

// ProcessEvent can be adapted to use the function address directly, without first using FindFunctionChecked to look up the function by name. 
// Instead, the address is cast to a function pointer of the correct type and passed directly to ProcessEvent
// This wrapper function returns a Boolean value indicating whether the event was successfully processed or not.

static bool bProcessEvent(long Object, void* FunctionAddress, void* Params);

static bool bProcessEvent(long Object, void* FunctionAddress, void* Params) {
    
    long BaseAddress = (long)_dyld_get_image_header(0);
    
    const auto ProcessEventFunction = reinterpret_cast<void*>(BaseAddress + ProcessEventOffset);
    
    if (ProcessEventFunction) {
        
        // Note that the reinterpret_cast is used to convert the FunctionAddress and Params pointers to long values
        reinterpret_cast<void(*)(long, long, long)>(ProcessEventFunction)(Object, reinterpret_cast<long>(FunctionAddress), reinterpret_cast<long>(Params));
        
        return true;
    }
    return false;
}


 

/*     example   
Function Name: DungeonAccess();
Class: uWorld.ShooterPlayerController;
Params & Returns: 0, 0;
Offset Address: 0x1044e9650;
*/


// Class address of the function DungeonAccess
long ShooterPlayerController = 0x12345678;

// no parameters or return value
void* Params = nullptr;

ProcessEvent(ShooterPlayerController, L"DungeonAccess", &Params);

/*      using the function address to call, with a boolean return    */

// BaseAddr needs to be defined within scope
long BaseAddr = (long)_dyld_get_image_header(0);

// the address of the function, cast to a void* 
void* FunctionAddress = reinterpret_cast<void*>(BaseAddr + 0x1044e9650);

void* Params = nullptr;

if(bProcessEvent(ShooterPlayerController, &FunctionAddress, &Params))
{
    // Success
}


/* 

How to define structs for function parameters and return values 

*/


/*
- Example use case: 
Pretend there is a function called CheckPointsSameLine(isnt a real function)
which is in class AFakeFunctions, has a reutrn type of bool,  a vector, a rotator, and another vector as an argument
bool AFakeFunctions::CheckPointsSameLine(Vector StartLocation, Rotator AimRotation, Vector TargetLocation);
and the goal is to make a triggerbot and there is a shoot function 
void WeaponClass:FireWeapon(long Controller, long Weapon);
to call this you would do */

//Note: While CheckPointsSameLine is not a real function, a similar thing can be done using LineTrace functions
struct Vector{
    float x;
    float y;
    float z;
};
struct Rotation{
    float pitch;
    float yaw;
    float roll;
};
struct CheckPointsSameLineParams{
    Vector StartLocation;
    Rotator AimRotation;
    Vector TargetLocation;
    bool returnVal;
};
struct FireWeaponParams{ //since the FireWeapon function is void, you dont need a return
    long Controller;
    long Weapon;
};

void Triggerbot{
    long AFakeFunctionsClass = Gworld->Something->Something->FAkeFunctions;

    CheckPointsSameLine Input;
    CheckPointsSameLine.StartLocation = MyLocation;
    CheckPointsSameLine.AimRotation = MyRotation;
    CheckPointsSameLine.TargetLocation = EnemyLocation;

    ProcessEvent(AFakeFunctionsClass, L"CheckPointsSameLine", &CheckPointsSameLine);

    if(CheckPointsSameLine.returnVal){

        long Controller = UWorld->PointerChain->aController;
        long Weapon = PointerChain -> Weapon;
        FireWeaponParams fireInput;

        fireInput.Controller = Controller;
        fireInput.Weapon = Weapon;

        ProcessEvent(Weapon, L"FireWeapon", &fireInput);
    }
}

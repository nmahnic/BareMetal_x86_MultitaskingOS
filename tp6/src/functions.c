#define dword long
#define byte  char
#define word  short

__attribute__(( section(".functions"))) byte __guardarCaracter(dword *pressedKey, dword *dst){
    if(0x21 != (dword)pressedKey){
        if((dword)pressedKey != 0x0B){
            *dst = (dword)pressedKey + 0x30 - 0x01;    
        }else{
            *dst = (dword)0x30;
        }
        dst++;
    }
    return((dword)dst);
}
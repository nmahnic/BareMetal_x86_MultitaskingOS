#define dword long
#define byte  char
#define word  short

__attribute__(( section(".functions_rom"))) byte __fast_memcopy(const dword *src, dword *dst, dword *length){
    byte status = 0; //ERROR_DEFECTO;
    dword indice = 0;
    dword largo = length;

    while(indice < largo){
        *dst = *src;
        dst++;
        src++;
        indice++;
    }
    if(indice == largo){
        status = 1;
    }else{
        status = -1;
    }

    return(status);
}
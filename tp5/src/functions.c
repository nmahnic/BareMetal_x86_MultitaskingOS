#define dword int
#define byte  char
#define word  short

__attribute__(( section(".functions"))) byte suma(){
    short a =  50;
    short b = 100;
    short i = 0;

    for(i=0; i<5; i++){
        b +=a;
    }
    return(b);
}
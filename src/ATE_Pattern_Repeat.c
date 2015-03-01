#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <limits.h>
#include <stddef.h>

#define C 10

int main(int argc, char *argv[] ){

FILE *fpr = NULL;  //reading pointer
FILE *fpw = NULL;  //writing pointer

int counter = 1;
int r = 0; //for the case of different last lines


char *buf = calloc(1,sizeof(char*));
char *read1 = calloc(C,sizeof(char*));
char *read2 = calloc(C,sizeof(char*));

//Open file for reading the encoded slices
if((fpr = fopen( argv[1],"r+"))== NULL){
//C:\\Users\\Kat\\Desktop\\master\\Nikolos\\encoder\\testSets\\IWLS05.LOC.tmax\\vga.lcd.trans.tmax_enc.txt,r+))== NULL){
	printf("Cannot open data file\n");
    exit(1);
}

//Open file for writing with ATE pattern repeat
if((fpw = fopen(argv[2],"w+"))== NULL){

//"C:\\Users\\Kat\\Desktop\\master\\Nikolos\\encoder\\testSets\\IWLS05.LOC.tmax\\vga.lcd.trans.tmax_pat.txt","w+"))== NULL){
	printf("Cannot open pattern repeat file\n");
   	exit(1);
}

fread(read1,C+1,1,fpr);

while(fread(read2,C+1,1,fpr)!= 0){
	
	r=0;
	
	if(strcmp(read1,read2) == 0){
		counter++;  //pattern repeat
		continue;
    }
    else{
		fwrite(read1,sizeof(char),C,fpw);
		fwrite(",",sizeof(char),1,fpw);
    	snprintf(buf, sizeof(buf), "%d", counter);
    	fwrite(buf,sizeof(char),sizeof(buf),fpw);
    	fwrite("\n",sizeof(char),1,fpw);    	
		counter = 1;
    	
		while(fread(read1,C+1,1,fpr)!=0){
			    		
			if(strcmp(read1,read2) == 0){
				counter++;
				continue;
    		}
    		else{
    			fwrite(read2,sizeof(char),C,fpw);
    			fwrite(",",sizeof(char),1,fpw);
    			snprintf(buf, sizeof(buf), "%d", counter);
    			fwrite(buf,sizeof(char),sizeof(buf),fpw);
    			fwrite("\n",sizeof(char),1,fpw);
    			r=1;
    			counter = 1;	
    			break;
    		}
    	}
    }
}

if(r){
	fwrite(read1,sizeof(char),C,fpw);
}
else{
	fwrite(read2,sizeof(char),C,fpw);
}

fwrite(",",sizeof(char),1,fpw);
snprintf(buf, sizeof(buf), "%d", counter);
fwrite(buf,sizeof(char),sizeof(buf),fpw);
fwrite("\n",sizeof(char),1,fpw);

free(read1);
free(read2);
free(buf);

return 0;

}

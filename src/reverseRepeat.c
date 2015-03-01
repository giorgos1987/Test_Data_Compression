#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <limits.h>
#include <stddef.h>

#define C 7
#define K 7

int main(){

FILE *fpr = NULL;  //reading pointer
FILE *fpw = NULL;  //writing pointer

char *read = calloc(2*C,sizeof(char*));
int i = 0, counter = 0;
char delims[] = ",";
char *result = NULL;

//Open file for reading the encoded slices with pattern-repeat
if((fpr = fopen("C:\\Users\\kat\\Desktop\\master\\Nikolos\\encoder\\patternRepeat.txt","r+"))== NULL){
	printf("Cannot open data file\n");
    exit(1);
}

//Open file for writing the original encoded slices
if((fpw = fopen("C:\\Users\\kat\\Desktop\\master\\Nikolos\\encoder\\reverseRepeat.txt","w+"))== NULL){
	printf("Cannot open pattern repeat file\n");
   	exit(1);
}

while(fgets(read,2*C+1,fpr)!= 0){

	result = strtok(read,delims);
	while( result != NULL ) {
    	counter = atoi(result);
    	result = strtok(NULL,delims);
    }   	    	

	for(i=0;i<counter;i++){
		fwrite(read,sizeof(char),C,fpw);
		fwrite("\n",sizeof(char),1,fpw);
	}
}

return(0);

}

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <limits.h>
#include <stddef.h>

// N = number of internal SCAN CHAINS - size of a SLICE
// T = size of TEST VECTOR, length of each line in test set file, given by the number displayed on the first line
// K = size of DATA CODE - ceil(log2(N+1))
// C = size of ENCODED SLICE (K+2)

struct target_symbols{
	char ts; //TARGET SYMBOL
	int ts_num;  //number of target symbols in each slice
} a;

struct target_symbols *ts_p = &a;

FILE *fpr = NULL;  //reading pointer
FILE *fpw = NULL;  //writing pointer

//functions' declarations
void *singleBit(char *slice_p, struct target_symbols *ts_p, char *encSlice_p, int N_size, int K_size, int C_size); //single-bit encoding
struct target_symbols *calculate_ts(char *slice_p, struct target_symbols *ts_p, int N_size); //target symbol calculation
void *groupCopy(char *slice_p, struct target_symbols *ts_p, char *encSlice_p, int M_size, int N_size, int K_size, int C_size);  //group-copy encoding
void dec2bin(int index, char dc[], int K_size);  //decimal-to-binary conversion


int main(int argc, char *argv[]) {

//char fname[200];
int N = 255; //atoi(argv[3]);
char slice[N]; //SLICE to be encoded
char *slice_p = &slice[0];
int K = 8;  //ceil(log2(N+1)) = ceil(log10(N+1)/log10(2))
int C = K+2;
char encSlice[C];
char *encSlice_p = &encSlice[0];

int M = (N+K-1)/K;  //number of GROUPS in group-copy mode - ceil(N/K)

int i = 0, j = 0;

//Open file for reading the test vectors
//sprintf(fname,argv[1]);
if((fpr = fopen("C:\\Users\\kat\\Desktop\\master\\Nikolos\\encoder\\testSets\\IWLS05.LOC.tmax\\vga.lcd.trans.tmax.vec","r+"))== NULL){
	printf("Cannot open test vector file\n");
    exit(1);
}

//Open file for writing the encoded slices
//sprintf(fname,argv[2]); 
if((fpw = fopen("C:\\Users\\kat\\Desktop\\master\\Nikolos\\encoder\\testSets\\IWLS05.LOC.tmax\\vga.lcd.trans.tmax_enc.txt","w+"))== NULL){
	printf("Cannot open encoded data file\n");
   	exit(1);
}

char *temp = malloc(C*sizeof(char*));
//the number in the first line gives the length of test vector
int T = atoi(fgets(temp,C+1,fpr));
//printf("vector length: %d\n",T);

free(temp);

//dynamically allocate a temporary array to read each vector
char *tempVector = malloc(T * sizeof(char*));

int F = (T+N-1)/N; //number of scan cells in each scan chain - ceil(T/N)
//printf("slice table size: %d x %d\n",N,F);

//dynamically allocate a table of slices: (number of scan chains N)x(number of scan cells in each scan chain F)
char **vectorTable = malloc(sizeof(char*) * N);
if (vectorTable)
{
  for (i = 0; i < N; i++)
  {
    vectorTable[i] = malloc(sizeof *vectorTable[i] * F);
  }
}

 while((fread(tempVector,T+1,1,fpr)!= 0) ){  //read test vector from file

	 int g = 0;
	//put test vector in table of slices (with padding)
	for (i=0;i<N;i++){
		for(j=0;j<F;j++){
			if (g<T-1){
				vectorTable[i][j] = *(tempVector+g);
	     		g++;
			}
			else{
				vectorTable[i][j] = 'X';
			}
			//printf("%c ",vectorTable[i][j]);
	    }
	    //printf("\n");
	}

	 //take each COLUMN of vectorTable as a SLICE
	for (j=0;j<F;j++){
		int s = 0;
		//printf("\nslice %d is: ",j);
		for(i=0;i<N;i++){
			slice[s] = vectorTable[i][j];
	     	//printf("%c",slice[s]);
	     	s++;
	     }
	     calculate_ts(slice_p,ts_p,N);
	     //printf("target symbols %c are %d\n",ts_p->ts,ts_p->ts_num);

	     if(ts_p->ts_num>1){
	     	//printf("group copy mode\n");
	     	groupCopy(slice_p,ts_p,encSlice_p,M,N,K,C);
		 }
	     else{
	     	singleBit(slice_p,ts_p,encSlice_p,N,K,C);
	 	}

	}

}

 fclose(fpr);
 fclose(fpw);
 free(tempVector);
 free(vectorTable);

 return(0);

}

struct target_symbols *calculate_ts(char *slice_p, struct target_symbols *ts_p, int N_size){

	 int i=0;
	 int n0 = 0, n1 = 0;  //n0: number of 0's, n1: number of 1's

     for(i=0;i<N_size;i++){
     	if(*(slice_p+i) == '0'){
     		n0++;
     	}
     	else if (*(slice_p+i) == '1'){
     		n1++;
     	}
	}

	//printf("\nn0 = %d, n1 = %d, ",n0,n1);

	//find target symbols, map x's to non-target symbols

	if(n0>n1){
		ts_p->ts = '1';
		ts_p->ts_num = n1;
		for(i=0;i<N_size;i++){
     		if(*(slice_p+i) == 'X'){
     			*(slice_p+i) = '0';
     		}
		}
	}
	else{
		ts_p->ts = '0';
		ts_p->ts_num = n0;
		for(i=0;i<N_size;i++){
     		if(*(slice_p+i) == 'X'){
     			*(slice_p+i) = '1';
     		}
		}
	}

	return(ts_p);
}

void *singleBit(char *slice_p, struct target_symbols *ts_p, char *encSlice_p, int N_size, int K_size, int C_size){

     int i=0, index=0;
     char d2b[K_size];

	 if(ts_p->ts == '1'){
	 	*encSlice_p = '0';  //single-bit mode, all zeros, target symbol 1
	 	*(encSlice_p+1) = '0';
	 	if(ts_p->ts_num != 0){
	 		for(i=0;i<N_size;i++){
		 		if(*(slice_p+i) == '1' ){
			 		index = i;
					//printf("single bit mode, 1 at index %d, ",index);
				}
         	}
        	dec2bin(index,d2b,K_size);
			//printf("data code:");
			for(i=0;i<K_size;i++){
				//printf("%c",d2b[i]);
			}
			for(i=0;i<K_size;i++){
				*(encSlice_p+i+2) = d2b[i];
			}
    	}
		else{    //dummy data-code (11111)
			for(i=0;i<K_size;i++){
				*(encSlice_p+i+2) = '1';
			}
		}

	}
    else{
		*encSlice_p = '0';  //single-bit mode, all ones, target symbol 0
		*(encSlice_p+1) = '1';
	 	if(ts_p->ts_num != 0){
	 			for(i=0;i<N_size;i++){
		 			if(*(slice_p+i) == '0' ){
			 			index = i;
						//printf("1 at index %d, ",index);
					}
         		}
        		dec2bin(index,d2b,K_size);
				//printf("data code:");
				for(i=0;i<K_size;i++){
				//	printf("%c",d2b[i]);
				}
				for(i=0;i<K_size;i++){
					*(encSlice_p+i+2) = d2b[i];
				}
    		}
		else{   //dummy data-code (11111)
			for(i=0;i<K_size;i++){
				*(encSlice_p+i+2) = '1';
			}
		}

}

	/*printf("\nencoded slice is: ");
	for(i=0;i<K_size+2;i++){
		printf("%c",*(encSlice_p+i));
	}
	printf("\n"); */

	fwrite(encSlice_p,sizeof(char),C_size,fpw);
	fwrite("\n",sizeof(char),1,fpw);

return(0);

}

void *groupCopy(char *slice_p, struct target_symbols *ts_p, char *encSlice_p, int M_size, int N_size, int K_size, int C_size){

char groups[M_size][K_size], d2b[K_size];
int i=0, j=0, g=0, start=0, end=0, flag=0, index=0;

//take slice and divide it into M groups
for(i=0;i<M_size;i++){
	//printf("group %d is: ",i);
	for(j=0;j<K_size;j++){
		if(g<N_size){
			groups[i][j] = *(slice_p+g);
			g++;
		}
		else{
			groups[i][j] = 'X';  // wherever there is a X, we ignore these bits (non-perfect division of groups) 
		}	
		
		//printf("%c",groups[i][j]);
	}
	//printf("\n");
}

//find the index of the *first* target symbol
for(i=0;i<M_size;i++){
	for(j=0;j<K_size;j++){
		if(ts_p->ts == groups[i][j]){
			start = i;
			flag = 1;
			break;
		}
	}
	if (flag) break;
}

//find the index of the *last* target symbol
for(i=0;i<M_size;i++){
	for(j=0;j<K_size;j++){
		if(ts_p->ts == groups[i][j]){
			end = i;
			break;
		}
	}
}

//printf("start from group %d, last target symbol at group %d\n",start,end);

//start new slice - "dummy" data code
if (ts_p->ts == '1'){
	*encSlice_p = '0';
	*(encSlice_p+1) = '0';
}
else{
	*encSlice_p = '0';
	*(encSlice_p+1) = '1';
}

for(j=0;j<K_size;j++){
   	*(encSlice_p+j+2) = '1';
}

fwrite(encSlice_p,sizeof(char),C_size,fpw);
fwrite("\n",sizeof(char),1,fpw);

//group copy mode, control code "11", start from group x
*encSlice_p = '1';
*(encSlice_p+1) = '1';

dec2bin(start,d2b,K_size);

for(j=0;j<K_size;j++){
   	*(encSlice_p+j+2) = d2b[j];
}

fwrite(encSlice_p, sizeof(char), C_size, fpw);
fwrite("\n", sizeof(char), 1, fpw);

for(i=0;i<=end;i++){

	*encSlice_p = '1';
	*(encSlice_p+1) = '1';

	for(j=0;j<K_size;j++){
		*(encSlice_p+j+2) = groups[i][j];
	}

	fwrite(encSlice_p,sizeof(char),C_size,fpw);
	fwrite("\n",sizeof(char),1,fpw);
}

//printf("\n");
return(0);
}

void dec2bin(int index, char dc[], int K_size)
{
   int i = 0, j = 0;
   for(i = (K_size - 1); i >= 0; i--){
     if((index & (1 << i)) != 0){
       dc[j] = '1';
       j++;
     }else{
       dc[j] = '0';
       j++;
     }
   }
}

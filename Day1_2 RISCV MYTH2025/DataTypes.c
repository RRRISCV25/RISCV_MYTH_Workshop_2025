#include <stdio.h>
#include <math.h>
int main() {

unsigned int max1 = (unsigned int) (pow(2,32) -1);
unsigned int min1 = (unsigned int) (pow(2,32) * -1);
printf("Highest number represented by unsigned int is %u\n", max1);
printf("Lowest number represented by unsigned int is %u\n", min1);

int max2 = (int) (pow(2,32) -1);
int min2 = (int) (pow(2,32) * -1);
printf("Highest number represented by int is %d\n", max2);
printf("Lowest number represented by int is %d\n", min2);

unsigned long long int max3 = (unsigned long long int) (pow(2,64) -1);
unsigned long long int min3 = (unsigned long long int) (pow(2,64) * -1);
printf("Highest number represented by unsigned long long int is %llu\n", max3);
printf("Lowest number represented by unsigned long long int is %llu\n", min3);

long long int max4 = (long long int) (pow(2,64) -1);
long long int min4 = (long long int) (pow(2,64) * -1);
printf("Highest number represented by long long int is %lld\n", max4);
printf("Lowest number represented by long long int is %lld\n", min4);
return 0; 
}

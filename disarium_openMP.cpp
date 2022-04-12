#include <iostream>
#include <cmath>
#include <omp.h>
#include <string>

using namespace std;

const int SIZE = 1000000;

int input [SIZE];
bool output [SIZE];
int i, j;

bool isDisariumNumber(int number){
    string number_str = to_string(number);
    int size = number_str.length();
    int sum = 0;
    for(j=0;j<size;j++){
        sum += pow(int(number_str[j]-48),j+1);
    }
    return sum==number;
}

int main(int argc, char** argv)
{ 
    int num_thr = 4;
    if (argc >= 2)
    {
        num_thr = stoi(argv[1]);
    }
    double start;
    double end;
    start = omp_get_wtime();
    # pragma omp parallel for num_threads(num_thr) shared(input, output) private(i)
    for(i=0; i<SIZE; i++)
    {
        int number = i+1;
        input[i]=number;
        output[i]=isDisariumNumber(number);
    }
    end = omp_get_wtime();
    printf("Work took %f seconds\n", end - start);
}

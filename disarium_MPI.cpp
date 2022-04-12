#include <iostream>
#include <cmath>
#include <string>
#include <assert.h>
#include "mpi.h"

using namespace std;

const int SIZE = 1000000;

int *generate_input(){
    int *input = (int *)malloc(sizeof(int)* SIZE);
    assert(input != NULL);
    int m;
    for(m=0; m<SIZE; m++){
        int number = m+1;
        input[m]=number;
    }
    return input;
}

bool isDisariumNumber(int number){
    string number_str = to_string(number);
    int size = number_str.length();
    int sum = 0;
    int j;
    for(j=0;j<size;j++){
        sum += pow(int(number_str[j]-48),j+1);
    }
    return sum==number;
}

int main(int argc, char** argv)
{ 
    double start;
    double end;
    int rank, size, batch, rest, l,i;
    
    start = MPI_Wtime();
    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);
    batch=SIZE/size;
    rest = SIZE - (batch*size);

    int *input = NULL;
    if(rank==0){
        input = generate_input();
    }

    int *sub_input = (int *)malloc(sizeof(int) * batch);
    assert(sub_input != NULL);

    MPI_Scatter(input, batch, MPI_INT, sub_input, batch, MPI_INT, 0, MPI_COMM_WORLD);

    int *sub_output = (int *)malloc(sizeof(int) * batch);
    int *sub_outputs = NULL;
    if(rank==0){
        sub_outputs = (int *)malloc(sizeof(int) * batch * size);
        assert(sub_outputs != NULL);
    }
    
    for(l=0; l<batch; l++){
        sub_output[l]=isDisariumNumber(sub_input[l]);
    }

    MPI_Gather(sub_output, batch, MPI_INT, sub_outputs, batch, MPI_INT, 0, MPI_COMM_WORLD);

    if (rank == 0) {
        free(input);
        free(sub_outputs);
    }
    free(sub_input);

    MPI_Barrier(MPI_COMM_WORLD);
    MPI_Finalize();
    end = MPI_Wtime();
    printf("Work took %f seconds\n", end - start);
}

#include <chrono>
#include <iostream>
#include <assert.h>
#include <math.h> 

using namespace std;

const int SIZE = 1000000;

int *generate_input();
__global__ void _cuda_parallel_Disarium(int count, int* test_data, int* output);
__device__ bool _cuda_parallel_isDisariumNumber(int number);
__device__ int _cuda_parallel_countDigits(int number);
bool isDisariumNumber(int number);
int countDigits(int number);
void method(int* input, int threads_number, int blocks_number);

int main() {
    int threads_number_const = 1;
    int blocks_number = ceil(SIZE/threads_number_const) + 1;
    int* input = generate_input();
    int* output_sequential = (int *)malloc(sizeof(int) * SIZE);

    for(int i = 0; i < SIZE; i++){
        output_sequential[i]=isDisariumNumber(input[i]);
    }

    printf("Meastrements with changing threads number (1-30): \n");
    for(int i = threads_number_const; i < 31; i+=1){
        int blocks_number = ceil(SIZE/i) + 1;
        method(input, i, blocks_number);
    }
}

void method(int* input, int threads_number, int blocks_number){
    int* output_parallel = (int *)malloc(sizeof(int) * SIZE);
        
    // Copy data to device
    int* d_input;
    cudaMalloc(&d_input, SIZE * sizeof(int));
    int* d_output;
    cudaMalloc(&d_output, SIZE * sizeof(int));

    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    cudaMemcpy(d_input, input, SIZE * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(d_output, output_parallel, SIZE * sizeof(int), cudaMemcpyHostToDevice);

    cudaEventRecord(start);
    // Launch kernel
    _cuda_parallel_Disarium<<<blocks_number, threads_number>>>(SIZE, d_input, d_output);
    cudaEventRecord(stop);
        
    // Copy results back to device
    cudaDeviceSynchronize();
    cudaMemcpy(output_parallel, d_output, SIZE * sizeof(int), cudaMemcpyDeviceToHost);
    cudaEventSynchronize(stop);
    float milliseconds = 0;
    cudaEventElapsedTime(&milliseconds, start, stop);
    cudaFree(d_input);
    cudaFree(d_output);
    printf("time for %d threads: %lf ms\n", threads_number, milliseconds);
}

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

__global__ void _cuda_parallel_Disarium(int size, int* input, int* output) {

     int globalIdx = blockIdx.x * blockDim.x + threadIdx.x;

     while (globalIdx < size) {
        output[globalIdx] = _cuda_parallel_isDisariumNumber(input[globalIdx]);

        globalIdx +=  blockDim.x * gridDim.x;
        __syncthreads();
     }
}

__device__ bool _cuda_parallel_isDisariumNumber(int number){
    int count_digits = _cuda_parallel_countDigits(number);
    int sum = 0;
    int x = number;
    while (x)
    {
        int r = x%10;
        sum = sum + pow(r, count_digits--);
        x = x/10;
    }
    return (sum==number);
}

__device__ int _cuda_parallel_countDigits(int number)
{
    int count_digits = 0;
    int x = number;

    while (x)
    {
        x = x/10;
        count_digits++;
    }
    return count_digits;
}

bool isDisariumNumber(int number){
    int count_digits = countDigits(number);
    int sum = 0;
    int x = number;
    while (x)
    {
        int r = x%10;
        sum = sum + pow(r, count_digits--);
        x = x/10;
    }
    return sum==number;
}

int countDigits(int number)
{
    int count_digits = 0;
    int x = number;

    while (x)
    {
        x = x/10;
        count_digits++;
    }
    return count_digits;
}
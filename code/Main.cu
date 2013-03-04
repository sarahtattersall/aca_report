#include <cuda.h>
#include <cuda_runtime.h>
#include <iostream>
#include <vector>

#define N 10

__global__ void add(float *a, float *b, float *c) {
  c[blockIdx.x] = a[blockIdx.x] + b[blockIdx.x];
}

void cuda_check(cudaError_t status) {
  if (status != cudaSuccess) {
    std::cout << "Error could not allocate memory result " << status << std::endl;
    exit(1);
  }
}

int main(void) {
  std::vector<float> vec_a; 
  std::vector<float> vec_b; 
  std::vector<float> vec_c;

  float *a, *b, *c;
  float *d_a, *d_b, *d_c;
  int size = N * sizeof(int);

  cudaMalloc((void**)&d_a, size);
  cudaMalloc((void**)&d_b, size);
  cudaMalloc((void**)&d_c, size);
  
  cuda_check(cudaHostAlloc((void **)&a, size, cudaHostAllocPortable));
  cuda_check(cudaHostAlloc((void **)&b, size, cudaHostAllocPortable));
  cuda_check(cudaHostAlloc((void **)&c, size, cudaHostAllocPortable));
  
//  a = new int[N];
//  b = new int[N];
//  c = new int[N];

  for(int i = 0; i < N; ++i) {
    vec_a.push_back(i);
    vec_b.push_back(i);
    //a[i] = i;
    //b[i] = i;
  }
  
  memcpy(a, &vec_a[0], size);
  memcpy(b, &vec_b[0], size);


  cudaMemcpy(d_a, a, size, cudaMemcpyHostToDevice);
  cudaMemcpy(d_b, b, size, cudaMemcpyHostToDevice);

  add<<<N, 1>>>(d_a, d_b, d_c);

  cudaMemcpy(c, d_c, size, cudaMemcpyDeviceToHost);

  for(int i = 0; i <  N; ++i) {
    std::cout << c[i] << std::endl;
  }

  //free(a); free(b); free(c);
  cudaFreeHost(a); cudaFreeHost(b); cudaFreeHost(c);
  cudaFree(d_a); cudaFree(d_b); cudaFree(d_c);
  return 0;
}

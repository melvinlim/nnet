forwardTemplate="""
__global__ void forwardKernel(double *A,double *x,double *y,double *deriv){
	int i;
	double Cval=0;
	//int row = blockIdx.y * blockDim.y + threadIdx.y;
	//int col = blockIdx.x * blockDim.x + threadIdx.x;
	//int row = blockIdx.x * blockDim.x + threadIdx.x;
	const int row = threadIdx.x;
	for(i=0;i<%(NCOLS)s;i++){
		Cval+=A[row*%(NCOLS)s+i]*x[i];
	}
	double tmp=tanhf(Cval);
	y[row]=tmp;
	deriv[row]=1.0-(tmp*tmp);
}
"""
deltaTemplate="""
__global__ void deltaKernel(double *A,double *x,double *y,double *deriv){
	int i;
	double Cval=0;
	const int col = threadIdx.x;
	for(i=0;i<%(NCOLS)s;i++){
		Cval+=A[i*%(NCOLS)s+col]*y[i];
	}
	x[col]=deriv[col]*Cval;
}
"""
weightTemplate="""
__global__ void weightKernel(double *A,double *x,double *delta){
	int i;
	const int row = threadIdx.x;
	for(i=0;i<%(NCOLS)s;i++){
		A[row*%(NCOLS)s+i] -= x[i]*delta[row];
	}
}
"""
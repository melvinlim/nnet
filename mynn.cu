#include <cuda.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "matrixmul.cu"

#define LAYERS 3
#define L1M 2
#define L1N 6
#define L2M 6
#define L2N 40
#define L3M 40
#define L3N 2

#define RANDSCALING 10	//scale random weights to be from -0.1 to +0.1

const int nDim[LAYERS]={L1N,L2N,L3N};
const int mDim[LAYERS]={L1M,L2M,L3M};

struct Layer{
	Array *in;
	Matrix *M;
	Matrix *dW;
	Array *out;
	Array *error;
};
struct Net{
	Layer **L;
	int size;
};
void PRINTMATRIX(Matrix *M){
	int i,j;
	for(i=0;i<M->height;i++){
		for(j=0;j<M->width;j++){
			printf("[%i,%i]%.09f\t",i,j,M->elements[i*M->stride+j]);
		}
	}
	printf("\n");
}
void PRINTARRAY(Array *A){
	int i;
	float *x;
	int sz=A->len;
	x=A->el;
	for(i=0;i<sz;i++){
		printf("[%i]%.02f\t",i,*x++);
	}
	printf("\n");
}
void randMatrix(Matrix *M){
	int i,j;
	for(i=0;i<M->height;i++){
		for(j=0;j<M->width;j++){
			M->elements[i*M->stride+j]=
			(random()-(RAND_MAX/2))*2.0/((float)RAND_MAX)/((float)RANDSCALING);
		}
	}
}
void randArray(Array *A){
	int i;
	for(i=0;i<A->len;i++){
		A->el[i]=
		(random()-(RAND_MAX/2))*2.0/((float)RAND_MAX)/((float)RANDSCALING);
	}
}
void nnRand(Net *N){
	Matrix *pM;
	int i;
	int n=N->size;
	for(i=0;i<n;i++){
		pM=N->L[i]->M;
		randMatrix(pM);
	}
}
Array *CREATEARRAY(const float *x,int n){
	Array *p=(Array *)malloc(sizeof(Array));
	p->len=n;
	p->el=(float *)malloc(n*sizeof(float));
	if(x){
		memcpy(p->el,x,n*sizeof(float));
	}
	return(p);
}
void nnInsert(Net *N,Array *x){
	memcpy(N->L[0]->in->el,x->el,x->len*sizeof(float));
	N->L[0]->in->len=x->len;	
}
Array *nnForward(Net *N){
	int i;
	for(i=0;i<LAYERS;i++){
printf("***********%d\n",i);
		PRINTARRAY(N->L[i]->in);
		PRINTARRAY(N->L[i]->out);
		//MatMul(*N->L[i]->M,*N->L[i]->in,*N->L[i]->out);
		MatMul(*N->L[i]->M,*N->L[i]->in,*N->L[i]->out,*N->L[i]->error);
		PRINTARRAY(N->L[i]->in);
		PRINTARRAY(N->L[i]->out);
	}
	return N->L[LAYERS-1]->out;
}
void nnError(Array *err,const Array *y0,const Array *y){
	int i;
	int n=y0->len;
	float ret=0;
	for(i=0;i<n;i++){
		//err[i]=fabs(y0->el[i]-y->el[i]);
		err->el[i]=(y0->el[i]-y->el[i]);
	}
}
float nnTotalError(const Array *y0,const Array *y){
	int i;
	int n=y0->len;
	float ret=0;
	for(i=0;i<n;i++){
		ret+=fabs(y0->el[i]-y->el[i]);
		ret*=ret;
	}
	return(ret/2.0);
}
const float ex1[L1M]={-1,-1};
const float ex2[L1M]={-1,+1};
const float ex3[L1M]={+1,-1};
const float ex4[L1M]={+1,+1};
const float ans1[L3N]={-1,+1};
const float ans2[L3N]={+1,-1};
const float ans3[L3N]={+1,-1};
const float ans4[L3N]={-1,+1};
int main(){
	int i,j,k;
	Net *net;
	net=(Net *)malloc(sizeof(Net));
	net->L=(Layer **)malloc(LAYERS*sizeof(Layer *));
	net->size=LAYERS;
	net->L[0]=(Layer *)malloc(sizeof(Layer));
	net->L[0]->in=(Array *)malloc(sizeof(Array));
	net->L[0]->out=(Array *)malloc(sizeof(Array));
	net->L[0]->error=(Array *)malloc(sizeof(Array));
	net->L[0]->in->len=L1M;
	net->L[0]->in->el=(float *)malloc(L1N*sizeof(float));
	net->L[0]->out->len=L1N;
	net->L[0]->out->el=(float *)malloc(L1M*sizeof(float));
	net->L[0]->error->len=L1N;
	net->L[0]->error->el=(float *)malloc(L1M*sizeof(float));
	for(i=0;i<LAYERS;i++){
		if(i>0){
			net->L[i]=(Layer *)malloc(sizeof(Layer));
			net->L[i]->in=net->L[i-1]->out;
			net->L[i]->out=(Array *)malloc(sizeof(Array));
			net->L[i]->error=(Array *)malloc(sizeof(Array));
			net->L[i]->in->len=mDim[i];
			net->L[i]->in->el=(float *)malloc(nDim[i]*sizeof(float));
			net->L[i]->out->len=nDim[i];
			net->L[i]->out->el=(float *)malloc(mDim[i]*sizeof(float));
			net->L[i]->error->len=nDim[i];
			net->L[i]->error->el=(float *)malloc(mDim[i]*sizeof(float));
		}
//		net->L[i]=(Layer *)malloc(sizeof(Layer));
		net->L[i]->M=(Matrix *)malloc(sizeof(Matrix));
		memcpy(&net->L[i]->M->height,&nDim[i],sizeof(int));
		memcpy(&net->L[i]->M->width,&mDim[i],sizeof(int));
		memcpy(&net->L[i]->M->stride,&mDim[i],sizeof(int));
		net->L[i]->M->elements=(float *)malloc(nDim[i]*mDim[i]*sizeof(float));
		net->L[i]->dW=(Matrix *)malloc(sizeof(Matrix));
		memcpy(&net->L[i]->dW->height,&nDim[i],sizeof(int));
		memcpy(&net->L[i]->dW->width,&mDim[i],sizeof(int));
		memcpy(&net->L[i]->dW->stride,&mDim[i],sizeof(int));
		net->L[i]->dW->elements=(float *)malloc(nDim[i]*mDim[i]*sizeof(float));
	}
	//Matrix *pM=net->L[0]->M;
	//PRINTMATRIX(net->L[0]->M);
	nnRand(net);
	for(i=0;i<LAYERS;i++){
		PRINTMATRIX(net->L[i]->M);
	}
	//PRINTMATRIX(net->L[0]->M);

	Array *p1,*p2,*p3,*p4,*ret;
	p1=CREATEARRAY(ex1,L1M);
	p2=CREATEARRAY(ex2,L1M);
	p3=CREATEARRAY(ex3,L1M);
	p4=CREATEARRAY(ex4,L1M);
	Array *pAns1,*pAns2,*pAns3,*pAns4;
	pAns1=CREATEARRAY(ans1,L3N);
	pAns2=CREATEARRAY(ans2,L3N);
	pAns3=CREATEARRAY(ans3,L3N);
	pAns4=CREATEARRAY(ans4,L3N);

	Array *pError;
	pError=CREATEARRAY(ans4,L3N);

	ret=CREATEARRAY(0,L3N);

	nnInsert(net,p1);
	ret=nnForward(net);
	PRINTARRAY(ret);

	nnError(pError,ret,pAns1);
	float err=nnTotalError(ret,pAns1);
	printf("err:%f\n",err);
	PRINTMATRIX(net->L[2]->M);
	NNBackProp0(*net->L[LAYERS-1]->dW,*net->L[LAYERS-1]->M,*net->L[LAYERS-1]->in,*net->L[LAYERS-1]->out,*net->L[LAYERS-1]->error);
	PRINTARRAY(net->L[LAYERS-1]->out);
	PRINTARRAY(net->L[LAYERS-1]->error);
	PRINTMATRIX(net->L[2]->dW);
}

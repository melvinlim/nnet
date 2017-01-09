#ifndef _MYNN
#define _MYNN

#include <cuda.h>
#include <math.h>
#include <time.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <vector>

using namespace std;

#include "types.h"
#include "libnn.h"

#define NINPUTS (2)
#define NOUTPUTS (2)

#define L1M (NINPUTS)
#define L1N (7)
#define L2M (7)
#define L2N (NOUTPUTS)

const int nDim[LAYERS]={L1N,L2N};//,L3N};
const int mDim[LAYERS]={L1M,L2M};//,L3M};
//const int nDim[LAYERS]={L1N,L2N,L3N};
//const int mDim[LAYERS]={L1M,L2M,L3M};

void PRINTINFO(const Array<double> &pIn,const Array<double> &answer,const Array<double> &pOut,const Array<double> &pErr){
	printf("in:[%.0f,%.0f] out:[%f,%f] targ:[%.0f,%.0f] err:[%f,%f]\n",
	pIn(0),pIn(1),
	answer(0),answer(1),
	pOut(0),pOut(1),
	pErr(0),pErr(1)
	);
}
double ex1[NINPUTS]={-1,-1};
double ex2[NINPUTS]={-1,+1};
double ex3[NINPUTS]={+1,-1};
double ex4[NINPUTS]={+1,+1};
double ans1[NOUTPUTS]={-1,+1};
double ans2[NOUTPUTS]={+1,-1};
double ans3[NOUTPUTS]={+1,-1};
double ans4[NOUTPUTS]={-1,+1};
//const double ans1[NOUTPUTS]={-1,+1};
//const double ans2[NOUTPUTS]={+1,-1};
//const double ans3[NOUTPUTS]={+1,-1};
//const double ans4[NOUTPUTS]={+1,-1};
int main(){
	int i;
	srand(time(0));
	Net *net;
	net=new Net(LAYERS);
	for(i=0;i<LAYERS;i++){
		net->insertLayer(i,nDim[i],mDim[i]);
	}

	net->rand();

	Array<double> arr1=Array<double>(10);
	Array<double> arr2=Array<double>();
	arr2.resize(10);
	for(i=0;i<10;i++){
		arr1(i)=i;
		arr2(i)=i+2;
	}
	arr1.print();
	arr2.print();
	arr1=arr1+arr2;
	arr1.print();
	//return 0;

	vector<Array<double> > pIn,pOut;
	pIn.resize(4);
	pIn[0]=Array<double>(ex1,NINPUTS);
	pIn[1]=Array<double>(ex2,NINPUTS);
	pIn[2]=Array<double>(ex3,NINPUTS);
	pIn[3]=Array<double>(ex4,NINPUTS);
	for(Array<double> x:pIn)
		x.print();
	pOut.resize(4);
	pOut[0]=Array<double>(ans1,NOUTPUTS);
	pOut[1]=Array<double>(ans2,NOUTPUTS);
	pOut[2]=Array<double>(ans3,NOUTPUTS);
	pOut[3]=Array<double>(ans4,NOUTPUTS);
	for(Array<double> x:pOut)
		x.print();
	int tmpvar;
	for(i=0;i<EPOCHS;i++){
		tmpvar=rand()%4;
		net->train(pIn[tmpvar],pOut[tmpvar]);
		PRINTINFO(pIn[tmpvar],net->answer,pOut[tmpvar],net->error);
	}
}

#endif

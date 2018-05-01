#include"net.h"

Net::Net(int n,int outputs){
	srandom(time(0));
	this->n=n;
	L=new Layer *[n];
	error=new Array(outputs);
	response=0;
}
Net::~Net(){
	int i;
	if(L){
		for(i=0;i<n;i++){
			delete L[i];
		}
	}
	delete[] L;
	delete error;
}
void Net::insertLayer(int i,Matrix *mat){
	L[i]=new Layer(mat);
}
void Net::insertLayer(int i,int m,int n){
	L[i]=new Layer(m,n);
}
void Net::forward(const Array *x){
	L[0]->forward(x);
	L[1]->forward(L[0]->out);
	response=L[1]->out;
}
inline void Net::backward(const Array *input){
	L[1]->outputDelta(error);
	L[0]->hiddenDelta(L[1]->mat,L[1]->delta);
/*
	L[1]->directUpdateWeights(L[0]->out);
	L[0]->directUpdateWeights(input);
*/
}
void Net::randomize(){
	int i;
	for(i=0;i<n;i++){
		L[i]->randomize();
	}
}
void Net::print(){
	int i;
	for(i=0;i<n;i++){
		L[i]->mat->print();
	}
}
inline void Net::updateBatchCorrections(const Array *input){
	L[1]->saveErrors(L[0]->out);
	L[0]->saveErrors(input);
}
void Net::updateWeights(){
	L[1]->updateWeights();
	L[0]->updateWeights();
}
Array *Net::trainOnce(const Array *x,const Array *y){
	forward(x);
	updateError(y);
	backward(x);
	return(error);
}
Array *Net::trainBatch(const Array *x,const Array *y){
	forward(x);
	updateError(y);
	backward(x);
	updateBatchCorrections(x);
	return(error);
}
void Net::updateError(const Array *yTarget){
	int i;
	for(i=0;i<yTarget->n;i++){
		error->item[i]=yTarget->item[i]-response->item[i];
	}
}
SingleHidden::SingleHidden(int inputs,int hidden,int outputs):Net(2,outputs){
	int L1M=(inputs+1);
	int L1N=(hidden);
	int L2M=(hidden+1);
	int L2N=(outputs);
	insertLayer(0,L1M,L1N);
	insertLayer(1,L2M,L2N);
	randomize();
}

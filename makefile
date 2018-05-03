CXX =				g++
CXXFLAGS =	-std=c++11 -Wall -Wextra -pedantic -g -c
LFLAGS =		-std=c++11 -Wall -Wextra -pedantic -g -o mynn
OBJECTS =		main.o layer.o net.o data.o idx.o mnist.o xor.o linear.o
mynn:		$(OBJECTS)
	$(CXX) $(LFLAGS) $(OBJECTS)
main:			main.cpp types.h defs.h
	$(CXX) $(CXXFLAGS) main.cpp
layer:		layer.cpp defs.h
	$(CXX) $(CXXFLAGS) layer.cpp
net:			net.cpp defs.h
	$(CXX) $(CXXFLAGS) net.cpp
data:			data.cpp defs.h
	$(CXX) $(CXXFLAGS) data.cpp
idx:			idx.cpp defs.h
	$(CXX) $(CXXFLAGS) idx.cpp
mnist:		mnist.cpp defs.h
	$(CXX) $(CXXFLAGS) mnist.cpp
xor:			xor.cpp defs.h
	$(CXX) $(CXXFLAGS) xor.cpp
linear:		linear.cpp defs.h
	$(CXX) $(CXXFLAGS) linear.cpp
clean:
	rm -f mynn *.o a.out

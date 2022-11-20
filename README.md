# Cardinal C++ Container Based Compiler

The purpose of this container is to provide a fresh environment to compile the Cardinal C++ Server Application for use within debugging and for production use.

This docker image enables the quick compilation of Cardinal C++ and produces a binary artifact designed to run in the same version of Ubuntu as it was compiled in.

Cardinal C++: https://github.com/sarahjabado/cardinal-cpp

Docker Hub: https://hub.docker.com/r/sarahjabado/cardinal-compiler

### Usage
```
docker run -v `pwd`:/app:rw -it sarahjabado/cardinal-compiler:latest
```
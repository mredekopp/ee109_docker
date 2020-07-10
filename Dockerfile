FROM ubuntu:18.04

# Scripts and configuration
RUN mkdir -p /usr/local/bin/
COPY files/local/avrdude /usr/local/bin/avrdude
RUN chmod 755 /usr/local/bin/avrdude
RUN curl http://ee.usc.edu/~redekopp/ee109/avr.tar.gz -o /tmp/avr.tar.gz
WORKDIR /usr/local
RUN tar xfz /tmp/avr.tar.gz
#RUN sudo usermod -a -G dialout user_name
COPY files/root/* /root/


# Make sure line endings are Unix
# This changes nothing if core.autocrlf is set to input
RUN sed -i 's/\r$//' /root/.bashrc

#RUN apt-get update && apt-get install -y \
#    clang \
#    g++ \
#    make \
#    gdb \
#    llvm \
#    cmake
RUN apt-get update && apt-get install -y \
    make \
    cmake

# Grading
RUN apt-get install -y \
    git
    
VOLUME ["/work"]
WORKDIR /work

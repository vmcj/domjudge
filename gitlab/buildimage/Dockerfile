FROM domjudge/gitlabci:2.1

ARG DJ_SRC
ARG DJ_ETC

ENV DEBIAN_FRONTEND=noninteractive

# Use the current PR sources as if its a released version
RUN mkdir $DJ_SRC
COPY domjudge $DJ_SRC/
RUN chown -R domjudge $DJ_SRC

WORKDIR $DJ_SRC
RUN sudo -u domjudge ./gitlab/buildimage/configure.sh

# Expose HTTP port
EXPOSE 80

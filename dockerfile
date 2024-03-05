FROM ubuntu:latest

RUN apt-get update && apt-get install -y openssh-server sudo net-tools
RUN mkdir /var/run/sshd
RUN useradd -m -s /bin/bash alex && echo 'alex:12345' | chpasswd && usermod -aG sudo alex
RUN mkdir -p /home/alex/.ssh
#COPY jenkins-hillel.pub /home/alex/.ssh/authorized_keys
#RUN chown -R alex:alex /home/alex/.ssh && \
	#chmod 700 /home/alex/.ssh && \
	#chmod 600 /home/alex/.ssh/authorized_keys
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
RUN sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_confi


CMD ["/usr/sbin/sshd", "-D"]


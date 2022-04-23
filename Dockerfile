FROM tomcat:8.0-alpine
COPY /home/ansible/webapp.war  /usr/local/tomcat/webapps
ENV DEVOPS=money
ENV MONEY=DEVOPS_AWS_LINUX
RUN mkdir /volumes
VOLUME /volume

FROM tomcat:8.0-alpine
COPY ./webapp.war  /usr/local/tomcat/webapps

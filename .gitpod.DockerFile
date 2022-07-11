FROM gitpod/workspace-full:latest

ARG YB_VERSION=2.15.0.0
ARG YB_BUILD=b11-darwin-x86_64
ARG YB_PATH=/usr/local/yugabyte

ARG ROLE=gitpod

USER root
RUN mkdir -p $YB_PATH \
  && mkdir -p /var/ybdp
RUN chown -R $ROLE:$ROLE /var/ybdp \
  && chown -R $ROLE:$ROLE /usr/local/yugabyte

USER $ROLE
RUN curl -sSLo ./yugabyte.tar.gzhttps://downloads.yugabyte.com/releases/${YB_VERSION}/yugabyte-${YB_VERSION}-${ YB_BUILD}.tar.gz \
  && tar -xvf yugabyte.tar.gz -C $YB_PATH --strip-components=1 \
  && chmod +x $YB_PATH/bin/* \
  && rm ./yugabyte.tar.gz
RUN ["/usr/local/yugabyte/bin/post_install.sh"]
RUN echo "\n# yugabytedb executable path" >> ~/.bashrc
RUN echo "export PATH=\$PATH:$YB_PATH/bin/" >> ~/.bashrc

ENV HOST_LB1=127.0.0.1
ENV HOST_LB2=127.0.0.2
ENV HOST_LB3=127.0.0.3
ENV STORE=/var/ybdp
ENV YSQL_PORT=5433
ENV YCQL_PORT=9042
ENV WEB_PORT=7000
ENV TSERVER_WEB_PORT=8200
ENV MASTER_WEB_PORT=7000
ENV YCQL_API_PORT=12000
ENV YSQL_API_PORT=13000
ENV MY_SUDO=psswrd
ENV MY_DB_NAME=db_ybu
ENV MY_YB_PATH=/usr/local/yugabyte/
ENV MY_DATA_DML_FILE=world_dml.sql
ENV MY_DATA_DDL_FILE=world_ddl.sql
ENV MY_UTIL_FUNCTIONS_FILE=util_functions.sql
ENV MY_UTIL_YBTSERVER_METRICS_FILE=util_ybtserver_metrics.sql


EXPOSE ${YSQL_PORT} ${YCQL_PORT} ${WEB_PORT} ${TSERVER_WEB_PORT} ${YSQL_API_PORT} ${YCQL_API_PORT}

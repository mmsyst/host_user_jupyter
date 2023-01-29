FROM jupyter/minimal-notebook:python-3.8.8
USER root
COPY ./scripts/run.sh /tmp/run.sh
COPY ./tmp/entrypoint.sh /tmp/entrypoint.sh
RUN chmod 0777 /tmp/run.sh && chmod 0777 /tmp/entrypoint.sh
EXPOSE 8888
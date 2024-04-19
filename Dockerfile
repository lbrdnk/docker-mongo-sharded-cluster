FROM mongo:6

RUN mkdir -p /data/dbshard
RUN mkdir -p /data/dbcfg

# Setup script
WORKDIR /cluster
COPY start.sh ./start.sh

CMD ["./start.sh"]
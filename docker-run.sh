docker stop dmd-gui || true && docker rm dmd-gui || true
docker build . -f Dockerfile -t f18-dmd-gui:latest
docker run -d --name dmd-gui -p 8050:8050 f18-dmd-gui:latest

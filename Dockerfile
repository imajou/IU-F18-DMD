FROM    python:slim

WORKDIR /app

COPY    requirements.txt .
COPY    main.py .
COPY    queries/ queries/

RUN     pip install --upgrade pip; \
        pip install -r requirements.txt

EXPOSE  8050

ENV     HOST_ADDRESS=0.0.0.0
ENV     HOST_PORT=8050

ENTRYPOINT python3 /app/main.py

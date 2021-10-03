FROM python:3.9.6
WORKDIR /app
COPY requirements.txt requirements.txt
RUN pip3 install -r requirements.txt
COPY update-db.py update-db.py
CMD [ "python3", "update-db.py"]
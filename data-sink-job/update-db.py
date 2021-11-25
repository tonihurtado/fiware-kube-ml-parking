import pycurl
import pymongo
import json
from io import BytesIO
from datetime import datetime

rs_url = "mongodb://mongodb-0.mongodb-svc.tfm.svc.cluster.local:27017,mongodb-1.mongodb-svc.tfm.svc.cluster.local:27017,mongodb-2.mongodb-svc.tfm.svc.cluster.local:27017/?replicaSet=MainRepSet"
src_url = "https://datosabiertos.malaga.eu/recursos/aparcamientos/ocupappublicosmun/ocupappublicosmunfiware.json"
collection_name = "parking"
dt = datetime.now().strftime("%Y-%m-%dT%H%M")

def addDate(it):
    it['availableSpotNumber']['metadata']['timestamp']['value'] = datetime.now().strftime("%Y-%m-%dT%H%M")
    return it

def readSource(url):
    b_obj = BytesIO()
    crl = pycurl.Curl()

    crl.setopt(crl.URL, url)
    crl.setopt(crl.WRITEDATA, b_obj)
    crl.perform()
    crl.close()

    return json.loads(b_obj.getvalue().decode('utf8'))

print("Intializing mongodb connection 🇲🇳")

myclient = pymongo.MongoClient(rs_url)
db = myclient.tfm
collection = db[collection_name]

print("Collecting data from source... 🌤️")

data = readSource(src_url)

print("Updating data with the current datetime {} 📅".format(datetime.now().strftime("%Y-%m-%dT%H%M")))

data_wdate = list(map(addDate,data))

print("Inserting new files to database... 🍵")

collection.insert_many(data_wdate)

print("Done 🏡")
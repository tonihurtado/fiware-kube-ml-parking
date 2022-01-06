# Fiware-kube-ml-parking

[![N|Solid](https://www.etsit.upm.es/fileadmin/documentos/laescuela/la_escuela/galerias_fotograficas/Servicios/generales/logos/MANCHETA/MANCHETA.png)](https://www.etsit.upm.es)

### TFT MUIRST UPM
*Developed by Jose Antonio Hurtado Morón*

## How to run
I've developed a script to automate the creation process, but stills we need some requirements.
#### Requirements
- Have Minikube installed: [install minikube](https://v1-18.docs.kubernetes.io/es/docs/tasks/tools/install-minikube/)
- Have kubectl installed and configured: [install kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/)

#### Run minikube local cluster
All you need is Docker (or similarly compatible) container or a Virtual Machine environment, and Kubernetes is a single command away: 
```
minikube start
```
#### Execute cluster deployment script
Now you can run the `create_cluster.sh` script to automatically deploy all the components and configurations to minikube
```
chmod +x create_cluster.sh
./create_cluster.sh
```
## About the project

The increasing adoption of **Open Data** by public and private entities opens the door to new projects and developments that make use of these huge amount of data for multiple applications in several fields and contexts. [**FiWare**](https://github.com/Fiware) is an open platform focused on the management and consumption of data for Smart Cities, and through its framework of development tools, allows us to integrate these unstructured open  data in large-scale systems.

Deploying and administrating these applications and systems at production level, even for seemingly simple configurations, can introduce huge barriers of complexity for developers and data scientists, both because of the amount of real-time data to be processed and the increasing complexity that these systems can acquire when scaling them out. **Kubernetes** and **Spark**, among other technologies, provide us with this layer of abstraction when thinking about these large-scale systems, and make it easier and faster to process and maintain them.

The main goal of this project is to show the potential of these technologies both separately and together, allowing us to automate and improve the deployment of this kind of environments. To do so, we will design a use case that involves the whole process: a web application for user interaction, a cloud architecture based on micro-services and a prediction model trained with open data, collected in real time from a public data source, that will allow the user to obtain a prediction of the occupancy of the public parking spaces in his city on a given date and time.

#### Reference sites
| Resource | URL |
| ------ | ------ |
| LaTex TFT Memory | https://github.com/tonihurtado/tfm-tex |
| Datos Abiertos Málaga | https://datosabiertos.malaga.eu/dataset/6774b754-c0f7-4bf8-8c55-84a5d747084a/resource/0dcf7abd-26b4-42c8-af19-4992f1ee60c6 |

## Others
TO-DO

## License

kubectl port-forward -n tfm $(kubectl get pods -n tfm -l spark-role=driver -o jsonpath="{.items[0].metadata.name}") 4040:4040

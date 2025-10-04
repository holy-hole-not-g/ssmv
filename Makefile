up:
	@echo "Применение манифестов Kubernetes..."
	kubectl apply -f k8s/secretstore.yaml
	kubectl apply -f k8s/externalsecret.yaml
	@echo "Секреты должны быть доступны. Проверьте: kubectl get secrets -n default myapp-db-secret"

status:
	@echo "Проверка статуса ESO..."
	kubectl get pods -n external-secrets

describe:
	@echo "Описание ExternalSecret..."
	kubectl describe externalsecret myapp-db-secret -n default

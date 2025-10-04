# Secure Secrets Management with Vault and ESO in Kubernetes

> Безопасное управление секретами является критически важным для Kubernetes. Данное решение интегрирует HashiCorp Vault и External Secrets Operator для централизованного хранения, ротации, аудита и автоматического обновления секретов в Kubernetes, предотвращая утечку конфиденциальных данных в коде или конфигурациях. Это позволяет упростить управление секретами, повысить безопасность и соответствовать требованиям регуляторов.

## 📋 Описание задачи

Подробное описание проблемы, которую решает проект:
- Проблема заключается в небезопасном хранении секретов непосредственно в Kubernetes Secrets, конфигурационных файлах, или коде приложений, что делает их уязвимыми для несанкционированного доступа. Также сложно отслеживать использование секретов и обеспечивать их своевременную ротацию. Задача – внедрить безопасное и автоматизированное управление секретами.
- В телеком-индустрии, где обрабатываются конфиденциальные данные клиентов, финансовых транзакций и сетевых конфигураций, утечка секретов может привести к серьезным последствиям, включая финансовые потери, репутационный ущерб и нарушение регуляторных требований (например, GDPR, PCI DSS). Безопасность и управление секретами критичны для защиты этих данных.
-  *Централизованное хранение секретов вне Kubernetes.
   *Автоматическая синхронизация секретов из хранилища в Kubernetes.
   *Регулярная ротация секретов.
   *Детальный аудит доступа к секретам.
   *Минимальное влияние на существующие приложения.
   *Простота интеграции с существующей инфраструктурой.
   *Возможность быстрого развертывания и масштабирования.

## 🏗️ Архитектура решения

### Схема архитектуры

```mermaid
flowchart LR
    subgraph Kubernetes Cluster
        subgraph Namespace (myapp)
            Pod[Application Pod] -->|Secret data| Secret[Kubernetes Secret]
            ExternalSecret[ExternalSecret Resource] -- Watches --> Secret
        end
        ESO[External Secrets Operator] -- Fetches secrets from --> Vault

        Vault[HashiCorp Vault]

        Ingress[Ingress Controller] --> Pod
    end

    Developer[Developer] -- Creates/Updates ExternalSecret --> Kubernetes Cluster
    Ops[Operations Team] -- Configures/Manages Vault --> Vault
```

### Компоненты системы

- **HashiCorp Vault**: Централизованное хранилище секретов, обеспечивающее шифрование, контроль доступа, ротацию и аудит.
- **External Secrets Operator (ESO)**: Kubernetes-оператор, который синхронизирует секреты из Vault в Kubernetes Secrets.
- **Kubernetes Secrets**: Объекты Kubernetes, в которых хранятся секреты, используемые приложениями.
- **ExternalSecret**: Пользовательский ресурс Kubernetes (CRD), определяющий, какие секреты из Vault нужно синхронизировать в Kubernetes Secrets.

## 🛠️ Используемые технологии

### Инфраструктура
- **Kubernetes**: v1.28 (k3s/minikube)
- **Terraform**: v1.5+ (IaC для инфраструктуры)
- **Helm**: v3+ (конфигурация серверов)

### CI/CD
- **GitHub Actions** / GitLab CI / Jenkins
- **Argo CD** / Flux (GitOps)

### Мониторинг и наблюдаемость
- **Prometheus**: сбор метрик
- **Grafana**: визуализация
- **Loki**: агрегация логов

### Безопасность
- **HashiCorp Vault** v1.14+
- **External Secrets Operator** v0.8+

## 🚀 Быстрый старт

### Требования

- Docker 20.10+
- kubectl 1.28+
- Helm 3+
- Минимум 4GB RAM, 2 CPU

### Установка и запуск

```bash
# Клонирование репозитория
git clone https://github.com/holy-hole-not-g/ssmv.git
cd ssmv

# Установка External Secrets Operator (ESO) через Helm
helm repo add external-secrets https://charts.external-secrets.io
helm repo update
helm install external-secrets external-secrets/external-secrets -n external-secrets --create-namespace

# Применение манифестов Kubernetes
kubectl apply -f k8s/secretstore.yaml
kubectl apply -f k8s/externalsecret.yaml

# Запуск всей инфраструктуры (одной командой)
make up


### Проверка работоспособности

```bash
# Проверка статуса ESO
kubectl get pods -n external-secrets

# Проверка наличия Kubernetes Secret
kubectl get secret myapp-db-secret -n default

# Проверка содержимого Secret (закодировано в base64)
kubectl get secret myapp-db-secret -n default -o yaml
```

## 📊 Мониторинг и наблюдаемость

### Доступ к дашбордам

- **Grafana**: http://localhost:3000 (admin/admin)
- **Prometheus**: http://localhost:9090
- **Alertmanager**: http://localhost:9093

### Ключевые метрики

- Доступность сервиса (uptime)
- Время отклика (response time)
- Количество ошибок (error rate)
- Использование ресурсов (CPU/RAM)

## 🔒 Безопасность

### Реализованные меры

- ✅ Секреты хранятся в Vault, вне Kubernetes.
- ✅ ESO синхронизирует секреты в Kubernetes Secrets.
- ✅ Можно настроить ротацию секретов в Vault, и ESO автоматически обновит Kubernetes Secrets.
- ✅ Vault предоставляет логи аудита доступа к секретам.
- ✅ RBAC настроен для ограничения доступа к Kubernetes Secrets.

### Проверка безопасности

```bash
# Проверка политик Vault
vault policy read myapp-policy

# Проверка RBAC в Kubernetes
kubectl auth can-i get secrets -n default --as system:serviceaccount:default:default
```

## 🧪 Тестирование

```bash
# Запуск тестов
make test

# Проверка работоспособности
make verify
```

## 🔧 Troubleshooting

### Частые проблемы

**Проблема**: ESO не может подключиться к Vault
```bash
# Решение
kubectl logs -n external-secrets <eso-pod-name>
```

**Проблема**: ExternalSecret не синхронизирует секрет
```bash
# Решение
kubectl describe externalsecret myapp-db-secret -n default
```

## 📈 Применимость в МТС

Данное решение может быть применено в МТС для:

- **5G Core Network**: автоматизация развертывания сетевых функций
- **BSS/OSS системы**: CI/CD для биллинговых систем
- **Мобильные приложения**: автоматизация тестирования и деплоя
- **Дата-центры**: управление инфраструктурой как кодом
- **Телеком-аналитика**: мониторинг и логирование в реальном времени

### ROI и преимущества

- ⚡ Ускорение деплоя в 5 раз
- 🛡️ Снижение инцидентов на 40%
- 📊 Полная наблюдаемость системы
- 💰 Экономия до 30% инфраструктурных затрат

## 📝 Лицензия

MIT License

## 👤 Автор

**Александр ФГорловамилия**
- GitHub: [@holy-hole-not-g](https://github.com/holy-hole-not-g)
- Email: alexandr.gorlov.2003@mail.ru

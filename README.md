## NodePort List

  | Name                   | Port  |
  |------------------------|-------|
  | Kube Dashboard (HTTPS) | 31100 |
  | Kube Dashboard (HTTP)  | 31101 |
  | Grafana                | 31110 |
  | Loki                   | 31111 |
  | Minio UI               | 31120 |
  | Minio API              | 31121 |
  | Gitea HTTP             | 31130 |
  | Gitea SSH              | 31131 |
  | Joxit UI               | 31140 |
  | DockerRegistry local   | 31141 |

## Summary Helm chart
Add Helm chart repo
```
helm repo add grafana https://grafana.github.io/helm-charts
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add minio https://charts.min.io/
helm repo add gitea-charts https://dl.gitea.com/charts/
helm repo add joxit https://helm.joxit.dev
helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo add kiali https://kiali.org/helm-charts
helm repo add argo https://argoproj.github.io/argo-helm

```

Pull chart to local
```
helm pull kubernetes-dashboard/kubernetes-dashboard --version 7.14.0 --untar -d helm-charts
helm pull prometheus-community/kube-prometheus-stack --version 80.0.0 --untar -d helm-charts
helm pull minio/minio --version 5.4.0 --untar -d helm-charts
helm pull grafana/loki --version 6.46.0 --untar -d helm-charts
helm pull grafana/alloy --version 1.5.0 --untar -d helm-charts
helm pull gitea-charts/gitea --version 12.4.0 --untar -d helm-charts
helm pull gitea-charts/actions --version 0.0.2 --untar -d helm-charts
helm pull joxit/docker-registry-ui --version 1.1.3 --untar -d helm-charts
helm pull istio/base --version 1.28.2 --untar -d helm-charts
helm pull istio/istiod --version 1.28.2 --untar -d helm-charts
helm pull kiali/kiali-operator --version 2.20.0 --untar -d helm-charts
```

Upgrade dependency
```
helm dependency update helm-charts/kubernetes-dashboard
helm dependency update helm-charts/kube-prometheus-stack
helm dependency update helm-charts/minio
helm dependency update helm-charts/loki
helm dependency update helm-charts/alloy
helm dependency update helm-charts/gitea
helm dependency update helm-charts/docker-registry-ui
helm dependency update helm-charts/kiali-operator
```

Install Helm
```
  helm upgrade --install kubernetes-dashboard helm-charts/kubernetes-dashboard --create-namespace --namespace kubernetes-dashboard -f helm-values/kube-dashboard-values.yaml
  helm upgrade --install monitoring helm-charts/kube-prometheus-stack --namespace monitoring --create-namespace -f helm-values/metrics-values.yaml
  helm upgrade --install minio helm-charts/minio --namespace minio --create-namespace -f helm-values/minio-values.yaml
  helm upgrade --install loki helm-charts/loki --namespace monitoring -f helm-values/loki-values.yaml
  helm upgrade --install alloy helm-charts/alloy --namespace monitoring -f helm-values/alloy-values.yaml
  helm upgrade --install gitea helm-charts/gitea --namespace git --create-namespace -f helm-values/gitea-values.yaml
  helm upgrade --install container-registry helm-charts/docker-registry-ui --namespace container-registry --create-namespace -f helm-values/joxit-values.yaml
  helm install --namespace kiali-operator  --create-namespace kiali-operator helm-charts/kiali-operator
  helm install istio-base helm-charts/base -n istio-system --set defaultRevision=default --create-namespace
  helm install istiod helm-charts/istiod -n istio-system --wait


```


## Install K3s + kubectl

  
  curl -sfL https://get.k3s.io | sh -
  sudo chmod 666 /etc/rancher/k3s/k3s.yaml
  

  
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"

  echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
  sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
  

## Metrics

  Chạy các command sau để install prometheus-kube-stack helm

  
  helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
  

  
  helm repo list
  helm repo update
  

  Sau đó chạy command sau để list các helm của *Grafana*

  
  helm search repo  prometheus-community
  

  Để chạy offline thì phải tải helm chart về bằng command và update để tải các dependency nếu có

  
  helm pull prometheus-community/kube-prometheus-stack --version 80.0.0 --untar
  helm dependency update kube-prometheus-stack
  

  khi có file value thì chãy install với helm chart đã download về

  
  helm upgrade --install monitoring helm-charts/kube-prometheus-stack --namespace monitoring --create-namespace -f helm-values/metrics-values.yaml
  

  Khi chạy trong WSL se co báo error cua pod *prometheus-node-exporter* vì cái này có thu thập disk của host nen no mount thư mục / cua Host vao, mà cái này thường set là private nen se fail. Co vai cach fix

* Cách 1: chạy ở Host sudo mount --make-rshared / sau do91 delete pod do91 di9
* Cách 2: mở file ở /etc/systemd/system/k3s.service, update như sau

  
  [Unit]
  Description=Lightweight Kubernetes
  ...

  [Service]
  Type=notify
  EnvironmentFile=-/etc/default/k3s
  EnvironmentFile=-/run/k3s/k3s.env
  KillMode=process
  Delegate=yes
  ## ---> THÊM DÒNG NÀY <---
  MountFlags=shared
  ...
  

  Sau đó restart lại K3s

* Cách 3: trong file values, set phần dưới này, cách này thì metrics ko thấy dc disk usage của Host

  
  prometheus-node-exporter:
    hostRootFsMount:
      enabled: false
  

## Kube dashboard

  
  helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
  helm pull  kubernetes-dashboard/kubernetes-dashboard --version 7.14.0 --untar
  helm upgrade --install kubernetes-dashboard helm-charts/kubernetes-dashboard --create-namespace --namespace kubernetes-dashboard -f helm-values/kube-dashboard-values.yaml
  

  Phiên bản dashboard mới từ 7.xx trở đi có thay đổi lớn về security và cách tách microservice trong đó nên phải dùng thông qua kong proxy, vì dashboard thì đúng là chỉ có dashboard, ko có routeing đi đâu, nó là 1 nginx server static file nó không biết /api là gì và cũng không được cấu hình để chuyển tiếp (proxy) request này sang API Container.
  Theo cơ chế của Single Page Application (SPA), khi Nginx không tìm thấy file, nó sẽ trả về file index.html với mã 200 OK.
  Web cần JSON nhưng chỉ nahn65 dc html nên nó parse HTML -> JSON nên lỗi

  Sau đó chuyển qua nodeport, nếu dùng HTTP nhưng báo invalid token vì

* Dashboard v7 được thiết kế bảo mật cao (Secure default)
* Khi backend tạo cookie session/token, nó gắn cờ *Secure* và *SameSite=Strict*. Cờ *Secure* bắt buộc trình duyệt chỉ được phép gửi/nhận cookie này qua kết nối được mã hóa (HTTPS).
* Vì đang dùng HTTP, trình duyệt sẽ từ chối lưu cookie hoặc từ chối gửi cookie kèm theo request tiếp theo.
* Khi bấm Login, request gửi đi không kèm theo cookie xác thực hợp lệ -> Server trả về "Invalid token" hoặc "CSRF token missing".

  Sau đó chạy command để apply tạo service account và phần quyển cho các account và lấy token

  
  kubectl apply -f helm-values/kube-dashboard-dev-token.yaml
  

  Tạo token cho admin

  
  kubectl apply -f helm-values/kube-dashboard-admin.yaml

Lấy token

  ```
  kubectl -n kube-system get secret/super-admin-token -o jsonpath='{.data.token}' | base64 --decode
  ```
  


## Minio

  
  helm repo add minio https://charts.min.io/
  helm pull minio/minio --version 5.4.0 --untar
  

  
  helm upgrade --install minio helm-charts/minio --namespace minio --create-namespace -f helm-values/minio-values.yaml
  

## Loki

  Download chart về

  
  helm pull grafana/loki --version 6.46.0 --untar
  helm dependency update loki
  

  Dùng Loki để deploy luôn cả Minio để lưu log và dùng như 1 S3

  
  helm upgrade --install loki helm-charts/loki --namespace monitoring -f helm-values/loki-values.yaml
  

## Alloy

  
  helm pull grafana/alloy --version 1.5.0 --untar
  helm dependency update alloy
  

  
  helm upgrade --install alloy helm-charts/alloy --namespace monitoring -f helm-values/alloy-values.yaml
  

  Trong quá trình chạy trên WSL thì alloy và minio sẽ tranh tài nguyên read file nên chậy alloy thì minio sẽ bị đứng ( xem kĩ fsnotify)

  Nếu Minio bị đứng khi login web thì chạy command này để tạm dừng alloy

  
  kubectl patch daemonset alloy -n monitoring -p '{"spec": {"template": {"spec": {"nodeSelector": {"non-existent-label": "true"}}}}}'
  

  Khi muốn start lại alloy thì

  
  kubectl patch daemonset alloy -n monitoring --type=merge -p '{"spec": {"template": {"spec": {"nodeSelector": {"non-existent-label": null}}}}}'
  

  Hoặc chạy lại Helm upgrade

## Gitea - git

  
  helm repo add gitea-charts https://dl.gitea.com/charts/
  helm pull gitea-charts/gitea --version 12.4.0 --untar
  helm pull gitea-charts/actions   --untar
  

  helm upgrade --install gitea helm-charts/gitea --namespace git --create-namespace -f helm-values/gitea-values.yaml

## Gitea -action


## Joxit UI + Docker registry - container registry
helm repo add joxit https://helm.joxit.dev
helm pull joxit/docker-registry-ui --version 1.1.3 --untar

  helm upgrade --install container-registry helm-charts/docker-registry-ui --namespace container-registry --create-namespace -f helm-values/joxit-values.yaml

Khi chạy, sẽ có vấn đề là UI và registry là do 2 người khac 1nhau làm nên registry default sẽ ko trả header Allow-cross-orgin :<web-UI> nên sẽ thấy báo error missing header đó trên web UI. Lúc này cần bật cờ proxy bên UI dể chạy reverse proxy, lúc này UI đảm nhận việc gửi và xử lý request gửi đến registry và trả về cho người dùng nên sẽ thấy các request đến cùng từ 1 origin là web UI nên sẽ thấy dc iamge list


Update phần K3s để lấy dc image từ registry local này

thêm vào file này /etc/rancher/k3s/registries.yaml bằng command
sudo vi /etc/rancher/k3s/registries.yaml

với nội dung


mirrors:
  "container-registry-docker-registry-ui-registry-server.container-registry.svc.cluster.local:5000":
    endpoint:
      - "http://127.0.0.1:31141"
configs:
  "container-registry-docker-registry-ui-registry-server.container-registry.svc.cluster.local:5000":
    insecure_skip_verify: true


sau đó restart lại k3s sudo service k3s retart


## Kiali Helm
helm repo add kiali https://kiali.org/helm-charts
helm pull kiali/kiali-operator --untar

helm install --namespace kiali-operator  --create-namespace kiali-operator helm-charts/kiali-operator



## Istio Helm
helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo update

helm pull istio/base --untar
helm pull istio/istiod --untar

Set label cho sito sidecar cho các namespace

echo -n "default container-registry monitoring kubernetes-dashboard minio" | xargs -d' ' -t -I{} kubectl label namespace {} istio-injection=enabled

helm install istio-base helm-charts/base -n istio-system --set defaultRevision=default --create-namespace
helm install istiod helm-charts/istiod -n istio-system --wait


## argocd

```
helm repo add argo https://argoproj.github.io/argo-helm

```
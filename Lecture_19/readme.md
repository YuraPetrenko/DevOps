**Створеннф VPC а  двох віртуалок** 

Редагування файлу hosts для роботи по іменах вузлів


`vim /etc/hosts

10.0.10.90 lecture20.worker1 worker1
10.0.4.113 lecture20.master master`


**Налаштування для мастрера та воркер нод**


Для кібернетіса треба вирубити свап
відключити свап
`swapoff -a	`

закоментувати всф строки де є слово свап

`sed -i '/\/swap\.img/ s/^\(.*\)$/#\1/g' /etc/fstab`



Додати до мастера два модуля для контейнер Д

`tee /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF`

`modprobe overlay
modprobe br_netfilter`

`echo "overlay" >> /etc/modules`
`echo "br_netfilter" >> /etc/modules`


Налаштування мережі для роботи подів

`sudo tee /etc/sysctl.d/kubernetes.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF`

Примінити зміни

`sysctl --system`

Встановлення залежностей для контейнер д
Використання сертифікатів

`apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates`

Оновити систему

`apt update`

`sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/docker.gpg`

`sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

`

Оновити систему

`apt update`

Встановлення додатка контейнера

apt install -y containerd.io

Налаштування конфіга контейнера д

` containerd config default | sudo tee /etc/containerd/config.toml >/dev/null 2>&1
`

`cat /etc/containerd/config.toml | grep SystemdCgroup`

зміна значення SystemdCgroup = false

`sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml`

Перезавантаження сервіса контейнер д 

`sudo systemctl restart containerd`

перевірка контейнер д

`systemctl status containerd`

Встановлення КУБЕРА

`sudo echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list `

`sudo curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg`
`apt update`

Встановлення сервісів керування КУБЕРА  кублет кубдм кубктл


`sudo apt install -y kubelet kubeadm kubectl`


**До ЦЬОГО МІСЦЯ налаштовуєтся воркер нода**

**Далі налаштування тільки для мастера**

Ініціалізація матер-ноди

`sudo kubeadm init --control-plane-endpoint=master`

використання кластера

`mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config`


Встановлення сервісу на мастера для звязку сервісів у когтейнерах нод

`kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.1/manifests/calico.yaml`

vi /etc/cni/net.d/calico-kubeconfig    тут треба перевірити айпі сервера


Перевірка всі запущених процесів на ноде мастер

`kubectl get pods -A -o wide`

генерація токена для підключення ноди

`kubeadm token create --print-join-command`

kubeadm token create --print-join-command

`kubeadm join master-noda:6443 --token kvnxi1.n6bo04fxivzecvqm --discovery-token-ca-cert-hash sha256:eba35c9142876b82258ab5b9545fdd0f0ffbc378b29ba2958632ccf4c7a1392b`

пошук процеса по порту

`lsof -i :10250`




Заморозка ноди перед видаленням 


`kubectl drain worker-noda-1 --ignore-daemonsets --delete-emptydir-data`

видалення ноди

`kubectl delete node worker-noda-1`

rm -f /etc/kubernetes/kubelet.conf

rm -f /etc/kubernetes/pki/ca.crt

перевірка наявності нод 

`kubectl get nodes`


Створення нейм спейсу lecture-19-space у майстрі  через ямл файл і активація чи задія цього файла


`
root@master:/home/ubuntu# cat > namespace.yaml << EOF
apiVersion: v1
kind: Namespace
metadata:
name: my-nginx-app
EOF
root@master:/home/ubuntu# ls
namespace.yaml
root@master:/home/ubuntu# kubectl apply -f namespace.yaml
namespace/my-nginx-app created`



`root@master:/home/ubuntu# kubectl get namespaces
NAME              STATUS   AGE
default           Active   174m
kube-node-lease   Active   174m
kube-public       Active   174m
kube-system       Active   174m
my-nginx-app      Active   9s`


Створення пристем волума 

`root@master:/home/ubuntu# cat > pv.yaml <<EOF
 apiVersion: v1
 kind: PersistentVolume
 metadata:
   name: nginx-pv
 spec:
   capacity:
     storage: 1Gi
  accessModes:
    - ReadWriteOnce persistentVolumeReclaimPolicy: Retain
   hostPath:
     path: /mnt/data
 EOF
`
`root@master:/home/ubuntu# kubectl apply -f pv.yaml
persistentvolume/nginx-pv created`

 Створення каталогу для присистем волума та надання прав на каталог на воркер ноде де бутуть запускатися поди

`root@master:/home/ubuntu# mkdir /mnt/data
root@master:/home/ubuntu# chmod 777 /mnt/data `

Створення пристемВолумКлейм   для подів 

`root@master:/home/ubuntu# cat > pvc.yaml << EOF
> apiVersion: v1
> kind: PersistentVolumeClaim
> metadata:
>   name: nginx-pvc
>   namespace: my-nginx-app
> spec:
>   accessModes:
>     - ReadWriteOnce
>   resources:
>     requests:
>       storage: 1Gi
> EOF
root@master:/home/ubuntu# kubectl apply -f pvc.yaml
persistentvolumeclaim/nginx-pvc created`





Подивитися чи створився присистем волум 

`root@master:/home/ubuntu# kubectl get persistentvolume
NAME       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM   STORAGECLASS   REASON   AGE
nginx-pv   1Gi        RWO            Retain           Available                                   95s`

Створення деплою для нджинкса 

root@master:/home/ubuntu# cat > deployment.yaml <<EOF
> apiVersion: apps/v1
> kind: Deployment
> metadata:
>   name: nginx-deployment
>   namespace: my-nginx-app
> spec:
>   replicas: 2
>   selector:
>     matchLabels:
>       app: nginx
>   template:
>     metadata:
>       labels:
>         app: nginx
>     spec:
>       containers:
>       - name: nginx
>         image: nginx:latest
>         ports:
>         - containerPort: 80
>         volumeMounts:
>         - name: nginx-data
>           mountPath: /usr/share/nginx/html
>       volumes:
>       - name: nginx-data
>         persistentVolumeClaim:
>           claimName: nginx-pvc
> EOF
root@master:/home/ubuntu# kubectl apply -f deployment.yaml
deployment.apps/nginx-deployment created


створенн кластер айпі для доступу до подів

`root@master:/home/ubuntu# cat > service.yaml <<EOF
> apiVersion: v1
> kind: Service
> metadata:
>   name: nginx-service
>   namespace: my-nginx-app
> spec:
>   selector:
>     app: nginx
>   ports:
>   - protocol: TCP
      >     port: 8080
      >     targetPort: 80
      >   type: ClusterIP
      > EOF
      root@master:/home/ubuntu# kubectl apply -f service.yaml
      service/nginx-service created`

Зявився кластер айпі 

`root@master:/home/ubuntu# kubectl get service nginx-service -n my-nginx-app
NAME            TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
nginx-service   ClusterIP   10.105.90.171   <none>        80/TCP    2m28s
root@master:/home/ubuntu#`

Перевірка подів 

`root@master:/home/ubuntu# kubectl get pods -n my-nginx-app
NAME                                READY   STATUS    RESTARTS   AGE
nginx-deployment-57cbcf9764-sp579   1/1     Running   0          29m
nginx-deployment-57cbcf9764-v896h   1/1     Running   0          29m`

Якщо щось пішло не так з монтування то можна видалити поди і вони автоматично створятся наново 

`root@master:/home/ubuntu# kubectl delete pods -n my-nginx-app --all
pod "nginx-deployment-57cbcf9764-sp579" deleted
pod "nginx-deployment-57cbcf9764-v896h" deleted`

еревірка вмісту директоріїї поди  

`kubectl exec -it nginx-deployment-56f44f6f74-4lfmr -n my-nginx-app -- bash
cd /usr/share/nginx/html
ls -l`

Після змін у диплої треба все перезавантажити 

`root@master:/home/ubuntu# kubectl rollout restart deployment nginx-deployment -n my-nginx-app
 root@master:/home/ubuntu# deployment.apps/nginx-deployment restarted`

Вивести  лог пода

`kubectl logs nginx-deployment-56f44f6f74-4lfmr -n my-nginx-app -f`



kubectl exec -it nginx-deployment-56f44f6f74-4lfmr -n my-nginx-app -- ping google.com

Перевірка чи запускаєтся под без помилок

`kubectl logs nginx-deployment-56f44f6f74-4lfmr -n my-nginx-app`

Перенаправлення портів пода з 80 до 8080

`kubectl port-forward nginx-deployment-56f44f6f74-4lfmr -n my-nginx-app 8080:80`

Подивитися на яких нодах воркерах крутятся поди 

`kubectl get pods -n my-nginx-app -l app=nginx -o wide`

Подивитися роботу сервісу в нашому неймспейсі


`root@master:/home/ubuntu# kubectl get services -n my-nginx-app
NAME            TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
nginx-service   NodePort   10.105.90.171   <none>        80:30007/TCP   14h`

Стан сервісу але обовязково указувати неймспейс 

`root@master:/home/ubuntu# kubectl describe svc nginx-service -n my-nginx-app`


Name:                     nginx-service
Namespace:                my-nginx-app
Labels:                   <none>
Annotations:              <none>
Selector:                 app=nginx
Type:                     NodePort
IP Family Policy:         SingleStack
IP Families:              IPv4
IP:                       10.105.90.171
IPs:                      10.105.90.171
Port:                     <unset>  80/TCP
TargetPort:               80/TCP
NodePort:                 <unset>  30007/TCP
Endpoints:                192.168.235.165:80,192.168.235.166:80,192.168.235.167:80
Session Affinity:         None
External Traffic Policy:  Cluster
Events:                   <none>


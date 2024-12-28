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

Створення неймспейсу my-redis-app

`kubectl create namespace my-redis-app`






![Результат роботи скрипта]( Screenshots/kubectl.PNG)

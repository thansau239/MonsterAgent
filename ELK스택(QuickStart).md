# ELK Stack Quick Start
이 튜토리얼에서는 ELK(Elasticsearch, Logstash, Kibana 이하, ELK) 스택을 가상환경에 구축하는 내용을 살펴봅니다. 가상환경의 세부 설정 항목은 다음과 같습니다.
```bash
os : ubuntu 16.04.03 desktop (x64)
ram : 4G
* (Elasticsearch itself needs 2GB to start)
disk : 30G
```
ELK 스택 설치 순서는 다음과 같습니다.
+ 자바 설치
+ 엘라스틱서치 설치 및 설정
+ 키바나 설치 및 설정
  - 키바나 인증 설정(옵션)
+ 로그스태시 설치
+ 포스트맨 설치(옵션)
---

### 자바 설치
엘라스틱서치는 `java` 기반으로 동작합니다. 먼저, 자바 설치 유무를 확인 해야 하며, 다음 명령를 사용 하여 할 수 있습니다. 만약, 자바가 설치 되어 있는 경우 엘라스틱서치 설치를 진행 하시면 됩니다.
```bash
~$ java
The program 'java' can be found in the following packages:
 * default-jre
 * gcj-5-jre-headless
 * openjdk-8-jre-headless
 * gcj-4.8-jre-headless
 * gcj-4.9-jre-headless
 * openjdk-9-jre-headless
Try: sudo apt install <selected package>
```
설치 되어 있지 않은 경우 명령어(`sudo apt-get install openjdk-8-jre-headless`)로 설치 후 다음 단계를 진행합니다.
```bash
~$ sudo apt-get install openjdk-8-jre-headless
~$ java -version
openjdk version "1.8.0_131"
OpenJDK Runtime Environment (build 1.8.0_131-8u131-b11-2ubuntu1.16.04.3-b11)
OpenJDK 64-Bit Server VM (build 25.131-b11, mixed mode)
```

---

### 엘라스틱서치 설치
ELK Stack 설치 방법은 zip, tar, deb, rpm, msi 등 다양한 방법이 있습니다. 이번 문서에서는 우분투 패키지 매니저를 사용하여 ELK Stack을 구성합니다. 그 이외에 방법은 [공식 홈페이지 설치 문서](https://www.elastic.co/guide/en/elasticsearch/reference/current/install-elasticsearch.html)를 참조하여 진행하시면 됩니다.

elastic이 제공하는 Elastic PGP 서명 키를 패키지에 서명합니다.

> ~$ wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -

엘라스틱서치를 설치 전에 보안을 위해서 apt-transport-https 를 설치합니다.

> ~$ sudo apt-get install apt-transport-https

elastic 6.x 버전을 다운 받기 위해 패키지 소스 목록에 추가합니다.

> ~$ echo "deb https://artifacts.elastic.co/packages/6.x/apt stable main" | sudo tee -a  /etc/apt/sources.list.d/elastic-6.x.list

시스템 업데이트와 elasticsearch 를 다운로드 및 설치를 진행합니다.

> ~$ sudo apt-get update && sudo apt-get install elasticsearch


만약 elasticsearch 를 다운로드 중 `hash sum mismatch`가 발생 했을 시에 아래 명령어를 실행 해보시길 바랍니다.

> ~$ sudo apt clean

> ~$ sudo rm -rf /var/lib/apt/lists/*

> ~$ sudo apt-get update && sudo apt-get install elasticsearch

설치 이후 elasticsearch(이하, 엘라스틱서치) 구동을 위해 기본적인 환경설정을 해줍니다. 엘라스틱서치 설정 파일은 `/etc/elasticsearch/` 폴더 밑에 있으며 해당 폴더에는 다음과 같은 파일이 생성 되어져 있습니다.
+ elasticsearch.yml
  - 엘라스틱서치 구동에 필요한 옵션들을 관리합니다.
+ jvm.options
  - [엘라스틱서치 JVM에 관한 설정을 관리합니다.](https://www.elastic.co/guide/en/elasticsearch/reference/master/heap-size.html)
+ log4j2.properties
  - 엘라스틱서치 로그에 관한 설정을 관리합니다.
```bash
~$ sudo ls -al /etc/elasticsearch
-rw-rw----  1 root elasticsearch 2854 Oct  7 05:34 elasticsearch.yml
-rw-rw----  1 root elasticsearch 3064 Oct  7 05:34 jvm.options
-rw-rw----  1 root elasticsearch 4456 Oct  7 05:34 log4j2.properties
```
튜토리얼에서는 네트워크 설정 이외의 작업은 필요 없습니다. 만약 엘라스틱을 클러스터로 구성을 해야 하는 경우 다음 블로그를 참고 하여 환경을 구성 할 수 있습니다.
```bash
엘라스틱서치 클러스터 구성 :
- 개념 http://arclab.tistory.com/106
- 구축 http://arclab.tistory.com/109
```
엘라스틱서치는 포트 9200번을 권장 하고 있습니다. 해당 포트를 이미 사용 중이면, 설정 파일을 수정 하여 다른 포트로 변경 하시면 됩니다. 엘라스틱서치 시스템이 외부 네트워크와 통신이 필요 없는 경우에는 IP를 `localhost`, 아닌 경우 `0.0.0.0`으로 설정 합니다.
```bash
~$ sudo vi /etc/elasticsearch/elasticsearch.yml

# ======================== Elasticsearch Configuration =========================
...
# ---------------------------------- Network -----------------------------------
#
# Set the bind address to a specific IP (IPv4 or IPv6):
#
network.host: 0.0.0.0(or localhost)
#
# Set a custom port for HTTP:
#
http.port: 9200
#
# For more information, consult the network module documentation.
...
```
설정 변경 후 다음과 같은 명령어를 통해 엘라스틱서치 데몬을 등록하여 운영체제가 부팅 될때 마다 자동으로 서비스가 시작되도록 설정을 합니다.

> ~$ sudo /bin/systemctl daemon-reload

> ~$ sudo /bin/systemctl enable elasticsearch.service

`curl`을 이용하여 엘라스틱서치 설치 후 정상 실행 유무를 확인 해 볼 수 있습니다. curl 이 설치가 안되어 있는 경우 curl을 설치 후 진행합니다.

> ~$ sudo apt install curl

엘라스틱서치 설치 후 정상 실행 중인 경우 아래와 같은 메시지를 볼 수 있습니다.
```bash
~$ curl -XGET http://localhost:9200
{
  "name" : "sdqM747",
  "cluster_name" : "elasticsearch",
  "cluster_uuid" : "EcOr_MWRQlaf0hMqP1Uulg",
  "version" : {
    "number" : "6.1.1",
    "build_hash" : "bd92e7f",
    "build_date" : "2017-12-17T20:23:25.338Z",
    "build_snapshot" : false,
    "lucene_version" : "7.1.0",
    "minimum_wire_compatibility_version" : "5.6.0",
    "minimum_index_compatibility_version" : "5.0.0"
  },
  "tagline" : "You Know, for Search"
}
```

---

### 키바나 설치
엘라스틱서치 설치를 우분투 패키지 매니저를 사용했습니다. 이때 우분투 패키지 매니저에 엘라스틱서치 관련 제품 저장소에 관한 정보를 등록 하였기 때문에 `kibana`, `logstash`를 새로운 저장소 추가와 같은 과정 없이 설치 할 수 있습니다.

> ~$ sudo apt-get update && sudo apt-get install kibana


키바나 설치 후 설정 파일은 `/etc/kibana/` 폴더 아래 있으며 이 문서에서는 네트워크 관련 설정 파일만 수정 합니다. 키바나를 별도의 서버에 구성을 하게 되면 설정 해야할 항목이 현재의 문서와 다릅니다. 그때는 [공식 사이트](https://www.elastic.co/guide/en/kibana/current/settings.html#settings)의 설정 파일 관련 내용을 참고하여 설정 하면 됩니다.
```bash
~$ sudo vi /etc/kibana/kibana.yml

# Specifies the address to which the Kibana server will bind. IP addresses and host names are both valid values.
# The default is 'localhost', which usually means remote machines will not be able to connect.
# To allow connections from remote users, set this parameter to a non-loopback address.
server.host: "localhost"
```
설정 변경 후 다음과 같은 명령어를 통해 키바나 데몬을 등록 하여 운영체제가 부팅 될때 마다 자동으로 서비스가 시작되도록 설정을 합니다.

> ~$ sudo /bin/systemctl daemon-reload

> ~$ sudo /bin/systemctl enable kibana.service

다음 단계에서 kibana 접근시 웹 인증을 nginx를 `reverse-proxy`로 연동 합니다. 키바나 인증 설정은 `x-pack` 을 사용 중인 경우 `x-pack` 에서 지원 하는 인증을 사용하면 됩니다.
___
### 키바나 인증 설정
키바나 인증을 위해서 nginx에서 제공 하는 `HTTP basic authentication`을 사용 합니다. nginx는 다음과 같이 설치 할 수 있습니다.

> ~$ sudo apt-get -y install nginx

kibana 웹 인터페이스에 로그온에 이용하는 아이디와 비밀번호를 설정합니다. 이 예제에서는 아이디가 `kibadmin` 이며, 사용자가 임의로 설정할 수 있습니다.

> ~$ sudo -v

> ~$ sudo echo "kibadmin:\`openssl passwd -apr1\`" | sudo tee -a /etc/nginx/htpasswd.users

> Password:

키바나와의 연동을 위해서 nginx의 "reverse proxy"를 사용할 것이며, `/etc/nginx/sites-available/` 경로에 있는 기존의 설정 파일은 백업 해둔 뒤 새로운 설정 파일을 다음과 같이 작성합니다.

> ~$ sudo cp /etc/nginx/sites-available/default /etc/nginx/sites-available/backup_default
```bash
~$ sudo ls -al /etc/nginx/sites-available
total 16
drwxr-xr-x 2 root root 4096 Dec 21 17:26 .
drwxr-xr-x 6 root root 4096 Dec 20 21:39 ..
-rw-r--r-- 1 root root 2074 Dec 20 21:38 default
-rw-r--r-- 1 root root 2074 Dec 21 17:27 backup_default
```

```bash
~$ ifconfig
ens33     Link encap:Ethernet  HWaddr 00:0c:29:a6:96:d6
          inet addr:192.168.0.13  Bcast:192.168.0.255  Mask:255.255.255.0
          inet6 addr: fe80::fb0d:beb:83c5:500b/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:222385 errors:0 dropped:0 overruns:0 frame:0
          TX packets:89378 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:321265697 (321.2 MB)  TX bytes:10476857 (10.4 MB)
          ...
```
nginx가 설치된 IP를 확인하여 /etc/nginx/sites-available/default 설정 파일을 아래와 같이 수정합니다.

```bash
~$ sudo vim /etc/nginx/sites-available/default
server {
    listen 80;

    server_name 192.168.0.13;

    auth_basic "Restricted Access";
    auth_basic_user_file /etc/nginx/htpasswd.users;

    location / {
        proxy_pass http://localhost:5601;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```
server_name의 `192.168.0.13`은 nginx가 설치된 IP입니다.

설정 파일이 올바른지 확인 하는 방법은 다음과 같으며 이후 nginx를 재시작 하여 정상 동작 하는지를 확인합니다.
> ~$ sudo nginx -t

> ~$ sudo systemctl restart nginx

---

### 로그스태시 설치
`로그스태시`를 다음과 같이 설치 할 수 있습니다.
> ~$ sudo apt-get update && sudo apt-get install logstash

logstash의 설정 파일은 `/etc/logstash/` 폴더 밑에 있으며 해당 폴더에는 다음과 같은 파일이 생성 되어져 있습니다.
```bash
~$ sudo ls -al /etc/logstash
drwxrwxr-x   2 root root  4096 Dec 17 13:51 conf.d
-rw-r--r--   1 root root  1738 Dec 17 13:48 jvm.options
-rw-r--r--   1 root root  1334 Dec 17 13:48 log4j2.properties
-rw-r--r--   1 root root  6426 Dec 20 18:41 logstash.yml
-rw-r--r--   1 root root  1659 Dec 17 13:48 startup.options
```

설정 변경 후 다음과 같은 명령어를 통해 서비스가 시작되도록 설정을 합니다.
> ~$ sudo systemctl start logstash.service

> ~$ sudo systemctl enable logstash.service

로그스태시가 설치 후 정상 동작 유무를 확인하기 위해서 `/usr/share/logstash/bin`에 있는 logstash 를 간단한 파이프라인를 입력하여 실행해봅니다.
```bash
~$ sudo /usr/share/logstash/bin/logstash -e 'input { stdin { } } output { stdout { } }'
...
The stdin plugin is now waiting for input:
test
2017-12-21T09:36:18.967Z ubuntu test
```
실행 후 정삭적인 결과를 확인 할 수 있다면 ELK 스택 구성은 완료가 된 것입니다. 설치 이후 엘라스틱 서치 활용 문서는 `tech.somma.kr`에서 블로그 제목 `Monster Agent: ELK Integration`에서 확인 할 수 있습니다.

---

### 포스트맨 설치
엘라스틱서치 매핑 템플릿 생성은 kibana에 있는 dev tool로도 가능하지만, `Monster Agent: ELK Integration`에서는 포스트맨으로 진행하기 때문에 설치를 권장 드립니다.

> ~$ wget https://dl.pstmn.io/download/latest/linux64 -O postman.tar.gz

포스트맨을 다운 받습니다.

> ~$ sudo tar -xzf postman.tar.gz -C /opt

`/opt` 에 압축 해제합니다.

```bash
~$ sudo ls -al /opt/
total 12
drwxr-xr-x  3 root     root     4096 Dec 21 23:20 .
drwxr-xr-x 24 root     root     4096 Oct 19 07:26 ..
drwxr-xr-x  4 logstash logstash 4096 Dec  8 21:49 Postman
```

`/opt`를 확인하면 포스트맨이 정상적으로 압축 해제가 된 것을 확인할 수 있습니다.

> ~$ rm postman.tar.gz

정상적으로 압축 해제가 되었으니, 압축 파일은 삭제합니다.

> ~$ sudo ln -s /opt/Postman/Postman /usr/bin/postman

포스트맨을 터미널에서 실행하기 위해 심볼릭 링크를 생성합니다.

> ~$ postman

심볼릭 링크한 뒤에는 터미널 창에서 실행할 수 있습니다. 로그인은 구글 계정으로 쉽게 할 수 있습니다. 정상적으로 작동 확인 법은 `GET 메소드를 이용하여 localhost:9200 으로 전송`하면, 엘라스틱서치 정상 실행 결과를 보실 수 있습니다.
```bash
{
  "name" : "sdqM747",
  "cluster_name" : "elasticsearch",
  "cluster_uuid" : "EcOr_MWRQlaf0hMqP1Uulg",
  "version" : {
    "number" : "6.1.1",
    "build_hash" : "bd92e7f",
    "build_date" : "2017-12-17T20:23:25.338Z",
    "build_snapshot" : false,
    "lucene_version" : "7.1.0",
    "minimum_wire_compatibility_version" : "5.6.0",
    "minimum_index_compatibility_version" : "5.0.0"
  },
  "tagline" : "You Know, for Search"
}
```


# Monster Agent

`Monster Agent` 는 `Threat Hunting`에 필요한 데이터(e.g. 프로세스, 네트워크, 파일, 레지스트리 등)를 실시간으로 수집합니다. 

`Monster Agent` 는 설정에 따라 수집한 데이터를 

- `TSV (Tab Seperated Values)` 파일로 로컬디스크에 저장 (기본값)
- `Kafka` 클러스터로 전송
- `Syslog` 서버로 전송

할 수 있으며, 이를 통해 시스템에 유입된 악성코드 행위 추적, 호스트 시스템의 비-정상적인 행위 탐지 등에 활용 할 수 있습니다.

## 라이선스

`Monster Agent` 는 개인 또는 학교에서 비 상업적인 용도로 사용 가능하며 이외의 사용에 관해서는 별도의 라이선스가 필요합니다. 

# Quick Start

`Monster Agent` 활용에 대한 상세한 내용은 블로그 글 중 [`Monster Agent: Collects Events for Threat Hunters`](http://tech.somma.kr/2017/12/17/monster-collector/#)에서 확인 할 수 있습니다.


## Monster Agent 설치

컴퓨터 환경(32bit, 64bit)에 맞는 에이전트를 다운 받습니다.

+ [32 bit 다운로드](https://github.com/somma-inc/MonsterAgent/blob/release/1.0.0.2/monster-agent/v1.0.2.2/monster_v1.0.2.2_x86.zip)
+ [64 bit 다운로드](https://github.com/somma-inc/MonsterAgent/blob/release/1.0.0.2/monster-agent/v1.0.2.2/monster_v1.0.2.2_x64.zip)


다운로드 한 압축파일을 적당한 위치에 압축을 풀고, `Monster.exe /install` 를 실행하면 설치가 완료됩니다. 이후 시스템 부팅 시 자동으로 `Monster` 가 실행됩니다. 

![install](/images/monster-install.png)

## Monster Agent시작
`Monster.exe /start` 명령으로 즉시 시작할 수 있습니다. 

![service](/images/monster-start.png)

## Monster Agent 중지

`Monster.exe /stop` 명령으로 즉시 종료 할 수 있습니다.

![stop](/images/monster-stop.png)

## Monster Agent 제거

`Monster.exe /remove` 명령으로 시스템에서 제거할 수 있습니다. 이후 시스템 부팅 시 더이상 `Monster` 가 실행되지 않습니다. 

![delete](/images/monster-remove.png)

---

# 지원

지원이 필요하신 경우 언제든지 아래의 채널을 활용 하실 수 있습니다. 

- [Facebook](https://www.facebook.com/Somma.Inc/)
- [Threat Hunters List](https://groups.google.com/forum/?hl=ko#!forum/threat-hunters) 
- [Github Issue](https://github.com/somma-inc/MonsterAgent/issues)
- 메일: support@somma.kr 

---


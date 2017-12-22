# Monster Agent(Beta)

# Quick Start
## Donwload Monster Agent
컴퓨터 환경(32bit, 64bit)에 맞는 에이전트를 다운 받습니다.
+ [32 bit 다운로드](https://monsterti.blob.core.windows.net/monster-agent/Monster(x86).zip)
+ [64 bit 다운로드](https://monsterti.blob.core.windows.net/monster-agent/Monster(x64).zip)

## Install Monster Agent
`몬스터 에이전트` 를 다운 받은 후 먼저 압축을 해제합니다. `Monster.exe /install` 명령어로 몬스터 에이전트를 설치합니다. 

![install](/images/monster-install.png)

## Monster Agent Start
`Monster.exe /start` 명령어로 몬스터 에이전트를 실행 할 수 있으며 실행 후 로그는 `Monster.exe.log` , `MonsterTray.exe.log` 로 확인 할 수 있습니다.

![service](/images/monster-service-mode.png)

## Monster Agent logs
`몬스터 에이전트` 실행 후 발생하는 로그들은 다음과 같이 기록이 됩니다. 또한, ficacheex는 파일 이벤트에서 사용되는 정보(해시, 서명자 정보 등)의 캐싱을 위해서 사용하는 파일입니다.

![logs](/images/monster-logs.png)

## Monster Agent Results
`몬스터 에이전트` 다운로드 후 기본 설정 파일로 실행할 경우 `TSV` 파일에 수집된 이벤트들이 기록 됩니다.

![tsv-export](/images/monster-tsv-export.png)

## Moster Agent Stop
`몬스터 에이전트` 다음과 같이 `/stop` 옵션을 사용 하여 종료 할 수 있습니다.

![stop](/images/monster-stop.png)

## Monster Agent Delete
`Monster.exe /remove` 명령어로 몬스터 에이전트를 삭제 할 수 있습니다.

![delete](/images/monster-delete.png)

---

# 기타
+ Monster Agent 사용 중 문제가 발생 하는 경우 메일(contact@somma.kr) 혹은 이슈로 등록 해주시면 됩니다.

---

자세한 내용은 블로그 글 중 [`Monster Agent: Collects Events for Threat Hunters`](http://tech.somma.kr/2017/12/17/monster-collector/#)에서 확인 할 수 있습니다.

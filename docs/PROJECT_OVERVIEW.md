# Cybersecurity Box - Visao Geral do Projeto

## Indice

1. [Visao geral do projeto](#1-visao-geral-do-projeto)
2. [Arquitetura atual](#2-arquitetura-atual)
3. [Fluxo de execucao do ESP32](#3-fluxo-de-execucao-do-esp32)
4. [main.py](#4-mainpy)
5. [wifi_monitor.py](#5-wifi_monitorpy)
6. [time_sync.py](#6-time_syncpy)
7. [Credenciais](#7-credenciais)
8. [Automacao com mpremote](#8-automacao-com-mpremote)
9. [VS Code](#9-vs-code)
10. [Git e GitHub](#10-git-e-github)
11. [Codex e agentes](#11-codex-e-agentes)
12. [Estado atual do projeto](#12-estado-atual-do-projeto)
13. [Conceitos que ja foram praticados](#13-conceitos-que-ja-foram-praticados)
14. [Pontos para estudar melhor](#14-pontos-para-estudar-melhor)
15. [Proximas etapas](#15-proximas-etapas)
16. [Diagrama final](#16-diagrama-final)

## 1. Visao geral do projeto

A Cybersecurity Box e um projeto de hardware e software para construir, aos poucos, uma plataforma modular de seguranca cibernetica. A fase atual e um monitor de redes Wi-Fi executando em um ESP32 com MicroPython.

O objetivo atual nao e atacar redes, derrubar conexoes ou interferir em dispositivos. O objetivo e observar passivamente o ambiente Wi-Fi ao redor, coletando informacoes como nome da rede, identificador do ponto de acesso, canal, intensidade do sinal, tipo de seguranca e se a rede parece oculta.

Comecar pelo ESP32 faz sentido por alguns motivos:

- e barato e facil de conectar ao computador por USB;
- tem Wi-Fi integrado;
- roda MicroPython, o que permite praticar Python em um microcontrolador;
- permite aprender conceitos de hardware, firmware, serial, memoria limitada e redes sem comecar por uma arquitetura grande demais.

Hoje o ESP32 Network Monitor faz:

- varredura de redes Wi-Fi proximas;
- exibicao de SSID, BSSID, canal, RSSI, seguranca e rede oculta;
- classificacao simples de qualidade de sinal;
- monitoramento continuo em loop;
- comparacao entre scans para identificar redes novas;
- sincronizacao de horario por NTP quando ha credenciais locais autorizadas;
- exibicao de timestamps locais usando offset configuravel.

No futuro, o ESP32 deve ser apenas um dos modulos sensores. A direcao de longo prazo e:

```text
ESP32
  -> coleta dados do ambiente
  -> envia eventos para um host
  -> Raspberry Pi agrega, armazena e exibe
  -> Cybersecurity Box vira uma central modular
```

Nessa arquitetura futura, o Raspberry Pi pode cuidar de tarefas mais pesadas: banco de dados, dashboard, API, correlacao de eventos e integracao com outros sensores.

## 2. Arquitetura atual

Arvore simplificada do repositorio:

```text
ESP32/
|-- AGENTS.md
|-- README.md
|-- ROADMAP.md
|-- .gitignore
|-- .agents/
|   |-- agents/
|   |   |-- embedded-dev/
|   |   |   `-- agent.md
|   |   `-- reviewer/
|   |       `-- agent.md
|   `-- rules/
|       `-- project.md
|-- .vscode/
|   `-- tasks.json
|-- docs/
|   |-- ARCHITECTURE.md
|   |-- DEVELOPMENT.md
|   |-- SECURITY.md
|   |-- PROJECT_NOTES.md
|   `-- PROJECT_OVERVIEW.md
|-- firmware/
|   `-- esp32/
|       |-- main.py
|       |-- wifi_monitor.py
|       |-- time_sync.py
|       `-- wifi_secrets.example.py
`-- scripts/
    |-- device-info.ps1
    |-- repl.ps1
    |-- reset.ps1
    |-- upload.ps1
    `-- upload-secrets.ps1
```

### AGENTS.md

Define as regras para agentes de desenvolvimento trabalharem no projeto. Ele explica o objetivo, o hardware atual, a arquitetura, as regras de seguranca, as regras de Git e os limites de operacoes em hardware.

Esse arquivo existe para evitar que uma IA ou outro agente automatizado faca algo perigoso, como apagar flash, gravar credenciais ou trocar MicroPython por C/C++ sem necessidade.

### README.md

E a porta de entrada do projeto. Resume o que e a Cybersecurity Box, qual e a fase atual, quais capacidades ja existem e onde ficam os principais diretorios.

### ROADMAP.md

Mostra a evolucao planejada. Ele separa o que ja foi feito do que ainda vem, como logging, armazenamento, dashboard e integracao com Raspberry Pi.

### docs/

Guarda documentacao mais detalhada:

- `ARCHITECTURE.md`: explica a responsabilidade dos modulos principais;
- `DEVELOPMENT.md`: descreve fluxo de desenvolvimento e automacoes;
- `SECURITY.md`: concentra regras de seguranca;
- `PROJECT_NOTES.md`: anotacoes curtas do projeto;
- `PROJECT_OVERVIEW.md`: este documento didatico.

### firmware/esp32/

Contem o codigo MicroPython que roda no ESP32. Ele e separado do codigo do PC porque o ambiente do ESP32 e diferente: menos memoria, bibliotecas diferentes e execucao em microcontrolador.

### scripts/

Contem automacoes PowerShell para Windows. Esses scripts substituem boa parte do trabalho manual de IDE: enviar firmware, abrir REPL, resetar a placa, consultar informacoes e enviar segredos de forma separada.

### .vscode/

Contem tarefas do VS Code. O arquivo `tasks.json` transforma comandos PowerShell em acoes acessiveis pelo editor.

### .agents/

Contem perfis auxiliares de agentes:

- `embedded-dev`: foco em firmware MicroPython e hardware;
- `reviewer`: foco em revisao de seguranca, compatibilidade e manutencao;
- `rules/project.md`: aponta para as regras canonicas do projeto.

## 3. Fluxo de execucao do ESP32

Quando o ESP32 liga, o fluxo esperado e:

```text
ESP32 liga
  -> MicroPython inicia
  -> boot.py e executado se existir
  -> main.py e executado
  -> tenta sincronizar horario via NTP
  -> inicia Wi-Fi Monitor
  -> faz scan de redes
  -> processa e exibe redes encontradas
  -> compara com redes conhecidas
  -> registra novas redes
  -> espera alguns segundos
  -> novo scan
```

### ESP32 liga

Ao receber energia pelo USB-C, o microcontrolador inicializa o firmware MicroPython gravado na flash.

### MicroPython inicia

MicroPython e uma implementacao enxuta de Python para microcontroladores. Ele nao tem tudo que o Python do PC tem, mas oferece modulos especificos para hardware, como `machine`, `network` e `ntptime`.

### boot.py

O `boot.py`, quando presente no filesystem do ESP32, roda antes do `main.py`. Ele normalmente e usado para configuracoes iniciais muito basicas.

### main.py

O `main.py` e o ponto de entrada da aplicacao. No projeto atual, ele imprime mensagens iniciais, tenta sincronizar horario, cria estruturas para acompanhar redes conhecidas e entra no loop de monitoramento.

### Sincronizacao de horario

O ESP32 tenta conectar a uma rede Wi-Fi autorizada usando `wifi_secrets.py`, sincronizar o relogio por NTP e manter o RTC em UTC.

NTP significa Network Time Protocol, um protocolo usado para obter hora precisa pela rede.

### Wi-Fi Monitor

O monitor chama `wifi_monitor.escanear_redes()`, recebe uma lista de redes e exibe os dados de cada uma.

### Comparacao com redes conhecidas

O projeto guarda BSSIDs ja vistos em um `set`. Quando um scan encontra um BSSID que ainda nao estava nesse conjunto, ele registra uma nova rede detectada.

### Espera e novo scan

Depois de processar o scan, o programa usa `time.sleep(INTERVALO_SCAN)` e repete tudo.

## 4. main.py

O `main.py` coordena a aplicacao. Ele nao deveria concentrar toda a logica de Wi-Fi; por isso a varredura e exibicao de redes ficam em `wifi_monitor.py`, e a sincronizacao fica em `time_sync.py`.

### Imports

Exemplo pequeno:

```python
import time
import time_sync
import wifi_monitor
```

`import` carrega modulos. `time` fornece funcoes de tempo; `time_sync` cuida do NTP; `wifi_monitor` cuida do scan Wi-Fi.

### Constantes

```python
INTERVALO_SCAN = 10
UTC_OFFSET_HORAS = -3
```

Em Python, uma constante e apenas uma variavel escrita em maiusculas por convencao. O interpretador nao impede mudancas, mas o nome indica: "isto deve ser tratado como configuracao fixa".

`INTERVALO_SCAN` controla o tempo entre scans. `UTC_OFFSET_HORAS` controla a conversao para exibicao local. O RTC interno continua em UTC.

### Funcao de horario

`obter_horario()` pega o horario atual, aplica o offset apenas para exibicao e formata como:

```text
DD/MM/AAAA HH:MM:SS
```

A parte importante e ajustar o timestamp inteiro:

```python
time.localtime(time.time() + (offset_horas * 3600))
```

Isso e melhor do que fazer `hora = hora - 3`, porque mudar apenas a hora quebra perto da meia-noite. Por exemplo, `01:30 UTC - 3 horas` deve virar `22:30` do dia anterior.

### main()

`main()` e a funcao principal. Ela:

- imprime mensagens iniciais;
- tenta sincronizar o horario;
- informa se os timestamps estao em UTC ou com offset;
- prepara estruturas para detectar redes novas;
- entra no loop infinito de monitoramento.

### redes_conhecidas

`redes_conhecidas` e um `set`. Um `set` e uma colecao sem itens duplicados. Isso e util para saber rapidamente se um BSSID ja foi visto.

Exemplo:

```python
vistos = set()
vistos.add("aa:bb:cc:dd:ee:ff")
```

### primeiro_scan

`primeiro_scan` evita alertar que todas as redes do primeiro scan sao "novas". No primeiro scan, o projeto apenas aprende o ambiente inicial.

### while True

`while True` cria um loop continuo:

```python
while True:
    fazer_algo()
```

Em firmware embarcado isso e comum, porque o dispositivo fica rodando ate ser desligado ou resetado.

### Scan

O scan e feito por:

```python
redes = wifi_monitor.escanear_redes()
```

O resultado e uma lista de tuplas. Lista e uma colecao ordenada e mutavel. Tupla e uma colecao ordenada normalmente usada para representar um registro fixo.

### Deteccao de novas redes

Para cada rede, o codigo pega o BSSID e compara com `redes_conhecidas`. Se ainda nao estava la, imprime um alerta com timestamp.

### Timestamps

O monitor registra:

- `SCAN INICIADO EM`;
- `SCAN FINALIZADO EM`;
- `HORARIO DA DETECCAO`.

Esses horarios sao legiveis para humanos e usam o offset de exibicao configurado.

### sleep

`time.sleep(INTERVALO_SCAN)` pausa a execucao por alguns segundos antes do proximo scan.

### Conceitos Python importantes

- Variavel: nome que aponta para um valor, como `redes`.
- Constante: variavel tratada por convencao como fixa, como `INTERVALO_SCAN`.
- Funcao: bloco reutilizavel definido com `def`.
- `return`: devolve um valor para quem chamou a funcao.
- `while`: repete enquanto uma condicao for verdadeira.
- `for`: percorre itens de uma colecao.
- `if`: executa um bloco se a condicao for verdadeira.
- `set`: colecao sem duplicatas.
- `list`: colecao ordenada, como a lista de redes retornada pelo scan.
- `tuple`: sequencia fixa, como cada rede retornada por `wlan.scan()`.

## 5. wifi_monitor.py

Um modulo Python e um arquivo `.py` que pode ser importado por outro arquivo. `wifi_monitor.py` existe para separar a logica de Wi-Fi do fluxo principal.

Essa separacao ajuda porque:

- `main.py` fica mais facil de ler;
- funcoes de Wi-Fi podem ser testadas ou alteradas separadamente;
- a arquitetura fica mais modular;
- evitamos duplicar processamento de SSID, BSSID, RSSI e seguranca.

### network.WLAN

`network.WLAN` e a interface de rede Wi-Fi do MicroPython.

```python
wlan = network.WLAN(network.WLAN.IF_STA)
wlan.active(True)
```

`IF_STA` significa interface Station. Modo Station e quando o ESP32 age como cliente Wi-Fi, isto e, um dispositivo que pode se conectar a um roteador ou escanear redes proximas.

### wlan.scan()

`wlan.scan()` retorna redes visiveis ao ESP32. Em MicroPython no ESP32, cada item costuma ter estrutura parecida com:

```python
(ssid, bssid, channel, rssi, authmode, hidden)
```

### SSID

SSID significa Service Set Identifier. E o nome da rede Wi-Fi mostrado para usuarios.

No scan, o SSID vem em bytes:

```python
ssid = rede[0].decode("utf-8")
```

Bytes sao dados brutos. `str` e texto. O `.decode("utf-8")` transforma bytes em texto.

### BSSID

BSSID e o identificador do ponto de acesso, geralmente baseado no MAC address do radio Wi-Fi.

O projeto usa `binascii.hexlify()` para transformar bytes em algo legivel:

```python
binascii.hexlify(bssid, ":").decode("utf-8")
```

### Canal

Canal e a faixa usada pela rede Wi-Fi. Em 2.4 GHz, canais comuns incluem 1, 6 e 11.

### RSSI

RSSI significa Received Signal Strength Indicator. E uma medida da intensidade do sinal, normalmente em dBm. Valores mais proximos de zero sao melhores.

Exemplo simples:

```text
-45 dBm -> forte
-70 dBm -> medio
-85 dBm -> fraco
```

### Seguranca

O campo `authmode` informa o tipo de seguranca. O projeto traduz codigos para nomes como:

- `OPEN`;
- `WEP`;
- `WPA-PSK`;
- `WPA2-PSK`;
- `WPA/WPA2-PSK`.

### Rede oculta

O campo `hidden` indica se a rede e anunciada normalmente ou se tenta ocultar o SSID. Rede oculta nao significa rede segura; significa apenas que o nome pode nao ser anunciado do jeito comum.

### Classificacao de sinal

`classificar_sinal()` transforma RSSI em categorias simples:

- `FORTE`;
- `MEDIO`;
- `FRACO`.

Essa classificacao e didatica e util para leitura no terminal.

## 6. time_sync.py

O ESP32 pode iniciar com uma data incorreta, como algo perto de 01/01/2000, porque ele nao tem um relogio permanente alimentado por bateria como muitos computadores. Ao reiniciar, o relogio interno precisa ser ajustado.

### RTC

RTC significa Real-Time Clock, ou relogio de tempo real. No ESP32 com MicroPython, ele guarda a data/hora atual enquanto o sistema esta ligado.

### NTP

NTP significa Network Time Protocol. Ele permite perguntar a servidores na internet qual e a hora atual.

O NTP normalmente trabalha em UTC. UTC significa Coordinated Universal Time, uma referencia global de horario sem fuso local aplicado.

### Conexao Wi-Fi autorizada

Para sincronizar por NTP, o ESP32 precisa de internet. O modulo `time_sync.py` tenta carregar SSID e senha de `wifi_secrets.py`, ativa a interface Wi-Fi em modo Station e conecta.

O codigo nao imprime a senha.

### Timeout

Timeout e um limite de espera. Sem timeout, o firmware poderia ficar preso tentando conectar para sempre. O projeto usa um limite de tempo para a conexao Wi-Fi antes de desistir e continuar.

### Tratamento de falha

Falhas esperadas:

- arquivo de credenciais ausente;
- senha incorreta;
- rede fora de alcance;
- NTP temporariamente indisponivel;
- timeout de rede.

O monitor deve continuar mesmo nesses casos. Isso e importante porque observar redes Wi-Fi ainda e util mesmo se o horario nao foi sincronizado naquele boot.

### UTC_OFFSET_HORAS

`UTC_OFFSET_HORAS` e a configuracao explicita para exibicao local. No estado atual, ela esta em `-3`.

O RTC fica em UTC. A conversao para horario local ocorre so quando o texto do timestamp e produzido.

### Por que nao fazer hora - 3

Fazer apenas:

```python
hora = hora - 3
```

quebra quando o horario passa para o dia anterior. Ajustar o timestamp inteiro permite que `time.localtime()` recalcule dia, mes e ano corretamente.

## 7. Credenciais

A arquitetura de segredos separa tres coisas:

```text
Host local fora do projeto:
  $HOME\.cybersecurity-box\wifi_secrets.py

Exemplo versionavel:
  firmware/esp32/wifi_secrets.example.py

Arquivo no ESP32:
  /wifi_secrets.py
```

### Arquivo real fora do projeto

O arquivo real fica fora do repositorio e fora do workspace. Ele deve ser criado manualmente pelo usuario.

Formato:

```python
WIFI_SSID = "..."
WIFI_PASSWORD = "..."
```

Os valores reais nao devem aparecer em documentacao, commits, terminal compartilhado ou arquivos versionados.

### Arquivo de exemplo

`wifi_secrets.example.py` mostra apenas o formato esperado:

```python
WIFI_SSID = "your_wifi_name"
WIFI_PASSWORD = "your_wifi_password"
```

Esse arquivo pode ir para o Git porque nao contem senha real.

### Arquivo no ESP32

No ESP32, `time_sync.py` importa `/wifi_secrets.py`. Esse arquivo existe apenas no filesystem da placa, nao no repositorio.

### Por que nao deixar senha no projeto

Repositorios costumam ser compartilhados, sincronizados e historizados. Uma senha commitada pode continuar aparecendo no historico mesmo depois de removida.

### Por que .gitignore nao basta

`.gitignore` ajuda a evitar commits acidentais, mas nao e a unica protecao. Um arquivo pode ser copiado manualmente, exibido no terminal ou incluido por engano antes de ser ignorado. Por isso o desenho do projeto tambem evita colocar o segredo dentro do workspace.

### Por que o Codex nao precisa ver a senha

O agente so precisa saber onde o arquivo esta e como envia-lo para o ESP32. Ele nao precisa abrir o arquivo nem conhecer SSID ou senha reais.

### upload-secrets.ps1 conceitualmente

O script:

1. recebe `-Port` e `-SecretsPath`;
2. usa um caminho padrao fora do repositorio;
3. verifica que o arquivo existe;
4. envia o arquivo para `:wifi_secrets.py` no ESP32;
5. confirma existencia com `os.stat()`;
6. nao imprime conteudo.

## 8. Automacao com mpremote

`mpremote` e uma ferramenta para conversar com dispositivos MicroPython pelo cabo serial. Ela permite copiar arquivos, executar comandos, abrir REPL e resetar a placa.

O projeto usa:

```powershell
py -m mpremote
```

Isso chama o modulo Python `mpremote` pelo launcher `py`, sem depender de um executavel `mpremote` estar no PATH.

### COM3

`COM3` e a porta serial atual do ESP32 no Windows. O numero pode mudar se a placa for reconectada ou se outro dispositivo USB serial for usado.

### Filesystem do ESP32

O ESP32 com MicroPython tem um filesystem interno. Arquivos como `main.py`, `wifi_monitor.py` e `time_sync.py` sao copiados para a raiz desse filesystem.

### upload

Upload copia arquivos do PC para o ESP32:

```powershell
py -m mpremote connect COM3 fs cp arquivo.py :arquivo.py
```

### exec

`exec` executa um trecho de Python diretamente no ESP32:

```powershell
py -m mpremote connect COM3 exec "print('ok')"
```

### soft-reset

Soft reset reinicia o ambiente MicroPython sem apagar flash:

```powershell
py -m mpremote connect COM3 soft-reset
```

### REPL

REPL significa Read-Eval-Print Loop. E um console interativo onde voce digita comandos Python e ve respostas imediatamente.

### scripts/device-info.ps1

Consulta informacoes do dispositivo:

- implementacao MicroPython;
- plataforma;
- frequencia da CPU;
- heap livre.

### scripts/reset.ps1

Executa soft reset. Nao apaga firmware, nao formata filesystem e nao reinstala MicroPython.

### scripts/repl.ps1

Abre o REPL interativo na porta configurada.

### scripts/upload.ps1

Envia firmware permitido para o ESP32:

- `wifi_monitor.py`;
- `time_sync.py`;
- `main.py`.

`main.py` vai por ultimo, porque ele e o ponto de entrada.

Esse script nao envia segredos automaticamente.

### scripts/upload-secrets.ps1

Envia o arquivo privado de credenciais para o ESP32, separadamente do firmware.

Essa separacao e importante: atualizar firmware nao deve implicar envio automatico de segredo.

### Fluxo substituindo upload manual

Antes, o caminho natural seria usar uma IDE manualmente. Agora o fluxo e reprodutivel:

```text
VS Code Task
  -> PowerShell
  -> py -m mpremote
  -> USB/COM3
  -> filesystem do ESP32
```

Isso ajuda tanto o usuario quanto o Codex, porque o processo vira comando repetivel.

## 9. VS Code

`.vscode/tasks.json` define tarefas que aparecem no VS Code.

As tarefas atuais incluem:

- `ESP32: Upload Firmware`;
- `ESP32: Upload Secrets`;
- `ESP32: Device Info`;
- `ESP32: Soft Reset`;
- `ESP32: REPL`.

Cada tarefa chama `powershell` com:

```powershell
-ExecutionPolicy Bypass -File
```

e aponta para um script dentro de `${workspaceFolder}`. Isso evita caminhos absolutos dependentes da maquina.

### Como isso ajuda no desenvolvimento

O usuario nao precisa memorizar todos os comandos. A tarefa encapsula detalhes como porta, script e argumentos.

### Como isso ajuda o Codex

O Codex consegue executar validacoes e uploads por comandos previsiveis, em vez de depender de cliques manuais no editor.

## 10. Git e GitHub

Git registra a evolucao do projeto em commits. GitHub hospeda o repositorio remoto.

Fluxo basico:

```text
working directory
  -> git diff
  -> git add
  -> staging area
  -> git diff --staged
  -> git commit
  -> git push
```

### Working directory

E o estado dos arquivos no disco. Quando voce edita um arquivo, a mudanca aparece aqui.

### git diff

Mostra o que mudou nos arquivos rastreados antes de entrar no staging.

### git add

Move mudancas para a staging area. Isso prepara o que entrara no proximo commit.

### Staging area

E a area de preparacao do commit. Permite escolher exatamente quais arquivos ou trechos entram.

### git diff --staged

Mostra o que esta preparado para commit.

### git commit

Cria um registro permanente local com as mudancas staged.

### git push

Envia commits locais para o remoto, como `origin`.

### Branch main

`main` e a linha principal do projeto. Normalmente representa uma versao mais estavel.

### Branch chore/project-structure

Branch atual usada para organizar estrutura, automacao, NTP, timestamps e documentacao.

### origin/main

`origin/main` e a referencia local para o estado da branch `main` no GitHub.

### Tag v0.1.0

Tag e um marcador fixo no historico. `v0.1.0` marca uma versao inicial do projeto.

### Conventional Commits

Conventional Commits e uma convencao de mensagens:

- `feat:` nova funcionalidade;
- `fix:` correcao de bug;
- `refactor:` reorganizacao sem mudar comportamento esperado;
- `chore:` tarefa de manutencao;
- `docs:` documentacao.

O historico recente mostra a evolucao por pequenos passos: scanner Wi-Fi, modularizacao, loop continuo, estrutura para agentes, automacao de upload, segredos e NTP.

## 11. Codex e agentes

### Papel do AGENTS.md

`AGENTS.md` e o contrato de trabalho para agentes. Ele reduz ambiguidade e define limites de seguranca.

### Por que criar documentacao

Documentacao transforma conhecimento temporario em conhecimento reutilizavel. Isso ajuda o usuario, novos colaboradores e agentes futuros.

### O que e um handoff

Handoff e uma entrega de contexto: o que ja existe, o que falta, quais comandos usar e quais limites respeitar.

### Como o Codex recebe uma tarefa

Fluxo tipico:

```text
Usuario define objetivo
  -> Codex le contexto
  -> Codex analisa Git
  -> Codex implementa
  -> Codex testa
  -> Codex mostra diff
  -> Usuario revisa
  -> Usuario faz commit
```

### Por que nao fazer commit/push automaticamente

Commit e push registram e publicam mudancas. O usuario deve revisar antes, especialmente em projeto com hardware e seguranca.

### Chat/autocomplete vs agente

Como chat, a IA responde perguntas. Como autocomplete, sugere trechos enquanto voce digita. Como agente de desenvolvimento, ela le arquivos, edita, executa comandos, testa e relata resultados.

### Agente embedded-dev

Foca em firmware, MicroPython, comunicacao com dispositivo, hardware e limitacoes do ESP32.

### Agente reviewer

Foca em riscos: compatibilidade, memoria, loops infinitos, bloqueios, seguranca, segredos e manutencao.

## 12. Estado atual do projeto

### Hardware

- ESP32 WROOM-32.
- Conexao serial atual por USB/COM3.
- MicroPython 1.28.0, firmware ESP32_GENERIC.

### Firmware

- `main.py` como ponto de entrada.
- `wifi_monitor.py` para scan e exibicao.
- `time_sync.py` para Wi-Fi autorizado e NTP.

### Wi-Fi Monitor

- Scan passivo de redes proximas.
- Exibicao de SSID, BSSID, canal, RSSI, seguranca e rede oculta.
- Classificacao de sinal.
- Monitoramento continuo.
- Deteccao de novas redes por BSSID.

### Horario/NTP

- RTC sincronizado por NTP em UTC quando possivel.
- Offset local explicito em `UTC_OFFSET_HORAS`.
- Timestamps legiveis em scans e novas deteccoes.
- Falha segura quando NTP nao esta disponivel.

### Seguranca

- Credenciais reais ficam fora do repositorio.
- `.gitignore` ignora `wifi_secrets.py`.
- `upload.ps1` nao envia segredos.
- `upload-secrets.ps1` envia segredos separadamente sem imprimir conteudo.

### Automacao

- Scripts PowerShell para device info, reset, REPL, upload de firmware e upload de segredos.
- Uso padronizado de `py -m mpremote`.

### Git

- Branch atual: `chore/project-structure`.
- Branch remota correspondente: `origin/chore/project-structure`.
- Branch `main` e `origin/main` existem.
- Tag `v0.1.0` existe.

### Agentes

- Regras canonicas em `AGENTS.md`.
- Perfis locais em `.agents/`.
- Fluxo pensado para agente implementar e usuario revisar.

### Inconsistencias relevantes encontradas

- `README.md` ainda diz "Timestamp development in progress", mas o codigo atual ja possui NTP e timestamps locais. A frase pode ser atualizada em uma etapa de documentacao.
- O historico tem um commit com typo: `refacotr`. Isso nao quebra o projeto, mas e uma pequena inconsistencia no historico.
- Existe `firmware/esp32/__pycache__/` no workspace. Ele esta ignorado pelo Git, mas nao faz parte do firmware que deve ser enviado.

## 13. Conceitos que ja foram praticados

### Python

- Variaveis.
- Constantes por convencao.
- Funcoes.
- Imports.
- Strings.
- Listas.
- Tuplas.
- Sets.
- Condicionais.
- Loops.
- Formatacao de texto.

### MicroPython

- Execucao de `main.py`.
- Modulos especificos como `network`, `ntptime`, `machine`.
- Limitacoes de biblioteca e memoria.
- Filesystem interno do microcontrolador.

### ESP32

- Porta serial.
- Soft reset.
- Firmware MicroPython.
- Wi-Fi em modo Station.
- Scan de redes.

### Redes

- SSID.
- BSSID.
- Canal Wi-Fi.
- RSSI.
- Modos de seguranca.
- NTP.
- UTC e horario local.

### Git

- Branch.
- Commit.
- Tag.
- Remote.
- `git status`.
- `git diff`.
- Conventional Commits.

### PowerShell

- Parametros de script.
- Execucao com `-File`.
- Uso de `$HOME`.
- Verificacao de existencia de arquivo.
- Chamadas externas com `&`.

### VS Code

- Tasks.
- `${workspaceFolder}`.
- Integracao entre editor e terminal.

### Seguranca

- Separacao de segredos.
- Uso de `.gitignore`.
- Principio de menor exposicao.
- Operacoes passivas por padrao.

### Engenharia de software

- Modularizacao.
- Responsabilidades separadas.
- Pequenas alteracoes incrementais.
- Revisao antes de commit.
- Automacao reprodutivel.

## 14. Pontos para estudar melhor

### Fundamental

- Como `main.py` e executado automaticamente no MicroPython.
- Diferenca entre Python do PC e MicroPython do ESP32.
- `while True`, `for`, `if`, funcoes e `return`.
- Como funciona `set` para detectar itens ja vistos.
- O que sao SSID, BSSID, RSSI e canal.
- Como usar `git status`, `git diff`, `git add` e `git commit`.

### Intermediario

- `network.WLAN` e modos de operacao Wi-Fi.
- Estrutura completa retornada por `wlan.scan()`.
- NTP, RTC e UTC.
- Timeouts e tratamento de excecoes.
- Como PowerShell chama programas externos.
- Como `mpremote` copia arquivos e executa codigo.
- Como organizar segredos fora do repositorio.

### Pode esperar

- Logging persistente em flash.
- Rotacao de logs.
- Banco de dados no Raspberry Pi.
- Protocolos de comunicacao ESP32 -> host.
- Dashboard web.
- Analise estatistica de eventos.
- Empacotamento de releases.

## 15. Proximas etapas

Sem implementar agora, o roadmap tecnico mais provavel e:

### Logging persistente

Registrar eventos importantes em arquivo ou em uma fila simples:

- scan iniciado;
- scan finalizado;
- nova rede detectada;
- falha de NTP;
- horario de boot.

### Eventos

Transformar prints em eventos estruturados. Exemplo conceitual:

```python
evento = {
    "tipo": "nova_rede",
    "horario": "...",
    "bssid": "..."
}
```

Em MicroPython, talvez seja melhor usar estruturas mais simples do que dicionarios grandes, por memoria.

### Armazenamento

Definir onde guardar dados:

- temporariamente no ESP32;
- em arquivo;
- enviado para PC;
- futuramente enviado ao Raspberry Pi.

### Comunicacao ESP32 -> PC/Raspberry Pi

Possiveis caminhos:

- serial USB;
- Wi-Fi HTTP;
- MQTT;
- UDP local;
- protocolo proprio simples.

### Dashboard

Um painel pode mostrar:

- redes vistas;
- redes novas;
- intensidade de sinal;
- historico por horario;
- alertas.

### Raspberry Pi Cybersecurity Box

O Raspberry Pi pode virar o controlador central:

- recebe dados de um ou mais ESP32;
- armazena eventos;
- roda dashboard;
- centraliza configuracao;
- prepara caminho para novos modulos.

## 16. Diagrama final

```text
                           +-------------------+
                           |      Usuario      |
                           +---------+---------+
                                     |
                                     v
                           +-------------------+
                           |      VS Code      |
                           |  tasks.json       |
                           +---------+---------+
                                     |
                  +------------------+------------------+
                  |                                     |
                  v                                     v
        +-------------------+                 +-------------------+
        |       Codex       |                 |        Git        |
        | le contexto       |                 | status/diff/log   |
        | implementa/testa  |                 | commit pelo user  |
        +---------+---------+                 +-------------------+
                  |
                  v
        +-------------------+
        |    PowerShell     |
        | scripts/*.ps1     |
        +---------+---------+
                  |
                  v
        +-------------------+
        | py -m mpremote    |
        | fs cp / exec      |
        | soft-reset / repl |
        +---------+---------+
                  |
                  v
        +-------------------+
        |     USB / COM3    |
        +---------+---------+
                  |
                  v
        +-------------------+
        |       ESP32       |
        | MicroPython 1.28  |
        +---------+---------+
                  |
      +-----------+-----------+
      |           |           |
      v           v           v
+-----------+ +-------------+ +-------------+
|  main.py  | |wifi_monitor | | time_sync   |
| loop      | | scan Wi-Fi  | | Wi-Fi + NTP |
| timestamps| | RSSI/BSSID  | | RTC em UTC  |
+-----+-----+ +------+------+ +------+------+
      |              |               |
      |              v               v
      |      +---------------+ +-------------+
      |      | Redes Wi-Fi   | | Servidor NTP|
      |      | proximas      | | UTC         |
      |      +---------------+ +-------------+
      |
      v
+-------------------------------+
| Saida serial / terminal       |
| SCAN INICIADO EM              |
| SCAN FINALIZADO EM            |
| HORARIO DA DETECCAO           |
+-------------------------------+
```


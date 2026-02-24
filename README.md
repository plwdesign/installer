## Primeira instalação (comando único)

```bash
sudo apt update && sudo apt upgrade -y
```

```bash
sudo apt install -y git && git clone https://github.com/plwdesign/installer.git && cd installer && chmod +x install.sh install_primaria install_instancia scripts/*.sh && sudo ./install.sh
```

Escolha a opção **1** (Instalação primária). A instância será criada em `/home/deploy/NOME` (ex: `/home/deploy/gruposzap`).

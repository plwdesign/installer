# Instalador - WhatsApp Group Sender SaaS

## Erro: `$'\r': command not found`

Se aparecer esse erro (line endings Windows no Linux), execute no servidor:

```bash
cd /root/installer
sed -i 's/\r$//' variables/*.sh lib/*.sh utils/*.sh scripts/*.sh install.sh install_primaria install_instancia fix-crlf.sh 2>/dev/null
```

Depois rode o instalador novamente.

Instalador estilo [Whaticket SaaS](https://github.com/plwdesign/instaladorwhatsapsaas-main-new) para deploy em servidor Linux (Ubuntu/Debian).

**GP** - Inserir em meu installer | Nginx • Certbot • PM2 • PostgreSQL • Node.js

## Pré-requisitos

- Ubuntu 20.04+ ou Debian 11+
- Acesso root (sudo)
- Domínio apontando para o IP do servidor (para SSL)
- Repositório Git do projeto

## Menu principal (recomendado)

```bash
cd automacao/installer
chmod +x install.sh install_primaria install_instancia scripts/*.sh
sudo ./install.sh
```

### Opções do menu

| Opção | Descrição |
|-------|-----------|
| 1 | **Instalação primária** - Instalar do zero (Nginx, Certbot, SSL) |
| 2 | **Nova instância** - Adicionar outra instância no servidor |
| 3 | **Trocar domínio** - Alterar domínios API/App e gerar novo SSL |
| 4 | **Remover instalação** - Parar PM2, remover Nginx, opcional: banco/dados |
| 5 | **Atualizar** - Puxar alterações do GitHub e recompilar |
| 6 | **Ver portas ocupadas** - Listar portas em uso para evitar conflito entre instâncias |
| 0 | Sair |

## Primeira instalação (comando único)

```bash
sudo apt update && sudo apt upgrade -y
```

```bash
sudo apt install -y git && git clone https://github.com/SEU_USUARIO/automacao.git && cd automacao/installer && chmod +x install.sh install_primaria install_instancia scripts/*.sh && sudo ./install.sh
```

Escolha a opção **1** (Instalação primária). A instância será criada em `/home/deploy/NOME` (ex: `/home/deploy/gruposzap`).

### Perguntas durante a instalação

| Campo | Exemplo | Descrição |
|-------|---------|-----------|
| Nome da instância | post01, cliente1 | Identificador único da instalação |
| URL do repositório | https://github.com/... | Git do projeto |
| Senha do banco | *** | Senha PostgreSQL para o banco |
| Usuário PostgreSQL | postgres | Usuário do banco |
| Porta do backend | 4250 | Porta da API |
| Porta do frontend | 3000 | Porta se usar PM2 para servir |
| Subdomínio backend | api.seudominio.com | Para produção com Nginx |
| Subdomínio frontend | app.seudominio.com | Para produção com Nginx |
| E-mail admin | admin@admin.com | Login do SuperAdmin |
| Senha admin | *** | Senha do SuperAdmin |
| **Redis** | | |
O instalador usa **Redis** em 127.0.0.1 com a **mesma senha do PostgreSQL** (configuração fixa; não é perguntado).

O WhatsApp usa **libzapitu-rf** (API direta, nova API). Não são usados whatsapp-web.js nem Chrome/Puppeteer; sessões e autenticação ficam no **PostgreSQL** (tabela WhatsappAuthState).

### Subdomínios

Antes de rodar o instalador, configure os DNS:
- `api.seudominio.com` → IP do servidor
- `app.seudominio.com` → IP do servidor

O Certbot solicitará certificado SSL automaticamente após a instalação.

## Instalações adicionais (múltiplas instâncias)

No menu principal, opção **2** (Nova instância), ou diretamente:

```bash
cd automacao/installer
sudo ./install_instancia
```

Será solicitado o nome da nova instância, senha do banco e subdomínios. Cada instância usa portas e bancos diferentes.

**Ver portas ocupadas (menu 7):** antes de instalar uma nova instância, use a opção **7** para listar quais portas estão em uso (80, 443, 5432, 6379, 3000, 3999, 4250, 5173) e evitar conflito.

## Trocar domínio

Para alterar os domínios (ex: migrar para novo domínio) e gerar novo certificado SSL:

```bash
sudo ./install.sh
# Opção 3 (Trocar domínio)
```

Ou diretamente: `sudo ./scripts/trocar_dominio.sh`

## Remover instalação

Para remover uma instância (PM2, Nginx, banco e/ou arquivos):

```bash
sudo ./install.sh
# Opção 4 (Remover instalação)
```

Será perguntado o que remover: processos PM2, configs Nginx, banco de dados e arquivos.

## Redis e backend

O backend usa **Redis** para filas (BullMQ) e blocklist. O instalador:

- Instala sempre a **versão mais recente** do Redis (repositório oficial).
- Usa **127.0.0.1:6379** com a **mesma senha do PostgreSQL** (REDIS_URI no .env).
- Configura `requirepass` no Redis com a senha do banco automaticamente.

O `.env` do backend é gerado com REDIS_URI, rate limits e blocklist. Não são usadas variáveis CHROME_* (WhatsApp usa libzapitu-rf, sem browser).

## Estrutura após instalação

```
/home/deploy/post01/   # Nome da instância (ex: post01, gruposzap)
├── backend/
│   ├── .env
│   └── dist/
├── frontend/
│   ├── config/.env.production
│   └── dist/
└── ...
```

## Comandos úteis

```bash
# Ver processos PM2
pm2 list

# Reiniciar backend
pm2 restart post01-backend

# Logs
pm2 logs post01-backend
```

## QR Code do WhatsApp

O backend usa **libzapitu-rf** para gerar o QR (sem Chrome/Puppeteer). O QR é exibido no painel ao conectar uma sessão. Estado de autenticação fica no PostgreSQL. Se o QR não aparecer, verifique os logs do backend (`pm2 logs NOME-backend`).

## Migrations com falha

Se `prisma migrate deploy` falhar com erro P3018, execute primeiro:

```bash
cd backend
npx prisma migrate resolve --rolled-back "NOME_DA_MIGRATION_FALHADA"
npx prisma migrate deploy
```

## Configuração salva

O arquivo `installer/config` contém senhas e configurações. **Não versionar no Git.**

## Personalizar repositório

Antes de instalar, edite `installer/variables/_app.sh` e defina `REPO_URL` com a URL do seu repositório, ou informe durante o prompt.

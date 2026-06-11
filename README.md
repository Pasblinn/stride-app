# Stride App

Aplicativo full-stack de registro e rastreamento de atividades físicas, inspirado no Strava. O **frontend** é desenvolvido em **Flutter/Dart** e o **backend** em **Node.js/TypeScript** com **Express**, **TypeORM** e **PostgreSQL**. Projeto da disciplina de **Dispositivos Móveis** - UTFPR.

## Integrantes do Grupo

- Carlos Eduardo Zurlo
- Pablo Juan Tadini Soto
- Fabio Vieira

---

## Objetivo do Aplicativo

O **Stride** é um aplicativo móvel que permite aos usuários registrar, rastrear (via GPS), acompanhar e analisar suas atividades físicas de forma simples e visual. Inspirado no Strava, o app oferece funcionalidades como:

- Registro de diferentes tipos de atividades (corrida, ciclismo, caminhada, trilha, natação)
- **Rastreamento por GPS em tempo real** com desenho do trajeto sobre o mapa
- Acompanhamento de métricas (distância, duração, pace médio, calorias)
- Visualização de estatísticas gerais e semanais
- Gerenciamento de perfil de usuário com autenticação (JWT + refresh token)
- Persistência de sessão (o usuário permanece logado ao reabrir o app)

---

## Arquitetura Geral

O projeto é dividido em duas aplicações que se comunicam via API REST:

```
stride-app/
├── lib/          # Frontend Flutter (mobile / desktop / web)
├── backend/      # API REST Node.js + Express + TypeORM + PostgreSQL
├── android/ ios/ windows/ linux/ web/   # plataformas Flutter
└── README.md
```

O frontend consome a API através de [lib/services/api_service.dart](lib/services/api_service.dart) (base URL `http://localhost:3333`).

---

## Tecnologias Utilizadas

### Frontend (Flutter)
- **Flutter** 3.41+ e **Dart** 3.11+ (SDK multiplataforma)
- **Provider** (gerenciamento de estado reativo)
- **flutter_map** + **latlong2** (renderização de mapas e trajetos)
- **geolocator** (acesso ao GPS do dispositivo)
- **http** (consumo da API REST)
- **SharedPreferences** (persistência local de sessão)
- **intl** / **flutter_localizations** (formatação e localização pt-BR)

### Backend (Node.js)
- **Node.js** + **TypeScript** com **Express 5**
- **TypeORM** + **PostgreSQL** (persistência relacional + migrations)
- **JWT** (`jsonwebtoken`) com **refresh tokens** para autenticação
- **bcrypt** (hash de senhas)
- **zod** (validação de payloads)
- **tsyringe** (injeção de dependências)
- Arquitetura **modular / Clean Architecture** (domain → application → infra)

---

## Estrutura do Frontend (Padrão MVC + Provider)

O frontend adota o padrão **MVC (Model-View-Controller)** combinado com **Provider** para estado reativo.

```
lib/
├── main.dart                          # Ponto de entrada e configuração global (Providers)
├── models/                            # Camada de dados (entidades)
│   ├── user_model.dart                # Modelo de usuário
│   └── activity_model.dart            # Modelo de atividade, RoutePoint e enum ActivityType
├── controllers/                       # Camada de lógica de negócio (ChangeNotifier)
│   ├── auth_controller.dart           # Autenticação (login/cadastro/logout)
│   ├── activity_controller.dart       # CRUD de atividades + estatísticas
│   └── tracking_controller.dart       # Sessão de rastreamento GPS (start/pause/stop)
├── services/                          # Integrações externas
│   ├── api_service.dart               # Cliente HTTP da API REST
│   └── location_service.dart          # Acesso ao GPS (stream real e simulado)
├── repositories/                      # Camada de acesso a dados
│   ├── user_repository.dart
│   └── activity_repository.dart
└── views/                             # Camada de apresentação (UI)
    ├── login_page.dart                # Tela de login
    ├── register_page.dart             # Tela de cadastro
    ├── home_page.dart                 # Tela principal com BottomNavigationBar
    ├── activity_feed_page.dart        # Feed de atividades
    ├── activity_detail_page.dart      # Detalhes da atividade (com mapa do trajeto)
    ├── add_activity_page.dart         # Formulário de nova atividade
    ├── edit_activity_page.dart        # Formulário de edição
    ├── tracking_page.dart             # Tela de rastreamento ao vivo
    ├── save_tracked_activity_page.dart# Salvar atividade rastreada
    ├── stats_page.dart                # Estatísticas gerais
    ├── profile_page.dart              # Perfil do usuário
    ├── edit_profile_page.dart         # Edição de perfil
    └── widgets/
        └── route_map.dart             # Widget reutilizável de mapa com polyline
```

### Responsabilidade de cada camada

- **Model**: Classes que representam entidades do domínio (UserModel, ActivityModel, RoutePoint). Incluem serialização (`fromJson`/`toJson`) e transformação (`copyWith`).
- **View**: Widgets Flutter responsáveis pela interface. Não possuem lógica de negócio.
- **Controller**: Estende `ChangeNotifier` para notificar a UI sobre mudanças e orquestra services/repositórios.
- **Service**: Isola integrações externas (API REST e GPS).

---

## Estrutura do Backend (Clean Architecture / Modular)

Cada módulo (`auth`, `user`, `activity`) é organizado em camadas independentes:

```
backend/src/
├── app/
│   ├── app.ts                         # Configuração do Express e middlewares
│   ├── server.ts                      # Bootstrap do servidor
│   └── http/
│       ├── middlewares/               # auth e validation (zod)
│       └── routes/                    # /auth, /users, /activities
├── modules/
│   ├── auth/                          # Login, logout, refresh token
│   ├── user/                          # CRUD de usuários
│   └── activity/                      # CRUD de atividades (com trajeto GPS)
│       ├── domain/                    # Entidades e interfaces de repositório
│       ├── application/               # DTOs e use-cases
│       └── infra/                     # Controllers e repositórios TypeORM
├── db/typeorm/
│   ├── data-source.ts                 # DataSource do TypeORM
│   └── migrations/                    # Migrations (users, activity, refresh-tokens, route)
├── shared/                            # Erros, helpers e container de DI
└── config/                            # Configuração de autenticação
```

---

## Funcionalidades Implementadas

### Autenticação
- Login com validação de email e senha (mínimo 6 caracteres)
- Cadastro com confirmação de senha e verificação de email duplicado
- Senhas armazenadas com **hash bcrypt** no backend
- Autenticação via **JWT** com **refresh token** (sessão renovável)
- Logout com confirmação via AlertDialog
- **Persistência de sessão**: o usuário permanece logado ao reabrir o app

### Rastreamento por GPS
- Tela de rastreamento ao vivo com mapa (`flutter_map`)
- Acúmulo dos pontos do trajeto e cálculo de distância/duração em tempo real
- Controles de **iniciar / pausar / retomar / finalizar** a gravação
- Trajeto persistido junto à atividade (`RoutePoint` → coluna `route`)
- Visualização do trajeto no detalhe da atividade (polyline sobre o mapa)
- Modo **simulado** para demonstração no navegador/desktop (onde a posição é fixa)

### Navegação
- `Navigator.push/pop`, `pushReplacement`
- `BottomNavigationBar` com 3 abas (Atividades, Estatísticas, Perfil)
- `FloatingActionButton` central para adicionar/rastrear atividade

### Formulários, Validações e Feedback
- Formulários completos com `GlobalKey<FormState>` e validações customizadas
- `DropdownButtonFormField` e `showDatePicker` localizado em pt-BR
- `SnackBar` (sucesso/erro) e `AlertDialog` (confirmações críticas)

### Interface
- Design consistente com tema Material 3 (paleta deepOrange)
- Cards com gradientes e sombras, suporte completo a pt-BR
- Layout responsivo

---

## Como Executar o Projeto

### Pré-requisitos
- **Flutter SDK** 3.41+ ([instalar Flutter](https://docs.flutter.dev/get-started/install))
- **Node.js** 18+ e **npm**
- **PostgreSQL** (local ou em container Docker)
- Para Windows: Visual Studio com workload "Desktop development with C++"
- Para Android: Android Studio com SDK instalado

### 1. Clonar o repositório

```bash
git clone https://github.com/Pasblinn/stride-app.git
cd stride-app
```

### 2. Subir o Backend

```bash
cd backend
npm install

# Crie um arquivo .env na pasta backend/ com as variáveis abaixo
npm run migration:run   # cria as tabelas no PostgreSQL
npm run dev             # inicia a API em modo desenvolvimento (porta API_PORT)
```

Exemplo de `backend/.env`:

```env
API_PORT=3333
DB_PORT=5432
DB_USERNAME=postgres
DB_PASSWORD=postgres
DB_NAME=stride
AUTH_SECRET=sua_chave_secreta
AUTH_SECRET_EXPIRES_IN=15m
AUTH_REFRESH_SECRET=sua_chave_refresh
AUTH_REFRESH_SECRET_EXPIRES_IN=7d
```

Rotas principais: `/auth`, `/users`, `/activities`.

### 3. Rodar o Frontend (Flutter)

```bash
# a partir da raiz do projeto
flutter pub get

flutter run                 # dispositivo/emulador conectado
flutter run -d windows      # Windows Desktop
flutter run -d chrome       # Navegador (web)
```

> O frontend aponta para `http://localhost:3333` em [api_service.dart](lib/services/api_service.dart). Para rodar em emulador Android, ajuste a `baseUrl` para `http://10.0.2.2:3333`.

### Gerando builds de produção

```bash
flutter build apk            # APK Android
flutter build windows        # Executável Windows
flutter build web            # Build web

cd backend && npm run build  # Compila o backend (dist/) — depois: npm start
```

---

## Dependências do Frontend (pubspec.yaml)

| Pacote | Versão | Finalidade |
|--------|--------|------------|
| `provider` | ^6.1.2 | Gerenciamento de estado reativo |
| `flutter_map` | ^8.3.0 | Renderização de mapas |
| `latlong2` | ^0.9.1 | Coordenadas geográficas (LatLng) |
| `geolocator` | ^14.0.2 | Acesso ao GPS do dispositivo |
| `http` | ^1.2.0 | Consumo da API REST |
| `shared_preferences` | ^2.5.4 | Persistência local da sessão |
| `intl` | ^0.20.2 | Formatação de datas |
| `flutter_localizations` | SDK | Localização pt-BR |
| `cupertino_icons` | ^1.0.8 | Ícones estilo iOS |

---

## Informações do Projeto

- **Disciplina:** Dispositivos Móveis
- **Instituição:** Universidade Tecnológica Federal do Paraná (UTFPR)
</content>
</invoke>

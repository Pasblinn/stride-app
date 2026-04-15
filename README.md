# Stride App

Aplicativo de registro de atividades físicas desenvolvido em **Flutter** com **Dart**, inspirado no Strava. Projeto da disciplina de **Dispositivos Móveis** - UTFPR.

## Integrantes do Grupo

- Carlos Eduardo Zurlo
- Pablo Juan Tadini Soto
- Fabio Vieira

---

## Objetivo do Aplicativo

O **Stride** é um aplicativo móvel que permite aos usuários registrar, acompanhar e analisar suas atividades físicas de forma simples e visual. Inspirado no Strava, o app oferece funcionalidades como:

- Registro de diferentes tipos de atividades (corrida, ciclismo, caminhada, trilha, natação)
- Acompanhamento de métricas (distância, duração, pace médio, calorias)
- Visualização de estatísticas gerais e semanais
- Gerenciamento de perfil de usuário com autenticação
- Persistência de sessão (o usuário permanece logado ao reabrir o app)

---

## Tecnologias Utilizadas

- **Flutter** 3.41+ (SDK para desenvolvimento mobile multiplataforma)
- **Dart** 3.11+
- **Provider** (gerenciamento de estado reativo)
- **SharedPreferences** (persistência local de sessão)
- **intl** (formatação de datas em português)
- **flutter_localizations** (suporte a pt-BR para DatePicker)

---

## Estrutura do Projeto (Padrão MVC + Provider)

O projeto adota o padrão arquitetural **MVC (Model-View-Controller)** combinado com **Provider** para gerenciamento de estado reativo, garantindo separação de responsabilidades e facilidade de manutenção.

```
lib/
├── main.dart                          # Ponto de entrada e configuração global
├── models/                            # Camada de dados (entidades)
│   ├── user_model.dart                # Modelo de usuário
│   └── activity_model.dart            # Modelo de atividade + enum ActivityType
├── controllers/                       # Camada de lógica de negócio
│   ├── auth_controller.dart           # Autenticação (login/cadastro/logout)
│   └── activity_controller.dart       # CRUD de atividades + estatísticas
├── repositories/                      # Camada de acesso a dados
│   ├── user_repository.dart           # Dados de usuários em memória
│   └── activity_repository.dart       # Dados de atividades em memória
└── views/                             # Camada de apresentação (UI)
    ├── login_page.dart                # Tela de login
    ├── register_page.dart             # Tela de cadastro
    ├── home_page.dart                 # Tela principal com BottomNavigationBar
    ├── activity_feed_page.dart        # Feed de atividades
    ├── activity_detail_page.dart      # Detalhes da atividade
    ├── add_activity_page.dart         # Formulário de nova atividade
    ├── edit_activity_page.dart        # Formulário de edição
    ├── stats_page.dart                # Estatísticas gerais
    ├── profile_page.dart              # Perfil do usuário
    └── edit_profile_page.dart         # Edição de perfil
```

### Responsabilidade de cada camada

- **Model**: Classes imutáveis que representam entidades do domínio (UserModel, ActivityModel). Contêm apenas dados e métodos de transformação (`copyWith`).
- **View**: Widgets Flutter responsáveis pela interface. Não possuem lógica de negócio.
- **Controller**: Estende `ChangeNotifier` para notificar a UI sobre mudanças. Contém a lógica do app e orquestra chamadas aos repositórios.
- **Repository**: Isola o acesso aos dados. Atualmente usa listas em memória, podendo ser substituído por banco de dados sem impacto nas outras camadas.

---

## Funcionalidades Implementadas

### Autenticação
- Login com validação de email (RegExp) e senha (mínimo 6 caracteres)
- Cadastro com confirmação de senha e verificação de email duplicado
- Logout com confirmação via AlertDialog
- **Persistência de sessão**: o usuário permanece logado ao fechar e reabrir o app

### Navegação
- `Navigator.push/pop` para navegação em pilha
- `Navigator.pushReplacement` para substituição de telas (login → home, logout → login)
- `BottomNavigationBar` com 3 abas principais (Atividades, Estatísticas, Perfil)
- `FloatingActionButton` central para adicionar nova atividade

### Formulários e Validações
- 5 formulários completos com validação: login, cadastro, nova atividade, editar atividade, editar perfil
- `GlobalKey<FormState>` para controle de validação
- `TextEditingController` para captura de entrada
- Validações customizadas por campo (email, senha, números, intervalos)
- `DropdownButtonFormField` para seleção de tipo de atividade
- `showDatePicker` com localização pt-BR

### Feedback ao Usuário
- `SnackBar` para mensagens de sucesso (verde) e erro (vermelho)
- `AlertDialog` para confirmações críticas (exclusão, logout)
- Mensagens de erro específicas em cada campo de formulário
- Estados de loading e vazio tratados na UI

### Interface
- 10 telas com design consistente
- Tema Material 3 com paleta personalizada (deepOrange)
- Cards com gradientes e sombras
- Suporte completo a português (pt-BR) incluindo DatePicker
- Layout responsivo com `SingleChildScrollView` e `Expanded`

---

## Como Executar o Projeto

### Pré-requisitos
- Flutter SDK 3.41 ou superior ([instalar Flutter](https://docs.flutter.dev/get-started/install))
- Dart SDK (incluso no Flutter)
- Para rodar no Windows: Visual Studio com workload "Desktop development with C++"
- Para rodar no Android: Android Studio com SDK instalado

### Passos para executar

```bash
# 1. Clone o repositório
git clone https://github.com/Pasblinn/stride-app.git
cd stride-app

# 2. Instale as dependências
flutter pub get

# 3. Execute o app na plataforma desejada
flutter run                 # dispositivo/emulador conectado
flutter run -d windows      # Windows Desktop
flutter run -d chrome       # Navegador (web)
```

### Gerando builds de produção

```bash
flutter build apk            # Gera APK Android (build/app/outputs/flutter-apk/app-release.apk)
flutter build windows        # Gera executável Windows (build/windows/x64/runner/Release/)
flutter build web            # Gera build web (build/web/)
```

### Credenciais para teste

Ao abrir o app pela primeira vez, use as seguintes credenciais pré-cadastradas:

- **Email:** `pablo@gmail.com`
- **Senha:** `123456`

Ou cadastre-se como um novo usuário pela tela de cadastro.

---

## Dependências (pubspec.yaml)

| Pacote | Versão | Finalidade |
|--------|--------|------------|
| `provider` | ^6.1.2 | Gerenciamento de estado reativo (ChangeNotifier, Consumer) |
| `shared_preferences` | ^2.3.3 | Persistência local da sessão do usuário |
| `intl` | ^0.20.2 | Formatação de datas (DateFormat) |
| `flutter_localizations` | SDK | Localização pt-BR (DatePicker, Material) |
| `cupertino_icons` | ^1.0.8 | Ícones estilo iOS |

---

## Informações do Projeto

- **Disciplina:** Dispositivos Móveis
- **Instituição:** Universidade Tecnológica Federal do Paraná (UTFPR)


Compreendido. Fiz as alterações solicitadas, incluindo a reorganização das seções e o ajuste no formato de instalação.

Aqui está o `README` revisado:

-----

# GIF Flutter: Aplicação de Busca e Gerenciamento de GIFs

Um aplicativo mobile nativo, desenvolvido em **Flutter**, para buscar, visualizar e organizar GIFs utilizando a API do Giphy. O projeto implementa persistência local e um gerenciamento de estado eficiente para uma experiência completa de usuário.

-----

## ⚙️ Instalação e Execução

### 1\. Configuração da API do Giphy

A chave da API deve ser inserida durante a inicialização do `GifsController` no arquivo **`lib/main.dart`**:

```dart
// Exemplo em main.dart
GifsController(
  GiphyService(apiKey: '<SUA_API_KEY_AQUI>'),
)
```

### 2\. Passos de Instalação

```bash
# Clone o repositório
git clone <https://github.com/MMarcooss/gif_flutter.git>
cd gif_flutter

# Instale as dependências
flutter pub get

# Execute o aplicativo em um dispositivo ou emulador
flutter run
```

-----

## Funcionalidades

O aplicativo inclui as seguintes funcionalidades principais:

  \* **Busca por Palavra-Chave:** Pesquisa de GIFs por tags e termos.
  \* **Visualização Aleatória:** Tela de GIFs aleatórios com funcionalidade de *auto-shuffle*.
  \* **Gerenciamento de Favoritos:** Adicionar e remover GIFs, com persistência de dados local.
  \* **Histórico de Pesquisas:** Armazenamento e acesso rápido às pesquisas realizadas.
  \* **Controle de Classificação (Rating):** Filtragem de resultados pela classificação G, PG, PG-13, R.
  \* **Interface Responsiva:** Otimização do layout para diferentes tamanhos de tela (mobile e tablet).

## 🛠️ Tecnologias e Dependências

| Tecnologia | Finalidade |
| :--- | :--- |
| **Flutter** | Framework de desenvolvimento. |
| **Provider** | Gerenciamento de estado e injeção de dependência. |
| **SQFlite** | Persistência local para dados estruturados (Favoritos e Histórico). |
| **SharedPreferences** | Persistência simples para cache e preferências de usuário (`random_id`). |
| **HTTP** | Comunicação assíncrona com a API do Giphy. |

-----

## Estrutura de Pastas

A arquitetura do projeto separa as responsabilidades em camadas lógicas:

```
lib/
├─ core/             # Constantes, Temas e configurações gerais.
├─ data/
│  ├─ controllers/  # Camada de Domínio/State (GifsController) - Lógica de negócio.
│  ├─ models/       # Modelos de Dados (Ex: GiphyGif).
│  └─ services/     # Camada de Dados - Implementações de API (GiphyService) e Banco de Dados.
├─ features/         # Módulos de funcionalidade.
│  └─ gifs/
│     ├─ screens/     # Telas/Páginas.
│     └─ widgets/     # Componentes de UI reutilizáveis.
└─ main.dart         # Ponto de entrada do aplicativo.
```

### Uso do Provider

O `GifsController` é a classe que provê o estado para a aplicação:

  \* **Observar (Rebuild UI):**
    ` dart     final controller = context.watch<GifsController>();      `
  \* **Acessar/Chamar Métodos:**
    ` dart     final controller = context.read<GifsController>();      `

-----

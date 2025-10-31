GIF Flutter

Um aplicativo Flutter para buscar, visualizar e favoritar GIFs usando a API do Giphy.
Esta versão demonstra integração com a API do Giphy, armazenamento local de favoritos e
histórico de pesquisas, e um fluxo simples de estado usando Provider.

## Funcionalidades principais

- Buscar GIFs por palavra-chave (tags) com suporte a paginação.
- Visualizar GIFs aleatórios com auto-shuffle.
- Favoritar e remover favoritos (salvos no banco local).
- Histórico das pesquisas recentes.
- Filtragem por classificação (G, PG, PG-13, R).
- Interface responsiva pensada para várias plataformas (mobile, desktop).

## Tecnologias e dependências

- Flutter (SDK)
- Provider - gerenciamento de estado
- SQFlite - armazenamento local (favoritos, histórico, preferências)
- http - chamadas à API do Giphy
- shared_preferences - cache do random_id

> As dependências reais estão definidas em `pubspec.yaml`.

## Pré-requisitos

- Flutter SDK instalado (compatível com o projeto)
- Uma chave de API do Giphy (veja abaixo como configurar)

## Instalação rápida (PowerShell)

```powershell
git clone <URL_DO_REPOSITORIO>
Set-Location -Path .\gif_flutter
flutter pub get
flutter run
```

Substitua `<URL_DO_REPOSITORIO>` pelo URL do repositório.

## Configuração da API do Giphy

O app exige uma chave da API do Giphy para buscar GIFs. Há duas opções simples:

1. Editar diretamente `lib/main.dart` e procurar onde `GiphyService` é instanciado. Substitua
   `'<SUA_API_KEY_AQUI>'` pela sua chave.

2. (Recomendado para produção) Implementar uma estratégia de variáveis de ambiente ou
   usar um arquivo de configuração excluído do controle de versão.

Exemplo mínimo (em `lib/main.dart`):

```dart
GifsController(
  GiphyService(apiKey: '<SUA_API_KEY_AQUI>'),
)
```

Depois de inserir a chave, rode `flutter run` novamente.

## Estrutura do projeto (resumida)

Principais pastas em `lib/`:

- `core/` - constantes e tema do app (`constants.dart`, `theme.dart`).
- `data/controllers/` - `gifs_controller.dart`: lógica e Provider principal.
- `data/models/` - modelos de dados, por ex. `gif_item.dart`.
- `data/services/` - serviços como `giphy_service.dart` (API) e `local_storage.dart` (SQFlite).
- `features/gifs/screens/` - telas: `random_gif.dart`, `search_gif_page.dart`, `favorite_page.dart`, `history_page.dart`, `detail_page.dart`.
- `features/gifs/widgets/` - widgets reutilizáveis: `gif_grid.dart`, `gif_tile.dart`, `gif_display.dart`, `search_bar.dart`, `state_widgets.dart`.
- `settings/pages/` - página de configurações (`settings_page.dart`).

Isso ajuda a localizar rapidamente a responsabilidade de cada arquivo.
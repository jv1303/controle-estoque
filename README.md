# Meu Estoque

Aplicativo mobile em Flutter para controlar o estoque de produtos de um pequeno comércio ou de casa. Cada pessoa tem sua conta e cadastra os próprios produtos, com categoria, quantidade e preço. A tela inicial mostra quantos produtos existem, o total de unidades e o valor total em estoque.

## O que dá pra fazer

- Criar conta, entrar e sair
- Continuar logado ao fechar e abrir o app (sessão salva no aparelho)
- Cadastrar, listar, editar e excluir produtos
- Somar ou tirar unidades direto na lista (botões + e -)
- Buscar produto pelo nome
- Ver aviso de "Estoque baixo" quando sobram 5 unidades ou menos
- Excluir arrastando o item para a esquerda (com confirmação) ou pela tela de edição
- Validação dos formulários: campos obrigatórios, e-mail válido, senha com 6+ caracteres, confirmação de senha, quantidade inteira e preço válido
- Mensagens de erro: e-mail já cadastrado, conta não encontrada, senha incorreta

## Stack

| Item | Uso |
|---|---|
| Flutter / Dart | interface e lógica |
| material_ui | componentes visuais (Material 3) |
| sqflite | banco SQLite local |
| shared_preferences | guarda o id do usuário logado |
| crypto | hash SHA-256 da senha |
| intl | formatação de dinheiro (R$) |
| sqflite_common_ffi | usado só nos testes, para rodar o SQLite no computador |

## Rodando localmente

Requisitos: Flutter instalado e um emulador Android aberto (ou celular com depuração USB).

```bash
git clone https://github.com/jv1303/controle-estoque.git
cd controle-estoque
flutter pub get
flutter run
```

Testes automáticos:

```bash
flutter test
```

## Como funciona o login

Toda a parte de autenticação está em `lib/services/auth_service.dart`.

1. No cadastro é gerado um *salt* aleatório para o usuário. A senha é salva como `sha256(salt + senha)`, nunca em texto puro.
2. O e-mail tem restrição `UNIQUE` no banco. Se já existir, o SQLite recusa e o app mostra "Já existe uma conta com esse e-mail."
3. No login o app busca o usuário pelo e-mail, refaz o hash com o salt dele e compara.
4. Quando dá certo, o id do usuário é salvo com `shared_preferences`. Ao abrir o app de novo, `restoreSession()` lê esse id e entra direto.
5. As rotas `/home` e `/product-form` são privadas: em `lib/core/app_routes.dart`, se ninguém estiver logado, o `onGenerateRoute` manda para o login.
6. Os erros de autenticação são lançados como `AuthException` e a tela mostra a mensagem num SnackBar.

## Banco de dados

SQLite, arquivo `meu_estoque.db`, criado em `lib/services/database_service.dart`.

**users**

| coluna | tipo |
|---|---|
| id | INTEGER, chave primária |
| name | TEXT |
| email | TEXT, único |
| password_hash | TEXT |
| salt | TEXT |
| created_at | TEXT (data ISO) |

**products**

| coluna | tipo |
|---|---|
| id | INTEGER, chave primária |
| owner_id | INTEGER, chave estrangeira para users.id |
| name | TEXT |
| category | TEXT |
| quantity | INTEGER (não pode ser negativo) |
| price | REAL (não pode ser negativo) |
| updated_at | TEXT (data ISO) |

O CRUD fica em `lib/services/product_service.dart`. Todas as consultas usam `owner_id = ?`, então um usuário nunca vê nem altera produtos de outro.

## Organização das pastas

```
lib/
  main.dart                  inicia o app e restaura a sessão
  core/
    app_routes.dart          nomes das rotas e proteção das telas
    validators.dart          validações dos formulários
    formatters.dart          formatação de R$
  models/
    app_user.dart
    product.dart
  services/
    database_service.dart    abre o banco e cria as tabelas
    auth_service.dart        cadastro, login, logout e sessão
    product_service.dart     CRUD de produtos
  screens/
    login_screen.dart
    register_screen.dart
    home_screen.dart
    product_form_screen.dart cadastro e edição
  widgets/
    app_text_field.dart      campo de texto e campo de senha
    product_card.dart        item da lista
    stock_summary.dart       resumo no topo da Home
    empty_state.dart         mensagem de lista vazia
    feedback.dart            SnackBar e diálogo de confirmação
test/
  validators_test.dart
  product_test.dart
  services_test.dart         testa login e CRUD com SQLite de verdade
```

## Autor

João Victor Serafim, 5º semestre de DSM

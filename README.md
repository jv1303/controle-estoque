# Controle de Estoque

Projeto da disciplina de desenvolvimento mobile (DSM). É um app Android em Flutter para quem precisa saber o que tem guardado, quanto tem e quanto vale: uma pequena loja, uma cantina, a despensa de casa. Cada conta tem o seu próprio estoque.

> Desenvolvido por **João Victor Serafim** (DSM, 5º semestre).

## Telas

| Tela | O que tem |
|---|---|
| Login | e-mail e senha (com botão para mostrar a senha) e link para criar conta |
| Criar conta | nome, e-mail, senha e confirmação da senha |
| Início | três quadros de resumo (produtos, unidades e valor total), busca por nome e a lista de produtos |
| Produto | formulário de cadastro e edição: nome, categoria, quantidade e preço. Na edição aparece a lixeira |

Na lista dá para somar ou tirar unidades com os botões **+** e **-**, tocar no produto para editar e arrastar para a esquerda para excluir. Toda exclusão e o logout pedem confirmação.

## Regras do sistema

1. Só entra quem tem conta. As telas de Início e Produto não abrem sem login.
2. Não existem duas contas com o mesmo e-mail.
3. A senha precisa ter pelo menos 6 caracteres e é guardada só como hash.
4. Quantidade é um número inteiro e nunca fica negativa. Preço também não pode ser negativo.
5. Produto com 5 unidades ou menos aparece marcado como **Estoque baixo**.
6. Um usuário nunca vê nem altera produtos de outro.
7. Depois de entrar, o app lembra do usuário até ele tocar em sair.

## Persistência

Os dados ficam num banco **SQLite** local (`meu_estoque.db`), aberto pelo pacote `sqflite`. São duas tabelas com relação de um para muitos: um usuário tem vários produtos.

```
users (1) ──────< (N) products
  id                  id
  name                owner_id  -> users.id
  email (único)       name
  password_hash       category
  salt                quantity  (>= 0)
  created_at          price     (>= 0)
                      updated_at
```

As tabelas são criadas no `onCreate` do `DatabaseService`. As chaves estrangeiras são ligadas com `PRAGMA foreign_keys = ON`, então ao apagar um usuário os produtos dele vão junto (`ON DELETE CASCADE`).

As operações do CRUD estão no `ProductService`, e todas filtram por `owner_id`:

| Operação | Método |
|---|---|
| Inserir | `create` |
| Consultar / buscar | `findAll(search:)` |
| Alterar | `update` e `adjustQuantity` |
| Remover | `remove` |

## Login e segurança

- **Cadastro:** o app sorteia um *salt* para o usuário e salva `sha256(salt:senha)`. Mesmo duas pessoas com a mesma senha ficam com hashes diferentes.
- **E-mail repetido:** a coluna `email` é `UNIQUE`. O SQLite recusa o insert, e o `AuthService` transforma esse erro na mensagem "Já existe uma conta com esse e-mail."
- **Entrar:** busca a conta pelo e-mail, recalcula o hash com o salt salvo e compara. Os erros possíveis são "Nenhuma conta com esse e-mail." e "Senha incorreta."
- **Sessão:** o id do usuário fica no `shared_preferences`. No `main()`, `restoreSession()` lê esse id antes de abrir o app.
- **Sair:** apaga o id salvo e volta para o login.
- **Telas protegidas:** o `MaterialApp` usa `onGenerateRoute`. Em `AppRoutes.generate`, se a rota pedida é privada e ninguém está logado, a tela entregue é a de login.

## Arquitetura

| Pasta | Responsabilidade |
|---|---|
| `lib/core` | rotas (`app_routes.dart`), validações dos formulários (`validators.dart`) e formatação de dinheiro (`formatters.dart`) |
| `lib/models` | `Product` e `AppUser`, com conversão de/para linha do banco |
| `lib/services` | `DatabaseService` (conexão), `AuthService` (conta e sessão) e `ProductService` (CRUD) |
| `lib/screens` | `login_screen`, `register_screen`, `home_screen` e `product_form_screen` |
| `lib/widgets` | peças reutilizadas pelas telas: campos de texto, card do produto, resumo, lista vazia, SnackBar e diálogo |

As telas não escrevem SQL: elas chamam os services, e os services falam com o banco.

## Pacotes usados

`sqflite`, `path`, `crypto`, `shared_preferences`, `intl` e `material_ui`. Nos testes também é usado o `sqflite_common_ffi`.

## Testes

São 18 testes automáticos em `test/`:

- `validators_test.dart`: regras de e-mail, senha, quantidade e preço
- `product_test.dart`: valor total, estoque baixo e conversão para o banco
- `services_test.dart`: usa o SQLite de verdade no computador para testar cadastro, e-mail repetido, senha errada, sessão, CRUD completo e o isolamento entre usuários

## Como executar

Com o Flutter instalado e um emulador Android aberto:

1. Clone o repositório: `git clone https://github.com/jv1303/controle-estoque.git`
2. Entre na pasta e baixe as dependências: `flutter pub get`
3. Rode o app: `flutter run`
4. Para rodar os testes: `flutter test`

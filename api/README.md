# API de Autenticação

Esta é uma API simples em Flask que fornece duas rotas: uma para o login do usuário com validação de TOTP e outra 
para recuperação do secret TOTP usando um código de recuperação especial junto com a verificação de senha.

## Requisitos

Antes de executar a API, certifique-se de que as dependências necessárias estão instaladas:

- Python 3.x
- Flask
- pyotp

### Instalar as Dependências

Você pode instalar as dependências executando o seguinte comando:

```bash
pip install flask pyotp
```

## Executando a API

Para executar a API, use o seguinte comando:

```bash
python app.py
```

O servidor será iniciado em `http://127.0.0.1:5000`.

## Endpoints da API

### 1. `/auth/login` - POST

Este endpoint autentica um usuário com nome de usuário, senha e código TOTP.

#### Requisição:

- **URL:** `/auth/login`
- **Método:** `POST`
- **Content-Type:** `application/json`
- **Corpo da Requisição:**

```json
{
    "username": "admin",
    "password": "password123",
    "totp_code": "123456"
}
```

- **Username:** O nome de usuário (neste caso, `admin`).
- **Password:** A senha do usuário (neste caso, `password123`).
- **TOTP Code:** O código TOTP de 6 dígitos gerado por um autenticador TOTP (como o Google Authenticator).

_Nota:_ você pode gerar um código TOTP neste site https://totp.danhersam.com/.

#### Respostas:

- **200 OK:** Se o login for bem-sucedido e o código TOTP for válido.
  
  ```json
  {
      "message": "Login successful",
      "status": "success"
  }
  ```

- **401 Unauthorized:** Se o código TOTP ou as credenciais forem inválidos.

  ```json
  {
      "message": "Invalid credentials",
      "status": "failure"
  }
  ```

### 2. `/auth/recovery-secret` - POST

Este endpoint permite que os usuários recuperem seu secret TOTP se fornecerem um código de recuperação válido (`000010`) 
e a senha correta.

#### Requisição:

- **URL:** `/auth/recovery-secret`
- **Método:** `POST`
- **Content-Type:** `application/json`
- **Corpo da Requisição:**

```json
{
    "username": "admin",
    "password": "password123",
    "code": "000010"
}
```

- **Username:** O nome de usuário do usuário.
- **Password:** A senha do usuário (neste caso, `password123`).
- **Code:** Um código de recuperação especial (`000010`) que permite a recuperação do secret.

#### Respostas:

- **200 OK:** Se o código de recuperação e a senha forem válidos, o secret TOTP é retornado.

  ```json
  {
      "message": "Recovery code and password verified",
      "totp_secret": "your_totp_secret_here"
  }
  ```

- **401 Unauthorized:** Se o código de recuperação ou a senha fornecida forem inválidos.

  ```json
  {
      "message": "Invalid password"
  }
  ```

  ```json
  {
      "message": "Invalid recovery code"
  }
  ```

- **404 Not Found:** Se o usuário não for encontrado.

  ```json
  {
      "message": "User not found"
  }
  ```

## Exemplo de Uso

### Login com TOTP:

```bash
curl -X POST http://127.0.0.1:5000/auth/login \
-H "Content-Type: application/json" \
-d '{"username": "admin", "password": "password123", "totp_code": "123456"}'
```

### Recuperar o Secret TOTP:

```bash
curl -X POST http://127.0.0.1:5000/auth/recovery-secret \
-H "Content-Type: application/json" \
-d '{"username": "admin", "password": "password123", "code": "000010"}'
```

**Nota:** o código de recuperação é `000010` e a senha deve ser correta (`password123` neste exemplo).

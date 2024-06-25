# naldodj-2FA-windows
Autenticação 2FA para logon no Windows

![image](https://github.com/naldodj/naldodj-2FA-windows/assets/102384575/ee3632d7-cc40-40cb-8886-7ca30ad42bb8)

# Adicionando Autenticação de Dois Fatores ao Windows com PowerShell e Otp.NET

Autenticação de dois fatores (2FA) é uma camada adicional de segurança usada para garantir que as pessoas tentando obter acesso a uma conta online sejam quem dizem ser. Primeiro, um usuário insere seu nome de usuário e uma senha. Em seguida, em vez de obter acesso imediatamente, ele é solicitado a fornecer outra informação. Essa segunda camada pode vir de uma variedade de fontes:

- Algo que você sabe - uma informação adicional, como uma senha ou PIN.
- Algo que você possui - um dispositivo específico, como um smartphone.
- Algo que você é - uma impressão digital ou reconhecimento facial.

Neste guia, vamos configurar a autenticação de dois fatores (2FA) usando PowerShell e a biblioteca Otp.NET, armazenando a chave secreta no Windows Credential Manager e validando o código gerado por aplicativos autenticadores como Google Authenticator ou Microsoft Authenticator.

## Pré-requisitos

1. **PowerShell** instalado no seu sistema.
2. **Otp.NET** - Biblioteca .NET para geração de códigos TOTP e HOTP.

## Passo 1: Instalar a Biblioteca Otp.NET

Primeiro, precisamos instalar a biblioteca Otp.NET usando o NuGet. Execute o seguinte comando no PowerShell:

```powershell
Install-Package Otp.NET
```

## Passo 2: Gerar e Armazenar a Chave Secreta

Vamos criar um script PowerShell para gerar e mostrar a chave secreta para configurar o aplicativo autenticador.

###(`2FASecretKeyPutCredentialManager.ps1`)[https://github.com/naldodj/naldodj-2FA-windows/blob/main/src/2FA/2FASecretKeyPutCredentialManager.ps1]

### `.\2FASecretKeyPutCredentialManager.ps1`
![image](https://github.com/naldodj/naldodj-2FA-windows/assets/102384575/6c11d4d7-d9cd-48f2-8b77-505ba64b9fb0)
![image](https://github.com/naldodj/naldodj-2FA-windows/assets/102384575/cc38f83f-d218-41d9-9305-b23e54c160c4)
![image](https://github.com/naldodj/naldodj-2FA-windows/assets/102384575/66fb6810-47c6-4c4f-af97-906a2e2d8204)

## Passo 3: Verificar o Código 2FA

Agora, vamos criar um script PowerShell para verificar o código 2FA gerado pelo aplicativo autenticador.
###(`2FASecretKeyChkCredentialManager.ps1`)[https://github.com/naldodj/naldodj-2FA-windows/blob/main/src/2FA/2FASecretKeyChkCredentialManager.ps1]

### `.\2FASecretKeyChkCredentialManager.ps1`
![image](https://github.com/naldodj/naldodj-2FA-windows/assets/102384575/9f5a0b2c-14fd-463e-a668-367114a1eec3)
![image](https://github.com/naldodj/naldodj-2FA-windows/assets/102384575/9426267e-ea39-4792-a550-d9ffc9064dce)
![image](https://github.com/naldodj/naldodj-2FA-windows/assets/102384575/eb8ef4d1-8913-4ecb-81c1-c9cc05826b7b)

## Passo 4: Integrar o Script ao Processo de Logon do Windows

Para integrar este script ao processo de logon do Windows, vamos configurá-lo para ser executado por meio de uma Política de Grupo (GPO).

### Configuração da GPO

#### Abra o Editor de Política de Grupo Local:
1. Pressione Win + R, digite `gpedit.msc` e pressione Enter.

#### Navegue até o Script de Logon:
1. Vá para Configuração do Usuário -> Políticas -> Configurações do Windows -> Scripts (Logon/Logoff).

#### Adicione o Script de Logon:
1. Clique em Logon -> Adicionar Script.
2. No campo **Script Name**, forneça o caminho do script PowerShell criado acima.
3. No campo **Script Parameters**, você pode adicionar parâmetros se necessário.

#### Aplique e Feche:
1. Clique em OK para salvar as configurações.

## Passo 5: Testar o Script

Após configurar a GPO, você pode testar o script fazendo logon com uma conta de usuário e verificando se o prompt do PowerShell aparece solicitando o código 2FA.

## Considerações de Segurança

- **Segurança da Chave Secreta**: Certifique-se de proteger a chave secreta e outras credenciais sensíveis. Armazene-as de forma segura.
- **HTTPS**: Use HTTPS para todas as comunicações com a API para garantir a segurança dos dados transmitidos.
- **Tratamento de Erros**: Adicione tratamento de erros e logs apropriados ao script para lidar com falhas e garantir a auditoria.

---

Para garantir que o usuário não possa fechar a tela do PowerShell e evitar a validação, vamos modificar o segundo script de forma que nos forneça uma interface para digitação do código 2FA.

###(`2FASecretKeyGetCredentialManager.ps1`)[https://github.com/naldodj/naldodj-2FA-windows/blob/main/src/2FA/2FASecretKeyGetCredentialManager.ps1]

### `.\2FASecretKeyRunCredentialManager.bat => 2FASecretKeyGetCredentialManager.ps1`
![image](https://github.com/naldodj/naldodj-2FA-windows/assets/102384575/1914af19-187e-49a4-bd84-90d62cbe6a25)
![image](https://github.com/naldodj/naldodj-2FA-windows/assets/102384575/4ae3cd88-68a4-4f49-97a8-834b3779897b)

### 1. Executar o Script como uma Tarefa

Usar o `Task Scheduler` para executar o script pode ajudar a evitar que o usuário feche a janela do PowerShell. Aqui estão os passos:

1. **Criar o Script**:
   - Salve o script de validação como `2FASecretKeyGetCredentialManager.ps1`.

2. **Criar uma Tarefa no Task Scheduler**:
   - Abra o `Task Scheduler`.
   - Clique em `Create Task`.
   - Na aba `General`, dê um nome à tarefa, por exemplo, "2FAuth".
![image](https://github.com/naldodj/naldodj-2FA-windows/assets/102384575/c61778b0-0078-454e-8a44-b568f947d0d7)
   - Na aba `Triggers`, clique em `New` e selecione `At log on` e/ou outras opções para validação.
![image](https://github.com/naldodj/naldodj-2FA-windows/assets/102384575/737b31a5-1a0f-44e0-a04f-7b3c9af6b7d6)
   - Na aba `Actions`, clique em `New` e selecione `Start a program`. No campo `Program/script`, digite `2FASecretKeyRunCredentialManager.bat`.
```cmd
pwsh -executionPolicy bypass -file "C:\tools\2FA\2FASecretKeyGetCredentialManager.ps1"
```
   - Na aba `Conditions`, desmarque a opção `Start the task only if the computer is on AC power` para garantir que a tarefa seja executada mesmo se o computador estiver usando bateria.
![image](https://github.com/naldodj/naldodj-2FA-windows/assets/102384575/b3ea419f-5f5b-4536-ab61-33565ad82bb5)
   - Na aba `Settings`, marque a opção `Allow task to be run on demand` e `Run task as soon as possible after a scheduled start is missed`.
![image](https://github.com/naldodj/naldodj-2FA-windows/assets/102384575/f710d4c8-d411-4410-a630-c4d6f9eb8cf1)

3. **Criar uma ação na Inicialização do Windows ou um Script de Logon**:
![image](https://github.com/naldodj/naldodj-2FA-windows/assets/102384575/8dc7791b-77cd-427b-af6e-50821976c6ac)
![image](https://github.com/naldodj/naldodj-2FA-windows/assets/102384575/4fa44386-24a4-4150-bb55-babce0bcf657)
![image](https://github.com/naldodj/naldodj-2FA-windows/assets/102384575/e42636f7-9408-4d04-b6c8-cd7a3a4edcf4)
![image](https://github.com/naldodj/naldodj-2FA-windows/assets/102384575/445470fa-c307-4d79-a5d0-33f5de6e0f5f)

### Considerações Finais

Essas abordagens ajudam a garantir que o script seja executado de forma consistente e que o usuário não possa fechá-lo facilmente😊!

Com esses passos, você pode adicionar uma camada adicional de segurança ao seu processo de autenticação no Windows, utilizando a autenticação de dois fatores. Isso garante que apenas usuários autorizados, que possuem acesso ao código 2FA gerado pelo aplicativo autenticador, possam acessar o sistema.

### Exemplo
![image](https://github.com/naldodj/naldodj-2FA-windows/assets/102384575/ed5c409a-d517-448a-a37c-33b218d15048)

### Autenticação 2FA para logon no Windows
![image](https://github.com/naldodj/naldodj-2FA-windows/assets/102384575/2e605b77-98aa-422a-8405-dc5af719a11e)

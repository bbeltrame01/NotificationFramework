# 🚀 Notification Framework

Framework genérico de notificações com integração e agendamento configurável. Ideal para projetos Delphi que precisam de uma solução flexível e extensível para envio de notificações. A implementação utiliza princípios SOLID e padrões como Factory Method e Dependency Injection para facilitar a manutenção e expansão do sistema.

---

## 📋 Características

- **Suporte Multicanal**: Notificações via Email, SMS, Push, entre outros.
- **Agendamento Flexível**: Frequência configurável (diária, semanal, mensal).
- **Fácil Integração**: Adapte facilmente o framework ao seu projeto Delphi.
- **Extensível**: Adicione novos métodos de envio sem complicações.

---

## 🗂️ Estrutura do Projeto

```plaintext
├── src/                  # Código do framework
│   ├── uNotificationFramework.pas
│   ├── uEmailNotification.pas
│   ├── uSMSNotification.pas
│   ├── uPushNotification.pas
├── test/                 # Testes unitários
│   ├── TestuNotificationFramework.pas
├── vcl_app/              # Aplicativo VCL de demonstração
│   ├── uFrMain.pas
│   ├── uFrMain.dfm
│   ├── NotificationDemo.exe (pré-compilado)
├── README.md             # Documentação
```

### 🏷️ Tipos e Enumerações
- `TNotificationType`: Define os tipos de notificação suportados (ntEmail, ntPush, ntSMS).
- `TNotificationFrequency`: Define as frequências de notificação (Diária, Semanal, Mensal, Nenhuma).

### 🔗 Interfaces Principais

#### `INotificationSender`
Interface para envio de notificações. Cada tipo de notificação deve implementar esta interface.
- `SendNotification`: Envia uma mensagem.
- `GetNotificationType`: Retorna o tipo da notificação.

#### `IEmailConfigService`
Interface para configuração de envio de e-mails.
- `ConfigureSMTP`: Configura o servidor SMTP.
- `SetCredentials`: Define credenciais para autenticação.

#### `ILogNotification`
Interface para registro de logs de notificações.
- `LogNotification`: Registra logs com data, hora, mensagens e tipos.

### 🏗️ Classes Principais

#### `TEmailNotification`
Implementação de envio de notificações por e-mail.
- Depende de `IEmailConfigService` para configuração SMTP.

#### `TPushNotification`
Implementação de envio de notificações push.

#### `TSMSNotification`
Implementação de envio de notificações via SMS.

#### `TLogNotification`
Implementação para registro de logs.
- Utiliza `TStrings` para armazenar logs.
- Usa `TCriticalSection` para garantir a thread safety.

#### `TNextSendNotification`
Classe para calcular a próxima data de envio de notificação com base na frequência configurada.

#### `TNotificationFactory`
Factory Method para criar instâncias de `INotificationSender` com base no tipo de notificação.

#### `TNotification`
Classe principal para gerenciar o ciclo de vida das notificações.
- Cria instâncias de `INotificationSender`.
- Gerencia threads para envio de notificações.
- Valida entradas e configurações.

---

## 🔧 Requisitos

- **Delphi** (versão recomendada: mais recente).

---

## 📥 Instalação

1. **Clone o repositório:**
   ```bash
   git clone https://github.com/bbeltrame01/NotificationFramework
   ```

2. **Adicione o diretório `src/` ao seu projeto no Delphi.**

---

## ➕ Incluir Novos Tipos de Envio
Para adicionar um novo tipo de notificação, siga os passos abaixo:

1. **Atualizar o `TNotificationType`:**
   Adicione um novo valor ao enum:
   ```delphi
   TNotificationType = (ntEmail=0, ntPush=1, ntSMS=2, ntNew=3);
   ```
   
2. **Criar uma nova unit com uma classe que implemente `INotificationSender`:**
   ```delphi
   uses
	 uNotificationFramework;
  
   type
     TNewNotification = class(TInterfacedObject, INotificationSender)
     protected
       procedure SendNotification(const AMessage: string);
       function GetNotificationType: string;
     end;

     procedure TNewNotification.SendNotification(const AMessage: string);
     begin
       // Lógica para envio da nova notificação.
     end;

     function TNewNotification.GetNotificationType: string;
     begin
       Result := 'NewNotification';
     end;
   ```
   
3. **Incluir a nova unit no `uses` do `uNotificationFramework.pas`**
	```delphi
	implementation

	uses
	  uEmailNotification, uSMSNotification, uPushNotification, uNewNotification;
	```

4. **Adicionar o `initialization` com `TNotificationFactory`:**
   Inclua ao final da unit a inicialização para o novo tipo:
   ```delphi
   initialization
	 TNotificationFactory.SetNotification(ntNew,
		function: INotificationSender begin Result := TNewNotification.Create; end);
   ```

4. **Testar a Implementação:**
   Certifique-se de que o novo tipo de notificação esteja funcionando conforme o esperado.

## 📚 Uso

### 💡 Framework

1. Inclua o framework no seu projeto:
   ```delphi
   uses uNotificationFramework;
   ```

2. Configure o envio de notificações:
   ```delphi
   var
      Notification: INotification;
      LogOutput: TStringList; // Opcional
   begin
      LogOutput := TStringList.Create;
      try
         Notification := TNotification.Create([
            ntEmail, ntPush, ntNew
         ], 'Mensagem de Teste', nfDaily, LogOutput);
         Notification.Start;

         // Aguarde algum tempo para testes.
         Sleep(10000);

         Notification.Stop;
         ShowMessage(LogOutput.Text);
      finally
         LogOutput.Free;
      end;
   end;
   ```

---

### 🖥️ Aplicativo VCL

1. Navegue até o diretório `vcl_app/` e execute `NotificationDemo.exe`.
2. Configure os tipos de notificação e a frequência desejada.
3. Clique em **"Iniciar"** para testar as notificações.

---

## ✅ Testes Unitários

1. Abra o arquivo `test/TestuNotificationFramework.pas`.
2. Execute os testes usando **DUnit** ou **DUnitX** no Delphi.

---

## 📜 Licença

Este projeto está licenciado sob a [MIT License](LICENSE).

---

💡 **Contribuições**: Feedbacks, issues ou contribuições são sempre bem-vindos!
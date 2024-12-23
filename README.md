# 🚀 Notification Framework

Framework genérico de notificações com integração e agendamento configurável. Ideal para projetos Delphi que precisam de uma solução flexível e extensível para envio de notificações.

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
│   ├── uEmailNotification.pas
│   ├── uNotificationFramework.pas
│   ├── uPushNotification.pas
│   ├── uSMSNotification.pas
├── test/                 # Testes unitários
│   ├── TestuNotificationFramework.pas
├── vcl_app/              # Aplicativo VCL de demonstração
│   ├── uFrMain.pas
│   ├── uFrMain.dfm
│   ├── NotificationDemo.exe (pré-compilado)
├── README.md             # Documentação
```

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

## 📚 Uso

### 💡 Framework

1. Inclua o framework no seu projeto:
   ```delphi
   uses uNotificationFramework;
   ```

2. Configure o envio de notificações:
   ```delphi
   var
     Notification: TNotification;
     Sender: INotificationSender;
   begin
     Sender := TEmailNotificationSender.Create;
     Notification := TNotification.Create(Sender, 'Teste de notificação', nfDaily);
     Notification.Start;
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
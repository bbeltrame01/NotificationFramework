# Notification Framework

## Description
Framework genérico de notificações com integração e agendamento configurável.

## Features
- Suporte a diferentes métodos de envio de notificações.
- Configuração de frequência: diária, semanal ou mensal.
- Fácil integração com outros projetos Delphi.
- Extensível para novos métodos de envio.

## Project Structure
```
├── src/                  # Código do framework
│   ├── uEmailNotification.pas
│   ├── uNotificationFramework.pas
│   ├── uPushNotification.pas
│   ├── uSMSNotification.pas
├── tests/                # Testes unitários
│   ├── uNotificationFrameworkTests.pas
├── vcl_app/              # Aplicativo VCL de demonstração
│   ├── uFrMain.pas
│   ├── uFrMain.dfm
│   ├── NotificationDemo.exe (pré-compilado)
├── README.md             # Documentação
```

## Requirements
- Delphi (recomendado: versão recente).

## Installation
1. Clone o repositório:
   ```bash
   git clone <repository_url>
   ```

2. Abra o Delphi e adicione o diretório `src/` ao seu projeto para usar o framework.

## Usage

### Framework
1. Inclua o framework no seu projeto:
   ```delphi
   uses uNotificationFramework;
   ```

2. Crie uma instância de um método de envio implementando `INotificationSender`.
3. Configure e envie uma notificação:
   ```delphi
   var
     Notification: TNotification;
     Sender: INotificationSender;
   begin
     Sender := TEmailNotificationSender.Create;
     Notification := TNotification.Create(Sender, 'Teste de notificação', nfDaily);
     Notification.Send;
   end;
   ```

### Aplicativo VCL
1. Navegue até o diretório `vcl_app/` e execute `NotificationDemo.exe`.
2. Configure os tipos de notificação e a frequência.
3. Clique em "Enviar" para testar as notificações.

## Tests
1. Abra o arquivo de testes localizado em `tests/uNotificationFrameworkTests.pas`.
2. Execute os testes unitários no Delphi usando DUnit ou DUnitX.

## Contributing
1. Faça um fork do repositório.
2. Crie um branch para a sua feature: `git checkout -b minha-feature`.
3. Envie um Pull Request descrevendo a mudança.

## License
Este projeto está licenciado sob a [MIT License](LICENSE).

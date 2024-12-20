unit uSMSNotification;

interface

uses
  uNotificationFramework;

type
  TSMSNotification = class(TInterfacedObject, INotificationSender)
  public
    procedure SendNotification(const AMessage: string);
  end;

implementation

uses
  Dialogs;

{ TSMSNotification }

procedure TSMSNotification.SendNotification(const AMessage: string);
begin
  // Simulação de envio de SMS
  ShowMessage('SMS enviado: ' + AMessage);
end;

end.


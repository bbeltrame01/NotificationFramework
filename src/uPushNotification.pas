unit uPushNotification;

interface

uses
  uNotificationFramework;

type
  TPushNotification = class(TInterfacedObject, INotificationSender)
  public
    procedure SendNotification(const AMessage: string);
  end;

implementation

uses
  Dialogs;

{ TPushNotification }

procedure TPushNotification.SendNotification(const AMessage: string);
begin
  // Simula��o de envio de push
  ShowMessage('Push enviado: ' + AMessage);
end;

end.

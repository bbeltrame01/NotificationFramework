unit uEmailNotification;

interface

uses
  uNotificationFramework;

type
  TEmailNotification = class(TInterfacedObject, INotificationSender)
  public
    procedure SendNotification(const AMessage: string);
  end;

implementation

uses
  Dialogs;

procedure TEmailNotification.SendNotification(const AMessage: string);
begin
  // Simulação de envio de e-mail
  ShowMessage('E-mail enviado: ' + AMessage);
end;

end.


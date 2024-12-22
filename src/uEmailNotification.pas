unit uEmailNotification;

interface

uses
  uNotificationFramework;

type
  TEmailNotification = class(TInterfacedObject, INotificationSender)
  public
    procedure SendNotification(const AMessage: string);
    function GetNotificationType: string;
  end;

implementation

uses
  Dialogs;

{ TEmailNotification }

function TEmailNotification.GetNotificationType: string;
begin
  Result := 'E-Mail';
end;

procedure TEmailNotification.SendNotification(const AMessage: string);
begin
  (*
    TODO: Incluir processo de envio de e-mail aqui.
  *)
  MessageDlg('E-mail enviado: ' + AMessage, mtInformation, [mbOK], 0);
end;

end.


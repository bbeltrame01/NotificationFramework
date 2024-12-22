unit uSMSNotification;

interface

uses
  uNotificationFramework;

type
  TSMSNotification = class(TInterfacedObject, INotificationSender)
  public
    procedure SendNotification(const AMessage: string);
    function GetNotificationType: string;
  end;

implementation

uses
  Dialogs;

{ TSMSNotification }

function TSMSNotification.GetNotificationType: string;
begin
  Result := 'SMS';
end;

procedure TSMSNotification.SendNotification(const AMessage: string);
begin
  (*
    TODO: Incluir processo de envio de SMS aqui.
  *)
  MessageDlg('SMS enviado: ' + AMessage, mtInformation, [mbOK], 0);
end;

end.


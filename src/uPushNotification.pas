unit uPushNotification;

interface

uses
  uNotificationFramework, System.UITypes;

type
  TPushNotification = class(TInterfacedObject, INotificationSender)
  protected
    procedure SendNotification(const AMessage: string);
    function GetNotificationType: string;
  end;

implementation

uses
  Dialogs;

{ TPushNotification }

function TPushNotification.GetNotificationType: string;
begin
  Result := 'Push';
end;

procedure TPushNotification.SendNotification(const AMessage: string);
begin
  (*
    TODO: Incluir processo de envio de push aqui.
  *)
  MessageDlg('Push enviado: ' + AMessage, mtInformation, [mbOK], 0);
end;

initialization
  TNotificationFactory.SetNotification(ntPush,
    function: INotificationSender begin Result := TPushNotification.Create; end);

end.

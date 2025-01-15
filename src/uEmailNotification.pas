unit uEmailNotification;

interface

uses
  uNotificationFramework, System.UITypes;

type
  IEmailConfigService = interface
    ['{7E5A19B3-64FC-4152-A34F-EF066624C644}']
    procedure ConfigureSMTP(const AServer: string; const APort: Integer);
    procedure SetCredentials(const AUsername, APassword: string);
  end;

  TEmailConfigService = class(TInterfacedObject, IEmailConfigService)
  public
    procedure ConfigureSMTP(const AServer: string; const APort: Integer);
    procedure SetCredentials(const AUsername, APassword: string);
  end;

  TEmailNotification = class(TInterfacedObject, INotificationSender)
  private
    FEmailConfigService: IEmailConfigService;
  protected
    procedure SendNotification(const AMessage: string);
    function GetNotificationType: string;
  public
    constructor Create(AEmailConfigService: IEmailConfigService);
    destructor Destroy; override;
  end;

implementation

uses
  Dialogs;

{ TEmailConfigService }

procedure TEmailConfigService.ConfigureSMTP(const AServer: string; const APort: Integer);
begin
  (*
    TODO: Configurar SMTP para envio de E-Mail
  *)
end;

procedure TEmailConfigService.SetCredentials(const AUsername, APassword: string);
begin
  (*
    TODO: Configurar Credenciais para envio de E-Mail
  *)
end;

{ TEmailNotification }

constructor TEmailNotification.Create(AEmailConfigService: IEmailConfigService);
begin
  FEmailConfigService := AEmailConfigService;
end;

destructor TEmailNotification.Destroy;
begin
  FEmailConfigService := nil;
  inherited;
end;

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

initialization
  TNotificationFactory.SetNotification(ntEmail,
    function: INotificationSender
    var
      LEmailConfigService: IEmailConfigService;
    begin
      LEmailConfigService := TEmailConfigService.Create;
      LEmailConfigService.ConfigureSMTP('smtp.server.com', 465);
      LEmailConfigService.SetCredentials('username', 'password');

      Result := TEmailNotification.Create(LEmailConfigService);
    end);

end.

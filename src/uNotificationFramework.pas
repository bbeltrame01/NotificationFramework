unit uNotificationFramework;

interface

uses
  Vcl.StdCtrls, System.Classes, System.SysUtils, DateUtils, Vcl.Dialogs, System.SyncObjs, Generics.Collections;

type
  TNotificationType = (ntEmail=0, ntPush=1, ntSMS=2);
  TNotificationFrequency = (nfNone=-1, nfDaily=0, nfWeekly=1, nfMonthly=2);

  INotificationSender = interface
    ['{DC9CBC93-5A27-47E5-A9C4-6E3ACDC131EA}']
    procedure SendNotification(const AMessage: string);
    function GetNotificationType: string;
  end;

  { E-Mail }

  TEmailNotification = class(TInterfacedObject, INotificationSender)
  protected
    procedure SendNotification(const AMessage: string);
    function GetNotificationType: string;
  public
    procedure ConfigureEmailSMTP;
  end;

  { Notificação do Sistema }

  TPushNotification = class(TInterfacedObject, INotificationSender)
  protected
    procedure SendNotification(const AMessage: string);
    function GetNotificationType: string;
  end;

  { SMS }

  TSMSNotification = class(TInterfacedObject, INotificationSender)
  protected
    procedure SendNotification(const AMessage: string);
    function GetNotificationType: string;
  public
    procedure ConfigureOperadora;
  end;

  { Manter Logs }

  ILogNotification = interface
    ['{7BBCE50B-0333-41A5-8829-C702BE110F1F}']
    procedure LogNotification(const AMessage: string; const AType: string = '');
  end;

  TLogNotification = class(TInterfacedObject, ILogNotification)
  private
    FLogOutput: TStrings;
    FCriticalSection: TCriticalSection;
  protected
    procedure LogNotification(const AMessage: string; const AType: string = '');
  public
    constructor Create(ALogOutput: TStrings = nil);
    destructor Destroy; override;
  end;

  { Calcular próxima Data de Envio }

  TNextSendNotification = class
  private
    FNextSend: TDateTime;
    FFrequency: TNotificationFrequency;
  public
    constructor Create;
    procedure Configure(AFrequency: TNotificationFrequency);
    procedure ScheduleNext;
  end;

  { Factory Method }

  TNotificationFactory = class
  public
    class function NotificationTypeFactory(ANotificationType: TNotificationType): INotificationSender;
  end;

  INotification = interface
    ['{29A17DDF-D2C6-46D3-B568-1136B89BB7E0}']
    procedure Start;
    procedure Stop;
    procedure UpdateParams(const ATypes: TArray<TNotificationType>; const AMessage: string; AFrequency: TNotificationFrequency);
  end;

  TNotification = class(TInterfacedObject, INotification)
  private
    FLogNotification: TLogNotification;
    FNextSend: TNextSendNotification;
    FSenders: TList<INotificationSender>;
    FFrequency: TNotificationFrequency;
    FMessage: string;
    FThread: TThread;
    FStopEvent: TEvent;
    procedure CreateSenders(const ATypes: TArray<TNotificationType>);
    procedure NotificationThreadExecute;
    function ValidateInputs(out ErrorMessage: string): Boolean;
  public
    constructor Create(const ATypes: TArray<TNotificationType>; const AMessage: string; AFrequency: TNotificationFrequency; ALogOutput: TStrings);
    destructor Destroy; override;

    procedure Start;
    procedure Stop;
    procedure UpdateParams(const ATypes: TArray<TNotificationType>; const AMessage: string; AFrequency: TNotificationFrequency);
  end;

implementation

{ TNotificationFactory }

class function TNotificationFactory.NotificationTypeFactory(ANotificationType: TNotificationType): INotificationSender;
begin
  case ANotificationType of
    ntEmail: result := TEmailNotification.Create;
    ntPush:  result := TPushNotification.Create;
    ntSMS:   result := TSMSNotification.Create;
  else
    raise Exception.Create('Tipo de Notificação inválido ou inexistente');
  end;
end;

{ TNotification }

constructor TNotification.Create(const ATypes: TArray<TNotificationType>; const AMessage: string; AFrequency: TNotificationFrequency; ALogOutput: TStrings);
begin
  FLogNotification := TLogNotification.Create(ALogOutput);
  FSenders         := TList<INotificationSender>.Create;
  FNextSend        := TNextSendNotification.Create;
  FStopEvent       := TEvent.Create(nil, True, False, '');

  FLogNotification.LogNotification('Iniciando o processo de envio de notificações...');

  UpdateParams(ATypes, AMessage, AFrequency);
end;

destructor TNotification.Destroy;
begin
  Stop;
  FSenders.Free;
  FLogNotification.Free;
  FNextSend.Free;
  FStopEvent.Free;
  inherited;
end;

procedure TNotification.CreateSenders(const ATypes: TArray<TNotificationType>);
var
  LNotificationType: TNotificationType;
begin
  FSenders.Clear;
  for LNotificationType in ATypes do
    FSenders.Add(TNotificationFactory.NotificationTypeFactory(LNotificationType));
end;

procedure TNotification.UpdateParams(const ATypes: TArray<TNotificationType>; const AMessage: string; AFrequency: TNotificationFrequency);
begin
  FMessage := AMessage;
  FFrequency := AFrequency;
  if Assigned(FNextSend) then
    FNextSend.Configure(AFrequency);
  CreateSenders(ATypes);
end;

procedure TNotification.Start;
var
  LErrorMessage: string;
begin
  if Assigned(FThread) then
    raise Exception.Create('Notificação já está em execução.');

  if not ValidateInputs(LErrorMessage) then
    raise Exception.Create(LErrorMessage);

  FThread := TThread.CreateAnonymousThread(
    procedure
    begin
      NotificationThreadExecute;
    end);
  FThread.FreeOnTerminate := False;
  FThread.Start;
  FLogNotification.LogNotification('Enviando...');
end;

procedure TNotification.NotificationThreadExecute;
begin
  try
    while not (FStopEvent.WaitFor(1000) = wrSignaled) do
    begin
      if (Now >= FNextSend.FNextSend) then
      begin
        try
          for var Sender in FSenders do
          begin
            Sender.SendNotification(FMessage);
            FLogNotification.LogNotification('Envio realizado com sucesso.', Sender.GetNotificationType);
          end;
          FNextSend.ScheduleNext;
        except
          on E: Exception do
            FLogNotification.LogNotification(Format('Erro no envio: %s', [E.Message]));
        end;
      end;
    end;
  except
    on E: Exception do
      FLogNotification.LogNotification(Format('Erro na thread: %s', [E.Message]));
  end;
end;

procedure TNotification.Stop;
begin
  if Assigned(FThread) then
  begin
    FStopEvent.SetEvent;
    FThread.WaitFor;
    FreeAndNil(FThread);
  end;

  if Assigned(FLogNotification) then
    FLogNotification.LogNotification('Processo de envio finalizado.');
end;

function TNotification.ValidateInputs(out ErrorMessage: string): Boolean;
begin
  Result := True;
  ErrorMessage := '';

  // Validar: Tipo de Notificação
  if not Assigned(FSenders) then
  begin
    ErrorMessage := 'Tipo de Notificação inexistente.';
    Exit(False);
  end;

  // Validar: Mensagem
  if (FMessage = '') then
  begin
    ErrorMessage := 'Nenhuma mensagem informada.';
    Exit(False);
  end;

  // Validar: Frequência
  if FNextSend.FFrequency = nfNone then
  begin
    ErrorMessage := 'Frequência não informada.';
    Exit(False);
  end;
end;

constructor TLogNotification.Create(ALogOutput: TStrings);
begin
  inherited Create;
  if not Assigned(ALogOutput) then
    FLogOutput := TstringList.Create
  else
    FLogOutput := ALogOutput;
  FCriticalSection := TCriticalSection.Create;
end;

destructor TLogNotification.Destroy;
begin
  FCriticalSection.Free;
  if FLogOutput.ClassName = 'TStringList' then
    FLogOutput.Free;
  inherited;
end;

procedure TLogNotification.LogNotification(const AMessage: string; const AType: string = '');
begin
  if Assigned(FLogOutput) then
  begin
    FCriticalSection.Enter;
    try
      if (AType = '') then
        FLogOutput.Add(Format('[%s] %s', [DateTimeToStr(Now), AMessage]))
      else
        FLogOutput.Add(Format('[%s][%s] %s', [DateTimeToStr(Now), AType, AMessage]));
    finally
      FCriticalSection.Leave;
    end;
  end;
end;

procedure TNextSendNotification.Configure(AFrequency: TNotificationFrequency);
begin
  FFrequency := AFrequency;
end;

constructor TNextSendNotification.Create;
begin
  FNextSend  := 0;
end;

procedure TNextSendNotification.ScheduleNext;
begin
  case FFrequency of
    nfDaily:   FNextSend := IncDay(Now, 1); // Próximo dia
    nfWeekly:  FNextSend := IncWeek(Now, 1); // Próxima semana
    nfMonthly: FNextSend := IncMonth(Now, 1); // Próximo mês
  else
    FNextSend := 0;
  end;
end;

{ TEmailNotification }

procedure TEmailNotification.ConfigureEmailSMTP;
begin
  (*
    TODO: Configurar SMTP para envio de E-Mail
  *)
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

{ TSMSNotification }

procedure TSMSNotification.ConfigureOperadora;
begin
  (*
    TODO: Configurar Operadora para envio de SMS
  *)
end;

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


unit uNotificationFramework;

interface

uses
  Vcl.StdCtrls, System.Classes, System.SysUtils, DateUtils, Vcl.Dialogs, System.SyncObjs,
  Generics.Collections, System.UITypes;

type
  // Tipos de notificação (Email, Push, SMS)
  TNotificationType = (ntEmail = 0, ntPush = 1, ntSMS = 2);

  // Frequência de notificação (Nenhuma, Diária, Semanal, Mensal)
  TNotificationFrequency = (nfNone = -1, nfDaily = 0, nfWeekly = 1, nfMonthly = 2);

  // Interface para enviar notificações
  INotificationSender = interface
    ['{DC9CBC93-5A27-47E5-A9C4-6E3ACDC131EA}']
    procedure SendNotification(const AMessage: string);
    function GetNotificationType: string;
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
    FFrequency: TNotificationFrequency;
  public
    FNextSend: TDateTime;
    constructor Create;
    procedure Configure(AFrequency: TNotificationFrequency);
    procedure ScheduleNext;
  end;

  { Factory Method }

  TNotificationFactory = class
  private
    class var FRegistry: TDictionary<TNotificationType, TFunc<INotificationSender>>;
    class function GetRegistry: TDictionary<TNotificationType, TFunc<INotificationSender>>; static;
  public
    class property Registry: TDictionary<TNotificationType, TFunc<INotificationSender>> read GetRegistry;

    class procedure SetNotification(AType: TNotificationType; ACreator: TFunc<INotificationSender>);
    class function GetNotification(AType: TNotificationType): INotificationSender;
  end;

  { Thread }

  TNotificationThread = class(TThread)
  private
    FTask: TProc;
  protected
    procedure Execute; override;
  public
    constructor Create(ATask: TProc; ACreateSuspended: Boolean = True);
  end;

  { Principal }

  INotification = interface
    ['{29A17DDF-D2C6-46D3-B568-1136B89BB7E0}']
    procedure Start;
    procedure Stop;
    procedure UpdateParams(const ATypes: TArray<TNotificationType>; const AMessage: string; AFrequency: TNotificationFrequency);
  end;

  TNotification = class(TInterfacedObject, INotification)
  private
    FLogNotification: ILogNotification;
    FNextSend:        TNextSendNotification;
    FFrequency:       TNotificationFrequency;
    FTypes:           TArray<TNotificationType>;
    FMessage:         String;
    FThread:          TThread;
    FStopEvent:       TEvent;

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

uses
  uEmailNotification, uSMSNotification, uPushNotification;

{ TNotificationFactory }

class function TNotificationFactory.GetRegistry: TDictionary<TNotificationType, TFunc<INotificationSender>>;
begin
  if FRegistry = nil then
    FRegistry := TDictionary<TNotificationType, TFunc<INotificationSender>>.Create;
  Result := FRegistry;
end;

class procedure TNotificationFactory.SetNotification(AType: TNotificationType; ACreator: TFunc<INotificationSender>);
begin
  if not Assigned(ACreator) then
    raise EArgumentException.Create('ACreator não pode ser nulo.');

  if Registry.ContainsKey(AType) then
    raise Exception.Create('Tipo de Notificação já registrada.');

  FRegistry.AddOrSetValue(AType, ACreator);
end;

class function TNotificationFactory.GetNotification(AType: TNotificationType): INotificationSender;
var
  LSender: TFunc<INotificationSender>;
begin
  if not Registry.TryGetValue(AType, LSender) then
    raise Exception.Create('Tipo de Notificação inválido ou inexistente.');

  Result := LSender;
end;

{ TNotificationThread }

constructor TNotificationThread.Create(ATask: TProc; ACreateSuspended: Boolean = True);
begin
  inherited Create(ACreateSuspended); // Criar suspenso
  FreeOnTerminate := False;
  FTask := ATask;
end;

procedure TNotificationThread.Execute;
begin
  if Assigned(FTask) then
  begin
    try
      FTask();
    except
      on E: Exception do
      begin
        TThread.Synchronize(nil,
          procedure
          begin
            MessageDlg('Erro na thread: ' + E.Message, mtError, [mbOK], 0);
          end
        );
      end;
    end;
  end;
end;

{ TNotification }

constructor TNotification.Create(const ATypes: TArray<TNotificationType>; const AMessage: string; AFrequency: TNotificationFrequency; ALogOutput: TStrings);
begin
  FLogNotification := TLogNotification.Create(ALogOutput);
  FNextSend        := TNextSendNotification.Create;
  FStopEvent       := TEvent.Create(nil, True, False, '');

  if Assigned(FLogNotification) then
    FLogNotification.LogNotification('Iniciando o processo de envio de notificações...');

  UpdateParams(ATypes, AMessage, AFrequency);
end;

destructor TNotification.Destroy;
begin
  Stop;
  FNextSend.Free;
  FStopEvent.Free;
  FLogNotification := nil;
  inherited;
end;

procedure TNotification.UpdateParams(const ATypes: TArray<TNotificationType>; const AMessage: string; AFrequency: TNotificationFrequency);
var
  LErrorMessage: string;
begin
  FTypes   := ATypes;
  FMessage := AMessage;

  if (FFrequency<>AFrequency) then
  begin
    FFrequency := AFrequency;
    if Assigned(FNextSend) then
    begin
      FNextSend.Configure(AFrequency);
      FNextSend.ScheduleNext;
      if Assigned(FLogNotification) and (FNextSend.FNextSend > 0) then
        FLogNotification.LogNotification(Format('Próxima notificação agendada para %s', [DateTimeToStr(FNextSend.FNextSend)]));
    end;
  end;

  if not ValidateInputs(LErrorMessage) then
  begin
    if Assigned(FLogNotification) then
      FLogNotification.LogNotification(LErrorMessage);
    raise Exception.Create(LErrorMessage);
  end;
end;

procedure TNotification.Start;
begin
  if Assigned(FThread) then
    raise Exception.Create('Notificação já está em execução.');

  FThread := TNotificationThread.Create(
    procedure
    begin
      NotificationThreadExecute;
    end
  );
  TNotificationThread(FThread).FreeOnTerminate := False;
  FThread.Start;
  if Assigned(FLogNotification) then
    FLogNotification.LogNotification('Enviando...');
end;

procedure TNotification.NotificationThreadExecute;
var
  LSender: INotificationSender;
begin
  try
    while not (FStopEvent.WaitFor(1000) = wrSignaled) do
    begin
      if (Now >= FNextSend.FNextSend) then
      begin
        try
          for var LNotificationType in FTypes do
          begin
            LSender := TNotificationFactory.Registry.Items[LNotificationType]();

            if Assigned(LSender) then
              LSender.SendNotification(FMessage);

            if Assigned(FLogNotification) then
              FLogNotification.LogNotification('Envio realizado com sucesso.', LSender.GetNotificationType);
          end;

          FNextSend.ScheduleNext;

          if Assigned(FLogNotification) and (FNextSend.FNextSend > 0) then
            FLogNotification.LogNotification(Format('Próxima notificação agendada para %s', [DateTimeToStr(FNextSend.FNextSend)]));
        except
          on E: Exception do
            if Assigned(FLogNotification) then
              FLogNotification.LogNotification(Format('Erro no envio: %s', [E.Message]))
            else
              MessageDlg(Format('Erro no envio: %s', [E.Message]), mtError, [mbOk], 0);
        end;
      end;
    end;
  except
    on E: Exception do
      if Assigned(FLogNotification) then
        FLogNotification.LogNotification(Format('Erro na thread: %s', [E.Message]))
      else
        MessageDlg(Format('Erro no envio: %s', [E.Message]), mtError, [mbOk], 0);
  end;
end;

procedure TNotification.Stop;
begin
  if Assigned(FThread) then
  begin
    FStopEvent.SetEvent;
    FThread.WaitFor;
    FreeAndNil(FThread);

    if Assigned(FLogNotification) then
      FLogNotification.LogNotification('Processo de envio finalizado.');
  end;
end;

function TNotification.ValidateInputs(out ErrorMessage: string): Boolean;
begin
  Result := True;
  ErrorMessage := 'Processo Abortado.';

  // Validar: Tipo de Notificação
  if not Assigned(TNotificationFactory.Registry) then
  begin
    ErrorMessage := ErrorMessage + sLineBreak + 'Tipo de Notificação inexistente.';
    Exit(False);
  end else
  if Length(FTypes) = 0 then
  begin
    ErrorMessage := ErrorMessage + sLineBreak + 'Nenhum Tipo de Notificação informado.';
    Exit(False);
  end;

  // Validar: Mensagem
  if (FMessage = '') then
  begin
    ErrorMessage := ErrorMessage + sLineBreak + 'Nenhuma mensagem informada.';
    Exit(False);
  end;

  // Validar: Frequência
  if FNextSend.FFrequency = nfNone then
  begin
    ErrorMessage := ErrorMessage + sLineBreak + 'Frequência não informada.';
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

end.


unit uNotificationFramework;

interface

uses
  Vcl.StdCtrls, System.Classes, System.SysUtils, DateUtils, Vcl.Dialogs, System.SyncObjs;

type
  TNotificationFrequency = (nfNone, nfDaily, nfWeekly, nfMonthly);

  INotificationSender = interface
    ['{A1B2C3D4-E5F6-1234-5678-90ABCDEF1234}']
    procedure SendNotification(const AMessage: string);
    function GetNotificationType: string;
  end;

  TNotification = class
  private
    FSender: INotificationSender;
    FMessage: string;
    FFrequency: TNotificationFrequency;
    FLogOutput: TStrings;
    FNextSend: TDateTime;
    FThread: TThread;
    FThreadTerminated: Boolean;
    FCriticalSection: TCriticalSection;
    procedure NotificationThreadExecute;
    procedure LogNotification(const AMessage: string; const AType: string = '');
  public
    constructor Create(ASender: INotificationSender; const AMessage: string; AFrequency: TNotificationFrequency; ALogOutput: TStrings = nil);
    destructor Destroy; override;

    function ValidateInputs(out ErrorMessage: string): Boolean;
    procedure ScheduleNext;
    procedure Start;
    procedure Stop;

    property NextSend: TDateTime read FNextSend;
  end;

implementation

{ TNotification }

constructor TNotification.Create(ASender: INotificationSender; const AMessage: string; AFrequency: TNotificationFrequency; ALogOutput: TStrings = nil);
begin
  inherited Create;

  FSender    := ASender;
  FMessage   := AMessage;
  FLogOutput := ALogOutput;
  FFrequency := AFrequency;
  FNextSend  := 0;
  FThread    := nil;
  FThreadTerminated := False;
  FCriticalSection := TCriticalSection.Create;
end;

destructor TNotification.Destroy;
begin
  Stop;
  FCriticalSection.Free;
  inherited;
end;

procedure TNotification.LogNotification(const AMessage: string; const AType: string = '');
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

procedure TNotification.NotificationThreadExecute;
begin
  try
    while not FThreadTerminated do
    begin
      if (Now >= FNextSend) then
      begin
        try
          if Assigned(FSender) then
          begin
            FSender.SendNotification(FMessage);
            LogNotification('Envio realizado com sucesso.', FSender.GetNotificationType);
          end;
          ScheduleNext; // Define o próximo envio
        except
          on E: Exception do
            LogNotification(Format('Erro no envio: %s', [E.Message]), FSender.GetNotificationType);
        end;
      end;
      Sleep(1000); // Verifica a cada 1s
    end;
  except
    on E: Exception do
      LogNotification(Format('Erro na thread: %s', [E.Message]), FSender.GetNotificationType);
  end;
end;

procedure TNotification.ScheduleNext;
begin
  case FFrequency of
    nfDaily:   FNextSend := IncDay(Now, 1); // Próximo dia
    nfWeekly:  FNextSend := IncWeek(Now, 1); // Próxima semana
    nfMonthly: FNextSend := IncMonth(Now, 1); // Próximo mês
  else
    FNextSend := 0;
  end;

  if FNextSend > 0 then
    LogNotification(Format('Próxima notificação agendada para %s', [DateTimeToStr(FNextSend)]), FSender.GetNotificationType);
end;

procedure TNotification.Start;
var
  LErrorMessage: string;
begin
  if Assigned(FThread) then
    raise Exception.Create('Notificação já está em execução.');

  if not ValidateInputs(LErrorMessage) then
  begin
    if Assigned(FSender) then
      LogNotification(Format('Erro no envio: %s', [LErrorMessage]), FSender.GetNotificationType)
    else
      LogNotification(Format('Erro no envio: %s', [LErrorMessage]));
    Exit;
  end;

  FThread := TThread.CreateAnonymousThread(
    procedure
    begin
      NotificationThreadExecute;
    end);
  FThread.FreeOnTerminate := False;
  FThread.Start;
  LogNotification('Enviando...', FSender.GetNotificationType);
end;

procedure TNotification.Stop;
begin
  if Assigned(FThread) then
  begin
    FThreadTerminated := True;
    FThread.WaitFor;
    FreeAndNil(FThread);
  end;

  if Assigned(FSender) then
    LogNotification('Processo de envio finalizado.', FSender.GetNotificationType)
  else
    LogNotification('Processo de envio finalizado.');
end;

function TNotification.ValidateInputs(out ErrorMessage: string): Boolean;
begin
  Result := True;
  ErrorMessage := '';

  // Validar: Tipo de Notificação
  if not Assigned(FSender) then
  begin
    ErrorMessage := 'Tipo de Notificação não foi informada.';
    Exit(False);
  end;

  // Validar: Mensagem
  if (FMessage = '') then
  begin
    ErrorMessage := 'Nenhuma mensagem informada.';
    Exit(False);
  end;

  // Validar: Frequência
  if FFrequency = nfNone then
  begin
    ErrorMessage := 'Frequência não informada.';
    Exit(False);
  end;
end;

end.


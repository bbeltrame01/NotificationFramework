unit uNotificationFramework;

interface

uses
  Vcl.StdCtrls, System.Classes, System.SysUtils, DateUtils;

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
    FLogMemo: TMemo;
    FNextSend: TDateTime;
    FThread: TThread;
    FThreadTerminated: Boolean;
    procedure NotificationThreadExecute;
    procedure LogNotification(const AMessage: string; const AType: string = '');
  public
    constructor Create(ASender: INotificationSender; const AMessage: string; AFrequency: TNotificationFrequency; ALogMemo: TMemo = nil);
    destructor Destroy; override;

    procedure ScheduleNext;
    procedure Start;
    procedure Stop;

    property NextSend: TDateTime read FNextSend;
  end;

implementation

{ TNotification }

constructor TNotification.Create(ASender: INotificationSender; const AMessage: string; AFrequency: TNotificationFrequency; ALogMemo: TMemo);
begin
  inherited Create;
  if not Assigned(ASender) then
    raise Exception.Create('Sender não pode ser nil.');

  FSender := ASender;
  FMessage := AMessage;
  FLogMemo := ALogMemo;
  FFrequency := AFrequency;
  FNextSend := 0;
  FThread := nil;
  FThreadTerminated := False;
end;

destructor TNotification.Destroy;
begin
  Stop; // Garante que a thread será finalizada antes de destruir
  inherited;
end;

procedure TNotification.LogNotification(const AMessage: string; const AType: string = '');
begin
  if Assigned(FLogMemo) then
    TThread.Synchronize(nil,
      procedure
      begin
        if (AType = '') then
          FLogMemo.Lines.Add(Format('[%s] %s', [DateTimeToStr(Now), AMessage]))
        else
          FLogMemo.Lines.Add(Format('[%s][%s] %s', [DateTimeToStr(Now), AType, AMessage]));
      end);
end;

procedure TNotification.NotificationThreadExecute;
begin
  try
    while not FThreadTerminated do
    begin
      if Now >= FNextSend then
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
begin
  if Assigned(FThread) then
    raise Exception.Create('Notificação já está em execução.');

  FThreadTerminated := False;

  FThread := TThread.CreateAnonymousThread(
    procedure
    begin
      NotificationThreadExecute;
    end);
  FThread.FreeOnTerminate := False;
  FThread.Start;
end;

procedure TNotification.Stop;
begin
  if Assigned(FThread) then
  begin
    FThreadTerminated := True;
    FThread.WaitFor;
    FreeAndNil(FThread);
  end;
end;

end.


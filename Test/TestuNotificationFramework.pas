unit TestuNotificationFramework;

interface

uses
  TestFramework, Vcl.StdCtrls, System.SysUtils, uNotificationFramework, System.SyncObjs, Generics.Collections,
  System.Classes, DateUtils, uEmailNotification, uSMSNotification, uPushNotification;

type
  TMockEmailNotification = class(TInterfacedObject, IEmailConfigService)
  public
    procedure ConfigureSMTP(const AServer: string; const APort: Integer);
    procedure SetCredentials(const AUsername, APassword: string);
  end;

  TMockNotificationSender = class(TInterfacedObject, INotificationSender)
  private
    FEmailConfigService: TMockEmailNotification;
    FMessagesSent: TStringList;
    FRaiseError: Boolean;
  public
    constructor Create;
    destructor Destroy; override;

    procedure SendNotification(const AMessage: string);
    function GetMessagesSent: TStringList;
    function GetNotificationType: string;

    property EmailConfigService: TMockEmailNotification read FEmailConfigService write FEmailConfigService;
    property RaiseError: Boolean read FRaiseError write FRaiseError;
  end;

  TestTNotification = class(TTestCase)
  strict private
    FMockSender: TMockNotificationSender;
    FLogOutput: TStringList;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestLogNotification;
    procedure TestScheduleNext;
    procedure TestStartStop;
    procedure TestSendNotification;
    procedure TestHandleSendError;
    procedure TestInvalidSender;
    procedure TestInvalidMessage;
    procedure TestInvalidFrequency;
    procedure TestThreadAlreadyRunning;
  end;

const
  SIMPLE_MESSAGE = 'Notificação Simples';

implementation

{ TMockEmailNotification }

procedure TMockEmailNotification.ConfigureSMTP(const AServer: string; const APort: Integer);
begin
  (*
    TODO: Configurar SMTP para envio de E-Mail
  *)
end;

procedure TMockEmailNotification.SetCredentials(const AUsername, APassword: string);
begin
  (*
    TODO: Configurar Credenciais para envio de E-Mail
  *)
end;

{ TMockNotificationSender }

constructor TMockNotificationSender.Create;
begin
  FMessagesSent := TStringList.Create;

  FEmailConfigService := TMockEmailNotification.Create;
  FEmailConfigService.ConfigureSMTP('smtp.server.com', 465);
  FEmailConfigService.SetCredentials('username', 'password');

  FRaiseError := False;
end;

destructor TMockNotificationSender.Destroy;
begin
  FMessagesSent.Free;
  inherited;
end;

function TMockNotificationSender.GetMessagesSent: TStringList;
begin
  Result := FMessagesSent;
end;

function TMockNotificationSender.GetNotificationType: string;
begin
  Result := 'MockNotification';
end;

procedure TMockNotificationSender.SendNotification(const AMessage: string);
begin
  if FRaiseError then
    raise Exception.Create('Erro simulado no envio de notificação.');
  FMessagesSent.Add(AMessage);
end;

{ TestTNotification }

procedure TestTNotification.SetUp;
begin
  FMockSender := TMockNotificationSender.Create;
  FLogOutput := TStringList.Create;
end;

procedure TestTNotification.TearDown;
begin
  FMockSender := nil;
end;

// Teste: procedure LogNotification
procedure TestTNotification.TestLogNotification;
var
  LLogNotification: ILogNotification;
begin
  LLogNotification := TLogNotification.Create(FLogOutput);
  LLogNotification.LogNotification(SIMPLE_MESSAGE, 'INFO');

  Check(FLogOutput.Count > 0, 'Nenhuma mensagem foi registrada no log.');
  Assert(FLogOutput.Text.Contains(SIMPLE_MESSAGE));
  Assert(FLogOutput.Text.Contains('INFO'));
end;

// Teste: procedure ScheduleNext
procedure TestTNotification.TestScheduleNext;
var
  LScheduler: TNextSendNotification;
begin
  LScheduler := TNextSendNotification.Create;
  try
    LScheduler.Configure(nfDaily);
    LScheduler.ScheduleNext;
    Check(Round(LScheduler.FNextSend - Now) >= 1, '(Diária) O próximo envio não foi agendado corretamente.');

    LScheduler.Configure(nfWeekly);
    LScheduler.ScheduleNext;
    Check(Round(LScheduler.FNextSend - Now) >= 7, '(Semanal) O próximo envio não foi agendado corretamente.');

    LScheduler.Configure(nfMonthly);
    LScheduler.ScheduleNext;
    Check(Round(LScheduler.FNextSend - Now) >= 28, '(Mensal) O próximo envio não foi agendado corretamente.');
  finally
    LScheduler.Free;
  end;
end;

// Teste: precedure Start/Stop
procedure TestTNotification.TestStartStop;
var
  LNotification: INotification;
begin
  LNotification := TNotification.Create([ntEmail,ntPush,ntSMS], SIMPLE_MESSAGE, nfDaily, FLogOutput);
  try
    LNotification.Start;
    Check(FLogOutput.Text.Contains('Enviando.'), 'O envio não foi realizado corretamente.');

    LNotification.Stop;
    Check(FLogOutput.Text.Contains('Processo de envio finalizado.'), 'O envio não foi finalizado corretamente.');
  except
    on E: Exception do
      Fail(E.Message);
  end;
end;

// Teste: procedure SendNotification
procedure TestTNotification.TestSendNotification;
var
  LEmailSender: INotificationSender;
begin
  try
    LEmailSender := TEmailNotification.Create(FMockSender.EmailConfigService);
    FMockSender.RaiseError := False;
    FMockSender.SendNotification(SIMPLE_MESSAGE);

    CheckEquals(FMockSender.GetNotificationType, 'MockNotification', 'O processo não foi iniciado corretamente.');
    CheckEquals(FMockSender.FMessagesSent.Count, 1, 'A mensagem não foi enviada corretamente.');
    CheckEquals(FMockSender.GetMessagesSent[0], SIMPLE_MESSAGE, 'A mensagem enviada está diferente da original.');
  except
    on E: Exception do
      Fail(E.Message);
  end;
end;

// Teste: Tratamento de erro no envio
procedure TestTNotification.TestHandleSendError;
var
  LLogNotification: ILogNotification;
begin
  LLogNotification := TLogNotification.Create(FLogOutput);
  try
    try
      raise Exception.Create('Erro no envio');
    except
      on E: Exception do
        LLogNotification.LogNotification(E.Message, 'ERROR');
    end;
    Check(FLogOutput.Text.Contains('Erro no envio'), 'Erro no envio não foi registrado no log.');
  finally
    LLogNotification := nil;
  end;
end;

// Teste: Tipo de Notificação inválido
procedure TestTNotification.TestInvalidSender;
begin
  try
    TNotificationFactory.GetNotification(TNotificationType(-1));

    Fail('Exceção esperada ao setar um Tipo de Notificação inválido.');
  except
    on E: Exception do
      CheckEquals(E.Message, 'Tipo de Notificação inválido ou inexistente.', 'Mensagem de erro incorreta.');
  end;
end;

// Teste: Mensagem inválida
procedure TestTNotification.TestInvalidMessage;
var
  LNotification: INotification;
begin
  try
    LNotification := TNotification.Create([ntEmail], '', nfDaily, FLogOutput);
    LNotification.Start;

    Fail('Exceção esperada ao iniciar uma thread sem mensagem informada.');
  except
    on E: Exception do
      Check(E.Message.Contains('Nenhuma mensagem informada.'), 'Mensagem de erro incorreta.');
  end;
end;

// Teste: Frequência inválida (nfNone)
procedure TestTNotification.TestInvalidFrequency;
var
  LNotification: INotification;
begin
  try
    LNotification := TNotification.Create([ntEmail], SIMPLE_MESSAGE, nfNone, FLogOutput);
    LNotification.Start;

    Fail('Exceção esperada ao iniciar uma thread com Frequência inválida (nfNone).');
  except
    on E: Exception do
      Check(E.Message.Contains('Frequência não informada.'), 'Mensagem de erro incorreta.');
  end;
end;

// Teste: Thread já em execução
procedure TestTNotification.TestThreadAlreadyRunning;
var
  LNotification: INotification;
begin
  LNotification := TNotification.Create([ntEmail], SIMPLE_MESSAGE, nfDaily, FLogOutput);
  try
    LNotification.Start;
    try
      LNotification.Start;

      Fail('Exceção esperada ao iniciar uma thread já em execução.');
    except
      on E: Exception do
        CheckEquals(E.Message, 'Notificação já está em execução.', 'Mensagem de erro incorreta.');
    end;
  finally
    LNotification.Stop;
  end;
end;

initialization
  RegisterTest(TestTNotification.Suite);

end.


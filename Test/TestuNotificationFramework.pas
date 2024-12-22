unit TestuNotificationFramework;

interface

uses
  TestFramework, Vcl.StdCtrls, System.SysUtils, uNotificationFramework,
  System.Classes, DateUtils;

type
  TMockNotificationSender = class(TInterfacedObject, INotificationSender)
  private
    FMessagesSent: TStringList;
    FRaiseError: Boolean;
  public
    constructor Create;
    destructor Destroy; override;

    procedure SendNotification(const AMessage: string);
    function GetMessagesSent: TStringList;
    function GetNotificationType: string;

    property RaiseError: Boolean read FRaiseError write FRaiseError;
  end;

  TestTNotification = class(TTestCase)
  strict private
    FNotification: TNotification;
    FMockSender: TMockNotificationSender;
    FLogList: TStringList;
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

implementation

{ TMockNotificationSender }

constructor TMockNotificationSender.Create;
begin
  FMessagesSent := TStringList.Create;
  FRaiseError := False;
end;

destructor TMockNotificationSender.Destroy;
begin
  FMessagesSent.Free;
  inherited;
end;

procedure TMockNotificationSender.SendNotification(const AMessage: string);
begin
  if FRaiseError then
    raise Exception.Create('Erro simulado no envio de notificação.');
  FMessagesSent.Add(AMessage);
end;

function TMockNotificationSender.GetMessagesSent: TStringList;
begin
  Result := FMessagesSent;
end;

function TMockNotificationSender.GetNotificationType: string;
begin
  Result := 'MockNotification';
end;

{ TestTNotification }

procedure TestTNotification.SetUp;
begin
  FMockSender := TMockNotificationSender.Create;
  FLogList := TStringList.Create;
  FNotification := TNotification.Create(FMockSender, 'Notificação Simples', nfDaily, FLogList);
end;

procedure TestTNotification.TearDown;
begin
  FreeAndNil(FNotification);
  FreeAndNil(FLogList);
  FMockSender := nil;
end;

// Teste: procedure LogNotification
procedure TestTNotification.TestLogNotification;
begin
  FNotification.Start;
  Sleep(1000); // Aguarda o log ser gerado
  Check(FLogList.Count > 0, 'Nenhuma mensagem foi registrada no log.');
  Check(FLogList.Text.Contains('Enviando'), 'Log de início ausente.');
  FNotification.Stop;
end;

// Teste: procedure ScheduleNext
procedure TestTNotification.TestScheduleNext;
begin
  FNotification.ScheduleNext;
  Check(FNotification.NextSend > Now, 'O próximo envio não foi agendado corretamente.');
  Check(SecondsBetween(FNotification.NextSend, Now) >= 10, 'O intervalo de agendamento está incorreto.');
end;

// Teste: precedure Start/Stop
procedure TestTNotification.TestStartStop;
begin
  FNotification.Start;
  Check(FLogList.Text.Contains('Enviando'), 'Log de início ausente.');
  FNotification.Stop;
  Check(FLogList.Text.Contains('Processo de envio finalizado.'), 'Log de parada ausente.');
end;

// Teste: procedure SendNotification
procedure TestTNotification.TestSendNotification;
begin
  FNotification.Start;
  Sleep(5000); // Aguarda pelo menos uma notificação ser enviada (5s)
  Check(FMockSender.GetMessagesSent.Count > 0, 'Nenhuma mensagem foi enviada.');
  CheckEquals('Notificação Simples', FMockSender.GetMessagesSent[0], 'A mensagem enviada está incorreta.');
  FNotification.Stop;
end;

// Novo Teste: Tratamento de erro no envio
procedure TestTNotification.TestHandleSendError;
begin
  FMockSender.RaiseError := True;
  FNotification.Start;
  Sleep(5000); // Tempo suficiente para o envio e erro
  Check(FLogList.Text.Contains('Erro no envio'), 'Erro no envio não foi registrado no log.');
  FNotification.Stop;
end;

// Teste: Frequência inválida (nfNone)
procedure TestTNotification.TestInvalidFrequency;
begin
  TearDown;

  FMockSender := TMockNotificationSender.Create;
  FLogList := TStringList.Create;
  FNotification := TNotification.Create(FMockSender, 'Notificação Simples', nfNone, FLogList);

  FMockSender.RaiseError := True;
  FNotification.Start;
  Sleep(2000);
  Check(FLogList.Text.Contains('Frequência não informada'), 'Notificação enviada com frequência inválida (nfNone).');
  FNotification.Stop;
end;

// Teste: Mensagem inválida
procedure TestTNotification.TestInvalidMessage;
begin
  TearDown;

  FMockSender := TMockNotificationSender.Create;
  FLogList := TStringList.Create;
  FNotification := TNotification.Create(FMockSender, '', nfDaily, FLogList);

  FMockSender.RaiseError := True;
  FNotification.Start;
  Sleep(2000);
  Check(FLogList.Text.Contains('Nenhuma mensagem informada'), 'Notificação enviada sem mensagem.');
  FNotification.Stop;
end;

// Teste: Tipo de Notificação não informado
procedure TestTNotification.TestInvalidSender;
begin
  TearDown;

  FLogList := TStringList.Create;
  FNotification := TNotification.Create(nil, 'Notificação Simples', nfDaily, FLogList);

  FNotification.Start;
  Sleep(2000);
  Check(FLogList.Text.Contains('Tipo de Notificação não foi informada'), 'Tipo de Notificação não informado.');
  FNotification.Stop;
end;

// Teste: Thread já em execução
procedure TestTNotification.TestThreadAlreadyRunning;
begin
  FNotification.Start;
  try
    FNotification.Start; // Deve levantar exceção
    Fail('Exceção esperada ao iniciar uma thread já em execução.');
  except
    on E: Exception do
      Check(E.Message.Contains('Notificação já está em execução'), 'Mensagem de erro incorreta.');
  end;
  FNotification.Stop;
end;

initialization
  RegisterTest(TestTNotification.Suite);

end.


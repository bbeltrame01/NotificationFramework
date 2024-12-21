unit TestuNotificationFramework;

interface

uses
  TestFramework, Vcl.StdCtrls, System.SysUtils, uNotificationFramework,
  System.Classes, DateUtils;

type
  TMockNotificationSender = class(TInterfacedObject, INotificationSender)
  private
    FMessagesSent: TStringList;
  public
    constructor Create;
    destructor Destroy; override;

    procedure SendNotification(const AMessage: string);
    function GetMessagesSent: TStringList;
    function GetNotificationType: string;
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
  end;

implementation

{ TMockNotificationSender }

constructor TMockNotificationSender.Create;
begin
  FMessagesSent := TStringList.Create;
end;

destructor TMockNotificationSender.Destroy;
begin
  FMessagesSent.Free;
  inherited;
end;

procedure TMockNotificationSender.SendNotification(const AMessage: string);
begin
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

procedure TestTNotification.TestLogNotification;
begin
  FNotification.Start;
  Sleep(1000); // Aguarda o log ser gerado
  Check(FLogList.Count > 0, 'Nenhuma mensagem foi registrada no log.');
  Check(FLogList.Text.Contains('Enviando'), 'Log de início ausente.');
  FNotification.Stop;
end;

procedure TestTNotification.TestScheduleNext;
begin
  FNotification.ScheduleNext;
  Check(FNotification.NextSend > Now, 'O próximo envio não foi agendado corretamente.');
  Check(SecondsBetween(FNotification.NextSend, Now) >= 10, 'O intervalo de agendamento está incorreto.');
end;

procedure TestTNotification.TestStartStop;
begin
  FNotification.Start;
  Check(FLogList.Text.Contains('Enviando'), 'Log de início ausente.');
  FNotification.Stop;
  Check(FLogList.Text.Contains('Processo de envio finalizado.'), 'Log de parada ausente.');
end;

procedure TestTNotification.TestSendNotification;
begin
  FNotification.Start;
  Sleep(5000); // Aguarda pelo menos uma notificação ser enviada (5s)
  Check(FMockSender.GetMessagesSent.Count > 0, 'Nenhuma mensagem foi enviada.');
  CheckEquals('Notificação Simples', FMockSender.GetMessagesSent[0], 'A mensagem enviada está incorreta.');
  FNotification.Stop;
end;

initialization
  RegisterTest(TestTNotification.Suite);

end.


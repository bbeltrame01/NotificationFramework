unit uNotificationFrameworkTests;

interface

uses
  DUnitX.TestFramework, uNotificationFramework;

type
  [TestFixture]
  TNotificationTests = class
  private
    FMockSender: INotificationSender;
  public
    [Setup]
    procedure Setup;

    [Test]
    procedure TestSendNotification;
  end;

implementation

uses
  System.SysUtils;

type
  TMockNotificationSender = class(TInterfacedObject, INotificationSender)
  private
    FMessageSent: string;
  public
    procedure SendNotification(const AMessage: string);
    property MessageSent: string read FMessageSent;
  end;

procedure TMockNotificationSender.SendNotification(const AMessage: string);
begin
  FMessageSent := AMessage;
end;

{ TNotificationTests }

procedure TNotificationTests.Setup;
begin
  FMockSender := TMockNotificationSender.Create;
end;

procedure TNotificationTests.TestSendNotification;
var
  Notification: TNotification;
  Mock: TMockNotificationSender;
begin
  Mock := TMockNotificationSender(FMockSender);
  Notification := TNotification.Create(FMockSender, 'Test Message', nfDaily);
  try
    Notification.Send;
    Assert.AreEqual('Test Message', Mock.MessageSent, 'Message was not sent correctly.');
  finally
    Notification.Free;
  end;
end;

end.


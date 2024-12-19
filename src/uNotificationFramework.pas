unit uNotificationFramework;

interface

type
  TNotificationFrequency = (nfDaily, nfWeekly, nfMonthly);

  INotificationSender = interface
    ['{A1B2C3D4-E5F6-1234-5678-90ABCDEF1234}']
    procedure SendNotification(const AMessage: string);
  end;

  TNotification = class
  private
    FSender: INotificationSender;
    FMessage: string;
    FFrequency: TNotificationFrequency;
    FNextSend: TDateTime;
  public
    constructor Create(ASender: INotificationSender; const AMessage: string; AFrequency: TNotificationFrequency);
    procedure ScheduleNext;
    procedure Send;
    property NextSend: TDateTime read FNextSend;
  end;

implementation

uses
  SysUtils, DateUtils;

{ TNotification }

constructor TNotification.Create(ASender: INotificationSender; const AMessage: string; AFrequency: TNotificationFrequency);
begin
  FSender := ASender;
  FMessage := AMessage;
  FFrequency := AFrequency;
  ScheduleNext;
end;

procedure TNotification.ScheduleNext;
begin
  case FFrequency of
    nfDaily: FNextSend := Now + 1;
    nfWeekly: FNextSend := Now + 7;
    nfMonthly: FNextSend := IncMonth(Now, 1);
  end;
end;

procedure TNotification.Send;
begin
  if Assigned(FSender) then
  begin
    FSender.SendNotification(FMessage);
    ScheduleNext;
  end;
end;

end.


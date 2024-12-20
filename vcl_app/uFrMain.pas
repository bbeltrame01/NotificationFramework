unit uFrMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.CheckLst, uNotificationFramework,
  uEmailNotification, uPushNotification, uSMSNotification;

type
  TFrMain = class(TForm)
    clbTipoNotificacao: TCheckListBox;
    cbbFrequencia: TComboBox;
    btnTeste: TButton;
    memLogs: TMemo;
    labFrequencia: TLabel;
    procedure btnTesteClick(Sender: TObject);
  private
    { Private declarations }
    procedure LogNotification(const AMessage: string);
  public
    { Public declarations }
  end;

var
  FrMain: TFrMain;

implementation

{$R *.dfm}

procedure TFrMain.btnTesteClick(Sender: TObject);
const
  tnEMAIL = 0; tnPUSH = 1; tnSMS = 2;
var
  LNotification: TNotification;
  LFrequency: TNotificationFrequency;
  procedure SendNotification(ANotificationSender: INotificationSender);
  begin
    LNotification := TNotification.Create(ANotificationSender, 'Sample Notification', LFrequency);
    try
      LNotification.Send;
      LogNotification('Notification sent successfully.');
    finally
      LNotification.Free;
    end;
  end;
begin
  case cbbFrequencia.ItemIndex of
    0: LFrequency := nfDaily;
    1: LFrequency := nfWeekly;
    2: LFrequency := nfMonthly;
  end;
  { E-Mail }
  if clbTipoNotificacao.Checked[tnEMAIL] then
    SendNotification(TEmailNotification.Create);
  { Notificações do Sistema }
  if clbTipoNotificacao.Checked[tnPUSH] then
    SendNotification(TPushNotification.Create);
  { SMS }
  if clbTipoNotificacao.Checked[tnSMS] then
    SendNotification(TSMSNotification.Create);
end;

procedure TFrMain.LogNotification(const AMessage: string);
begin
  memLogs.Lines.Add(AMessage);
end;

end.

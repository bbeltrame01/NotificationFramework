unit uFrMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.CheckLst, uNotificationFramework,
  uEmailNotification, uPushNotification, uSMSNotification, Vcl.ExtCtrls, System.Generics.Collections;

type
  TFrMain = class(TForm)
    clbTipoNotificacao: TCheckListBox;
    cbbFrequencia: TComboBox;
    btnStart: TButton;
    memLogs: TMemo;
    labFrequencia: TLabel;
    btnStop: TButton;
    procedure btnStartClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
  private
    FNotifications: TList<TNotification>;
    procedure Start;
    procedure Stop;
    procedure CtrlButtons;
    function GetFrequency: TNotificationFrequency;
    function ValidateInputs(out ErrorMessage: string): Boolean;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  FrMain: TFrMain;

implementation

{$R *.dfm}

constructor TFrMain.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FNotifications := TList<TNotification>.Create;
end;

destructor TFrMain.Destroy;
begin
  Stop;
  FNotifications.Free;
  inherited Destroy;
end;

procedure TFrMain.btnStartClick(Sender: TObject);
begin
  Start;
end;

procedure TFrMain.btnStopClick(Sender: TObject);
begin
  Stop;
end;

procedure TFrMain.CtrlButtons;
begin
  btnStart.Enabled := not btnStart.Enabled;
  btnStop.Enabled := not btnStart.Enabled;
  clbTipoNotificacao.Enabled := btnStart.Enabled;
  cbbFrequencia.Enabled := btnStart.Enabled;
end;

function TFrMain.GetFrequency: TNotificationFrequency;
begin
  case cbbFrequencia.ItemIndex of
    0: Result := nfDaily;
    1: Result := nfWeekly;
    2: Result := nfMonthly;
  else
    Result := nfNone;
  end;
end;

function TFrMain.ValidateInputs(out ErrorMessage: string): Boolean;
var
  i: Integer;
  bTipoNotificacao: Boolean;
begin
  Result := True;
  ErrorMessage := '';

  // Validar: Tipos de Notificação
  bTipoNotificacao := False;
  for i := 0 to Pred(clbTipoNotificacao.Count) do
  begin
    if clbTipoNotificacao.Checked[i] then
      bTipoNotificacao := True;
  end;

  if not bTipoNotificacao then
  begin
    ErrorMessage := 'Nenhum tipo de notificação informado.';
    Exit(False);
  end;

  // Validar: Frequência
  if GetFrequency = nfNone then
  begin
    ErrorMessage := 'Frequência não informada.';
    Exit(False);
  end;
end;

procedure TFrMain.Start;
const
  tnEMAIL = 0; tnPUSH = 1; tnSMS = 2;
var
  LFrequency: TNotificationFrequency;
  ErrorMessage: string;

  procedure SendNotification(ANotificationSender: INotificationSender);
  var
    Notification: TNotification;
  begin
    Notification := TNotification.Create(ANotificationSender, 'Notificação Simples', LFrequency, memLogs.Lines);
    FNotifications.Add(Notification);

    try
      Notification.Start;
    except
      on E: Exception do
        ShowMessage(Format('Erro ao realizar envio. %s', [E.Message]));
    end;
  end;
begin
  if not ValidateInputs(ErrorMessage) then
  begin
    MessageDlg(ErrorMessage, mtWarning, [mbOk], 0);
    Exit;
  end;

  CtrlButtons;
  memLogs.Lines.Add('Iniciando o processo de envio de notificações...');
  LFrequency := GetFrequency;

  // Criar e enviar notificações
  if clbTipoNotificacao.Checked[tnEMAIL] then
    SendNotification(TEmailNotification.Create);

  if clbTipoNotificacao.Checked[tnPUSH] then
    SendNotification(TPushNotification.Create);

  if clbTipoNotificacao.Checked[tnSMS] then
    SendNotification(TSMSNotification.Create);
end;

procedure TFrMain.Stop;
var
  Notification: TNotification;
begin
  try
    for Notification in FNotifications do
      Notification.Free;
    FNotifications.Clear;
  finally
    CtrlButtons;
  end;
end;

end.


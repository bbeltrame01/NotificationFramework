unit uFrMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.CheckLst, uNotificationFramework,
  Vcl.ExtCtrls, System.Generics.Collections, System.UITypes;

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
    procedure clbTipoNotificacaoClickCheck(Sender: TObject);
    procedure cbbFrequenciaChange(Sender: TObject);
  private
    FNotification: INotification;
    procedure Start;
    procedure Stop;
    procedure CtrlButtons;
    function GetTypes: TArray<TNotificationType>;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

const
  SIMPLE_MESSAGE = 'Notificação Simples';

var
  FrMain: TFrMain;

implementation

{$R *.dfm}

constructor TFrMain.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

destructor TFrMain.Destroy;
begin
  Stop;
  inherited Destroy;
end;

function TFrMain.GetTypes: TArray<TNotificationType>;
begin
  Result:=[];

  { Envio de E-Mail }
  if clbTipoNotificacao.Checked[Integer(ntEMAIL)] then
    Result := Result + [ntEmail];

  { Envio de Push }
  if clbTipoNotificacao.Checked[Integer(ntPUSH)] then
    Result := Result + [ntPush];

  { Envio de SMS }
  if clbTipoNotificacao.Checked[Integer(ntSMS)] then
    Result := Result + [ntSMS];
end;

procedure TFrMain.btnStartClick(Sender: TObject);
begin
  Start;
end;

procedure TFrMain.btnStopClick(Sender: TObject);
begin
  Stop;
end;

procedure TFrMain.cbbFrequenciaChange(Sender: TObject);
begin
  if Assigned(FNotification) then
    FNotification.UpdateParams(GetTypes(), SIMPLE_MESSAGE, TNotificationFrequency(cbbFrequencia.ItemIndex));
end;

procedure TFrMain.clbTipoNotificacaoClickCheck(Sender: TObject);
begin
  if Assigned(FNotification) then
  begin
    if (Length(GetTypes)=0) then
    begin
      MessageDlg('Nenhum Tipo de Notificação informado.', TMsgDlgType.mtError, [mbOk], 0);
      clbTipoNotificacao.Checked[clbTipoNotificacao.ItemIndex] := True;
      Abort;
    end;

    FNotification.UpdateParams(GetTypes(), SIMPLE_MESSAGE, TNotificationFrequency(cbbFrequencia.ItemIndex));
  end;
end;

procedure TFrMain.CtrlButtons;
begin
  if Length(GetTypes)=0 then Abort;

  btnStart.Enabled := not btnStart.Enabled;
  btnStop.Enabled  := not btnStart.Enabled;
end;

procedure TFrMain.Start;
begin
  FNotification := TNotification.Create(
    GetTypes(),                                      // Tipos de Envio: [ntEmail, ntPush, ntSMS]
    SIMPLE_MESSAGE,                                  // Mensagem: 'Notificação Simples'
    TNotificationFrequency(cbbFrequencia.ItemIndex), // Frequência de Envio: (nfDaily=0, nfWeekly=1, nfMonthly=2)
    memLogs.Lines                                    // (Opcional) Logs: TStrings
  );
  FNotification.Start;
  CtrlButtons;
end;

procedure TFrMain.Stop;
begin
  if Assigned(FNotification) then
  begin
    try
      FNotification.Stop;
    finally
      FNotification := nil;
      CtrlButtons;
    end;
  end;
end;

end.


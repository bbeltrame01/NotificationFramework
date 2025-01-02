unit uFrMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.CheckLst, uNotificationFramework,
  Vcl.ExtCtrls, System.Generics.Collections;

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
    procedure UpdateParams(Sender: TObject);
  private
    FNotification: TNotification;
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
  CtrlButtons;
  Start;
end;

procedure TFrMain.btnStopClick(Sender: TObject);
begin
  Stop;
end;

procedure TFrMain.CtrlButtons;
begin
  btnStart.Enabled := not btnStart.Enabled;
  btnStop.Enabled  := not btnStart.Enabled;
end;

procedure TFrMain.Start;
begin
  FNotification := TNotification.Create(GetTypes(), SIMPLE_MESSAGE, TNotificationFrequency(cbbFrequencia.ItemIndex), memLogs.Lines);
  FNotification.Start;
end;

procedure TFrMain.Stop;
begin
  if Assigned(FNotification) then
  begin
    try
      FNotification.Stop;
    finally
      CtrlButtons;
    end;
  end;
end;

procedure TFrMain.UpdateParams(Sender: TObject);
begin
  if Assigned(FNotification) then
    FNotification.UpdateParams(GetTypes(), SIMPLE_MESSAGE, TNotificationFrequency(cbbFrequencia.ItemIndex));
end;

end.


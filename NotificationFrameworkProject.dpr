program NotificationFrameworkProject;

uses
  Vcl.Forms,
  uFrMain in 'vcl_app\uFrMain.pas' {FrMain},
  uNotificationFramework in 'src\uNotificationFramework.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrMain, FrMain);
  Application.Run;
end.

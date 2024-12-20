program NotificationFrameworkProject;

uses
  Vcl.Forms,
  uFrMain in 'vcl_app\uFrMain.pas' {FrMain},
  uEmailNotification in 'src\uEmailNotification.pas',
  uNotificationFramework in 'src\uNotificationFramework.pas',
  uPushNotification in 'src\uPushNotification.pas',
  uSMSNotification in 'src\uSMSNotification.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrMain, FrMain);
  Application.Run;
end.

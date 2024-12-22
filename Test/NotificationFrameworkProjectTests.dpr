program NotificationFrameworkProjectTests;
{

  Delphi DUnit Test Project
  -------------------------
  This project contains the DUnit test framework and the GUI/Console test runners.
  Add "CONSOLE_TESTRUNNER" to the conditional defines entry in the project options
  to use the console test runner.  Otherwise the GUI test runner will be used by
  default.

}

{$IFDEF CONSOLE_TESTRUNNER}
{$APPTYPE CONSOLE}
{$ENDIF}

uses
  DUnitTestRunner,
  uFrMain in '..\vcl_app\uFrMain.pas',
  TestuNotificationFramework in 'TestuNotificationFramework.pas',
  uNotificationFramework in '..\src\uNotificationFramework.pas',
  uEmailNotification in '..\src\uEmailNotification.pas',
  uPushNotification in '..\src\uPushNotification.pas',
  uSMSNotification in '..\src\uSMSNotification.pas';

{$R *.RES}

begin
  DUnitTestRunner.RunRegisteredTests;
end.


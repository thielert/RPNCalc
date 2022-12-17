program DelphiRPNCalc;

uses
  System.StartUpCopy,
  FMX.Forms,
  RPNCalc in 'RPNCalc.pas' {Form_RPNCalc};

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  Application.CreateForm(TForm_RPNCalc, Form_RPNCalc);
  Application.Run;
end.

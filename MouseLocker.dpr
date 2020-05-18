program MouseLocker;

uses
  Windows,
  Forms,
  Unit1 in 'Unit1.pas' {Form1},
  Appl,
  Main in 'Main.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.

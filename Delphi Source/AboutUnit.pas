unit AboutUnit;

interface

uses
  Winapi.Windows,Winapi.Messages,System.SysUtils,System.Variants,System.Classes,
  Vcl.Graphics,Vcl.Controls,Vcl.Forms,Vcl.Dialogs,Vcl.StdCtrls,Vcl.ExtCtrls,
  ShellAPI;

type
  TAboutForm = class(TForm)
    Panel1: TPanel;
    Label2: TLabel;
    Label1: TLabel;
    appversion: TLabel;
    apptitle: TLabel;
    procedure appversionClick(Sender: TObject);
    procedure Label2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AboutForm: TAboutForm;

implementation

{$R *.dfm}

procedure TAboutForm.appversionClick(Sender: TObject);
begin
 Close;
end;

procedure TAboutForm.Label2Click(Sender: TObject);
begin
 ShellExecute(Application.Handle,PChar('open'),PChar('http://www.geraldholdsworth.co.uk'),PChar(0),nil,SW_NORMAL);
end;

end.

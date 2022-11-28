unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, IniFiles,
  Controls, Forms, uniGUITypes, uniGUIAbstractClasses, StrUtils,
  uniGUIClasses, uniGUIRegClasses, uniGUIForm, uniGUIBaseClasses, uniMemo,
  uniButton, REST.Types, IdExplicitTLSClientServerBase, IdSSLOpenSSL, IdSMTP,
  uniGroupBox, uniEdit, uniLabel;

type
  TMainForm = class(TUniForm)
    btnSendEmailIndy: TUniButton;
    btnLoginOffice: TUniButton;
    GroupOffice: TUniGroupBox;
    UniMemo: TUniMemo;
    edtSendTo: TUniEdit;
    edtMicrosoftAccount: TUniEdit;
    lblMicrosoftAccount: TUniLabel;
    lblSendTo: TUniLabel;
    procedure UniFormShow(Sender: TObject);
    procedure btnAuthWithRefreshTokenClick(Sender: TObject);
    procedure btnSendEmailIndyClick(Sender: TObject);
    procedure btnLoginOfficeClick(Sender: TObject);
    procedure UniFormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    FIniSettings : TIniFile;
    authCode, session, session_state, realmId, refreshToken: string;
  end;

function MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  uniGUIVars, MainModule, uniGUIApplication, uDm;

function MainForm: TMainForm;
begin
  Result := TMainForm(UniMainModule.GetFormInstance(TMainForm));
end;

procedure TMainForm.btnAuthWithRefreshTokenClick(Sender: TObject);
begin
  dm.ChangeRefreshTokenToAccessToken;
end;

procedure TMainForm.btnLoginOfficeClick(Sender: TObject);
begin
  dm.ShowLoginOffice;
end;

procedure TMainForm.btnSendEmailIndyClick(Sender: TObject);
begin
  dm.SendEmailOffice;
end;

procedure TMainForm.UniFormCreate(Sender: TObject);
var
  LFilename: string;
begin
  LFilename := ChangeFileExt(ParamStr(0),'.ini');
  FIniSettings := TIniFile.Create(LFilename);
end;

procedure TMainForm.UniFormShow(Sender: TObject);
var
  i: integer;
begin
  authCode := UniSession.UniApplication.Parameters.values['code'];
  session_state := UniSession.UniApplication.Parameters.values['session_state'];
  realmId := UniSession.UniApplication.Parameters.values['realmId'];

  UniMemo.Lines.Clear;

  for i := 0 to UniSession.UniApplication.Parameters.Count - 1 do
  begin
    UniMemo.Lines.Add(UniSession.UniApplication.Parameters.Names[i]);
    UniMemo.Lines.Add(UniSession.UniApplication.Parameters.ValueFromIndex[i]);
    UniMemo.Lines.Add('');
  end;

  dm.SetupAuthOffice;

  //change code to access token due auth setup above
  if (authCode <> EmptyStr) then
    dm.ChangeCodeToAccesToken;
end;

initialization
  RegisterAppFormClass(TMainForm);

end.

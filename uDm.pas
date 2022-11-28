unit uDm;

interface

uses
  SysUtils, Classes, REST.Types, REST.Client, Data.Bind.Components,
  Data.Bind.ObjectScope, System.Net.URLClient, uniGUIApplication,
  REST.Authenticator.OAuth, System.NetEncoding, DateUtils, IdMessage,
  IdBaseComponent, IdComponent, IdCustomTCPServer, IdTCPServer, IdCmdTCPServer,
  IdExplicitTLSClientServerBase, IdSMTPServer, IdTCPConnection, IdTCPClient,
  IdMessageClient, IdSMTPBase, IdSMTP, IdIOHandler, IdIOHandlerSocket,
  IdIOHandlerStack, IdSSL, IdSSLOpenSSL, IdServerIOHandler, IdSASLCollection,
  IdSASL;

type
  TDm = class(TDataModule)
    RESTResponse: TRESTResponse;
    RESTRequest: TRESTRequest;
    RESTClient: TRESTClient;
    OAuth2Authenticator: TOAuth2Authenticator;
    IdSMTP: TIdSMTP;
    IdSSLIOHandlerSocketOpenSSL: TIdSSLIOHandlerSocketOpenSSL;
    IdMessage: TIdMessage;
  private
    procedure ChangeRefreshTokenToAccesToken;
    { Private declarations }
  public
    { Public declarations }
    procedure SetupAuthOffice;
    procedure ChangeCodeToAccesToken;
    procedure ChangeRefreshTokenToAccessToken;
    procedure ShowLoginOffice;
    procedure SendEmailOffice;
  end;

function Dm: TDm;

implementation

{$R *.dfm}

uses
  UniGUIVars, uniGUIMainModule, MainModule, Main, IdSASLXOAUTH;

const
  REDIRECT_URL = 'http://localhost:8077';
  OFFICE_CLIENTID = 'YOUR_OFFICE_CLIENTID_FROM_AZURE';
  OFFICE_CLIENTSECRET = 'YOUR_OFFICE_CLIENTSECRET_FROM_AZURE';

procedure TDm.ShowLoginOffice;
var
  uri : TURI;
  LTokenName : string;
begin
  SetupAuthOffice;
  uri := TURI.Create(OAuth2Authenticator.AuthorizationRequestURI);
  UniSession.UrlRedirect(uri.ToString);
end;

procedure TDm.SetupAuthOffice;
begin
  OAuth2Authenticator.AuthorizationEndpoint := 'https://login.microsoftonline.com/common/oauth2/v2.0/authorize';
  OAuth2Authenticator.AccessTokenEndpoint := 'https://login.microsoftonline.com/common/oauth2/v2.0/token';
  OAuth2Authenticator.RedirectionEndpoint := REDIRECT_URL;
  OAuth2Authenticator.Scope := 'https://outlook.office.com/IMAP.AccessAsUser.All https://outlook.office.com/POP.AccessAsUser.All https://outlook.office.com/SMTP.Send offline_access';
  OAuth2Authenticator.ClientID := OFFICE_CLIENTID;
  OAuth2Authenticator.ClientSecret := OFFICE_CLIENTSECRET;
  RESTClient.Authenticator := OAuth2Authenticator;
end;

procedure TDm.ChangeRefreshTokenToAccessToken;
begin
  OAuth2Authenticator.RefreshToken := MainForm.RefreshToken;
  ChangeRefreshTokenToAccesToken;

  MainForm.UniMemo.Lines.Add('New Access Token from Refresh Token');
  MainForm.UniMemo.Lines.Add(OAuth2Authenticator.AccessToken);
  MainForm.UniMemo.Lines.Add('');
end;

procedure TDm.ChangeRefreshTokenToAccesToken;
var
  LClient: TRestClient;
  LRequest: TRESTRequest;
  LToken: string;
  LIntValue: int64;
  AuthData : String;
begin
  LClient := TRestClient.Create(OAuth2Authenticator.AccessTokenEndpoint);
  try
    LRequest := TRESTRequest.Create(LClient);
    LRequest.Method := TRESTRequestMethod.rmPOST;

    LRequest.AddAuthParameter('refresh_token', OAuth2Authenticator.RefreshToken, TRESTRequestParameterKind.pkGETorPOST);
    LRequest.AddAuthParameter('grant_type', 'refresh_token', TRESTRequestParameterKind.pkGETorPOST);

    AuthData := 'Basic ' + TNetEncoding.Base64.Encode(OAuth2Authenticator.ClientID + ':' + OAuth2Authenticator.ClientSecret);
    AuthData := AuthData.Replace(#10,'').Replace(#13,'');
    LRequest.AddAuthParameter('Authorization', AuthData, TRESTRequestParameterKind.pkHTTPHEADER,[TRESTRequestParameterOption.poDoNotEncode]);

    LRequest.Execute;

    if LRequest.Response.GetSimpleValue('access_token', LToken) then
      OAuth2Authenticator.AccessToken := LToken;
    if LRequest.Response.GetSimpleValue('refresh_token', LToken) then
      OAuth2Authenticator.RefreshToken := LToken;

    if LRequest.Response.GetSimpleValue('token_type', LToken) then
      OAuth2Authenticator.TokenType := OAuth2TokenTypeFromString(LToken);

    if LRequest.Response.GetSimpleValue('expires_in', LToken) then
    begin
      LIntValue := StrToIntdef(LToken, -1);
      if (LIntValue > -1) then
        OAuth2Authenticator.AccessTokenExpiry := IncSecond(Now, LIntValue)
      else
        OAuth2Authenticator.AccessTokenExpiry := 0.0;
    end;

    if (OAuth2Authenticator.AccessToken <> '') then
      OAuth2Authenticator.AuthCode := '';
  finally
    LClient.DisposeOf;
  end;
end;

procedure TDm.ChangeCodeToAccesToken;
begin
  dm.OAuth2Authenticator.AuthCode := MainForm.authCode;
  dm.OAuth2Authenticator.ChangeAuthCodeToAccesToken;
  MainForm.refreshToken := OAuth2Authenticator.RefreshToken;
  MainForm.UniMemo.Lines.Add('Access Token: ' + OAuth2Authenticator.AccessToken);
  MainForm.UniMemo.Lines.Add('');
  MainForm.UniMemo.Lines.Add('Access Token Expiry: ' + DateTimeToStr(OAuth2Authenticator.AccessTokenExpiry));
  MainForm.UniMemo.Lines.Add('');
  MainForm.UniMemo.Lines.Add('Refresh Token: ' + OAuth2Authenticator.RefreshToken);
  MainForm.UniMemo.Lines.Add('');
  MainForm.FIniSettings.WriteString('Authentication', 'RefreshToken', OAuth2Authenticator.RefreshToken);
end;

procedure TDm.SendEmailOffice;
var
  xoauthSASL : TIdSASLListEntry;
begin
  OAuth2Authenticator.RefreshToken := MainForm.FIniSettings.ReadString('Authentication', 'RefreshToken', '');

  IdSMTP.AuthType := satNone;
  IdSMTP.Host := 'smtp-mail.outlook.com';
  IdSMTP.UseTLS := utUseExplicitTLS;
  IdSMTP.Port := 587;
  IdSSLIOHandlerSocketOpenSSL.SSLOptions.SSLVersions := [sslvTLSv1_2];

  OAuth2Authenticator.ClientID := OFFICE_CLIENTID;
  OAuth2Authenticator.ClientSecret := OFFICE_CLIENTSECRET;

  if OAuth2Authenticator.AccessTokenExpiry < now then
  begin
    ChangeRefreshTokenToAccesToken;
    MainForm.FIniSettings.WriteString('Authentication', 'RefreshToken', OAuth2Authenticator.RefreshToken);
  end;

  MainForm.UniMemo.Lines.Add('refresh_token=' + OAuth2Authenticator.RefreshToken);
  MainForm.UniMemo.Lines.Add('');
  MainForm.UniMemo.Lines.Add('access_token=' + OAuth2Authenticator.AccessToken);
  MainForm.UniMemo.Lines.Add('');

  if OAuth2Authenticator.AccessToken.Length = 0 then
  begin
    MainForm.UniMemo.Lines.Add('Failed to authenticate properly');
    Exit;
  end;

  xoauthSASL := IdSMTP.SASLMechanisms.Add;
  xoauthSASL.SASL := TIdSASLXOAuth.Create(nil);
  TIdSASLXOAuth(xoauthSASL.SASL).Token := OAuth2Authenticator.AccessToken;
  TIdSASLXOAuth(xoauthSASL.SASL).User := MainForm.edtMicrosoftAccount.Text;

  IdSMTP.Connect;
  IdSMTP.AuthType := satSASL;
  IdSMTP.Authenticate;
  try
    IdMessage.From.Address := MainForm.edtMicrosoftAccount.Text;
    IdMessage.From.Name := 'Test';
    IdMessage.ReplyTo.EMailAddresses := IdMessage.From.Address;
    IdMessage.Recipients.Add.Text := MainForm.edtSendTo.Text;
    IdMessage.Subject := 'Test email from Office 365';
    IdMessage.Body.Add('Notification email from UniGUI Application');
    IdSMTP.Send(dm.IdMessage);
    MainForm.UniMemo.Lines.Add('Message sent');
  finally
    IdSMTP.Disconnect;
  end;
end;

function Dm: TDm;
begin
  Result := TDm(UniMainModule.GetModuleInstance(TDm));
end;

initialization
  RegisterModuleClass(TDm);

end.

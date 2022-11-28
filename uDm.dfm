object Dm: TDm
  OldCreateOrder = False
  Height = 208
  Width = 470
  object RESTResponse: TRESTResponse
    Left = 259
    Top = 48
  end
  object RESTRequest: TRESTRequest
    Client = RESTClient
    Params = <>
    Response = RESTResponse
    SynchronizedEvents = False
    Left = 152
    Top = 48
  end
  object RESTClient: TRESTClient
    Authenticator = OAuth2Authenticator
    Params = <>
    Left = 48
    Top = 48
  end
  object OAuth2Authenticator: TOAuth2Authenticator
    TokenType = ttBEARER
    Left = 368
    Top = 48
  end
  object IdSMTP: TIdSMTP
    IOHandler = IdSSLIOHandlerSocketOpenSSL
    SASLMechanisms = <>
    Left = 48
    Top = 128
  end
  object IdSSLIOHandlerSocketOpenSSL: TIdSSLIOHandlerSocketOpenSSL
    Destination = ':25'
    MaxLineAction = maException
    Port = 25
    DefaultPort = 0
    SSLOptions.Mode = sslmUnassigned
    SSLOptions.VerifyMode = []
    SSLOptions.VerifyDepth = 0
    Left = 168
    Top = 128
  end
  object IdMessage: TIdMessage
    AttachmentEncoding = 'UUE'
    BccList = <>
    CCList = <>
    Encoding = meDefault
    FromList = <
      item
      end>
    Recipients = <>
    ReplyTo = <>
    ConvertPreamble = True
    Left = 296
    Top = 128
  end
end

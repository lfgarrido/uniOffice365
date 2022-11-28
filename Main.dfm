object MainForm: TMainForm
  Left = 0
  Top = 0
  ClientHeight = 638
  ClientWidth = 785
  Caption = 'MainForm'
  OnShow = UniFormShow
  OldCreateOrder = False
  MonitoredKeys.Keys = <>
  OnCreate = UniFormCreate
  DesignSize = (
    785
    638)
  PixelsPerInch = 96
  TextHeight = 13
  object GroupOffice: TUniGroupBox
    Left = 2
    Top = 8
    Width = 775
    Height = 82
    Hint = ''
    Caption = 'Office 365'
    TabOrder = 0
    object btnLoginOffice: TUniButton
      Left = 10
      Top = 40
      Width = 75
      Height = 25
      Hint = ''
      Caption = 'Login'
      TabOrder = 1
      OnClick = btnLoginOfficeClick
    end
    object btnSendEmailIndy: TUniButton
      Left = 623
      Top = 40
      Width = 124
      Height = 25
      Hint = ''
      Caption = 'Send Email Indy'
      TabOrder = 2
      OnClick = btnSendEmailIndyClick
    end
    object edtSendTo: TUniEdit
      Left = 376
      Top = 41
      Width = 225
      Hint = ''
      Text = 'some_address_to_test@gmail.com'
      TabOrder = 3
    end
    object edtMicrosoftAccount: TUniEdit
      Left = 118
      Top = 41
      Width = 217
      Hint = ''
      Text = 'your_office_365_mail@microsoft.com'
      TabOrder = 4
    end
    object lblMicrosoftAccount: TUniLabel
      Left = 118
      Top = 22
      Width = 86
      Height = 13
      Hint = ''
      Caption = 'Microsoft Account'
      ParentColor = False
      Color = clBtnFace
      TabOrder = 5
    end
    object lblSendTo: TUniLabel
      Left = 379
      Top = 22
      Width = 39
      Height = 13
      Hint = ''
      Caption = 'Send To'
      ParentColor = False
      Color = clBtnFace
      TabOrder = 6
    end
  end
  object UniMemo: TUniMemo
    Left = 2
    Top = 96
    Width = 775
    Height = 534
    Hint = ''
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 1
  end
end

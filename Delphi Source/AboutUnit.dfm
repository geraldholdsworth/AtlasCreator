object AboutForm: TAboutForm
  Left = 0
  Top = 0
  BorderIcons = []
  BorderStyle = bsNone
  Caption = 'About'
  ClientHeight = 131
  ClientWidth = 606
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 604
    Height = 130
    TabOrder = 0
    object Label2: TLabel
      Left = 0
      Top = 97
      Width = 604
      Height = 24
      Cursor = crHandPoint
      Alignment = taCenter
      AutoSize = False
      Caption = 'www.geraldholdsworth.co.uk'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      OnClick = Label2Click
    end
    object Label1: TLabel
      Left = 0
      Top = 65
      Width = 604
      Height = 32
      Alignment = taCenter
      AutoSize = False
      Caption = 'written by and '#169' Gerald J Holdsworth'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -24
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      OnClick = appversionClick
    end
    object appversion: TLabel
      Left = 0
      Top = 41
      Width = 604
      Height = 24
      Alignment = taCenter
      AutoSize = False
      Caption = 'apptitle'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      OnClick = appversionClick
    end
    object apptitle: TLabel
      Left = 0
      Top = 0
      Width = 604
      Height = 41
      Alignment = taCenter
      AutoSize = False
      Caption = 'apptitle'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -35
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      OnClick = appversionClick
    end
  end
end
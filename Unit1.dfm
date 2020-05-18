object Form1: TForm1
  Left = 427
  Top = 336
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = #1054#1075#1088#1072#1085#1080#1095#1080#1090#1077#1083#1100' '#1084#1099#1096#1080
  ClientHeight = 83
  ClientWidth = 338
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 64
    Top = 48
    Width = 32
    Height = 13
    Caption = 'Label1'
  end
  object BitBtn1: TBitBtn
    Left = 261
    Top = 56
    Width = 75
    Height = 25
    TabOrder = 0
    OnClick = BitBtn1Click
    Kind = bkOK
  end
  object PopupMenu1: TPopupMenu
    object N6: TMenuItem
      Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1080
      OnClick = N6Click
    end
    object N7: TMenuItem
      Caption = '-'
    end
    object N5: TMenuItem
      Caption = #1055#1088#1086#1079#1088#1072#1095#1085#1086#1089#1090#1100
    end
    object N2: TMenuItem
      Caption = #1055#1086#1074#1077#1088#1093' '#1086#1082#1086#1085
    end
    object N4: TMenuItem
      Caption = '-'
    end
    object N1: TMenuItem
      Caption = #1042#1082#1083#1102#1095#1080#1090#1100
      OnClick = N1Click
    end
    object N3: TMenuItem
      Caption = #1042#1099#1093#1086#1076
      OnClick = N3Click
    end
  end
end

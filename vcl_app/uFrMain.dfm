object FrMain: TFrMain
  Left = 0
  Top = 0
  BorderStyle = bsSingle
  Caption = 'Framework de Notifica'#231#245'es'
  ClientHeight = 442
  ClientWidth = 628
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poDesktopCenter
  TextHeight = 15
  object labFrequencia: TLabel
    Left = 24
    Top = 155
    Width = 61
    Height = 15
    Caption = 'Frequ'#234'ncia:'
  end
  object clbTipoNotificacao: TCheckListBox
    Left = 24
    Top = 16
    Width = 577
    Height = 130
    ItemHeight = 17
    Items.Strings = (
      'E-Mail'
      'Notifica'#231#245'es do Sistema'
      'SMS')
    TabOrder = 0
  end
  object cbbFrequencia: TComboBox
    Left = 91
    Top = 152
    Width = 174
    Height = 23
    Style = csDropDownList
    TabOrder = 1
    Items.Strings = (
      'Di'#225'ria'
      'Semanal'
      'Mensal')
  end
  object btnTeste: TButton
    Left = 24
    Top = 181
    Width = 241
    Height = 49
    Caption = 'Testar Notifica'#231#227'o'
    TabOrder = 2
    OnClick = btnTesteClick
  end
  object memLogs: TMemo
    Left = 24
    Top = 236
    Width = 577
    Height = 189
    TabOrder = 3
  end
end

object FrMain: TFrMain
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
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
    ItemHeight = 15
    Items.Strings = (
      'E-Mail'
      'Notifica'#231#245'es do Sistema'
      'SMS')
    TabOrder = 0
    OnClickCheck = UpdateParams
  end
  object cbbFrequencia: TComboBox
    Left = 91
    Top = 152
    Width = 174
    Height = 23
    Style = csDropDownList
    ItemIndex = 0
    TabOrder = 1
    Text = 'Di'#225'ria'
    OnChange = UpdateParams
    Items.Strings = (
      'Di'#225'ria'
      'Semanal'
      'Mensal')
  end
  object btnStart: TButton
    Left = 24
    Top = 181
    Width = 241
    Height = 49
    Caption = 'Iniciar'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = 20
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
    OnClick = btnStartClick
  end
  object memLogs: TMemo
    Left = 24
    Top = 236
    Width = 577
    Height = 189
    ReadOnly = True
    TabOrder = 4
  end
  object btnStop: TButton
    Left = 360
    Top = 181
    Width = 241
    Height = 49
    Caption = 'Parar'
    Enabled = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = 20
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    TabOrder = 3
    OnClick = btnStopClick
  end
end

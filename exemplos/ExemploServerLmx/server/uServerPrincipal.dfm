object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 378
  ClientWidth = 713
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 0
    Top = 193
    Width = 713
    Height = 3
    Cursor = crVSplit
    Align = alTop
    ExplicitLeft = -95
    ExplicitWidth = 808
  end
  object pgcServidor: TPageControl
    Left = 0
    Top = 0
    Width = 713
    Height = 193
    ActivePage = tbsDadosServer
    Align = alTop
    TabOrder = 0
    object tbsDadosServer: TTabSheet
      Caption = 'Config'
      object lblStatusServidor: TLabel
        Left = 498
        Top = 30
        Width = 192
        Height = 23
        Caption = 'Servidor Desconectado'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -19
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object Label1: TLabel
        Left = 12
        Top = 3
        Width = 50
        Height = 13
        Caption = 'Porta Http'
      end
      object lblServerName: TLabel
        Left = 15
        Top = 61
        Width = 109
        Height = 23
        Caption = 'Server Name'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -19
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object Label2: TLabel
        Left = 498
        Top = 11
        Width = 62
        Height = 13
        Caption = 'Server Name'
      end
      object lblVersaoAtual: TLabel
        Left = 15
        Top = 90
        Width = 75
        Height = 23
        Caption = 'Vers'#227'o : '
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -19
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object Label3: TLabel
        Left = 96
        Top = 3
        Width = 55
        Height = 13
        Caption = 'Porta Https'
      end
      object btnAtivarServidor: TBitBtn
        Left = 190
        Top = 20
        Width = 145
        Height = 34
        Caption = 'Ativar Servidor'
        TabOrder = 0
        OnClick = btnAtivarServidorClick
      end
      object edtPortaServer: TSpinEdit
        Left = 12
        Top = 22
        Width = 78
        Height = 33
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -19
        Font.Name = 'Tahoma'
        Font.Style = []
        MaxValue = 0
        MinValue = 0
        ParentFont = False
        TabOrder = 1
        Value = 8500
      end
      object ctrlHabilitarLog: TCheckBox
        Left = 341
        Top = 47
        Width = 78
        Height = 17
        Caption = 'Habilitar Log'
        Checked = True
        State = cbChecked
        TabOrder = 2
      end
      object BitBtn1: TBitBtn
        Left = 15
        Top = 119
        Width = 226
        Height = 25
        Caption = 'Limpar Logs'
        TabOrder = 3
      end
      object chkLogSQL: TCheckBox
        Left = 341
        Top = 67
        Width = 106
        Height = 17
        Caption = 'Habilitar Log SQL'
        Checked = True
        State = cbChecked
        TabOrder = 4
      end
      object chkLogErros: TCheckBox
        Left = 341
        Top = 88
        Width = 106
        Height = 17
        Caption = 'Habilitar Log Erros'
        Checked = True
        State = cbChecked
        TabOrder = 5
      end
      object ctrlSalvarEmArquivo: TCheckBox
        Left = 341
        Top = 28
        Width = 106
        Height = 17
        Caption = 'Salvar Em Arquivo'
        Checked = True
        State = cbChecked
        TabOrder = 6
      end
      object edtPortaHttps: TSpinEdit
        Left = 96
        Top = 22
        Width = 78
        Height = 33
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -19
        Font.Name = 'Tahoma'
        Font.Style = []
        MaxValue = 0
        MinValue = 0
        ParentFont = False
        TabOrder = 7
        Value = 8501
      end
    end
  end
  object memComandos: TMemo
    Left = 0
    Top = 196
    Width = 713
    Height = 182
    Align = alClient
    ScrollBars = ssVertical
    TabOrder = 1
  end
end

object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 507
  ClientWidth = 744
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Menu = menu
  Position = poDesktopCenter
  WindowState = wsMaximized
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 15
  object Panel1: TPanel
    Left = 0
    Top = 466
    Width = 744
    Height = 41
    Align = alBottom
    TabOrder = 0
    ExplicitTop = 457
    ExplicitWidth = 738
    object edTypeMagazine: TComboBox
      Left = 8
      Top = 6
      Width = 145
      Height = 23
      Style = csDropDownList
      TabOrder = 0
      OnChange = edTypeMagazineChange
    end
  end
  object pnIndex: TSplitView
    Left = 544
    Top = 0
    Width = 200
    Height = 466
    OpenedWidth = 200
    Placement = svpRight
    TabOrder = 1
    Visible = False
    ExplicitLeft = 538
    ExplicitHeight = 457
  end
  object http: TIdHTTP
    IOHandler = IdSSLIOHandlerSocketOpenSSL1
    ProxyParams.BasicAuthentication = False
    ProxyParams.ProxyPort = 0
    Request.ContentLength = -1
    Request.ContentRangeEnd = -1
    Request.ContentRangeStart = -1
    Request.ContentRangeInstanceLength = -1
    Request.Accept = 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8'
    Request.BasicAuthentication = False
    Request.UserAgent = 'Mozilla/3.0 (compatible; Indy Library)'
    Request.Ranges.Units = 'bytes'
    Request.Ranges = <>
    HTTPOptions = [hoForceEncodeParams]
    Left = 424
    Top = 200
  end
  object IdSSLIOHandlerSocketOpenSSL1: TIdSSLIOHandlerSocketOpenSSL
    MaxLineAction = maException
    Port = 0
    DefaultPort = 0
    SSLOptions.Method = sslvSSLv23
    SSLOptions.SSLVersions = [sslvSSLv2, sslvSSLv3, sslvTLSv1, sslvTLSv1_1, sslvTLSv1_2]
    SSLOptions.Mode = sslmUnassigned
    SSLOptions.VerifyMode = []
    SSLOptions.VerifyDepth = 0
    Left = 504
    Top = 216
  end
  object SQLConnection1: TSQLConnection
    ConnectionName = 'c:\mydb'
    DriverName = 'Sqlite'
    Params.Strings = (
      'DriverUnit=Data.DbxSqlite'
      
        'DriverPackageLoader=TDBXSqliteDriverLoader,DBXSqliteDriver280.bp' +
        'l'
      
        'MetaDataPackageLoader=TDBXSqliteMetaDataCommandFactory,DbxSqlite' +
        'Driver280.bpl'
      'FailIfMissing=True'
      'Database=')
    Left = 936
    Top = 296
  end
  object SimpleDataSet1: TSimpleDataSet
    Aggregates = <>
    DataSet.MaxBlobSize = -1
    DataSet.Params = <>
    Params = <>
    Left = 936
    Top = 352
    object SimpleDataSet1nuev: TStringField
      FieldName = 'nuev'
      Size = 10
    end
  end
  object DataSource1: TDataSource
    DataSet = SimpleDataSet1
    Left = 936
    Top = 248
  end
  object menu: TMainMenu
    Left = 112
    Top = 136
    object File1: TMenuItem
      Caption = 'File'
      object Magazine1: TMenuItem
        Caption = 'Magazine'
      end
      object N9: TMenuItem
        Caption = '-'
      end
      object aPreload1: TMenuItem
        Action = aPreload
      end
      object DownloadTape1: TMenuItem
        Action = aDownloadTape
      end
      object Magazine2: TMenuItem
        Caption = '-'
      end
      object File2: TMenuItem
        Action = aPrintOriginal
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object N2: TMenuItem
        Action = aExit
      end
    end
    object WordOfSpectrum2: TMenuItem
      Caption = 'Edit'
      object MetaData1: TMenuItem
        Action = aMetaData
      end
      object N3: TMenuItem
        Caption = '-'
      end
      object GotoNumber1: TMenuItem
        Action = aGotoNumber
      end
      object Priornumber1: TMenuItem
        Action = aNumberPrior
        Caption = 'Number prior'
      end
      object N6: TMenuItem
        Action = aNumberNext
        Caption = 'Number next'
      end
      object N5: TMenuItem
        Caption = '-'
      end
      object PriorPage1: TMenuItem
        Action = aPagePrior
        Caption = 'Page prior'
      end
      object N4: TMenuItem
        Action = aPageNext
        Caption = 'Page next'
      end
      object N7: TMenuItem
        Caption = '-'
      end
      object N8: TMenuItem
        Action = aMark
        Caption = 'Mark'
      end
    end
    object View1: TMenuItem
      Caption = 'View'
      object MaximizeNormal1: TMenuItem
        Action = aMaximize
        ShortCut = 123
      end
      object N10: TMenuItem
        Caption = '-'
      end
      object Zoom1: TMenuItem
        Action = aZoomPlus
        Caption = 'Zoom +'
      end
      object Zoom2: TMenuItem
        Action = aZoomMinus
        Caption = 'Zoom -'
      end
      object Index2: TMenuItem
        Caption = '-'
      end
      object itViewIndex: TMenuItem
        AutoCheck = True
        Caption = 'Index'
        OnClick = itViewIndexClick
      end
    end
    object ools1: TMenuItem
      Caption = 'Tools'
      object ools2: TMenuItem
        Action = aGoEmulator
        Caption = 'Go to Emulator ZX-Spectrum'
      end
      object WordOfSpectrum1: TMenuItem
        Action = aGoWOS
        Caption = 'Go to World of Spectrum web'
      end
      object Calculator1: TMenuItem
        Action = aCalculator
        Caption = 'Calculator IPC'
      end
    end
    object Calculator2: TMenuItem
      Caption = 'Help'
    end
  end
  object ActionList: TActionList
    Left = 232
    Top = 144
    object aPrintOriginal: TAction
      Caption = 'Print original...'
      ShortCut = 16464
      OnExecute = aPrintOriginalExecute
    end
    object aExit: TAction
      Caption = 'Exit'
    end
    object aMetaData: TAction
      Caption = 'Info Metadata'
    end
    object aNumberPrior: TAction
      Caption = 'aNumberPrior'
      ShortCut = 49230
      OnExecute = aNumberPriorExecute
    end
    object aNumberNext: TAction
      Caption = 'aNumberNext'
      ShortCut = 49229
      OnExecute = aNumberNextExecute
    end
    object aPagePrior: TAction
      Caption = 'aPagePrior'
      ShortCut = 16462
      OnExecute = aPagePriorExecute
    end
    object aPageNext: TAction
      Caption = 'aPageNext'
      ShortCut = 16461
      OnExecute = aPageNextExecute
    end
    object aMark: TAction
      Caption = 'aMark'
      ShortCut = 16496
    end
    object aZoomPlus: TAction
      Caption = 'aZoomPlus'
      ShortCut = 16496
    end
    object aZoomMinus: TAction
      Caption = 'aZoomMinus'
    end
    object aGoEmulator: TAction
      Caption = 'aGoEmulator'
      OnExecute = aGoEmulatorExecute
    end
    object aGoWOS: TAction
      Caption = 'aGoWOS'
      OnExecute = aGoWOSExecute
    end
    object aCalculator: TAction
      Caption = 'aCalculator'
      OnExecute = aCalculatorExecute
    end
    object aPreload: TAction
      Caption = 'Preload maganize'
      OnExecute = aPreloadExecute
    end
    object aDownloadTape: TAction
      Caption = 'Download Tape'
      OnExecute = aDownloadTapeExecute
    end
    object aGotoNumber: TAction
      Caption = 'Go to Number...'
      ShortCut = 16454
      OnExecute = aGotoNumberExecute
    end
    object aMaximize: TAction
      Caption = 'Maximize/Normal'
      OnExecute = aMaximizeExecute
    end
  end
end

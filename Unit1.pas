unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, JPEG, IdHTTP, ShellAPI,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdIOHandler, inifiles, System.Generics.Collections,
  IdIOHandlerSocket, IdIOHandlerStack, IdSSL, IdSSLOpenSSL, Vcl.NumberBox, magazine.Reader, magazine.Index,
  Data.DbxSqlite, Data.DB, Vcl.Mask, Vcl.DBCtrls, Datasnap.DBClient, SimpleDS,
  printers,
  Data.SqlExpr, Vcl.Menus, System.Actions, Vcl.ActnList;

const
  MZ_MICROHOBBY = 0;
  TYPE_MAGAZINE: array [0 .. 3, 0 .. 1] of string = (('Microhobby', 'MH'), ('MicroHobby Espcial', 'MHES'), ('Revista ZX', 'ZX'), ('Input Sinclair', 'INPUT'));

type
  TMHBookMark = class
  public
    numero, pagina: integer;
    nota: string;
  end;

  TForm1 = class(TForm)
    http: TIdHTTP;
    IdSSLIOHandlerSocketOpenSSL1: TIdSSLIOHandlerSocketOpenSSL;
    Panel1: TPanel;
    edTypeMagazine: TComboBox;
    Splitter1: TSplitter;
    pnIndex: TPanel;
    SQLConnection1: TSQLConnection;
    SimpleDataSet1: TSimpleDataSet;
    SimpleDataSet1nuev: TStringField;
    DataSource1: TDataSource;
    menu: TMainMenu;
    File1: TMenuItem;
    File2: TMenuItem;
    N1: TMenuItem;
    N2: TMenuItem;
    ools1: TMenuItem;
    ools2: TMenuItem;
    WordOfSpectrum1: TMenuItem;
    WordOfSpectrum2: TMenuItem;
    MetaData1: TMenuItem;
    Calculator1: TMenuItem;
    Calculator2: TMenuItem;
    Magazine1: TMenuItem;
    Magazine2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    PriorPage1: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    Priornumber1: TMenuItem;
    N7: TMenuItem;
    N8: TMenuItem;
    View1: TMenuItem;
    Zoom1: TMenuItem;
    Zoom2: TMenuItem;
    ActionList: TActionList;
    aPrintOriginal: TAction;
    aExit: TAction;
    aMetaData: TAction;
    aNumberPrior: TAction;
    aNumberNext: TAction;
    aPagePrior: TAction;
    aPageNext: TAction;
    aMark: TAction;
    aZoomPlus: TAction;
    aZoomMinus: TAction;
    aGoEmulator: TAction;
    aGoWOS: TAction;
    aCalculator: TAction;
    aPreload: TAction;
    aDownloadTape: TAction;
    aPreload1: TMenuItem;
    DownloadTape1: TMenuItem;
    N9: TMenuItem;
    aGotoNumber: TAction;
    GotoNumber1: TMenuItem;
    aMaximize: TAction;
    N10: TMenuItem;
    MaximizeNormal1: TMenuItem;
    itViewIndex: TMenuItem;
    Index2: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Image10Click(Sender: TObject);
    procedure Image20Click(Sender: TObject);
    procedure aNumberPriorExecute(Sender: TObject);
    procedure aNumberNextExecute(Sender: TObject);
    procedure aPreloadExecute(Sender: TObject);
    procedure aGoEmulatorExecute(Sender: TObject);
    procedure aGoWOSExecute(Sender: TObject);
    procedure aCalculatorExecute(Sender: TObject);
    procedure aPrintOriginalExecute(Sender: TObject);
    procedure aDownloadTapeExecute(Sender: TObject);
    procedure edTypeMagazineChange(Sender: TObject);
    procedure aPagePriorExecute(Sender: TObject);
    procedure aPageNextExecute(Sender: TObject);
    procedure aMaximizeExecute(Sender: TObject);
    procedure aGotoNumberExecute(Sender: TObject);
    procedure itViewIndexClick(Sender: TObject);
  private
    fnumero: integer;
    busy: Boolean;
    mg: TmagazineReader;
    mi: TmagazineIndex;
    BookMarks: Tlist<TMHBookMark>;

    meta: record
      numero: string;
      date, datePublic: TdateTime;
      URL: string;
    end;

    function CargarImagenDesdeURL(const URL: string): string;
    procedure Cargar;
    procedure setNumero(const Value: integer);
    procedure nextPage;
    procedure priorPage;
    procedure selectRect(x, y: integer; link: TLink; var valid: Boolean);
    procedure saveLinks;
    procedure calculatorIPC;
    function getDirCache(numMagazine, numPagina: integer): string;
    function loadPage(numPagina: integer): string;
    function loadPageMagazine(numeroMagazine, numPagina: integer): string;
    function getURLMagazine(numMagazine, numPage: integer): string;
    procedure selectMagazine(numero: integer);
    procedure loadIndexMagazine(index: integer; var filename: string; var eof: Boolean);
  public
    pagina: integer;
    mainIni: Tinifile;
    property numero: integer read fnumero write setNumero;

  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.aCalculatorExecute(Sender: TObject);
begin
  calculatorIPC;
end;

procedure TForm1.aMaximizeExecute(Sender: TObject);
begin
  if WindowState = wsMaximized then
    self.WindowState := wsNormal
  else
    self.WindowState := wsMaximized;
end;

procedure TForm1.aDownloadTapeExecute(Sender: TObject);
var
  nCinta: integer;
  _url, _dir, cintaName: string;
  procedure DescargarZIP(const URL, RutaDestino: string);
  var
    ArchivoSalida: TFileStream;
  begin

    ArchivoSalida := TFileStream.Create(RutaDestino, fmCreate);
    try
      http.Get(URL, ArchivoSalida);
      showMessage('Cinta descargada');
    finally
      ArchivoSalida.Free;

    end;
  end;

begin
  nCinta := (trunc((numero - 1) / 4) * 4) + 1;
  cintaName := format('MicroHobbySemanal%d-%d.zip', [nCinta, nCinta + 3]);
  _url := 'https://microhobby.speccy.cz/mhforever/images-mh/cintas/grande/' + cintaName;
  _dir := extractfiledir(application.ExeName) + format('\cache\%0:s', [TYPE_MAGAZINE[edTypeMagazine.itemindex, 1]]);
  ForceDirectories(_dir);

  if not FileExists(_dir + '\' + cintaName) then
    DescargarZIP(_url, _dir + '\' + cintaName);

end;

procedure TForm1.aGoEmulatorExecute(Sender: TObject);
var
  emuExe: string;
begin
  with Tinifile.Create(extractfiledir(application.ExeName) + '\config.ini') do
  begin
    emuExe := readString('emulator', 'exe', '');
    if FileExists(emuExe) then
      ShellExecute(0, 'open', pchar(emuExe), nil, nil, SW_SHOWNORMAL)
    else
      writeString('emulator', 'exe', '');
    Free;
  end;
end;

procedure TForm1.aGotoNumberExecute(Sender: TObject);
var
  _number: string;
begin
  if not InputQuery('Number of magazine', 'Number', _number) then
    exit;

  numero := strtoint(_number);

end;

procedure TForm1.selectMagazine(numero: integer);
begin
  self.numero := numero;
end;

procedure TForm1.loadIndexMagazine(index: integer; var filename: string; var eof: Boolean);
begin
  filename := loadPageMagazine(index, 1);
end;

procedure TForm1.aGoWOSExecute(Sender: TObject);
begin
  ShellExecute(0, 'open', 'https://worldofspectrum.org/archive/software/games/sir-fred-made-in-spain', nil, nil, SW_SHOWNORMAL);
end;

procedure TForm1.aNumberNextExecute(Sender: TObject);
begin
  numero := numero + 1;
end;

procedure TForm1.aNumberPriorExecute(Sender: TObject);
begin
  numero := numero - 1;
end;

procedure TForm1.aPageNextExecute(Sender: TObject);
begin
  nextPage;
end;

procedure TForm1.aPagePriorExecute(Sender: TObject);
begin
  priorPage;
end;

procedure TForm1.aPreloadExecute(Sender: TObject);
var
  f: integer;
begin
  for f := 1 to 100 do
  begin
    pagina := f;
    Cargar;
  end;
end;

procedure TForm1.aPrintOriginalExecute(Sender: TObject);
var

  f: integer;
  JPEG: TJPEGImage;
  _filename1, _filename2: string;
  p: TPrintDialog;
begin

  p := TPrintDialog.Create(self);
  p.MinPage := 1;
  p.MaxPage := 999;
  p.FromPage := 1;
  p.ToPage := 36;

  p.Options := [poPrintToFile, poPageNums, poSelection, poWarning, poHelp, poDisablePrintToFile];
  
  try
    if not p.Execute then
      abort;

    JPEG := TJPEGImage.Create;

    printer.Orientation := TPrinterOrientation.poLandscape;
    printer.Title := format('%s-%d', [TYPE_MAGAZINE[edTypeMagazine.itemindex, 0], numero]);
    printer.BeginDoc;
    for f := 1 to (p.ToPage div 2) - 1 do
    begin
      caption := format('Process page %d of %d', [f * 2, p.ToPage]);
      if (f mod 2) = 0 then
      begin
        _filename1 := loadPage(f);
        _filename2 := loadPage(p.ToPage + 1 - f);
      end
      else
      begin
        _filename1 := loadPage(p.ToPage + 1 - f);
        _filename2 := loadPage(f);
      end;

      if _filename1 <> '' then
      begin

        JPEG.loadfromfile(_filename1);
        printer.Canvas.StretchDraw(rect(0, 0, printer.PageWidth div 2, printer.PageHeight), JPEG);
      end;

      if _filename2 <> '' then
      begin
        JPEG.loadfromfile(_filename2);
        printer.Canvas.StretchDraw(rect(printer.PageWidth div 2, 0, printer.PageWidth, printer.PageHeight), JPEG);
      end;
      printer.NewPage;
    end;
    printer.endDoc;
    JPEG.Free;
  finally
    p.Free;

  end;
end;

function TForm1.getURLMagazine(numMagazine: integer; numPage: integer): string;
begin
  case edTypeMagazine.itemindex of
    0:
      begin
        result := format('https://microhobby.speccy.cz/mhf/%0:.3d/MH%0:.3d_%1:.2d.jpg', [numMagazine, numPage]);
      end;
    1:
      result := format('https://microhobby.speccy.cz/mhf/MHEs%0:.1d/mhes%0:.1d_%1:.2d.jpg', [numMagazine, numPage]);
    2:
      result := format('https://microhobby.speccy.cz/zx/zx%0:.2d/%0:.2d-%1:.2d.JPG', [numMagazine, numPage]);
    3:
      result := format('http://www.robertp.net/Input/%0:.2d/Imatges/%1:.2d.jpg', [numMagazine, numPage]);
  end;

end;

procedure TForm1.Cargar;
var
  _url: string;
  _file: string;

begin
  if busy then
    exit;
  busy := true;
  _url := getURLMagazine(numero, pagina);
  try
    if (pagina mod 2) = 0 then
    begin
      _file := CargarImagenDesdeURL(_url);
      mg.pageLeft(_file);
    end
    else
    begin
      _file := CargarImagenDesdeURL(_url);
      mg.pageRight(_file);
    end;
  finally
    busy := false;
  end;

end;

procedure TForm1.calculatorIPC;
const
  Inflacion: array [1982 .. 2024] of Double = (14.0, 12.2, 11.3, 8.3, 8.8, 4.6, 5.8, 6.9, 6.5, 5.9, 5.9, 4.6, 4.7, 4.3, 3.6, 2.0, 1.4, 2.9, 4.0, 2.7, 3.6, 2.6, 3.2, 3.4, 3.5, 4.2, 1.4, -0.3, 3.0, 2.4, 2.9, 1.4, -1.0, -0.5, 1.6, 1.1, 1.2, 0.8, -0.5,
    6.5, 8.4, 3.1, 3.0);
var
  valor: string;
  ptas: Double;
  inflaAcu: Double;
  anyo, mes, dia: Word;

  function getFactorInflaA(DesdeAnio: integer; HastaAnio: integer = 2024): Double;
  var
    i: integer;
    Factor: Double;
  begin
    Factor := 1.0;

    for i := DesdeAnio to HastaAnio do
    begin
      Factor := Factor * (1.0 + Inflacion[i] / 100.0);
    end;

    result := Factor;
  end;

begin
  if not InputQuery('Calculadora inflaccion', 'valor inicial en ptas', valor) then
    exit;
  decodeDate(meta.datePublic, anyo, mes, dia);
  ptas := strtoFloat(valor);
  inflaAcu := getFactorInflaA(anyo);

  showMessage(format('%.0n ptas en %d con una inflaccion acumulada de %2.n, es de %.2n€ en 2024', [ptas, anyo, inflaAcu, ptas * inflaAcu / 166.386]));

end;

function TForm1.CargarImagenDesdeURL(const URL: string): string;
var

  rectCoor: String;

  i: integer;
  lmetas: Tstringlist;
  linkStr: string;
  link: TLink;

  function getFechaDefault(index: integer): TdateTime;
  begin
    try

      case index of
        MZ_MICROHOBBY:
          begin
            if numero = 218 then // nunero especial
              result := (encodedate(2007, 4, 1))
            else if numero >= 212 then // epoca III - el 211 fue doble
              result := (encodedate(1989 + (numero - 181) div 12, ((numero - 181) mod 12) + 1, 1))
            else if numero >= 202 then // epoca III - el 201 fue doble
              result := (encodedate(1989 + (numero - 182) div 12, ((numero - 182) mod 12) + 1, 1))
            else if numero >= 191 then // epoca III - el 190 fue doble
              result := (encodedate(1989 + (numero - 183) div 12, ((numero - 183) mod 12) + 1, 1))
            else if numero >= 184 then // epoca III - año VI -1989
              result := (encodedate(1989 + (numero - 184) div 12, ((numero - 184) mod 12) + 1, 1))
            else if numero >= 161 then // epoca II  - año V 1988
              result := (encodedate(1988, 1, 16) + (numero - 161) * 15)
            else // epoca I
              result := (encodedate(1984, 11, 5) + (numero - 1) * 7)

          end;
        1:
          result := (encodedate(1984, 11, 5) + (numero - 1) * 7);
        2:
          result := (encodedate(1983 + ((numero + 10) div 12), ((numero + 10) mod 12) + 1, 1));
        3:
          result := (encodedate(1985 + ((numero + 9 - 1) div 13), (numero + 9 - 1) mod 13, 1));
      end;
    except
      result := 0;
    end;

  end;

  function getEdadAcademica(fechPublicacion: TdateTime): string;
  const
    CURSO: array [11 .. 17] of string = ('6º EGB', '7º EGB', '8º EGB', '1º BUP', '2º BUP', '3º BUP', 'COU');
  var
    edad: integer;
    y, mes, d: Word;
    cursoStr: string;
  begin
    edad := trunc((fechPublicacion - encodedate(1970, 1, 1)) / 365);
    decodeDate(fechPublicacion, y, mes, d);

    try

      if mes < 7 then
        cursoStr := CURSO[edad - 1]
      else if mes < 9 then
        cursoStr := CURSO[edad - 1] + ' verano ' + CURSO[edad]
      else
        cursoStr := CURSO[edad];

    except
      cursoStr := '';

    end;

    result := inttostr(edad) + ' años ' + cursoStr;
  end;

begin
  // caption := URL;

  // carga metainformacion
  meta.date := getFechaDefault(edTypeMagazine.itemindex);
  meta.datePublic := getFechaDefault(edTypeMagazine.itemindex);

  with Tinifile.Create(getDirCache(numero, pagina) + '\info.meta') do
  begin
    writeString('meta', 'dateStr', datetostr(meta.date));
    writeString('meta', 'datePublic', datetostr(meta.datePublic));

    writeString('page_' + inttostr(pagina), 'url', URL);
    writeString('page_' + inttostr(pagina), 'number', inttostr(pagina));

    lmetas := Tstringlist.Create;
    ReadSection('page_' + inttostr(pagina) + '_links', lmetas);
    for i := 0 to lmetas.count - 1 do
    begin

      rectCoor := readString(readString('page_' + inttostr(pagina) + '_links', lmetas[i], ''), 'rect', '');
      linkStr := readString(readString('page_' + inttostr(pagina) + '_links', lmetas[i], ''), 'link', '');

      link := TLink.Create(mg, rectCoor);
      link.link := linkStr;
      mg.links.add(link);

    end;

    Free;
  end;

  caption := format('%s Número %d,%d (%s, %s) han pasado %d años, yo tenia por aquel entonces %s', [TYPE_MAGAZINE[edTypeMagazine.itemindex, 0], numero, pagina, datetostr(meta.datePublic), formatDateTime('MMM/YY', meta.datePublic),
    trunc((now - meta.datePublic) / 365), getEdadAcademica(meta.datePublic)]);

  result := loadPage(pagina);
end;

procedure TForm1.edTypeMagazineChange(Sender: TObject);
begin

end;

{
  Intentara cargar la pagina de la cache, si no la tiene procedera con la descarga
  desde internet
}

function TForm1.getDirCache(numMagazine, numPagina: integer): string;
begin
  result := extractfiledir(application.ExeName) + format('\cache\%0:s\%1:.3d', [TYPE_MAGAZINE[edTypeMagazine.itemindex, 1], numMagazine]);
  ForceDirectories(result);
end;

function TForm1.loadPage(numPagina: integer): string;
begin
  result := loadPageMagazine(numero, numPagina);
end;

function TForm1.loadPageMagazine(numeroMagazine, numPagina: integer): string;
var
  Stream: TMemoryStream;

begin

  result := getDirCache(numeroMagazine, numPagina) + format('\pag_%0:.3d_%1:.2d.jpg', [numeroMagazine, numPagina]);

  Stream := TMemoryStream.Create;

  if not FileExists(result) then
  begin
    try
      http.Get(getURLMagazine(numeroMagazine, numPagina), Stream); // Descargar imagen desde la URL
      Stream.Position := 0; // Reiniciar posición del stream
      Stream.SaveToFile(result);
    except
      result := '';
    end;

  end;

  Stream.Free;

end;

procedure TForm1.selectRect(x, y: integer; link: TLink; var valid: Boolean);
var
  linkStr: string;
begin
  valid := InputQuery('Link', 'link', linkStr);
  link.link := linkStr;

end;

procedure TForm1.FormCreate(Sender: TObject);
var
  i: integer;
begin
  mi := TmagazineIndex.Create(pnIndex);
  mi.Align := alClient;
  mi.onSelectMagazine := selectMagazine;
  mi.onLoadIndexMagazine := loadIndexMagazine;

  mg := TmagazineReader.Create(self);
  mg.Align := alClient;

  mg.onNextPage := aPageNext.OnExecute;
  mg.onPriorPage := aPagePrior.OnExecute;
  mg.onSelectRect := selectRect;

  for i := Low(TYPE_MAGAZINE) to High(TYPE_MAGAZINE) do
    edTypeMagazine.Items.add(TYPE_MAGAZINE[i, 0]);

  edTypeMagazine.itemindex := 0;

  BookMarks := Tlist<TMHBookMark>.Create;

  mainIni := Tinifile.Create(extractfiledir(application.ExeName) + '\config.ini');
  numero := mainIni.readInteger('magazine', 'number', 1);
  // pagina := mainIni.readInteger('magazine', 'page', 1);
  // cargar;

end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  mainIni.writeInteger('magazine', 'number', 1);
  mainIni.writeInteger('magazine', 'page', pagina - 1);
  mainIni.Free;

  BookMarks.Free;
  mg.Free;
end;

procedure TForm1.priorPage;
begin
  saveLinks;
  mg.BeginTransaction(false);
  pagina := pagina - 3;
  Cargar;
  inc(pagina);
  Cargar;
  mg.roll;
end;

procedure TForm1.saveLinks;
var
  link: TLink;
  indice: string;
begin
  for link in mg.links do
  begin
    with Tinifile.Create(getDirCache(numero, pagina) + '\info.meta') do
    begin
      indice := 'page_' + inttostr(pagina) + '_' + link.name;
      writeString('page_' + inttostr(pagina) + '_links', link.name, indice);

      writeString(indice, 'link', link.link);
      writeString(indice, 'rect', link.rectStr);
    end;
  end;

  mg.links.Clear;
end;

procedure TForm1.nextPage;

begin

  saveLinks;

  mg.BeginTransaction(true);

  inc(pagina);
  Cargar;
  inc(pagina);
  Cargar;

  mg.roll;

end;

procedure TForm1.Image10Click(Sender: TObject);
begin
  priorPage;
end;

procedure TForm1.Image20Click(Sender: TObject);
begin
  nextPage;
end;

procedure TForm1.itViewIndexClick(Sender: TObject);
var
  JPEG: TJPEGImage;
  numMagazine: integer;
begin
  pnIndex.Visible := itViewIndex.Checked;
  if pnIndex.Visible then
    mi.prepaint;
end;

procedure TForm1.setNumero(const Value: integer);
begin

  mg.Clear;
  fnumero := Value;
  pagina := 1;
  Cargar;
  mg.prepaint;

  mi.index := numero;

end;

end.

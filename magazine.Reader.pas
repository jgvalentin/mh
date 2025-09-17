unit magazine.Reader;

interface

uses JPEG, System.StrUtils, Generics.Collections, Graphics, vcl.ExtCtrls, Classes, vcl.Controls, SysUtils, forms, System.Types, vcl.StdCtrls;

type
  TmagazineReader = class;

  TSelectR = record
    sel: boolean;
    point: Tpoint;
  end;

  TLink = class
    link: string;
    rect: Trect;
    name: string;
    color: Tcolor;
    function isLink(x, y: integer): boolean;
    function rectStr: string;
    constructor create(owner: TmagazineReader); overload;
    constructor create(owner: TmagazineReader; rectCoor: string); overload;
    constructor create(owner: TmagazineReader; pin, pfin: TSelectR); overload;
  end;

  TmagazineReader = class(TcustomPanel)
    lpages: Tlist<TJPEGImage>;
  private
    fnumero: integer;
    lbinfo: Tlabel;
    pini, pfin: TSelectR;
    fzoom: extended;
    zoom_dx, zoom_dy: integer;
    bitmap: Tbitmap;
    TR: integer;
    tr_left: boolean;
    fx: boolean;

    procedure setNumero(const Value: integer);

    procedure pageBlank(index: integer);
    procedure setZoom(const Value: extended);

  public
    onNextPage, onPriorPage: TNotifyEvent;
    onSelectRect: procedure(x, y: integer; link: TLink; var valid: boolean) of object;
    stepPageTime: extended;
    links: Tlist<TLink>;
    procedure Paint; override;
    procedure Resize; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; x, y: integer); override;
    function DoMouseWheelDown(Shift: TShiftState; MousePos: Tpoint): boolean; override;
    function DoMouseWheelUp(Shift: TShiftState; MousePos: Tpoint): boolean; override;
    procedure MouseMove(Shift: TShiftState; x, y: integer); override;
    procedure prepaint;
    procedure clear;
    procedure BeginTRansaction(left: boolean = true);
    procedure roll;
    procedure pageRight(pag: string);
    procedure pageLeft(pag: string);
    procedure ZoomIn;
    procedure ZoomOut;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property numero: integer read fnumero write setNumero;
    property zoom: extended read fzoom write setZoom;

  end;

implementation

{ TmagazineReader }

procedure TmagazineReader.clear;
var
  f: integer;
begin

  for f := 0 to 3 do
  begin
    pageBlank(f);
  end;
end;

constructor TmagazineReader.Create(AOwner: TComponent);
begin
  inherited;
  parent := TWinCOntrol(AOwner);
  links := Tlist<TLink>.create;
  lpages := Tlist<TJPEGImage>.create;
  lpages.Add(TJPEGImage.create);
  lpages.Add(TJPEGImage.create);
  lpages.Add(TJPEGImage.create);
  lpages.Add(TJPEGImage.create);
  bitmap := Tbitmap.create;

  stepPageTime := 1.7;
  fzoom := 1;
  lbinfo := Tlabel.create(self);
  lbinfo.parent := self;
end;

procedure TmagazineReader.MouseDown(Button: TMouseButton; Shift: TShiftState; x, y: integer);
var
  link: TLink;
  valid: boolean;
begin
  inherited;
  if (Button in [mbLeft]) then
  begin
    { TODO: Determinar si lo que se ha pulsado es un link e ir hace un onclick con el Tlink, se pued usar el isSelect the Tlink }

    if x > Width div 2 then
    begin
      if assigned(onNextPage) then
        onNextPage(self)
    end
    else
    begin
      if assigned(onPriorPage) then
        onPriorPage(self)
    end;

  end;

  if (Button in [mbRight]) then
  begin
    if pini.sel then
    begin
      pfin.point := point(x, y);

      link := TLink.create(self, pini, pfin);

      valid := true;
      if assigned(onSelectRect) then
        onSelectRect(x, y, link, valid);

      if valid then
        links.Add(link)
      else
        link.Free;

      pini.sel := false;

      prepaint;
    end
    else
    begin
      pini.point := point(x, y);
      pini.sel := true;
    end;
  end;

end;

procedure TmagazineReader.MouseMove(Shift: TShiftState; x, y: integer);
var
  link: TLink;
  loc: boolean;
  i: integer;
begin
  inherited;
  lbinfo.top := 0;
  lbinfo.left := 0;
  lbinfo.caption := format('%d,%d', [x, y]);

  // Localizar enlaces
  i := 0;
  loc := false;
  while not loc and (i < links.Count) do
  begin
    link := links[i];
    loc := link.isLink(x, y);
    inc(i);
  end;

  if loc then
    prepaint;

end;

destructor TmagazineReader.Destroy;
begin

  { TODO:Eliminar paginas }

  links.Free;
  lpages.Free;
  bitmap.Free;

  inherited;
end;

function TmagazineReader.DoMouseWheelDown(Shift: TShiftState; MousePos: Tpoint): boolean;
var p:Tpoint;
begin
  result  := inherited;
    p := ScreenToClient(point(mousePos.X,mousePos.Y));
  fzoom := fzoom * 1.1;

  zoom_dx := p.x;

  zoom_dy := p.y;
  prepaint;
end;

function TmagazineReader.DoMouseWheelUp(Shift: TShiftState; MousePos: Tpoint): boolean;
var p:Tpoint;
begin
  result := inherited;
    p := ScreenToClient(point(mousePos.X,mousePos.Y));
  fzoom := fzoom / 1.1;
  zoom_dx := MousePos.x;
  zoom_dy := MousePos.y;
  prepaint;

end;

procedure TmagazineReader.pageBlank(index: integer);
begin
  bitmap.Canvas.Pen.Style := psClear;
  bitmap.Canvas.Rectangle(0, 0, screen.Width, screen.Height);
  lpages[index].Assign(bitmap);

end;

procedure TmagazineReader.pageRight(pag: string);
begin
  if fileexists(pag) then
    lpages[1].LoadFromFile(pag)
  else
  begin
    pageBlank(1);

  end;

  // prepaint;
end;

procedure TmagazineReader.pageLeft(pag: string);
begin
  if fileexists(pag) then
    lpages[0].LoadFromFile(pag)
  else
  begin
    pageBlank(0);
  end;


  // prepaint;

end;

{ go to derecha=partimos de TR=1 hasta llegar a width,
  la pagina derecha se encoge y se superpone a la pagina i4, que es una copia de i1 (futura)

  cuando TR pasa de la mitad
}
procedure TmagazineReader.prepaint;
var
  link: TLink;
  _px, _py: integer;
  procedure go(i0, i1, i2, i3: integer);
  begin
    with bitmap do
    begin
      Canvas.StretchDraw(rect(0, 0, Width div 2, Height), lpages[i0]); // Hoja izquierda de fondo

      Canvas.StretchDraw(rect(Width div 2, 0, Width, Height), lpages[i3]); // Hoja derecha de fondo

      if (TR < Width div 2) then
      begin
        if TR < 0 then
          Canvas.StretchDraw(rect(Width div 2, 0, Width, Height), lpages[i1])
        else
          Canvas.StretchDraw(rect(Width div 2, 0, Width - TR, Height), lpages[i1]);
      end
      else
      begin // acaba de pasar la pagina cuando va a la derecha
        if TR > Width then
        begin
          Canvas.StretchDraw(rect(0, 0, (Width div 2), Height), lpages[i2]); // finalizo por exceso la pagina
          fzoom := 1;
        end
        else
          Canvas.StretchDraw(rect(Width - TR, 0, (Width div 2), Height), lpages[i2]);
      end;

    end;
  end;

begin
  bitmap.Canvas.Pen.Style := psClear;
  bitmap.Canvas.Brush.Style := bsSolid;
  bitmap.Canvas.Pen.color := clwhite;
  bitmap.Canvas.Rectangle(0, 0, Width, Height);
  if fx then
  begin

    if tr_left then // avanzamos una hoja
      go(2, 3, 0, 1)
    else
      go(0, 1, 2, 3);
  end
  else
  begin
    with bitmap do
    begin
      _px := round(-zoom_dx * zoom + zoom_dx);
      _py := round(-zoom_dy * zoom + zoom_dy);

      Canvas.StretchDraw(rect(_px, _py, round(_px + zoom * (Width div 2)), round(_py + zoom * Height)), lpages[0]);
      Canvas.StretchDraw(rect(_px + round(zoom * (Width div 2)), _py, _px + round(zoom * Width), _py + round(zoom * Height)), lpages[1]);
    end;
  end;

  for link in links do
  begin

    with bitmap do
    begin
      Canvas.Brush.Style := bsClear;
      Canvas.Pen.Style := psSolid;
      Canvas.Pen.color := link.color;
      Canvas.Rectangle(link.rect);
      Canvas.TextOut(link.rect.left, link.rect.top, link.link);
    end;
  end;

  Paint;
end;

procedure TmagazineReader.Paint;
begin
  inherited;

  Canvas.Draw(0, 0, bitmap);

end;

procedure TmagazineReader.Resize;
begin
  inherited;
  bitmap.SetSize(Width, Height);
  prepaint;
end;

procedure TmagazineReader.setNumero(const Value: integer);
begin
  fnumero := Value;

end;

procedure TmagazineReader.setZoom(const Value: extended);
begin
  fzoom := Value;
  prepaint;
end;

procedure TmagazineReader.ZoomIn;
begin
  zoom := zoom * 1.1;
end;

procedure TmagazineReader.ZoomOut;
begin
  zoom := zoom / 1.1;
end;

procedure TmagazineReader.BeginTRansaction(left: boolean = true);

begin
  fx := true;
  tr_left := left;
  lpages[2].Assign(lpages[0]);
  lpages[3].Assign(lpages[1]);
  if tr_left then
    TR := 0
  else
    TR := Width;
end;

procedure TmagazineReader.roll;
var

  paso: extended;
begin
  paso := 1;
  try
    while (TR <= Width) and (TR >= 0) do
    begin
      if tr_left then
        TR := round(TR + paso)
      else
        TR := round(TR - paso);
      paso := paso * stepPageTime;
      prepaint;
      // sleep(100);
    end;
    fx := false;
  finally
    // prepaint;
  end;

end;

{ TLink }

constructor TLink.create(owner: TmagazineReader; rectCoor: string);
var
  coors: Tarray<string>;
begin
  create(owner);
  coors := SplitString(rectCoor, ' ');

  rect.left := strToInt(coors[0]);
  rect.top := strToInt(coors[1]);
  rect.right := strToInt(coors[2]);
  rect.Bottom := strToInt(coors[3]);

end;

constructor TLink.create(owner: TmagazineReader; pin, pfin: TSelectR);
begin
  create(owner);
  rect.left := pin.point.x;
  rect.top := pin.point.y;
  rect.right := pfin.point.x;
  rect.Bottom := pfin.point.y;
end;

function TLink.isLink(x, y: integer): boolean;
begin
  result := (rect.left <= x) and (rect.right >= x) and (rect.top <= y) and (rect.Bottom >= y);
  if result then
    color := clred
  else
    color := clblack;

end;

constructor TLink.create(owner: TmagazineReader);
begin
  name := 'link' + inttostr(owner.links.Count);
end;

function TLink.rectStr: string;
begin
  result := format('%d %d %d %d', [rect.left, rect.top, rect.right, rect.Bottom]);
end;

end.

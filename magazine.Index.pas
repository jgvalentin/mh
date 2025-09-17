unit magazine.Index;

interface

uses JPEG, System.StrUtils, Generics.Collections, Graphics, vcl.ExtCtrls, Classes,
Math,
vcl.Controls, SysUtils, forms, System.Types, vcl.StdCtrls;

type
  TonSelectMagazine = procedure(numero: integer) of object;
  TonLoadIndexMagazine = procedure(Index: integer; var filename: string; var eof: boolean) of object;

  TmagazineIndex = class(TcustomPanel)

  private
    dragState: boolean;
    click: boolean;
    dragY, offsetY: integer;
    JPEG: TJPEGImage;
    bitmap: Tbitmap;
    //Altura por pagina
    pageHeight:integer;
    //Numero maximo de paginas que soporta
    numMaxPages:integer;
    //Numero de la primera revita
    findex: integer;
    procedure setIndex(const Value: integer);
  public
    onNextPage, onPriorPage: TNotifyEvent;

    onSelectMagazine: TonSelectMagazine;
    onLoadIndexMagazine: TonLoadIndexMagazine;
    procedure Paint; override;
    procedure Resize; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; x, y: integer); override;
    function DoMouseWheelDown(Shift: TShiftState; MousePos: Tpoint): boolean; override;
    function DoMouseWheelUp(Shift: TShiftState; MousePos: Tpoint): boolean; override;
    procedure MouseMove(Shift: TShiftState; x, y: integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; x, y: integer); override;

    procedure prepaint;
    procedure clear;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property index: integer read findex write setIndex;
  end;

implementation

{ TmagazineIndex }

procedure TmagazineIndex.clear;
begin

end;

constructor TmagazineIndex.Create(AOwner: TComponent);
begin
  inherited;
  parent := TWinCOntrol(AOwner);

  bitmap := Tbitmap.create;

  JPEG := TJPEGImage.create;
  index := 1;
end;

procedure TmagazineIndex.MouseDown(Button: TMouseButton; Shift: TShiftState; x, y: integer);
begin
  click := true;
  dragY := y-offsetY;
end;

procedure TmagazineIndex.MouseMove(Shift: TShiftState; x, y: integer);

begin
  if click then
  begin
    offsetY := (y - dragY);
    Paint;
    dragState := true;
  end;

end;

procedure TmagazineIndex.MouseUp(Button: TMouseButton; Shift: TShiftState; x, y: integer);
begin
  inherited;

  begin
    if dragState then
    begin
      findex := findex - trunc(offsetY / pageHeight);

      if offsetY>0 then   //Se ha bajado
      begin
      findex := findex-1;
         offsetY:=-(pageHeight-offsetY)
      end
         else
      offsetY := offsetY mod pageHeight;
      prepaint;
      dragState := false;

    end
    else
    begin

      if assigned(onSelectMagazine) then
      begin
//        index := trunc((y+offsetY)/ pageHeight) + index;
        onSelectMagazine(trunc((y-offsetY)/ pageHeight) + index);
      end;
    end;
  end;

  click := false;

end;

destructor TmagazineIndex.Destroy;
begin
  JPEG.free;
  bitmap.free;

  inherited;
end;

function TmagazineIndex.DoMouseWheelDown(Shift: TShiftState; MousePos: Tpoint): boolean;
begin
  inherited;
  index := index + 1;

end;

function TmagazineIndex.DoMouseWheelUp(Shift: TShiftState; MousePos: Tpoint): boolean;
begin
  inherited;
  index := index - 1;
end;

procedure TmagazineIndex.prepaint;
var

  posicionY: integer;
  filename: string;
  eof: boolean;
begin

  if not assigned(onLoadIndexMagazine) then
    exit;

  posicionY := 0;
  while ((round(posicionY * pageHeight)+offsetY ) < bitmap.height) do
  begin
    onLoadIndexMagazine(index + posicionY, filename, eof);
    JPEG.loadfromfile(filename);
    bitmap.Canvas.StretchDraw(rect(0, round(posicionY * pageHeight) , width, round((posicionY + 1) * pageHeight) ), JPEG);
    inc(posicionY);
  end;

  Paint;
end;

procedure TmagazineIndex.Paint;
begin
  inherited;

  Canvas.Draw(0, offsetY, bitmap);
  canvas.Brush.Style := bsClear;
  canvas.Rectangle(0,offsetY,width,bitmap.Height+offsetY);

end;

procedure TmagazineIndex.Resize;
begin
  inherited;
  pageHeight := round(width * 1.41);
  numMaxPages :=ceil(height/pageHeight);

  bitmap.SetSize(width, (numMaxPages+1)*pageHeight);

  prepaint;
end;

procedure TmagazineIndex.setIndex(const Value: integer);
begin
  findex := Value;
  prepaint;
end;

end.

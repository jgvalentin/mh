unit magazine.Index;

interface

uses JPEG, System.StrUtils, Generics.Collections, Graphics, vcl.ExtCtrls, Classes, vcl.Controls, SysUtils, forms, System.Types, vcl.StdCtrls;

type
  TonSelectMagazine = procedure(numero: integer) of object;
  TonLoadIndexMagazine = procedure(index: integer; var filename: string; var eof: boolean) of object;

  TmagazineIndex = class(TcustomPanel)

  private
    dragState: boolean;
    click: boolean;
    dragY, offsetY: integer;
    JPEG: TJPEGImage;
    bitmap: Tbitmap;

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
    constructor create(AOwner: TComponent); override;
    destructor Destroy; override;

    property index: integer read findex write setIndex;
  end;

implementation

{ TmagazineIndex }

procedure TmagazineIndex.clear;
begin

end;

constructor TmagazineIndex.create(AOwner: TComponent);
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
  dragY := y;
end;

procedure TmagazineIndex.MouseMove(Shift: TShiftState; x, y: integer);
begin
  if click then
  begin
    offsetY := y - dragY;
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
      findex := findex - round(offsetY / (width * 1.41));
      offsetY := 0;
      prepaint;
      dragState := false;

    end
    else
    begin

      if assigned(onSelectMagazine) then
      begin
        index := trunc(y / (width * 1.43)) + index;
        onSelectMagazine(index);
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

  posicionY, _index: integer;
  filename: string;
  eof: boolean;
begin

  if not assigned(onLoadIndexMagazine) then
    exit;

  posicionY := 0;
  while ((round(posicionY * width * 1.41) - offsetY) < bitmap.height) do
  begin

    onLoadIndexMagazine(index + posicionY, filename, eof);

    JPEG.loadfromfile(filename);

    bitmap.Canvas.StretchDraw(rect(0, round(posicionY * width * 1.41) + offsetY, width, round((posicionY + 1) * width * 1.41) + offsetY), JPEG);

    inc(posicionY);
  end;

  Paint;
end;

procedure TmagazineIndex.Paint;
begin
  inherited;

  Canvas.Draw(0, offsetY, bitmap);

end;

procedure TmagazineIndex.Resize;
begin
  inherited;
  bitmap.SetSize(width, height*2);
  prepaint;
end;

procedure TmagazineIndex.setIndex(const Value: integer);
begin
  findex := Value;
  prepaint;
end;

end.

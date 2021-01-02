unit DragNDropImage;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,  ExtCtrls;

type
  TMyDragObject = class(TDragControlObject)
  private
    FImageList:TImageList;
    FDragSource:TControl;
  protected
    function GetDragImages: TDragImageList; override;
  public
    Procedure StartDrag(G:TGraphic;p:TPoint;DragSource:TControl);
    Constructor Create(AControl: TControl); override;
    Destructor Destroy;override;
    Property DragSource:TControl read FDragSource;
  end;

implementation

constructor TMyDragObject.Create(AControl: TControl);
begin
 inherited;
 FImageList:=TImageList.Create(nil);
end;

destructor TMyDragObject.Destroy;
begin
 FImageList.Free;
 inherited;
end;

function TMyDragObject.GetDragImages: TDragImageList;
begin
 Result:=FImageList;
end;

procedure TMyDragObject.StartDrag(G: TGraphic;p:TPoint;DragSource:TControl);
var
 bmp: TBitMap;
begin
 FDragSource:=DragSource;
 bmp:=TBitMap.Create;
 try
  FImageList.Width :=g.Width;
  FImageList.Height:=g.Height;
  bmp.Width :=g.Width;
  bmp.Height:=g.Height;
  bmp.Canvas.Draw(0,0,g);
  FImageList.Add(bmp,nil);
 finally
  bmp.Free;
 end;
 FImageList.SetDragImage(0,p.x,p.y)
end;

end.

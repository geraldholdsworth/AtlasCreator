unit MainUnit;

interface

uses
  Winapi.Windows,Winapi.Messages,System.SysUtils,System.Variants,System.Classes,
  Vcl.Graphics,Vcl.Controls,Vcl.Forms,Vcl.Dialogs,Vcl.ExtCtrls,Vcl.ComCtrls,
  Vcl.StdCtrls,Vcl.Buttons,DragNDropImage,Vcl.Imaging.pngimage,Vcl.ExtDlgs,
  Vcl.Imaging.JPEG,Vcl.Imaging.GIFImg,Math,System.StrUtils,System.UITypes,
  ShBrowseU, LZRW1;

type
  TMainForm = class(TForm)
    AtlasCreatePanel: TPanel;
    FinalImagePanel: TPanel;
    BottomSplitter: TSplitter;
    default: TImage;
    sb_atlas: TScrollBox;
    img_atlas: TImage;
    AtlasSettingPanel: TPanel;
    AtlasSizeBox: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    ed_ImagesAcross: TEdit;
    ed_ImagesDown: TEdit;
    ed_TotalImages: TEdit;
    ud_ImagesAcross: TUpDown;
    ud_ImagesDown: TUpDown;
    AtlasDetailBox: TGroupBox;
    Label4: TLabel;
    Label5: TLabel;
    lb_TileSize: TLabel;
    lb_BPP: TLabel;
    ResposPanel: TPanel;
    TopSplitter: TSplitter;
    sb_AtlasCreate: TScrollBox;
    ToolPanel: TPanel;
    sb_Files: TScrollBox;
    sb_Folder: TSpeedButton;
    Label6: TLabel;
    cb_BPP: TComboBox;
    sb_LoadScript: TSpeedButton;
    sb_SaveScript: TSpeedButton;
    sb_SaveAtlas: TSpeedButton;
    SaveTextFile: TSaveDialog;
    img_Bin: TImage;
    closed_bin: TImage;
    open_bin: TImage;
    SavePicture: TSavePictureDialog;
    OpenTextFile: TOpenDialog;
    sb_createatlas: TSpeedButton;
    Panel1: TPanel;
    Label7: TLabel;
    Panel2: TPanel;
    Label8: TLabel;
    Panel3: TPanel;
    Label9: TLabel;
    Panel4: TPanel;
    Label10: TLabel;
    sb_LoadAtlas: TSpeedButton;
    lzrw11: Tlzrw1;
    OpenPicture: TOpenPictureDialog;
    sb_SaveAtlasFiles: TSpeedButton;
    bpp_progress: TProgressBar;
    sb_About: TSpeedButton;
    procedure FormShow(Sender: TObject);
    procedure UpdateTotalImages(BPP: Integer);
    procedure ed_ImagesAcrossChange(Sender: TObject);
    function createImage(parent: TObject;top,left,width,height: Integer): TImage;
    function GetBPP(bmp: TBitmap): Integer;
    procedure sb_FolderClick(Sender: TObject);
    procedure LoadImagesFromDirectory;
    procedure ImageStartDrag(Sender: TObject; var DragObject: TDragObject);
    procedure FormCreate(Sender: TObject);
    procedure ImageDragOver(Sender, Source: TObject; X,Y: Integer;
                            State: TDragState; var Accept: Boolean);
    procedure ImageDragDrop(Sender, Source: TObject; X,Y: Integer);
    procedure sb_SaveScriptClick(Sender: TObject);
    procedure sb_SaveAtlasClick(Sender: TObject);
    function extractExtension(filename: String): String;
    procedure sb_LoadScriptClick(Sender: TObject);
    function ReduceBPP(bmp: TBitmap):Integer;
    function LoadBitmapFromFile(filename: String;var Image: TImage): Boolean;
    function AppVersion: String;
    procedure img_BinDblClick(Sender: TObject);
    procedure ResposPanelResize(Sender: TObject);
    procedure sb_createatlasClick(Sender: TObject);
    procedure sb_LoadAtlasClick(Sender: TObject);
    procedure sb_SaveAtlasFilesClick(Sender: TObject);
    procedure sb_AboutClick(Sender: TObject);
  private
   atlas           : array of array of TImage;
   atlasfiles      : array of array of String;
   files           : array of TImage;
   filenames       : array of String;
   FDragObject     : TMyDragObject;
   dragging        : String;
   dragging_width,
   dragging_height,
   def_width,
   def_height      : Integer;
   bin_closed      : Boolean;
   const
    blank_text     = 'Blank';
    atlas_text     = 'Atlas';
    file_text      = 'File';
    bin_text       = 'Bin';
    delete_confirm = 'This will delete the current atlas. Continue?';
    remove_confirm = 'Remove all tiles from the atlas?';
    app_date       = 'beta';
  public
  end;

var
  MainForm: TMainForm;

// There appears to be a bug where some atlas bitmaps are not saved correctly
// Could be when switching BPP, or tile sizes???

implementation

{$R *.dfm}

uses AboutUnit;

//Procedures 'fixkey' and 'Listsort' written by Gary Darby www.delphiforfun.org
procedure fixkey(key:string; var fix1:string; var fix2:integer; var fix3:string);
{{Parse string "key" into alpha, numeric, and alpa parts}
var
 i,j :integer;
begin
 i:=1;
 while (i<=length(key)) and (not (ANSIChar(key[i]) in ['0'..'9'])) do inc(i);
 if i<=length(key) then
 begin {digits found}
  fix1:=uppercase(copy(key,1,i-1));
  j:=i;
  while (j<=length(key)) and (ANSIChar(key[j]) in ['0'..'9']) do inc(j);
  fix2:=strtoint(copy(key,i, j-i));
  fix3:=uppercase(copy(key,j,length(key)-j+1));
 end
 else
 begin {what to do if there is no number in the name?}
  fix1:=uppercase(key);
  fix2:=0;
  fix3:='';
 end;
end;

function Listsort(List:TStringList; index1,index2:integer):integer;
{Sort the "list: stringlist in customized sort order}
var
 n1,n2         : integer;
 s1A,s2A,S1B,S2B : string;
begin
 with list do
 begin
  result:=0;
  fixkey(list[index1], S1a, N1, S1B); {split first key into 3 parts}
  fixkey(list[index2], S2a, N2, S2B); {split 2nd key into 3 parts}
  if s1a<s2a then result:=-1  {1st part of 1st key is low}
  else
   if s1a>s2a then result:=+1 {1st part of 1st key is high}
   else  {1st parts are equal}
   begin {compare numeric parts}
    if n1<n2 then result:=-1
    else
     if n1>n2 then result:=+1
     else
     begin {numeric parts also equal, compare 3rd parts}
      if S1b<s2b then result:=-1
      else
       if s1b>s2b then result:=+1;
     end;
   end;
 end;
end;

procedure TMainForm.ed_ImagesAcrossChange(Sender: TObject);
begin
 UpdateTotalImages(0);
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
 i,t: Integer;
begin
 Caption:=Application.Title;
 //Change all the controls to show the dragged image
 ControlStyle:=ControlStyle+[csDisplayDragImage];
 img_atlas.ControlStyle:=img_atlas.ControlStyle+[csDisplayDragImage];
 img_Bin.ControlStyle:=img_Bin.ControlStyle+[csDisplayDragImage];
 for i:=0 to ControlCount-1 do
 begin
  Controls[i].ControlStyle:=Controls[i].ControlStyle+[csDisplayDragImage];
  for t:=0 to TWinControl(Controls[i]).ControlCount-1 do
   TWinControl(TWinControl(Controls[i]).Controls[t]).ControlStyle
                    :=TWinControl(TWinControl(Controls[i]).Controls[t]).ControlStyle
                     +[csDisplayDragImage];
 end;
 //Blank the dragging details
 dragging:='';
 dragging_width:=0;
 dragging_height:=0;
 //Set up the bin
 img_Bin.Picture:=closed_bin.Picture;
 img_Bin.Hint:=bin_text;
 bin_closed:=True;
 //Initialise the default size variables
 def_height:=default.Picture.Bitmap.Height;
 def_width :=default.Picture.Bitmap.Width;
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
 UpdateTotalImages(0);
 sb_Folder.Caption:=GetCurrentDir;
 LoadImagesFromDirectory;
 AboutForm.apptitle.Caption:=Application.Title;
 AboutForm.appversion.Caption:='Version '+AppVersion+' ('+app_date+')';
end;

procedure TMainForm.UpdateTotalImages(BPP: Integer);
var
 x,y : Integer;
 dest: TRect;
const
 pxfm: array[0..5] of TPixelFormat = (pf32bit,
                                      pf1bit,
                                      pf4bit,
                                      pf8bit,
                                      pf16bit,
                                      pf32bit);
begin
 if BPP=0 then BPP:=cb_BPP.ItemIndex;
 //Update the details on the left hand panel
 ed_TotalImages.Text:=IntToStr(ud_ImagesAcross.Position*ud_ImagesDown.Position);
 //Remove any extra atlas pictures
 if ud_ImagesAcross.Position<Length(atlas) then
  for x:=0 to Length(atlas)-1 do
   for y:=0 to Length(atlas[x])-1 do
    if x>ud_ImagesAcross.Position-1 then
     atlas[x,y].Free;
 if Length(atlas)>0 then
  if ud_ImagesDown.Position<Length(atlas[0]) then
   for x:=0 to Length(atlas)-1 do
    for y:=0 to Length(atlas[x])-1 do
     if y>ud_ImagesDown.Position-1 then
      atlas[x,y].Free;
 //Adjust the atlas arrays
 SetLength(atlas,ud_ImagesAcross.Position,ud_ImagesDown.Position);
 SetLength(atlasfiles,ud_ImagesAcross.Position,ud_ImagesDown.Position);
 //Iterate through all the pictures
 for x:=0 to Length(atlas)-1 do
  for y:=0 to Length(atlas[x])-1 do
  begin
   //Has it been created? If not, then create it
   if atlas[x,y]=nil then
   begin
    atlas[x,y]:=createImage(sb_AtlasCreate,
                            1+y*(def_height+1),
                            1+x*(def_width+1),
                            def_width,
                            def_height);
    atlas[x,y].Picture:=default.Picture;
    atlasfiles[x,y]:=blank_text;
    atlas[x,y].OnDragOver:=ImageDragOver;
    atlas[x,y].OnDragDrop:=ImageDragDrop;
    atlas[x,y].OnStartDrag:=ImageStartDrag;
    atlas[x,y].DragCursor:=crArrow;
    atlas[x,y].DragMode:=dmAutomatic;
    atlas[x,y].Tag:=x+y*$100;    //Used to identify when dragging
    atlas[x,y].Hint:=atlas_text; //Used to identify when dragging
   end;
   //Change the BPP according to the user setting
   if (x=0) and (y=0) then
   begin
    if BPP<6 then
     img_atlas.Picture.Bitmap.PixelFormat:=pxfm[BPP]
    else //Match - get the BPP of 0,0 and use that
     case GetBPP(atlas[0,0].Picture.Bitmap) of
      1    : img_atlas.Picture.Bitmap.PixelFormat:=pf1bit;
      2,4  : img_atlas.Picture.Bitmap.PixelFormat:=pf4bit;
      8    : img_atlas.Picture.Bitmap.PixelFormat:=pf8bit;
      15,16: img_atlas.Picture.Bitmap.PixelFormat:=pf16bit;
      24,32: img_atlas.Picture.Bitmap.PixelFormat:=pf32bit;
     end;
    //Change the final image size
    img_atlas.Picture.Bitmap.Width:=atlas[0,0].Picture.Bitmap.Width*ud_ImagesAcross.Position;
    img_atlas.Picture.Bitmap.Height:=atlas[0,0].Picture.Bitmap.Height*ud_ImagesDown.Position;
   end;
   //Now draw each picture onto the final image, if the size matches 0,0 or is blank
   if ((atlas[x,y].Width=atlas[0,0].Width)
   and (atlas[x,y].Height=atlas[0,0].Height))
   or (atlasfiles[x,y]=blank_text) then
   begin
    dest.Top:=y*atlas[0,0].Picture.Bitmap.Height;
    dest.Left:=x*atlas[0,0].Picture.Bitmap.Width;
    dest.Width:=atlas[0,0].Picture.Bitmap.Width;
    dest.Height:=atlas[0,0].Picture.Bitmap.Height;
    //We'll stretch it on, for those blank images
    img_atlas.Canvas.StretchDraw(dest,atlas[x,y].Picture.Graphic);
   end;
  end;
 //Work out the lowest possible BPP and apply
 if BPP=0 then
  UpdateTotalImages(ReduceBPP(img_atlas.Picture.Bitmap));
 //Move the bin
 img_Bin.Left:=1+Length(atlas)*(def_width+1);
 img_Bin.Top:=1+(Length(atlas[0])-1)*(def_height+1);
 //Update the details on the left panel
 lb_TileSize.Caption:=IntToStr(atlas[0,0].Picture.Bitmap.Width)+'x'
                     +IntToStr(atlas[0,0].Picture.Bitmap.Height);
 lb_BPP.Caption:=IntToStr(GetBPP(img_atlas.Picture.Bitmap));
end;

function TMainForm.createImage(parent: TObject;top,left,width,height: Integer): TImage;
var
 i: TImage;
begin
 i:=TImage.Create(parent as TComponent);
 i.Parent:=parent as TWinControl;
 i.Visible:=true;
 i.Top:=top;
 i.Left:=left;
 i.Width:=width;
 i.Height:=height;
 i.Stretch:=true;
 i.Proportional:=True;
 i.Center:=True;
 i.ControlStyle:=i.ControlStyle+[csDisplayDragImage];
 createImage:=i;
end;

function TMainForm.GetBPP(bmp: TBitmap): Integer;
var
 buffer: array[0..1] of Byte;
 ms    : TMemoryStream;
begin
 //Create the stream
 ms:=TMemoryStream.Create;
 //Copy the bitmap into it
 ms.Position:=0;
 bmp.SaveToStream(ms);
 //Read the two bytes for the BPP
 ms.Position:=$1C;
 ms.ReadBuffer(buffer,2);
 //Turn it into a 16bit Integer
 Result:=buffer[0]+buffer[1]*$100;
 ms.Free;
end;

procedure TMainForm.sb_AboutClick(Sender: TObject);
begin
 AboutForm.ShowModal;
end;

procedure TMainForm.sb_createatlasClick(Sender: TObject);
var
 x,y,f: Integer;
begin
 if Length(files)>0 then
  if MessageDlg(delete_confirm,mtConfirmation,[mbYes,mbNo,mbCancel],0)=mrYes then
  begin
   //First, remove all tiles and reset the atlas
   for x:=0 to Length(atlas)-1 do
    for y:=0 to Length(atlas[x])-1 do
    begin
    atlas[x,y].Picture:=default.Picture;
    atlasfiles[x,y]:=blank_text;
    end;
   UpdateTotalImages(0);
   //Now add all the file images, in order, unless there are not enough spaces
   x:=0;
   y:=0;
   f:=0;
   repeat
    if ((x=0) and (y=0))
    or ((files[f].Picture.Bitmap.Width=atlas[0,0].Picture.Bitmap.Width)
    and (files[f].Picture.Bitmap.Height=atlas[0,0].Picture.Bitmap.Height)) then
    begin
     atlas[x,y].Picture:=files[f].Picture;
     atlasfiles[x,y]:=filenames[f];
     inc(x);
     if x>=ud_imagesacross.Position then
     begin
      inc(y);
      x:=0;
     end;
    end;
    inc(f);
   until (f=Length(files)) or (y>=ud_imagesdown.Position);
   UpdateTotalImages(0);
  end;
end;

procedure TMainForm.sb_FolderClick(Sender: TObject);
begin
 with TShBrowse.Create do
 begin
  Caption:='Browse for directory';
  UserMessage:='Browse for directory';
  InitFolder:=sb_Folder.Caption;
  if Execute then
   sb_Folder.Caption:=Folder;
  LoadImagesFromDirectory;
  Free
 end;
end;

procedure TMainForm.sb_LoadAtlasClick(Sender: TObject);
var
 x,y,sizex,sizey: Integer;
 dest,src: TRect;
begin
 if OpenPicture.Execute then
  if MessageDlg(delete_confirm,mtConfirmation,[mbYes,mbNo,mbCancel],0)=mrYes then
  begin
   img_atlas.Picture.Bitmap.PixelFormat:=pfDevice;
   if LoadBitmapFromFile(OpenPicture.FileName,img_atlas) then
   begin
    sizex:=img_atlas.Picture.Bitmap.Width div ud_ImagesAcross.Position;
    sizey:=img_atlas.Picture.Bitmap.Height div ud_ImagesDown.Position;
    for x:=0 to Length(atlas)-1 do
     for y:=0 to Length(atlas[x])-1 do
     begin
      dest.Top:=0;
      dest.Left:=0;
      dest.Width:=sizex;
      dest.Height:=sizey;
      atlas[x,y].Picture.Bitmap.Width:=sizex;
      atlas[x,y].Picture.Bitmap.Height:=sizey;
      atlas[x,y].Picture.Bitmap.PixelFormat:=pfDevice;
      src.Top:=y*sizey;
      src.Left:=x*sizex;
      src.Width:=sizex;
      src.Height:=sizey;
      atlas[x,y].Canvas.CopyRect(dest,img_atlas.Canvas,src);
     end;
    UpdateTotalImages(cb_BPP.ItemIndex);
   end;
  end;
end;

procedure TMainForm.sb_LoadScriptClick(Sender: TObject);
var
 F         : TextFile;
 S,filename: String;
 x,y       : Integer;
 bmp       : TImage;
begin
 if OpenTextFile.Execute then
  if MessageDlg(delete_confirm,mtConfirmation,[mbYes,mbNo,mbCancel],0)=mrYes then
  begin
   //Open the file
   AssignFile(F,OpenTextFile.FileName);
   Reset(F);
   Repeat
    //Read in line by line
    ReadLn(F,S);
    if Copy(S,1,5)='SIZE=' then //Set the size
    begin
     //Changing either of these will update the arrays and pictures
     ud_ImagesAcross.Position:=StrToIntDef(Copy(S,6,Pos('x',S,6)-6),16);
     ud_ImagesDown.Position:=StrToIntDef(Copy(S,Pos('x',S,6)+1),4);
    end;
    if Copy(S,1,4)='BPP=' then //Set the bitmap size
     cb_BPP.ItemIndex:=StrToIntDef(Copy(S,5),5); //Changing this will update the arrays and pictures
    if Copy(S,1,5)='FILES' then //Load the pictures
    repeat
     //Read in file by file
     ReadLn(F,S);
     //Get the co-ordinates
     x:=StrToIntDef(Copy(S,1,Pos(',',S)-1),Length(atlas));
     y:=StrToIntDef(Copy(S,Pos(',',S)+1,Pos(':',S)-Pos(',',S)-1),Length(atlas[0]));
     //And the filename
     filename:=Copy(S,Pos(':',S)+1);
     //Ensures that only valid co-ordinates are specified
     if (x<Length(atlas)) and (y<Length(atlas[0])) then
     begin
      //Blank off the image
      atlas[x,y].Picture:=default.Picture;
      atlasfiles[x,y]:=blank_text;
      //Only load if the file still exists
      if FileExists(filename) then
      begin
       //Create the temporary store
       bmp:=TImage.Create(MainForm);
       //Load into temporary store for testing
       if LoadBitmapFromFile(filename,bmp) then
       begin
        //if OK, then transfer to picture
        if ((bmp.Picture.Width=atlas[0,0].Picture.Width)
        and (bmp.Picture.Height=atlas[0,0].Picture.Height))
        or ((x=0) and (y=0)) then
        begin
         atlas[x,y].Picture:=bmp.Picture;
         atlasfiles[x,y]:=filename;
        end;
       end;
       bmp.Free;
      end;
     end;
     UpdateTotalImages(0);
    until EOF(F);
   Until EOF(F);
   //Tidy up
   CloseFile(F);
  end;
end;

procedure TMainForm.sb_SaveAtlasClick(Sender: TObject);
var
 ext: String;
 png: TPNGImage;
 gif: TGIFImage;
 jpg: TJPEGImage;
 ms,res: TMemoryStream;
begin
 if SavePicture.Execute then
 begin
  //Get extension
  ext:=extractExtension(SavePicture.FileName);
  //Save as bitmap
  if ext='.bmp' then img_atlas.Picture.Bitmap.SaveToFile(SavePicture.FileName);
  //Save as PNG
  if ext='.png' then
  begin
   png:=TPNGImage.Create;
   png.Assign(img_atlas.Picture.Bitmap);
   png.SaveToFile(SavePicture.FileName);
   png.Free;
  end;
  //Save as GIF
  if ext='.gif' then
  begin
   gif:=TGIFImage.Create;
   gif.Assign(img_atlas.Picture.Bitmap);
   gif.SaveToFile(SavePicture.FileName);
   gif.Free;
  end;
  //Save as JPEG
  if ext='.jpg' then
  begin
   jpg:=TJPEGImage.Create;
   jpg.CompressionQuality:=100;
   jpg.Assign(img_atlas.Picture.Bitmap);
   jpg.SaveToFile(SavePicture.FileName);
   jpg.Free;
  end;
  //Save as LZRW compressed bitmap
  if ext='.lzrw' then
  begin
   ms:=TMemoryStream.Create;
   ms.Position:=0;
   img_atlas.Picture.Bitmap.SaveToStream(ms);
   ms.Position:=0;
   res:=TMemoryStream.Create;
   res.Position:=0;
   lzrw11.InputStream:=ms;
   lzrw11.OutputStream:=res;
   lzrw11.Compress;
   res.Position:=0;
   res.SaveToFile(SavePicture.FileName);
   ms.Free;
   res.Free;
  end;
 end;
end;

procedure TMainForm.sb_SaveAtlasFilesClick(Sender: TObject);
var
 x,y: Integer;
begin
 for x:=0 to Length(atlas)-1 do
  for y:=0 to Length(atlas[x])-1 do
   atlas[x,y].Picture.Bitmap.SaveToFile(sb_Folder.Caption+'\'+
                                        IntToStr(y*ud_ImagesAcross.Position+x)+
                                        '.bmp');
 LoadImagesFromDirectory;
end;

procedure TMainForm.sb_SaveScriptClick(Sender: TObject);
var
 S : String;
 x,
 y : Integer;
 F : TextFile;
begin
 if SaveTextFile.Execute then
 begin
  S:='';
  AssignFile(F,SaveTextFile.FileName);
  ReWrite(F);
  WriteLn(F,'SIZE='+IntToStr(ud_ImagesAcross.Position)+'x'+IntToStr(ud_ImagesDown.Position));
  WriteLn(F,'BPP='+IntToStr(cb_BPP.ItemIndex));
  WriteLn(F,'FILES');
  for x:=0 to Length(atlas)-1 do
   for y:=0 to Length(atlas[x])-1 do
    WriteLn(F,IntToStr(x)+','+IntToStr(y)+':'+atlasfiles[x,y]);
  CloseFile(F);
 end;
end;

procedure TMainForm.LoadImagesFromDirectory;
var
 i,
 FindResult: integer;
 SearchRec : TSearchRec;
 FileList  : TStringList;
 TempImage : TImage;
begin
 //First part gets a list of files in the current directory
 FileList:=TStringList.Create;
 FileList.Clear;
 FindResult:=FindFirst(sb_Folder.Caption+'\*.*',faAnyFile-faDirectory,SearchRec);
 while FindResult=0 do
 begin
  FileList.Add({sb_Folder.Caption+'\'+}SearchRec.Name);
  FindResult:=FindNext(SearchRec);
 end;
 FindClose(SearchRec);
 FileList.CustomSort(ListSort);
 //Now we'll blank off any arrays currently open
 if Length(files)>0 then
  for i:=0 to Length(files)-1 do
   files[i].Free;
 SetLength(files,0);
 SetLength(filenames,0);
 //Now we iterate through the list to find bitmap images
 for i:=0 to FileList.Count-1 do
 begin
  TempImage:=TImage.Create(MainForm);
  if LoadBitmapFromFile(sb_Folder.Caption+'\'+FileList[i],TempImage) then
  begin
   SetLength(files,Length(files)+1);
   SetLength(filenames,Length(filenames)+1);
   files[Length(files)-1]:=createImage(sb_Files,
                                       4,
                                       (def_width+2)*(Length(files)-1),
                                       def_width,
                                       def_height);
   files[Length(files)-1].Picture:=TempImage.Picture;
   files[Length(files)-1].OnStartDrag:=ImageStartDrag;
   files[Length(files)-1].DragCursor:=crArrow;
   files[Length(files)-1].DragMode:=dmAutomatic;
   files[Length(files)-1].Tag:=Length(files)-1;
   files[Length(files)-1].Hint:=file_text;
   filenames[Length(filenames)-1]:=sb_Folder.Caption+'\'+FileList[i];
  end;
  TempImage.Free;
 end;
 //Tidy up
 FileList.Free;
 //Re-arrange panel
 ResposPanelResize(nil);
end;

procedure TMainForm.ImageStartDrag(Sender: TObject; var DragObject: TDragObject);
var
 p: TPoint;
begin
 p:=TImage(Sender).ScreenToClient(mouse.cursorpos);
 if Assigned(FDragObject) then FDragObject.Free;
 FDragObject:=TMyDragObject.Create(TImage(Sender));
 FDragObject.StartDrag(TImage(Sender).Picture.Graphic,p,TImage(Sender));
 //Take note of  the image being dragged - there is no other way to get this
 //info later on
 dragging:=TImage(Sender).Hint;
 dragging_width:=TImage(Sender).Picture.Bitmap.Width;
 dragging_height:=TImage(Sender).Picture.Bitmap.Height;
 DragObject:=FDragObject;
end;

procedure TMainForm.img_BinDblClick(Sender: TObject);
var
 x,y: Integer;
begin
 if MessageDlg(remove_confirm,mtConfirmation,[mbYes,mbNo,mbCancel],0)=mrYes then
 begin
  for x:=0 to Length(atlas)-1 do
   for y:=0 to Length(atlas[x])-1 do
   begin
    atlas[x,y].Picture:=default.Picture;
    atlasfiles[x,y]:=blank_text;
   end;
  UpdateTotalImages(0);
 end;
end;

procedure TMainForm.ImageDragOver(Sender, Source: TObject; X,Y: Integer;
                                  State: TDragState; var Accept: Boolean);
begin
 if Source is TMyDragObject then
 begin
  //By default, Accept is False on entry
  Accept:=False;
  //Is it a file being dragged onto the top atlas, or an atlas picture
  //being dragged onto the bin?
  if ((dragging=file_text) and (TImage(Sender).Hint=atlas_text))
  or ((dragging=atlas_text) and (TImage(Sender).Hint=bin_text)) then
   Accept:=True;
  //If it is a file being dragged onto the top atlas, is it the correct size
  //or being dragged to 0,0?
  if TImage(Sender).Hint=atlas_text then
  begin
   x:=TImage(Sender).Tag mod $100;
   y:=TImage(Sender).Tag div $100;
   if ((x>0) or (y>0))
   and (dragging_width<>atlas[0,0].Picture.Bitmap.Width)
   and (dragging_height<>atlas[0,0].Picture.Bitmap.Height) then
    Accept:=False; //That'll be a 'no' then
  end;
  //Dragging onto the bin? Open it
  if (Accept) and (TImage(Sender).Hint=bin_text) then
  begin
   img_Bin.Picture:=open_bin.Picture;
   bin_closed:=False;
  end
  else
  //Make sure the bin is closed
   if not bin_closed then
   begin
    img_Bin.Picture:=closed_bin.Picture;
    bin_closed:=True;
   end;
 end;
end;

procedure TMainForm.ImageDragDrop(Sender, Source: TObject; X,Y: Integer);
var
 confirm: Integer;
begin
 if FDragObject.DragSource is TImage then
 begin
  if dragging=file_text then //When dragging files
   //This will only update if the picture is the same size as the top right.
   if ((TImage(FDragObject.DragSource).Picture.Bitmap.Width=atlas[0,0].Picture.Bitmap.Width)
   and (TImage(FDragObject.DragSource).Picture.Bitmap.Height=atlas[0,0].Picture.Bitmap.Height))
   or (TImage(Sender)=atlas[0,0])then
   begin
    //First, if this is the top right picture, check all others are compatible
    if TImage(Sender)=atlas[0,0] then
     if (TImage(FDragObject.DragSource).Picture.Bitmap.Width<>atlas[0,0].Picture.Bitmap.Width)
     or (TImage(FDragObject.DragSource).Picture.Bitmap.Height<>atlas[0,0].Picture.Bitmap.Height) then
      for x:=0 to Length(atlas)-1 do
       for y:=0 to Length(atlas[x])-1 do
       begin
        atlas[x,y].Picture:=default.Picture;
        atlasfiles[x,y]:=blank_text;
       end;
    //Now update the appropriate picture
    TImage(Sender).Picture:=TImage(FDragObject.DragSource).Picture;
    atlasfiles[TImage(Sender).Tag mod $100,TImage(Sender).Tag div $100]
       :=filenames[TImage(FDragObject.DragSource).Tag];
    //And then the actual atlas
    UpdateTotalImages(0);
   end;
  if dragging=atlas_text then //Throw away an image
  begin
   x:=TImage(FDragObject.DragSource).Tag mod $100;
   y:=TImage(FDragObject.DragSource).Tag div $100;
   confirm:=mrYes;
   if (x=0) and (y=0) then
    confirm:=MessageDlg('This operation will remove all tiles from the atlas '
                       +'that are not of size '+IntToStr(def_width)+'x'
                       +IntToStr(def_height)+'pixels. Continue?',
                       mtConfirmation,
                       [mbYes,mbNo,mbCancel],0);
   if confirm=mrYes then
   begin
    atlas[x,y].Picture:=default.Picture;
    atlasfiles[x,y]:=blank_text;
    //If image is 0,0, then remove all others if not the same size as blank
    if (x=0) and (y=0) then
     for x:=0 to Length(atlas)-1 do
      for y:=0 to Length(atlas[x])-1 do
       if (atlas[x,y].Picture.Bitmap.Width<>atlas[0,0].Picture.Bitmap.Width)
       or (atlas[x,y].Picture.Bitmap.Height<>atlas[0,0].Picture.Bitmap.Height) then
       begin
        atlas[x,y].Picture:=default.Picture;
        atlasfiles[x,y]:=blank_text;
       end;
    img_Bin.Picture:=closed_bin.Picture;
    bin_closed:=True;
    UpdateTotalImages(0);
   end;
  end;
 end;
end;

function TMainForm.extractExtension(filename: String): String;
var
 s: String;
 i: Integer;
begin
 i:=Length(filename);
 Repeat
  i:=i-1;
 until (Copy(filename,i,1)='.') or (Copy(filename,i,1)=',') or (i=-1);
 if i>=0 then
  s:=LowerCase(Copy(filename,i,(Length(filename)-i)+1))
 else
  s:='';
 Result:=s;
end;

function TMainForm.ReduceBPP(bmp: TBitmap):Integer;
var
 Palette   : array of String;
 ms        : TMemoryStream;
 BPP,
 i,x,y,
 pxd       : Integer;
 buffer    : array of Byte;
 S         : String;
begin
 bpp_progress.Visible:=True;
 bpp_progress.Position:=0;
 //Set the bitmap to maximum colour depth
 bmp.PixelFormat:=pf32bit;
 //Create the memory stream
 ms:=TMemoryStream.Create;
 //Copy the bitmap into the stream
 ms.Position:=0;
 bmp.SaveToStream(ms);
 //Setup the buffer
 SetLength(buffer,ms.Size);
 for i:=0 to Length(buffer)-1 do buffer[i]:=0;
 //And read the bitmap into it
 ms.Position:=0;
 ms.ReadBuffer(buffer[0],ms.Size);
 //Get the offset to the pixel data
 pxd:=buffer[$0A]
     +buffer[$0B]*$100
     +buffer[$0C]*$10000
     +buffer[$0D]*$1000000;
 //Build the palette
 SetLength(Palette,0);
 for y:=0 to bmp.Height do
  for x:=0 to bmp.Width do
  begin
   S:=IntToHex(buffer[pxd+(bmp.Height-y)*bmp.Width*4+(x*4)]
              +buffer[pxd+(bmp.Height-y)*bmp.Width*4+(x*4)+1]*$100
              +buffer[pxd+(bmp.Height-y)*bmp.Width*4+(x*4)+2]*$10000
              +buffer[pxd+(bmp.Height-y)*bmp.Width*4+(x*4)+3]*$1000000
               ,8);
   if not MatchStr(S,Palette) then
   begin
    SetLength(Palette,Length(Palette)+1);
    Palette[Length(Palette)-1]:=S;
   end;
   bpp_progress.Position:=Round(((y*bmp.Width)/(bmp.Width*bmp.Height))*100);
  end;
 //Work out the new BPP
 BPP:=0;
 repeat
  if BPP=0 then inc(BPP) else BPP:=BPP*2;
 until Length(Palette)<1 shl BPP;
 //Return the new BPP value
 Result:=6; //Default to 'Match'
 case BPP of
  1  : Result:=1;
  2,4: Result:=2;
  8  : Result:=3;
  16 : Result:=4;
  32 : Result:=5;
 end;
 //Free up the memory stream
 ms.Free;
 //Close the progress bar
 bpp_progress.Visible:=False;
end;

procedure TMainForm.ResposPanelResize(Sender: TObject);
var
 f,max,top,left: Integer;
begin
 //Find out the width of the panel
 max:=sb_Files.ClientWidth-20;
 //If the max is less than def_width, then make it bigger
 if max<def_width+4 then max:=def_width+4;
 //Reset the current scroll position
 sb_Files.HorzScrollBar.Position:=0;
 sb_Files.VertScrollBar.Position:=0;
 //Start at the top left
 top:=2;
 left:=2;
 //Move the images
 for f:=0 to Length(files)-1 do
 begin
  files[f].Left:=left;
  files[f].Top:=top;
  inc(left,def_width+2);
  if left+def_width>max then
  begin
   left:=2;
   inc(top,def_height+2);
  end;
 end;
end;

function TMainForm.LoadBitmapFromFile(filename: String;var Image: TImage): Boolean;
var
 size,j    : Integer;
 pngfound,
 bmpfound,
 giffound  : Boolean;
 png       : TPNGImage;
 gif       : TGIFImage;
 buffer    : array[0..$F] of Byte;
 F         : TFileStream;
 const
  pngsig: array[0..$F] of Byte=($89,$50,$4E,$47
                               ,$0D,$0A,$1A,$0A
                               ,$00,$00,$00,$0D
                               ,$49,$48,$44,$52);
begin
 //We need to know the size of each file
 size:=0;
 //Clear the buffer
 for j:=0 to 15 do buffer[j]:=0;
 //Load each file - if file is already open, it will error
 try
  F:=TFileStream.Create(filename,fmOpenRead);
  size:=F.Size;
  F.Position:=0;
  F.Read(buffer[0],16);
  F.Free;
 except
 end;
 //Bitmaps:
 //The first two bytes should be 'BM', and the next four should be the filesize
 //which will match what we got before
 bmpfound:=(buffer[0]=ord('B')) and (buffer[1]=ord('M'))
       and (buffer[2]+buffer[3]*$100+buffer[4]*$10000+buffer[5]*$1000000=size);
 //PNG:
 //First sixteen bytes will be: 89 50 4E 47 0D 0A 1A 0A 00 00 00 0D 49 48 44 52
 pngfound:=True;
 for j:=0 to 15 do
  if buffer[j]<>pngsig[j] then pngfound:=False;
 //GIF:
 //Starts 'GIF87a' or 'GIF89a'
 giffound:=(buffer[0]=ord('G'))and(buffer[1]=ord('I'))and(buffer[2]=ord('F'))
        and(buffer[3]=ord('8'))and(buffer[5]=ord('a'))
        and((buffer[4]=ord('7'))or(buffer[4]=ord('9')));
 //If we have found one of the above, then load it
 try
  if (bmpfound) or (pngfound) or (giffound) then
  begin
   if bmpfound then
    Image.Picture.Bitmap.LoadFromFile(filename);
   if pngfound then
   begin
    png:=TPNGImage.Create;
    png.LoadFromFile(filename);
    Image.Picture.Bitmap.Width:=png.Width;
    Image.Picture.Bitmap.Height:=png.Height;
    Image.Canvas.Draw(0,0,png);
    png.Free;
   end;
   if giffound then
   begin
    gif:=TGIFImage.Create;
    gif.LoadFromFile(filename);
    Image.Picture.Bitmap.Width:=gif.Width;
    Image.Picture.Bitmap.Height:=gif.Height;
    Image.Canvas.Draw(0,0,gif);
    gif.Free;
   end;
  end;
 except
  bmpfound:=False;
  pngfound:=False;
  giffound:=False;
 end;
 Result:=bmpfound or pngfound or giffound;
end;

function TMainForm.AppVersion: String;
var
 sFileName   : String;
 iBufferSize,
 iDummy      : DWORD;
 pBuffer,
 pFileInfo   : Pointer;
 iVer        : array[1..4] of Word;
begin
 Result:='';
 SetLength(sFileName,MAX_PATH+1);
 SetLength(sFileName,GetModuleFileName(hInstance,PChar(sFileName),MAX_PATH+1));
 iBufferSize:=GetFileVersionInfoSize(PChar(sFileName),iDummy);
 if (iBufferSize>0) then
 begin
  GetMem(pBuffer,iBufferSize);
  try
   GetFileVersionInfo(PChar(sFileName),0,iBufferSize,pBuffer);
   VerQueryValue(pBuffer,'\',pFileInfo,iDummy);
   iVer[1]:=HiWord(PVSFixedFileInfo(pFileInfo)^.dwFileVersionMS); {Major}
   iVer[2]:=LoWord(PVSFixedFileInfo(pFileInfo)^.dwFileVersionMS); {Minor}
   iVer[3]:=HiWord(PVSFixedFileInfo(pFileInfo)^.dwFileVersionLS); {Release}
   iVer[4]:=LoWord(PVSFixedFileInfo(pFileInfo)^.dwFileVersionLS); {Build}
  finally
   FreeMem(pBuffer);
  end;
  Result:=Format('%d.%.2d',[iVer[1],iVer[2]]{,iVer[3],iVer[4]]});
 end;
end;

end.

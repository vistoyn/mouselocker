unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ShellForms, Wnd, StdCtrls, Menus, ICO, ExtCtrls, ListObj, Streams,
  WinUtils, Buttons, Main;

type
  TForm1 = class(TShellForm)
    PopupMenu1: TPopupMenu;
    N3: TMenuItem;
    N1: TMenuItem;
    N2: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    N7: TMenuItem;
    BitBtn1: TBitBtn;
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure N3Click(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure N6Click(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
  private
    { Private declarations }
  protected
   procedure CreateWnd; override;
   procedure DestroyWnd; override;

   procedure WndProc(var Message: TMessage); override;
   procedure HideApplication;
   procedure ShowApplication;  
  public
    { Public declarations }
    is_show : boolean;
  end;

var
  Form1: TForm1;
  IconList : TListObject;

implementation
uses InitHook, Appl;

{$R *.dfm}
{$R icons.res}

procedure starthook; forward;

type
 TStatus = (stDisable, stEnable, stLocked);

 TMouseLock = object
   WindowHandle : THandle;
   status : TStatus;
   oldMouseRect : TRect;

   function  LockEnable : boolean;
   procedure ChangeStatus(value : TStatus);

   procedure LockMouse;
   procedure UnLockMouse;
 end;

 function TMouseLock.LockEnable : boolean;
 begin
  result := status <> stDisable;
 end;

 procedure TMouseLock.ChangeStatus(value : TStatus);
 begin
  if value <> status then status := value;
  if (not Assigned(Form1)) or (IconList.Count < 3) then exit;
  case status of
   stDisable :
   begin
    Form1.ShellForm.SetTrayIconCaption('Выключен');
    Form1.ShellForm.SetTrayIcon(TICO(IconList.Items[2, 0]).Icons[0]^.handle);
    Form1.Caption := 'Выключен';
    if Assigned(DataArea) then DataArea^.LockEnable := false;
   end;
   stEnable :
   begin
    Form1.ShellForm.SetTrayIconCaption('Включен');
    Form1.ShellForm.SetTrayIcon(TICO(IconList.Items[0, 0]).Icons[0]^.handle);
    Form1.Caption := 'Включен';
    if Assigned(DataArea) then DataArea^.LockEnable := true;
   end;
   stLocked :
   begin
    Form1.ShellForm.SetTrayIconCaption('Заблокирован');
    Form1.ShellForm.SetTrayIcon(TICO(IconList.Items[1, 0]).Icons[0]^.handle);
    Form1.Caption := 'Заблокирован';
    if Assigned(DataArea) then DataArea^.LockEnable := true;
   end;
  end;
 end;

 procedure TMouseLock.LockMouse;
 var
  r : TRect;
 begin
  WindowHandle := GetForegroundWindow;
  r := GetWindowClientRect(WindowHandle);
  ClipCursor(@r);
  ChangeStatus(stLocked);
 end;

 procedure TMouseLock.UnLockMouse;
 begin
  ClipCursor(@oldMouseRect);
  ChangeStatus(stEnable);
 end;

var
 MouseLock : TMouseLock;

procedure TForm1.CreateWnd;
begin
 inherited;
 DataArea^.MyAppWnd := Handle;
end;

procedure TForm1.DestroyWnd;
begin
 DataArea^.MyAppWnd := 0;
 inherited;
end;

procedure TForm1.HideApplication;
begin
 hide;
 is_show := false;
end;

procedure TForm1.ShowApplication;
begin
 show;
 WindowVisible(Handle, true);
 WindowSetFocus(Handle);
end;

procedure TForm1.WndProc(var Message: TMessage);
begin

 case Message.Msg of

  WM_SHOWWINDOW :
   WindowVisible(Application.Handle, false);

  WM_SYSCOMMAND:
    case Message.WParam and $FFF0 of
      SC_MINIMIZE :
      begin
       Message.Msg := WM_NULL;
       Form1.Hide;
      end;

      SC_CLOSE :
      begin
       PostMessage(Handle, WM_SYSCOMMAND, SC_MINIMIZE, 0);
       Message.Msg := WM_NULL;
      end;
    end;

  WM_Tray_Message :
  begin
   case Message.LParam of
    WM_LBUTTONDOWN, WM_LBUTTONDBLCLK :
     if is_show then
//      HideApplication
     else            ;
//      ShowApplication;

    WM_RBUTTONDOWN :
     PopupMenu1.Popup(Mouse.CursorPos.X, Mouse.CursorPos.Y);

    WM_MOUSEMOVE :
     is_show := GetForegroundWindow = Form1.Handle;

   end;
  end;

 end;

 if (Message.Msg = DataArea^.WM_MYKEYHOOK) and (MouseLock.LockEnable = false) then
 begin
//  Message.Result := KeyboardFunc(0, Message.wparam, Message.lparam);
  exit;
 end;

 if (Message.Msg = DataArea^.WM_LOCK) and (MouseLock.LockEnable = true) then
 begin
  MouseLock.LockMouse;
  exit;
 end;

 if (Message.Msg = DataArea^.WM_UNLOCK) and (MouseLock.LockEnable = true) then
 begin
  MouseLock.UnLockMouse;
  exit;
 end;
                                                                                         
 inherited WndProc(Message);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
 ShellForm.SetTrayIconCaption('Ограничитель мыши');
 MouseLock.ChangeStatus(stDisable);
 ShellForm.CreateTrayIcon;

 PostMessage(Handle, WM_SYSCOMMAND, SC_MINIMIZE, 0);

 starthook;
end;

procedure TForm1.N3Click(Sender: TObject);
begin
 Close;
end;

procedure TForm1.N1Click(Sender: TObject);
begin
 if not MouseLock.LockEnable then
 begin
  MouseLock.ChangeStatus(stEnable);
  N1.Caption := 'Выключить';
 end
 else
 begin
  MouseLock.ChangeStatus(stDisable);
  N1.Caption := 'Включить';
 end;
end;

procedure TForm1.N6Click(Sender: TObject);
begin
 if is_show then
  HideApplication
 else
  ShowApplication;
end;

procedure TForm1.BitBtn1Click(Sender: TObject);
begin
 HideApplication;
end;

//--------------------------------------------------------------------------

const
 LibStr : string = 'keyhook.dll';
 SetHook : procedure; stdcall = nil;
 DelHook : procedure; stdcall = nil;

var
 fDLLHandle : THandle;

procedure starthook;
begin
 if Assigned(Form1) and Assigned(DataArea) then
 begin
//  DataArea^.func := KeyboardFunc;
  SetHook;
 end;
end;

procedure LoadIconFromResource(Name, rt : PAnsiChar);
var
 fStream : TCoolResourceStream;
 icon : TICO;
begin
 fStream := TCoolResourceStream.Create(Name, rt);

 if not fStream.Error then
 begin
  icon := TICO.Create(nil);
  icon.LoadFromStream(fStream);
  IconList.AddItem(cardinal(icon));
 end;

 fStream._Release;
end;

procedure LoadIcons;
begin
 LoadIconFromResource('icon1', RT_RCDATA);
 LoadIconFromResource('icon2', RT_RCDATA);
 LoadIconFromResource('icon3', RT_RCDATA);
end;

procedure FreeIcons;
var
 i : cardinal;
 icon : TICO;
begin
 for i := 1 to IconList.Count do
 begin
  icon := pointer(IconList.Items[i, 0]);
  if icon <> nil then icon._Release;
 end;
end;

initialization
 GetClipCursor(MouseLock.oldMouseRect);
 MouseLock.WindowHandle := 0;
 MouseLock.status := stDisable;
 
 ListObjectCreateEx(1*4, 0,  Flag_Can_Resize or
                     Flag_Can_Change_Lock_Flags or
                     Flag_Can_Add_Item, IconList);

 LoadIcons;

 fDLLHandle := LoadLibrary(pchar(LibStr));

 if fDLLHandle = 0 then
  ApplicationError('Не найдена библиотека : ' + LibStr, 'Ошибка', [aeHalt]);

 SetHook := GetProcAddress(fDLLHandle, 'SetHook');
 if not Assigned(SetHook) then
  ApplicationError('Не найдена точка входа в библиотеку : ' + 'SetHook', 'Ошибка', [aeHalt]);

 DelHook := GetProcAddress(fDLLHandle, 'DelHook');
 if not Assigned(DelHook) then
  ApplicationError('Не найдена точка входа в библиотеку : ' + 'DelHook', 'Ошибка', [aeHalt]);

 if not Assigned(DataArea) then
  ApplicationError('Программа допустила недопустимую операцию и будет закрыта' + LibStr, 'Ошибка', [aeHalt]);

 fillchar(DataArea^, sizeof(DataArea^), 0);
 DataArea^.WM_MYKEYHOOK := RegisterWindowMessage('KeyboardHook.A4B8F5F6-B117-4ADA-8186-0C2ADC12BBC5');
 DataArea^.WM_LOCK := RegisterWindowMessage('MouseLock.A4B8F5F6-B117-4ADA-8186-0C2ADC12BBC5');
 DataArea^.WM_UNLOCK := RegisterWindowMessage('MouseUnlock.A4B8F5F6-B117-4ADA-8186-0C2ADC12BBC5');

 DataArea^.LockKey[0] := 111;
 DataArea^.CountLockKey := 1;

 DataArea^.UnLockKey[0] := 106;
 DataArea^.CountUnLockKey := 1;

finalization
 Form1 := nil;
 MouseLock.UnLockMouse;
 if Assigned(DelHook) then DelHook;
 FreeLibrary(fDLLHandle);
 FreeIcons;
 IconList.Destroy;

end.

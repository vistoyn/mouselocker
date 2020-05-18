unit InitHook;

interface
uses
 Windows;

type
  PHookFunc = ^THookFunc;
  THookFunc = function (code: Integer; wparam: WPARAM; lparam: LPARAM): LRESULT; stdcall;

  PHookInfo = ^THookInfo;
  THookInfo = object
    MyAppWnd : THandle;     // Дескриптор окна приложения
    SysHook : THandle;      // Дескриптор ловушки
    WM_MYKEYHOOK, WM_LOCK, WM_UNLOCK : Cardinal;
    func : THookFunc;
    KeyState : array [0 .. 255] of byte;
    LockKey : array [0 .. 255] of byte;
    UnLockKey : array [0 .. 255] of byte;
    CountLockKey, CountUnLockKey : byte;

    LockEnable : LongBool;

    function CheckLock : boolean;
    function CheckUnLock : boolean;
  end;



var
  DataArea: PHookInfo = nil;
  hMapArea: THandle = 0;

implementation


function THookInfo.CheckLock : boolean;
var
 i : byte;
begin
 result := true;
 for i := 1 to DataArea^.CountLockKey do
  if DataArea^.KeyState[DataArea^.LockKey[i - 1]] = 0 then
  begin
   result := false;
   exit;
  end;
end;

function THookInfo.CheckUnLock : boolean;
var
 i : byte;
begin
 result := true;
 for i := 1 to DataArea^.CountUnLockKey do
  if DataArea^.KeyState[DataArea^.UnLockKey[i - 1]] = 0 then
  begin
   result := false;
   exit;
  end;
end;

{
 Ctrl + Shift + G
}

initialization
  hMapArea := CreateFileMapping(INVALID_HANDLE_VALUE, nil, PAGE_READWRITE, 0, SizeOf(THookInfo), '70E3E736-A65E-4898-814F-8F8EC3E7A3F4');
  if hMapArea = 0 then exit;

  DataArea := MapViewOfFile(hMapArea, FILE_MAP_ALL_ACCESS, 0, 0, 0);
  if not Assigned(DataArea) then
  begin
   CloseHandle(hMapArea);
   exit;
  end;

//  DataArea^.WM_MYKEYHOOK := RegisterWindowMessage('A4B8F5F6-B117-4ADA-8186-0C2ADC12BBC5');

finalization
  if Assigned(DataArea) then UnMapViewOfFile(DataArea);
  if hMapArea <> 0 then CloseHandle(hMapArea);

end.

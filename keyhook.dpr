library keyhook;

uses
  SysUtils,
  Classes,
  Windows,
  InitHook in 'InitHook.pas';

function KeyboardProc (code: Integer; wparam: WPARAM; lparam: LPARAM): LRESULT; stdcall;
var
 the_result : LRESULT;
begin
  result := 0;
  if (code >= 0) and (Assigned(DataArea)) and (wParam in [0 .. 255]) then
   begin
    if lparam >= 0 then DataArea^.KeyState[wParam] := 1 else DataArea^.KeyState[wParam] := 0;
    if DataArea^.MyAppWnd <> 0 then
     SendMessage(DataArea^.MyAppWnd, DataArea^.WM_MYKEYHOOK, wParam, lParam);

    if DataArea^.LockEnable then
    begin
     if DataArea^.CheckLock then
     begin
      SendMessage(DataArea^.MyAppWnd, DataArea^.WM_LOCK, 0, 0);
      result := 1;
     end
     else
      if DataArea^.CheckUnLock then
      begin
       SendMessage(DataArea^.MyAppWnd, DataArea^.WM_UNLOCK, 0, 0);
       result := 1;
      end;
    end;

   end;

  the_result := CallNextHookEx(DataArea^.SysHook, Code, wParam, lParam);

  if result = 0 then result := the_result;
end;

procedure SetHook; stdcall;
begin
 if not Assigned(DataArea) then exit;
 DataArea^.SysHook := SetWindowsHookEx(WH_KEYBOARD, KeyboardProc, hInstance, 0);
end;

procedure DelHook; stdcall;
begin
 if not Assigned(DataArea) then exit;
 UnhookWindowsHookEx(DataArea^.SysHook);
 DataArea^.SysHook := 0;
end;

exports SetHook, DelHook;

begin
end.


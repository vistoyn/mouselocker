unit Main;

interface

implementation
Uses Windows, Appl;

type
 PFirst = ^TFirst;
 TFirst = record
   ApplicationRuning : boolean;
 end;

var
  First  : PFirst = nil;
  hFirst : THandle = 0;
  err : boolean;

initialization
 hFirst := CreateFileMapping(INVALID_HANDLE_VALUE, nil, PAGE_READWRITE, 0, SizeOf(TFirst), 'MouseLocker.exe.2B929715-E926-4712-9486-28E29D9BAFDC');
 if hFirst = 0 then exit;

 First := MapViewOfFile(hFirst, FILE_MAP_ALL_ACCESS, 0, 0, 0);

 if First^.ApplicationRuning then
 begin
  err := true;
  ApplicationError('Программа уже запущена', 'MouseLocker.exe', [aeHalt]);
 end;

 err := false;
 First^.ApplicationRuning := true;


finalization
 if not err then First^.ApplicationRuning := false;
 if Assigned(First) then UnMapViewOfFile(First);
 if hFirst <> 0 then CloseHandle(hFirst);

end.

unit Horse.JsonDataObjects;

{$IF DEFINED(FPC)}
{$MODE DELPHI}{$H+}
{$ENDIF}

interface

uses
  Horse, Horse.Commons,
{$IF DEFINED(FPC)}
  SysUtils, Classes, HTTPDefs, fpjson, jsonparser;
{$ELSE}
  JsonDataObjects,
  System.Classes, System.SysUtils, Web.HTTPApp;
{$ENDIF}

type
{$IF DEFINED(FPC)}
  THorseJsonObject = TJsonData;
{$ELSE}
  THorseJsonObject = TJDOJsonObject;
{$ENDIF}

function HorseJsonDataObjects: THorseCallback; overload;
function HorseJsonDataObjects(const ACharset: string): THorseCallback; overload;

procedure Middleware(Req: THorseRequest; Res: THorseResponse; Next: {$IF DEFINED(FPC)}TNextProc{$ELSE}TProc{$ENDIF});

implementation

var
  Charset: string;

function HorseJsonDataObjects: THorseCallback; overload;
begin
  Result := HorseJsonDataObjects('UTF-8');
end;

function HorseJsonDataObjects(const ACharset: string): THorseCallback; overload;
begin
  Charset := ACharset;
  Result  := Middleware;
end;

procedure Middleware(Req: THorseRequest; Res: THorseResponse; Next: {$IF DEFINED(FPC)}TNextProc{$ELSE}TProc{$ENDIF});
var
  LJSON: THorseJsonObject;
begin
  if ({$IF DEFINED(FPC)} StringCommandToMethodType(Req.RawWebRequest.Method)
{$ELSE} Req.RawWebRequest.MethodType{$ENDIF} in [mtPost, mtPut]) and (Req.RawWebRequest.ContentType = 'application/json') then
  begin
    LJSON := {$IF DEFINED(FPC)} GetJSON(Req.Body) {$ELSE}TJSONObject.ParseUtf8(Req.Body) as TJDOJsonObject{$ENDIF};
    Req.Body(LJSON);
  end;
  try
    Next;
  finally
    if (Res.Content <> nil) and Res.Content.InheritsFrom({$IF DEFINED(FPC)}TJsonData{$ELSE}TJDOJsonBaseObject{$ENDIF}) then
    begin
{$IF DEFINED(FPC)}
      Res.RawWebResponse.ContentStream := TStringStream.Create(TJsonData(Res.Content).AsJSON);
{$ELSE}
      Res.RawWebResponse.Content := TJDOJsonBaseObject(Res.Content).ToUtf8JSON;
{$ENDIF}
      Res.RawWebResponse.ContentType := 'application/json; charset=' + Charset;
    end;
  end;
end;

end.

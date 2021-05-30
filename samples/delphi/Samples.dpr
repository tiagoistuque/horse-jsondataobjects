program Samples;

{$APPTYPE CONSOLE}

{$R *.res}

uses Horse, Horse.JsonDataObjects;

begin
  THorse.Use(HorseJsonDataObjects);

  THorse.Post('/ping',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    var
      LBody: THorseJsonObject;
    begin
      LBody := Req.Body<THorseJsonObject>;
      Res.Send<THorseJsonObject>(LBody);
    end);

  THorse.Listen(9000);
end.

unit uinv;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, mysql55conn, sqldb, FileUtil, Forms, Controls, Graphics,
  Dialogs, StdCtrls, DateUtils, IdHTTP, IdSSLOpenSSL, IniFiles, base64, BlowFish;

type
    TAct = (staah_check,staah_update,staah_get);

type

  { TForm1 }

  TForm1 = class(TForm)
    btStart: TButton;
    btStop: TButton;
    ckDirect: TCheckBox;
    ckRateCode: TCheckBox;
    http: TIdHTTP;
    IdSSLIOHandlerSocketOpenSSL1: TIdSSLIOHandlerSocketOpenSSL;
    Memo1: TMemo;
    mysql55: TMySQL55Connection;
    SQLQuery1: TSQLQuery;
    SQLTransaction1: TSQLTransaction;
    procedure btStartClick(Sender: TObject);
    procedure btStopClick(Sender: TObject);
    procedure ConnectDB;
    procedure FormActivate(Sender: TObject);
    function setAvailable(fmdt,todt:TDate;sRoomTyp:String): String;
    function FormatDateXML(dttm : TDateTime): String;
    function generateEcho(tp:String): String;
    function CountRoomAv(Tgl:String;RoomTp:String): Integer;
    procedure UpdateRoomInv(frdate,todate:TDate;staahroom:String);
    function GetDataInt(query,fieldnm: String) : Integer;
    function GetDataStr(query,fieldnm: String) : String;
    function ContactSiteMinder(act:TAct;txt: String): String;
    function DecryptString(aString:string):string;
  private
    { private declarations }
  public
    { public declarations }
    running : Boolean;
    fromdt,todt : TDate;
    roomid,sroomid : String;
    iRoomAv : Integer;
    echostr : String;
    id : Integer;
    sett : TStrings;
    tryagain : Boolean;
    g_tgl : TDate;
    g_roomtpcd : String;
    g_roomav : Integer;
<<<<<<< HEAD
    host,db,pass,mode : String;
    channel_user,channel_pass,channel_hotelid: String;
    port: Integer;
=======
>>>>>>> f10422416d3e1d889c98ea9eb07260cf0f1f170d
  end;

var
  Form1: TForm1;

const
     KUNCI = 'AsuKabeh';

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.ConnectDB;
var retry : Integer;
begin

  sett := TStringList.Create;
  try
<<<<<<< HEAD
    //sett.LoadFromFile('hostn.txt');

=======
    sett.LoadFromFile('hostn.txt');
>>>>>>> f10422416d3e1d889c98ea9eb07260cf0f1f170d
    tryagain := True;

    mysql55.HostName:= host;
    mysql55.UserName:= 'root';
<<<<<<< HEAD
    mysql55.Password:= pass;
    mysql55.DatabaseName:= db;
    mysql55.Port:=port;
=======
    mysql55.Password:= 'p3nd3kar';
    mysql55.DatabaseName:= sett.Strings[1];
>>>>>>> f10422416d3e1d889c98ea9eb07260cf0f1f170d

    retry := 0;

    while tryagain=True do begin

     try
       mysql55.Connected:=True;
       if mysql55.Connected=True then tryagain:=False;
     except
       Memo1.Lines.Add('retrying to connect...');
       Sleep(1000);
     end;
     retry := retry + 1;
     if retry=3 then begin
        ShowMessage('time out');
        Exit;
     end;

  end;

  finally
    sett.Free;
  end;


end;

procedure TForm1.FormActivate(Sender: TObject);
var au : String;
begin
  //sett := TStringList.Create;
  //try
  //   sett.LoadFromFile('hostn.txt');
  //   if sett.Strings[2]='1' then btStart.Click;
  //   Application.ProcessMessages;
  //finally
  //   sett.Free;
  //end;

   with TIniFile.Create('host.ini') do begin
         host := ReadString('default','host','localhost');
         db   := ReadString('default','db','emerald');
         pass := DecryptString(ReadString('default','code',''));
         port := ReadInteger('default','port',3306);
         mode := ReadString('default','mode','SM');
         au := ReadString('default','autostart','0');
         channel_user:= ReadString('channel','cuser','');
         channel_pass:= ReadString('channel','cpass','');
         channel_hotelid := ReadString('channel','chotelid','');
         Free;
    end;

<<<<<<< HEAD
   if mode='SM' then Form1.Caption:='SiteMinder Inventory'
   else if mode='BL' then Form1.Caption:='BookAndLink Inventory';

   if au='1' then btStart.Click;

end;

=======
>>>>>>> f10422416d3e1d889c98ea9eb07260cf0f1f170d
procedure TForm1.btStartClick(Sender: TObject);
var orifromdt : TDate;
    cmdstr: String;
    channelup : TSQLQuery;

begin

  ConnectDB;

  btStart.Enabled:=False;
  btStop.Enabled := True;

  running := True;

  while running do begin
    if running=False then Exit;
    if mysql55.Connected=False then ConnectDB;
    if Memo1.Lines.Count > 1000 then begin
       Memo1.Lines.Clear;
    end;

    channelup := TSQLQuery.Create(Self);
    channelup.DataBase := mysql55;

    if channelup.Active=True then channelup.Close;
    //channelupd.SQL.Text:='select min(fromdt) as fromdt,max(todt) as todt,roomtpcd from channelupd where processed=0 and roomtpcd<>'''' group by roomtpcd';
    channelup.SQL.Text:='select id,fromdt,todt,roomtpcd from channelupd where processed=0 and roomtpcd<>'''' and roomtpcd in (select sroomid from siteminder_roomid) order by fromdt,id';
    //Memo1.Lines.Add(channelup.SQL.Text);
    channelup.Open;
    channelup.First;
    while not channelup.EOF do begin
      Application.ProcessMessages;
      if running=False then Exit;
      id := channelup.FieldByName('id').AsInteger;
      fromdt := channelup.FieldByName('fromdt').AsDateTime;
      orifromdt := fromdt;
      todt   := channelup.FieldByName('todt').AsDateTime;
      roomid := channelup.FieldByName('roomtpcd').AsString;
      Application.ProcessMessages;


      UpdateRoomInv(fromdt,todt,roomid);


      channelup.Next;
      //cmdstr := 'update channelupd set processed=1 where roomtpcd='+QuotedStr(roomid);

      // ===> PINDAH DI BAGIAN BAWAH
      //cmdstr := 'update channelupd set processed=1 where id='+IntToStr(id);
      //mysql55.ExecuteDirect(cmdstr);
      //SQLTransaction1.CommitRetaining;

    end;
    Application.ProcessMessages;


    Sleep(5000);
    Memo1.Lines.Add(FormatDateTime('yyyy-mm-dd hh:nn:ss',Now)+' -- no data');

    if Memo1.Lines.Count=100 then begin
       Memo1.Lines.Clear;
       end;
    channelup.Close;
    channelup.Free;

    mysql55.Close();


  end;
end;

procedure TForm1.btStopClick(Sender: TObject);
begin
  btStart.Enabled:=True;
  btStop.Enabled := False;

  running := False;
  Application.ProcessMessages;

end;

function TForm1.setAvailable(fmdt,todt:TDate;sRoomTyp:String): String;
var filenm : String;
    strlist : TStrings;
    newtxt : String;
    c : Integer;
begin

  strlist := TStringList.Create;
  filenm := 'xml/HotelAvailNotifRQ.xml';
  strlist.LoadFromFile(filenm);

  newtxt := strlist.Text;
  newtxt := StringReplace(newtxt,'time-xxx',FormatDateXML(Now),[rfIgnoreCase,rfReplaceAll]);
  echostr := generateEcho('e');
  newtxt := StringReplace(newtxt,'echo-xxx',echostr,[rfIgnoreCase,rfReplaceAll]);
  newtxt := StringReplace(newtxt,'start-xxx',FormatDateTime('yyyy-mm-dd',fmdt),[rfIgnoreCase,rfReplaceAll]);
  newtxt := StringReplace(newtxt,'end-xxx',FormatDateTime('yyyy-mm-dd',todt),[rfIgnoreCase,rfReplaceAll]);
  newtxt := StringReplace(newtxt,'room-xxx',sRoomTyp,[rfIgnoreCase,rfReplaceAll]);
  newtxt := StringReplace(newtxt,'user-xxx',channel_user,[rfIgnoreCase,rfReplaceAll]);
  newtxt := StringReplace(newtxt,'pass-xxx',channel_pass,[rfIgnoreCase,rfReplaceAll]);
  newtxt := StringReplace(newtxt,'hotelid-xxx',channel_hotelid,[rfIgnoreCase,rfReplaceAll]);


  if ckRateCode.Checked then begin
     newtxt := StringReplace(newtxt,'rate-xxx','RatePlanCode="'+sRoomTyp+'"',[rfIgnoreCase,rfReplaceAll]);
  end
  else begin
     newtxt := StringReplace(newtxt,'rate-xxx','',[rfIgnoreCase,rfReplaceAll]);
  end;

  iRoomAv := CountRoomAv(FormatDateTime('yyyy-mm-dd',fmdt),sRoomTyp);

  c := GetDataInt('select count(*) as cnt from siteminder_roomav where '+
                  ' roomcd='+QuotedStr(sRoomTyp)+
                  ' and fromdt <='+QuotedStr(FormatDateTime('yyyy-mm-dd',fmdt))+
                  ' and todt > '+QuotedStr(FormatDateTime('yyyy-mm-dd',fmdt))+
                  ' and active=1','cnt');

  if c > 0 then begin
     iRoomAv := GetDataInt('select qty as cnt from siteminder_roomav where '+
                  ' roomcd='+QuotedStr(sRoomTyp)+
                  ' and fromdt <='+QuotedStr(FormatDateTime('yyyy-mm-dd',fmdt))+
                  ' and todt > '+QuotedStr(FormatDateTime('yyyy-mm-dd',fmdt))+
                  ' and active=1','qty');
  end;

  newtxt := StringReplace(newtxt,'book-xxx',IntToStr(iRoomAv),[rfIgnoreCase,rfReplaceAll]);
  g_tgl:=fmdt;
  g_roomav:=iRoomAv;
  g_roomtpcd:=sRoomTyp;
  Result := newtxt;



end;

function TForm1.FormatDateXML(dttm : TDateTime): String;
var str1,str2: String;
begin
  //
  str1 := FormatDateTime('yyyy-mm-dd',dttm);
  str2 := FormatDateTime('hh:nn:ss',dttm);
  Result := str1+'T'+str2+'+07:00';

end;

function TForm1.generateEcho(tp:String): String;
begin
  //
  Result := tp+FormatDateTime('yyyymmddhhnnsszzz',Now);
end;

function TForm1.CountRoomAv(Tgl:String;RoomTp:String): Integer;
var currdt : TDate;
    IH,EA,ED,TotRoom,FO,M,Grp,Allot : Smallint;
    strcmd : String;
begin

  //menghitung room available

  try

    //menghitung total kamar untuk Room Type tertentu



    TotRoom := GetDataInt('select roomtot from fosroomtype where roomtpcd='+QuotedStr(RoomTp),'roomtot');

    //menghitung InHouse (semua yang Reg sampai tanggal hari ini)

    strcmd := 'select count(a.rsvno) as IH' +
                                ' from fofrsv a,fosroom b,fosroomtype c' +
                                ' where a.roomno <> '''''+
                                ' and a.roomno=b.roomno' +
                                ' and b.roomtpcd=c.roomtpcd' +
                                ' and a.rsvst=''R''' +
                                ' and a.arrdt <= ' + QuotedStr(Tgl) + ' and a.depdt >= ' + QuotedStr(Tgl) +
                                ' and c.roomtpcd='+QuotedStr(RoomTp);

    IH := GetDataInt(strcmd,'IH');

    //menghitung EA
    strcmd := 'select count(a.rsvno) as EA' +
                                ' from fofrsv a,fosroom b,fosroomtype c' +
                                ' where a.roomno <> '''''+
                                ' and a.roomno=b.roomno' +
                                ' and b.roomtpcd=c.roomtpcd' +
                                ' and a.rsvst=''D''' +
                                ' and a.arrdt = ' + QuotedStr(Tgl) +
                                ' and c.roomtpcd=' + QuotedStr(RoomTp);


    EA := GetDataInt(strcmd,'EA');

    //menghitung ED

    strcmd := 'select count(a.rsvno) as ED' +
                                ' from fofrsv a,fosroom b,fosroomtype c' +
                                ' where a.roomno <> '''''+
                                ' and a.roomno=b.roomno' +
                                ' and b.roomtpcd=c.roomtpcd' +
                                ' and a.rsvst=''R''' +
                                ' and a.depdt = ' + QuotedStr(Tgl) +
                                ' and c.roomtpcd=' + QuotedStr(RoomTp);

    ED := GetDataInt(strcmd,'ED');

    //menghitung Forecast Occ

    strcmd := 'select count(distinct a.rsvno) as FO' +
                                ' from fofrsv a,fosroom b' +
                                ' where a.rsvst in (''R'',''D'',''T'')' +
                                ' and a.arrdt <= '+ QuotedStr(Tgl)+ ' and a.depdt > '+QuotedStr(Tgl) +
                                ' and a.roomtpcd='+QuotedStr(RoomTp)+
                                ' and a.rsvtp in (''1'',''3'',''4'')';//uncomment 18/09/14+      // add 30/01
                                //' group by rsvno';           //remove 18/09/14


    FO := GetDataInt(strcmd,'FO');

    strcmd := 'select count(roomno) as cnt' +
                                ' from fofroommaint' +
                                ' where fromdt <= ' + QuotedStr(Tgl) + ' and todt > '+QuotedStr(Tgl) +
                                ' and todt<>'+QuotedStr(Tgl)+
                                ' and roomtpcd='+QuotedStr(RoomTp);


    M := GetDataInt(strcmd,'cnt');


    strcmd := 'select ifnull(sum(qtyblc),0) as qtyblock' +
                                ' from fofgrpblc' +
                                ' where roomtpcd='+QuotedStr(RoomTp)+
                                ' and trdt='+QuotedStr(Tgl)+
                                ' group by roomtpcd';



    Grp := GetDataInt(strcmd,'qtyblock');


    strcmd := 'select ifnull(qtyblc,0) as qtyblc' +
                                ' from fofallotment ' +
                                ' where trdt = ' + QuotedStr(Tgl)+
                                ' and roomtpcd='+QuotedStr(RoomTp);
    Allot := GetDataInt(strcmd,'qtyblc');






  finally

  end;

  Result := TotRoom-FO-M-Grp-Allot;
  if Result < 0 then Result := 0;



end;

procedure TForm1.UpdateRoomInv(frdate,todate:TDate;staahroom:String);
var xmlstr : AnsiString;
    res,res2: String;
    cmdstr : String;
    arrdt,depdt : String;
    pos : Integer;
begin

  Memo1.Lines.Clear;

  while frdate <= todate do begin
        arrdt := FormatDateTime('yyyy-mm-dd',frdate);
        depdt := arrdt;
        sroomid := staahroom;
        xmlstr:= setAvailable(frdate,frdate,staahroom); //MakeJSON;

        Memo1.Lines.Add(FormatDateTime('yyyy-mm-dd hh:nn:ss',Now)+' -- updating room type :'+sroomid+', date :'+arrdt+', qty :'+ IntToStr(iRoomAv));
        //Memo1.Lines.Add(xmlstr);;


        if ckDirect.Checked = True then begin;
        // TADINYA LANGSUNG KIRIM KE SITEMINDER

        res := '';
        res := ContactSiteMinder(staah_update,xmlstr);
        pos := AnsiPos('Success',res);

        if pos <> 0 then begin
           Memo1.Lines.Add('Success');
           cmdstr := 'update channelupd set processed=1,ref='+QuotedStr(echostr)+' where id='+IntToStr(id);
           mysql55.ExecuteDirect(cmdstr);
           SQLTransaction1.CommitRetaining;
        end;

        end

        else begin

        // SEKARANG MASUK ANTRIAN AJA



        cmdstr := 'insert into xmlchain (xmlstr,typ,roomtpcd,roomav,roomdt) values ('+QuotedStr(xmlstr)+
                  ','+QuotedStr('A')+
                  ','+QuotedStr(g_roomtpcd)+
                  ','+IntToStr(g_roomav)+
                  ','+QuotedStr(FormatDateTime('yyyy-mm-dd',g_tgl))+
                  ')';

        mysql55.ExecuteDirect(cmdstr);
        SQLTransaction1.CommitRetaining;

        cmdstr := 'update channelupd set processed=1 where id='+IntToStr(id);
        mysql55.ExecuteDirect(cmdstr);
        SQLTransaction1.CommitRetaining;

        end;



        //res2 := decode(staah_update,res);

        //Memo1.Lines.Add(res2);

        //cmdstr := 'insert into staah_updatelog (jsonstr,status) '+
        //          ' values ('+QuotedStr(xmlstr)+
        //          ','+QuotedStr(res)+
        //          ')';
        //mysql55.ExecuteDirect(cmdstr);

        frdate := frdate + 1;
        Sleep(100);
        Application.ProcessMessages;
  end;
  SQLTransaction1.CommitRetaining;
  if Memo1.Lines.Count=1000 then begin;
     Memo1.Lines.SaveToFile('staah-inv-'+FormatDateTime('yyyymmddhhnnss',Now)+'.txt');
  end;
end;

function TForm1.GetDataInt(query,fieldnm: String) : Integer;
var data : TSQLQuery;
begin
  try
    data := TSQLQuery.Create(nil);

    try
      data.Database := mysql55;
      data.SQL.Text := query;
      try
         data.Open;

      except
        ConnectDB;
      end;
      if data.RecordCount > 0 then
        Result := data.FieldByName(fieldnm).AsInteger
      else
        Result := 0;
    finally
      data.Free;
    end;
  except
    on E: Exception do begin
      ShowMessage('Error 1003: '+E.ClassName + ' ' + E.Message);

    end;
  end;

end;

function TForm1.GetDataStr(query,fieldnm: String) : String;
var data : TSQLQuery;
begin
  try
    data := TSQLQuery.Create(nil);

    try
      data.Database := mysql55;
      data.SQL.Text := query;
      data.Open;
      if data.RecordCount > 0 then
        Result := data.FieldByName(fieldnm).AsString
      else
        Result := '';
    finally
      data.Free;
    end;
  except
    on E: Exception do begin
      ShowMessage('Error 1003: '+E.ClassName + ' ' + E.Message);
    end;
  end;

end;

function TForm1.ContactSiteMinder(act:TAct;txt: String): String;
var jsontosend : TStringStream;
        sResponse: String;
begin
  sResponse := '';
  JsonToSend := TStringStream.Create(Utf8Encode(txt)); // D2007 and earlier only
  //in D2009 and later, use this instead:
  //JsonToSend := TStringStream.Create(Json, TEncoding.UTF8);
  try
    http.Request.ContentType := 'text/xml';
    http.Request.AcceptCharSet := 'utf-8';
    http.ReadTimeout := 5000;

    try
       if act=staah_update then
          //sResponse := http.Post('https://cmtpi.siteminder.com/pmsxchangev2/services/EMERALD', JsonToSend);
          sResponse := http.Post('https://ws-apac.siteminder.com/pmsxchangev2/services/EMERALD', JsonToSend);
       if act=staah_get then
          sResponse := http.Post('https://emerald.staah.net/common-cgi/Booking.pl',jsontosend);
    except
      on E: Exception do begin
        Memo1.Lines.Add('Error on request: '#13#10 + e.Message);
        //SendEmail(False,e.Message);
      end;
    end;
  finally
    JsonToSend.Free;
  end;

  Result := sResponse;


end;

function TForm1.DecryptString(aString:string):string;
var Key:string;
    DecrytpStream:TBlowFishDeCryptStream;
    StringStream:TStringStream;
    DecryptedString:string;
begin
  Key := KUNCI;
  StringStream := TStringStream.Create(DecodeStringBase64(aString));
  DecrytpStream := TBlowFishDeCryptStream.Create(Key,StringStream);
  DecryptedString := DecrytpStream.ReadAnsiString;
  DecrytpStream.Free;
  StringStream.Free;
  Result := DecryptedString;
end;

end.


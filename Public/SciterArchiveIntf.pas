{*******************************************************************************
 ����:     SciterArchiveIntf.pas
 ����:     sciter�Դ��Ĵ����Դ�Ľ������� �ӿڵ�Ԫ
 ����ʱ�䣺2015-02-07
 ���ߣ�    gxlmyacc
 ******************************************************************************}
unit SciterArchiveIntf;

interface

uses
  SysUtils, Windows, SciterTypes;

type
  PISciterArchive = ^ISciterArchive;
  ISciterArchive = interface
  ['{6F79A531-225D-409A-9BFD-2337DEA992C7}']
    function GetActive: Boolean;
    function GetHandle: HSARCHIVE;
    function GetHandleOwner: Boolean;
    procedure SetHandle(const Value: HSARCHIVE);
    procedure SetHandleOwner(const Value: Boolean);
    
    // open archive blob:
    function  Open(data: LPCBYTE; dataLen: UINT; dataCanWrite: Boolean = False): Boolean; overload;
    function  Open(const filename: SciterString): Boolean; overload;
    procedure Close();

    // get archive item:
    function Get(path: LPCWSTR; var data: LPCBYTE; var data_length: UINT): Boolean;

    property Active: Boolean read GetActive;
    property Handle: HSARCHIVE read GetHandle write SetHandle;
    property HandleOwner: Boolean read GetHandleOwner write SetHandleOwner;
  end;

function SciterArchive: PISciterArchive;

implementation

uses
  SciterImportDefs;

function SciterArchive: PISciterArchive;
type
  TSciterArchive = function : PISciterArchive;
begin
  Result := TSciterArchive(SciterApi.Funcs[FuncIdx_SciterArchive]);
end;

end.

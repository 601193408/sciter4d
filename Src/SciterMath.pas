{*******************************************************************************
 ����:     SciterHash.pas
 ����:     Sciter4D��ʹ�õļ��㺯����Ԫ
 ����ʱ�䣺2015-05-07
 ���ߣ�    gxlmyacc
 ******************************************************************************}
unit SciterMath;

interface

function Max(const A, B: Integer): Integer;


implementation

function Max(const A, B: Integer): Integer;
begin
  if A > B then
    Result := A
  else
    Result := B;
end;


end.

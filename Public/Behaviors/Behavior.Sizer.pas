{*******************************************************************************
 ����:     Behavior.Sizer.pas
 ����:     �ߴ�ɵ��� ��Ϊ
 ����ʱ�䣺2015-02-07
 ���ߣ�    gxlmyacc
 ******************************************************************************}
unit Behavior.Sizer;

interface

uses
  Windows, SysUtils, SciterIntf, SciterTypes, SciterBehavior;

type
  TSizerBehavior = class(TBehaviorEventHandler)
  private
		tracking: Boolean;
    delta: TSize;
  protected
    function  OnSubscription(const he: IDomElement; var event_groups: UINT{EVENT_GROUPS}): Boolean; override;
    //����ģʽ(�¼����´��ݽ׶�)��������
    function  OnMouseDown(const he, target: IDomElement; event_type: UINT; pt: TPoint; mouseButtons, keyboardStates: UINT; var params: TMouseParams): Boolean; override;
    function  OnMouseMove(const he, target: IDomElement; event_type: UINT; pt: TPoint; mouseButtons, keyboardStates: UINT; var params: TMouseParams): Boolean; override;
    function  OnMouseUp(const he, target: IDomElement; event_type: UINT; pt: TPoint; mouseButtons, keyboardStates: UINT; var params: TMouseParams): Boolean; override;
  end;

implementation

uses
  SciterMath;
  
{ TSizerBehavior }

function TSizerBehavior.OnMouseDown(const he, target: IDomElement;
  event_type: UINT; pt: TPoint; mouseButtons, keyboardStates: UINT;
  var params: TMouseParams): Boolean;
var
  rc: TRect;
begin
  Result := False;
  if not IsBubbling(event_type) then
    Exit;

  if not tracking then
  begin
    if params.is_on_icon and (mouseButtons = MAIN_MOUSE_BUTTON) then
    begin
      // icon - foreground-image/foreground-repeat:no-repeat is serving role of gripper
      tracking := True;
      rc := he.GetLocation(SELF_RELATIVE or CONTENT_BOX);
      
      delta.cx := rc.right  - pt.X;
      delta.cy := rc.Bottom - pt.Y;

      he.SetCapture;

      Result := True; // handled
    end;
  end;
end;

function TSizerBehavior.OnMouseMove(const he, target: IDomElement;
  event_type: UINT; pt: TPoint; mouseButtons, keyboardStates: UINT;
  var params: TMouseParams): Boolean;
var
  w, h: Integer;
begin
  Result := False;
  if not IsBubbling(event_type) then
    Exit;

  if not tracking then
    Exit;

  w := Max(0, pt.x + delta.cx);
	h := Max(0, pt.y + delta.cy);
			 
  if he.Attributes['resize'] <> 'vertical' then
    he.style['width'] := IntToStr(w);

  if he.Attributes['resize'] <> 'horizontal' then
    he.style['height'] := IntToStr(h);

  Result := True; // handled
end;

function TSizerBehavior.OnMouseUp(const he, target: IDomElement;
  event_type: UINT; pt: TPoint; mouseButtons, keyboardStates: UINT;
  var params: TMouseParams): Boolean;
begin
  Result := False;
  if not IsBubbling(event_type) then
    Exit;

  if not tracking then
    Exit;
    
  he.ReleaseCapture;
  tracking := False;
  
  Result := True;
end;

function TSizerBehavior.OnSubscription(const he: IDomElement;
  var event_groups: UINT): Boolean;
begin
  event_groups := HANDLE_MOUSE;
  Result := True;
end;


initialization
  BehaviorFactorys.Reg(TBehaviorFactory.Create('sizer', TSizerBehavior));

finalization
  BehaviorFactorys.UnReg('sizer');

end.

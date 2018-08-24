{*******************************************************************************
 ����:     Behavior.Dragable.pas
 ����:     ���϶� ��Ϊ
 ����ʱ�䣺2015-02-07
 ���ߣ�    gxlmyacc
 ******************************************************************************}
unit Behavior.Dragable;

interface

uses
  Windows, Classes, SysUtils, SciterIntf, SciterTypes, SciterBehavior;

type
(*
  BEHAVIOR: draggable
     goal: Ԫ�ؿ��϶���Ϊ
  VIEWS:
      ________________________________________________
     |     _________________________                 |
     |    |    ����Ԫ��            |                 |
     |    |    _____________       |                 |
     |    |   |            |       |     body        |
     |    |   | ���϶�Ԫ�� |       |                 |
     |    |   |____________|       |                 |
     |    |________________________|                 |
     |_______________________________________________|
  COMMENTS:
      <html>
        <body>
          <div.container style="positon:relative|absolute|fixed;">
            <div style="behavior:draggable" draggable="both|horizontal|vertical" drag-margin="5 5 5 5" dragmode="auto|attached-window|detached-window" />
          </div>
      </html>
  NOTE:
    1�������϶�Ԫ�ء������ڡ�����Ԫ�ء��ڲ�������϶����ƶ�λ�ã�
    2�������϶�Ԫ�ء�����ͨ����draggable�����������������϶��ķ���
         both:        ˫���϶�
         horizontal:  �����϶�
         vertical:    �����϶�
    3�������϶�Ԫ�ء�����ͨ����drag-margin�������������ڡ�����Ԫ�ء��б��϶������Χ����ʽΪ���� �� �� �󡿣�
         ���硾drag-margin="5 5 5 5"���ĺ����ǣ������϶�Ԫ�ء������ɡ�����Ԫ�ء��ı߽����5���ص�λ����ɵľ������϶���
    4��������Ԫ�ء�ָ���������϶�Ԫ�ء�����������ʽ�а�����positon:relative|absolute|fixed;����Ԫ�أ�
         ���û��������Ԫ�أ�������Ԫ�ء�Ϊ��ҳ�ĸ�Ԫ��,��HTMLԪ�ء�
    5�������϶�Ԫ�ء��е�dragmode����ָ���϶�ģʽ��֧������ģʽ��
         ��:                      ͨ���ƶ�Ԫ�ص�left��top�������϶�Ԫ��
         auto:                    ���Ԫ���ƶ�����ͼ���潫�ᴴ�����ڡ����Ԫ������ͼ�������ᱻ��ȾΪpopup:fixed
         attached-window:         ǿ������Ϊ��Ԫ�ش���һ���������ڡ��ô��ں�������������(��ͼ)��ͬ���ƶ���
         detached-window:         ǿ������Ϊ��Ԫ�ش����������ڣ���Ԫ�صĴ���λ�ö�����������������
         detached-topmost-window: ��#detached-window��ͬ�������Ǵ���������ڲ��ϡ� 
*)

  TDragableBehavior = class(TBehaviorEventHandler)
  private
		dragMarginTop: Integer;
    dragMarginRight: Integer;
    dragMarginBottom: Integer;
    dragMarginLeft: Integer;
    view: IDomElement;
    dx, dy: Integer;
    mode: IDomValue;
  protected
    function  OnSubscription(const he: IDomElement; var event_groups: UINT{EVENT_GROUPS}): Boolean; override;
    procedure OnAttached(const he: IDomElement); override;
    function  OnMouseDown(const he, target: IDomElement; event_type: UINT; var params: TMouseParams): Boolean; override;
    function  OnMouseMove(const he, target: IDomElement; event_type: UINT; var params: TMouseParams): Boolean; override;
    function  OnMouseUp(const he, target: IDomElement; event_type: UINT; var params: TMouseParams): Boolean; override;
  end;
  
implementation

uses
  SciterFactoryIntf;

{ TDragableBehavior }

procedure TDragableBehavior.OnAttached(const he: IDomElement);
var
  dragMargin, position, sMode: SciterString;
  t: array of Integer;
  ls: TStringList;
  i: Integer;
  ltView: IDomElement;
begin
  he.Style['position'] := 'absolute';
  dragMargin := he.Attributes['drag-margin'];
  if dragMargin = EmptyStr then
    dragMargin := he.Style['drag-margin'];

  if dragMargin <> EmptyStr then
  begin
    ls := TStringList.Create;
    try
      ls.Delimiter := ' ';
      ls.DelimitedText := dragMargin;

      for i := ls.Count - 1 downto 0 do
        if ls[i] = '' then
          ls.Delete(i);

      if ls.Count > 0 then
      begin
        SetLength(t, ls.Count);
        for i := 0 to ls.Count - 1 do
          t[i] := StrToIntDef(ls[i], 0);

        if t[0] > 0 then
        begin
          dragMarginTop := t[0];
          if Length(t) < 2 then
            dragMarginRight := t[0]
          else
            dragMarginRight := t[1];
          if Length(t) < 3 then
            dragMarginBottom := t[2]
          else
            dragMarginBottom := dragMarginTop;
          if Length(t) < 4 then
            dragMarginLeft := t[3]
          else
            dragMarginLeft := dragMarginRight;
        end;
      end;
    finally
      ls.Free;
    end;   
  end;

  sMode := he.Attributes['drag-mode'];
  if (sMode <> '') and (sMode <> 'none') then
    mode := ValueFactory.MakeSymbol(sMode)
  else
    mode := nil;

  ltView := he.Parent;
  while ltView <> nil do
  begin
    position := ltView.Style['position'];
    if (position='relative') or (position='absolute') or (position='fixed') then
    begin
      view := ltView;
      break;
    end;
    ltView := ltView.Parent;
  end;
  if view = nil then
    view := he.Root;
end;

function NotDraggable(const target: IDomElement): Boolean;
var
  sTag: SciterString;
begin
  sTag := WideLowerCase(target.Tag);
  Result := (sTag = 'a') or (sTag = 'select') or (sTag = 'input') or (sTag = 'button')
    or (sTag = 'checkbox') or target.HasAttribute('no-drag');
end;

function TDragableBehavior.OnMouseDown(const he, target: IDomElement;
  event_type: UINT; var params: TMouseParams): Boolean;
var
  sDragable: string;
begin
  Result := False;
  if not IsBubbling(event_type) then
    Exit;

  if params.button_state = MAIN_MOUSE_BUTTON then
  begin
    sDragable := he.Attributes['draggable'];
    if (sDragable = '') or (sDragable = 'none') or NotDraggable(target) then
      Exit;

    he.SetCapture;
    dx := params.pos.X;
    dy := params.pos.Y;

    he.ChangeState(STATE_MOVING);
    he.SendEvent(UI_STATE_CHANGED);
    he.Update(True);
  end;
end;

function TDragableBehavior.OnMouseMove(const he, target: IDomElement;
  event_type: UINT; var params: TMouseParams): Boolean;
var
  rcWnd, rc: TRect;
  pos: TPoint;
  sDragable: string;
begin
  Result := False;
  if not IsBubbling(event_type) then
    Exit;

  if (params.button_state = MAIN_MOUSE_BUTTON) and he.TestState(STATE_MOVING) then
  begin
    sDragable := he.Attributes['draggable'];
    if (sDragable = '') or (sDragable = 'none') then
      Exit;
    if view = nil then
      Exit;

    pos.x := params.pos_view.X - dx;
    pos.y := params.pos_view.Y - dy;

    if dragMarginTop <> 0 then
    begin
      rcWnd := view.GetLocation(VIEW_RELATIVE or MARGIN_BOX);
      rc    := he.GetLocation(VIEW_RELATIVE or MARGIN_BOX);
      
      if (sDragable = 'both') or (sDragable = 'horizontal') then
      begin
        if pos.x <= (rcWnd.Left + dragMarginLeft) then
          pos.x := rcWnd.Left + dragMarginLeft
        else
        if (pos.x+rc.Right-rc.Left) > (rcWnd.Right-dragMarginRight) then
          pos.X := rcWnd.Right - dragMarginRight - (rc.Right - rc.Left);
      end;

      if (sDragable = 'both') or (sDragable = 'vertical') then
      begin
        if pos.y <= (rcWnd.Top + dragMarginTop) then
          pos.y := rcWnd.top + dragMarginTop
        else
        if (pos.y+rc.Bottom-rc.Top) > (rcWnd.bottom-dragMarginBottom) then
          pos.y := rcWnd.bottom - dragMarginBottom - (rc.Bottom - rc.top);
      end;
    end;

    if mode = nil then
    begin
      if (sDragable = 'both') or (sDragable = 'horizontal') then
        he.Style['left'] := IntToStr(pos.X-rcWnd.Left);
      if (sDragable = 'both') or (sDragable = 'vertical') then
        he.Style['top'] := IntToStr(pos.Y-rcWnd.Top);
    end
    else
    begin
      he.CallMethod('move', [
        ValueFactory.Create(pos.X),
        ValueFactory.Create(pos.Y),
        ValueFactory.MakeSymbol('#view'),
        mode
        ]);
    end;
  end;
end;

function TDragableBehavior.OnMouseUp(const he, target: IDomElement;
  event_type: UINT; var params: TMouseParams): Boolean;
begin
  Result := False;
  if not IsBubbling(event_type) then
    Exit;
  if (params.button_state = MAIN_MOUSE_BUTTON) and he.TestState(STATE_MOVING) then
  begin
    he.ReleaseCapture;
    he.ClearState(STATE_MOVING);
    he.SendEvent(UI_STATE_CHANGED);
    he.Update(True);
  end;                        
end;

function TDragableBehavior.OnSubscription(const he: IDomElement;
  var event_groups: UINT): Boolean;
begin
  event_groups := HANDLE_INITIALIZATION or HANDLE_MOUSE;
  Result := True;
end;


initialization
  BehaviorFactorys.Reg(TBehaviorFactory.Create('draggable', TDragableBehavior));

finalization
  BehaviorFactorys.UnReg('draggable');

end.

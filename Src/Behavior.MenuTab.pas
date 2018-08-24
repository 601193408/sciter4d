{*******************************************************************************
 ����:     Behavior.MenuTab.pas
 ����:     ��ǩҳ ��Ϊ
 ����ʱ�䣺2015-02-07
 ���ߣ�    gxlmyacc
 ******************************************************************************}
unit Behavior.MenuTab;

interface

uses
  SysUtils, Windows, SciterIntf, SciterTypes, SciterBehavior;

type
  (*

  BEHAVIOR: menutab
     goal: menutab��Ϊ��ʵ�֣�����һ��Tab��ǩҳ��Ϊ
  VIEWS:
     | ��ǩ1 | ��ǩ2 | ��ǩ3 |
     -------------------------
     |                       |
     |          ���         |
     |                       |
     |_______________________|
  COMMENTS:
      <ul>
         <li href|target="panel-name1" style="behavior:menutab" group="groupDemo" selected >��ǩ1</li>
         <li href|target="panel-name2" style="behavior:menutab" group="groupDemo" >��ǩ2</li>
         <li href|target="panel-name3" style="behavior:menutab" group="groupDemo" noselect>��ǩ3</li>
         <li href|target="panel-name4" style="behavior:menutab" group="groupDemo" onselect="execSomeFunc(this);">��ǩ3</li>
         <li href|target="panel-name5" style="behavior:menutab" group="groupDemo" onselected="afterSelect(this);">��ǩ4</li>
         <li href|target="panel-name6" style="behavior:menutab" group="groupDemo" trigger="hover" >��ǩ4</li>
      </ul>
      <div>
        <div name="panel-name1" group="groupDemo" > ���1 </div>
        <div name="panel-name2" group="groupDemo" alwaysload > ���2 </div>
     </div>
  NOTE:
     1�� ���һ��ҳ�����ж������ǩ��ʹ���ˡ�menutab����Ϊ����ͬ�ġ���ǩ����Ҫʹ�á�group�����з��飻
     2�� ����ǩ��Ԫ���еġ�href������ָ�����������ǩ��ʱ��ʾ�ġ���塿Ԫ��;
     3��  ������selected�����Եġ���ǩ��Ԫ�أ���ʾ��ʼ��ҳ��ʱĬ��ѡ�еġ���ǩ����Ĭ����ʾ�ġ���塿;
     4�� ����ǩ���͡���塿Ԫ�ص�λ�ÿ�������ţ�����Ϊ�Ĳ��ҹ�������html��Ԫ�����ң������ܳ���һ��ҳ�棻
     5�� �����ڽű��е��á�selectTab��������ѡ�иá���ǩ�������硾el.selectTab()����
     6�� ָ���ˡ�alwaysload�����Եġ���塿Ԫ����ÿ��ѡ�񡾱�ǩ��ʱ�������¼��ء���塿�����ݣ�
     7�� ָ���ˡ�noselect�����Եġ���ǩ�������ǲ�����¡���塿Ԫ�����ݣ���ʱ�û����ԶԸá���ǩ����onClick�¼����д���
     8�� �������ǩ����name���ԣ���ѡ�иá���ǩ��ʱ�Ὣ����ǩ����name��group����ֵ�ֱ�д������塿Ԫ�صġ�menu-name����menu-group�������ϣ�
     9�� ��ѡ�С���ǩ1��ʱ������ǩ1��.state�����ӡ�expand��״̬��ͬʱ������expand���¼���
     10��������ǩ1������ѡ��ʱ��expand��״̬��ȥ����ͬʱ��ӡ�collapsed��״̬, ͬʱ������collapsed���¼���
     11����ѡ�С���ǩ1��ʱ�������1����ʾ�����ӡ�activechild��״̬��ͬʱ������statechange���¼���
     12���������ǩ1����onselect���ԣ�����ѡ��ñ�ǩǰ����onselect��ֵ��Ϊһ�����ʽ��ִ�У�������ʽ����true,�����л�����塿���ݣ�
     13���������ǩ1����onselected���ԣ����ڡ����1�����ݳɹ��ı��onselected��ֵ��Ϊһ�����ʽ��ִ�У�����������¼�����һЩɨβ������
     14���������ǩ1����trigger���ԣ���ֵΪhover����ñ�ǩҳ����ͨ�����������ģ����ǵ�������ñ�ǩҳʱ�����
  *)
  TMenuTabBehavior = class(TBehaviorEventHandler)
  private
    FGroup: SciterString;
    FElement: HELEMENT;
  protected
    function  OnSubscription(const he: IDomElement; var event_groups: UINT{EVENT_GROUPS}): Boolean; override;
    procedure OnAttached(const he: IDomElement); override;
    procedure OnDetached(const he: IDomElement); override;
    function  OnMouseClick(const he, target: IDomElement; event_type: UINT; var params: TMouseParams): Boolean; override;
    function  OnMouseEnter(const he, target: IDomElement; event_type: UINT; var params: TMouseParams): Boolean; override;
  published
    function selectTab: Boolean;
  end;

function _GetTargetName(const he: IDomElement): SciterString;
function _GetSelectedElement(const he: IDomElement; const AGroup: SciterString): IDomElement;
function _MenuTabLoadFrame(const he, target: IDomElement): Boolean;
function _MenuTabSelectTab(const he: IDomElement; const AGroup: SciterString;
  const doAnimation: Boolean = True): Boolean;

implementation

uses
  SciterFactoryIntf, SciterApiImpl;

const
  Trigger_Click = 'click';
  Trigger_Hover = 'hover';

{ TMenuTabBehavior }

function _GetTargetName(const he: IDomElement): SciterString;
begin
  Result := he.Attributes['target'];
  if Result = EmptyStr then
    Result := he.Attributes['href'];
end;

function _GetSelectedElement(const he: IDomElement; const AGroup: SciterString): IDomElement;
begin
  Result := he.Root.FindFirst('[target][selected]'+AGroup, []);
  if Result = nil then
    Result := he.Root.FindFirst('[href][selected]'+AGroup, []);
end;

function _MenuTabLoadFrame(const he, target: IDomElement): Boolean;
var
  sUrl: SciterString;
  bAlwaysLoad, bLoaded: Boolean;
begin
  Result := False;
  sUrl :=  target.Attributes['url'];
  if sUrl = '' then
  begin
    sUrl :=  he.Attributes['url'];
    if sUrl = '' then
      Exit;
  end;

  bAlwaysLoad := target.IndexOfAttribute('alwaysload') >= 0;
  bLoaded := target.IndexOfAttribute('-menutab-url-loaded') >= 0;
  if bLoaded and (not bAlwaysLoad) then
  begin
    Result := True;
    Exit;
  end;
  sUrl := Sciter.DecodeURI(target.CombineURL(Sciter.EncodeURI(sUrl)));
  target.LoadHtml(sUrl);
  if not bLoaded then
    target.Attributes['-menutab-url-loaded'] := '';
  Result := True;
end;

function _MenuTabSelectTab(const he: IDomElement; const AGroup: SciterString; const doAnimation: Boolean): Boolean;
var
  selectedEle, selectedPanel, Ltarget, LtargetP, LChild: IDomElement;
  i, v: Integer;
  iIsBefore: Integer;
  sAnimation, sTarget, sEvent: SciterString;
  val: SCITER_VALUE;
  pType: TDomValueType; 
  pUnits: UINT;
begin
  Result := False;
  if he.IndexOfAttribute('noselect') >= 0 then
    Exit;
  //�������onselect�¼�����ֱ��ִ������¼�
  sEvent := he.Attributes['onselect'];
  if sEvent <> '' then
  begin
    if SAPI.SciterEvalElementScript(he.Element, PWideChar(sEvent), Length(sEvent), val) <> SCDOM_OK  then
      Exit;
    SAPI.ValueType(val, pType, pUnits);
    if pType = T_BOOL then
    begin
      SAPI.ValueIntData(val, v);
      if v <> 0 then
        Exit;
    end;
  end;
  
  sTarget := _GetTargetName(he);
  if sTarget = EmptyStr then
    Exit;
  Ltarget := he.Root.FindFirst('[name="%s"]'+AGroup, [sTarget]);
  if Ltarget = nil then
    Exit;

  //����ԭ��ǩ
  selectedEle := _GetSelectedElement(he, AGroup); 
  iIsBefore := -1;
  if (selectedEle <> nil) then
  begin
    if doAnimation and selectedEle.Equal(he) and (not he.HasAttribute('alwaysload')) then
    begin
      Result := True;
      Exit;
    end;
    selectedPanel := he.Root.FindFirst('[name="%s"]'+AGroup, [_GetTargetName(selectedEle)]);
    if selectedPanel <> nil then
      selectedPanel.ClearState(ACTIVATE_CHILD);

    selectedEle.RemoveAttribute('selected');
    if selectedEle.UID > he.UID then
      iIsBefore := 1
    else                     
      iIsBefore := 0;              
    selectedEle.SetStateEx(STATE_COLLAPSED, STATE_EXPANDED or ACTIVATE_CHILD);
    selectedEle.PostEvent(STATE_COLLAPSED);
  end;                                      
  he.Attributes['selected'] := '';

  //����Ŀ����ʾ
  LtargetP := Ltarget.Parent;
  for i := 0 to LtargetP.ChildCount - 1 do
  begin
    LChild := LtargetP.Child[i];
    if LChild = nil then
      continue;
    if LChild.Attributes['name'] <> '' then
      LChild.Style['visibility'] := 'none';
  end;

  if doAnimation and (iIsBefore >= 0) then
  begin
    if iIsBefore=1 then
      sAnimation := Ltarget.Attributes['before-animation']
    else
      sAnimation := Ltarget.Attributes['after-animation'];

    if sAnimation <> '' then
      Ltarget.Style['transition'] := sAnimation;
  end;
  
  if he.Attributes['name'] <> '' then
    Ltarget.Attributes['menu-name'] := he.Attributes['name']
  else
    Ltarget.RemoveAttribute('menu-name');
  Ltarget.Attributes['menu-group'] := he.Attributes['group'];

  he.SetStateEx(STATE_EXPANDED, STATE_COLLAPSED);
  he.PostEvent(ELEMENT_EXPANDED);
  
  Ltarget.Style['visibility'] := 'visible';
  Ltarget.PostEvent(ACTIVATE_CHILD);
  Ltarget.PostEvent(UI_STATE_CHANGED);
  
  Result := _MenuTabLoadFrame(he, Ltarget);
  if Result then
  begin
    sEvent := he.Attributes['onselected'];
    if sEvent <> '' then
      SAPI.SciterEvalElementScript(he.Element, PWideChar(sEvent), Length(sEvent), val);
  end;
end;

procedure TMenuTabBehavior.OnAttached(const he: IDomElement);
var
  selectedEle: IDomElement;
  sGroup: SciterString;
begin
  sGroup := he.Attributes['group'];
  FGroup := sGroup;
  if FGroup <> EmptyStr then
    FGroup := '[group="'+FGroup+'"]';
  FElement := he.Element;
  
  if he.Root.IndexOfAttribute('-init-menutab-'+sGroup) >= 0 then
    Exit;
  he.Root.Attributes['-init-menutab-'+sGroup] := '';
  selectedEle := _GetSelectedElement(he, FGroup);
  if selectedEle <> nil then
    _MenuTabSelectTab(selectedEle, FGroup, False);
end;

procedure TMenuTabBehavior.OnDetached(const he: IDomElement);
begin
  he.RemoveAttribute('-init-menutab-'+he.Attributes['group']);
  FElement := nil;
end;

function TMenuTabBehavior.OnMouseClick(const he, target: IDomElement;
  event_type: UINT; var params: TMouseParams): Boolean;
begin
  Result := False;
  if (not IsBubbling(event_type)) or (not he.IsValid) then
    Exit;
  if he.Attributes['trigger'] <> Trigger_Hover then
    Result := _MenuTabSelectTab(he, FGroup);
end;

function TMenuTabBehavior.OnMouseEnter(const he, target: IDomElement;
  event_type: UINT; var params: TMouseParams): Boolean;
begin
  Result := False;
  if (not IsBubbling(event_type)) or (not he.IsValid) then
    Exit;
  if he.Attributes['trigger'] = Trigger_Hover then
    Result := _MenuTabSelectTab(he, FGroup);
end;

function TMenuTabBehavior.OnSubscription(const he: IDomElement;
  var event_groups: UINT): Boolean;
begin
  event_groups := HANDLE_MOUSE;
  Result := True;
end;

function TMenuTabBehavior.selectTab: Boolean;
var
  LHe: IDomElement;
begin
  LHe := ElementFactory.Create(FElement);
  Result := _MenuTabSelectTab(LHe, FGroup);
end;

initialization
  BehaviorFactorys.Reg(TBehaviorFactory.Create('menutab', TMenuTabBehavior));

finalization
  BehaviorFactorys.UnReg('menutab');


end.

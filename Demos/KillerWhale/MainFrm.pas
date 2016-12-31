unit MainFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, SciterFrm, SciterIntf, SciterTypes, ExtCtrls, Menus;

type
  TIam = (iaDad, iaMom, iaBaby);
  TMainForm = class(TSciterForm)
    tm: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure tmTimer(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FIsSwimming: Boolean;
    FDownPos: TPoint;
    FIam: TIam;
    FIsLeftSwim: Boolean;
    FNum, r: Integer;
    cx, cy: Integer;
  protected
    //��갴���϶���������ĺ���
    function  OnMouseMove(const he, target: IDomElement; event_type: UINT; var params: TMouseParams): Boolean;
    //��갴�´�������ĺ���
    function  OnMouseDown(const he, target: IDomElement; event_type: UINT; var params: TMouseParams): Boolean;
    //��굯�𴥷�����ĺ���
    function  OnMouseUp(const he, target: IDomElement; event_type: UINT; var params: TMouseParams): Boolean;
    //�Ҽ��˵���������ĺ���
    function  OnMenuItemClick(const he, target: IDomElement; _type: UINT{BEHAVIOR_EVENTS}; var params: TBehaviorEventParams): Boolean;
  protected
    //�޸Ľڵ����
    procedure xghtml;
    //Ĭ������
    function getScreen: TPoint;
    //�����������ƽ���ζ�
    procedure RandMove(xnum: Integer);
    //�����ƶ�
    procedure ToLeft;
    //�����ƶ�
    procedure ToRight;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  ShellAPI, Math, TLHelp32;

var
  hDskManager: THandle = 0;
  hShellView: THandle = 0;

{ TMainForm }

function TMainForm.getScreen: TPoint;
begin
  Self.Left := -200;
  Self.Top  := 200;  //��ʼλ��
  Show;

  Randomize;

  FNum := 1;
  r   := 0;
  FIam := iaDad;
  FIsLeftSwim := True; //�����ƶ�
  FIsSwimming := True; //��ʼʱ�ζ�
end;

function TMainForm.OnMenuItemClick(const he, target: IDomElement;
  _type: UINT; var params: TBehaviorEventParams): Boolean;
begin
  Result := False;
  if not IsBubbling(_type) then
    Exit;
  
	FIsSwimming := false;
  if target.Text = '�˳�' then
  begin
    if hShellView <> 0 then
      ShowWindow(hShellView, SW_NORMAL);  //�˳�ǰ��ʾ����ͼ��
    tm.Enabled := False;

    Application.Terminate;
  end
  else
  if target.Text = '����ͼ��' then
  begin
    if hShellView <> 0 then
      ShowWindow(hShellView, SW_HIDE); //��������ͼ��
    tm.Interval := 15; //�޸Ķ�ʱ��
    FIsSwimming := True;
  end
  else
  if target.Text = '��ʾͼ��' then
  begin
    if hShellView <> 0 then
      ShowWindow(hShellView, SW_NORMAL); //��ʾ����ͼ��
    tm.Interval := 15; //�޸Ķ�ʱ��
    FIsSwimming := True;
  end
  else
  if target.Text = '����ְ�' then
  begin
    FIam := iaDad;
    xghtml; //�޸Ĵ��� 
  end
  else
  if target.Text = '��������' then
  begin
    FIam := iaMom;
    xghtml; //�޸Ĵ��� 
  end
  else
  if target.Text = '���㱦��' then
  begin
    FIam := iaBaby;
    xghtml; //�޸Ĵ��� 
  end
  else
  if target.Text = '���ڻ���' then
  begin
    ShellExecute(Handle, nil,PChar('http://baike.baidu.com/view/9005.htm'), nil, nil, SW_shownormal);
    
    tm.Interval := 15; //�޸Ķ�ʱ��
    FIsSwimming := True;
  end;
  Result := True;
end;

function TMainForm.OnMouseDown(const he, target: IDomElement;
  event_type: UINT; var params: TMouseParams): Boolean;
begin
  Result := False;
  if not IsBubbling(event_type) then
    Exit;
  
  if (params.button_state = MAIN_MOUSE_BUTTON) or (params.button_state = PROP_MOUSE_BUTTON) then
  begin
    FIsSwimming := False;
    tm.Interval := 1000000; //��ʱ����ͣ3��ȴ��˳�������
    if params.button_state = MAIN_MOUSE_BUTTON then
      he.SetCapture;
    FDownPos := params.pos;
    
    Result := True;
  end;
end;

function TMainForm.OnMouseMove(const he, target: IDomElement;
  event_type: UINT; var params: TMouseParams): Boolean;
var
  wx, wy: Integer;
begin
  Result := False;
  if not IsBubbling(event_type) then
    Exit;

  if params.button_state = MAIN_MOUSE_BUTTON then
  begin
    FIsSwimming := False;
    tm.Interval := 5000;
    
    wx := Self.Left + params.pos.X - FDownPos.X;
    wy := Self.Top  + params.pos.Y - FDownPos.Y;
    Self.SetBounds(wx, wy, Self.Width, Self.Height);
    
    Result := True;
  end
end;

function TMainForm.OnMouseUp(const he, target: IDomElement;
  event_type: UINT; var params: TMouseParams): Boolean;
begin
  Result := False;
  if not IsBubbling(event_type) then
    Exit;

  if (params.button_state = MAIN_MOUSE_BUTTON) or (params.button_state = PROP_MOUSE_BUTTON) then
  begin
    he.ReleaseCapture;
  end;
  
  if params.button_state = MAIN_MOUSE_BUTTON then
  begin
    tm.Interval := 15;   //�޸Ķ�ʱ��
    FIsSwimming := True;
    
    Result := True;
  end
  else
    Result := False;
end;

procedure TMainForm.RandMove(xnum: Integer);
begin
  //����Ļ���ζ�200�κ�����ı䷽��
  if (FNum > 200) and (cy<Screen.DesktopRect.Bottom) and (cy > 0) then
  begin   
    r := RandomRange(-1, 1);
    FNum := 1;
  end
  else
  if (cy > Screen.DesktopRect.Bottom+20) then //�ζ�������Ļ�·�ʱ��Ϊ�����ζ�
  begin
    r := -1;
  end
  else
  if cy < -20 then  //�ζ�������Ļ�Ϸ�ʱ��Ϊ�����ζ�
  begin
    r := 1;
  end;
  FNum := FNum + 1;

  if r = 0 then  //ֱ���ζ�ʱ�����ٶ�
  begin
    tm.Interval := 25;
  end
  else  //�ӿ��ٶ�
  begin
    tm.Interval := 15;
  end;

  Self.SetBounds(cx+xnum, cy+r, Self.Width, Self.Height);
end;

procedure TMainForm.xghtml;
var
  myTab: IDomElement;
begin
  case FIam of
    iaDad:
    begin
      myTab := Layout.RootElement.FindFirst('#myTab img');   //��ȡ�ڵ�
      if myTab <> nil then
      begin
        if FIsLeftSwim then
          myTab.Attributes['src'] := 'res:daddy_left.png'
        else
          myTab.Attributes['src'] := 'res:daddy_right.png';
      end;
    end;
    iaMom:
    begin
      myTab := Layout.RootElement.FindFirst('#myTab img');   //��ȡ�ڵ�
      if myTab <> nil then
      begin
        if FIsLeftSwim then
          myTab.Attributes['src'] := 'res:mummy_left.png'
        else
          myTab.Attributes['src'] := 'res:mummy_right.png';
      end;
    end;
    iaBaby:
    begin
      myTab := Layout.RootElement.FindFirst('#myTab img');   //��ȡ�ڵ�
      if myTab <> nil then
      begin
        if FIsLeftSwim then
          myTab.Attributes['src'] := 'res:son_left.png'
        else
          myTab.Attributes['src'] := 'res:son_right.png';
      end;   
    end;
  end;
  FIsSwimming := True;

  tm.Interval := 15; //�޸Ķ�ʱ��
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  inherited;
  Self.Left := Screen.DesktopWidth-200;
  Self.Top  := 200;  //��ʼλ��

  Randomize;

  FNum := 1;
  r   := 0;
  FIam := iaDad;
  FIsLeftSwim := True; //�����ƶ�
  FIsSwimming := True; //��ʼʱ�ζ�

  Behavior.OnMouseMove := OnMouseMove;
  Behavior.OnMouseDown := OnMouseDown;
  Behavior.OnMouseUp   := OnMouseUp;
  Behavior.OnMenuItemClick := OnMenuItemClick;

  tm.Enabled := True;
end;

procedure TMainForm.ToLeft;
var
  xnum: Integer;
begin
  cx := Self.Left;
  cy := Self.Top;

	if cx > -240 then //δ������Ļ���ʱ������ζ�
  begin
		xnum := -1;
		randmove(xnum)//����ζ�
	end
	else
  begin
		FIsLeftSwim := false;//���������ƶ�;
		xghtml();//�޸Ĵ���
	end;
end;

procedure TMainForm.ToRight;
var
  xnum: Integer;
begin
  cx := Self.Left;
  cy := Self.Top;

	if cx < Screen.DesktopWidth then //δ������Ļ�ұ�ʱ������ζ�
  begin
		xnum := 1;
		randmove(xnum)//����ζ�
	end
	else
  begin
		FIsLeftSwim := True;//�����ƶ�
		xghtml();//�޸Ĵ���
	end;
end;

procedure TMainForm.tmTimer(Sender: TObject);
begin
  if FIsLeftSwim then
    ToLeft
  else
    ToRight;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  tm.Enabled := False;
  inherited;
end;

initialization
  hDskManager := FindWindowEx(FindWindow('Progman',nil),0,'shelldll_defview',nil);
  hShellView  := FindWindowEx(FindWindow('WorkerW',nil),0,'shelldll_defview',nil);



finalization

end.

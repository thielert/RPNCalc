unit RPNCalc;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  FMX.Controls.Presentation,
  FMX.StdCtrls,
  FMX.Layouts,
  FMX.ListView.Types,
  FMX.ListView.Appearances,
  FMX.ListView.Adapters.Base,
  FMX.ListView,
  System.Actions,
  FMX.ActnList,
  Data.Bind.EngExt,
  FMX.Bind.DBEngExt,
  System.Rtti,
  System.Bindings.Outputs,
  FMX.Bind.Editors,
  Data.Bind.Components,
  FMX.Edit,
  FMX.ListBox,
  FMX.Styles.Objects,
  StrUtils;

type
  TForm_RPNCalc = class(TForm)
    GridPanelLayout1: TGridPanelLayout;
    Button_Swap: TButton;
    Button_CLR: TButton;
    Button_CLA: TButton;
    Button_Polarity: TButton;
    Button_Enter: TButton;
    Button_ShiftUp: TButton;
    Button_ShiftDown: TButton;
    Button_Div: TButton;
    Button_Mul: TButton;
    Button_Sub: TButton;
    Button_Add: TButton;
    Button_0: TButton;
    Button_1: TButton;
    Button_2: TButton;
    Button_3: TButton;
    Button_4: TButton;
    Button_5: TButton;
    Button_6: TButton;
    Button_7: TButton;
    Button_8: TButton;
    Button_9: TButton;
    Button_Dot: TButton;
    ListBox1: TListBox;
    StyleBook1: TStyleBook;

    procedure FormCreate(Sender: TObject);
    procedure PushInputToStack();
    procedure PushValueToStack(x: double);
    procedure Button_NumberClick(Sender: TObject);
    procedure Button_DotClick(Sender: TObject);
    procedure Button_EnterClick(Sender: TObject);
    procedure Button_AddClick(Sender: TObject);
    procedure Button_SubClick(Sender: TObject);
    procedure Button_MulClick(Sender: TObject);
    procedure Button_DivClick(Sender: TObject);
    procedure Button_PolarityClick(Sender: TObject);
    procedure Button_CLAClick(Sender: TObject);
    procedure Button_CLRClick(Sender: TObject);
    procedure Button_SwapClick(Sender: TObject);
    procedure Button_ShiftUpClick(Sender: TObject);
    procedure Button_ShiftDownClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure Button_KeyDown(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);

  private
    { Private declarations }
    enteringValue: Boolean;
    procedure Action_NumberInput(numPart: String);
    procedure Action_DotInput;
    procedure Action_EnterInput;
    procedure Action_AddInput;
    procedure Action_SubInput;
    procedure Action_MulInput;
    procedure Action_DivInput;
    procedure Action_PolarityInput;
    procedure Action_CLAInput;
    procedure Action_CLRInput;
    procedure Action_SwapInput;
    procedure Action_ShiftUpInput;
    procedure Action_ShiftDownInput;

  public
    { Public declarations }
  end;

var
  Form_RPNCalc: TForm_RPNCalc;

implementation

{$R *.fmx}

procedure TForm_RPNCalc.FormCreate(Sender: TObject);
begin
  enteringValue := False;
end;

procedure TForm_RPNCalc.FormKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  if Key = vkEscape then
  begin
    Focused := Button_Enter; // Is this the best way to clear focus?
    Button_Enter.ResetFocus();
  end
  else if CharInSet(KeyChar, ['0' .. '9']) then
  begin
    Action_NumberInput(KeyChar);
  end
  else if KeyChar = '.' then
  begin
    Action_DotInput();
  end
  else if Key = vkReturn then
  begin
    Action_EnterInput();
  end
  else if KeyChar = '+' then
  begin
    Action_AddInput();
  end
  else if KeyChar = '-' then
  begin
    Action_SubInput();
  end
  else if KeyChar = '*' then
  begin
    Action_MulInput();
  end
  else if KeyChar = '/' then
  begin
    Action_DivInput();
  end
  else if Key = vkEnd then
  begin
    Action_PolarityInput();
  end
  else if ((Key = vkDelete) and (Shift = [ssCtrl])) then
  begin
    Action_CLAInput();
  end
  else if Key = vkBack then
  begin
    Action_CLRInput();
  end
  else if Key = vkDelete then
  begin
    Action_CLRInput();
  end
  else if Key = vkHome then
  begin
    Action_SwapInput();
  end
  else if Key = vkPrior then
  begin
    Action_ShiftUpInput();
  end
  else if Key = vkNext then
  begin
    Action_ShiftDownInput();
  end

end;

procedure TForm_RPNCalc.Button_KeyDown(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  if Key = vkReturn then
  begin
    Action_EnterInput();
    Key := 0;
    KeyChar := #0; // Is this the best way to trap the Enter Key Click?
  end;
end;

procedure TForm_RPNCalc.PushInputToStack();
begin
  if enteringValue = True then
  begin
    if ContainsText(ListBox1.Items[0], '.') then
      ListBox1.Items[0] := ListBox1.Items[0].TrimRight(['0']);
    ListBox1.Items[0] := ListBox1.Items[0].TrimRight(['.']);
    if ListBox1.Items[0] = '' then
      ListBox1.Items[0] := '0';

    ListBox1.ItemByIndex(0).StyleLookup := 'RPN_ListItem';
    enteringValue := False;
  end;
end;

procedure TForm_RPNCalc.PushValueToStack(x: double);
begin
  var newValue: TListBoxItem := TListBoxItem.Create(ListBox1);
  newValue.StyleLookup := 'RPN_ListItem';
  newValue.ItemData.text := x.ToString();
  ListBox1.InsertObject(0, newValue);
end;

procedure TForm_RPNCalc.Button_NumberClick(Sender: TObject);
begin
  Action_NumberInput((Sender as TButton).text);
end;

procedure TForm_RPNCalc.Action_NumberInput(numPart: String);
begin
  if enteringValue = False then
  begin
    enteringValue := True;
    var newValue: TListBoxItem := TListBoxItem.Create(ListBox1);
    newValue.StyleLookup := 'RPN_ListItemEditing';
    newValue.ItemData.text := numPart;
    ListBox1.InsertObject(0, newValue);
  end
  else
  begin
    ListBox1.Items[0] := ListBox1.Items[0] + numPart;
  end;
end;

procedure TForm_RPNCalc.Button_DotClick(Sender: TObject);
begin
  Action_DotInput();
end;

procedure TForm_RPNCalc.Action_DotInput();
begin
  if enteringValue = False then
  begin
    enteringValue := True;
    var newValue: TListBoxItem := TListBoxItem.Create(ListBox1);
    newValue.StyleLookup := 'RPN_ListItemEditing';
    newValue.ItemData.text := '0.';
    ListBox1.InsertObject(0, newValue);
  end;
  if ContainsText(ListBox1.Items[0], '.') then
    Exit;
  if ListBox1.Items[0] = '' then
  begin
    ListBox1.Items[0] := '0.';
    Exit;
  end;
  ListBox1.Items[0] := ListBox1.Items[0] + '.';
end;

procedure TForm_RPNCalc.Button_EnterClick(Sender: TObject);
begin
  Action_EnterInput();
end;

procedure TForm_RPNCalc.Action_EnterInput();
begin
  if ((enteringValue = False) and (ListBox1.Items.Count > 0))then
  begin
    PushValueToStack(StrToFloat(ListBox1.Items[0]));
    Exit;
  end;
  PushInputToStack();
end;

procedure TForm_RPNCalc.Button_AddClick(Sender: TObject);
begin
  Action_AddInput();
end;

procedure TForm_RPNCalc.Action_AddInput();
begin
  PushInputToStack();
  if ListBox1.Count >= 2 then
  begin
    var x: double := StrToFloat(ListBox1.Items[0]);
    ListBox1.Items.Delete(0);
    var y: double := StrToFloat(ListBox1.Items[0]);
    ListBox1.Items.Delete(0);
    var z: double := y + x;
    PushValueToStack(z);
  end;
end;

procedure TForm_RPNCalc.Button_SubClick(Sender: TObject);
begin
  Action_SubInput();
end;

procedure TForm_RPNCalc.Action_SubInput();
begin
  PushInputToStack();
  if ListBox1.Count >= 2 then
  begin
    var x: double := StrToFloat(ListBox1.Items[0]);
    ListBox1.Items.Delete(0);
    var y: double := StrToFloat(ListBox1.Items[0]);
    ListBox1.Items.Delete(0);
    var z: double := y - x;
    PushValueToStack(z);
  end;
end;

procedure TForm_RPNCalc.Button_MulClick(Sender: TObject);
begin
  Action_MulInput();
end;

procedure TForm_RPNCalc.Action_MulInput();
begin
  PushInputToStack();
  if ListBox1.Count >= 2 then
  begin
    var x: double := StrToFloat(ListBox1.Items[0]);
    ListBox1.Items.Delete(0);
    var y: double := StrToFloat(ListBox1.Items[0]);
    ListBox1.Items.Delete(0);
    var z: double := y * x;
    PushValueToStack(z);
  end;
end;

procedure TForm_RPNCalc.Button_DivClick(Sender: TObject);
begin
  Action_DivInput();
end;

procedure TForm_RPNCalc.Action_DivInput();
begin
  PushInputToStack();
  if ListBox1.Count >= 2 then
  begin
    var x: double := StrToFloat(ListBox1.Items[0]);
    ListBox1.Items.Delete(0);
    var y: double := StrToFloat(ListBox1.Items[0]);
    ListBox1.Items.Delete(0);
    var z: double := y / x;
    PushValueToStack(z);
  end;
end;

procedure TForm_RPNCalc.Button_PolarityClick(Sender: TObject);
begin
  Action_PolarityInput();
end;

procedure TForm_RPNCalc.Action_PolarityInput();
begin
  if ListBox1.Count >= 1 then
  begin
    var x: double := StrToFloat(ListBox1.Items[0]);
    var z: double := x * -1;
    ListBox1.Items[0] := z.ToString();
  end;
end;

procedure TForm_RPNCalc.Button_CLAClick(Sender: TObject);
begin
  Action_CLAInput();
end;

procedure TForm_RPNCalc.Action_CLAInput();
begin
  ListBox1.Items.Clear();
end;

procedure TForm_RPNCalc.Button_CLRClick(Sender: TObject);
begin
  Action_CLRInput();
end;

procedure TForm_RPNCalc.Action_CLRInput();
begin
  if enteringValue = True then
  begin
    ListBox1.Items[0] := ListBox1.Items[0].Substring(0,
      ListBox1.Items[0].Length - 1);
    Exit;
  end;
  ListBox1.Items.Delete(0);
end;

procedure TForm_RPNCalc.Button_SwapClick(Sender: TObject);
begin
  Action_SwapInput();
end;

procedure TForm_RPNCalc.Action_SwapInput();
begin
  PushInputToStack();
  if ListBox1.Count >= 2 then
  begin
    var x: double := StrToFloat(ListBox1.Items[0]);
    ListBox1.Items.Delete(0);
    var y: double := StrToFloat(ListBox1.Items[0]);
    ListBox1.Items.Delete(0);
    PushValueToStack(x);
    PushValueToStack(y);
  end;
end;

procedure TForm_RPNCalc.Button_ShiftUpClick(Sender: TObject);
begin
  Action_ShiftUpInput();
end;

procedure TForm_RPNCalc.Action_ShiftUpInput();
begin
  PushInputToStack();
  if ListBox1.Count >= 2 then
  begin
    var x: double := StrToFloat(ListBox1.Items[ListBox1.Items.Count - 1]);
    ListBox1.Items.Delete(ListBox1.Items.Count - 1);
    PushValueToStack(x);
  end;
end;

procedure TForm_RPNCalc.Button_ShiftDownClick(Sender: TObject);
begin
  Action_ShiftDownInput();
end;

procedure TForm_RPNCalc.Action_ShiftDownInput();
begin
  PushInputToStack();
  if ListBox1.Count >= 2 then
  begin
    var x: double := StrToFloat(ListBox1.Items[0]);
    ListBox1.Items.Delete(0);

    var newValue: TListBoxItem := TListBoxItem.Create(ListBox1);
    newValue.StyleLookup := 'RPN_ListItem';
    newValue.ItemData.text := x.ToString();
    ListBox1.InsertObject(ListBox1.Items.Count, newValue);
  end;
end;

end.

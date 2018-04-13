unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Tlhelp32, PsAPI, Vcl.StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    ListBox1: TListBox;
    procedure Button1Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure ListBox1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
    procedure ListarProcessosAbertos;
    function KillTask(ExeFileName: string): Integer;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
begin
   ListarProcessosAbertos;
end;

procedure TForm1.FormActivate(Sender: TObject);
begin
   ListarProcessosAbertos;
end;

function TForm1.KillTask(ExeFileName: string): Integer;
Const
   PROCESS_TERMINATE = $0001;

var
  ContinueLoop: BOOL;
  FSnapshotHandle: THandle;
  FProcessEntry32: TProcessEntry32;

begin

   Result := 0;

   FSnapshotHandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
   FProcessEntry32.dwSize := SizeOf(FProcessEntry32);
   ContinueLoop := Process32First(FSnapshotHandle, FProcessEntry32);

   While Integer(ContinueLoop) <> 0 Do
     Begin

        If ( (UpperCase(ExtractFileName(FProcessEntry32.szExeFile)) = UpperCase(ExeFileName)) Or
             (UpperCase(FProcessEntry32.szExeFile) = UpperCase(ExeFileName)) ) Then

           Result := Integer(TerminateProcess(OpenProcess(PROCESS_TERMINATE, BOOL(0),
                                              FProcessEntry32.th32ProcessID), 0));

       ContinueLoop := Process32Next(FSnapshotHandle, FProcessEntry32);

     End;

   CloseHandle(FSnapshotHandle);

end;

procedure TForm1.ListarProcessosAbertos;
const
   PROCESS_TERMINATE = $0001;

var
   ContinueLoop: BOOL;
   FSnapshotHandle: THandle;
   FProcessEntry32: TProcessEntry32;

Begin

   FSnapshotHandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
   FProcessEntry32.dwSize := sizeof(FProcessEntry32);
   ContinueLoop := Process32First(FSnapshotHandle, FProcessEntry32);

   { Zerar Lista }
   ListBox1.Clear;

   While Integer(ContinueLoop) <> 0 Do
      Begin

         If (FProcessEntry32.szExeFile <> '[System Process]' ) Then
            ListBox1.Items.Add(FProcessEntry32.szExeFile);

         ContinueLoop := Process32Next(FSnapshotHandle, FProcessEntry32);

      End;

   CloseHandle(FSnapshotHandle);

   { Serve para ordenar a lista dos processos por ordem alfabética }
   ListBox1.Sorted := True ;

end;

procedure TForm1.ListBox1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
   cMsg : String;
begin

   cMsg := 'Deseja Finalizar Tarefa?';
   If ( Key = Vk_Delete ) Then
      Begin

         If Application.MessageBox(pChar(cMsg), 'Confirmação',
            MB_ICONQUESTION + MB_YESNO + MB_DEFBUTTON1) <> idYes Then
            Exit ;

         KillTask(ListBox1.Items[ListBox1.ItemIndex]);
         Sleep(500);
         ListarProcessosAbertos;

      End;

end;

end.

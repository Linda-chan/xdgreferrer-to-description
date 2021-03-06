Option Explicit

Dim FSO

Const ForReading = 1
Const ForWriting = 2
Const ForAppending = 8 

Const AppTitle = "AJPscripts - xdg.referrer to Descript.ion"
Const AppCopyright = "Линда Кайе 2016-2019. Посвящается Ариэль"

'====================================================================
Public Sub Main()
  Dim DescriptionData
  Dim FileNames
  Dim OEMMode
  Dim JPGMode
  
  If Not InitObjects() Then Exit Sub
  
  If Not ParseCommandLine(FileNames, OEMMode, JPGMode) Then
    ShowUsage
    Exit Sub
  End If
  
  ' Debug!
  'MsgBox TypeName(FileNames)
  'MsgBox FileNames
  'Exit Sub
  
  DescriptionData = GetDescriptionData(FileNames, JPGMode)
  If DescriptionData = "" Then
    WScript.Echo "Ссылок не найдено."
    Exit Sub
  End If
  
  UpdateDescriptionFile "NUL", DescriptionData, OEMMode
End Sub

'====================================================================
Private Function InitObjects()
  InitObjects = False
  
  On Error Resume Next
  
  Set FSO = CreateObject("Scripting.FileSystemObject")
  If Err.Number <> 0 Then
    WScript.Echo "Can't create object Scripting.FileSystemObject..."
    WScript.Echo "Error " & Err.Number & ": " & Err.Description
    Exit Function
  End If
  
  InitObjects = True
End Function

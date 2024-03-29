Option Explicit

'====================================================================
Public Function GetDescriptionData(ByRef FileNames, ByVal JPGMode)
  If IsNull(FileNames) Then
    GetDescriptionData = GetDescriptionData_All(JPGMode)
  Else
    GetDescriptionData = GetDescriptionData_Files(FileNames, JPGMode)
  End If
End Function

'====================================================================
Private Function GetDescriptionData_All(ByVal JPGMode)
  Dim Line
  Dim TXT
  Dim Folder
  Dim File
  
  TXT = ""
  
  Set Folder = FSO.GetFolder(".")
  For Each File In Folder.Files
    Line = GetDescriptionLine(File, JPGMode)
    If Line <> "" Then TXT = TXT & Line & vbCrLf
  Next
  
  GetDescriptionData_All = TXT
End Function

'====================================================================
Private Function GetDescriptionData_Files(ByRef FileNames, ByVal JPGMode)
  Dim FileName
  Dim File
  Dim Line
  Dim TXT
  
  On Error Resume Next
  
  TXT = ""
  
  For Each FileName In FileNames
    ' Отбрасывать путь не будем - пусть стреляют в ногу.
    'FileName = FSO.GetFileName
    
    Set File = FSO.GetFile(FileName)
    If Err.Number <> 0 Then
      WScript.Echo "Не удалось обработать файл: " & FileName
      WScript.Echo "Ошибка " & Err.Number & ": " & Err.Description
    Else
      Line = GetDescriptionLine(File, JPGMode)
      If Line <> "" Then TXT = TXT & Line & vbCrLf
    End If
  Next
  
  GetDescriptionData_Files = TXT
End Function

'====================================================================
Private Function GetDescriptionLine(ByRef File, ByVal JPGMode)
  Dim FileName
  Dim Stream
  Dim Data
  Dim TXT
  Dim RC
  
  GetDescriptionLine = ""
  FileName = File.Path & ":user.xdg.referrer.url"
  
  On Error Resume Next

  Set Stream = FSO.OpenTextFile(FileName, ForReading, False, False)
  If Err.Number <> 0 Then 
    ' Если ошибка 53 (файл не найден), то ничего не сообщаем, 
    ' поскольку поток может отсутствовать, но через 
    ' FSO.FileExists() узнать этого мы не можем. Остаётся только 
    ' пробовать открыть и глушить ошибку.
    If Err.Number <> 53 Then
      WScript.Echo "Не удалось прочитать файл: " & FileName
      WScript.Echo "Ошибка " & Err.Number & ": " & Err.Description
    End If
    Exit Function
  End If
  
  Data = Stream.ReadAll()
  If Err.Number <> 0 Then 
    WScript.Echo "Не удалось прочитать файл: " & FileName
    WScript.Echo "Ошибка " & Err.Number & ": " & Err.Description
    Exit Function
  End If
  
  Stream.Close
  
  Data = Trim(Data)
  
  RC = InStr(Data, vbCr)
  If RC > 0 Then Data = Left(Data, RC - 1)
  
  RC = InStr(Data, vbLf)
  If RC > 0 Then Data = Left(Data, RC - 1)
  
  If Data = "" Then Exit Function
  
  TXT = GetDescriptionLine2(File.Name, Data)
  If JPGMode Then _
    TXT = TXT & GetDescriptionLineJPGMode(File, Data)
  
  GetDescriptionLine = TXT
End Function

'====================================================================
Private Function GetDescriptionLineJPGMode(ByRef File, Byval Data)
  Dim CurrExtension
  Dim TXT
  Dim Extensions
  Dim Extension
  Dim ThumbFile
  
  Const THUMB_EXTS = "bmp:rle:jpg:jpeg:gif:png:webp"
  
  On Error Resume Next
  
  TXT = ""
  
  CurrExtension = LCase(GetFileExtension(File.Name))
  If InStr(":" & THUMB_EXTS & ":", ":" & CurrExtension & ":") = 0 Then
    Extensions = Split(THUMB_EXTS, ":")
    For Each Extension In Extensions
      ' Здесь используется объект, чтобы имя файла автоматически 
      ' привелось к правильному регистру. Ну и проверка 
      ' существования файла при этом тоже осуществляется.
      Set ThumbFile = FSO.GetFile(ReplaceFileExtension(File.Path, Extension))
      If Err.Number = 0 Then _
        TXT = TXT & vbCrLf & GetDescriptionLine2(ThumbFile.Name, Data)
      Err.Clear
    Next
  End If
  
  GetDescriptionLineJPGMode = TXT
End Function

'====================================================================
Private Function GetDescriptionLine2(ByVal FileName, ByVal Data)
  Dim TXT
  
  TXT = FileName
  If InStr(TXT, " ") <> 0 Then TXT = """" & TXT & """"
  TXT = TXT & " " & Data
  
  GetDescriptionLine2 = TXT
End Function

'====================================================================
Private Function ReplaceExtension(ByVal FileName, ByVal NewExtension)
  Dim Ext
  
  Ext = FSO.GetExtensionName(FileName)
  If Ext = "" Then
    FileName = FileName & "." & NewExtension
  Else
    FileName = Left(FileName, Len(FileName) - Len(Ext)) & NewExtension
  End If
  
  ReplaceExtension = FileName
End Function

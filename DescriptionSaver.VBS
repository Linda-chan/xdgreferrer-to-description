Option Explicit

'====================================================================
Public Sub UpdateDescriptionFile(ByVal FileName, ByVal Data, ByVal OEMMode)
  Dim IonFileName
  
  If Not SaveDataToFile(FileName, "Descript.ion", _
                        Data, OEMMode, IonFileName) Then Exit Sub
  If Not HideFile(IonFileName) Then Exit Sub
End Sub

'====================================================================
' Дозаписывает данные в файл.
' 
' OriginalFileName - имя файла (полное или относительное), рядом 
'                    с которым должен лежать новый файл. От него 
'                    берётся путь.
' NewFileName      - имя файла без каталога, с которым нужно 
'                    сохранить данные. К этому имени дописывается 
'                    путь из предыдущего параметра.
' DataToSave       - данные.
' OEMMode          - рудимент. Сохранять ли данные в OEM кодировке 
'                    или в UTF-8. Если файл существует, то его 
'                    кодировка не проверяется.
' lpNewFileName    - имя файла, в который в итоге попали данные. 
'                    Возвращается наружу.
'====================================================================
Private Function SaveDataToFile(ByVal OriginalFileName, _
                                ByVal NewFileName, _
                                ByVal DataToSave, _
                                ByVal OEMMode, _
                                ByRef lpNewFileName)
  Dim Stream
  
  SaveDataToFile = False
  NewFileName = FSO.BuildPath(FSO.GetParentFolderName(OriginalFileName), NewFileName)
  
  On Error Resume Next
  
  ' Запанее перекодируем...
  If OEMMode Then
    DataToSave = CharToOem(DataToSave)
  Else
    DataToSave = CharToUtf8(DataToSave)
  End If

  ' Гарантируем пустую строку в начале, если файл уже существует. 
  ' Мало ли, вдруг там в конце нет переноса. Если же файл 
  ' не существует, то гарантируем BOM...
  If FSO.FileExists(NewFileName) Then
    DataToSave = vbCrLf & DataToSave
  Else
    If Not OEMMode Then _
      DataToSave = UTF8_BOM & DataToSave
  End If
  
  Set Stream = FSO.OpenTextFile(NewFileName, ForAppending, True, False)
  If Err.Number <> 0 Then
    WScript.Echo "Не удалось записать файл: " & NewFileName
    WScript.Echo "Ошибка " & Err.Number & ": " & Err.Description
    Exit Function
  End If
  
  Stream.Write DataToSave
  If Err.Number <> 0 Then
    WScript.Echo "Не удалось записать файл: " & NewFileName
    WScript.Echo "Ошибка " & Err.Number & ": " & Err.Description
    Exit Function
  End If
  
  WScript.Echo "Файл был обновлён: " & NewFileName
  
  lpNewFileName = NewFileName
  SaveDataToFile = True
End Function

'====================================================================
Private Function HideFile(ByVal FileName)
  Dim File
  
  HideFile = False
  
  On Error Resume Next
  
  Set File = FSO.GetFile(FileName)
  If Err.Number <> 0 Then
    WScript.Echo "Не удалось сделать скрытым файл: " & FileName
    WScript.Echo "Ошибка " & Err.Number & ": " & Err.Description
    Exit Function
  End If
  
  File.Attributes = 2
  If Err.Number <> 0 Then
    WScript.Echo "Не удалось сделать скрытым файл: " & FileName
    WScript.Echo "Ошибка " & Err.Number & ": " & Err.Description
    Exit Function
  End If
  
  HideFile = True
End Function

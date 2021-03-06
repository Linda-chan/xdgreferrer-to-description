Option Explicit

'====================================================================
Public Function ParseCommandLine(ByRef lpFileNames, _
                                 ByRef lpOEMMode, _
                                 ByRef lpJPGMode)
  Dim TMP
  
  lpFileNames = Null
  lpOEMMode = False
  ParseCommandLine = False
  
  If WScript.Arguments.Named.Exists("?") Then _
    Exit Function
  
  If WScript.Arguments.Named.Exists("OEM") Then _
    lpOEMMode = True
  
  If WScript.Arguments.Named.Exists("JPG") Then _
    lpJPGMode = True
  
  If WScript.Arguments.Unnamed.Count > 0 Then
    ReDim lpFileNames(WScript.Arguments.Unnamed.Count - 1)
    
    For TMP = 0 To WScript.Arguments.Unnamed.Count - 1
      lpFileNames(TMP) = WScript.Arguments.Unnamed(TMP)
    Next
  End If
  
  ParseCommandLine = True
End Function

'====================================================================
Private Sub ShowUsage()
  WScript.Echo AppTitle
  WScript.Echo AppCopyright
  WScript.Echo
  WScript.Echo "Использование: " & WScript.ScriptName & _
               " [/OEM] [/JPG] [FileName [FileName [...]]]"
  WScript.Echo
  WScript.Echo "Имена файлов должны быть без путей. " & _
               "Сами файлы должны лежать в текуем каталоге."
  WScript.Echo
  WScript.Echo "Если файлы не указаны, поиск ведётся по всем " & _
               "файлам в текущем каталоге."
End Sub

Option Explicit

' Этот модуль сделан чтобы бороться с этим:
' 
' Dim FSO
' Set FSO = CreateObject("Scripting.FileSystemObject")
' MsgBox FSO.GetExtensionName(".txt")
' 
' ==> txt

'====================================================================
Public Function ReplaceFileExtension(ByVal FileName, ByVal NewExtension)
  Dim RC1
  Dim RC2
  Dim RC3
  
  RC1 = InStrRev(FileName, ".")
  RC2 = InStrRev(FileName, "\")
  
  RC3 = InStrRev(FileName, "/")
  If RC3 > RC2 Then RC2 = RC3

  ' Первое условие:
  ' • Если индекс точки меньше индекса слэша, то имя файла
  '   не содержит точку, тость не содержит расширение. Дописываем.
  ' • Если индекс точки и индекс слэша равны, то они оба равны нулю.
  '   Тоесть у нас только имя файла без расширения. Тоже дописываем.
  ' • Если же индекс точки больше индекса слэша (есть он или нет),
  '   то имя файла содержит точку, и надо смотреть второе условие.
  ' Второе условие:
  ' • Если разница между индексом точки и индексом слэша равна
  '   одному, то точка идёт сразу за слэшем. Это имя файла,
  '   начинающееся с точки, но без расширения (дальше точек нет).
  '   Windows думает, что всё имя - расширение, но мы-то знаем, что
  '   это не так. Дописываем.
  ' Если оба условия не верны, то у нас обычное имя файла
  ' с расширением. Заменяем.
  If (RC1 <= RC2) Or (RC1 - RC2 = 1) Then
    ReplaceFileExtension = FileName & "." & NewExtension
  Else
    ReplaceFileExtension = Left(FileName, RC1) & NewExtension
  End If
End Function

'====================================================================
Public Function GetFileExtension(ByVal PathName)
  Dim RC1
  Dim RC2
  Dim RC3
  
  RC1 = InStrRev(PathName, ".")
  RC2 = InStrRev(PathName, "\")
  
  RC3 = InStrRev(PathName, "/")
  If RC3 > RC2 Then RC2 = RC3
  
  ' См. csReplaceFileExtension() выше...
  If (RC1 <= RC2) Or (RC1 - RC2 = 1) Then
    GetFileExtension = ""
  Else
    GetFileExtension = Mid(PathName, RC1 + 1)
  End If
End Function

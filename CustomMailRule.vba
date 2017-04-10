Sub CustomMailMessageRule(Item As Outlook.MailItem)
' custom mail rule to parse JIRA emails to determine if assigned to a generic user.   
' using the generic user for indicating that custom code is ready for code reviews.  
' Also includes creation of a JIRA Notifications
' Mail rule must run on a local instance of Outlook. 

    Dim strAsgn As String
    Dim strSCDev As String
    Dim myItem As Outlook.MailItem
    On Error Resume Next
    
     If Item.SenderEmailAddress = "jira@jhu.edu" Then
        'MsgBox "Mail message arrived: " & Item.Subject & "  " & Item.ReceivedTime
              
        strAsgn = ParseTextLinePair(Item.Body, "assigned an issue to SAP Development SC")
                
        If strAsgn <> "" Then
            strSCDev = ParseAssignee(Item.Body, "Assignee:")
            If StrComp(strSCDev, "SAP Development SC", CompareMethod.Text) Then
                ' Bingo
               ' MsgBox "Mail message arrived with Assigned Issue " & strSCDev
                ' Forward
                Set myItem = Item.Forward
                 
                myItem.Recipients.Add "jcompto8@jhu.edu" '
                myItem.Recipients.Add "pkhuran1@jhmi.edu"
                myItem.Recipients.Add "lkrishn1@jhmi.edu"
                myItem.Recipients.Add "hkurup3@jhmi.edu"
                myItem.Recipients.Add "lsezike1@jhmi.edu"
                
                myItem.Send
            Else
                ' MsgBox "Assigned Issue Mail message arrived without the SC Dev as assignee " & strSCDev
            End If
        Else
            strAsgn = ParseTextLinePair(Item.Body, "created an issue")
            If strAsgn <> "" Then
                strSCDev = ParseAssignee(strAsgn, "Assignee:")
                If StrComp(strSCDev, "SAP Development SC", CompareMethod.Text) Then
                ' Bingo
                    'MsgBox "Mail message arrived with Created Issue " & strSCDev
                    'forward item
                    Set myItem = Item.Forward
                     
                    myItem.Recipients.Add "jcompto8@jhu.edu" '
                    myItem.Recipients.Add "pkhuran1@jhmi.edu"
                    myItem.Recipients.Add "lkrishn1@jhmi.edu"
                    myItem.Recipients.Add "hkurup3@jhmi.edu"
                    myItem.Recipients.Add "lsezike1@jhmi.edu"
                    myItem.Send
                Else
                    'MsgBox "Created Issue Mail message arrived without the SC Dev as assignee " & strAsgn
                    
                End If


            End If
            
        End If
              
    End If
End Sub
Function ParseAssignee(strSource As String, strLabel As String)
    Dim strAssignee As String
    Dim iLen As Integer
    Dim iTarget As Integer
     
    strAssignee = ParseTextLinePair(strSource, strLabel)
            
    If strAssignee <> "" Then
      iTarget = Len("SAP Development SC") + 2
      iLen = Len(strAssignee)
      strAssignee = Right(strAssignee, iTarget)
    End If
                
    ParseAssignee = RTrim(strAssignee)
End Function
Function ParseTextLinePair _
  (strSource As String, strLabel As String)
    Dim intLocLabel As Integer
    Dim intLocCRLF As Integer
    Dim intLenLabel As Integer
    Dim strText As String
    intLocLabel = InStr(strSource, strLabel)
    intLenLabel = Len(strLabel)
        If intLocLabel > 0 Then
        intLocCRLF = InStr(intLocLabel, strSource, vbCrLf)
        If intLocCRLF > 0 Then
            intLocLabel = intLocLabel + intLenLabel
            strText = Mid(strSource, _
                            intLocLabel, _
                            intLocCRLF - intLocLabel)
        Else
            intLocLabel = _
              Mid(strSource, intLocLabel + intLenLabel)
        End If
    End If
    ParseTextLinePair = Trim(strText)
End Function

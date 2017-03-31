' Was looking for an example to read from an access database where data is in a form and export it in a format 
' to move it into EverNote.  Adding to GitHub
'
' In the forum where found code, person had issues when they adapted the original example: 
'
'...exporting a form or report per record and save the exported file under a filename with the recordID in the filename.
'However it is well known that subForms are not exported to RTF in Access, so i am working around that to export a single Report for every individual record instead of trying to export a Form including Subforms. This works well.

'I am running into trouble in the above VB statement if i try to export a lot of reports individually. I do not understand if the Employees.[EmployeeID] From Employees is referring to a table, the form or ......
'I also get errors using the _ & statement in Access 2003.
'Also if i try to run Access asks me about a macro to start. So a lot goes wrong
'

Dim MyDB As DAO.Database
Dim MyRS As DAO.Recordset
Dim strSQL As String
Dim strRptName As String
 
strRptName = "SAP Info"
 
'Used to create a Recordset of PatientIDs for Form Filtering for each
'patient. [Patnr_waarde] is the Primary Key making the job easy
strSQL = "Select [SAP Info].[Patnr_waarde] From SAP Info;"
 
 
Set MyDB = CurrentDb
Set MyRS = MyDB.OpenRecordset(strSQL, dbOpenForwardOnly)
 
With MyRS
  Do While Not MyRS.EOF
    'Open the Report Filering by the WHERE Clause for each specific [Patnr_waarde] Value
    DoCmd.OpenReport strRptName, acViewPreview, , "[Patnr_waarde] = " & ![Patnr_waarde]
 
    'Output Reports for each PK ([Patnr_waarde])
    DoCmd.OutputTo acOutputReport, strRptName, acFormatSNP, "D:\" & ![Patnr_waarde] & ".snp"
 
    'Close each Report after Outputting
    DoCmd.Close acReport, strRptName, acSaveNo
      .MoveNext       'Move to the next Record in Recordset
  Loop
End With
 
MyRS.Close
Set MyRS = Nothing

''
' Original Example
' person had issues when they adapted it 
Dim MyDB As DAO.Database
Dim MyRS As DAO.Recordset
Dim strSQL As String
 
'Used to create a Recordset of Employee IDs for Form Filtering for each
'Employee. [EmployeeID] is the Primary Key making the job easy
strSQL = "Select Employees.[EmployeeID] From Employees;"
 
Set MyDB = CurrentDb
Set MyRS = MyDB.OpenRecordset(strSQL, dbOpenForwardOnly)
 
With MyRS
  Do While Not MyRS.EOF
    Me.RecordSource = "Select * From Employees Where [EmployeeID] = " & _
                       ![EmployeeID]
    'Form has a single Record only, Output it to a unique RTF File
    DoCmd.OutputTo acOutputForm, "Employees", acFormatRTF, "C:\Test\Emp" & _
                   ![EmployeeID] & ".rtf"
     .MoveNext
  Loop
End With
 
 
MyRS.Close
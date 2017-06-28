REPORT sy-repid
       LINE-SIZE 200
       LINE-COUNT 65
       MESSAGE-ID s1
       NO STANDARD PAGE HEADING.

***********************************************************************
*  Creation Date          : 01/10/2008                                *
*  Author                 : Tom Renninger                             *
*  Application            : FI                                        *
*  Description            : Data extract for FI data                  *
*                                                                     *
*         This program was developed to extract data from SAP to      *
*         populate Business Strategy, Inc. (Third Party Software).    *
*                                                                     *
*  Type                   : Interface                                 *
*********************** Modification Log ******************************
*  Date      Init  Description                                        *
*  --------  ----  ---------------------------------------------------*
*  01/10/08  TPR   Initial Version                                    *
*                                                                     *
***********************************************************************
*-----------------------------------------------------------------------
*Tables
*-----------------------------------------------------------------------
TABLES:  lfa1,               " Vendor
         bsik,               " Accounting: Secondary Index for Vendors
         bsak,               " Accounting: Secondary Index for Vendors (
         bkpf,               " Accounting Document Header
         ekko,               " Purchasing Document Header
         payr,               " Payment Medium File
         reguh,              " Settlement data from payment program
         cdhdr,
*         tvarvc,             " Table of Variant Variables
         t001,               " Company Codes
         t001w.              " Plant/branches

*INCLUDE zbcin001    .        " Standard Report Heading Include

*=======================================================================
*  General Note on Field Naming Conventions
*
*          All "p_"   fields are Parameters
*          All "s_"   fields are Select-Options
*          All "c_"   fields are Constants
*          All "t_"   fields are temporary fields
*          All "i_"   fields are Input  Fields Local to Subroutine
*          All "o_"   fields are Output Fields Local to Subroutine
*
*=======================================================================

*_______________________________________________________________________
*Temp Fields / Tables

INCLUDE <icon>.

TYPE-POOLS: slis,      " Global types for generic list modules
            abap.


TYPES:

 BEGIN OF ty_lfa1,
   lifnr         TYPE lifnr,          " Account Number of Vendor or Cred
   land1         TYPE land1_gp,       " Country Key
   name1         TYPE name1_gp,                             " Name 1
   name2         TYPE name2_gp,                             " Name 2
   name3         TYPE name3_gp,                             " Name 3
   name4         TYPE name4_gp,                             " Name 4
   ort01         TYPE ort01_gp,       " City
   ort02         TYPE ort02_gp,       " District
   pfach         TYPE pfach,          " PO Box
   pstl2         TYPE pstl2,          " P.O. Box Postal Code
   pstlz         TYPE pstlz,          " Postal Code
   regio         TYPE regio,          " Region (State, Province, County)
   sperr         TYPE sperb_x,        " Central posting block
   sperm         TYPE sperm_x,        " Centrally imposed purchasing block
   stras         TYPE stras_gp,       " House number and street
   telf1         TYPE telf1,          " First telephone number
   telf2         TYPE telf2,          " Second telephone number
   telfx         TYPE telfx,          " Fax Number
   adrnr         TYPE adrnr,          " Address
   stcd1   TYPE stcd1,        " Tax Number 1
   stcd2   TYPE stcd2,        " Tax Number 2
   ktokk   TYPE ktokk,        " Vendor account group
   sperz         TYPE sperz,          " Payment block
 END OF ty_lfa1,

 BEGIN OF ty_bsik,
   bukrs  LIKE  bsik-bukrs,     " Company code
   lifnr  LIKE  bsik-lifnr,     " Vendor number
   umsks  LIKE  bsik-umsks,     " Special G/L transaction type
   umskz  LIKE  bsik-umskz,     " Special G/L indicator
   augdt  LIKE  bsik-augdt,     " Clear Date
   augbl  LIKE  bsik-augbl,     " Clearing Document
   zuonr  LIKE  bsik-zuonr,     " Allocation number
   gjahr  LIKE  bsik-gjahr,     " Fiscal year
   belnr  LIKE  bsik-belnr,     " Accounting document
   buzei  LIKE  bsik-buzei,     " Line item number
   budat  LIKE  bsik-budat,     " Posting Date
   bldat  LIKE  bsik-bldat,     " Document Date
   waers  LIKE  bsik-waers,     " Currency
   xblnr  LIKE  bsik-xblnr,     " Reference Document number
   blart  LIKE  bsik-blart,     " Document Type
   monat  LIKE  bsik-monat,     " Fiscal Period
   bschl  LIKE  bsik-bschl,     " Posting key
   shkzg  LIKE  bsik-shkzg,     " Debit Credit Indicator
   mwskz  LIKE  bsik-mwskz,     " Tax on sales / purchases code
   dmbtr  LIKE  bsik-dmbtr,     " Amount in local currency
   wrbtr  LIKE  bsik-wrbtr,     " Amount in document currency
   mwsts  LIKE  bsik-mwsts,     " Tax Amount in local
   wmwst  LIKE  bsik-wmwst,     " Tax Amount in document
   bdiff  LIKE  bsik-bdiff,	" Valuation difference	
   sgtxt  LIKE  bsik-sgtxt,     " Item Text
   ebeln  LIKE  bsik-ebeln,     "  Purchasing Document
   ebelp  LIKE  bsik-ebelp,     " Item number in purchasing document
   saknr  LIKE  bsik-saknr,     " G/L account number
   hkont  LIKE  bsik-hkont,     " G/L account number
   zfbdt  LIKE  bsik-zfbdt,     " Baseline Date
   zterm  LIKE  bsik-zterm,     " terms of payment
   zbd1t  LIKE  bsik-zbd1t,     " cash discount days 1
   zbd1p  LIKE  bsik-zbd1p,     " Cash discount percentage
   skfbt  LIKE  bsik-skfbt,     " Amount eligible for cash discount
   sknto  LIKE  bsik-sknto,     " Cash discount amount in local
   wskto  LIKE  bsik-wskto,     " Cash discount amount in document
   zlsch  LIKE  bsik-zlsch,     " Payment Method
   kostl  LIKE  bsik-kostl,     " cost center
   vertt  LIKE  bsik-vertt,     " contract type
   vertn  LIKE  bsik-vertn,     " contract number
   zlspr  LIKE  bsik-zlspr,     " Payment block key
 END OF ty_bsik,


 BEGIN OF ty_bsak,
   bukrs  LIKE  bsak-bukrs,      " Company code
   lifnr  LIKE  bsak-lifnr,      " Vendor number
   umsks  LIKE  bsak-umsks,      " Special G/L transaction type
   umskz  LIKE  bsak-umskz,      " Special G/L indicator
   augdt  LIKE  bsak-augdt,      " Clear Date
   augbl  LIKE  bsak-augbl,      " Clearing Document
   zuonr  LIKE  bsak-zuonr,      " Allocation number
   gjahr  LIKE  bsak-gjahr,      " Fiscal year
   belnr  LIKE  bsak-belnr,      " Accounting document
   buzei  LIKE  bsak-buzei,      " Line item number
   budat  LIKE  bsak-budat,      " Posting Date
   bldat  LIKE  bsak-bldat,      " Document Date
   waers  LIKE  bsak-waers,      " Currency
   xblnr  LIKE  bsak-xblnr,      " Reference Document number
   blart  LIKE  bsak-blart,      " Document Type
   monat  LIKE  bsak-monat,      " Fiscal Period
   bschl  LIKE  bsak-bschl,      " Posting key
   shkzg  LIKE  bsak-shkzg,      " Debit Credit Indicator
   mwskz  LIKE  bsak-mwskz,      " Tax on sales / purchases code
   dmbtr  LIKE  bsak-dmbtr,      " Amount in local currency
   wrbtr  LIKE  bsak-wrbtr,      " Amount in document currency
   mwsts  LIKE  bsak-mwsts,      " Tax Amount in local
   wmwst  LIKE  bsak-wmwst,      " Tax Amount in document
   bdiff  LIKE  bsik-bdiff,	 " Valuation difference
   sgtxt  LIKE  bsak-sgtxt,      " Item Text
   ebeln  LIKE  bsak-ebeln,      "  Purchasing Document
   ebelp  LIKE  bsak-ebelp,      " Item number in purchasing document
   saknr  LIKE  bsak-saknr,      " G/L account number
   hkont  LIKE  bsak-hkont,      " G/L account number
   zfbdt  LIKE  bsak-zfbdt,      " Baseline Date
   zterm  LIKE  bsak-zterm,      " terms of payment
   zbd1t  LIKE  bsak-zbd1t,      " cash discount days 1
   zbd1p  LIKE  bsak-zbd1p,      " Cash discount percentage
   skfbt  LIKE  bsak-skfbt,      " Amount eligible for cash discount
   sknto  LIKE  bsak-sknto,      " Cash discount amount in local
   wskto  LIKE  bsak-wskto,      " Cash discount amount in document
   zlsch  LIKE  bsak-zlsch,      " Payment Method
   kostl  LIKE  bsak-kostl,      " cost center
   vertt  LIKE  bsak-vertt,      " contract type
   vertn  LIKE  bsak-vertn,      " contract number
   zlspr  LIKE  bsak-zlspr,      " Payment block key
 END OF ty_bsak,


 BEGIN OF ty_bseg,
  bukrs  LIKE  bseg-bukrs,    " Company Code
  belnr  LIKE  bseg-belnr,    " Accounting Document Number
  gjahr  LIKE  bseg-gjahr,    " Fiscal year
  buzei  LIKE  bseg-buzei,    " Line Item number within the accounting
  augdt  LIKE  bseg-augdt,    " Clear Date
  augbl  LIKE  bseg-augbl,    " Clear Document
  buzid  LIKE  bseg-buzid,    " Identification of the Line Item
  bschl  LIKE  bseg-bschl,    " Posting key
  koart  LIKE  bseg-koart,    " Account type
  shkzg  LIKE  bseg-shkzg,    " Debit/credit indicator
  gsber  LIKE  bseg-gsber,    " Business Area
  mwskz  LIKE  bseg-mwskz,    " Tax code
  dmbtr  LIKE  bseg-dmbtr,    " Amount in local currency
  wrbtr  LIKE  bseg-wrbtr,    " Amount in document currency
  mwsts  LIKE  bseg-mwsts,    " Tax Amount in Local Currency
  hwbas  LIKE  bseg-hwbas,    " Tax Base Amount in Local Currency
  mwart  LIKE  bseg-mwart,    " Tax Type
  txgrp  LIKE  bseg-txgrp,    " Group Indicator for Tax Line Items
  sgtxt  LIKE  bseg-sgtxt,    " Item Text
  kostl  LIKE  bseg-kostl,    " Cost Center
  saknr  LIKE  bseg-saknr,     " G/L account number
  hkont  LIKE  bseg-hkont,    " General ledger account
  lifnr  LIKE  bseg-lifnr,    " Account number of vendor or credito
  mwsk1  LIKE  bseg-mwsk1,   " Tax Code for Distribution
  dmbt1  LIKE  bseg-dmbt1,   " Amount in Local Currency for Tax Di
  mwsk2  LIKE  bseg-mwsk2,   " Tax Code for Distribution
  dmbt2  LIKE  bseg-dmbt2,   " Amount in Local Currency for Tax Di
  mwsk3  LIKE  bseg-mwsk3,   " Tax Code for Distribution
  dmbt3  LIKE  bseg-dmbt3,   " Amount in Local Currency for Tax Di
  matnr  LIKE  bseg-matnr,   " Material number
  werks  LIKE  bseg-werks,   " Plant
  menge  LIKE  bseg-menge,   " Quantity
  meins  LIKE  bseg-meins,   " Base Unit of Measure
  ebeln  LIKE  bseg-ebeln,   " Purchasing Document Number
  ebelp  LIKE  bseg-ebelp,   " Item Number of Purchasing Document
  rewrt  LIKE  bseg-rewrt,   " Invoice value entered (in local cur
  rewwr  LIKE  bseg-rewwr,   " Invoice value entered (in foreign c
  prctr  LIKE  bseg-prctr,   " Profit center
  txjcd  LIKE  bseg-txjcd,   " Jurisdiction for tax calculation -
  kstrg  LIKE  bseg-kstrg,   " Cost Object
  vertt  LIKE  bseg-vertt,   " Contract type
  vertn  LIKE  bseg-vertn,   " Contract number
 END OF ty_bseg,



 BEGIN OF ty_bkpf,
  bukrs  LIKE  bkpf-bukrs,    " Company Code
  belnr  LIKE  bkpf-belnr,    " Accounting document number
  gjahr  LIKE  bkpf-gjahr,    " Fiscal year
  blart  LIKE  bkpf-blart,    " Document type
  budat  LIKE  bkpf-budat,    " Posting date in the document
  monat  LIKE  bkpf-monat,    " Fiscal period
  bvorg  LIKE  bkpf-bvorg,    " InterCompany Posting Procedure Number
  awtyp  LIKE  bkpf-awtyp,    " Object Type
  awkey  LIKE  bkpf-awkey,    " Object Key
  usnam	 LIKE  bkpf-usnam,    " User name
  xblnr  LIKE  bkpf-xblnr,    " Reference document number
  waers	 LIKE  bkpf-waers,    " Currency key
  kursf  LIKE  bkpf-kursf,    " Exchange rate
END OF ty_bkpf,


 BEGIN OF ty_bset,
  bukrs  LIKE  bset-bukrs,    " Company Code
  belnr  LIKE  bset-belnr,    " Accounting Document Number
  gjahr  LIKE  bset-gjahr,    " Fiscal Year
  buzei  LIKE  bset-buzei,    " Number of the Line Item within the Acc
  mwskz  LIKE  bset-mwskz,    " Tax Code
  txgrp  LIKE  bset-txgrp,    " Group indicator for tax line items
  shkzg  LIKE  bset-shkzg,    " debit / credit
  hwbas  LIKE  bset-hwbas,    " Tax Base Amount in Local Currency
  hwste  LIKE  bset-hwste,    " Tax Amount in Local Currency
  txjcd  LIKE  bset-txjcd,    " Jurisdiction for Tax Calculation - Tax
  kschl  LIKE  bset-kschl,    " Condition Type
  stbkz  LIKE  bset-stbkz,    " Posting indicator
 END OF ty_bset,


 BEGIN OF ty_ekko,
  ebeln   LIKE  ekko-ebeln,     " Purchasing Document Number
  bukrs   LIKE  ekko-bukrs,     " Company Code
  bstyp   LIKE  ekko-bstyp,     " purchasing document category
  bsart   LIKE  ekko-bsart,     " Purchasing document type
  loekz   LIKE  ekko-loekz,     " deletion indicator in purchasing
  statu   LIKE  ekko-statu,     " Status of purchasing document
  aedat   LIKE  ekko-aedat,     " record create date
  ernam   LIKE  ekko-ernam,     " User name
  lifnr   LIKE  ekko-lifnr,     " Vendor account number
  zterm   LIKE  ekko-zterm,     " Terms of payment key
  zbd1t   LIKE  ekko-zbd1t,     " Cash discount days
  zbd1p   LIKE  ekko-zbd1p,     " Cash discount percentage 1
  ekorg   LIKE  ekko-ekorg,     " Purchasing organization
  ekgrp   LIKE  ekko-ekgrp,     " purchasing group
  bedat   LIKE  ekko-bedat,     " Purchasing document Date
  inco1   LIKE  ekko-inco1,     " Incoterms
  inco2   LIKE  ekko-inco2,     " Incoterms
  kdatb   LIKE  ekko-kdatb,     " Start of Validity Period
  kdate   LIKE  ekko-kdate,     " End of Validity Period
  konnr   LIKE  ekko-konnr,     " Number of Principle Purchase Agre
 END OF ty_ekko,

 BEGIN OF ty_ekpo,
  ebeln   LIKE  ekpo-ebeln,     " Purchasing document
  ebelp   LIKE  ekpo-ebelp,     " Item number of Purchasing documen
  loekz   LIKE  ekpo-loekz,     " deletion indicator
  aedat   LIKE  ekpo-aedat,     " Item change date
  txz01   LIKE  ekpo-txz01,     " Short Text
  matnr   LIKE  ekpo-matnr,     " material number
  ematn   LIKE  ekpo-ematn,     " material number
  bukrs   LIKE  ekpo-bukrs,     " Company code
  werks   LIKE  ekpo-werks,     " Plant
  matkl   LIKE  ekpo-matkl,     " Material group
  idnlf   LIKE  ekpo-idnlf,     " Material number used by vendor
  ktmng   LIKE  ekpo-ktmng,     " Target Qty
  menge   LIKE  ekpo-menge,     " po quantity
  meins   LIKE  ekpo-meins,     " order unit
  bprme   LIKE  ekpo-bprme,     " order price unit
  bpumz   LIKE  ekpo-bpumz,     " numerator
  bpumn   LIKE  ekpo-bpumn,     " denominator
  umrez   LIKE  ekpo-umrez,     " numerator
  umren   LIKE  ekpo-umren,     " denominator
  netpr   LIKE  ekpo-netpr,     " net price
  peinh   LIKE  ekpo-peinh,     " price unit
  netwr   LIKE  ekpo-netwr,     " po value
  brtwr   LIKE  ekpo-brtwr,     " po value
  konnr   LIKE  ekpo-konnr,     " number of the principle purchase
  ktpnr   LIKE  ekpo-ktpnr,     " Item number of principle purchase
  lmein   LIKE  ekpo-lmein,     " base unit of measure
  zwert   LIKE  ekpo-zwert,     " Target value for outline agreeme
  effwr   LIKE  ekpo-effwr,     " Effective value
  ntgew   LIKE  ekpo-ntgew,     " net weight
  gewei   LIKE  ekpo-gewei,     " Unit of weight
  brgew   LIKE  ekpo-brgew,     " Gross Weight
  volum   LIKE  ekpo-volum,     " volume
  voleh   LIKE  ekpo-voleh,     " Volume unit
  xersy   LIKE  ekpo-xersy,     " ERS
  retpo   LIKE  ekpo-retpo,     "returns item
 END OF ty_ekpo,

 BEGIN OF ty_ekbe,
  ebeln   LIKE  ekbe-ebeln,     " Purchasing Document Number
  ebelp   LIKE  ekbe-ebelp,     " Item Number of Purchasing Doc
  zekkn   LIKE  ekbe-zekkn,     " Sequential number of account
  vgabe   LIKE  ekbe-vgabe,     " Transaction/event type, purch
  gjahr   LIKE  ekbe-gjahr,     " Material Document Year
  belnr   LIKE  ekbe-belnr,     " Number of Material Document
  buzei   LIKE  ekbe-buzei,     " Item in Material Document
  bewtp   LIKE  ekbe-bewtp,     " po history category
  bwart   LIKE  ekbe-bwart,     " movement type
  budat   LIKE  ekbe-budat,     " posting date of the document
  menge   LIKE  ekbe-menge,     " quantity
  bpmng   LIKE  ekbe-bpmng,     " quantity in purchase order price u
  dmbtr   LIKE  ekbe-dmbtr,     " amount in local
  wrbtr   LIKE  ekbe-wrbtr,     " amount in document
  waers   LIKE  ekbe-waers,     " currency key
  arewr   LIKE  ekbe-arewr,     " GR/IR account clearing value
  wesbs   LIKE  ekbe-wesbs,     " GR block
  bpwes   LIKE  ekbe-bpwes,     " qty GR block
  shkzg   LIKE  ekbe-shkzg,     " Debit Credit indicator
  bwtar   LIKE  ekbe-bwtar,     " Valuation type
  elikz   LIKE  ekbe-elikz,     " Delivery Complete
  xblnr   LIKE  ekbe-xblnr,     " Reference document number
  lfgja   LIKE  ekbe-lfgja,     " Fiscal year of the reference docu
  lfbnr	  LIKE  ekbe-lfbnr,	" Document number of a reference doc
  lfpos   LIKE  ekbe-lfpos,     " Item of a reference document
  grund   LIKE  ekbe-grund,     " Reason for movement
  cpudt   LIKE  ekbe-cpudt,     " entry date
  cputm	  LIKE  ekbe-cputm,     " entry time
  reewr   LIKE  ekbe-reewr,     " Invoice value in local currency
  refwr   LIKE  ekbe-refwr,     " Invoice value in foreign currency
  matnr   LIKE  ekbe-matnr,     " material number
  werks   LIKE  ekbe-werks,     " plant
  lsmng   LIKE  ekbe-lsmng,     " qty in uom from delivery
  lsmeh   LIKE  ekbe-lsmeh,     " Unit of measure from delivery
  ematn   LIKE  ekbe-ematn,     " material number
  areww   LIKE  ekbe-areww,     " Clearing value on GR/IR
  bamng   LIKE  ekbe-bamng,     " qty
  bldat   LIKE  ekbe-bldat,     " document date
*  lemin   like  ekbe-lemin,    " Returns item
 END OF ty_ekbe,

 BEGIN OF ty_ekkn,
  ebeln   LIKE  ekkn-ebeln,     "/h/Purchasing Document Number
  ebelp   LIKE  ekkn-ebelp,     "/h/Item number of the purchasing doc
  sakto   LIKE  ekkn-sakto,     "/h/GL account number
  gsber   LIKE  ekkn-gsber,     "/h/Business Area
  kostl   LIKE  ekkn-kostl,     "/h/Cost Center
  anln1   LIKE  ekkn-anln1,     "/h/Main Asset Number
  anln2   LIKE  ekkn-anln2,     "/h/Asset Sub Number
  aufnr   LIKE  ekkn-aufnr,     "/h/Order Number
  kstrg   LIKE  ekkn-kstrg,     "/h/Cost Object
  ps_psp_pnr   LIKE  ekkn-ps_psp_pnr, " Work Breakdown Structure Ele
 END OF ty_ekkn,


 BEGIN OF ty_payr,
  zbukr   LIKE   payr-zbukr,    " Company code
  hbkid   LIKE   payr-hbkid,    " ID for house bank
  hktid   LIKE   payr-hktid,    " ID for account details
  rzawe   LIKE   payr-rzawe,    " Payment method
  chect   LIKE   payr-chect,    " Check number
  laufd   LIKE   payr-laufd,    " Date for program
  lifnr   LIKE   payr-lifnr,    " vendor number
  vblnr   LIKE   payr-vblnr,    " Document of the payment
  gjahr   LIKE   payr-gjahr,    " Fiscal Year
  zaldt   LIKE   payr-zaldt,    " Probable Payment date
  waers   LIKE   payr-waers,    " Currency Key
  rwbtr   LIKE   payr-rwbtr,    " Amount paid in payment currency
  pridt   LIKE   payr-pridt,    " Print Date
  bancd   LIKE   payr-bancd,    " Encashment Date
  znme1   LIKE   payr-znme1,    " name of the Payee
  voidr   LIKE   payr-voidr,    " void reason
  voidd   LIKE   payr-voidd,    " voided check
  checv   LIKE   payr-checv,    " Replacement check number
 END OF ty_payr,

 BEGIN OF ty_reguh,
  laufd   LIKE   reguh-laufd,     " Program date
  zbukr   LIKE   reguh-zbukr,     " paying company code
  lifnr   LIKE   reguh-lifnr,     " vendor number
  vblnr   LIKE   reguh-vblnr,     " document number of the payment
  waers   LIKE   reguh-waers,     " currency
  name1   LIKE   reguh-name1,                               " name1
  zaldt   LIKE   reguh-zaldt,     " posting date
  rzawe   LIKE   reguh-rzawe,     " payment method
  rbetr   LIKE   reguh-rbetr,     " amount in local currency
  rskon   LIKE   reguh-rskon,     " total cash discount
  rwbtr   LIKE   reguh-rwbtr,     " amount paid in payment currency
  rwskt   LIKE   reguh-rwskt,     " total cash discount in payment
  rpost   LIKE   reguh-rpost,     " number of items paid
 END OF ty_reguh,

 BEGIN OF ty_skat,
  spras   LIKE   skat-spras,     " Language Key
  ktopl   LIKE   skat-ktopl,     " Chart of Accounts
  saknr   LIKE   skat-saknr,     " G/L Account Number
  txt20   LIKE   skat-txt20,     " G/L account short text
  txt50   LIKE   skat-txt50,     " G/L account long text
 END OF ty_skat,

 BEGIN OF ty_cdhdr,
  objectclas     LIKE   cdhdr-objectclas,     " Object class
  objectid       LIKE   cdhdr-objectid,       " Object value
  changenr       LIKE   cdhdr-changenr,       " Document change nu
  username       LIKE   cdhdr-username,       " User Name
  udate          LIKE   cdhdr-udate,          " Creation Date
  tcode          LIKE   cdhdr-tcode,          " Transaction code
  planchngnr     LIKE   cdhdr-planchngnr,     " Planned change
  act_chngno     LIKE   cdhdr-act_chngno,     " Change number
  change_ind     LIKE   cdhdr-change_ind,     " Change type
 END OF ty_cdhdr,


 BEGIN OF ty_cdpos,
  objectclasv  LIKE   cdpos-objectclas,   " Object class
  objectid     LIKE   cdpos-objectid,     " Object value
  changenr     LIKE   cdpos-changenr,     " Document change number
  tabname      LIKE   cdpos-tabname,      " Table Name
  tabkey       LIKE   cdpos-tabkey,       " Changed table record key
  fname        LIKE   cdpos-fname,        " Field Name
  chngind      LIKE   cdpos-chngind,      " Change type (U, I, E, D)
  text_case    LIKE   cdpos-text_case,    " Flag: X=Text change
  unit_old     LIKE   cdpos-unit_old,     " Change documents, unit r
  unit_new     LIKE   cdpos-unit_new,     " Change documents, unit re
  cuky_old     LIKE   cdpos-cuky_old,     " Change documents, referen
  cuky_new     LIKE   cdpos-cuky_new,     " Change documents, referen
  value_new    LIKE   cdpos-value_new,    " New contents of chan
  value_old    LIKE   cdpos-value_old,    " Old contents of chan
 END OF ty_cdpos,


 BEGIN OF ty_objectclas,
   sign(01)      TYPE c,
   option(02)    TYPE c,
   low           TYPE cdobjectcl,
   high          TYPE cdobjectcl,
 END OF ty_objectclas,

 BEGIN OF ty_tabname,
   sign(01)      TYPE c,
   option(02)    TYPE c,
   low           TYPE tabname,
   high          TYPE tabname,
 END OF ty_tabname,

 BEGIN OF ty_fname,
   sign(01)      TYPE c,
   option(02)    TYPE c,
   low           TYPE fieldname,
   high          TYPE fieldname,
 END OF ty_fname,


 BEGIN OF ty_dnl_file,
   line(2000)    TYPE c,              " output line for extract file
 END OF ty_dnl_file.

* Internal Tables
DATA:
  zlfa1_tab         TYPE STANDARD TABLE OF ty_lfa1     WITH HEADER LINE,
  zbsik_tab         TYPE STANDARD TABLE OF ty_bsik     WITH HEADER LINE,
  zbsak_tab         TYPE STANDARD TABLE OF ty_bsak     WITH HEADER LINE,
  zbseg_tab         TYPE STANDARD TABLE OF ty_bseg     WITH HEADER LINE,
  zbkpf_tab         TYPE STANDARD TABLE OF ty_bkpf     WITH HEADER LINE,
  zbset_tab         TYPE STANDARD TABLE OF ty_bset     WITH HEADER LINE,
  zekko_tab         TYPE STANDARD TABLE OF ty_ekko     WITH HEADER LINE,
  zekpo_tab         TYPE STANDARD TABLE OF ty_ekpo     WITH HEADER LINE,
  zekbe_tab         TYPE STANDARD TABLE OF ty_ekbe     WITH HEADER LINE,
  zekkn_tab         TYPE STANDARD TABLE OF ty_ekkn     WITH HEADER LINE,
  zpayr_tab         TYPE STANDARD TABLE OF ty_payr     WITH HEADER LINE,
  zreguh_tab        TYPE STANDARD TABLE OF ty_reguh    WITH HEADER LINE,
  zskat_tab         TYPE STANDARD TABLE OF ty_skat     WITH HEADER LINE,
  zt156_tab         TYPE STANDARD TABLE OF t156        WITH HEADER LINE,
  zcdhdr_tab        TYPE STANDARD TABLE OF cdhdr       WITH HEADER LINE,
  zcdpos_tab        TYPE STANDARD TABLE OF cdpos       WITH HEADER LINE,
  zobjectclas_tab   TYPE STANDARD TABLE OF ty_objectclas
                                                       WITH HEADER LINE,
  ztabname_tab      TYPE STANDARD TABLE OF ty_tabname  WITH HEADER LINE,
  zfname_tab        TYPE STANDARD TABLE OF ty_fname    WITH HEADER LINE,

  z_dnl_file_tab    TYPE STANDARD TABLE OF ty_dnl_file WITH HEADER LINE,

  z_dnl_file_wa     TYPE ty_dnl_file.

DATA: BEGIN OF t_contract_tab OCCURS 0,
      konnr   LIKE  ekko-konnr.
DATA: END OF t_contract_tab.

DATA: BEGIN OF t_download_unix OCCURS 0,
      rrcty(1),                           " Record Type
      ryear(4),                           " Fiscal Year
      rtcur(5),                           " Currency Key
      drcrk(1),                           " Debit/Credit Indicator
      rbukrs(4),                          " Company Code
      racct(10),                          " Account number
      acctxt(50),                         " Account Descr
      rcntr(10),                          " Cost Center
      rprctr(10),                         " Profit Center
      rzzvbund(6),                        " Trading Partner
      rzzmkt(3),                          " Market
      rzzanbwa(3),                        " Asset Transaction Type
      lc_value(20),                       " Total LC Value
      gc_value(20).                       " Total GC Value
DATA: END OF t_download_unix.

DATA: BEGIN OF t_download_unix_2 OCCURS 0,
      fil(2000).
DATA: END OF t_download_unix_2.

DATA: BEGIN OF info OCCURS 20,
        flag,
        olength   TYPE x,
        line      LIKE raldb-infoline.
DATA: END OF info.


DATA:  t_unix      LIKE authb-filename,        " UNIX Filename
       t_pcfile    TYPE localfile,             " PC File
       t_dldir           TYPE localfile,       " PC Download Directory

       t_rpt_heading_sw,                       " Report Switch
       t_lines TYPE i,                         " # of lines in Z_ZHYPERT
       t_first_rec_sw    VALUE 'Y',            " First Record Switch
       t_header_line3(132),                    " Report name
       t_separator        VALUE ',',           " Unix Separator
       t_encoding_u       TYPE abap_encod,     " Codepage for UNIX download
       t_encoding         TYPE abap_encod,     " Codepage
       file1              LIKE filename-fileextern,    " Filename
       t_filename         LIKE rlgrap-filename,  " PC Filename
       t_download         LIKE STANDARD TABLE OF t_download_unix_2,
       t_fullpath         TYPE string,         " Path + Filename
       t_download_ctr     TYPE i,              " Download Counter
       t_delete_index     LIKE sy-tabix,       " Index
       t_dir              TYPE string,         " Path
       t_file_table       TYPE filetable,      " Table
       t_filedat          TYPE string,         " Filename
       t_rc               LIKE sy-subrc,       " Return Code
       t_buffer_size      TYPE i.              " Buffer size for output

DATA:  t_inx               TYPE i,
       t_line(2000)        TYPE c,
       t_pos               TYPE i,
       t_char_field(500)   TYPE c.

*data:  t_fields         type  table of fieldname with header line,
DATA:  t_details        TYPE  abap_compdescr_tab,
       t_details_wa     TYPE  abap_compdescr.

DATA:  lt_line(2000)        TYPE c,
       lt_pos               TYPE i,
       lt_char_field(500)   TYPE c.

DATA:  ref_descr TYPE REF TO cl_abap_structdescr.


*** Definition of Cursors

DATA: t_cursor_1 TYPE cursor,
      t_cursor_2 TYPE cursor,
      t_cursor_3 TYPE cursor,
      t_cursor_4 TYPE cursor.


*Constants
DATA:  c_separator        VALUE '|',
       c_sy_repid         LIKE sy-repid           VALUE 'Z_EXCEL_CODE',
       c_sy_repid_u       LIKE sy-repid           VALUE 'Z_UNIX_CODEP',
       c_objectclas       LIKE cdhdr-objectclas   VALUE 'EINKBELEG',
       c_ekpo             LIKE cdpos-tabname      VALUE 'EKPO',
       c_ekko             LIKE cdpos-tabname      VALUE 'EKKO',
       c_brtwr            LIKE cdpos-fname        VALUE 'BRTWR',
       c_effwr            LIKE cdpos-fname        VALUE 'EFFWR',
       c_netwr            LIKE cdpos-fname        VALUE 'NETWR',
       c_menge            LIKE cdpos-fname        VALUE 'MENGE',
       c_netpr            LIKE cdpos-fname        VALUE 'NETPR',
       c_kdatb            LIKE cdpos-fname        VALUE 'KDATB',
       c_kdate            LIKE cdpos-fname        VALUE 'KDATE',
       c_buffer_size      TYPE i                  VALUE 15000.


** Field Symbols

FIELD-SYMBOLS: <f>.


*_______________________________________________________________________
* Parameters / Select Options

*Selection Screen
SELECTION-SCREEN BEGIN OF SCREEN 1100 AS SUBSCREEN.

SELECTION-SCREEN BEGIN OF BLOCK block1 WITH FRAME TITLE text-s01.

SELECT-OPTIONS: s_bukrs  FOR ekko-bukrs.

SELECTION-SCREEN SKIP 1.

SELECT-OPTIONS: s_augdt  FOR bsak-augdt OBLIGATORY DEFAULT sy-datum.

SELECTION-SCREEN SKIP 1.

SELECT-OPTIONS: s_budat  FOR bkpf-budat OBLIGATORY DEFAULT sy-datum,
                s_blart  FOR bkpf-blart OBLIGATORY DEFAULT 'DR'.

SELECTION-SCREEN SKIP 1.

SELECT-OPTIONS:  s_bsart  FOR ekko-bsart OBLIGATORY DEFAULT 'NB',
                 s_aedat  FOR ekko-aedat OBLIGATORY DEFAULT sy-datum.

SELECTION-SCREEN SKIP 1.

SELECT-OPTIONS: s_laufd  FOR payr-laufd  OBLIGATORY DEFAULT sy-datum.

SELECTION-SCREEN SKIP 1.

SELECT-OPTIONS: s_udate  FOR cdhdr-udate OBLIGATORY DEFAULT sy-datum.


*PARAMETERS:  p_rpmax LIKE zhypert-rpmax             " Period
*                          .
*
SELECTION-SCREEN END   OF BLOCK block1.

SELECTION-SCREEN END OF SCREEN 1100.

*-----------------------------------------------------------------------
* Output File Options
*-----------------------------------------------------------------------
SELECTION-SCREEN BEGIN OF SCREEN 1200 AS SUBSCREEN.

SELECTION-SCREEN BEGIN OF BLOCK block2 WITH FRAME.

* Select Table LFA1 to download
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: p_lfa1  AS CHECKBOX.
SELECTION-SCREEN COMMENT 5(30) text-p01.
SELECTION-SCREEN END   OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS:
  p_ulfa1 RADIOBUTTON GROUP grp1 DEFAULT 'X'.
SELECTION-SCREEN COMMENT 5(10) text-p02.
SELECTION-SCREEN POSITION 25.
PARAMETERS:
  p_flfa1    LIKE rlgrap-filename.
SELECTION-SCREEN END   OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS:
  p_plfa1 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN COMMENT 5(10) text-p03.
SELECTION-SCREEN POSITION 25.
PARAMETERS:
  p_clfa1    LIKE rlgrap-filename.
SELECTION-SCREEN END   OF LINE.

SELECTION-SCREEN END OF BLOCK block2.

SELECTION-SCREEN BEGIN OF BLOCK block3 WITH FRAME TITLE text-f01.

* Select Table bkpf to download
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: p_bkpf  AS CHECKBOX.
SELECTION-SCREEN COMMENT 5(30) text-p10.
SELECTION-SCREEN END   OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS:
  p_ubkpf RADIOBUTTON GROUP grp5 DEFAULT 'X'.
SELECTION-SCREEN COMMENT 5(10) text-p02.
SELECTION-SCREEN POSITION 25.
PARAMETERS:
  p_fbkpf    LIKE rlgrap-filename.
SELECTION-SCREEN END   OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS:
  p_pbkpf RADIOBUTTON GROUP grp5.
SELECTION-SCREEN COMMENT 5(10) text-p03.
SELECTION-SCREEN POSITION 25.
PARAMETERS:
  p_cbkpf    LIKE rlgrap-filename.
SELECTION-SCREEN END   OF LINE.

SELECTION-SCREEN SKIP 1.

* Select Table bseg to download
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: p_bseg  AS CHECKBOX.
SELECTION-SCREEN COMMENT 5(30) text-p09.
SELECTION-SCREEN END   OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS:
  p_ubseg RADIOBUTTON GROUP grp4 DEFAULT 'X'.
SELECTION-SCREEN COMMENT 5(10) text-p02.
SELECTION-SCREEN POSITION 25.
PARAMETERS:
  p_fbseg    LIKE rlgrap-filename.
SELECTION-SCREEN END   OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS:
  p_pbseg RADIOBUTTON GROUP grp4.
SELECTION-SCREEN COMMENT 5(10) text-p03.
SELECTION-SCREEN POSITION 25.
PARAMETERS:
  p_cbseg    LIKE rlgrap-filename.
SELECTION-SCREEN END   OF LINE.

SELECTION-SCREEN SKIP 1.

* Select Table bsik to download
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: p_bsik  AS CHECKBOX.
SELECTION-SCREEN COMMENT 5(30) text-p07.
SELECTION-SCREEN END   OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS:
  p_ubsik RADIOBUTTON GROUP grp2 DEFAULT 'X'.
SELECTION-SCREEN COMMENT 5(10) text-p02.
SELECTION-SCREEN POSITION 25.
PARAMETERS:
  p_fbsik    LIKE rlgrap-filename.
SELECTION-SCREEN END   OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS:
  p_pbsik RADIOBUTTON GROUP grp2.
SELECTION-SCREEN COMMENT 5(10) text-p03.
SELECTION-SCREEN POSITION 25.
PARAMETERS:
  p_cbsik    LIKE rlgrap-filename.
SELECTION-SCREEN END   OF LINE.

SELECTION-SCREEN SKIP 1.

* Select Table bsak to download
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: p_bsak  AS CHECKBOX.
SELECTION-SCREEN COMMENT 5(30) text-p08.
SELECTION-SCREEN END   OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS:
  p_ubsak RADIOBUTTON GROUP grp3 DEFAULT 'X'.
SELECTION-SCREEN COMMENT 5(10) text-p02.
SELECTION-SCREEN POSITION 25.
PARAMETERS:
  p_fbsak    LIKE rlgrap-filename.
SELECTION-SCREEN END   OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS:
  p_pbsak RADIOBUTTON GROUP grp3.
SELECTION-SCREEN COMMENT 5(10) text-p03.
SELECTION-SCREEN POSITION 25.
PARAMETERS:
  p_cbsak    LIKE rlgrap-filename.
SELECTION-SCREEN END   OF LINE.

SELECTION-SCREEN SKIP 1.

* Select Table bset to download
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: p_bset  AS CHECKBOX.
SELECTION-SCREEN COMMENT 5(30) text-p15.
SELECTION-SCREEN END   OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS:
  p_ubset RADIOBUTTON GROUP grpa DEFAULT 'X'.
SELECTION-SCREEN COMMENT 5(10) text-p02.
SELECTION-SCREEN POSITION 25.
PARAMETERS:
  p_fbset    LIKE rlgrap-filename.
SELECTION-SCREEN END   OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS:
  p_pbset RADIOBUTTON GROUP grpa.
SELECTION-SCREEN COMMENT 5(10) text-p03.
SELECTION-SCREEN POSITION 25.
PARAMETERS:
  p_cbset    LIKE rlgrap-filename.
SELECTION-SCREEN END   OF LINE.

SELECTION-SCREEN END OF BLOCK block3.

SELECTION-SCREEN BEGIN OF BLOCK block4 WITH FRAME TITLE text-f02.

* Select Table ekko to download
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: p_ekko  AS CHECKBOX.
SELECTION-SCREEN COMMENT 5(30) text-p11.
SELECTION-SCREEN END   OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 5(30) text-p22.
SELECTION-SCREEN END   OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS:
  p_uekko RADIOBUTTON GROUP grp6 DEFAULT 'X'.
SELECTION-SCREEN COMMENT 5(10) text-p02.
SELECTION-SCREEN POSITION 25.
PARAMETERS:
  p_fekko    LIKE rlgrap-filename.
SELECTION-SCREEN END   OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS:
  p_pekko RADIOBUTTON GROUP grp6.
SELECTION-SCREEN COMMENT 5(10) text-p03.
SELECTION-SCREEN POSITION 25.
PARAMETERS:
  p_cekko    LIKE rlgrap-filename.
SELECTION-SCREEN END   OF LINE.

SELECTION-SCREEN SKIP 1.

* Select Table ekpo to download
SELECTION-SCREEN BEGIN OF LINE.
*PARAMETERS: p_ekpo  AS CHECKBOX.
SELECTION-SCREEN COMMENT 5(30) text-p12.
SELECTION-SCREEN END   OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS:
  p_uekpo RADIOBUTTON GROUP grp7 DEFAULT 'X'.
SELECTION-SCREEN COMMENT 5(10) text-p02.
SELECTION-SCREEN POSITION 25.
PARAMETERS:
  p_fekpo    LIKE rlgrap-filename.
SELECTION-SCREEN END   OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS:
  p_pekpo RADIOBUTTON GROUP grp7.
SELECTION-SCREEN COMMENT 5(10) text-p03.
SELECTION-SCREEN POSITION 25.
PARAMETERS:
  p_cekpo    LIKE rlgrap-filename.
SELECTION-SCREEN END   OF LINE.

SELECTION-SCREEN SKIP 1.

* Select Table ekbe to download
SELECTION-SCREEN BEGIN OF LINE.
*PARAMETERS: p_ekbe  AS CHECKBOX.
SELECTION-SCREEN COMMENT 5(30) text-p13.
SELECTION-SCREEN END   OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS:
  p_uekbe RADIOBUTTON GROUP grp8 DEFAULT 'X'.
SELECTION-SCREEN COMMENT 5(10) text-p02.
SELECTION-SCREEN POSITION 25.
PARAMETERS:
  p_fekbe    LIKE rlgrap-filename.
SELECTION-SCREEN END   OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS:
  p_pekbe RADIOBUTTON GROUP grp8.
SELECTION-SCREEN COMMENT 5(10) text-p03.
SELECTION-SCREEN POSITION 25.
PARAMETERS:
  p_cekbe    LIKE rlgrap-filename.
SELECTION-SCREEN END   OF LINE.

SELECTION-SCREEN SKIP 1.

* Select Table ekkn to download
SELECTION-SCREEN BEGIN OF LINE.
*PARAMETERS: p_ekkn  AS CHECKBOX.
SELECTION-SCREEN COMMENT 5(30) text-p14.
SELECTION-SCREEN END   OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS:
  p_uekkn RADIOBUTTON GROUP grp9 DEFAULT 'X'.
SELECTION-SCREEN COMMENT 5(10) text-p02.
SELECTION-SCREEN POSITION 25.
PARAMETERS:
  p_fekkn    LIKE rlgrap-filename.
SELECTION-SCREEN END   OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS:
  p_pekkn RADIOBUTTON GROUP grp9.
SELECTION-SCREEN COMMENT 5(10) text-p03.
SELECTION-SCREEN POSITION 25.
PARAMETERS:
  p_cekkn    LIKE rlgrap-filename.
SELECTION-SCREEN END   OF LINE.

SELECTION-SCREEN SKIP 1.


SELECTION-SCREEN END OF BLOCK block4.

SELECTION-SCREEN BEGIN OF BLOCK block5 WITH FRAME TITLE text-f03.

* Select Table payr to download
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: p_payr  AS CHECKBOX.
SELECTION-SCREEN COMMENT 5(30) text-p16.
SELECTION-SCREEN END   OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS:
  p_upayr RADIOBUTTON GROUP grpb DEFAULT 'X'.
SELECTION-SCREEN COMMENT 5(10) text-p02.
SELECTION-SCREEN POSITION 25.
PARAMETERS:
  p_fpayr    LIKE rlgrap-filename.
SELECTION-SCREEN END   OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS:
  p_ppayr RADIOBUTTON GROUP grpb.
SELECTION-SCREEN COMMENT 5(10) text-p03.
SELECTION-SCREEN POSITION 25.
PARAMETERS:
  p_cpayr    LIKE rlgrap-filename.
SELECTION-SCREEN END   OF LINE.

SELECTION-SCREEN SKIP 1.

* Select Table reguh to download
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: p_reguh  AS CHECKBOX.
SELECTION-SCREEN COMMENT 5(30) text-p17.
SELECTION-SCREEN END   OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS:
  p_ureguh RADIOBUTTON GROUP grpc DEFAULT 'X'.
SELECTION-SCREEN COMMENT 5(10) text-p02.
SELECTION-SCREEN POSITION 25.
PARAMETERS:
  p_freguh    LIKE rlgrap-filename.
SELECTION-SCREEN END   OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS:
  p_preguh RADIOBUTTON GROUP grpc.
SELECTION-SCREEN COMMENT 5(10) text-p03.
SELECTION-SCREEN POSITION 25.
PARAMETERS:
  p_creguh    LIKE rlgrap-filename.
SELECTION-SCREEN END   OF LINE.

SELECTION-SCREEN END OF BLOCK block5.

SELECTION-SCREEN BEGIN OF BLOCK block6 WITH FRAME.

* Select Table payr to download
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: p_skat  AS CHECKBOX.
SELECTION-SCREEN COMMENT 5(30) text-p18.
SELECTION-SCREEN END   OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS:
  p_uskat RADIOBUTTON GROUP grpd DEFAULT 'X'.
SELECTION-SCREEN COMMENT 5(10) text-p02.
SELECTION-SCREEN POSITION 25.
PARAMETERS:
  p_fskat    LIKE rlgrap-filename.
SELECTION-SCREEN END   OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS:
  p_pskat RADIOBUTTON GROUP grpd.
SELECTION-SCREEN COMMENT 5(10) text-p03.
SELECTION-SCREEN POSITION 25.
PARAMETERS:
  p_cskat    LIKE rlgrap-filename.
SELECTION-SCREEN END   OF LINE.

SELECTION-SCREEN SKIP 1.

* Select Table T156 to download
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: p_t156  AS CHECKBOX.
SELECTION-SCREEN COMMENT 5(30) text-p19.
SELECTION-SCREEN END   OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS:
  p_ut156 RADIOBUTTON GROUP grpe DEFAULT 'X'.
SELECTION-SCREEN COMMENT 5(10) text-p02.
SELECTION-SCREEN POSITION 25.
PARAMETERS:
  p_ft156    LIKE rlgrap-filename.
SELECTION-SCREEN END   OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS:
  p_pt156 RADIOBUTTON GROUP grpe.
SELECTION-SCREEN COMMENT 5(10) text-p03.
SELECTION-SCREEN POSITION 25.
PARAMETERS:
  p_ct156    LIKE rlgrap-filename.
SELECTION-SCREEN END   OF LINE.

SELECTION-SCREEN END OF BLOCK block6.

SELECTION-SCREEN BEGIN OF BLOCK block7 WITH FRAME.

* Select Table cdhdr to download
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: p_cdhdr  AS CHECKBOX.
SELECTION-SCREEN COMMENT 5(30) text-p20.
SELECTION-SCREEN END   OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 5(30) text-p23.
SELECTION-SCREEN END   OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS:
  p_ucdhdr RADIOBUTTON GROUP grpf DEFAULT 'X'.
SELECTION-SCREEN COMMENT 5(10) text-p02.
SELECTION-SCREEN POSITION 25.
PARAMETERS:
  p_fcdhdr    LIKE rlgrap-filename.
SELECTION-SCREEN END   OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS:
  p_pcdhdr RADIOBUTTON GROUP grpf.
SELECTION-SCREEN COMMENT 5(10) text-p03.
SELECTION-SCREEN POSITION 25.
PARAMETERS:
  p_ccdhdr    LIKE rlgrap-filename.
SELECTION-SCREEN END   OF LINE.

SELECTION-SCREEN SKIP 1.

* Select Table cdpos to download
SELECTION-SCREEN BEGIN OF LINE.
*PARAMETERS: p_cdpos  AS CHECKBOX.
SELECTION-SCREEN COMMENT 5(30) text-p21.
SELECTION-SCREEN END   OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS:
  p_ucdpos RADIOBUTTON GROUP grpg DEFAULT 'X'.
SELECTION-SCREEN COMMENT 5(10) text-p02.
SELECTION-SCREEN POSITION 25.
PARAMETERS:
  p_fcdpos    LIKE rlgrap-filename.
SELECTION-SCREEN END   OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS:
  p_pcdpos RADIOBUTTON GROUP grpg.
SELECTION-SCREEN COMMENT 5(10) text-p03.
SELECTION-SCREEN POSITION 25.
PARAMETERS:
  p_ccdpos    LIKE rlgrap-filename.
SELECTION-SCREEN END   OF LINE.

SELECTION-SCREEN END OF BLOCK block7.

SELECTION-SCREEN END OF SCREEN 1200.

*-----------------------------------------------------------------------
* Unicode File Options
*-----------------------------------------------------------------------
SELECTION-SCREEN BEGIN OF SCREEN 1300 AS SUBSCREEN.

SELECTION-SCREEN BEGIN OF BLOCK block80 WITH FRAME.

* Selection indicator for Unicode Files
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: p_unicd    AS CHECKBOX  DEFAULT ' '.
SELECTION-SCREEN COMMENT 5(30) text-p04.
SELECTION-SCREEN END   OF LINE.

SELECTION-SCREEN SKIP 1.

* Unix Unicode Parameter
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(31) text-p05.
PARAMETERS: p_uunicd    LIKE tcp00-cpcodepage  DEFAULT '1160'.
SELECTION-SCREEN END   OF LINE.

* PC File Unicode Parameter
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(31) text-p06.
PARAMETERS: p_cunicd    LIKE tcp00-cpcodepage  DEFAULT '4103'.
SELECTION-SCREEN END   OF LINE.

SELECTION-SCREEN END OF BLOCK block80.

SELECTION-SCREEN END OF SCREEN 1300.

**----------------------------------------------------------------------
*
SELECTION-SCREEN BEGIN OF TABBED BLOCK tabs FOR 35 LINES.
SELECTION-SCREEN TAB (18) tabs1 USER-COMMAND ucomm1
 DEFAULT SCREEN 1100.
SELECTION-SCREEN TAB (25) tabs2 USER-COMMAND ucomm2
 DEFAULT SCREEN 1200.
SELECTION-SCREEN TAB (25) tabs3 USER-COMMAND ucomm3
 DEFAULT SCREEN 1300.

SELECTION-SCREEN END OF BLOCK tabs.
*

************************************************************************
*-----------------------------------------------------------------------
* At Selection Screen - Drop Down for File Name
*-----------------------------------------------------------------------
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_clfa1.
*
  PERFORM search_for_filename USING p_clfa1.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_cbsik.
*
  PERFORM search_for_filename USING p_cbsik.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_cbsak.
*
  PERFORM search_for_filename USING p_cbsak.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_cbseg.
*
  PERFORM search_for_filename USING p_cbseg..

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_cbkpf.
*
  PERFORM search_for_filename USING p_cbkpf.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_cbset.
*
  PERFORM search_for_filename USING p_cbset.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_cekko.
*
  PERFORM search_for_filename USING p_cekko.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_cekpo.
*
  PERFORM search_for_filename USING p_cekpo.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_cekbe.
*
  PERFORM search_for_filename USING p_cekbe.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_cekkn.
*
  PERFORM search_for_filename USING p_cekkn.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_cpayr.
*
  PERFORM search_for_filename USING p_cpayr.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_creguh.
*
  PERFORM search_for_filename USING p_creguh.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_cskat.
*
  PERFORM search_for_filename USING p_cskat.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_ct156.
*
  PERFORM search_for_filename USING p_ct156.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_ccdhdr.
*
  PERFORM search_for_filename USING p_ccdhdr.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_ccdpos.
*
  PERFORM search_for_filename USING p_ccdpos.


***********************************************************************
*Macro Definitions
***********************************************************************

***********************************************************************
*Macro load_field_names
***********************************************************************

  DEFINE load_field_names.

*  This macro is to parse that data into a comma delimited file
*  The pramaters are as follows:
*
*    1       Table type definition
*    2       Output Table
*

* data:  t_details      type  abap_compdescr_tab,
*        t_details_wa   type  abap_compdescr.
* data:  lt_line(2000)        type c,
*        lt_pos               type i,
*        lt_char_field(500)   type c.

* Dynamic field description of a structure
*    data: ref_descr type ref to cl_abap_structdescr.

    refresh: t_details.
    clear:   ref_descr.

    ref_descr ?= cl_abap_typedescr=>describe_by_name('&1' ).
    t_details[] = ref_descr->components[].

*
    clear:  lt_line.

    refresh: &2.

    clear: lt_line, lt_pos.

    loop at t_details into t_details_wa.

      move t_details_wa-name to lt_line+lt_pos.
      lt_pos = strlen( t_details_wa-name ) + lt_pos.
      move c_separator to lt_line+lt_pos.
      add 1    to lt_pos.

    endloop.

    move lt_line  to  &2.
    append &2.


  END-OF-DEFINITION.

***********************************************************************
*Macro load_download_file
***********************************************************************

  DEFINE load_download_file.

*  This macro is to parse that data into a comma delimited file
*  The pramaters are as follows:
*
*    1       Extract Table
*    2       Output Table

*    field-symbols: <f>.

*    data:  t_inx               type i,
*           t_line(2000)        type c,
*           t_pos               type i,
*           t_char_field(500)   type c.
*
    clear:  t_inx,
            t_line.

    loop at &1.

      clear: t_line, t_inx, t_pos.

      do.
        add 1 to t_inx.
        assign component t_inx of structure &1 to <f>.
        if sy-subrc ne 0.
          exit.
        endif.
        move <f>  to  t_char_field.
        shift t_char_field left deleting leading ' '.

        move t_char_field to t_line+t_pos.
        t_pos = strlen( t_char_field ) + t_pos.
        move c_separator to t_line+t_pos.
        add 1    to t_pos.
      enddo.

      move t_line  to  &2.
      append &2.

    endloop.

  END-OF-DEFINITION.

***********************************************************************
*Macro load_download_file
***********************************************************************
  DEFINE download_file.

*  This macro writes the date to the appropriate file type.
*  The pramaters are as follows:
*
*    1       Extract Table
*    2       Download Table
*    3       Unix file download selection parameter
*    4       Unix file name
*    5       PC file download selection parameter
*    6       PC file name
*    7       Table type definition
*

    load_download_file  &1  &2.

    if not &3 is initial.
      perform unix_download tables &2
                            using  &4.
    endif.

    if not &5 is initial.
      perform pc_file_download tables &2
                               using  &6.
    endif.

    free:  &1,
           &2.

  END-OF-DEFINITION.


************************************************************************
*  Initialization                                                      *
************************************************************************
INITIALIZATION.

* Set up TABS on the selection screen.
  tabs1 = text-001.
  tabs2 = text-002.
  tabs3 = text-004.


* If program is running in batch - do not get PC Default Filename
  IF sy-batch = ' '.
** find pc directory
    PERFORM get_pc_temp_dir        CHANGING t_dldir.
  ENDIF.

  PERFORM create_file_names.



*_______________________________________________________________________
AT SELECTION-SCREEN.

* Check if Period is > 16 ( Only 16 Periods )
*  IF p_rpmax > 16.               " Period
*    MESSAGE e000 WITH text-e01. " Period Cannot be Greater than 16
*  ENDIF.


*_______________________________________________________________________

START-OF-SELECTION.

*_______________________________________________________________________
* Security

************************************************************************
* Main Processing                                                      *
************************************************************************

* Get Accounts/Ranges from TVARVC for Special Processing
*  PERFORM read_tvarvc.

* Extract vendor data from table LFA1
  PERFORM extract_table_lfa1_unix.
  PERFORM extract_table_lfa1.

* Extract Accounting Document Header
  PERFORM extract_table_bkpf_unix.
  PERFORM extract_table_bkpf.

* Extract Accounting Document Segment
  PERFORM extract_table_bseg_unix.
  PERFORM extract_table_bseg.

* Extract Accounting: Secondary Index for Vendors from table BSIK
  PERFORM extract_table_bsik_unix.
  PERFORM extract_table_bsik.

* Extract Accounting: Secondary Index for Vendors (Cleared Items)
  PERFORM extract_table_bsak_unix.
  PERFORM extract_table_bsak.

* Extract Tax Data Document Segment
  PERFORM extract_table_bset_unix.
  PERFORM extract_table_bset.

* Extract Purchasing Document Header
  PERFORM extract_table_ekko_unix.
  PERFORM extract_table_ekko.

* Extract Purchasing Document Line Items
  PERFORM extract_table_ekpo_unix.
  PERFORM extract_table_ekpo.

* Extract History per Purchasing Document
  PERFORM extract_table_ekbe_unix.
  PERFORM extract_table_ekbe.

* Extract Account Assignment in Purchasing Document
  PERFORM extract_table_ekkn_unix.
  PERFORM extract_table_ekkn.

* Extract Payment Medium File
  PERFORM extract_table_payr_unix.
  PERFORM extract_table_payr.

* Extract Settlement data from payment program
  PERFORM extract_table_reguh_unix.
  PERFORM extract_table_reguh.

* Extract G/L Account Master Record (Chart of Accounts: Description)
  PERFORM extract_table_skat_unix.
  PERFORM extract_table_skat.

* Extract Movement Type
  PERFORM extract_table_t156_unix.
  PERFORM extract_table_t156.

* Extract Change document header
  PERFORM extract_table_cdhdr_cdpos_unix.
  PERFORM extract_table_cdhdr_cdpos.

* Extract Change document items
*  PERFORM extract_table_cdpos.

* Write Selection Screen Entries
  MOVE ' ' TO t_rpt_heading_sw.
  NEW-PAGE.
  PERFORM front_page.


END-OF-SELECTION.

************************************************************************
TOP-OF-PAGE.
************************************************************************

  WRITE: /.

  ULINE.

*----------------------------------------------------------------------*
* Called Routines                                                      *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  Create File Names
*&---------------------------------------------------------------------*
FORM create_file_names.

  PERFORM create_unix_file_name USING 'LFA1' p_flfa1.
  PERFORM create_pc_file_name   USING 'LFA1' p_clfa1.

  PERFORM create_unix_file_name USING 'BSIK' p_fbsik.
  PERFORM create_pc_file_name   USING 'BSIK' p_cbsik.

  PERFORM create_unix_file_name USING 'BSAK' p_fbsak.
  PERFORM create_pc_file_name   USING 'BSAK' p_cbsak.

  PERFORM create_unix_file_name USING 'BSEG' p_fbseg.
  PERFORM create_pc_file_name   USING 'BSEG' p_cbseg.

  PERFORM create_unix_file_name USING 'BKPF' p_fbkpf.
  PERFORM create_pc_file_name   USING 'BKPF' p_cbkpf.

  PERFORM create_unix_file_name USING 'BSET' p_fbset.
  PERFORM create_pc_file_name   USING 'BSET' p_cbset.

  PERFORM create_unix_file_name USING 'EKKO' p_fekko.
  PERFORM create_pc_file_name   USING 'EKKO' p_cekko.

  PERFORM create_unix_file_name USING 'EKPO' p_fekpo.
  PERFORM create_pc_file_name   USING 'EKPO' p_cekpo.

  PERFORM create_unix_file_name USING 'EKBE' p_fekbe.
  PERFORM create_pc_file_name   USING 'EKBE' p_cekbe.

  PERFORM create_unix_file_name USING 'EKKN' p_fekkn.
  PERFORM create_pc_file_name   USING 'EKKN' p_cekkn.

  PERFORM create_unix_file_name USING 'PAYR' p_fpayr.
  PERFORM create_pc_file_name   USING 'PAYR' p_cpayr.

  PERFORM create_unix_file_name USING 'REGUH' p_freguh.
  PERFORM create_pc_file_name   USING 'REGUH' p_creguh.

  PERFORM create_unix_file_name USING 'SKAT' p_fskat.
  PERFORM create_pc_file_name   USING 'SKAT' p_cskat.

  PERFORM create_unix_file_name USING 'T156' p_ft156.
  PERFORM create_pc_file_name   USING 'T156' p_ct156.

  PERFORM create_unix_file_name USING 'CDHDR' p_fcdhdr.
  PERFORM create_pc_file_name   USING 'CDHDR' p_ccdhdr.

  PERFORM create_unix_file_name USING 'CDPOS' p_fcdpos.
  PERFORM create_pc_file_name   USING 'CDPOS' p_ccdpos.

ENDFORM.                    "create_file_names



*&---------------------------------------------------------------------*
*&      Form  create_unix_file_name
*&---------------------------------------------------------------------*
FORM create_unix_file_name USING u_table
                                 u_file_name.

* Build a File name for the download to UNIX.
  CONCATENATE '/transfer/'
              sy-sysid
              '/General/'
              'BSI_'
              u_table
              '_'
              sy-datum
                INTO t_unix.                  "determine UNIX file-path
  u_file_name = t_unix.



ENDFORM.                    "create_unix_file_name

*&---------------------------------------------------------------------*
*&      Form  create_pc_file_name
*&---------------------------------------------------------------------*
FORM create_pc_file_name USING u_table
                               u_file_name.

* Build a File name for the download to the PC.
  CONCATENATE t_dldir
              '\'
              sy-sysid
              '_'
              'BSI_'
              u_table
              '_'
              sy-datum
                INTO t_pcfile.                "determine PC file-path

  u_file_name = t_pcfile.

ENDFORM.                    "create_unix_file_name



*&---------------------------------------------------------------------*
*&      Form  READ TVARVC (Table of Variant Variables)
*&---------------------------------------------------------------------*
FORM read_tvarvc.

*  SELECT SINGLE low
*    FROM tvarvc
*    INTO t_st_bal
*    WHERE name = p_st_bal
*     AND type = 'P'.

ENDFORM.                    "read_tvarvc

*&---------------------------------------------------------------------*
*&      Form  Extract Table LFA1
*&---------------------------------------------------------------------*
FORM extract_table_lfa1.

  CHECK NOT p_lfa1  IS INITIAL
    AND NOT p_plfa1 IS INITIAL.

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE zlfa1_tab
    FROM lfa1.

  load_field_names  ty_lfa1           " Table definition Type
                    z_dnl_file_tab.   " Download Table

  download_file  zlfa1_tab        " Extract Table
                 z_dnl_file_tab   " Download Table
                 p_ulfa1          " Unix file download selection paramet
                 p_flfa1          " Unix file name
                 p_plfa1          " PC file download selection parameter
                 p_clfa1.         " PC file name

ENDFORM.                    "extract_table_lfa1

*&---------------------------------------------------------------------*
*&      Form  Extract Table LFA1 Unix
*&---------------------------------------------------------------------*
FORM extract_table_lfa1_unix.

  DATA:   zlfa1_wa   TYPE  ty_lfa1.

  CHECK NOT p_lfa1  IS INITIAL
    AND NOT p_ulfa1 IS INITIAL.


  PERFORM open_unix_file USING p_flfa1.

  load_field_names  ty_lfa1           " Table definition Type
                    z_dnl_file_tab.   " Download Table

  OPEN CURSOR : t_cursor_1 FOR
    SELECT *
    FROM lfa1.

  DO.
    CLEAR: zlfa1_wa.
    FETCH NEXT CURSOR t_cursor_1 INTO CORRESPONDING FIELDS OF zlfa1_wa.
    IF sy-subrc <> 0.
      CLOSE CURSOR t_cursor_1.
      EXIT.
    ENDIF.

    MOVE-CORRESPONDING zlfa1_wa TO zlfa1_tab.
    APPEND zlfa1_tab.
    t_buffer_size = t_buffer_size + 1.
    IF t_buffer_size > c_buffer_size.
      download_file  zlfa1_tab        " Extract Table
                     z_dnl_file_tab   " Download Table
                     p_ulfa1          " Unix file download selection par
                     p_flfa1          " Unix file name
                     ''               " PC file download selection param
                     ''.              " PC file name
    ENDIF.
  ENDDO.

  download_file  zlfa1_tab        " Extract Table
                 z_dnl_file_tab   " Download Table
                 p_ulfa1          " Unix file download selection paramet
                 p_flfa1          " Unix file name
                 ''               " PC file download selection parameter
                 ''.              " PC file name

  PERFORM close_unix_file USING p_flfa1.

ENDFORM.                    "extract_table_lfa1_unix

*&---------------------------------------------------------------------*
*&      Form  Extract Table BKPF
*&---------------------------------------------------------------------*
FORM extract_table_bkpf.

  CHECK NOT p_bkpf IS INITIAL
    AND NOT p_pbkpf IS INITIAL.

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE zbkpf_tab
    FROM bkpf
   WHERE bukrs IN s_bukrs
     AND blart IN s_blart
     AND budat IN s_budat.

  load_field_names  ty_bkpf           " Table definition Type
                    z_dnl_file_tab.   " Download Table

  download_file  zbkpf_tab        " Extract Table
                 z_dnl_file_tab   " Download Table
                 p_ubkpf          " Unix file download selection paramet
                 p_fbkpf          " Unix file name
                 p_pbkpf          " PC file download selection parameter
                 p_cbkpf.         " PC file name

ENDFORM.                    "extract_table_bkpf

*&---------------------------------------------------------------------*
*&      Form  Extract Table BKPF Unix
*&---------------------------------------------------------------------*
FORM extract_table_bkpf_unix.

  DATA:   zbkpf_wa   TYPE  ty_bkpf.

  CHECK NOT p_bkpf IS INITIAL
    AND NOT p_ubkpf IS INITIAL.


  PERFORM open_unix_file USING p_fbkpf.

  load_field_names  ty_bkpf           " Table definition Type
                    z_dnl_file_tab.   " Download Table

  OPEN CURSOR : t_cursor_1 FOR
    SELECT *
      FROM bkpf
     WHERE bukrs IN s_bukrs
       AND blart IN s_blart
       AND budat IN s_budat.

  DO.
    CLEAR: zbkpf_wa.
    FETCH NEXT CURSOR t_cursor_1 INTO CORRESPONDING FIELDS OF zbkpf_wa.
    IF sy-subrc <> 0.
      CLOSE CURSOR t_cursor_1.
      EXIT.
    ENDIF.

    MOVE-CORRESPONDING zbkpf_wa TO zbkpf_tab.
    APPEND zbkpf_tab.
    t_buffer_size = t_buffer_size + 1.
    IF t_buffer_size > c_buffer_size.
      download_file  zbkpf_tab        " Extract Table
                     z_dnl_file_tab   " Download Table
                     p_ubkpf          " Unix file download selection par
                     p_fbkpf          " Unix file name
                     ''               " PC file download selection param
                     ''.              " PC file name
    ENDIF.
  ENDDO.

  download_file  zbkpf_tab        " Extract Table
                 z_dnl_file_tab   " Download Table
                 p_ubkpf          " Unix file download selection paramet
                 p_fbkpf          " Unix file name
                 ''               " PC file download selection parameter
                 ''.              " PC file name

  PERFORM close_unix_file USING p_fbkpf.

ENDFORM.                    "extract_table_bkpf

*&---------------------------------------------------------------------*
*&      Form  Extract Table BSEG
*&---------------------------------------------------------------------*
FORM extract_table_bseg.

  CHECK NOT p_bseg IS INITIAL
    AND NOT p_pbseg IS INITIAL.

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE zbkpf_tab
    FROM bkpf
   WHERE bukrs IN s_bukrs
     AND blart IN s_blart
     AND budat IN s_budat.

  IF NOT p_bseg IS INITIAL      AND
     NOT zbkpf_tab[] IS INITIAL.
    SELECT *
      INTO CORRESPONDING FIELDS OF TABLE zbseg_tab
      FROM bseg
      FOR ALL ENTRIES IN zbkpf_tab
     WHERE bukrs = zbkpf_tab-bukrs
       AND belnr = zbkpf_tab-belnr
       AND gjahr = zbkpf_tab-gjahr.
  ENDIF.

  load_field_names  ty_bseg           " Table definition Type
                    z_dnl_file_tab.   " Download Table

  download_file  zbseg_tab        " Extract Table
                 z_dnl_file_tab   " Download Table
                 p_ubseg          " Unix file download selection paramet
                 p_fbseg          " Unix file name
                 p_pbseg          " PC file download selection parameter
                 p_cbseg.         " PC file name

ENDFORM.                    "extract_table_bseg

*&---------------------------------------------------------------------*
*&      Form  Extract Table BSEG Unix
*&---------------------------------------------------------------------*
FORM extract_table_bseg_unix.

  DATA:   zbseg_wa   TYPE  ty_bseg,
          zbkpf_wa   TYPE  ty_bkpf.

  CHECK NOT p_bseg IS INITIAL
    AND NOT p_ubseg IS INITIAL.


  PERFORM open_unix_file USING p_fbseg.

  load_field_names  ty_bseg           " Table definition Type
                    z_dnl_file_tab.   " Download Table

  OPEN CURSOR : t_cursor_1 FOR
    SELECT *
      FROM bkpf
     WHERE bukrs IN s_bukrs
       AND blart IN s_blart
       AND budat IN s_budat.

  DO.
    CLEAR: zbkpf_wa.
    FETCH NEXT CURSOR t_cursor_1 INTO CORRESPONDING FIELDS OF zbkpf_wa.
    IF sy-subrc <> 0.
      CLOSE CURSOR t_cursor_1.
      EXIT.
    ENDIF.

    OPEN CURSOR : t_cursor_2 FOR
      SELECT *
        FROM bseg
       WHERE bukrs = zbkpf_wa-bukrs
         AND belnr = zbkpf_wa-belnr
         AND gjahr = zbkpf_wa-gjahr.

    DO.
      CLEAR: zbseg_wa.
      FETCH NEXT CURSOR t_cursor_2 INTO CORRESPONDING FIELDS OF
                        zbseg_wa.
      IF sy-subrc <> 0.
        CLOSE CURSOR t_cursor_2.
        EXIT.
      ENDIF.
      MOVE-CORRESPONDING zbseg_wa TO zbseg_tab.
      APPEND zbseg_tab.
      t_buffer_size = t_buffer_size + 1.
      IF t_buffer_size > c_buffer_size.
        download_file  zbseg_tab        " Extract Table
                       z_dnl_file_tab   " Download Table
                       p_ubseg          " Unix file download selection p
                       p_fbseg          " Unix file name
                       ''               " PC file download selection par
                       ''.              " PC file name
      ENDIF.
    ENDDO.
  ENDDO.

  download_file  zbseg_tab        " Extract Table
                 z_dnl_file_tab   " Download Table
                 p_ubseg          " Unix file download selection paramet
                 p_fbseg          " Unix file name
                 ''               " PC file download selection parameter
                 ''.              " PC file name

  PERFORM close_unix_file USING p_fbkpf.

ENDFORM.                    "extract_table_bseg_unix

*&---------------------------------------------------------------------*
*&      Form  Extract Table BSIK
*&---------------------------------------------------------------------*
FORM extract_table_bsik.

  CHECK NOT p_bsik  IS INITIAL
    AND NOT p_pbsik IS INITIAL.

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE zbsik_tab
    FROM bsik
   WHERE bukrs IN s_bukrs.

  load_field_names  ty_bsik           " Table definition Type
                    z_dnl_file_tab.   " Download Table

  download_file  zbsik_tab        " Extract Table
                 z_dnl_file_tab   " Download Table
                 p_ubsik          " Unix file download selection paramet
                 p_fbsik          " Unix file name
                 p_pbsik          " PC file download selection parameter
                 p_cbsik.         " PC file name

ENDFORM.                    "extract_table_bsik

*&---------------------------------------------------------------------*
*&      Form  Extract Table BSIK Unix
*&---------------------------------------------------------------------*
FORM extract_table_bsik_unix.

  DATA:   zbsik_wa   TYPE  ty_bsik.

  CHECK NOT p_bsik  IS INITIAL
    AND NOT p_ubsik IS INITIAL.


  PERFORM open_unix_file USING p_fbsik.

  load_field_names  ty_bsik           " Table definition Type
                    z_dnl_file_tab.   " Download Table

  OPEN CURSOR : t_cursor_1 FOR
    SELECT *
      FROM bsik
     WHERE bukrs IN s_bukrs.


  DO.
    CLEAR: zbsik_wa.
    FETCH NEXT CURSOR t_cursor_1 INTO CORRESPONDING FIELDS OF zbsik_wa.
    IF sy-subrc <> 0.
      CLOSE CURSOR t_cursor_1.
      EXIT.
    ENDIF.
    MOVE-CORRESPONDING zbsik_wa TO zbsik_tab.
    APPEND zbsik_tab.
    t_buffer_size = t_buffer_size + 1.
    IF t_buffer_size > c_buffer_size.
      download_file  zbsik_tab        " Extract Table
                     z_dnl_file_tab   " Download Table
                     p_ubsik          " Unix file download selection par
                     p_fbsik          " Unix file name
                     ''               " PC file download selection param
                     ''.              " PC file name
    ENDIF.
  ENDDO.


  download_file  zbsik_tab        " Extract Table
                 z_dnl_file_tab   " Download Table
                 p_ubsik          " Unix file download selection paramet
                 p_fbsik          " Unix file name
                 ''               " PC file download selection parameter
                 ''.              " PC file name

  PERFORM close_unix_file USING p_fbsik.



ENDFORM.                    "extract_table_bsik_unix

*&---------------------------------------------------------------------*
*&      Form  Extract Table BSAK
*&---------------------------------------------------------------------*
FORM extract_table_bsak.

  CHECK NOT p_bsak  IS INITIAL
    AND NOT p_pbsak IS INITIAL.


  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE zbsak_tab
    FROM bsak
   WHERE bukrs IN s_bukrs
     AND augdt IN s_augdt.

  load_field_names  ty_bsak           " Table definition Type
                    z_dnl_file_tab.   " Download Table

  download_file  zbsak_tab        " Extract Table
                 z_dnl_file_tab   " Download Table
                 p_ubsak          " Unix file download selection paramet
                 p_fbsak          " Unix file name
                 p_pbsak          " PC file download selection parameter
                 p_cbsak.         " PC file name

ENDFORM.                    "extract_table_bsak

*&---------------------------------------------------------------------*
*&      Form  Extract Table BSAK Unix
*&---------------------------------------------------------------------*
FORM extract_table_bsak_unix.

  DATA:   zbsak_wa   TYPE  ty_bsak.

  CHECK NOT p_bsak  IS INITIAL
    AND NOT p_ubsak IS INITIAL.

  PERFORM open_unix_file USING p_fbsak.

  load_field_names  ty_bsak           " Table definition Type
                    z_dnl_file_tab.   " Download Table

  OPEN CURSOR : t_cursor_1 FOR
    SELECT *
      FROM bsak
     WHERE bukrs IN s_bukrs
       AND augdt IN s_augdt.

  DO.
    CLEAR: zbsak_wa.
    FETCH NEXT CURSOR t_cursor_1 INTO CORRESPONDING FIELDS OF zbsak_wa.
    IF sy-subrc <> 0.
      CLOSE CURSOR t_cursor_1.
      EXIT.
    ENDIF.
    MOVE-CORRESPONDING zbsak_wa TO zbsak_tab.
    APPEND zbsak_tab.
    t_buffer_size = t_buffer_size + 1.
    IF t_buffer_size > c_buffer_size.
      download_file  zbsak_tab        " Extract Table
                     z_dnl_file_tab   " Download Table
                     p_ubsak          " Unix file download selection par
                     p_fbsak          " Unix file name
                     ''               " PC file download selection param
                     ''.              " PC file name
    ENDIF.
  ENDDO.

  download_file  zbsak_tab        " Extract Table
                 z_dnl_file_tab   " Download Table
                 p_ubsak          " Unix file download selection paramet
                 p_fbsak          " Unix file name
                 ''               " PC file download selection parameter
                 ''.              " PC file name

  PERFORM close_unix_file USING p_fbsak.


ENDFORM.                    "extract_table_bsak_unix

*&---------------------------------------------------------------------*
*&      Form  Extract Table BSET
*&---------------------------------------------------------------------*
FORM extract_table_bset.

  CHECK NOT p_bset  IS INITIAL
    AND NOT p_pbset IS INITIAL.

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE zbset_tab
    FROM bset
   WHERE bukrs IN s_bukrs.

  load_field_names  ty_bset           " Table definition Type
                    z_dnl_file_tab.   " Download Table

  download_file  zbset_tab        " Extract Table
                 z_dnl_file_tab   " Download Table
                 p_ubset          " Unix file download selection paramet
                 p_fbset          " Unix file name
                 p_pbset          " PC file download selection parameter
                 p_cbset.         " PC file name

ENDFORM.                    "extract_table_bset

*&---------------------------------------------------------------------*
*&      Form  Extract Table BSET Unix
*&---------------------------------------------------------------------*
FORM extract_table_bset_unix.

  DATA:   zbset_wa   TYPE  ty_bset.

  CHECK NOT p_bset  IS INITIAL
    AND NOT p_ubset IS INITIAL.

  PERFORM open_unix_file USING p_fbset.

  load_field_names  ty_bset           " Table definition Type
                    z_dnl_file_tab.   " Download Table

  OPEN CURSOR : t_cursor_1 FOR
    SELECT *
      FROM bset
     WHERE bukrs IN s_bukrs
       AND hwbas GT 0.


  DO.
    CLEAR: zbset_wa.
    FETCH NEXT CURSOR t_cursor_1 INTO CORRESPONDING FIELDS OF zbset_wa.
    IF sy-subrc <> 0.
      CLOSE CURSOR t_cursor_1.
      EXIT.
    ENDIF.
    MOVE-CORRESPONDING zbset_wa TO zbset_tab.
    APPEND zbset_tab.
    t_buffer_size = t_buffer_size + 1.
    IF t_buffer_size > c_buffer_size.
      download_file  zbset_tab        " Extract Table
                     z_dnl_file_tab   " Download Table
                     p_ubset          " Unix file download selection par
                     p_fbset          " Unix file name
                     ''               " PC file download selection param
                     ''.              " PC file name
    ENDIF.
  ENDDO.

  download_file  zbset_tab        " Extract Table
                 z_dnl_file_tab   " Download Table
                 p_ubset          " Unix file download selection paramet
                 p_fbset          " Unix file name
                 ''               " PC file download selection parameter
                 ''.              " PC file name

  PERFORM close_unix_file USING p_fbset.

ENDFORM.                    "extract_table_bset_unix

*&---------------------------------------------------------------------*
*&      Form  Extract Table EKKO
*&---------------------------------------------------------------------*
FORM extract_table_ekko.

  CHECK NOT p_ekko  IS INITIAL
    AND NOT p_pekko IS INITIAL.

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE zekko_tab
    FROM ekko
   WHERE bukrs IN s_bukrs
     AND bsart IN s_bsart
     AND aedat IN s_aedat.

  IF NOT zekko_tab[] IS INITIAL.
    SELECT *
      INTO CORRESPONDING FIELDS OF TABLE zekpo_tab
      FROM ekpo
      FOR ALL ENTRIES IN zekko_tab
     WHERE ebeln = zekko_tab-ebeln.
  ENDIF.

  load_field_names  ty_ekko           " Table definition Type
                    z_dnl_file_tab.   " Download Table

  download_file  zekko_tab        " Extract Table
                 z_dnl_file_tab   " Download Table
                 p_uekko          " Unix file download selection paramet
                 p_fekko          " Unix file name
                 p_pekko          " PC file download selection parameter
                 p_cekko.         " PC file name

ENDFORM.                    "extract_table_ekko

*&---------------------------------------------------------------------*
*&      Form  Extract Table EKKO Unix
*&---------------------------------------------------------------------*
FORM extract_table_ekko_unix.

*  DATA:   zekko_tab  TYPE STANDARD TABLE OF ty_ekko WITH HEADER LINE.
  DATA:   l_ebeln  LIKE ekko-ebeln.
  DATA:   l_count  TYPE i.

  DATA:   zekko_wa   TYPE  ty_ekko.

  CHECK NOT p_ekko  IS INITIAL
    AND NOT p_uekko IS INITIAL.

  REFRESH: t_contract_tab.

  PERFORM open_unix_file USING p_fekko.

  load_field_names  ty_ekko           " Table definition Type
                    z_dnl_file_tab.   " Download Table

  OPEN CURSOR : t_cursor_1 FOR
    SELECT *
      FROM ekko
     WHERE bukrs IN s_bukrs
       AND bsart IN s_bsart
       AND aedat IN s_aedat.

  DO.
    CLEAR: zekko_wa.
    FETCH NEXT CURSOR t_cursor_1 INTO CORRESPONDING FIELDS OF zekko_wa.
    IF sy-subrc <> 0.
      CLOSE CURSOR t_cursor_1.
      EXIT.
    ENDIF.
    IF NOT zekko_wa-konnr IS INITIAL.
      MOVE zekko_wa-konnr  TO  t_contract_tab-konnr.
      COLLECT                  t_contract_tab.
    ENDIF.
    MOVE-CORRESPONDING zekko_wa TO zekko_tab.
    APPEND zekko_tab.
    t_buffer_size = t_buffer_size + 1.
    IF t_buffer_size > c_buffer_size.
      download_file  zekko_tab        " Extract Table
                     z_dnl_file_tab   " Download Table
                     p_uekko          " Unix file download selection par
                     p_fekko          " Unix file name
                     ''               " PC file download selection param
                     ''.              " PC file name
    ENDIF.
  ENDDO.

  download_file  zekko_tab        " Extract Table
                 z_dnl_file_tab   " Download Table
                 p_uekko          " Unix file download selection paramet
                 p_fekko          " Unix file name
                 ''               " PC file download selection parameter
                 ''.              " PC file name

*** Additional processing of table EKBE to extract Goods Receipts for
*** PO's that have been created outside of the audit period but the
*** PO is still receiving against it.

  OPEN CURSOR : t_cursor_1 FOR
    SELECT DISTINCT ebeln
      FROM ekbe
     WHERE ( vgabe EQ '1'   OR
             vgabe EQ '2' )
       AND budat IN s_aedat.

  DO.
    CLEAR: l_ebeln.
    FETCH NEXT CURSOR t_cursor_1 INTO l_ebeln.
    IF sy-subrc <> 0.
      CLOSE CURSOR t_cursor_1.
      EXIT.
    ENDIF.
    SELECT SINGLE *
      INTO CORRESPONDING FIELDS OF zekko_wa
      FROM ekko
     WHERE ebeln     EQ l_ebeln
       AND bukrs     IN s_bukrs
       AND bsart     IN s_bsart
       AND NOT aedat IN s_aedat.
    IF sy-subrc = 0.
      MOVE-CORRESPONDING zekko_wa TO zekko_tab.
      APPEND zekko_tab.
      t_buffer_size = t_buffer_size + 1.
      IF t_buffer_size > c_buffer_size.
        download_file  zekko_tab        " Extract Table
                       z_dnl_file_tab   " Download Table
                       p_uekko          " Unix file download sel par
                       p_fekko          " Unix file name
                       ''               " PC file download sel param
                       ''.              " PC file name
      ENDIF.
    ENDIF.
  ENDDO.

  download_file  zekko_tab        " Extract Table
                 z_dnl_file_tab   " Download Table
                 p_uekko          " Unix file download selection paramet
                 p_fekko          " Unix file name
                 ''               " PC file download selection parameter
                 ''.              " PC file name

  LOOP AT t_contract_tab.

    SELECT SINGLE *
      INTO CORRESPONDING FIELDS OF zekko_wa
      FROM ekko
     WHERE ebeln     EQ t_contract_tab-konnr.
    IF sy-subrc = 0.
      MOVE-CORRESPONDING zekko_wa TO zekko_tab.
      APPEND zekko_tab.
      t_buffer_size = t_buffer_size + 1.
      IF t_buffer_size > c_buffer_size.
        download_file  zekko_tab        " Extract Table
                       z_dnl_file_tab   " Download Table
                       p_uekko          " Unix file download sel par
                       p_fekko          " Unix file name
                       ''               " PC file download sel param
                       ''.              " PC file name
      ENDIF.
    ENDIF.

  ENDLOOP.

  download_file  zekko_tab        " Extract Table
                 z_dnl_file_tab   " Download Table
                 p_uekko          " Unix file download selection paramet
                 p_fekko          " Unix file name
                 ''               " PC file download selection parameter
                 ''.              " PC file name

  PERFORM close_unix_file USING p_fekko.

ENDFORM.                    "extract_table_ekko_unix

*&---------------------------------------------------------------------*
*&      Form  Extract Table EKPO
*&---------------------------------------------------------------------*
FORM extract_table_ekpo.

  CHECK NOT p_ekko  IS INITIAL
    AND NOT p_pekko IS INITIAL.


  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE zekko_tab
    FROM ekko
   WHERE bukrs IN s_bukrs
     AND bsart IN s_bsart
     AND aedat IN s_aedat.

  IF NOT zekko_tab[] IS INITIAL.
    SELECT *
      INTO CORRESPONDING FIELDS OF TABLE zekpo_tab
      FROM ekpo
      FOR ALL ENTRIES IN zekko_tab
     WHERE ebeln = zekko_tab-ebeln.
  ENDIF.

  load_field_names  ty_ekpo           " Table definition Type
                    z_dnl_file_tab.   " Download Table

  download_file  zekpo_tab        " Extract Table
                 z_dnl_file_tab   " Download Table
                 p_uekpo          " Unix file download selection paramet
                 p_fekpo          " Unix file name
                 p_pekpo          " PC file download selection parameter
                 p_cekpo.         " PC file name

ENDFORM.                    "extract_table_ekpo

*&---------------------------------------------------------------------*
*&      Form  Extract Table EKPO Unix
*&---------------------------------------------------------------------*
FORM extract_table_ekpo_unix.

  DATA:   l_ekpo_tab  TYPE STANDARD TABLE OF ty_ekpo WITH HEADER LINE.
  DATA:   l_ebeln  LIKE ekko-ebeln.

  DATA:   zekko_wa   TYPE  ty_ekko,
          zekpo_wa   TYPE  ty_ekpo.

  CHECK NOT p_ekko  IS INITIAL
    AND NOT p_uekko IS INITIAL.

  PERFORM open_unix_file USING p_fekpo.

  load_field_names  ty_ekpo           " Table definition Type
                    z_dnl_file_tab.   " Download Table

  OPEN CURSOR : t_cursor_1 FOR
    SELECT *
     FROM ekko
    WHERE bukrs IN s_bukrs
      AND bsart IN s_bsart
      AND aedat IN s_aedat.

  DO.
    CLEAR: zekko_wa.
    FETCH NEXT CURSOR t_cursor_1 INTO CORRESPONDING FIELDS OF zekko_wa.
    IF sy-subrc <> 0.
      CLOSE CURSOR t_cursor_1.
      EXIT.
    ENDIF.

    OPEN CURSOR : t_cursor_2 FOR
      SELECT *
        FROM ekpo
       WHERE ebeln = zekko_wa-ebeln.

    DO.
      CLEAR: zekpo_wa.
      FETCH NEXT CURSOR t_cursor_2 INTO CORRESPONDING FIELDS OF zekpo_wa
      .
      IF sy-subrc <> 0.
        CLOSE CURSOR t_cursor_2.
        EXIT.
      ENDIF.
      MOVE-CORRESPONDING zekpo_wa TO zekpo_tab.
      APPEND zekpo_tab.
      t_buffer_size = t_buffer_size + 1.
      IF t_buffer_size > c_buffer_size.
        download_file  zekpo_tab        " Extract Table
                       z_dnl_file_tab   " Download Table
                       p_uekpo          " Unix file download selection p
                       p_fekpo          " Unix file name
                       ''               " PC file download selection par
                       ''.              " PC file name
      ENDIF.
    ENDDO.
  ENDDO.

  download_file  zekpo_tab        " Extract Table
                 z_dnl_file_tab   " Download Table
                 p_uekpo          " Unix file download selection paramet
                 p_fekpo          " Unix file name
                 ''               " PC file download selection parameter
                 ''.              " PC file name

*** Additional processing of table EKBE to extract Goods Receipts for
*** PO's that have been created outside of the audit period but the
*** PO is still receiving against it.

  OPEN CURSOR : t_cursor_1 FOR
    SELECT DISTINCT ebeln
      FROM ekbe
     WHERE ( vgabe EQ '1'   OR
             vgabe EQ '2' )
       AND budat IN s_aedat.

  DO.
    CLEAR: l_ebeln.
    FETCH NEXT CURSOR t_cursor_1 INTO l_ebeln.
    IF sy-subrc <> 0.
      CLOSE CURSOR t_cursor_1.
      EXIT.
    ENDIF.
    SELECT SINGLE *
      INTO CORRESPONDING FIELDS OF zekko_wa
      FROM ekko
     WHERE ebeln     EQ l_ebeln
       AND bukrs     IN s_bukrs
       AND bsart     IN s_bsart
       AND NOT aedat IN s_aedat.
    IF sy-subrc = 0.
      REFRESH: l_ekpo_tab.
      SELECT *
        INTO CORRESPONDING FIELDS OF TABLE l_ekpo_tab
        FROM ekpo
       WHERE ebeln     EQ l_ebeln.
      LOOP AT l_ekpo_tab.
        MOVE-CORRESPONDING l_ekpo_tab TO zekpo_tab.
        APPEND zekpo_tab.
        t_buffer_size = t_buffer_size + 1.
        IF t_buffer_size > c_buffer_size.
          download_file  zekpo_tab        " Extract Table
                         z_dnl_file_tab   " Download Table
                         p_uekpo          " Unix file download sel par
                         p_fekpo          " Unix file name
                         ''               " PC file download sel param
                         ''.              " PC file name
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDDO.

  download_file  zekpo_tab        " Extract Table
                 z_dnl_file_tab   " Download Table
                 p_uekpo          " Unix file download selection paramet
                 p_fekpo          " Unix file name
                 ''               " PC file download selection parameter
                 ''.              " PC file name

  LOOP AT t_contract_tab.

    REFRESH: l_ekpo_tab.
    SELECT *
      INTO CORRESPONDING FIELDS OF TABLE l_ekpo_tab
      FROM ekpo
     WHERE ebeln     EQ t_contract_tab-konnr.
    LOOP AT l_ekpo_tab.
      MOVE-CORRESPONDING l_ekpo_tab TO zekpo_tab.
      APPEND zekpo_tab.
      t_buffer_size = t_buffer_size + 1.
      IF t_buffer_size > c_buffer_size.
        download_file  zekpo_tab        " Extract Table
                       z_dnl_file_tab   " Download Table
                       p_uekpo          " Unix file download sel par
                       p_fekpo          " Unix file name
                       ''               " PC file download sel param
                       ''.              " PC file name
      ENDIF.
    ENDLOOP.

  ENDLOOP.

  download_file  zekpo_tab        " Extract Table
                 z_dnl_file_tab   " Download Table
                 p_uekpo          " Unix file download selection paramet
                 p_fekpo          " Unix file name
                 ''               " PC file download selection parameter
                 ''.              " PC file name

  PERFORM close_unix_file USING p_fekpo.

ENDFORM.                    "extract_table_ekpo_unix.

*&---------------------------------------------------------------------*
*&      Form  Extract Table EKBE
*&---------------------------------------------------------------------*
FORM extract_table_ekbe.

  CHECK NOT p_ekko  IS INITIAL
    AND NOT p_pekko IS INITIAL.

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE zekko_tab
    FROM ekko
   WHERE bukrs IN s_bukrs
     AND bsart IN s_bsart
     AND aedat IN s_aedat.

  IF NOT zekko_tab[] IS INITIAL.
    SELECT *
      INTO CORRESPONDING FIELDS OF TABLE zekpo_tab
      FROM ekpo
      FOR ALL ENTRIES IN zekko_tab
     WHERE ebeln = zekko_tab-ebeln.
  ENDIF.

  IF NOT zekpo_tab[] IS INITIAL.
    SELECT *
      INTO CORRESPONDING FIELDS OF TABLE zekbe_tab
      FROM ekbe
      FOR ALL ENTRIES IN zekpo_tab
     WHERE ebeln = zekpo_tab-ebeln
       AND ebelp = zekpo_tab-ebelp.
  ENDIF.

  load_field_names  ty_ekbe           " Table definition Type
                    z_dnl_file_tab.   " Download Table

  download_file  zekbe_tab        " Extract Table
                 z_dnl_file_tab   " Download Table
                 p_uekbe          " Unix file download selection paramet
                 p_fekbe          " Unix file name
                 p_pekbe          " PC file download selection parameter
                 p_cekbe.         " PC file name

ENDFORM.                    "extract_table_ekbe

*&---------------------------------------------------------------------*
*&      Form  Extract Table EKBE Unix
*&---------------------------------------------------------------------*
FORM extract_table_ekbe_unix.

  DATA:   l_ebeln  LIKE ekko-ebeln.

  DATA:   zekko_wa   TYPE  ty_ekko,
          zekpo_wa   TYPE  ty_ekpo,
          zekbe_wa   TYPE  ty_ekbe.

  CHECK NOT p_ekko  IS INITIAL
    AND NOT p_uekko IS INITIAL.

  PERFORM open_unix_file USING p_fekbe.

  load_field_names  ty_ekbe           " Table definition Type
                    z_dnl_file_tab.   " Download Table

  OPEN CURSOR : t_cursor_1 FOR
    SELECT *
     FROM ekko
    WHERE bukrs IN s_bukrs
      AND bsart IN s_bsart
      AND aedat IN s_aedat.

  DO.
    CLEAR: zekko_wa.
    FETCH NEXT CURSOR t_cursor_1 INTO CORRESPONDING FIELDS OF zekko_wa.
    IF sy-subrc <> 0.
      CLOSE CURSOR t_cursor_1.
      EXIT.
    ENDIF.

    OPEN CURSOR : t_cursor_2 FOR
      SELECT *
        FROM ekpo
       WHERE ebeln = zekko_wa-ebeln.

    DO.
      CLEAR: zekpo_wa.
      FETCH NEXT CURSOR t_cursor_2 INTO CORRESPONDING FIELDS OF zekpo_wa
      .
      IF sy-subrc <> 0.
        CLOSE CURSOR t_cursor_2.
        EXIT.
      ENDIF.

      OPEN CURSOR : t_cursor_3 FOR
        SELECT *
          FROM ekbe
         WHERE ebeln = zekpo_wa-ebeln
           AND ebelp = zekpo_wa-ebelp.

      DO.
        CLEAR: zekbe_wa.
        FETCH NEXT CURSOR t_cursor_3 INTO CORRESPONDING FIELDS OF
        zekbe_wa.
        IF sy-subrc <> 0.
          CLOSE CURSOR t_cursor_3.
          EXIT.
        ENDIF.
        MOVE-CORRESPONDING zekbe_wa TO zekbe_tab.
        APPEND zekbe_tab.
        t_buffer_size = t_buffer_size + 1.
        IF t_buffer_size > c_buffer_size.
          download_file  zekbe_tab        " Extract Table
                         z_dnl_file_tab   " Download Table
                         p_uekbe          " Unix file download selection
                         p_fekbe          " Unix file name
                         ''               " PC file download selection p
                         ''.              " PC file name
        ENDIF.
      ENDDO.
    ENDDO.
  ENDDO.

  download_file  zekbe_tab        " Extract Table
                 z_dnl_file_tab   " Download Table
                 p_uekbe          " Unix file download selection paramet
                 p_fekbe          " Unix file name
                 ''               " PC file download selection parameter
                 ''.              " PC file name

*** Additional processing of table EKBE to extract Goods Receipts for
*** PO's that have been created outside of the audit period but the
*** PO is still receiving against it.

  OPEN CURSOR : t_cursor_1 FOR
    SELECT DISTINCT ebeln
      FROM ekbe
     WHERE ( vgabe EQ '1'   OR
             vgabe EQ '2' )
       AND budat IN s_aedat.

  DO.
    CLEAR: l_ebeln.
    FETCH NEXT CURSOR t_cursor_1 INTO l_ebeln.
    IF sy-subrc <> 0.
      CLOSE CURSOR t_cursor_1.
      EXIT.
    ENDIF.
    SELECT SINGLE *
      INTO CORRESPONDING FIELDS OF zekko_wa
      FROM ekko
     WHERE ebeln     EQ l_ebeln
       AND bukrs     IN s_bukrs
       AND bsart     IN s_bsart
       AND NOT aedat IN s_aedat.
    IF sy-subrc = 0.
      OPEN CURSOR : t_cursor_2 FOR
        SELECT *
          FROM ekbe
         WHERE ebeln = zekko_wa-ebeln
           AND ( vgabe EQ '1'   OR
                 vgabe EQ '2' )
           AND budat IN s_aedat.
      DO.
        CLEAR: zekbe_wa.
        FETCH NEXT CURSOR t_cursor_2 INTO CORRESPONDING FIELDS OF
        zekbe_wa.
        IF sy-subrc <> 0.
          CLOSE CURSOR t_cursor_2.
          EXIT.
        ENDIF.
        MOVE-CORRESPONDING zekbe_wa TO zekbe_tab.
        APPEND zekbe_tab.
        t_buffer_size = t_buffer_size + 1.
        IF t_buffer_size > c_buffer_size.
          download_file  zekbe_tab        " Extract Table
                         z_dnl_file_tab   " Download Table
                         p_uekbe          " Unix file download sel
                         p_fekbe          " Unix file name
                         ''               " PC file download sel p
                         ''.              " PC file name
        ENDIF.
      ENDDO.
    ENDIF.
  ENDDO.

  download_file  zekbe_tab        " Extract Table
                 z_dnl_file_tab   " Download Table
                 p_uekbe          " Unix file download selection param
                 p_fekbe          " Unix file name
                 ''               " PC file download selection param
                 ''.              " PC file name

  PERFORM close_unix_file USING p_fekbe.

ENDFORM.                    "extract_table_ekbe_unix

*&---------------------------------------------------------------------*
*&      Form  Extract Table EKBN
*&---------------------------------------------------------------------*
FORM extract_table_ekkn.

  CHECK NOT p_ekko  IS INITIAL
    AND NOT p_pekko IS INITIAL.

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE zekko_tab
    FROM ekko
   WHERE bukrs IN s_bukrs
     AND bsart IN s_bsart
     AND aedat IN s_aedat.

  IF NOT zekko_tab[] IS INITIAL.
    SELECT *
      INTO CORRESPONDING FIELDS OF TABLE zekpo_tab
      FROM ekpo
      FOR ALL ENTRIES IN zekko_tab
     WHERE ebeln = zekko_tab-ebeln.
  ENDIF.

  IF NOT zekpo_tab[] IS INITIAL.
    SELECT *
      INTO CORRESPONDING FIELDS OF TABLE zekkn_tab
      FROM ekkn
      FOR ALL ENTRIES IN zekpo_tab
     WHERE ebeln = zekpo_tab-ebeln
       AND ebelp = zekpo_tab-ebelp.
  ENDIF.

  load_field_names  ty_ekkn           " Table definition Type
                    z_dnl_file_tab.   " Download Table

  download_file  zekkn_tab        " Extract Table
                 z_dnl_file_tab   " Download Table
                 p_uekkn          " Unix file download selection paramet
                 p_fekkn          " Unix file name
                 p_pekkn          " PC file download selection parameter
                 p_cekkn.         " PC file name

ENDFORM.                    "extract_table_ekkn

*&---------------------------------------------------------------------*
*&      Form  Extract Table EKKN Unix
*&---------------------------------------------------------------------*
FORM extract_table_ekkn_unix.

  DATA:   zekko_wa   TYPE  ty_ekko,
          zekpo_wa   TYPE  ty_ekpo,
          zekkn_wa   TYPE  ty_ekkn.

  CHECK NOT p_ekko  IS INITIAL
    AND NOT p_uekko IS INITIAL.

  PERFORM open_unix_file USING p_fekkn.

  load_field_names  ty_ekkn           " Table definition Type
                    z_dnl_file_tab.   " Download Table

  OPEN CURSOR : t_cursor_1 FOR
    SELECT *
     FROM ekko
    WHERE bukrs IN s_bukrs
      AND bsart IN s_bsart
      AND aedat IN s_aedat.

  DO.
    CLEAR: zekko_wa.
    FETCH NEXT CURSOR t_cursor_1 INTO CORRESPONDING FIELDS OF zekko_wa.
    IF sy-subrc <> 0.
      CLOSE CURSOR t_cursor_1.
      EXIT.
    ENDIF.

    OPEN CURSOR : t_cursor_2 FOR
      SELECT *
        FROM ekpo
       WHERE ebeln = zekko_wa-ebeln.

    DO.
      CLEAR: zekpo_wa.
      FETCH NEXT CURSOR t_cursor_2 INTO CORRESPONDING FIELDS OF zekpo_wa
      .
      IF sy-subrc <> 0.
        CLOSE CURSOR t_cursor_2.
        EXIT.
      ENDIF.

      OPEN CURSOR : t_cursor_3 FOR
       SELECT *
          FROM ekkn
         WHERE ebeln = zekpo_wa-ebeln
           AND ebelp = zekpo_wa-ebelp.

      DO.
        CLEAR: zekkn_wa.
        FETCH NEXT CURSOR t_cursor_3 INTO CORRESPONDING FIELDS OF
        zekkn_wa.
        IF sy-subrc <> 0.
          CLOSE CURSOR t_cursor_3.
          EXIT.
        ENDIF.
        MOVE-CORRESPONDING zekkn_wa TO zekkn_tab.
        APPEND zekkn_tab.
        t_buffer_size = t_buffer_size + 1.
        IF t_buffer_size > c_buffer_size.
          download_file  zekkn_tab        " Extract Table
                         z_dnl_file_tab   " Download Table
                         p_uekkn          " Unix file download selection
                         p_fekkn          " Unix file name
                         ''               " PC file download selection p
                         ''.              " PC file name
        ENDIF.
      ENDDO.
    ENDDO.
  ENDDO.

  download_file  zekkn_tab        " Extract Table
                 z_dnl_file_tab   " Download Table
                 p_uekkn          " Unix file download selection paramet
                 p_fekkn          " Unix file name
                 ''               " PC file download selection parameter
                 ''.              " PC file name

  PERFORM close_unix_file USING p_fekbe.

ENDFORM.                    "extract_table_ekkn_unix

*&---------------------------------------------------------------------*
*&      Form  Extract Table PAYR
*&---------------------------------------------------------------------*
FORM extract_table_payr.

  CHECK NOT p_payr  IS INITIAL
    AND NOT p_ppayr IS INITIAL.

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE zpayr_tab
    FROM payr
   WHERE zbukr IN s_bukrs
     AND laufd IN s_laufd.

  load_field_names  ty_payr           " Table definition Type
                    z_dnl_file_tab.   " Download Table

  download_file  zpayr_tab        " Extract Table
                 z_dnl_file_tab   " Download Table
                 p_upayr          " Unix file download selection paramet
                 p_fpayr          " Unix file name
                 p_ppayr          " PC file download selection parameter
                 p_cpayr.         " PC file name

ENDFORM.                    "extract_table_payr

*&---------------------------------------------------------------------*
*&      Form  Extract Table PAYR Unix
*&---------------------------------------------------------------------*
FORM extract_table_payr_unix.

  DATA:   zpayr_wa   TYPE  ty_payr.

  CHECK NOT p_payr  IS INITIAL
    AND NOT p_upayr IS INITIAL.

  PERFORM open_unix_file USING p_fpayr.

  load_field_names  ty_payr           " Table definition Type
                    z_dnl_file_tab.   " Download Table

  OPEN CURSOR : t_cursor_1 FOR
    SELECT *
      FROM payr
     WHERE zbukr IN s_bukrs
       AND laufd IN s_laufd.

  DO.
    CLEAR: zpayr_wa.
    FETCH NEXT CURSOR t_cursor_1 INTO CORRESPONDING FIELDS OF zpayr_wa.
    IF sy-subrc <> 0.
      CLOSE CURSOR t_cursor_1.
      EXIT.
    ENDIF.
    MOVE-CORRESPONDING zpayr_wa TO zpayr_tab.
    APPEND zpayr_tab.
    t_buffer_size = t_buffer_size + 1.
    IF t_buffer_size > c_buffer_size.
      download_file  zpayr_tab        " Extract Table
                     z_dnl_file_tab   " Download Table
                     p_upayr          " Unix file download selection par
                     p_fpayr          " Unix file name
                     ''               " PC file download selection param
                     ''.              " PC file name
    ENDIF.
  ENDDO.

  download_file  zpayr_tab        " Extract Table
                 z_dnl_file_tab   " Download Table
                 p_upayr          " Unix file download selection paramet
                 p_fpayr          " Unix file name
                 ''               " PC file download selection parameter
                 ''.              " PC file name

  PERFORM close_unix_file USING p_fpayr.

ENDFORM.                    "extract_table_payr_unix

*&---------------------------------------------------------------------*
*&      Form  Extract Table REGUH
*&---------------------------------------------------------------------*
FORM extract_table_reguh.

  CHECK NOT p_reguh  IS INITIAL
    AND NOT p_preguh IS INITIAL.

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE zreguh_tab
    FROM reguh
   WHERE zbukr IN s_bukrs
     AND laufd IN s_laufd.

  load_field_names  ty_reguh          " Table definition Type
                    z_dnl_file_tab.   " Download Table

  download_file  zreguh_tab        " Extract Table
                 z_dnl_file_tab    " Download Table
                 p_ureguh          " Unix file download selection parame
                 p_freguh          " Unix file name
                 p_preguh          " PC file download selection paramete
                 p_creguh.         " PC file name

ENDFORM.                    "extract_table_reguh

*&---------------------------------------------------------------------*
*&      Form  Extract Table REGUH Unix
*&---------------------------------------------------------------------*
FORM extract_table_reguh_unix.

  DATA:   zreguh_wa   TYPE  ty_reguh.

  CHECK NOT p_reguh  IS INITIAL
    AND NOT p_ureguh IS INITIAL.

  PERFORM open_unix_file USING p_freguh.

  load_field_names  ty_reguh          " Table definition Type
                    z_dnl_file_tab.   " Download Table

  OPEN CURSOR : t_cursor_1 FOR
    SELECT *
      FROM reguh
     WHERE zbukr IN s_bukrs
       AND laufd IN s_laufd.

  DO.
    CLEAR: zreguh_wa.
    FETCH NEXT CURSOR t_cursor_1 INTO CORRESPONDING FIELDS OF zreguh_wa.
    IF sy-subrc <> 0.
      CLOSE CURSOR t_cursor_1.
      EXIT.
    ENDIF.
    MOVE-CORRESPONDING zreguh_wa TO zreguh_tab.
    APPEND zreguh_tab.
    t_buffer_size = t_buffer_size + 1.
    IF t_buffer_size > c_buffer_size.
      download_file  zreguh_tab       " Extract Table
                     z_dnl_file_tab   " Download Table
                     p_ureguh         " Unix file download selection par
                     p_freguh         " Unix file name
                     ''               " PC file download selection param
                     ''.              " PC file name
    ENDIF.
  ENDDO.

  download_file  zreguh_tab       " Extract Table
                 z_dnl_file_tab   " Download Table
                 p_ureguh         " Unix file download selection paramet
                 p_freguh         " Unix file name
                 ''               " PC file download selection parameter
                 ''.              " PC file name

  PERFORM close_unix_file USING p_freguh.

ENDFORM.                    "extract_table_payr_unix

*&---------------------------------------------------------------------*
*&      Form  Extract Table SKAT
*&---------------------------------------------------------------------*
FORM extract_table_skat.

  CHECK NOT p_skat  IS INITIAL
    AND NOT p_pskat IS INITIAL.

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE zskat_tab
    FROM skat.

  load_field_names  ty_skat           " Table definition Type
                    z_dnl_file_tab.   " Download Table

  download_file  zskat_tab        " Extract Table
                 z_dnl_file_tab   " Download Table
                 p_uskat          " Unix file download selection paramet
                 p_fskat          " Unix file name
                 p_pskat          " PC file download selection parameter
                 p_cskat.         " PC file name

ENDFORM.                    "extract_table_skat
*&---------------------------------------------------------------------*
*&      Form  Extract Table SKAT Unix
*&---------------------------------------------------------------------*
FORM extract_table_skat_unix.

  DATA:   zskat_wa   TYPE  ty_skat.

  CHECK NOT p_skat  IS INITIAL
    AND NOT p_uskat IS INITIAL.

  PERFORM open_unix_file USING p_fskat.

  load_field_names  ty_skat           " Table definition Type
                    z_dnl_file_tab.   " Download Table

  OPEN CURSOR : t_cursor_1 FOR
    SELECT *
      FROM skat.

  DO.
    CLEAR: zskat_wa.
    FETCH NEXT CURSOR t_cursor_1 INTO CORRESPONDING FIELDS OF zskat_wa.
    IF sy-subrc <> 0.
      CLOSE CURSOR t_cursor_1.
      EXIT.
    ENDIF.

    MOVE-CORRESPONDING zskat_wa TO zskat_tab.
    APPEND zskat_tab.
    t_buffer_size = t_buffer_size + 1.
    IF t_buffer_size > c_buffer_size.
      download_file  zskat_tab        " Extract Table
                     z_dnl_file_tab   " Download Table
                     p_uskat          " Unix file download selection par
                     p_fskat          " Unix file name
                     ''               " PC file download selection param
                     ''.              " PC file name
    ENDIF.
  ENDDO.

  download_file  zskat_tab        " Extract Table
                 z_dnl_file_tab   " Download Table
                 p_uskat          " Unix file download selection paramet
                 p_fskat          " Unix file name
                 ''               " PC file download selection parameter
                 ''.              " PC file name

  PERFORM close_unix_file USING p_fskat.



ENDFORM.                    "extract_table_skat_unix

*&---------------------------------------------------------------------*
*&      Form  Extract Table T156
*&---------------------------------------------------------------------*
FORM extract_table_t156.

  CHECK NOT p_t156  IS INITIAL
    AND NOT p_pt156 IS INITIAL.

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE zt156_tab
    FROM t156.

  load_field_names  t156              " Table definition Type
                    z_dnl_file_tab.   " Download Table

  download_file  zt156_tab        " Extract Table
                 z_dnl_file_tab   " Download Table
                 p_ut156          " Unix file download selection paramet
                 p_ft156          " Unix file name
                 p_pt156          " PC file download selection parameter
                 p_ct156.         " PC file name

ENDFORM.                    "extract_table_t156

*&---------------------------------------------------------------------*
*&      Form  Extract Table T156 Unix
*&---------------------------------------------------------------------*
FORM extract_table_t156_unix.

  DATA:   zt156_wa   TYPE  t156.

  CHECK NOT p_t156  IS INITIAL
    AND NOT p_ut156 IS INITIAL.

  PERFORM open_unix_file USING p_ft156.

  load_field_names  t156              " Table definition Type
                    z_dnl_file_tab.   " Download Table

  OPEN CURSOR : t_cursor_1 FOR
    SELECT *
      FROM t156.

  DO.
    CLEAR: zt156_wa.
    FETCH NEXT CURSOR t_cursor_1 INTO CORRESPONDING FIELDS OF zt156_wa.
    IF sy-subrc <> 0.
      CLOSE CURSOR t_cursor_1.
      EXIT.
    ENDIF.

    MOVE-CORRESPONDING zt156_wa TO zt156_tab.
    APPEND zt156_tab.
    t_buffer_size = t_buffer_size + 1.
    IF t_buffer_size > c_buffer_size.
      download_file  zt156_tab        " Extract Table
                     z_dnl_file_tab   " Download Table
                     p_ut156          " Unix file download selection par
                     p_ft156          " Unix file name
                     ''               " PC file download selection param
                     ''.              " PC file name
    ENDIF.
  ENDDO.

  download_file  zt156_tab        " Extract Table
                 z_dnl_file_tab   " Download Table
                 p_ut156          " Unix file download selection paramet
                 p_ft156          " Unix file name
                 ''               " PC file download selection parameter
                 ''.              " PC file name

  PERFORM close_unix_file USING p_ft156.

ENDFORM.                    "extract_table_t156_unix

*&---------------------------------------------------------------------*
*&      Form  Extract Table CDHDR CDPOS
*&---------------------------------------------------------------------*
FORM extract_table_cdhdr_cdpos.

  CHECK NOT p_cdhdr  IS INITIAL
    AND NOT p_pcdhdr IS INITIAL.

  REFRESH: zobjectclas_tab,
           ztabname_tab,
           zfname_tab.

  zobjectclas_tab-sign    = 'I'.
  zobjectclas_tab-option  = 'EQ'.
  zobjectclas_tab-low     = c_objectclas.
  APPEND zobjectclas_tab.

  ztabname_tab-sign    = 'I'.
  ztabname_tab-option  = 'EQ'.
  ztabname_tab-low     = c_ekpo.
  APPEND ztabname_tab.


  zfname_tab-sign    = 'I'.
  zfname_tab-option  = 'EQ'.
  zfname_tab-low     = c_brtwr.
  APPEND zfname_tab.
  zfname_tab-low     = c_effwr.
  APPEND zfname_tab.
  zfname_tab-low     = c_netwr.
  APPEND zfname_tab.
  zfname_tab-low     = c_menge.
  APPEND zfname_tab.
  zfname_tab-low     = c_netpr.
  APPEND zfname_tab.


  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE zcdhdr_tab
    FROM cdhdr
   WHERE objectclas  =  c_objectclas
     AND udate       IN s_udate.

  IF NOT zcdhdr_tab[] IS INITIAL.
    SELECT *
      INTO CORRESPONDING FIELDS OF TABLE zcdpos_tab
      FROM cdpos
      FOR ALL ENTRIES IN zcdhdr_tab
     WHERE objectclas =  zcdhdr_tab-objectclas
       AND objectid   =  zcdhdr_tab-objectid
       AND changenr   =  zcdhdr_tab-changenr
       AND tabname    IN ztabname_tab
       AND fname      IN zfname_tab.
  ENDIF.

  load_field_names  cdhdr             " Table definition Type
                    z_dnl_file_tab.   " Download Table

  download_file  zcdhdr_tab        " Extract Table
                 z_dnl_file_tab   " Download Table
                 p_ucdhdr          " Unix file download selection parame
                 p_fcdhdr          " Unix file name
                 p_pcdhdr          " PC file download selection paramete
                 p_ccdhdr.         " PC file name

  load_field_names  cdpos             " Table definition Type
                    z_dnl_file_tab.   " Download Table

  download_file  zcdpos_tab        " Extract Table
                 z_dnl_file_tab    " Download Table
                 p_ucdpos          " Unix file download selection parame
                 p_fcdpos          " Unix file name
                 p_pcdpos          " PC file download selection paramete
                 p_ccdpos.         " PC file name


ENDFORM.                    "extract_table_cdhdr

*&---------------------------------------------------------------------*
*&      Form  Extract Table CDHDR CDPOS Unix
*&---------------------------------------------------------------------*
FORM extract_table_cdhdr_cdpos_unix.

  DATA:   zcdhdr_wa   TYPE  cdhdr,
          zcdpos_wa   TYPE  cdpos.

  CHECK NOT p_cdhdr  IS INITIAL
    AND NOT p_ucdhdr IS INITIAL.

  REFRESH: zobjectclas_tab,
           ztabname_tab,
           zfname_tab.

  zobjectclas_tab-sign    = 'I'.
  zobjectclas_tab-option  = 'EQ'.
  zobjectclas_tab-low     = c_objectclas.
  APPEND zobjectclas_tab.

  ztabname_tab-sign    = 'I'.
  ztabname_tab-option  = 'EQ'.
  ztabname_tab-low     = c_ekpo.
  APPEND ztabname_tab.
  ztabname_tab-low     = c_ekko.
  APPEND ztabname_tab.



  zfname_tab-sign    = 'I'.
  zfname_tab-option  = 'EQ'.
  zfname_tab-low     = c_brtwr.
  APPEND zfname_tab.
  zfname_tab-low     = c_effwr.
  APPEND zfname_tab.
  zfname_tab-low     = c_netwr.
  APPEND zfname_tab.
  zfname_tab-low     = c_menge.
  APPEND zfname_tab.
  zfname_tab-low     = c_netpr.
  APPEND zfname_tab.
  zfname_tab-low     = c_kdatb.
  APPEND zfname_tab.
  zfname_tab-low     = c_kdate.
  APPEND zfname_tab.

  PERFORM open_unix_file USING p_fcdhdr.

  load_field_names  cdhdr             " Table definition Type
                    z_dnl_file_tab.   " Download Table

  OPEN CURSOR : t_cursor_1 FOR
    SELECT *
      FROM cdhdr
     WHERE objectclas  =  c_objectclas
       AND udate       IN s_udate.

  DO.
    CLEAR: zcdhdr_wa.
    FETCH NEXT CURSOR t_cursor_1 INTO CORRESPONDING FIELDS OF zcdhdr_wa.
    IF sy-subrc <> 0.
      CLOSE CURSOR t_cursor_1.
      EXIT.
    ENDIF.

    MOVE-CORRESPONDING zcdhdr_wa TO zcdhdr_tab.
    APPEND zcdhdr_tab.
    t_buffer_size = t_buffer_size + 1.
    IF t_buffer_size > c_buffer_size.
      download_file  zcdhdr_tab       " Extract Table
                     z_dnl_file_tab   " Download Table
                     p_ucdhdr         " Unix file download selection par
                     p_fcdhdr         " Unix file name
                     ''               " PC file download selection param
                     ''.              " PC file name
    ENDIF.
  ENDDO.

  download_file  zcdhdr_tab       " Extract Table
                 z_dnl_file_tab   " Download Table
                 p_ucdhdr         " Unix file download selection paramet
                 p_fcdhdr         " Unix file name
                 ''               " PC file download selection parameter
                 ''.              " PC file name

  PERFORM close_unix_file USING p_fcdhdr.


  PERFORM open_unix_file USING p_fcdpos.

  load_field_names  cdpos             " Table definition Type
                    z_dnl_file_tab.   " Download Table

  OPEN CURSOR : t_cursor_1 FOR
    SELECT *
      FROM cdhdr
     WHERE objectclas  =  c_objectclas
       AND udate       IN s_udate.


  DO.
    CLEAR: zcdhdr_wa.
    FETCH NEXT CURSOR t_cursor_1 INTO CORRESPONDING FIELDS OF zcdhdr_wa.
    IF sy-subrc <> 0.
      CLOSE CURSOR t_cursor_1.
      EXIT.
    ENDIF.

    OPEN CURSOR : t_cursor_2 FOR
      SELECT *
        FROM cdpos
       WHERE objectclas =  zcdhdr_wa-objectclas
         AND objectid   =  zcdhdr_wa-objectid
         AND changenr   =  zcdhdr_wa-changenr
         AND tabname    IN ztabname_tab
         AND fname      IN zfname_tab.

    DO.
      CLEAR: zcdpos_wa.
      FETCH NEXT CURSOR t_cursor_2 INTO CORRESPONDING FIELDS OF
      zcdpos_wa.
      IF sy-subrc <> 0.
        CLOSE CURSOR t_cursor_2.
        EXIT.
      ENDIF.

      MOVE-CORRESPONDING zcdpos_wa TO zcdpos_tab.
      APPEND zcdpos_tab.
      t_buffer_size = t_buffer_size + 1.
      IF t_buffer_size > c_buffer_size.
        download_file  zcdpos_tab       " Extract Table
                       z_dnl_file_tab   " Download Table
                       p_ucdpos         " Unix file download selection p
                       p_fcdpos         " Unix file name
                       ''               " PC file download selection par
                       ''.              " PC file name
      ENDIF.
    ENDDO.
  ENDDO.

  download_file  zcdpos_tab       " Extract Table
                 z_dnl_file_tab   " Download Table
                 p_ucdpos         " Unix file download selection paramet
                 p_fcdpos         " Unix file name
                 ''               " PC file download selection parameter
                 ''.              " PC file name

  PERFORM close_unix_file USING p_fcdpos.


ENDFORM.                    "extract_table_cdhdr_cdpos_unix

**&---------------------------------------------------------------------
**&      Form  Extract Table CDPOS
**&---------------------------------------------------------------------
*FORM extract_table_cdpos.
*
*  CHECK NOT p_cdhdr IS INITIAL.
*
*  load_field_names  cdpos             " Table definition Type
*                    z_dnl_file_tab.   " Download Table
*
*  download_file  zcdpos_tab        " Extract Table
*                 z_dnl_file_tab   " Download Table
*                 p_ucdpos          " Unix file download selection param
*                 p_fcdpos          " Unix file name
*                 p_pcdpos          " PC file download selection paramet
*                 p_ccdpos.         " PC file name
*
*ENDFORM.                    "extract_table_cdpos

*&---------------------------------------------------------------------*
*&      Form  UNIX DOWNLOAD
*&---------------------------------------------------------------------*
FORM unix_download TABLES  t_dnld_tab  STRUCTURE z_dnl_file_tab
                   USING   u_file.

*  MOVE u_file  TO  file1.


*  CLEAR: t_encoding_u.
*
*  IF NOT p_unicd IS INITIAL.
*    MOVE p_uunicd  TO  t_encoding_u.
*    OPEN DATASET file1 IN LEGACY TEXT MODE
*                       FOR OUTPUT
*                       CODE PAGE t_encoding_u.
*  ELSE.

*  OPEN DATASET file1  FOR OUTPUT
*                      IN TEXT MODE
*                      ENCODING DEFAULT.
*  ENDIF.

*  IF sy-subrc NE 0.
*    MESSAGE e020 WITH file1.        " Error Opening Unix File
*    EXIT.
*  ENDIF.

  LOOP AT t_dnld_tab.
    TRANSFER t_dnld_tab TO file1.
  ENDLOOP.

*  IF sy-subrc = 0.
*    MESSAGE i000 WITH text-008 p_funix text-009.   " File Transferred
*  ENDIF.                                           " to Unix

*  CLOSE DATASET file1.

  CLEAR:  t_buffer_size.
  REFRESH t_dnld_tab.

ENDFORM.                    "unix_download


*&---------------------------------------------------------------------*
*&      Form  PC FILE DOWNLOAD
*&---------------------------------------------------------------------*
FORM pc_file_download  TABLES  t_dnld_tab  STRUCTURE z_dnl_file_tab
                       USING   u_file.

  CLEAR: t_encoding.

  IF NOT p_unicd IS INITIAL.
    MOVE p_cunicd  TO  t_encoding.
  ENDIF.

  t_download[] =  t_dnld_tab[].
  t_fullpath   =  u_file.

  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
      filename                = t_fullpath
      filetype                = 'ASC'
      write_field_separator   = 'X'
      dat_mode                = 'X'
      trunc_trailing_blanks   = 'X'
      write_bom               = 'X'
      codepage                = t_encoding
    TABLES
      data_tab                = t_download
    EXCEPTIONS
      file_write_error        = 1
      no_batch                = 2
      gui_refuse_filetransfer = 3
      invalid_type            = 4
      no_authority            = 5
      unknown_error           = 6
      header_not_allowed      = 7
      separator_not_allowed   = 8
      filesize_not_allowed    = 9
      header_too_long         = 10
      dp_error_create         = 11
      dp_error_send           = 12
      dp_error_write          = 13
      unknown_dp_error        = 14
      access_denied           = 15
      dp_out_of_memory        = 16
      disk_full               = 17
      dp_timeout              = 18
      file_not_found          = 19
      dataprovider_exception  = 20
      control_flush_error     = 21
      not_supported_by_gui    = 22
      error_no_gui            = 23
      OTHERS                  = 24.

  IF sy-subrc NE 0.
    MESSAGE e665 WITH t_fullpath.
  ENDIF.

ENDFORM.                    "pc_file_download


*&---------------------------------------------------------------------*
*&      Form  OPEN_UNIX_FILE
*&---------------------------------------------------------------------*
FORM open_unix_file USING u_file.

  MOVE u_file  TO  file1.

*** Encoding option must be removed for a non-unicode system

  CLEAR: t_encoding_u.

  IF NOT p_unicd IS INITIAL.
    MOVE p_uunicd  TO  t_encoding_u.
    OPEN DATASET file1 IN LEGACY TEXT MODE
                       FOR OUTPUT
                       CODE PAGE t_encoding_u.
  ELSE.

    OPEN DATASET file1  FOR OUTPUT
                        IN TEXT MODE
                        ENCODING DEFAULT.
  ENDIF.

**  OPEN DATASET file1  FOR OUTPUT
**                      IN TEXT MODE
**                      ENCODING DEFAULT.

  IF sy-subrc NE 0.
    MESSAGE e665 WITH file1.        " Error Opening Unix File
    EXIT.
  ENDIF.

ENDFORM.                    "open_unix_file

*&---------------------------------------------------------------------*
*&      Form  CLOSE_UNIX_FILE
*&---------------------------------------------------------------------*
FORM close_unix_file USING u_file.

  MOVE u_file  TO  file1.

  CLOSE DATASET file1.

ENDFORM.                    "close_unix_file


*&---------------------------------------------------------------------*
*&      Form  FRONT_PAGE
*&---------------------------------------------------------------------*
FORM front_page.

  DATA: f_cprog  LIKE  rsvar-report.     " Report Name

  f_cprog = sy-cprog.

  CALL FUNCTION 'RS_COVERPAGE_SELECTIONS'
    EXPORTING
      report            = f_cprog
      variant           = ' '
      no_import         = ' '
    TABLES
      infotab           = info
    EXCEPTIONS
      error_message     = 1
      variant_not_found = 3
      OTHERS            = 2.
*            others            = 4.

  IF sy-subrc EQ 0.

    LOOP AT info.

*    clean up blank lines and "No selections"
      IF info-line CS 'No selections'
      OR info-line+1(77) IS INITIAL.

        t_delete_index = sy-tabix - 1.
        DELETE info INDEX sy-tabix.
        READ TABLE info INDEX t_delete_index.

        IF NOT info-line+2(1) IS INITIAL.
          DELETE info INDEX t_delete_index.
        ENDIF.

        CONTINUE.

      ENDIF.

    ENDLOOP.

    SKIP.
    PERFORM write_cover.

  ENDIF.

ENDFORM.                    "front_page

*&---------------------------------------------------------------------*
*&      Form  FRONT_PAGE
*&---------------------------------------------------------------------*
FORM write_cover.

  LOOP AT info.

    IF info-line CS 'Invisible'.
      info-line = sy-uline.
      WRITE: / info-line.
      EXIT.
    ENDIF.
    WRITE: / info-line.

  ENDLOOP.

  NEW-PAGE.

ENDFORM.                    "write_cover

*&---------------------------------------------------------------------
*&      Form  GET_PC_TEMP_DIR
*&---------------------------------------------------------------------
FORM get_pc_temp_dir CHANGING $path TYPE localfile.   "path w/o filename


  DATA l_path TYPE string.  "path of gui work directory

  CLEAR $path.

* get the standard GUI work directory
*  CALL METHOD cl_gui_frontend_services=>get_sapgui_workdir
*    CHANGING
*      sapworkdir            = l_path
*    EXCEPTIONS
*      get_sapworkdir_failed = 1
*      cntl_error            = 2
*      error_no_gui          = 3
*      not_supported_by_gui  = 4
*      OTHERS                = 5.

  CHECK sy-subrc EQ 0.

* flush automation queue
  CALL METHOD cl_gui_cfw=>flush
    EXCEPTIONS
      cntl_system_error = 1
      cntl_error        = 2
      OTHERS            = 3.

  IF sy-subrc EQ 0.
    $path = l_path.
  ENDIF.

ENDFORM.                    "get_pc_temp_dir


*&---------------------------------------------------------------------
*&      Form  SEARCH_FOR_FILENAME
*&---------------------------------------------------------------------
FORM search_for_filename USING u_pcfile.

  REFRESH: t_file_table.

  t_dir = u_pcfile.

*  CALL METHOD cl_gui_frontend_services=>file_open_dialog
*    EXPORTING
*      default_filename        = t_dir
*    CHANGING
*      file_table              = t_file_table
*      rc                      = t_rc
*    EXCEPTIONS
*      file_open_dialog_failed = 1
*      cntl_error              = 2
*      error_no_gui            = 3
*      not_supported_by_gui    = 4
*      OTHERS                  = 5.

  IF sy-subrc EQ 0.
    READ TABLE t_file_table INTO t_filedat INDEX 1.
    u_pcfile = t_filedat.
  ENDIF.


ENDFORM.                    "search_for_filename


************************************************************************
*                       End of Program
************************************************************************
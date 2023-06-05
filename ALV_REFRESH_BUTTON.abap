REPORT z_demo_alv_refresh_button.
**********************************************************************
* REPORT Z_DEMO_ALV_REFRESH_BUTTON - ALV Grid with refresh button    *
*--------------------------------------------------------------------*
* Author : Michel PIOUD - Updated 19-Nov-07                          *
* HomePage : http://www.oocities.org/mpioud                         *
**********************************************************************
CONSTANTS :
  c_x VALUE 'X'.
*---------------------------------------------------------------------*
TYPE-POOLS: slis.                      " ALV Global Types

CONSTANTS :
  gc_refresh TYPE syucomm VALUE '&REFRESH'.

TYPES:
  BEGIN OF ty_mara,
    ernam TYPE mara-ernam,
    matnr TYPE mara-matnr,
    ersda TYPE mara-ersda,
    brgew TYPE mara-brgew,
  END OF ty_mara.

DATA:
  gt_mara TYPE TABLE OF ty_mara.

*---------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM f_read_data.

*---------------------------------------------------------------------*
END-OF-SELECTION.

  PERFORM f_display_data.

*---------------------------------------------------------------------*
*       Form  f_read_data
*---------------------------------------------------------------------*
FORM f_read_data.

  STATICS :
    l_rows TYPE i.

  ADD 1 TO l_rows.
  SELECT ernam matnr ersda brgew INTO TABLE gt_mara FROM mara
                                   UP TO l_rows ROWS.

  MESSAGE s208(00) WITH 'Reading data ...'.

ENDFORM.                               " F_READ_DATA
*---------------------------------------------------------------------*
*      Form  f_display_data
*---------------------------------------------------------------------*
FORM f_display_data.

  DEFINE m_fieldcat.
    add 1 to ls_fieldcat-col_pos.
    ls_fieldcat-fieldname = &1.
    ls_fieldcat-ref_tabname = 'MARA'.
    append ls_fieldcat to lt_fieldcat.
  END-OF-DEFINITION.

  DATA :
    ls_fieldcat   TYPE slis_fieldcat_alv,
    lt_fieldcat   TYPE slis_t_fieldcat_alv,
    lt_event_exit TYPE slis_t_event_exit,
    ls_event_exit TYPE slis_event_exit.

  m_fieldcat 'ERNAM'.
  m_fieldcat 'MATNR'.
  m_fieldcat 'ERSDA'.
  m_fieldcat 'BRGEW'.

  CLEAR ls_event_exit.
  ls_event_exit-ucomm = gc_refresh.    " Refresh
  ls_event_exit-after = c_x.
  APPEND ls_event_exit TO lt_event_exit.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program       = sy-cprog
      i_callback_pf_status_set = 'PF_STATUS_SET'
      i_callback_user_command  = 'USER_COMMAND'
      it_fieldcat              = lt_fieldcat
      it_event_exit            = lt_event_exit
    TABLES
      t_outtab                 = gt_mara.

ENDFORM.                               " F_DISPLAY_DATA
*---------------------------------------------------------------------*
*       FORM USER_COMMAND                                             *
*---------------------------------------------------------------------*
FORM user_command USING u_ucomm     TYPE sy-ucomm
                        us_selfield TYPE slis_selfield.     "#EC CALLED

  CASE u_ucomm.
    WHEN gc_refresh.
      PERFORM f_read_data.             " Refresh data
      us_selfield-refresh    = c_x.
      us_selfield-col_stable = c_x.
      us_selfield-row_stable = c_x.
  ENDCASE.

ENDFORM.                    "user_command
*---------------------------------------------------------------------*
*       FORM PF_STATUS_SET                                            *
*---------------------------------------------------------------------*
FORM pf_status_set USING ut_extab TYPE slis_t_extab.        "#EC CALLED

  DELETE ut_extab WHERE fcode = gc_refresh.

  SET PF-STATUS 'STANDARD_FULLSCREEN' OF PROGRAM 'SAPLKKBL'
      EXCLUDING ut_extab.

ENDFORM.                    "pf_status_set
********* END OF PROGRAM Z_DEMO_ALV_REFRESH_BUTTON ********************

*----------------------------------------------------------------*
* Program Name:  Actualizacion de Datos BP para CFDI 4.0
* Creation:      Octubre 2022
* SAP Name:      ZSD_BP_CFDI40
* Application:   ABAP
* Author:        Johan Rodriguez
*----------------------------------------------------------------*
* Description : Upload excel file to change the master data of BP
*----------------------------------------------------------------*

REPORT zsd_bp_cfdi40.

DATA: BEGIN OF lt_excel OCCURS 0.
        INCLUDE STRUCTURE alsmex_tabline.
DATA: END OF lt_excel.

DATA: wa_excel LIKE lt_excel,
      lv_row   TYPE char4 VALUE 0001.

TYPES: BEGIN OF st_bpdata,
         kunnr      TYPE char10,
         name1      TYPE char40,
         name2      TYPE char40,
         name3      TYPE char40,
         title_let  TYPE char50,
         post_code1 TYPE char10,
         zregfi     TYPE char6,
         zusocf     TYPE char3,
       END   OF st_bpdata.

TYPES: BEGIN OF st_log,
         kunnr     TYPE char10,
         message01 TYPE char220,
         message02 TYPE char220,
         message1  TYPE char220,
         message2  TYPE char220,
         message3  TYPE char220,
       END   OF st_log.

DATA: it_bpdata TYPE TABLE OF st_bpdata,
      wa_bpdata TYPE st_bpdata,
      it_log    TYPE TABLE OF st_log,
      wa_log    TYPE st_log.


* Declarations for BAPI_BUPA_CENTRAL_CHANGE
DATA: businesspartner           LIKE bapibus1006_head-bpartner,
      centraldata               LIKE bapibus1006_central,
      centraldataorganization   LIKE bapibus1006_central_organ,
      centraldata_x             LIKE bapibus1006_central_x,
      centraldataorganization_x LIKE bapibus1006_central_organ_x,
      duplicate_check_address   LIKE bapibus1006_address,
      lt_return                 TYPE TABLE OF bapiret2 WITH HEADER LINE.

* Declarations for BAPI_IDENTIFICATION_ADD
DATA: identificationcategory LIKE bapibus1006_identification_key-identificationcategory,
      identificationnumber   LIKE bapibus1006_identification_key-identificationnumber,
      identification         LIKE bapibus1006_identification,
      identification_x       LIKE bapibus1006_identification_x.

* Declaration for BAPI_BUPA_ADDRESS_CHANGE
DATA: addressdata   LIKE bapibus1006_address,
      addressdata_x LIKE bapibus1006_address_x.


*ALV Header
DATA: lt_header     TYPE slis_t_listheader,                      "Header del rep
      ls_header     TYPE slis_listheader,                        "Linea del header
      lt_line       LIKE ls_header-info,
      lv_lines      TYPE i,
      lv_linesc(10) TYPE c.

DATA: lf_sp_group TYPE slis_t_sp_group_alv,                     "Grupos de campos
      lf_layout   TYPE slis_layout_alv.                         "Diseño de layout

* Eventos
DATA: i_events TYPE slis_t_event,
      w_events TYPE slis_alv_event.

DATA: p_status TYPE slis_t_extab.                                   "ALV Status Button
DATA: alv_git_fieldcat TYPE slis_t_fieldcat_alv WITH HEADER LINE.   "Parametros del catalogo

SELECTION-SCREEN BEGIN OF BLOCK 01 WITH FRAME TITLE TEXT-001.
  PARAMETERS: filename TYPE rlgrap-filename.
SELECTION-SCREEN END OF BLOCK 01.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR filename.

  CALL FUNCTION 'F4_FILENAME'
    EXPORTING
      program_name  = syst-cprog
      dynpro_number = syst-dynnr
*     FIELD_NAME    = ' '
    IMPORTING
      file_name     = filename.

START-OF-SELECTION.

  REFRESH: lt_excel.

  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
    EXPORTING
      filename                = filename
      i_begin_col             = 1
      i_begin_row             = 2
      i_end_col               = 8
      i_end_row               = 9999
    TABLES
      intern                  = lt_excel
    EXCEPTIONS
      inconsistent_parameters = 1
      upload_ole              = 2
      OTHERS                  = 3.

  SORT lt_excel BY row col.
  CONDENSE lv_row.


  IF lt_excel IS NOT INITIAL.

    CLEAR: wa_excel, wa_bpdata.

    LOOP AT lt_excel INTO wa_excel.

      CASE wa_excel-row.

        WHEN lv_row.

          CASE wa_excel-col.
            WHEN '1'.
              wa_bpdata-kunnr      = wa_excel-value.
            WHEN '2'.
              wa_bpdata-name1      = wa_excel-value.
            WHEN '3'.
              wa_bpdata-name2      = wa_excel-value.
            WHEN '4'.
              wa_bpdata-name3      = wa_excel-value.
            WHEN '5'.
              wa_bpdata-title_let  = wa_excel-value.
            WHEN '6'.
              wa_bpdata-post_code1 = wa_excel-value.
            WHEN '7'.
              wa_bpdata-zregfi     = wa_excel-value.
            WHEN '8'.
              wa_bpdata-zusocf     = wa_excel-value.
          ENDCASE.

        WHEN OTHERS.

      ENDCASE.

      IF wa_excel-col EQ 8.

        APPEND wa_bpdata TO it_bpdata.
        CLEAR: wa_bpdata, wa_excel.

        lv_row = lv_row + 1.

      ENDIF.

    ENDLOOP.

  ELSE.
    MESSAGE i162(00) WITH 'Por favor seleccionar un archivo excel a cargar.'.
    STOP.

  ENDIF.

  DELETE it_bpdata WHERE kunnr IS INITIAL.

  IF it_bpdata IS NOT INITIAL.

    LOOP AT it_bpdata INTO wa_bpdata.

* Start BAPI for BP Basic Data
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = wa_bpdata-kunnr
        IMPORTING
          output = businesspartner.

      CONDENSE businesspartner.
      centraldata-titleletter                 = wa_bpdata-title_let.
      centraldataorganization-name1           = wa_bpdata-name1.
      centraldataorganization-name2           = wa_bpdata-name2.
      centraldataorganization-name3           = wa_bpdata-name3.
      centraldata_x-titleletter               = 'X'.
      centraldataorganization_x-name1         = 'X'.
      centraldataorganization_x-name2         = 'X'.
      centraldataorganization_x-name3         = 'X'.
      duplicate_check_address-standardaddress = 'X'.
*      duplicate_check_address-postl_cod1      = wa_bpdata-post_code1.


      CALL FUNCTION 'BAPI_BUPA_CENTRAL_CHANGE'
        EXPORTING
          businesspartner           = businesspartner
          centraldata               = centraldata
          centraldataorganization   = centraldataorganization
          centraldata_x             = centraldata_x
          centraldataorganization_x = centraldataorganization_x
          valid_date                = sy-datum
          duplicate_check_address   = duplicate_check_address
        TABLES
          return                    = lt_return.

      READ TABLE lt_return WITH KEY type = 'E'.
      IF sy-subrc EQ 0.
*         An error was found, no update was done
        MOVE lt_return-message TO wa_log-message01.
      ELSE.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = 'X'.
      ENDIF.
* End BAPI for BP Basic Data


* Start BAPI for BP Postal Code
      IF wa_bpdata-post_code1 IS NOT INITIAL.

        CLEAR: addressdata,
               addressdata_x,
               lt_return.
        REFRESH: lt_return.

        addressdata-postl_cod1        = wa_bpdata-post_code1.
        addressdata-standardaddress   = 'X'.
        addressdata_x-standardaddress = 'X'.
        addressdata_x-postl_cod1      = 'X'.

        CALL FUNCTION 'BAPI_BUPA_ADDRESS_CHANGE'
          EXPORTING
            businesspartner = businesspartner
            addressdata     = addressdata
            addressdata_x   = addressdata_x
          TABLES
            return          = lt_return.

        READ TABLE lt_return WITH KEY type = 'E'.
        IF sy-subrc EQ 0.
*         An error was found, no update was done
          MOVE lt_return-message TO wa_log-message02.
        ELSE.
          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
            EXPORTING
              wait = 'X'.
        ENDIF.
      ENDIF.
* End BAPI for BP Postal Code


* Start BAPI for ZREGFI
      CLEAR: identificationcategory,
             identificationnumber,
             lt_return.
      REFRESH: lt_return.

      identificationcategory = 'ZREGFI'.
      identificationnumber    = wa_bpdata-zregfi.

      CALL FUNCTION 'BAPI_IDENTIFICATION_ADD'
        EXPORTING
          businesspartner        = businesspartner
          identificationcategory = identificationcategory
          identificationnumber   = identificationnumber
          identification         = identification
        TABLES
          return                 = lt_return.

      READ TABLE lt_return WITH KEY type = 'E'.
      IF sy-subrc EQ 0.

*        An error was found.
        IF lt_return-message EQ 'Clase ID ZREGFI ya existe para interlocutor'.

          REFRESH: lt_return.
          CLEAR: lt_return.

          CALL FUNCTION 'BAPI_IDENTIFICATION_CHANGE'
            EXPORTING
              businesspartner        = businesspartner
              identificationcategory = identificationcategory
              identificationnumber   = identificationnumber
              identification         = identification
              identification_x       = identification_x
            TABLES
              return                 = lt_return.

          READ TABLE lt_return WITH KEY type = 'E'.
          IF sy-subrc EQ 0.
*            An error was found
            MOVE lt_return-message TO wa_log-message2.
          ELSE.
            CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
              EXPORTING
                wait = 'X'.
          ENDIF.

        ELSE.
          MOVE lt_return-message TO wa_log-message2.
        ENDIF.

      ELSE.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = 'X'.
      ENDIF.
* End BAPI for ZREGFI


* Start BAPI for ZUSOCF
      CLEAR: identificationcategory,
             identificationnumber,
             lt_return.
      REFRESH: lt_return.

      identificationcategory  = 'ZUSOCF'.
      identificationnumber    = wa_bpdata-zusocf.

      CALL FUNCTION 'BAPI_IDENTIFICATION_ADD'
        EXPORTING
          businesspartner        = businesspartner
          identificationcategory = identificationcategory
          identificationnumber   = identificationnumber
          identification         = identification
        TABLES
          return                 = lt_return.

      READ TABLE lt_return WITH KEY type = 'E'.
      IF sy-subrc EQ 0.
*         An error was found
        IF lt_return-message EQ 'Clase ID ZUSOCF ya existe para interlocutor'.

          REFRESH: lt_return.
          CLEAR: lt_return.

          CALL FUNCTION 'BAPI_IDENTIFICATION_CHANGE'
            EXPORTING
              businesspartner        = businesspartner
              identificationcategory = identificationcategory
              identificationnumber   = identificationnumber
              identification         = identification
              identification_x       = identification_x
            TABLES
              return                 = lt_return.

          READ TABLE lt_return WITH KEY type = 'E'.
          IF sy-subrc EQ 0.
*            An error was found.
            MOVE lt_return-message TO wa_log-message3.
          ELSE.
            CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
              EXPORTING
                wait = 'X'.
          ENDIF.

        ELSE.
          MOVE lt_return-message TO wa_log-message3.
        ENDIF.

      ELSE.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = 'X'.
      ENDIF.

      REFRESH: lt_return.
      CLEAR: lt_return.
* End BAPI for ZUSOCF


      MOVE businesspartner TO wa_log-kunnr.
      CONCATENATE wa_log-message01 wa_log-message02 INTO wa_log-message1 SEPARATED BY space.
      APPEND wa_log TO it_log.
      CLEAR: wa_log.

    ENDLOOP.

  ENDIF.

  DELETE it_log WHERE message1 EQ ''
                  AND message2 EQ ''
                  AND message3 EQ ''.

  IF it_log[] IS NOT INITIAL.

    PERFORM alv_report USING it_log[].

  ELSE.

    MESSAGE  'Los datos del BP han sido actualizados.' TYPE 'S'.
    STOP.

  ENDIF.

*≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈     ALV

FORM alv_report  USING  pp_itab LIKE it_log[].

  PERFORM sp_group_build USING lf_sp_group[].         " ALV PERFORM_1
  PERFORM alv_ini_fieldcat.                           " ALV PERFORM_2
  PERFORM layout_build USING lf_layout.               " ALV PERFORM_3
*  PERFORM do_events.
  PERFORM alv_listado USING it_log[].                " ALV PERFORM_4

ENDFORM.                    "alv_report

*≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈     ALV PERFORM_1
FORM sp_group_build USING u_lf_sp_group TYPE slis_t_sp_group_alv.

  DATA: ls_sp_group TYPE slis_sp_group_alv.
  CLEAR  ls_sp_group.
  ls_sp_group-sp_group = 'A'.
  ls_sp_group-text     = TEXT-010.
  APPEND ls_sp_group TO u_lf_sp_group.

ENDFORM.


*///////////////////////////////      ALV PERFORM_2
FORM alv_ini_fieldcat.

  "Cliente
  CLEAR alv_git_fieldcat.
  alv_git_fieldcat-fieldname   = 'KUNNR'.
  alv_git_fieldcat-seltext_m   = 'Codigo Cliente'.
  alv_git_fieldcat-col_pos     = 0.
  alv_git_fieldcat-sp_group    = 'A'.
  alv_git_fieldcat-outputlen   = '13'.
  APPEND alv_git_fieldcat TO alv_git_fieldcat.

*Mensaje 1
  CLEAR alv_git_fieldcat.
  alv_git_fieldcat-fieldname   = 'MESSAGE1'.
  alv_git_fieldcat-seltext_l   = 'Mensaje'.
  alv_git_fieldcat-col_pos     = 0.
  alv_git_fieldcat-sp_group    = 'A'.
  alv_git_fieldcat-outputlen   = '55'.
  APPEND alv_git_fieldcat TO alv_git_fieldcat.

*Mensaje 2
  CLEAR alv_git_fieldcat.
  alv_git_fieldcat-fieldname   = 'MESSAGE2'.
  alv_git_fieldcat-seltext_l   = 'Mensaje'.
  alv_git_fieldcat-col_pos     = 0.
  alv_git_fieldcat-sp_group    = 'A'.
  alv_git_fieldcat-outputlen   = '55'.
  APPEND alv_git_fieldcat TO alv_git_fieldcat.

*Mensaje 3
  CLEAR alv_git_fieldcat.
  alv_git_fieldcat-fieldname   = 'MESSAGE3'.
  alv_git_fieldcat-seltext_l   = 'Mensaje'.
  alv_git_fieldcat-col_pos     = 0.
  alv_git_fieldcat-sp_group    = 'A'.
  alv_git_fieldcat-outputlen   = '55'.
  APPEND alv_git_fieldcat TO alv_git_fieldcat.


ENDFORM.

*///////////////////////////////      ALV PERFORM_3
FORM layout_build USING    u_lf_layout TYPE slis_layout_alv.

*  u_lf_layout-box_fieldname       = 'CHECK'.  "Checkbox
  u_lf_layout-zebra               = 'X'.      "Streifenmuster
*  u_lf_layout-get_selinfos        = 'X'.
*  u_lf_layout-f2code              = 'BEAN' .  "Doppelklickfunktion
*  u_lf_layout-confirmation_prompt = 'X'.      "Sicherheitsabfrage
*  u_lf_layout-key_hotspot         = 'X'.      "Schlüssel als Hotspot
*  u_lf_layout-info_fieldname      = 'COL'.    "Zeilenfarbe

ENDFORM.

*///////////////////////////////      ALV PERFORM_4
FORM alv_listado  USING ppp_itab LIKE it_log[].

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_buffer_active        = 'X'
*     I_BACKGROUND_ID        = 'ALV_BACKGROUND'
      i_callback_top_of_page = 'TOP_OF_PAGE'
      i_callback_program     = sy-repid
*     i_callback_pf_status_set = 'PF_STATUS'
*     I_CALLBACK_USER_COMMAND  = 'USER_COMMAND'
      is_layout              = lf_layout
      it_fieldcat            = alv_git_fieldcat[]
*     it_special_groups      = lf_sp_group
      i_save                 = 'X'
    TABLES
      t_outtab               = ppp_itab.

ENDFORM.

*≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈     ALV HEADER
FORM top_of_page.

  CLEAR lt_header[].                                               " Limpia la tabla y no repite el header.

* Titulo
  ls_header-typ = 'H'.
  ls_header-info = 'Log de Errores BP'.
  APPEND ls_header TO lt_header.
  CLEAR: ls_header.

* Fecha
  ls_header-typ = 'S'.
  ls_header-key = 'Fecha: '.
  CONCATENATE sy-datum+6(2) '.'
              sy-datum+4(2) '.'
              sy-datum(4)
              INTO ls_header-info.                                     "Fecha de hoy concatenada y separada por "."
  APPEND ls_header TO lt_header.
  CLEAR: ls_header.

*No. Registros en el Reporte
  DESCRIBE TABLE it_bpdata LINES lv_lines.
  lv_linesc = lv_lines.
  CONCATENATE 'No.Total de Clientes no Actualizados: ' lv_linesc        "Concatenamos Cant. de Registros
  INTO lt_line SEPARATED BY space.
  ls_header-typ = 'A'.
  ls_header-info = lt_line.
  APPEND ls_header TO lt_header.
  CLEAR: ls_header, lt_line.


  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = lt_header.

ENDFORM.                    "top_of_page

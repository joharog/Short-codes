*&---------------------------------------------------------------------*
*&      Form  imprimir_alv
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form imprimir_alv.

  perform catalogo.

  call function 'REUSE_ALV_GRID_DISPLAY'
    exporting
      i_callback_program       = g_repid    "Nombre del programa
      it_fieldcat              = field[]    "Catalogo de Salida
      it_excluding             = i_excluding[]
      is_layout                = gs_layout  "Layout de Salida
*      I_DEFAULT                = 'X'
      it_events                = i_events
*      i_callback_pf_status_set = 'SET_STATUS'
      i_callback_user_command  = 'COMMAND'
*      it_event_exit            = t_event_exit
    tables
      t_outtab                 = itab       "Tabla Interna con los Datos
    exceptions
      program_error            = 1
      others                   = 2.
  if sy-subrc <> 0.
    message e162(00) with 'Problema al Imprimir el Reporte'.
  endif.

endform.                    "imprimir_alv


*&---------------------------------------------------------------------*
*&      Form  catalogo
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form catalogo.

  call function 'REUSE_ALV_FIELDCATALOG_MERGE'
    exporting
      i_program_name     = g_repid
      i_internal_tabname = 'ITAB'
      i_inclname         = g_repid
    changing
      ct_fieldcat        = field.

  loop at field into w_field.

   if w_field-fieldname = 'AUGBL'.
*      w_field-key       = 'X'.
      w_field-hotspot   = 'X'.
*      APPEND w_field TO itab.
   endif.
   modify field from w_field.
  endloop.

endform.                    " catalogo


*&---------------------------------------------------------------------*
*&      Form  command
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->UCOMM      text
*      -->SELFIELD   text
*----------------------------------------------------------------------*
form command using      ucomm like sy-ucomm
                     selfield type slis_selfield.

  case selfield-fieldname.
    when 'AUGBL'.
      read table itab index selfield-tabindex.
      set parameter id 'BLN' field itab-augbl.
      set parameter id 'BUK' field s_bukrs-low.
      set parameter id 'GJR' field s_gjahr-low.
      call transaction 'FB03' and skip first screen.
    endcase.

endform.                    "command

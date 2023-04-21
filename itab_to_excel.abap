FORM user_command USING lv_okcode LIKE sy-ucomm l_selfield TYPE slis_selfield.

  DATA: lv_action   TYPE i,
        lv_filename TYPE string,
        lv_fullpath TYPE string,
        lv_path     TYPE string.

  TYPES:BEGIN OF ty_header,
          pernr      TYPE c LENGTH 8,
          icnum      TYPE pa0185-icnum,
          ename      TYPE c LENGTH 40,
          bttyp      TYPE c LENGTH 2,
          ofccta     TYPE c LENGTH 3,
          num_cuenta TYPE c LENGTH 34,
          tipo       TYPE c LENGTH 1,
          cont       TYPE i,
          monto2     TYPE p DECIMALS 2.
  TYPES:END OF ty_header.


  DATA: it_columns TYPE if_fdt_doc_spreadsheet=>t_column.
  DATA: lv_header TYPE ty_header.
  DATA: it_excel TYPE TABLE OF ty_header.

  MOVE-CORRESPONDING ta_detalle[] TO it_excel[].

  lv_okcode = sy-ucomm.

  CASE lv_okcode.
    WHEN '&EXCEL'.

      TRY.
          DATA(o_desc) = CAST cl_abap_structdescr( cl_abap_structdescr=>describe_by_data( lv_header ) ).


          LOOP AT o_desc->get_components( ) ASSIGNING FIELD-SYMBOL(<c>).
            IF <c> IS ASSIGNED.
              IF <c>-type->kind = cl_abap_structdescr=>kind_elem.
                APPEND VALUE #( id           = sy-tabix
                                name         = <c>-name
                                display_name = <c>-name
                                is_result    = abap_true
                                type         = <c>-type ) TO it_columns.
              ENDIF.
            ENDIF.
          ENDLOOP.

          LOOP AT it_columns ASSIGNING FIELD-SYMBOL(<fs_columns>).
            CASE <fs_columns>-name.
              WHEN 'PERNR'.
                <fs_columns>-display_name = '# Empleado'.
              WHEN 'ICNUM'.
                <fs_columns>-display_name = '# CÈd.'.
              WHEN 'ENAME'.
                <fs_columns>-display_name = 'Nombre'.
              WHEN 'BTTYP'.
                <fs_columns>-display_name = '1-Corr/2-Ahorr'.
              WHEN 'OFCCTA'.
                <fs_columns>-display_name = 'OfcCta'.
              WHEN 'NUM_CUENTA'.
                <fs_columns>-display_name = '# Cuenta IBAN'.
              WHEN 'TIPO'.
                <fs_columns>-display_name = '4 DB / 2-CR'.
              WHEN 'CONT'.
                <fs_columns>-display_name = '# Doc.'.
              WHEN 'MONTO2'.
                <fs_columns>-display_name = 'Monto'.
            ENDCASE.
          ENDLOOP.

          DATA(lv_bin_data) = cl_fdt_xl_spreadsheet=>if_fdt_doc_spreadsheet~create_document( columns      = it_columns
                                                                                             itab         = REF #( it_excel )
                                                                                             iv_call_type = ' ' ). "if_fdt_doc_spreadsheet=>gc_call_dec_table

          IF xstrlen( lv_bin_data ) > 0.

            cl_gui_frontend_services=>file_save_dialog( EXPORTING default_file_name = ' '
                                                                  default_extension = 'xlsx'
                                                                  file_filter       = |Excel-File (*.xlsx)\|*.xlsx\|{ cl_gui_frontend_services=>filetype_all }|
                                                        CHANGING  filename          = lv_filename
                                                                  path              = lv_path
                                                                  fullpath          = lv_fullpath
                                                                  user_action       = lv_action ).


            " Convert xstring->solix (raw)
            IF lv_action EQ cl_gui_frontend_services=>action_ok.

              DATA(it_raw_data) = cl_bcs_convert=>xstring_to_solix( EXPORTING iv_xstring = lv_bin_data ).

              "GUI Download
              cl_gui_frontend_services=>gui_download( EXPORTING filename     = lv_fullpath
                                                                filetype     = 'BIN'
                                                                bin_filesize = xstrlen( lv_bin_data )
                                                      CHANGING  data_tab     = it_raw_data ).


            ENDIF.
          ENDIF.

        CATCH cx_root INTO DATA(e_text).

          MESSAGE e_text->get_text( ) TYPE 'I'.

      ENDTRY.

  ENDCASE.

ENDFORM.                    "USER_COMMAND

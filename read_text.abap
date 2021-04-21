FORM transportista  TABLES inttab STRUCTURE itcsy
                           outtab STRUCTURE itcsy.

  DATA: p_vbeln LIKE vbrk-vbeln.

  DATA: tlines    LIKE tline OCCURS 0 WITH HEADER LINE,
        wa_tlines LIKE tlines,
        wa_thead  LIKE thead.

  data: lv_tdname  type thead-tdname,
        lv_tdspras type thead-tdspras.

  DATA: w_transp TYPE tline-tdline.


  CLEAR: wa_thead-tdname, lv_tdname, lv_tdspras, wa_tlines.
  REFRESH: tlines.

  READ TABLE inttab INDEX 1.
  MOVE inttab-value TO p_vbeln.


  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
   EXPORTING
      input  = p_vbeln
   IMPORTING
      output = p_vbeln.


    IF p_vbeln IS NOT INITIAL.
       wa_thead-tdid     = 'Z013'.
       wa_thead-tdspras  = 'ES'.
       wa_thead-tdname   = p_vbeln.
       wa_thead-tdobject = 'VBBK'.


       SELECT SINGLE tdname tdspras
         FROM stxh
         INTO (lv_tdname, lv_tdspras)
         WHERE tdname   EQ wa_thead-tdname
           AND tdobject EQ 'VBBK'
           AND tdid     EQ 'Z013'.

         IF lv_tdname IS NOT INITIAL.

           CALL FUNCTION 'READ_TEXT'
           EXPORTING
            id                            = wa_thead-tdid
            language                      = lv_tdspras
            name                          = lv_tdname
            object                        = wa_thead-tdobject
          TABLES
            lines                         = tlines

                  .

           IF sy-subrc <> 0.
*             MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                   WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
           ENDIF.

           READ TABLE tlines INTO wa_tlines.
           IF sy-subrc EQ 0.
             w_transp = wa_tlines-tdline.
           ENDIF.

         ENDIF.

    ENDIF.


  READ TABLE outtab INDEX 1.
  MOVE w_transp TO outtab-value.
  MODIFY outtab INDEX 1.

ENDFORM.                    "TRANSPORTISTA

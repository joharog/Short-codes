DATA: p_vbeln  LIKE vbrk-vbeln,
      ls_stxh  TYPE stxh,
      lt_lines LIKE tline OCCURS 0 WITH HEADER LINE,
      ls_lines LIKE lt_lines.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = ls_vbdpl-vbeln
    IMPORTING
      output = p_vbeln.

  IF p_vbeln IS NOT INITIAL.

    CLEAR: ls_stxh, ls_lines.
    REFRESH: lt_lines.

    SELECT SINGLE * FROM stxh INTO ls_stxh
      WHERE tdname   EQ p_vbeln
        AND tdobject EQ 'VBBK'
        AND tdid     EQ 'Z002'.

    IF ls_stxh-tdname IS NOT INITIAL.
      CALL FUNCTION 'READ_TEXT'
        EXPORTING
          id       = ls_stxh-tdid
          language = ls_stxh-tdspras
          name     = ls_stxh-tdname
          object   = ls_stxh-tdobject
        TABLES
          lines    = lt_lines.

      READ TABLE lt_lines INTO ls_lines.
      IF sy-subrc EQ 0.
        gv_transportista = ls_lines-tdline.
      ENDIF.
    ENDIF.

  ENDIF.

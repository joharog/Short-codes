LOOP AT gt_docs ASSIGNING FIELD-SYMBOL(<fs_docs>).
  PERFORM sapgui_progreso.
ENDLOOP.

  
FORM sapgui_progreso .
  gf_numbertext = lin.
  gf_progresspercentage = sy-tabix * 100 / lineas.
  gf_progresstext = gf_progresspercentage.
  gf_tabix = sy-tabix.

  CONCATENATE 'Procesando datos' gf_progresstext '%'
              'Tratando'gf_tabix'de'gf_numbertext 'registro(s)'
  INTO gf_progresstext SEPARATED BY space.

  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = gf_progresspercentage
      text       = gf_progresstext.
ENDFORM.

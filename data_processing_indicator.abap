DATA: stabix type char10,
      total type i,
      stotal type char10,
      msg type char200.

  DESCRIBE TABLE lt_011zc LINES total.

  LOOP AT lt_011zc INTO ls_011zc.

    stabix = sy-tabix.

    "Mensage de procesamiento en tiempo de carga
    WRITE: sy-tabix TO stabix, total TO stotal.
    CONDENSE: stabix, stotal.
    CONCATENATE 'Procesando: cuentas' ls_011zc-VONKT(4) '[' stabix ' de ' stotal ']'  INTO msg SEPARATED BY space.
    cl_progress_indicator=>progress_indicate( EXPORTING
                               i_text               = msg
                               i_processed          = sy-tabix
                               i_total              = total
                               i_output_immediately =  'X' ).

 ENDLOOP.

  IF sy-subrc <> 0.
    DATA(l_id) = sy-msgid.
    DATA(l_no) = sy-msgno.
    DATA(l_v1) = sy-msgv1.
    DATA(l_v2) = sy-msgv2.
    DATA(l_v3) = sy-msgv3.
    DATA(l_v4) = sy-msgv4.

    DATA cmd TYPE ole2_object.
    DATA(code) = 'cmd /c powershell "[console]::beep(500,900)"'.
    CREATE OBJECT cmd 'SAPINFO' NO FLUSH.
    CALL METHOD OF cmd 'EXEC'
      EXPORTING
        #1 = code
        #2 = 0.

    MESSAGE ID l_id TYPE 'I' NUMBER l_no WITH l_v1 l_v2 l_v3 l_v4 DISPLAY LIKE 'E'.
  ENDIF.

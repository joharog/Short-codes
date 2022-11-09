Class: CL_COS_UTILITIES
Method: IS_S4H

 METHOD is_s4h.

    validate_gv_s4h( ).

    IF gv_s4h-public_cloud_on = abap_true.
      rv_is_s4h = abap_true.
    ELSE.
      rv_is_s4h = gv_s4h-on_premise_on.
    ENDIF.

    IF sy-tcode = 'SMARTFORMS' OR sy-tcode = 'SE71'.
      rv_is_s4h = abap_false.
    ENDIF.

  ENDMETHOD.

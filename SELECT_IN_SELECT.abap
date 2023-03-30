
SELECT *
FROM edocument
INTO @DATA(ls_edocument) WHERE source_key EQ '0000000000'.
  IF sy-subrc EQ 0.
    SELECT SINGLE * FROM vbrk INTO @DATA(ls_vbrk) WHERE vbeln EQ @ls_edocument-source_key.
    IF sy-subrc EQ 0.
      SELECT SINGLE * FROM kna1 INTO @DATA(ls_kna1) WHERE kunnr EQ @ls_vbrk-kunrg.
    ENDIF.
  ENDIF.

  SELECT SINGLE *
    FROM kna1 INTO @DATA(ls_kna1) 
    WHERE kunnr EQ ( SELECT kunrg FROM vbrk 
    WHERE vbeln EQ ( SELECT source_key FROM edocument 
    WHERE edoc_gui EQ lv_vbeln ) ).

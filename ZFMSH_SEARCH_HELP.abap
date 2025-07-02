// Funcion logica para implementar ayuda de busqueda en CustomFields
// atravez de 

Example:
Table: EBAN->CI_EBANDB->ZZWORK_ORDER
Explicit search help interface to field > ZSH_WORK_ORDER
Elementary Help: ZSH_WORK_ORDER 
Parameter: ZZWORK_ORDER |X X 1 1| ZMM_WORKORDER

Function Group: ZFGSH_WORK_ORDER
Function module: ZFMSH_WORK_ORDER

*"--------------------------------------------------------------------

FUNCTION zfmsh_work_order.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  TABLES
*"      SHLP_TAB TYPE  SHLP_DESCR_TAB_T
*"      RECORD_TAB STRUCTURE  SEAHLPRES
*"  CHANGING
*"     REFERENCE(SHLP) TYPE  SHLP_DESCR_T
*"     REFERENCE(CALLCONTROL) TYPE  DDSHF4CTRL
*"--------------------------------------------------------------------
  TYPE-POOLS: shlp.

  DATA: lt_aufk TYPE STANDARD TABLE OF aufk,
        ls_aufk TYPE aufk.

  IF lt_aufk[] IS INITIAL.

    SELECT * FROM aufk INTO TABLE lt_aufk.
    SORT lt_aufk BY aufnr.

    IF record_tab[] IS INITIAL.
      LOOP AT lt_aufk INTO ls_aufk.
        IF ls_aufk-aufnr IS NOT INITIAL.
          record_tab-string = ls_aufk-aufnr.
          APPEND record_tab.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.

  CLEAR: record_tab-string.

ENDFUNCTION.

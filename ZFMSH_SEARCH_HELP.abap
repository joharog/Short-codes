// Funcion logica para implementar ayuda de busqueda en Customfields

Example:
Table: EBAN->CI_EBANDB->ZZCUSTOMER
Explicit search help interface to field > ZSH_CUSTOMER
Elementary Help: ZSH_WORK_ORDER 
Parameter: ZZCUSTOMER	X X 1	1 X	ZMM_CUSTOMER
           NAME1	      X 2	2 X NAME1_GP
           NAME2	      X 3	3	X NAME2_GP

Function Group: ZFGSH_CUSTOMER
Function module: ZFMSH_CUSTOMER

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

* Nueva logica de busqueda documentacion funcional:
* MRO_STP_D-077.01 Custom fields PR_Func_and_Tec_Spec__EN_V002

  DATA: lt_iflo TYPE STANDARD TABLE OF iflo,
        lt_ihpa TYPE STANDARD TABLE OF ihpa,
        ls_kna1 TYPE kna1,
        lt_kna1 TYPE STANDARD TABLE OF kna1.

* Se creo la vista ZVS_TAIL_NUMBER para exportar el memory ID.
  DATA: tail_number TYPE zmm_tailnum30.

  IF callcontrol-step = 'DISP'.

    IMPORT tail_number FROM MEMORY ID 'TAIL_N'.
    IF lt_iflo[] IS INITIAL.
      SELECT * FROM iflo INTO TABLE lt_iflo
        WHERE tplnr EQ tail_number.
      IF sy-subrc EQ 0.
        SELECT * FROM ihpa INTO TABLE lt_ihpa
          FOR ALL ENTRIES IN lt_iflo
           WHERE objnr EQ lt_iflo-objnr
             AND parvw EQ 'AG'.
        IF sy-subrc EQ 0.
          SELECT * FROM kna1 INTO TABLE lt_kna1
            FOR ALL ENTRIES IN lt_ihpa
            WHERE kunnr EQ lt_ihpa-parnr(10).

          SORT lt_kna1 BY kunnr.
          LOOP AT lt_kna1 INTO ls_kna1.
            record_tab-string = |{ ls_kna1-kunnr } { ls_kna1-name1 } { ls_kna1-name2 }|.
            APPEND record_tab.
            CLEAR record_tab.
          ENDLOOP.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDIF.

  FREE MEMORY ID 'TAIL_N'.

ENDFUNCTION.

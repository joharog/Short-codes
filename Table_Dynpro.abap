PROCESS BEFORE OUTPUT.
 MODULE DISABLE_DELETE.
 MODULE LISTE_INITIALISIEREN.
 LOOP AT EXTRACT WITH CONTROL
  TCTRL_YMQA02MMTB001 CURSOR NEXTLINE.
   MODULE LISTE_SHOW_LISTE.
 ENDLOOP.
*
PROCESS AFTER INPUT.
 MODULE LISTE_EXIT_COMMAND AT EXIT-COMMAND.
 MODULE LISTE_BEFORE_LOOP.
 LOOP AT EXTRACT.
   MODULE LISTE_INIT_WORKAREA.
   CHAIN.
    FIELD YMQA02MMTB001-CONTRATO .
    FIELD YMQA02MMTB001-POSCONTRATO .
    FIELD YMQA02MMTB001-MATERIAL .
    FIELD YMQA02MMTB001-UMEDIDA .
    FIELD YMQA02MMTB001-PROVEEDOR .
    FIELD YMQA02MMTB001-ORGCOMPRA .
    FIELD YMQA02MMTB001-CENTRO .
    FIELD YMQA02MMTB001-MONEDA .
    FIELD YMQA02MMTB001-GRPCOMPRA .
    FIELD YMQA02MMTB001-SOCIEDAD .
    FIELD YMQA02MMTB001-TIPOSERV .
    FIELD YMQA02MMTB001-PRECBASE .
    FIELD YMQA02MMTB001-TARIFA .
    FIELD YMQA02MMTB001-FECHA_INICIO .
    FIELD YMQA02MMTB001-FECHA_FINAL .
    FIELD YMQA02MMTB001-FECHA_CREACION .
    FIELD YMQA02MMTB001-FECHA_MODIFICACION .
    FIELD YMQA02MMTB001-ACTIVO .
    MODULE SET_UPDATE_FLAG ON CHAIN-REQUEST.
    MODULE YMQAFIELD_VALIDATION ON CHAIN-REQUEST. <--- Modification
   ENDCHAIN.
   FIELD VIM_MARKED MODULE LISTE_MARK_CHECKBOX.
   CHAIN.
    FIELD YMQA02MMTB001-CONTRATO .
    FIELD YMQA02MMTB001-POSCONTRATO .
    MODULE LISTE_UPDATE_LISTE.
   ENDCHAIN.
 ENDLOOP.
 MODULE LISTE_AFTER_LOOP.



*----------------------------------------------------------------------*
***INCLUDE LYMQA02MMTB001I01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  YMQAFIELD_VALIDATION  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*

* SAPLYMQA02MMTB001 -- Update IN with this include

MODULE ymqafield_validation INPUT.
  TABLES: mara, lfm1, ekko, ekpo, t024, t001, t001w, marc, tcurc.

  DATA: lv_msg TYPE char255.
*  BREAK mqa_abap1.

  IF ymqa02mmtb001-contrato IS NOT INITIAL.
    SELECT SINGLE * FROM ekko WHERE ebeln EQ ymqa02mmtb001-contrato.
    IF sy-subrc NE 0.
      lv_msg =  | Contrato { ymqa02mmtb001-proveedor } no existe en la tabla EKPO |.
      MESSAGE lv_msg TYPE 'E'.
    ENDIF.

    IF ymqa02mmtb001-poscontrato EQ '00000'.
      lv_msg =  | Pos. Contrato no puede estar vacio |.
      MESSAGE lv_msg TYPE 'E'.
    ELSE.
      IF ymqa02mmtb001-poscontrato IS NOT INITIAL.
        SELECT SINGLE * FROM ekpo WHERE ebeln EQ ymqa02mmtb001-contrato AND ebelp EQ ymqa02mmtb001-poscontrato.
        IF sy-subrc NE 0.
          lv_msg =  | Pos. Contrato { ymqa02mmtb001-poscontrato } no existe para Contrato { ymqa02mmtb001-contrato }|.
          MESSAGE lv_msg TYPE 'E'.
        ENDIF.

        IF ymqa02mmtb001-centro IS NOT INITIAL.
*    SELECT SINGLE * FROM t001w WHERE werks EQ ymqa02mmtb001-centro.
          SELECT SINGLE * FROM ekpo
             WHERE ebeln EQ ymqa02mmtb001-contrato
               AND ebelp EQ ymqa02mmtb001-poscontrato
               AND werks EQ ymqa02mmtb001-centro.
          IF sy-subrc NE 0.
            lv_msg =  | Centro { ymqa02mmtb001-centro } no corresponde al contrato { ymqa02mmtb001-contrato } |.
            MESSAGE lv_msg TYPE 'E'.
          ENDIF.
        ENDIF.

        IF ymqa02mmtb001-material IS NOT INITIAL.
*      SELECT SINGLE * FROM mara WHERE matnr EQ ymqa02mmtb001-material.
          SELECT SINGLE * FROM ekpo
            WHERE matnr EQ ymqa02mmtb001-material
              AND ebeln EQ ymqa02mmtb001-contrato
              AND ebelp EQ ymqa02mmtb001-poscontrato.
          IF sy-subrc NE 0.
            lv_msg =  | Material { ymqa02mmtb001-material } no corresponde al contrato { ymqa02mmtb001-contrato } |.
            MESSAGE lv_msg TYPE 'E'.
          ENDIF.

          IF ymqa02mmtb001-umedida IS NOT INITIAL.
*            SELECT SINGLE * FROM mara WHERE meins EQ ymqa02mmtb001-umedida.
            SELECT SINGLE * FROM ekpo
              WHERE meins EQ ymqa02mmtb001-umedida
                AND ebeln EQ ymqa02mmtb001-contrato
                AND ebelp EQ ymqa02mmtb001-poscontrato.
            IF sy-subrc NE 0.
              lv_msg =  | UM base { ymqa02mmtb001-umedida } no existe no corresponde al contrato { ymqa02mmtb001-contrato } |.
              MESSAGE lv_msg TYPE 'E'.
            ENDIF.
          ENDIF.
        ELSE.
          MESSAGE 'Debe insertar un material valido' TYPE 'E'.
        ENDIF.
      ENDIF.
    ENDIF.


    IF ymqa02mmtb001-proveedor IS NOT INITIAL.
*      SELECT SINGLE * FROM lfm1 WHERE lifnr EQ ymqa02mmtb001-proveedor AND ekorg EQ ymqa02mmtb001-orgcompra.
      SELECT SINGLE * FROM ekko
        WHERE ebeln EQ ymqa02mmtb001-contrato
          AND lifnr EQ ymqa02mmtb001-proveedor.
      IF sy-subrc NE 0.
        lv_msg =  | Proveedor { ymqa02mmtb001-proveedor } no corresponde al contrato { ymqa02mmtb001-contrato } |.
        MESSAGE lv_msg TYPE 'E'.
      ENDIF.
    ENDIF.

    IF ymqa02mmtb001-orgcompra IS NOT INITIAL.
*      SELECT SINGLE * FROM lfm1 WHERE lifnr EQ ymqa02mmtb001-proveedor AND ekorg EQ ymqa02mmtb001-orgcompra.
      SELECT SINGLE * FROM ekko
         WHERE ebeln EQ ymqa02mmtb001-contrato
           AND ekorg EQ ymqa02mmtb001-orgcompra.
      IF sy-subrc NE 0.
        lv_msg =  | Org. Compras { ymqa02mmtb001-orgcompra } no corresponde al contrato { ymqa02mmtb001-contrato } |.
        MESSAGE lv_msg TYPE 'E'.
      ENDIF.
    ENDIF.

    IF ymqa02mmtb001-moneda IS NOT INITIAL.
*    SELECT SINGLE * FROM tcurc WHERE waers EQ ymqa02mmtb001-moneda.
      SELECT SINGLE * FROM ekko
     WHERE ebeln EQ ymqa02mmtb001-contrato
       AND waers EQ ymqa02mmtb001-moneda.
      IF sy-subrc NE 0.
        lv_msg =  | Moneda { ymqa02mmtb001-moneda } no corresponde al contrato { ymqa02mmtb001-contrato } |.
        MESSAGE lv_msg TYPE 'E'.
      ENDIF.
    ENDIF.
  ENDIF.

  IF ymqa02mmtb001-grpcompra IS NOT INITIAL.
    SELECT SINGLE * FROM t024 WHERE ekgrp EQ ymqa02mmtb001-grpcompra.
    IF sy-subrc NE 0.
      lv_msg =  | Gr. Compras { ymqa02mmtb001-grpcompra } no existe en la tabla T024 |.
      MESSAGE lv_msg TYPE 'E'.
    ENDIF.
  ENDIF.

  IF ymqa02mmtb001-sociedad IS NOT INITIAL.
    SELECT SINGLE * FROM t001 WHERE bukrs EQ ymqa02mmtb001-sociedad.
    IF sy-subrc NE 0.
      lv_msg =  | Gr. Compras { ymqa02mmtb001-sociedad } no existe en la tabla T001 |.
      MESSAGE lv_msg TYPE 'E'.
    ENDIF.
  ENDIF.

  IF ymqa02mmtb001-fecha_creacion IS NOT INITIAL.
    ymqa02mmtb001-fecha_modificacion = sy-datum.
  ENDIF.

  IF ymqa02mmtb001-fecha_creacion IS INITIAL .
    ymqa02mmtb001-fecha_creacion = sy-datum .
  ENDIF.

ENDMODULE.


* EVENT 01
FORM save_data_user.
  BREAK-POINT.


  DATA: lv_line TYPE string,
        lv_last TYPE c.

  DATA: lv_length TYPE i.

  " Program Z_REPORT_A
  DATA: lt_docs TYPE TABLE OF ymqa02mmtb001.
  " Fill lt_products with data


  IF <action> = 'U' OR <action> = 'N'.
    LOOP AT total_l.

      " Get the length of the string
      lv_length = ( strlen( total_l-line ) - 1 ).
      CASE total_l-line+lv_length(1).
        WHEN 'U' OR 'N'.

          APPEND VALUE #( contrato = total_l-line+4(10)
                          poscontrato =  total_l-line+14(5) )
                         TO lt_docs.
      ENDCASE.
    ENDLOOP.

    EXPORT lt_docs TO MEMORY ID 'YMQA_DOCS'.

  ENDIF.

ENDFORM.


*----------------------------------------------------------------------*
***INCLUDE LYMQA02MMTB001F02.
*----------------------------------------------------------------------*


FORM call_ws_componet.

  BREAK-POINT.
  COMMIT WORK.

  DATA: lt_docs TYPE TABLE OF ymqa02mmtb001.
  IMPORT lt_docs FROM MEMORY ID 'YMQA_DOCS'.


  SELECT * FROM ymqa02mmtb001 INTO TABLE @DATA(lt_doc_tar)
    FOR ALL ENTRIES IN @lt_docs
    WHERE contrato EQ  @lt_docs-contrato
      AND poscontrato EQ @lt_docs-poscontrato.



ENDFORM.


* DISABLE DELETE BUTTON
*----------------------------------------------------------------------*
***INCLUDE LYMQA02MMTB001O01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module DISABLE_DELETE OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE disable_delete OUTPUT.
* SET PF-STATUS 'xxxxxxxx'.
* SET TITLEBAR 'xxx'.
  BREAK-POINT.
  excl_cua_funct-function = 'DELE'.
  APPEND excl_cua_funct.

ENDMODULE.


*----------------------------------------------------------------------*
***INCLUDE LYMQA02MMTB001O02.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module DISABLE_DELETE OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE disable_delete OUTPUT.
* SET PF-STATUS 'xxxxxxxx'.
* SET TITLEBAR 'xxx'.

 EXCL_CUA_FUNCT-FUNCTION = 'DELE'.
 APPEND EXCL_CUA_FUNCT.
ENDMODULE.



* regenerated at 22.10.2025 13:45:24
*******************************************************************
*   System-defined Include-files.                                 *
*******************************************************************
  INCLUDE LYMQA02MMTB001TOP.                 " Global Declarations
  INCLUDE LYMQA02MMTB001UXX.                 " Function Modules

*******************************************************************
*   User-defined Include-files (if necessary).                    *
*******************************************************************
* INCLUDE LYMQA02MMTB001F...                 " Subroutines
* INCLUDE LYMQA02MMTB001O...                 " PBO-Modules
* INCLUDE LYMQA02MMTB001I...                 " PAI-Modules
* INCLUDE LYMQA02MMTB001E...                 " Events
* INCLUDE LYMQA02MMTB001P...                 " Local class implement.
* INCLUDE LYMQA02MMTB001T99.                 " ABAP Unit tests
  INCLUDE LYMQA02MMTB001F00                       . " subprograms
  INCLUDE LYMQA02MMTB001I00                       . " PAI modules
  INCLUDE LYMQA02MMTB001I01                       . "
  INCLUDE LSVIMFXX                                . " subprograms
  INCLUDE LSVIMOXX                                . " PBO modules
  INCLUDE LSVIMIXX                                . " PAI modules

INCLUDE lymqa02mmtb001o02.

INCLUDE lymqa02mmtb001f01.

INCLUDE lymqa02mmtb001f02.

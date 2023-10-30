DATA: lr_event_receiver TYPE REF TO lcl_eventhandler.
DATA: gr_grid1          TYPE REF TO cl_gui_alv_grid. ---> ALV CALL <---

CREATE OBJECT lr_event_receiver.
SET HANDLER lr_event_receiver->hotspot FOR gr_grid1.

CLASS lcl_eventhandler DEFINITION.

  PUBLIC SECTION.
        hotspot
          FOR EVENT hotspot_click OF cl_gui_alv_grid
          IMPORTING e_row_id
                    e_column_id
                    es_row_no.
    
ENDCLASS.                    "lcl_eventhandler DEFINITION

  
CLASS lcl_eventhandler IMPLEMENTATION.
  
  METHOD hotspot.
    READ TABLE gt_alv INTO gs_alv INDEX e_row_id.
    IF sy-subrc EQ 0.
      CASE e_column_id.
        WHEN 'VBELN'.   "Pedido
          SET PARAMETER ID 'AUN' FIELD gs_alv-vbeln.
          CALL TRANSACTION 'VA02' AND SKIP FIRST SCREEN.
        WHEN 'ENTREGA'. "Entrega
          SET PARAMETER ID 'VL' FIELD gs_alv-entrega.
          CALL TRANSACTION 'VL03N' AND SKIP FIRST SCREEN.
        WHEN 'FACT'.    "Nro. Factura
          SET PARAMETER ID 'VF' FIELD gs_alv-fact.
          CALL TRANSACTION 'VF03' AND SKIP FIRST SCREEN.
      ENDCASE.
    ENDIF.

  ENDMETHOD.                    "hotspot

ENDCLASS.                    "lcl_eventhandler IMPLEMENTATION

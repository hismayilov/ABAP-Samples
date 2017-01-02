*--------------------------------------------------------------------*
* Utku Y. ABAP Sample Codes
*--------------------------------------------------------------------*
* Description:
*   Sample -> simplified pop-up ALV
*--------------------------------------------------------------------*
* Change log:
*  02.01.2017 10:43:18 - UYEGEN
*--------------------------------------------------------------------*

REPORT zpopup_alv_test.

DATA: gt_flights TYPE TABLE OF sflight.

*----------------------------------------------------------------------*
*       CLASS cl_event_handler DEFINITION
*----------------------------------------------------------------------*
CLASS cl_event_handler DEFINITION.
  PUBLIC SECTION.

    CLASS-DATA:
      lo_popup TYPE REF TO cl_salv_table.
    CLASS-METHODS on_function_click
      FOR EVENT if_salv_events_functions~added_function
        OF cl_salv_events_table IMPORTING e_salv_function.
ENDCLASS.                    "cl_event_handler DEFINITION
*----------------------------------------------------------------------*
*       CLASS cl_event_handler IMPLEMENTATION
*----------------------------------------------------------------------*
CLASS cl_event_handler IMPLEMENTATION.
  METHOD on_function_click.
    CASE e_salv_function.
      WHEN 'GOON'.
        lo_popup->close_screen( ).
*       do action
      WHEN 'ABR'.
        lo_popup->close_screen( ).
*       cancel
    ENDCASE.
  ENDMETHOD.                    "on_function_click
ENDCLASS.                    "cl_event_handler IMPLEMENTATION


SELECTION-SCREEN: BEGIN OF BLOCK b1 WITH FRAME.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN PUSHBUTTON (20) text-001 USER-COMMAND show_popup_alv.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN: END OF BLOCK b1.

AT SELECTION-SCREEN.
  PERFORM push_button.

*--------------------------------------------------------------------*
*--------------------------------------------------------------------*
*--------------------------------------------------------------------*
*--------------------------------------------------------------------*
*--------------------------------------------------------------------*


*&---------------------------------------------------------------------*
*&      Form  PUSH_BUTTON
*----------------------------------------------------------------------*
FORM push_button .
  CASE sy-ucomm.
    WHEN 'SHOW_POPUP_ALV'.

      SELECT *
        FROM sflight
        INTO TABLE gt_flights.

*--------------------------------------------------------------------*
      DATA: lo_popup   TYPE REF TO cl_salv_table,
            lo_events  TYPE REF TO cl_salv_events_table,
            lo_columns TYPE REF TO cl_salv_columns_table,
            lo_column  TYPE REF TO cl_salv_column.
      TRY.
          CALL METHOD cl_salv_table=>factory
            IMPORTING
              r_salv_table = lo_popup
            CHANGING
              t_table      = gt_flights.

*     register handler for actions
          lo_events = lo_popup->get_event( ).
          SET HANDLER cl_event_handler=>on_function_click FOR lo_events.

*     save reference to access object from handler
          cl_event_handler=>lo_popup = lo_popup.

*     use gui-status ST850 from program SAPLKKB
          lo_popup->set_screen_status( pfstatus      = 'ST850'
                                       report        = 'SAPLKKBL' ).

          lo_columns ?= lo_popup->get_columns( ).
          lo_columns->set_optimize( value = 'X' ).

*     display as popup
          lo_popup->set_screen_popup( start_column = 10
                                      end_column   = 150
                                      start_line   = 5
                                      end_line     = 20 ).

*     filter fields
          lo_column ?= lo_columns->get_column( 'MANDT' ).
          IF lo_column IS BOUND.
            lo_column->set_technical( abap_true ). " 'X'
            FREE lo_column.
          ENDIF.


          lo_popup->display( ).

        CATCH cx_salv_msg.
*      WRITE: / 'Error: ALV exception CX_SALV_MSG'.
          MESSAGE 'Error: ALV exception CX_SALV_MSG' TYPE 'E' DISPLAY LIKE 'I'.
      ENDTRY.

    WHEN OTHERS.
  ENDCASE.
ENDFORM.                    " PUSH_BUTTON

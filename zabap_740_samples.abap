*--------------------------------------------------------------------*
* Utku Y. ABAP Sample Codes
*--------------------------------------------------------------------*
* Description:
*   Sample - ABAP 7.40 features
*--------------------------------------------------------------------*
* Change log:
*  04.01.2017 16:03:14 - BTC-UYEGEN
*--------------------------------------------------------------------*


REPORT zabap_740_samples.

CLASS cl_event_handler DEFINITION.
  PUBLIC SECTION.

    CLASS-DATA:
      lo_popup TYPE REF TO cl_salv_table.
    CLASS-METHODS on_function_click
      FOR EVENT if_salv_events_functions~added_function
        OF cl_salv_events_table IMPORTING e_salv_function.
ENDCLASS.
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
  ENDMETHOD.
ENDCLASS.

END-OF-SELECTION.
  PERFORM run_the_world.

*--------------------------------------------------------------------*
*--------------------------------------------------------------------*
*--------------------------------------------------------------------*
*--------------------------------------------------------------------*
*--------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  RUN_THE_WORLD
*----------------------------------------------------------------------*
FORM run_the_world .
  TYPES: BEGIN OF ty_selection_list,
           l TYPE char100,
         END OF ty_selection_list,
         tty_selection_list TYPE TABLE OF ty_selection_list WITH EMPTY KEY.
  DATA: lv_line_number   TYPE sy-tabix,
        lt_fidesc_option LIKE rsvbfidesc OCCURS 5 WITH HEADER LINE.

  DATA(lt_sel_list) = VALUE tty_selection_list(
                          ( l = '1. Get DB values into ITAB with inline DATA declaration' )
                          ( l = '2. Get DB values with cased values (this support only EQ operand)' )
                          ( l = '3. Concatenate with inline declaration' )
                          ( l = '4. Change value with Constructor Operator REF' )
                          ( l = '5. Crate and fill typical range with FOR' )
                          ( l = '6. Sample usage for FOR statement' )
                        ).

  CLEAR lt_fidesc_option. REFRESH lt_fidesc_option.
  MOVE 1   TO lt_fidesc_option-fieldnum.
  MOVE 'X' TO lt_fidesc_option-display.
  APPEND lt_fidesc_option.

  CALL FUNCTION 'RS_VALUES_BOX'
    EXPORTING
      left_upper_col       = 10
      left_upper_row       = 5
      title                = 'Choose wisely!'
    IMPORTING
      linenumber           = lv_line_number
    TABLES
      field_desc           = lt_fidesc_option
      value_tab            = lt_sel_list
    EXCEPTIONS
      clear_contents       = 1
      invalid_coordinates  = 2
      invalid_field_number = 3
      no_action            = 4
      no_fields            = 5
      no_markfield         = 6
      process_user_action  = 7
      value_tab_empty      = 8
      value_tab_too_long   = 9
      OTHERS               = 10.

  CASE lv_line_number.
    WHEN 1. " Get DB values into ITAB with inline DATA declaration
      SELECT * FROM sflight INTO TABLE @DATA(lt_1) ORDER BY carrid, connid.
      PERFORM show_popup_alv USING lt_1 'ABAP - 7.40 : S.00001'.

    WHEN 2. " Get DB values with cased values (this support only EQ operand)
      SELECT carrid, connid,
             price,
             CASE
               WHEN carrid EQ 'AA' THEN price * 2
               WHEN carrid EQ 'AZ' THEN price * 3
               ELSE price * 1
             END AS multiplied_price
        FROM sflight INTO TABLE @DATA(lt_2) ORDER BY fldate DESCENDING.
      PERFORM show_popup_alv USING lt_2 'ABAP - 7.40 : S.00002'.

    WHEN 3. " Concatenate with inline declaration
      SELECT SINGLE * FROM sflight INTO @DATA(ls_3).
      DATA(lv_concatenated_value) = |{ ls_3-carrid }`s price is { ls_3-price } { ls_3-currency }|.
      WRITE:/ lv_concatenated_value.

    WHEN 4. " Change value with Constructor Operator REF
      SELECT SINGLE * FROM sflight INTO @DATA(ls_4).
      WRITE:/ |Before multiply with REF param, SEATSMAX is: { ls_4-seatsmax }|.
      DATA(lv_seatsmax) = REF #( ls_4-seatsmax ).
      lv_seatsmax->* = lv_seatsmax->* * 2.
      WRITE:/ |After multiply with REF param, SEATSMAX is: { ls_4-seatsmax }|.

    WHEN 5. " Crate and fill typical range
      DATA: ra_char10 TYPE RANGE OF char10.
      ra_char10 = VALUE #( FOR i = 1 WHILE i <= 100 ( sign = 'I' option = 'EQ' low = i ) ).
      PERFORM show_popup_alv USING ra_char10 'ABAP - 7.40'.

    WHEN 6. " Sample usage for FOR statement
      SELECT * UP TO 10 ROWS FROM sflight INTO TABLE @DATA(lt_6_flight).
      SELECT *               FROM scarr   INTO TABLE @DATA(lt_6_scarr).

      TYPES: BEGIN OF ty6,
               carrid TYPE sflight-carrid,
               fldate TYPE sflight-fldate,
             END OF ty6.
      TYPES: tty6 TYPE STANDARD TABLE OF ty6 WITH EMPTY KEY.
      TYPES: BEGIN OF ty6_1,
               " SCarr
               carrname         TYPE scarr-carrname,

               " SFlight
               connid           TYPE sflight-connid,
               fldate           TYPE sflight-fldate,
               price            TYPE sflight-price,
               currency         TYPE sflight-currency,
               planetype        TYPE sflight-planetype,

               " Multiplied
               multiplied_price TYPE sflight-price,
             END OF ty6_1.
      TYPES: tty6_1 TYPE STANDARD TABLE OF ty6_1 WITH EMPTY KEY.

      DATA(lt_6_new1) = VALUE tty6( FOR ls_6 IN lt_6_flight ( carrid = ls_6-carrid fldate = ls_6-fldate ) ).
      PERFORM show_popup_alv USING lt_6_new1 'ABAP - 7.40 : Non-Filtered'.

      DATA(lt_6_new2) = VALUE tty6( FOR ls_6 IN lt_6_flight WHERE ( fldate > '20170101' ) ( carrid = ls_6-carrid fldate = ls_6-fldate ) ).
      PERFORM show_popup_alv USING lt_6_new2 'ABAP - 7.40 : Filtered'.

      DATA(lt_6_new3) = VALUE tty6_1( FOR ls_sflight IN lt_6_flight
                                      FOR ls_scarr   IN lt_6_scarr WHERE ( carrid = ls_sflight-carrid )
                                      ( carrname         = ls_scarr-carrname
                                        connid           = ls_sflight-connid
                                        fldate           = ls_sflight-fldate
                                        price            = ls_sflight-price
                                        currency         = ls_sflight-currency
                                        planetype        = ls_sflight-planetype
                                        multiplied_price = ls_sflight-price * 3 ) ).
      PERFORM show_popup_alv USING lt_6_new3 'ABAP - 7.40 : Mixed'.

  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SHOW_POPUP_ALV
*&---------------------------------------------------------------------*
*       Shows input table as pop-up alv
*----------------------------------------------------------------------*
FORM show_popup_alv  USING ut_alv_data
                           uv_title.
  DATA: lo_popup            TYPE REF TO cl_salv_table,
        lo_events           TYPE REF TO cl_salv_events_table,
        lo_columns          TYPE REF TO cl_salv_columns_table,
        lo_column           TYPE REF TO cl_salv_column,
        lo_display_settings TYPE REF TO cl_salv_display_settings.
  TRY.
      CALL METHOD cl_salv_table=>factory
        IMPORTING
          r_salv_table = lo_popup
        CHANGING
          t_table      = ut_alv_data.

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

*     title
      lo_display_settings ?= lo_popup->get_display_settings( ).
      lo_display_settings->set_list_header( uv_title ).

*     display as popup
      lo_popup->set_screen_popup( start_column = 10
                                  end_column   = 150
                                  start_line   = 5
                                  end_line     = 20 ).

*     filter fields
      TRY .
          lo_column ?= lo_columns->get_column( 'MANDT' ).
          IF lo_column IS BOUND.
            lo_column->set_technical( abap_true ). " 'X'
            FREE lo_column.
          ENDIF.
        CATCH cx_salv_not_found.
      ENDTRY.

      lo_popup->display( ).

    CATCH cx_salv_msg.
*      WRITE: / 'Error: ALV exception CX_SALV_MSG'.
      MESSAGE 'Error: ALV exception CX_SALV_MSG' TYPE 'E' DISPLAY LIKE 'I'.
  ENDTRY.
ENDFORM.
